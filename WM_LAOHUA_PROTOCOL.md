# 物联网平台 · 服务端协议与接口文档（WM_LAOHUA）

> 本文档描述 **WM_LAOHUA 服务端**（Java，Maven 多模块）与 **ESP32 设备固件**（ESP-IDF v6.0.2）之间的完整通信协议，以及服务端对外提供的 HTTP 接口。
>
> - 架构：`common-module`（公共常量/工具/加密）/ `business-module`（业务与数据层）/ `web-module`（HTTP 接口、MQTT 收发、定时任务）
> - 应用：`web-module`，端口 **8080**，上下文路径 **/api**
> - MQTT 采用**双 Broker 双通道**：运行 Broker **1883** 与注册 Broker **1884** 隔离

## 文档信息

| 项目 | 内容 |
| :--- | :---
| 协议版本 | v4.0（对齐设备侧） |
| 运行 Broker | 1883 |
| 注册 Broker | 1884 |
| 下行入口 | `device/{mac}/command`、`$broadcast/command` |
| 上行 Topic | `online` / `offline` / `will` / `heartbeat` / `state` / `ack` / `event` / `sensor` |
| 注册 Topic | `/provision/device/{mac}/register`、`/provision/device/{mac}/config` |

> **设计原则**
>
> - 下行控制统一进入 `command`；单播命令使用 `commandId` 关联 ACK，广播命令由设备本地生成 `commandId`。
> - 上行按照语义拆分 Topic。
> - 设备状态使用 `state` 的 `full + targets` 模型（全量/增量上报）。
> - OTA 触发使用 `command`，升级过程与结果使用 `state` 上报（服务端侧）。
> - 注册走独立 1884 provision Broker，一次性换取运行凭据后切到 1883。

---

## 二、MQTT 收发架构（双 Broker 双通道）

| 通道 | Broker | 客户端后缀 | 订阅主题 | QoS |
| --- | --- | --- | --- | --- |
| runtime（运行时） | `192.168.1.15:1883` | `-runtime-in`/`-runtime-out` | `device/+/online`、`offline`、`will`、`heartbeat`、`state`、`ack`、`event`、`sensor` | 1,1,1,0,1,1,1,0 |
| provision（注册） | `192.168.1.15:1884` | `-provision-in`/`-provision-out` | `/provision/device/+/register` | 1 |

**入站链路**：inbound `MqttPahoMessageDrivenChannelAdapter` → `runtimeInputChannel` / `provisionInputChannel` → `MqttMessageReceiver`（读 header `mqtt_receivedTopic`/`mqtt_receivedQos`）→ `MqttMessageRouter.route()` → 命中 `supports()` 的 Handler。

**出站链路**：`MqttPahoMessageHandler`（`runtimeOutputChannel`/`provisionOutputChannel`，`setAsync(true)`）通过 header `mqtt_topic`/`mqtt_qos`/`mqtt_retained` 透传发布参数。

**Topic 解析（公共接口 `MqttMessageHandler` 默认方法）**：
- `extractDeviceId(topic)`：`device/{mac}/{type}` → 取 `parts[1]` 为 MAC
- `extractProvisionDeviceId(topic)`：`/provision/device/{mac}/register` → 取 `parts[3]`
- `extractMessageType(topic)`：取 `parts[2]`（如 heartbeat）

---

## 三、设备注册（PROVISION）

设备首次上电/恢复出厂/凭据失效时，本地 `provisioned=0`，连接 **1884** 注册 Broker 报到，换取正式运行凭据。

**安全四重机制**：

| 机制 | 作用 | 位置 |
| --- | --- | --- |
| `pubkey` 公钥 | 设备身份标识，服务器用它验签 | 设备首启生成（ECDSA P-256），随请求发送 |
| `signature` 签名 | 证明 pubkey 属于本设备 | 设备用私钥签名 `device\|timestamp\|nonce` |
| `nonce` 随机数 | 防重放 | 每次注册唯一 UUID，服务器 Redis 记录 5 分钟 |
| `timestamp` | 防过期 | 服务器校验 ±5 分钟 |

