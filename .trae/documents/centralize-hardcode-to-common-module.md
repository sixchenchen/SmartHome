# 硬编码集中到 common-module 统一管理

## Context（背景）

项目当前在各业务类中散落着大量领域常量：魔法数字（超时秒数、重试次数、调度间隔）、指令状态值（0~6）、设备状态值（0~2）、MQTT 主题/正则/字段名、默认操作人与来源、payload 字段 key 等。这些常量在不同文件（如 `DeviceCommandServiceImpl`、`CommandScheduler`、各 MQTT Handler、`MqttPublisher`）中重复出现，缺少统一出处，后期改值容易遗漏。

目标：**不改任何业务逻辑**，仅把这些领域常量抽取到 `common-module` 中，按功能分包成常量类，沿用现有 `ResponseConstants` 的编码风格（`public final class` + 私有构造器 + `public static final`，中文注释，SCREAMING_SNAKE_CASE）。

约定（已与用户确认）：
- **只抽领域常量**：魔法数字、状态值、主题/topic 正则、payload 字段名、默认操作人/来源、默认配置值、调度参数。
- **日志/异常中文文案不抽**（如「指令已入库待下发」「解析 JSON 失败」）保留在原处。
- **Mapper XML 中的 SQL 状态值不动**（XML 无法引用 Java 常量，视为表结构常量）。

## common-module 新增常量类（按功能分包）

新增包均位于 `common-module/src/main/java/com/womi/commonmodule/` 下，与现有 `response/`、`utils/` 平级。

### 1. `device/DeviceConstants.java`
设备领域常量（来源：`DeviceInfo`、`DeviceDataServiceImpl`、MQTT heart/mos handler）：
- `DEVICE_STATUS_OFFLINE = 0` 离线
- `DEVICE_STATUS_ONLINE = 1` 在线
- `DEVICE_STATUS_FAULT = 2` 故障
- `DEVICE_NAME_PREFIX = "设备-"` 新建设备默认名称前缀
- `HEARTBEAT_HISTORY_LIMIT = 100` 各历史记录上限
- `RECENT_SLAVE_LIMIT = 20` 从机记录条数
- `DATA_RETENTION_DAYS = 30` 历史数据保留天数

### 2. `command/CommandConstants.java`
指令状态与下发参数（来源：`DeviceCommand` 字段注释、`DeviceCommandServiceImpl`、`DeviceCommandController`）：
- `STATUS_PENDING = 0` / `STATUS_SENT = 1` / `STATUS_RECEIVED = 2` / `STATUS_SUCCESS = 3` / `STATUS_FAILED = 4` / `STATUS_TIMEOUT = 5` / `STATUS_CANCELED = 6`
- `FINISHED_STATUSES = List.of(3, 4, 5, 6)` 已结束状态集合（清理历史用）
- `DEFAULT_EXPIRE_SECONDS = 300` 默认过期秒数
- `DEFAULT_MAX_RETRY = 3` 默认最大重试次数
- `DEFAULT_QOS = 1`、`DEFAULT_RETAIN = 0` 默认下发参数
- `DEFAULT_OPERATOR = "system"`、`WEB_DEFAULT_OPERATOR = "web-user"`、`DEFAULT_SOURCE = "WEB"`
- `DEFAULT_FAIL_MSG = "设备执行失败"` ACK 失败时的默认原因

### 3. `mqtt/MqttConstants.java`
MQTT 主题、字段名、header key（来源：MQTT handlers、`MqttPublisher`、`MqttConfig`）：
- 主题前缀/分隔符：`DEVICE_TOPIC_PREFIX = "device"`、`TOPIC_SEPARATOR = "/"`
- 主题类型：`MSG_TYPE_HEART = "heart"`、`MSG_TYPE_MOS_STATE = "mos_state"`、`MSG_TYPE_SENSOR = "sensor"`、`MSG_TYPE_COMMAND = "command"`
- 主题正则：`HEART_TOPIC_PATTERN = "device/[^/]+/heart"`、`MOS_TOPIC_PATTERN = "device/[^/]+/mos_state"`、`SENSOR_TOPIC_PATTERN = "device/[^/]+/sensor"`
- 命令主题格式：`COMMAND_TOPIC_FORMAT = "device/%s/command"`
- 出站 header key：`MQTT_HEADER_TOPIC = "mqtt_topic"`、`MQTT_HEADER_QOS = "mqtt_qos"`、`MQTT_HEADER_RETAINED = "mqtt_retained"`
- 入站 header key：`MQTT_RECEIVED_TOPIC = "mqtt_receivedTopic"`、`MQTT_RECEIVED_QOS = "mqtt_receivedQos"`
- payload 字段 key：`FIELD_DATA = "data"`、`FIELD_UPTIME = "uptime"`、`FIELD_MOS = "mos"`、`FIELD_SLAVES = "slaves"`、`FIELD_ADDR = "addr"`、`FIELD_ONLINE = "online"`、`FIELD_COUNT = "count"`、`FIELD_COMMAND = "command"`、`FIELD_COMMAND_ID = "commandId"`、`FIELD_TIMESTAMP = "timestamp"`
- MOS 通道数：`MOS_CHANNEL_COUNT = 8`（循环 `i <= 7`）
- 默认发送 QoS/保留：`DEFAULT_QOS = 1`、`DEFAULT_RETAINED = false`
- 客户端后缀：`INBOUND_SUFFIX = "-inbound"`、`OUTBOUND_SUFFIX = "-outbound"`

