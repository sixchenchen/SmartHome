# WM_LAOHUA · 物联网设备管理平台

> Spring Boot 多模块服务端，负责 **设备注册发证、在线状态管理、指令下发与 ACK、OTA 固件升级、固件托管、传感器数据、设备白名单**，与 ESP32 设备固件（ESP-IDF）通过 MQTT 双 Broker 通信，并对外提供 HTTP REST 接口。

| 项目 | 值 |
| :--- | :--- |
| 构建 | Maven 多模块（`common-module` / `business-module` / `web-module`） |
| 运行入口 | `web-module` · `WebModuleApplication` |
| HTTP | 端口 **8080**，上下文路径 **/api** |
| MQTT 运行 Broker | `ssl://192.168.1.15:8883`（设备业务） |
| MQTT 注册 Broker | `ssl://192.168.1.15:8884`（设备发证） |
| 数据库 / 缓存 | MySQL `smart_device` · Redis（nonce 防重放） |
| 协议版本 | v4.0（对齐设备侧固件） |

---

## 一、功能特性

### 1. 设备注册与安全发证（Provisioning）
设备首次上电/恢复出厂时，连接**独立注册 Broker（8884）**报到，换取正式运行凭据后切换到 8883。

- **四重安全机制**：
  | 机制 | 作用 |
  | :--- | :--- |
  | `pubkey`（ECDSA P-256） | 设备身份标识，服务端用它验签；首次注册即绑定，防止他人冒充同一 MAC |
  | `signature` | 设备私钥签名 `device\|timestamp\|nonce`，证明公钥归属 |
  | `nonce` + Redis | 一次性随机数，5 分钟内防重放，使用 `setIfAbsent` 原子占位 |
  | `timestamp` | 毫秒时间戳，校验 ±5 分钟，防过期重放 |
- **重复注册策略**：同设备重启/网络重试允许换新密码；`pubkey` 不一致（疑似冒充或换密钥）拒绝并返回 `DEVICE_ALREADY_REGISTERED`。
- **白名单**（`device_whitelist`）：未在白名单的设备直接拒绝注册。
- **凭据生成**：`clientId=device-{mac}`、`username=dev_{mac}`、`password=UUID 去横线前 16 位`，落库 `mqtt_auth`（`salt` + `SHA-256(salt+password)`，供 EMQX 认证）。

### 2. 设备在线状态管理
- 统一 **`presence`** 主题承载上线/下线：`type=online` 走 `markOnline`，`type=offline` 走 `markOffline`。
- 离线原因枚举 `OfflineReason`：`shutdown`（正常关机）、`factory_reset`、`mqtt_lwt`（遗嘱/异常断线）、`heartbeat_timeout`（心跳超时）、`manual`。
- **心跳保活**：`heartbeat` 更新 `uptime`/`last_heartbeat_time` 并写 `heartbeat_record`；超过 `60s` 未收到心跳由定时任务判离线（阈值 = 3 个心跳周期）。
- **遗嘱（LWT）**：由注册响应下发 `will` 配置，设备异常断线由 Broker 代发离线。

### 3. 指令下发与 ACK 状态机
- HTTP 下发 → 入库 `device_command` → MQTT 发布 `device/{mac}/command` → 设备回 `ack` → 状态机收敛。
- **状态机**：`PENDING(0) → SENT(1) → SUCCESS(2) / FAILED(3)`，另有 `TIMEOUT(4)`、`CANCELLED(5)`、`ACCEPTED(6)`。
- **ACK 决策**（`DeviceCommandServiceImpl`）：按「是否 OTA 最终 ACK / 是否接收确认 / 是否终态」分支流转；终态幂等，不重复处理。
- **可靠性**：下发失败保持 `PENDING` 由定时器兜底；超时未 ACK 自动重试（`MAX_RETRY=3`）；到期未完成置 `TIMEOUT`；支持手动取消。
- **开关类指令复用 `data.state`**（MOS/LED 等 0/1），OTA 确认使用独立字段 `data.otaState`，避免语义冲突。