### 3.1 注册请求

**Topic：`/provision/device/{mac}/register`**（设备 → 服务器，QoS=1）

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

**字段说明：**

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| device | string | 是 | 设备 MAC（12 位大写十六进制，无冒号，正则 `^[0-9A-F]{12}$`） |
| product | string | 是 | 产品型号 |
| type | string | 是 | 固定 `"register"` |
| timestamp | long | 是 | 毫秒时间戳（校验 ±5 分钟） |
| data.firmware | string | 是 | 固件版本 |
| data.chip | string | 否 | 芯片型号 |
| data.hardware_version | string | 否 | 硬件版本 |
| data.nonce | string | 是 | 随机 UUID，每次注册唯一 |
| data.pubkey | string | 是 | PEM 格式公钥（ECDSA P-256） |
| data.signature | string | 是 | Base64 编码签名 |

**服务器校验顺序**：MAC 格式 → `timestamp`（±5 分钟）→ `nonce`（Redis 5 分钟防重放）→ 用 `pubkey` 验 `signature`。

**签名算法（`SignatureVerifierUtils`）**：
- 待签数据：`signData = deviceId + "|" + timestamp + "|" + nonce`（`|` 分隔，按此顺序）
- 算法：`SHA256withECDSA`，公钥 `EC`（X509EncodedKeySpec），PEM 去头尾/空白，`Base64(MIME)` 解码

### 3.2 注册响应

**Topic：`/provision/device/{mac}/config`**（服务器 → 设备，QoS=1，不保留）

**成功**

```json
{
  "device": "B4BFE90CDBA0",
  "success": true,
  "mqtt": {
    "host": "192.168.1.15",
    "port": 1883,
    "clientId": "device-B4BFE90CDBA0",
    "username": "dev_B4BFE90CDBA0",
    "password": "e2e1c28ef5d9489b",
    "keepAlive": 60
  },
  "will": {
    "topic": "device/B4BFE90CDBA0/will",
    "qos": 1,
    "retain": true,
    "payload": {
      "device": "B4BFE90CDBA0",
      "product": "SmartHome-v1",
      "type": "offline",
      "timestamp": 0,
      "data": { "reason": "mqtt_lwt" }
    }
  },
  "config": { "heartbeat_interval": 30, "sensor_batch_size": 32 },
  "timestamp": 1791444746640
}
```

**失败**

```json
{
  "device": "B4BFE90CDBA0",
  "success": false,
  "error": "INVALID_SIGNATURE",
  "message": "签名验证失败",
  "timestamp": 1791444746640
}
```

**凭据生成规则（`MqttCredentialGenerator`）**：

| 字段 | 规则 |
| --- | --- |
| clientId | `device-{mac}` |
| username | `dev_{mac}` |
| password | UUID 去横线后前 16 位 |

### 3.3 重复注册策略

| 场景 | pubkey 一致 | 服务器行为 |
| --- | --- | --- |
| 首次注册 | — | 保存 pubkey，分配凭据 |
| 同设备重启 | 一致 | 允许，换新密码（旧密码失效） |
| 网络抖动重试 | 一致 | 允许，nonce 不同即可 |
| 攻击者冒充 | **不一致** | 拒绝 `DEVICE_ALREADY_REGISTERED` |
| 设备换密钥对 | 不一致 | 拒绝（需人工清空 pubkey） |

**没有 pubkey 校验的后果**：攻击者用自己密钥注册同一 MAC → 验签通过 → 覆盖数据库 → 拿到凭据 → 冒充成功。加了 pubkey 绑定后则无法冒充。

### 3.4 注册错误码（`MqttErrorCode`）