### 4. `schedule/ScheduleConstants.java`
调度参数（来源：`CommandScheduler`）：
- `DISPATCH_FIXED_DELAY = 5000` 待下发扫描间隔 ms
- `RETRY_FIXED_DELAY = 30000` 超时重试间隔 ms
- `MARK_EXPIRED_FIXED_DELAY = 60000` 过期标记间隔 ms
- `BATCH_SIZE = 50` 单批处理条数
- `RETRY_TIMEOUT_SECONDS = 30` 重试超时阈值秒
- `CLEAN_RETENTION_DAYS = 30` 历史清理保留天数
- `CLEAN_HISTORY_CRON = "0 0 2 * * ?"` 每日清理 cron

> 注：`schedule` 包更贴近业务/调度，若你希望统一并入 `command` 包也可，默认独立成包以便按功能定位。

## 需修改的既有文件（仅替换值为常量引用，不改逻辑）

统一采用**限定引用**（`CommandConstants.STATUS_SUCCESS`），与现有 `ResponseConstants.SUCCESS_CODE` 用法一致；对批量出现的引用在类顶部加 `import static` 亦可，主用限定引用确保风格统一。

- `business-module/.../DeviceCommandServiceImpl.java`：替换 `DEFAULT_EXPIRE_SECONDS`、`DEFAULT_MAX_RETRY`、`qos(1)`、`retain(0)`、`status(0)`、`retryCount(0)`、`"system"`、`"WEB"`、`batchUpdateStatus(...,5)`、`Arrays.asList(3,4,5,6)`、`"设备执行失败"`
- `web-module/.../DeviceCommandController.java`：替换 `"web-user"`、`"WEB"`、`300`
- `web-module/.../schedule/CommandScheduler.java`：替换 `5000/30000/60000`、`50`、`30`、`30`、`"0 0 2 * * ?"`、`30`
- `business-module/.../DeviceDataServiceImpl.java`：替换 `setStatus(1)`、默认在线 `:1`、`"设备-" + deviceId`、`minusDays(30)`、`selectRecent(...100...)`、`selectRecentByDeviceId(...,20)`
- `web-module/.../mqtt/handler/DeviceHeartbeatHandler.java`：替换正则、历史限制 `100`
- `web-module/.../mqtt/handler/DeviceMosStateHandler.java`：替换 `TOPIC_PATTERN`、正则、`i<=7` 循环、`"mos" + i`、历史限制 `100`
- `web-module/.../mqtt/handler/DeviceSensorHandler.java`：替换 `TOPIC_PATTERN`、正则、`"slaves"/"addr"/"online"/"count"`
- `web-module/.../mqtt/MqttMessageHandler.java`（接口 default）：替换 `"device"` 前缀常量
- `web-module/.../mqtt/core/MqttPublisher.java`：替换默认 `qos 1/false`、header key、`device/%s/command`、payload key(`command/commandId/data/timestamp`)
- `web-module/.../mqtt/core/MqttConfig.java`：替换 `mqtt_receivedTopic` / `mqtt_receivedQos`、`-inbound` / `-outbound`

**保持不动**：`MqttProperties`（已是 `@ConfigurationProperties` 从 yml 注入的配置项）；Mapper XML；中英文日志文案；`JsonUtils`。

## 验证

1. 在根目录执行 `mvn -q compile`（或对应构建脚本）确认三个模块能通过编译——这是本次重构的核心验证（仅改常量引用，不应有编译错误）。
2. 双端抽查：确认 `DeviceCommandServiceImpl.prepareCommand` 中 `qos/source/operator` 等取值与重构前一致；`CommandScheduler` 各 `@Scheduled` 时间参数值不变；三个 MQTT handler 的 `supports()` 正则语义不变。
3. 运行 `web-module`（`mvn spring-boot:run`）确认应用正常启动、无 Bean 装配异常。