### 4. OTA 固件升级（三重收敛）
- **触发**：`POST /api/ota/start`，服务端校验「设备存在 → 无进行中的 OTA → 固件存在且启用 → 版本不同」，组装参数下发 `action=start, target=ota`，并允许同版本跳过。
- **进度上报**：设备经 **`ota_progress`** 主题上报 `accepted / downloading / verifying / flashing / success / failed` 与 `progress`（0–100）、`version`，写入 `device_info.ota_state / ota_progress / ota_version`。
- **版本收敛双保险**：`firmware` 字段只由设备上报驱动，两条路径共用同一幂等方法 `syncFirmwareIfTarget`：
  1. **最终 ACK 路径** —— ACK 携带 `toVersion` 时同步；
  2. **进度路径** —— `ota_progress` 上报 `success` 时同步。
  同步采用**带前置条件的定向更新**（`WHERE firmware <> ?`），幂等且不覆盖并发字段。
- **回滚校验兜底**：设备重启后经 `presence` 上报实际运行版本，若「已声明 success 但实际版本 ≠ 目标版本」判定升级回滚，置 `ota_state=failed`。
- **僵死清理**：OTA 指令超时置 `TIMEOUT` 并清理卡住的 `ota_state`；`ota_update_time` 超过 5 分钟未更新视为僵死。
- **并发安全**：`device_info` 的 OTA 相关写入全部改为**定向字段 UPDATE**，避免整行 `updateById` 造成并发字段丢失。

### 5. 固件管理
- 上传固件（`multipart`，16MB 上限）→ 落盘 → 计算 `md5` + `sha256` → 入库 `firmware`。
- 支持列表查询、删除；生成可下载 URL 供 OTA 指令下发（`firmware.base-url` + 文件名）。
- 文件名规则 `firmware_%s_%s.bin`（版本 + 时间）。

### 6. 传感器与从机数据
- `device_sensor`：设备传感器登记（类型、单位、量程、来源）。
- `sensor_record`：传感器采样记录（含从机地址、通道、`sensorKey`、原始值）。
- `sensor_threshold`：阈值与告警配置（`min/max`、`warnMin/warnMax`、告警级别与文案、持续时间）。
- `device_slave_data`：Modbus/从机通道数据（地址、类型、在线时刻、值、单位）。

### 7. 数据记录
| 表 | 内容 |
| :--- | :--- |
| `heartbeat_record` | 心跳历史（`uptime`、`payload`） |
| `device_state_record` | 设备状态变更（`target`、`channel`、`params`） |
| `device_event_record` | 设备事件（`event`、`code`、`message`、`triggerSource`、`context`） |
| `sensor_record` | 传感器采样历史 |

### 8. 定时任务与数据保留
| 任务 | 频率 | 职责 |
| :--- | :--- | :--- |
| 心跳超时扫描 | 每 **30s** | 超 `60s` 未心跳判离线 |
| 待下发扫描 | 每 **1s** | 抓取 `PENDING` 指令下发（OTA 指令已排除，防重复下载） |
| 超时重试 | 每 **3s** | 超 `5s` 未 ACK 重发（最多 3 次） |
| 过期标记 | 每 **30s** | 到期未完成置 `TIMEOUT` |
| OTA 过期标记 | 每 **5s** | OTA 指令超时处理 + 清理僵死状态 |
| 历史清理 | 每天 **02:00** | 清理 30 天前终态指令 |

保留策略：历史原始数据 **30 天**；单批处理 **50** 条。

### 9. 统一异常与响应
- HTTP 统一返回 `ApiResponse{code, message, data, timestamp}`。
- 全局异常处理 `GlobalExceptionHandler` 覆盖业务异常、参数异常、上传超限、文件异常、系统异常等 8 类。
- 错误码：HTTP `ErrorCode`（参数/业务/文件/固件/设备/OTA/系统）与 MQTT 注册 `MqttErrorCode` 双体系。

---

## 二、技术栈与模块结构

```
WM_LAOHUA
├── common-module      公共层：常量/枚举/工具/异常/响应（不依赖 DB、Web、MQTT）
├── business-module    业务层：实体 / Mapper / Service（设备、指令、OTA、传感器、认证）
└── web-module         接入层：HTTP Controller / MQTT 收发 / 定时任务 / 配置（可运行模块）
```

依赖方向：`web-module → business-module → common-module`（单向，无循环）。

| 模块 | 关键依赖 |
| :--- | :--- |
| common-module | Lombok、Jackson、BouncyCastle（ECDSA 验签） |
| business-module | MyBatis-Plus、MySQL、Spring Tx |
| web-module | Spring Web、Spring Integration MQTT（Paho）、Redis、Druid |