| 错误码 | 含义 | 设备处理 |
| --- | --- | --- |
| `INVALID_DEVICE_ID` | MAC 格式不对 | 检查固件 |
| `PARAM_MISSING` | product 为空 | 检查固件 |
| `INVALID_TIMESTAMP` | 时间戳超窗口 | 同步 NTP 后重试 |
| `REPLAY_ATTACK` | nonce 重复 | 换新 nonce 重试 |
| `INVALID_SIGNATURE` | 签名验证失败 | 检查密钥对 |
| `INVALID_PUBKEY` | 公钥非法 | 检查密钥对 |
| `DEVICE_ALREADY_REGISTERED` | pubkey 不匹配（被冒充） | 停止重试，人工介入 |
| `DEVICE_BLACKLISTED` | 设备被拉黑 | 停止重试 |
| `FIRMWARE_TOO_OLD` | 固件过旧 | 升级固件 |
| `DEVICE_NOT_REGISTERED` | 设备未注册 | 重试注册 |
| `INVALID_PAYLOAD` / `SERVER_ERROR` | 报文错误 / 服务器异常 | 等 30 秒重试 |

---

## 四、运行态上行消息（设备 → 服务器）

> 以下所有主题格式为 `device/{mac}/{type}`。除在线/离线/心跳/注册外，`state`/`ack`/`event`/`sensor` 四个主题**已被服务端订阅但处理器尚未接线**（后续版本接入）。已实现处理器见下。

### 4.1 上线 `device/{mac}/online`

设备连接 1883 成功后发送。**处理器 `OnlineMessageHandler`**：

```json
{
  "device": "B4BFE90CDBA0",
  "product": "SmartHome-v1",
  "type": "online",
  "timestamp": 1791444733387,
  "data": {
    "firmware": "1.0.29",
    "capabilities": { "mos": 8, "led": 3, "servo": 2 }
  }
}
```

- `data.capabilities` 整体转为 JSON Map 存储
- 动作：`deviceInfoService.markOnline(deviceId, product, firmware, capabilities)`

### 4.2 离线 `device/{mac}/offline` / 遗嘱 `device/{mac}/will`

正常关机发 `offline`；异常断线由 Broker 发 `will`（LWT）。**同一处理器 `OfflineMessageHandler`** 处理两者：

```json
{
  "device": "B4BFE90CDBA0",
  "type": "offline",
  "timestamp": 1791444733387,
  "data": { "reason": "shutdown" }
}
```

- `data.reason` ∈ `OfflineReason`：`shutdown`(正常关机)、`factory_reset`(恢复出厂)、`mqtt_lwt`(遗嘱/异常断线)、`heartbeat_timeout`(心跳超时)、`manual`(手动下线)
- 判定：`reason` 小于目标阈值时，will 主题取 `mqtt_lwt`，offline 主题取 `shutdown`，其余原样
- 动作：`deviceInfoService.markOffline(deviceId, reason)`

### 4.3 心跳 `device/{mac}/heartbeat`

**QoS=0**。**处理器 `HeartbeatMessageHandler`**：

```json
{
  "device": "B4BFE90CDBA0",
  "type": "heartbeat",
  "timestamp": 1791444733387,
  "data": { "uptime": 8640021 }
}
```

- `data.uptime` 内存运行时长（秒）
- 动作：`updateHeartbeat`（标记在线）+ `heartbeatRecordService.recordHeartbeat` 写历史表

### 4.4 状态 / ACK / 事件 / 传感器（已订阅，待实现）

| 主题 | payload.type | 设计定位 |
| --- | --- | --- |
| `device/{mac}/state` | `state` | 设备全量/增量状态，`full` + `targets` 模型，QoS=1 且 retain=true |
| `device/{mac}/ack` | `ack` | 指令 ACK，回带 `commandId`、`success`、`error`、`result` |
| `device/{mac}/event` | `event` | 设备事件：`event`+`trigger`+`context` |
| `device/{mac}/sensor` | `sensor_batch` | 传感器批量上报，QoS=0，字段见后 |

> 上述主题服务端当前**仅订阅未消费**（`MqttConstants` 已有完整字段常量与正则，业务处理待实现）。

---

## 五、下行指令（服务器 → 设备）

