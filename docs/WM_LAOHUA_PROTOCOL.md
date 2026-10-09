# WM_LAOHUA 物联网平台 - 项目与通信协议文档

> 本项目为基于 **Spring Boot 3.4.4 + MQTT (Eclipse Paho) + MyBatis-Plus + MySQL(Druid)** 的物联网设备管理平台，Maven 多模块工程。
>
> - 模块：`common-module`（公共常量/工具）、`business-module`（业务与数据层）、`web-module`（HTTP 接口、MQTT 收发与定时任务）
> - 应用：`web-module`，端口 `8080`，上下文路径 `/api`
> - 消息中间件：`192.168.124.6:1883`，默认 QoS=1，cleanSession=true（详见 `application.yml` 配置 `mqtt.*`）

---

## 目录

1. [MQTT 消息协议](#1-mqtt-消息协议)
   - [1.1 设备心跳](#11-设备心跳消息)
   - [1.2 MOS 状态上报](#12-mos-状态上报)
   - [1.3 传感器数据上报（含从机）](#13-传感器数据上报含从机)
   - [1.4 控制指令下发](#14-控制指令下发)
   - [1.5 带 ACK 匹配的控制指令下发](#15-带-ack-匹配的控制指令下发)
2. [HTTP REST 接口](#2-http-rest-接口)
   - [2.1 指令下发](#21-下发指令)
   - [2.2 指令查询](#22-查询指令详情)
   - [2.3 指令列表](#23-查询设备指令列表)
   - [2.4 取消指令](#24-取消指令)
   - [2.5 状态统计](#25-状态统计)
   - [2.6 MQTT 测试-命令](#26-mqtt-测试发命令)
   - [2.7 MQTT 测试-自定义发布](#27-mqtt-测试自定义发布)
   - [2.8 MQTT 测试-控制](#28-mqtt-测试控制)
3. [指令状态机](#3-指令状态机)
4. [定时任务](#4-定时任务)
5. [数据保留策略](#5-数据保留策略)

---

## 1. MQTT 消息协议

平台与设备通过 MQTT 交互。设备**上报三类消息**（主题含设备ID占位），平台**下发一类指令**。

平台订阅（`application.yml`）：

```
device/+/heart
device/+/mos_state
device/+/sensor
```

平台发布（下行指令）主题格式：

```
device/{deviceId}/command
```

> 主题路径结构：`device/{deviceId}/{消息类型}`。消息类型枚举 `heart` / `mos_state` / `sensor` / `command`。

### 1.1 设备心跳消息

**Topic：`device/{deviceId}/heart`**（设备 → 平台）

设备周期性上报心跳与运行时长。

**Payload：**

```json
{
  "data": {
    "uptime": 8640021
  }
}
```

**字段说明：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| data.uptime | long | 设备运行时长（秒） |

**平台处理逻辑：** 解析 `data.uptime` 写入心跳记录；心跳历史在内存 `DeviceData` 仅保留最近 `100` 条（超出即移除最早一条）；更新设备最近心跳时间并落库。

---

### 1.2 MOS 状态上报

**Topic：`device/{deviceId}/mos_state`**（设备 → 平台）

设备上报各 MOS 通道开关状态（8 通道）。

**Payload：**

```json
{
  "data": {
    "mos0": 1,
    "mos1": 0,
    "mos2": 1,
    "mos3": 0,
    "mos4": 0,
    "mos5": 1,
    "mos6": 0,
    "mos7": 0
  }
}
```

**字段说明：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| data.mos0 ~ data.mos7 | int | 8 个 MOS 通道状态（1/0），字段不存在则忽略，仅更新存在的通道 |

**平台处理逻辑：** 更新设备 MOS 状态映射；写入 `MosStateRecord`；历史仅保留最近 `100` 条。

---

### 1.3 传感器数据上报（含从机）

**Topic：`device/{deviceId}/sensor`**（设备 → 平台）

设备上报传感器数据，其中含从机（slave）列表，每个从机记录 `addr`/`online`/`count`。

**Payload：**

```json
{
  "data": {
    "slaves": [
      { "addr": 1,  "online": 1, "count": 8 },
      { "addr": 2,  "online": 1, "count": 8 },
      { "addr": 3,  "online": 0, "count": 0 }
    ]
  }
}
```

**字段说明：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| data | object | 原始传感器数据（整体存储） |
| data.slaves | array | 从机列表，为可选字段 |
| data.slaves[].addr | int | 从机地址 |
| data.slaves[].online | int | 从机在线状态（1/0） |
| data.slaves[].count | int | 从机通道/计数 |

**平台处理逻辑：** 整个 `data` 保存为 `sensor_record.sensor_data`；解析 `slaves` 写入从机表 `sensor_slave_data`（每个 slave 一条），并按设备侧最近 `20` 条保留在内存态。

---

### 1.4 控制指令下发

**Topic：`device/{deviceId}/command`**（平台 → 设备）

平台向单台设备下发控制指令（由 `MqttPublisher.sendCommand` 发布，QoS=1，不保留）。

**Payload：**

```json
{
  "command": "restart",
  "data": {
    "action": "restart",
    "delay": 5
  },
  "timestamp": 1791444733387
}
```

**字段说明：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| command | string | 指令类型 |
| data | object | 指令参数 |
| timestamp | long | 毫秒时间戳 |

> 指令类型 ε `MOS_CONTROL` / `REBOOT` / `CONFIG` / `QUERY` / `OTA`。
>
> 该接口用于一次性的命令发布（`MqttTestController` 测试路径即此类），**不产生指令记录、无 ACK 匹配**。

---

### 1.5 带 ACK 匹配的控制指令下发

**Topic：`device/{deviceId}/command`**（平台 → 设备）

用于正式的业务指令链路：先入 `device_command` 表（待下发状态），再通过本主题下发（QoS=1，不保留），并通过 `commandId` 在后续回调中匹配设备 ACK。

**Payload：**

```json
{
  "commandId": "ab7f9c2e-1122-4f3d-9c21-91f2b8f0d1aa",
  "command": "MOS_CONTROL",
  "data": {
    "channel": 1,
    "value": 1
  },
  "timestamp": 1791444733387
}
```

**字段说明：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| commandId | string | 指令唯一 ID（UUID，服务端生成，用于 ACK 匹配） |
| command | string | 指令类型（queue: `MOS_CONTROL/REBOOT/CONFIG/QUERY/OTA`） |
| data | object | 指令参数 |
| timestamp | long | 毫秒时间戳 |

---

## 2. HTTP REST 接口

> 统一前缀：`http://{host}:8080/api`
> 响应封装：`ApiResponse { code, message, data, timestamp }`（`MqttTestController` 使用）；`DeviceCommandController` 的个别接口直接返回实体或基本类型。

### 2.1 下发指令

```
POST /device/command/send
```

下发一条正式指令，入状态机队列后立即尝试通过 MQTT 下发。

**Request Body：**

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| deviceId | string | 是 | 目标设备 |
| commandType | string | 是 | 指令类型（`MOS_CONTROL/REBOOT/CONFIG/QUERY/OTA`） |
| payload | object | 否 | 指令参数 |
| operator | string | 否 | 操作人，缺省 `web-user` |
| expireSeconds | int | 否 | 过期秒数，缺省 `300` |

**示例 Request：**

```json
{
  "deviceId": "B4BFE90CDBA1",
  "commandType": "REBOOT",
  "payload": { "delay": 10 },
  "operator": "admin",
  "expireSeconds": 300
}
```

**Response：** 返回 `commandId`（String）。

> 说明：来源 source 固定为 `WEB`；若 MQTT 下发失败则转入定时重试。

### 2.2 查询指令详情

```
GET /device/command/{commandId}
```

返回 `DeviceCommand`（含 payload、responsePayload、状态等）实体。

### 2.3 查询设备指令列表

```
GET /device/command/list?deviceId=xxx&status=0
```

按设备查询指令，`status` 可选（不传则查询全部），按创建时间倒序。

### 2.4 取消指令

```
POST /device/command/cancel/{id}?operator=admin
```

取消指定指令（仅非终态可取消），返回 `boolean`。操作人缺省 `web-user`。

### 2.5 状态统计

```
GET /device/command/stats/{deviceId}
```

返回 `Map<Integer, Long>`，键为指令状态值，值为数量。

### 2.6 MQTT 测试-发命令

```
POST /mqtt/command/{deviceId}?command=restart
Body: { ...data... }
```

直接通过 MQTT 下发（不落库、无 ACK）。返回 `ApiResponse`。

### 2.7 MQTT 测试-自定义发布

```
POST /mqtt/publish?topic=device/xxx/command
Body: { ...payload... }
```

向任意主题发布自定义消息。返回 `ApiResponse`。

### 2.8 MQTT 测试-控制

```
POST /mqtt/test/control?deviceId=xxx
```

发布 `command=control`、`data={action:restart, delay:5}` 的控制命令（走 1.4 无 ACK 链路）。返回 `ApiResponse`。

---

## 3. 指令状态机

平台侧 `device_command` 表状态流转：

**状态值：**

| 值 | 含义 |
| --- | --- |
| 0 | 待下发 |
| 1 | 已下发 |
| 2 | 设备已接收 |
| 3 | 执行成功 |
| 4 | 执行失败 |
| 5 | 已超时 |
| 6 | 已取消 |

**流转：** `0 待下发 → 1 已下发 → 2 设备已接收 → 3 执行成功 / 4 执行失败`；非终态可被 `6 取消`；到期未 ACK 置 `5 已超时`。终态集合 `{3,4,5,6}`。

**相关默认参数：**

| 参数 | 值 |
| --- | --- |
| 默认过期秒数 | 300 |
| 默认最大重试次数 | 3 |
| 默认 QoS / retain | 1 / 0 |
| 默认操作人（系统 / Web） | system / web-user |
| 默认失败原因 | 设备执行失败 |

---

## 4. 定时任务

| 任务 | 频率 | 说明 |
| --- | --- | --- |
| 待下发扫描 | 每 5 秒 | 抓取最多 `50` 条 `status=0` 指令并发下 |
| 超时重试 | 每 30 秒 | 抓取超时（>30s 未 ACK）且 `status∈{1,2}` 的指令重发，单批最多 `50` |
| 过期标记 | 每 60 秒 | 将到期仍未完成的指令置为 `5 已超时` |
| 历史清理 | 每天 02:00 | 清理 `30` 天前已结束(`{3,4,5,6}`) 的指令 |

---

## 5. 数据保留策略

| 数据 | 保留策略 |
| --- | --- |
| 心跳 / MOS / 传感器 / 从机历史 | 清理 `30` 天前的数据（`cleanExpiredData`） |
| 内存态设备历史（心跳/传感器/MOS） | 每设备最近 `100` 条 |
| 内存态从机列表 | 每设备最近 `20` 条 |

> 常量统一收敛于 `common-module`：
> - 设备域 → `com.womi.commonmodule.device.DeviceConstants`
> - 指令域 → `com.womi.commonmodule.command.CommandConstants`
> - MQTT 域 → `com.womi.commonmodule.mqtt.MqttConstants`
> - 调度域 → `com.womi.commonmodule.schedule.ScheduleConstants`
> - 通用响应 → `com.womi.commonmodule.response.ResponseConstants`