**通用常量收敛于 `common-module/.../constants/`**：
`MqttConstants`（主题/字段/header）、`CommandConstants`、`DeviceConstants`、`FirmwareConstants`、`FileConstants`、`HttpStatusConstants`、`RegexConstants`、`ErrorInfoConstants`、`OtaStateConstants`。

**枚举**：`CommandStatus`、`OfflineReason`、`MqttErrorCode`、`ErrorCode`。

**工具**：`JsonUtils`、`SignatureVerifierUtils`、`TimestampValidatorUtils`、`DateTimeUtils`、`SaltPasswordUtils`、`OtaStateUtils`。

---

## 三、快速开始

### 1. 环境准备
- JDK 17+、Maven、MySQL 8、Redis、EMQX 5.x

### 2. 初始化数据库
```bash
mysql -uroot -p < web-module/src/main/resources/sql/smart_device.sql
```

### 3. 修改配置
编辑 `web-module/src/main/resources/application-dev.yml`：数据库/Redis 连接、MQTT 双 Broker 地址与账号、`firmware.upload-dir` 与 `firmware.base-url`。

### 4. 启动
```bash
mvn clean package
java -jar web-module/target/web-module-*.jar
# 或
mvn -pl web-module spring-boot:run
```
服务地址：`http://localhost:8080/api`

---

## 四、MQTT 通信协议

### 4.1 双 Broker 双通道

| 通道 | Broker | ClientId | 订阅主题 | QoS |
| :--- | :--- | :--- | :--- | :--- |
| **runtime**（业务） | `ssl://192.168.1.15:8883` | `wm-laohua-server-dev` | `device/+/presence`、`heartbeat`、`state`、`ack`、`event`、`sensor`、`ota_progress` | 1,0,1,1,1,0,0 |
| **provision**（注册） | `ssl://192.168.1.15:8884` | `wm-laohua-provision-dev` | `/provision/device/+/register` | 1 |

**入站链路**：
```
MqttPahoMessageDrivenChannelAdapter
  → runtimeInputChannel / provisionInputChannel
  → MqttMessageReceiver（提取 mqtt_receivedTopic / mqtt_receivedQos）
  → MqttMessageRouter.route() → 命中 supports() 的 Handler
```
**出站链路**：`MqttPahoMessageHandler(runtimeOutputChannel / provisionOutputChannel)`，经 header `mqtt_topic / mqtt_qos / mqtt_retained` 透传发布参数。

**主题解析**（`MqttMessageHandler` 默认方法）：`extractDeviceId` 取 `device/{mac}/{type}` 的 `parts[1]`；`extractProvisionDeviceId` 取 `/provision/device/{mac}/register` 的 `parts[3]`。

### 4.2 已实现的处理器

| Handler | Order | 主题 | 职责 |
| :--- | :--- | :--- | :--- |
| `DeviceRegisterMessageHandler` | — | `/provision/device/+/register` | 注册验签、发证、回 `/config` |
| `PresenceMessageHandler` | 1 | `device/+/presence` | 上线 `markOnline` + OTA 回滚校验；下线 `markOffline` |
| `HeartbeatMessageHandler` | — | `device/+/heartbeat` | 更新心跳 + 写心跳历史 |
| `AckMessageHandler` | — | `device/+/ack` | 指令 ACK → 状态机流转 |
| `OtaProgressMessageHandler` | — | `device/+/ota_progress` | OTA 进度落库 + 成功同步固件版本 |

> `state` / `event` / `sensor` 三个主题**已订阅但尚未接入处理器**（常量与字段定义已就绪），当前消息在 `MqttMessageRouter` 中会被记为「未找到匹配的处理器」。接入时新增对应 Handler 即可。

### 4.3 注册请求（设备 → 服务器）

**Topic：`/provision/device/{mac}/register`**（QoS=1）

```json
{
  "device": "B4BFE90CDBA0",
  "product": "SmartHome-v1",
  "type": "register",
  "timestamp": 1791444733387,
  "data": {
    "firmware": "1.0.29",
    "chip": "ESP32",
    "hardware_version": "V1.0",
    "nonce": "550e8400-e29b-41d4-a716-446655440000",
    "pubkey": "-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE...==\n-----END PUBLIC KEY-----\n",
    "signature": "MEUCIQDxYzEJnlxwvz+O4gteyR1PrT4WxY8Pf5h0..."
  }
}
```