统一主题：`device/{mac}/command`（单播，QoS=1，不保留）；`$broadcast/command`（广播）。

### 5.1 控制指令 `sendControlCommand`

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

**字段说明：**

| 字段 | 说明 |
| --- | --- |
| commandId | 指令唯一 ID（单播由服务器生成，用于 ACK 关联） |
| action | 动作：`set`/`get`/`toggle`/`start`/`reset`/`cancel` |
| target | 目标：`mos`/`led`/`servo`/`relay`/`ota`/`config` |
| channel | 通道号（可选，`0` 表示全部） |
| params | 参数（可选） |
| timestamp | 毫秒时间戳 |

### 5.2 OTA 指令 `sendOtaCommand`（`action=start, target=ota`）

```json
{
  "commandId": "...",
  "action": "start",
  "target": "ota",
  "params": {
    "url": "http://192.168.1.15:8000/firmware/firmware_1.0.30_20261001.bin",
    "version": "1.0.30",
    "md5": "d41d8cd98f00b204e9800998ecf8427e",
    "size": 1048576
  },
  "timestamp": 1791444733387
}
```

OTA 状态上报：`accepted`/`downloading`/`verifying`/`flashing`/`success`/`fail`/`canceled`（经 `state` 上报）。

### 5.3 配置指令 `sendConfigCommand`（`action=set, target=config`）

```json
{
  "commandId": "...",
  "action": "set",
  "target": "config",
  "params": {
    "config": { "heartbeat_interval": 30 },
    "configVersion": 1,
    "persist": true
  },
  "timestamp": 1791444733387
}
```

> 指令入 `device_command` 表（状态机见第七节）。下发参数默认：`qos=1`、`retain=0`、过期 `300s`、最大重试 `3` 次、操作人 `system`。

---

## 六、HTTP REST 接口

统一前缀 `http://{host}:8080/api`，响应体 `ApiResponse{code, message, data, timestamp}`（成功 code=200）。

### 6.1 设备指令 `DeviceCommandController`（`/device/command`）

| 方法 | 路径 | 参数 | 返回 |
| --- | --- | --- | --- |
| POST | `/api/device/command/send` | body `SendCommandRequest{deviceId, commandType, payload, operator, expireSeconds}` | String |
| GET | `/api/device/command/{commandId}` | path | DeviceCommand |
| GET | `/api/device/command/list?deviceId&status` | query | List&lt;DeviceCommand&gt; |
| POST | `/api/device/command/cancel/{id}?operator` | path+query，操作人缺省 `web-user` | boolean |
| GET | `/api/device/command/stats/{deviceId}` | path | Map&lt;Integer,Long&gt; |

### 6.2 MQTT 测试 `MqttTestController`（`/mqtt`）

| 方法 | 路径 | 参数 | 返回 |
| --- | --- | --- | --- |
| POST | `/api/mqtt/command/{deviceId}?command` | body Map | ApiResponse&lt;Void&gt; |
| POST | `/api/mqtt/publish?topic` | body Map | ApiResponse&lt;Void&gt; |
| POST | `/api/mqtt/test/control?deviceId` | query | ApiResponse&lt;Void&gt; |

### 6.3 OTA `DeviceOtaController`（`/ota`）

| 方法 | 路径 | 参数 | 返回 |
| --- | --- | --- | --- |
| POST | `/api/ota/start` | body `OtaStartRequest{deviceId, deviceIds[], firmwareId, operator, expireSeconds(默认600)}` | `ApiResponse<OtaStartResponse{total,success,failed,failedDevices[],commandIds[]}>` |
| GET | `/api/ota/{deviceId}/progress` | path | `ApiResponse<OtaProgressVO{deviceId,otaState,otaProgress,otaVersion,lastUpdateTime}>` |

### 6.4 固件 `FirmwareController`（`/firmware`）