| 字段 | 类型 | 必填 | 说明 |
| :--- | :--- | :--- | :--- |
| device | string | 是 | MAC（12 位大写十六进制，无冒号，`^[0-9A-F]{12}$`） |
| product | string | 是 | 产品型号 |
| type | string | 是 | 固定 `"register"` |
| timestamp | long | 是 | 毫秒时间戳（±5 分钟） |
| data.firmware | string | 是 | 固件版本 |
| data.chip | string | 否 | 芯片型号 |
| data.hardware_version | string | 否 | 硬件版本 |
| data.nonce | string | 是 | 随机 UUID，每次唯一 |
| data.pubkey | string | 是 | PEM 公钥（ECDSA P-256） |
| data.signature | string | 是 | Base64 签名 |

**校验顺序**：MAC 格式 → 白名单 → 已注册 pubkey 一致性 → `timestamp` → `nonce`（Redis）→ `pubkey` 验签。
**签名原文**：`signData = deviceId + "|" + timestamp + "|" + nonce`，算法 `SHA256withECDSA`。

### 4.4 注册响应（服务器 → 设备）

**Topic：`/provision/device/{mac}/config`**（QoS=1，不保留）

**成功**
```json
{
  "device": "B4BFE90CDBA0",
  "success": true,
  "mqtt": {
    "host": "192.168.1.15", "port": 8883,
    "clientId": "device-B4BFE90CDBA0",
    "username": "dev_B4BFE90CDBA0",
    "password": "e2e1c28ef5d9489b",
    "keepAlive": 60
  },
  "will": {
    "topic": "device/B4BFE90CDBA0/will", "qos": 1, "retain": true,
    "payload": {
      "device": "B4BFE90CDBA0", "type": "offline", "timestamp": 0,
      "data": { "reason": "mqtt_lwt" }
    }
  },
  "config": { "heartbeat_interval": 30, "sensor_batch_size": 32 },
  "timestamp": 1791444746640
}
```

**失败**
```json
{ "device": "B4BFE90CDBA0", "success": false, "error": "INVALID_SIGNATURE", "message": "签名验证失败", "timestamp": 1791444746640 }
```

**注册错误码（`MqttErrorCode`）**

| 错误码 | 含义 | 设备处理 |
| :--- | :--- | :--- |
| `INVALID_DEVICE_ID` | MAC 格式不对 | 检查固件 |
| `PARAM_MISSING` | 必填参数缺失 | 检查固件 |
| `INVALID_TIMESTAMP` | 时间戳超窗口 | 同步 NTP 后重试 |
| `REPLAY_ATTACK` | nonce 重复 | 换新 nonce 重试 |
| `INVALID_SIGNATURE` | 验签失败 | 检查密钥对 |
| `INVALID_PUBKEY` | 公钥非法 | 检查密钥对 |
| `DEVICE_ALREADY_REGISTERED` | pubkey 不匹配（疑似冒充） | 停止重试，人工介入 |
| `DEVICE_BLACKLISTED` | 设备被拉黑 | 停止重试 |
| `FIRMWARE_TOO_OLD` | 固件过旧 | 升级固件 |
| `DEVICE_NOT_REGISTERED` | 设备未注册 | 重试注册 |
| `INVALID_PAYLOAD` / `SERVER_ERROR` | 报文错误 / 服务器异常 | 等待重试 |

### 4.5 上行消息

#### ① 在线状态 `device/{mac}/presence`（QoS=1）

```json
{
  "device": "B4BFE90CDBA1",
  "type": "online",
  "timestamp": 1710000000000,
  "data": {
    "product": "SmartHome-v1",
    "firmware": "1.0.36",
    "capabilities": { "mos": 8, "led": 3, "servo": 2 }
  }
}
```

- `type=online` → `markOnline(deviceId, product, firmware, capabilities)`，随后做 **OTA 回滚校验**。
- `type=offline` → `markOffline`，`data.reason` 缺省为 `mqtt_lwt`。

```json
{ "device": "B4BFE90CDBA1", "type": "offline", "timestamp": 1710000000000, "data": { "reason": "shutdown" } }
```

#### ② 心跳 `device/{mac}/heartbeat`（QoS=0）

```json
{
  "device": "B4BFE90CDBA1",
  "type": "heartbeat",
  "timestamp": 1791943822688,
  "data": { "product": "SmartHome-v1", "uptime": 120, "rssi": -65 }
}
```

- `data.uptime`：内存运行时长（秒）；动作：更新心跳（顺带标记在线）+ 写 `heartbeat_record`。

#### ③ 指令 ACK `device/{mac}/ack`（QoS=1）

```json
{
  "device": "B4BFE90CDBA1",
  "type": "ack",
  "commandId": "d090cd32-7f66-4c83-835e-2d01c5b34945",
  "success": true,
  "message": null,
  "data": { "otaState": "success", "toVersion": "1.0.36" },
  "timestamp": 1791943822688
}
```

- 控制类 ACK：`data.state` 为执行后的通道状态（如 `1`）。
- OTA 接收确认：`data.otaState = "accepted"` → 指令置 `ACCEPTED(6)`。
- OTA 最终 ACK：`data.otaState = "success"` + `data.toVersion` → 指令置 `SUCCESS(2)` 并**同步固件版本**。
- 处理规则：终态幂等；`success` 缺省按失败处理。

#### ④ OTA 进度 `device/{mac}/ota_progress`（QoS=0）

```json
{
  "device": "B4BFE90CDBA1",
  "type": "ota_progress",
  "timestamp": 1791943822688,
  "data": { "otaState": "downloading", "progress": 45, "version": "1.0.36" }
}
```

- `otaState` ∈ `accepted / downloading / verifying / flashing / rebooting / success / failed`（`OtaStateConstants`）。
- 落库 `ota_state / ota_progress / ota_version`；当 `otaState=success` 时同步 `firmware`。

#### ⑤ 待接入主题

| 主题 | payload.type | 设计定位 |
| :--- | :--- | :--- |
| `device/{mac}/state` | `state` | 设备全量/增量状态，`full` + `targets` 模型，QoS=1 且 retain=true |
| `device/{mac}/event` | `event` | 设备事件：`event` + `trigger` + `context` |
| `device/{mac}/sensor` | `sensor_batch` | 传感器批量上报，QoS=0 |

### 4.6 下行指令

统一主题：`device/{mac}/command`（单播，QoS=1，不保留）；广播：`$broadcast/command`。

**控制指令**
```json
{
  "commandId": "ab7f9c2e-1122-4f3d-9c21-91f2b8f0d1aa",
  "action": "set",
  "target": "mos",
  "channel": 1,
  "params": { "value": 1 },
  "timestamp": 1791444733387
}
```

| 字段 | 说明 |
| :--- | :--- |
| commandId | 指令唯一 ID（单播由服务端生成，用于 ACK 关联） |
| action | `set`/`get`/`toggle`/`start`/`reset`/`cancel` |
| target | `mos`/`led`/`servo`/`relay`/`ota`/`config` |
| channel | 通道号（可选，`0` 表示全部） |
| params | 参数（可选） |

**OTA 指令**（`action=start, target=ota`）
```json
{
  "commandId": "...", "action": "start", "target": "ota",
  "params": {
    "url": "http://192.168.1.15:8000/firmware/firmware_1.0.30_20261001.bin",
    "version": "1.0.30",
    "sha256": "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
    "size": 1048576
  },
  "timestamp": 1791444733387
}
```

**配置指令**（`action=set, target=config`）
```json
{
  "commandId": "...", "action": "set", "target": "config",
  "params": { "config": { "heartbeat_interval": 30 }, "configVersion": 1, "persist": true },
  "timestamp": 1791444733387
}
```

---

## 五、HTTP REST 接口

统一前缀 `http://{host}:8080/api`，响应体 `ApiResponse{code, message, data, timestamp}`。

### 5.1 设备指令 `DeviceCommandController`（`/device/command`）

| 方法 | 路径 | 参数 | 返回 |
| :--- | :--- | :--- | :--- |
| POST | `/api/device/command/send` | body `SendCommandRequest{deviceId, action, target, channel, params, operator, expireSeconds}` | `ApiResponse<DeviceCommand>` |
| GET | `/api/device/command/{commandId}` | path | `ApiResponse<DeviceCommand>` |
| GET | `/api/device/command/list` | query `deviceId`、`status`(可选) | `ApiResponse<List<DeviceCommand>>` |
| POST | `/api/device/command/cancel/{id}` | path + query `operator`(可选) | `ApiResponse<Boolean>` |
| GET | `/api/device/command/stats/{deviceId}` | path | `ApiResponse<CommandStatsVO>` |