| 方法 | 路径 | 参数 | 返回 |
| --- | --- | --- | --- |
| POST | `/api/firmware/upload` | form `file`,`version`,`product`,`releaseNotes`,`operator(默认admin)` | ApiResponse&lt;FirmwareUploadResponse&gt; |
| GET | `/api/firmware/list` | — | ApiResponse&lt;List&lt;FirmwareVO&gt;&gt; |
| DELETE | `/api/firmware/{id}` | path | ApiResponse&lt;Void&gt; |

**HTTP 错误码（`ErrorCode`）**：`SUCCESS=200`；`PARAM_ERROR=1000`/`PARAM_MISSING=1001`/`PARAM_INVALID=1002`；`BUSINESS_ERROR=2000`；文件 `4000~4004`；固件 `4100~4102`；设备 `DEVICE_NOT_FOUND=4200`/`DEVICE_OFFLINE=4201`；OTA `4300~4301`；系统 `5000~5002`。

---

## 七、指令状态机（`device_command.status`）

| 值 | 枚举 | 含义 |
| --- | --- | --- |
| 0 | PENDING | 待下发 |
| 1 | SENT | 已下发 |
| 2 | SUCCESS | 执行成功 |
| 3 | FAILED | 执行失败（写入 `errorMsg`） |
| 4 | TIMEOUT | 已超时 |
| 5 | CANCELLED | 已取消 |

终态 = SUCCESS / FAILED / TIMEOUT / CANCELLED。ACK 处理会对终态指令幂等（避免重复处理）。

---

## 八、数据实体（business-module）

| 表 | 核心字段 |
| --- | --- |
| device_info | deviceId, deviceName, product, firmware, online, offlineReason, lastHeartbeatTime, uptime, capabilities(Map), currentState(Map), otaState, otaProgress, otaVersion, configVersion |
| device_command | commandId, deviceId, action, target, channel, params(Map), qos, retain, status, retryCount, maxRetry, errorMsg, responsePayload(Map), operator, source, expireTime |
| device_state_record | deviceId, target, channel, params(Map), timestamp |
| device_event_record | deviceId, type, event, code, message, context, triggerSource, payload(Map) |
| heartbeat_record | deviceId, uptime, timestamp, payload |
| device_slave_data | deviceId, address, slaveType, channel, onlineSince, value, unit, extra(Map) |
| sensor_record | deviceId, source, slaveAddress, sensorId, channel, sensorKey, sensorType, sensorValue, unit, extra, sensorData |
| device_sensor | deviceId, sensorKey, sensorId, sensorType, sensorName, source, slaveAddress, unit, spec, enabled |
| sensor_threshold | deviceId, sensorKey, sensorType, minValue, maxValue, warnMin, warnMax, alarmLevel, alarmMessage, duration, enabled |
| firmware | version, product, releaseNotes, url, fileName, filePath, md5, sha256, size, uploadedBy, status |

**设备状态（`DeviceConstants`）**：`OFFLINE=0`、`ONLINE=1`、`FAULT=2`；名称前缀 `设备-`。

**MOS 通道**：`8` 路（`MOS_CHANNEL_COUNT=8`）；状态值 `OFF=0`/`ON=1`，`CHANNEL_ALL=0`。

---

## 九、定时任务与数据保留

| 任务 | 频率 | 说明 |
| --- | --- | --- |
| 待下发扫描 | 每 5 秒 | 抓取待下发指令并发下 |
| 超时重试 | 每 30 秒 | 超时未 ACK 指令重发 |
| 过期标记 | 每 60 秒 | 到期未完成置超时 |
| 历史清理 | 每天 02:00 | 清理 30 天前终态指令/数据 |

**保留策略**：历史原始数据保留 `30` 天；内存态设备历史每设备 `100` 条，从机列表 `20` 条。

**常量统一收敛于 `common-module/.../constants/`**：`MqttConstants`（topic/字段/header）、`CommandConstants`、`DeviceConstants`、`FirmwareConstants`、`FileConstants`、`HttpStatusConstants`、`RegexConstants`、`ErrorInfoConstants`；枚举：`CommandStatus`、`OfflineReason`、`MqttErrorCode`、`ErrorCode`。