### 5.2 OTA `DeviceOtaController`（`/ota`）

| 方法 | 路径 | 参数 | 返回 |
| :--- | :--- | :--- | :--- |
| POST | `/api/ota/start` | body `SendCommandRequest`（`params.firmwareId` 指定固件） | `ApiResponse<OtaStartResponse>` |
| GET | `/api/ota/{deviceId}/progress` | path | `ApiResponse<OtaProgressVO>` |

### 5.3 固件 `FirmwareController`（`/firmware`）

| 方法 | 路径 | 参数 | 返回 |
| :--- | :--- | :--- | :--- |
| POST | `/api/firmware/upload` | form `file`、`version`、`product`(可选)、`releaseNotes`(可选)、`operator`(默认 `admin`) | `ApiResponse<FirmwareUploadResponse>` |
| GET | `/api/firmware/list` | — | `ApiResponse<List<FirmwareVO>>` |
| DELETE | `/api/firmware/{id}` | path | `ApiResponse<Void>` |

**HTTP 错误码（`ErrorCode`）**：`SUCCESS=200`；参数 `1000~1002`；业务 `2000`；文件 `4000~4004`；固件 `4100~4102`；设备 `DEVICE_NOT_FOUND=4200` / `DEVICE_OFFLINE=4201`；OTA `4300~4301`；系统 `5000~5002`。

> ⚠️ **当前 HTTP 接口未接入认证鉴权**（无 Spring Security / Token 校验），生产部署前需补齐。

---

## 六、数据模型

数据库脚本：`web-module/src/main/resources/sql/smart_device.sql`（共 12 张表）。

| 表 | 用途 | 关键字段 |
| :--- | :--- | :--- |
| `device_info` | 设备档案与实时状态 | deviceId, product, firmware, online, offlineReason, lastHeartbeatTime, uptime, capabilities(Map), currentState(Map), otaState, otaProgress, otaVersion, configVersion |
| `device_command` | 指令记录与状态机 | commandId, deviceId, action, target, channel, params(Map), qos, retain, status, retryCount, maxRetry, errorMsg, responsePayload(Map), operator, source, expireTime |
| `firmware` | 固件托管 | version, product, releaseNotes, url, fileName, filePath, md5, sha256, size, uploadedBy, status |
| `mqtt_auth` | EMQX 认证数据源 | username, password, salt, isSuperuser, enabled |
| `device_whitelist` | 注册白名单 | deviceId, enabled |
| `device_sensor` | 传感器登记 | deviceId, sensorKey, sensorId, sensorType, sensorName, source, slaveAddress, unit, spec, enabled |
| `sensor_record` | 传感器采样历史 | deviceId, source, slaveAddress, sensorId, channel, sensorKey, sensorType, sensorValue, unit, extra, sensorData |
| `sensor_threshold` | 阈值与告警 | deviceId, sensorKey, sensorType, minValue, maxValue, warnMin, warnMax, alarmLevel, alarmMessage, duration, enabled |
| `device_slave_data` | 从机/通道数据 | deviceId, address, slaveType, channel, onlineSince, value, unit, extra(Map) |
| `device_state_record` | 状态变更历史 | deviceId, target, channel, params(Map), timestamp |
| `device_event_record` | 事件历史 | deviceId, type, event, code, message, context, triggerSource, payload(Map) |
| `heartbeat_record` | 心跳历史 | deviceId, uptime, timestamp, payload |

**设备状态（`DeviceConstants`）**：`OFFLINE=0` / `ONLINE=1` / `FAULT=2`，默认名称前缀 `设备-`。
**MOS 通道**：8 路（`MOS_CHANNEL_COUNT=8`），`OFF=0` / `ON=1`，`CHANNEL_ALL=0`。

---

## 七、指令状态机

| 值 | 枚举 | 含义 |
| :--- | :--- | :--- |
| 0 | `PENDING` | 待下发 |
| 1 | `SENT` | 已下发 |
| 2 | `SUCCESS` | 执行成功 |
| 3 | `FAILED` | 执行失败（写 `errorMsg`） |
| 4 | `TIMEOUT` | 已超时 |
| 5 | `CANCELLED` | 已取消 |
| 6 | `ACCEPTED` | 设备已接收（OTA 下载中） |

终态 = `SUCCESS / FAILED / TIMEOUT / CANCELLED`。ACK 对终态幂等。

---

## 八、安全设计（EMQX）

### 8.1 认证（Authentication）
EMQX Dashboard → 访问控制 → 客户端认证，数据源为 MySQL，统一 SQL：
```sql
SELECT password, salt, is_superuser FROM mqtt_auth
WHERE username = ${username} AND enabled = 1 LIMIT 1
```
**密码加密**：`password_hash = SHA-256(salt + password)`，`salt_position = prefix`；`salt` 16 字节（32 位十六进制），`password` 32 字节（64 位十六进制）。

### 8.2 授权（ACL）
| 序号 | 主体 | 主题 | 权限 |
| :--- | :--- | :--- | :--- |
| 1 | `PROVISION_USER` | `/provision/#` | 允许 |
| 2 | `RUNTIME_USER` | `#` | 允许 |
| 3 | 所有用户 | `device/#` | 允许 |
| 4 | 所有用户 | `#` | **拒绝（兜底，必须放最后）** |

### 8.3 端口级认证隔离
EMQX Dashboard 不支持监听器级绑定不同认证器，需直接改 `etc/emqx.conf`（优先级高于 `cluster.hocon`）：
```hocon
listeners.tcp.default.enable = false
listeners.tcp.provision.enable = false

# 8884 注册端口：只允许服务器账号
listeners.ssl.provision.authentication = [
  { backend = mysql, mechanism = password_based, enable = true
    server = "127.0.0.1:3306", database = "smart_device",
    username = "root", password = "123456"
    query = "SELECT password, salt, is_superuser FROM mqtt_auth WHERE username = ${username} AND enabled = 1 AND is_superuser = 1 LIMIT 1"
    password_hash_algorithm { name = sha256, salt_position = prefix } }
]

# 8883 业务端口：只允许设备账号
listeners.ssl.default.authentication = [
  { backend = mysql, mechanism = password_based, enable = true
    server = "127.0.0.1:3306", database = "smart_device",
    username = "root", password = "123456"
    query = "SELECT password, salt, is_superuser FROM mqtt_auth WHERE username = ${username} AND enabled = 1 AND is_superuser = 0 LIMIT 1"
    password_hash_algorithm { name = sha256, salt_position = prefix } }
]
```

### 8.4 TLS 证书
| 项目 | 要求 |
| :--- | :--- |
| Common Name | `192.168.1.15` |
| SAN | `IP:192.168.1.15, IP:127.0.0.1, DNS:localhost`（**必须**，否则报 `ERR_TLS_CERT_ALTNAME_INVALID`） |
| 有效期 / 密钥 | 测试 10 年、量产 1 年；4096-bit RSA |

```powershell
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 3650 -nodes `
  -subj "/CN=192.168.1.15" `
  -addext "subjectAltName=IP:192.168.1.15,IP:127.0.0.1,DNS:localhost"
```
服务端信任库：`web-module/src/main/resources/certs/cert.pem`。

### 8.5 设备注册入网时序
```
① TLS 握手(8884) → ② CONNECT PROVISION_USER → ③ SUBSCRIBE /provision/device/{MAC}/config
④ PUBLISH /provision/device/{MAC}/register → 服务端验签发证、写 mqtt_auth
⑤ 收到 /config 凭据 → ⑥ 断开 8884 → ⑦ TLS 握手(8883)
⑧ CONNECT dev_{MAC} → ⑨ SUBSCRIBE device/{MAC}/# → ⑩ 业务通信（presence/heartbeat/...）
```

---

## 九、配置说明

| 配置 | 位置 | 说明 |
| :--- | :--- | :--- |
| 服务端口 / 上下文 | `application.yml` | `8080` / `/api` |
| 激活 profile | `application.yml` | 默认 `dev`，生产用 `--spring.profiles.active=prod` 覆盖 |
| 数据库连接池 | `application.yml` | Druid（initial 5 / max 10，slowSql 5000ms） |
| Redis | `application-dev.yml` | `localhost:6379`，用于 nonce 防重放 |
| 运行时 Broker | `application-dev.yml` | `192.168.1.15:8883`，`RUNTIME_USER`，订阅 7 个主题 |
| 注册 Broker | `application-dev.yml` | `192.168.1.15:8884`，`PROVISION_USER`，订阅 register 主题 |
| 固件存储 | `application-dev.yml` | `firmware.upload-dir=D:/data/firmware/`，`base-url` 为下载前缀 |
| 上传限制 | `application.yml` | 单文件 `16MB` / 单请求 `20MB` |
| 生产配置 | `application-prod.yml` | 数据库/Redis/MQTT 口令均走**环境变量注入** |

> ⚠️ `application-dev.yml` 与 EMQX 配置中含明文口令（本地开发用），生产请改用环境变量，并避免提交真实凭据。

---

## 十、目录结构

```
WM_LAOHUA
├── pom.xml                         父工程（依赖与版本集中管理）
├── common-module/
│   └── src/main/java/com/womi/commonmodule/
│       ├── constants/              统一常量（Mqtt/Command/Device/Firmware/OtaState/...）
│       ├── enums/                  CommandStatus / OfflineReason / MqttErrorCode / ErrorCode
│       ├── exception/              BusinessException
│       ├── response/               ApiResponse
│       └── utils/                  Json / SignatureVerifier / TimestampValidator / DateTime / SaltPassword / OtaState
├── business-module/
│   └── src/main/java/com/womi/businessmodule/
│       ├── model/                  12 个实体（DeviceInfo/DeviceCommand/Firmware/SensorRecord/...）
│       ├── mapper/                 对应 Mapper 接口
│       ├── service/ + service/impl/  业务服务
│       └── vo/                     CommandStatsVO
│   └── src/main/resources/mapper/   XML（DeviceInfo/DeviceCommand/Firmware/Sensor/...）
└── web-module/
    ├── src/main/java/com/womi/webmodule/
    │   ├── controller/             DeviceCommand / DeviceOta / Firmware
    │   ├── mqtt/core/              MqttConfig / MqttProperties / MqttMessageReceiver
    │   │                           MqttMessageRouter / MqttPublisher / MqttCredentialGenerator
    │   ├── mqtt/handler/           Register / Presence / Heartbeat / Ack / OtaProgress
    │   ├── service/ + service/impl/  DeviceControl / DeviceOta / DeviceRegister / FirmwareUpload
    │   ├── schedule/               心跳超时 / 指令下发与重试 / OTA 过期 / 历史清理
    │   ├── dto/                    http / mqtt / ota / firmware
    │   └── handler/                GlobalExceptionHandler
    └── src/main/resources/
        ├── application.yml / -dev.yml / -prod.yml
        ├── sql/smart_device.sql    建表脚本
        ├── certs/cert.pem          MQTT TLS 信任证书
        └── python/                 设备模拟脚本（见下）
```

---

## 十一、开发辅助脚本（Python）

`web-module/src/main/resources/python/` 提供 4 个设备模拟脚本，用于联调（需 `paho-mqtt`、`cryptography`）：

| 脚本 | 用途 |
| :--- | :--- |
| `device_create_key.py` | 生成 EC 密钥对，构造 `device\|timestamp\|nonce` 签名原文并输出注册 payload |
| `device_register.py` | 模拟设备连接 8884 发起注册，订阅 `/config` 解析返回的运行凭据 |
| `device_runtime.py` | 模拟设备运行：连接 8883，发 `presence`（上线）、周期心跳、接收指令回 ACK，支持 OTA 接收确认 / 进度上报 / 最终 ACK |
| `device_response_command_ack.py` | 订阅 `device/{mac}/command`，执行模拟动作并回 `device/{mac}/ack` |

```bash
python device_runtime.py --help
```

---

## 十二、验证清单

| 验证项 | 方法 | 期望结果 |
| :--- | :--- | :--- |
| `PROVISION_USER` 连 8884 | MQTTX | 成功 |
| `PROVISION_USER` 连 8883 | MQTTX | 失败（`is_superuser=0` 查不到） |
| 设备账号 `dev_*` 连 8883 | MQTTX | 成功 |
| 设备账号 `dev_*` 连 8884 | MQTTX | 失败（`is_superuser=1` 查不到） |
| TLS 证书 SAN 校验 | MQTTX 开启 SSL | 成功（无 ALTNAME 报错） |
| ACL 主题隔离 | 设备订阅 `device/OTHER/state` | 权限拒绝 |
| 注册闭环 | `device_register.py` | 收到 `/config` 凭据 |
| 指令闭环 | `device_response_command_ack.py` + `POST /device/command/send` | 指令状态 `PENDING→SENT→SUCCESS` |
| OTA 闭环 | `POST /ota/start` + `device_runtime.py` | 进度上报可见，`firmware` 收敛到目标版本 |
