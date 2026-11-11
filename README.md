# WM_LAOHUA 智能家居物联网平台

> **文档版本：v1.4 对接说明**<br>
> **工程版本：`0.0.1-SNAPSHOT`**
> 本文档按当前源码与 `docs/FRONTEND_API.md` 编写；SQL 结构以 `web-module/src/main/resources/sql/smart_device.sql` 为准。旧资料与当前实现不一致时，以源码为准。文中的示例用于说明现有字段和协议，不代表数据库中存在该条记录。

## 目录

- [1. 项目概述](#1-项目概述)
- [2. 技术栈清单](#2-技术栈清单)
- [3. 整体架构总览](#3-整体架构总览)
- [4. 项目目录结构](#4-项目目录结构)
- [5. 数据库设计](#5-数据库设计)
- [6. 认证与权限体系](#6-认证与权限体系)
- [7. 限流与风控体系](#7-限流与风控体系)
- [8. HTTP 接口规范](#8-http-接口规范)
- [9. 接口模块说明](#9-接口模块说明)
- [10. MQTT 设备通信设计](#10-mqtt-设备通信设计)
- [11. WebSocket STOMP 实时推送](#11-websocket-stomp-实时推送)
- [12. OTA 升级全流程与状态机](#12-ota-升级全流程与状态机)
- [13. 枚举与字典](#13-枚举与字典)
- [14. 配置文件说明](#14-配置文件说明)
- [15. 打包、部署与启动](#15-打包部署与启动)
- [16. 已知限制与风险点](#16-已知限制与风险点)
- [17. 开发规范与新增功能流程](#17-开发规范与新增功能流程)
- [18. 联调测试清单](#18-联调测试清单)
- [19. 后续扩展方向](#19-后续扩展方向)
- [快速上手](#快速上手)

## 1. 项目概述

### 1.1 业务定位与目标用户

WM_LAOHUA 是面向智能家居设备管理的后端服务，覆盖管理端、终端用户与硬件设备三类使用方：

- **管理与运维人员**：管理用户、角色、权限、设备、固件、告警、OTA 任务及 MQTT 死信。
- **终端用户**：注册登录、绑定设备、查看设备和传感器数据、控制本人绑定的设备、处理告警及升级固件。
- **设备端**：通过 MQTT 注册、上报在线状态、心跳、状态、传感器、事件、ACK 与 OTA 进度。

### 1.2 核心能力

- JWT 双 Token 登录、刷新、登出、角色权限及设备归属检查。
- 用户和设备管理、设备绑定、指令下发与 ACK 状态追踪。
- 传感器历史、设备事件、状态变更、告警与在线信息。
- 固件上传、单设备 OTA、批量任务和升级进度跟踪。
- MQTT 设备注册与运行时消息处理、异常消息死信记录。
- STOMP WebSocket 实时推送及设备订阅鉴权。
- Redis 缓存/限流/令牌状态，MySQL 持久化业务数据。

### 1.3 v1.4 说明与设计亮点

本版对接范围重点覆盖三层限流风控、当前已落地的遗留接口，以及 MQTT、HTTP、WebSocket 三条链路。`v1.4` 是本对接文档的版本标签；Maven 工程版本仍为 `0.0.1-SNAPSHOT`，不能据此推断发布构建号。

平台按通信对象区分三条链路：

1. **前端 HTTP 链路**：浏览器/管理端调用 `/api/...`，经 Spring Security、JWT、方法权限和业务校验后访问服务层、MySQL/Redis。
2. **设备 MQTT 链路**：设备通过 TLS MQTT 上报；服务端校验/解析后更新数据库，并按需发布 MQTT 指令。
3. **前端实时推送链路**：服务端将 MQTT 处理结果封装为 STOMP 消息，通过 `/ws` 推送到已授权订阅者。

**关键边界：**前端界面隐藏按钮仅是 UX 控制；服务端接口权限、用户身份、设备绑定关系和业务状态校验才是强制安全边界。设备报文规则与前端 HTTP/WS 契约分开维护，不能将三者字段混用。

## 2. 技术栈清单

| 模块 | 实际技术 |
|---|---|
| 核心框架 | Java 17、Spring Boot 3.4.4、Maven 多模块 |
| 安全鉴权 | Spring Security、JWT（JJWT 0.12.6）、BCrypt（强度 12）、方法级 `@PreAuthorize` |
| MQTT 消息 | Eclipse Paho 1.2.5、Spring Integration MQTT、TLS/mTLS；运行时与设备注册两个 Broker 连接 |
| 持久层 | MyBatis-Plus 3.5.7、Mapper XML、MySQL Connector/J 8.0.33、Druid 1.2.23 |
| 缓存与并发 | Spring Data Redis、Lettuce、ShedLock Redis Provider |
| 实时推送 | Spring WebSocket、STOMP、SockJS、内存 Simple Broker |
| JSON / 校验 | Jackson、Jakarta Validation |
| API 文档 | Knife4j 4.4.0、Springdoc OpenAPI |
| 文件 | Spring Multipart；头像与固件由配置指定本地目录及对外 URL |
| 构建与部署 | Maven Wrapper、Spring Boot 可执行应用；源码未包含 Docker Compose 部署编排 |

## 3. 整体架构总览

```text
                         ┌──────────────────────────┐
                         │ 前端管理端 / 用户端       │
                         └───────────┬──────────────┘
                      HTTP /api      │       STOMP /ws
                                     │
         ┌───────────────────────────▼───────────────────────────┐
         │ 后端 Spring Boot（web-module）                         │
         │ Security/JWT → Controller → Service → Mapper           │
         │ MQTT Router/Handler → 业务处理 → WebSocketPushService   │
         └───────────┬──────────────────┬───────────────────┬─────┘
                     │                  │                   │
                  MySQL               Redis          MQTT TLS clients
                     │                  │            ┌──────┴──────┐
                     │                  │            │             │
             用户/设备/指令/记录   限流/令牌等     Broker:8883  Broker:8884
                                                       │             │
                                               运行时主题       /provision
                                                       │             │
                                                  设备端上报   设备注册握手
                                                       └──────┬──────┘
                                                              │
                                                    设备端 MQTT Client
```

### 3.1 前端 HTTP 请求链路

```text
前端 → CORS → JWT Filter → 角色/接口权限 → Controller 参数校验
     → 设备归属/业务状态校验 → Service → MyBatis Mapper → MySQL/Redis
     ← ApiResponse 或文件流
```

### 3.2 MQTT 设备上行链路

```text
设备 → TLS MQTT Broker → Paho inbound channel → MqttMessageReceiver
     → MqttMessageRouter → 匹配的 MessageHandler → 更新业务记录/状态
     → 需要实时通知时调用 WebSocketPushService → STOMP Simple Broker
     → 处理异常时写 sys_dead_letter
```

### 3.3 WebSocket 下行推送链路

```text
设备 MQTT 报文 → 后端 Handler 持久化/转换 → WebSocketMessageVO
     → /topic/device/{deviceId}/{type} → 已通过 CONNECT 与 SUBSCRIBE 校验的前端
```

MySQL 保存可查询的业务记录；Redis 提供认证、限流、缓存及 ShedLock 等运行能力；WebSocket Broker 当前是进程内 Simple Broker，不能当作 Redis 消息总线。

## 4. 项目目录结构

```text
WM_LAOHUA/
├─ common-module/
│  └─ src/main/java/com/womi/commonmodule/
│     ├─ constants/       # HTTP、权限、设备、MQTT、OTA、限流等常量
│     ├─ enums/           # 业务状态与错误码
│     ├─ exception/       # 业务异常、限流异常
│     ├─ properties/      # 配置绑定对象
│     ├─ response/        # ApiResponse
│     └─ utils/           # JWT、MAC、JSON、验证码等工具
├─ business-module/
│  ├─ src/main/java/com/womi/businessmodule/
│  │  ├─ config/          # MyBatis-Plus 配置
│  │  ├─ dto/             # 请求数据对象
│  │  ├─ handler/         # MyBatis 自动填充
│  │  ├─ mapper/          # sys/device Mapper 接口
│  │  ├─ model/           # 持久化 Entity
│  │  ├─ service/         # 领域服务接口
│  │  └─ vo/              # API/推送响应对象
│  └─ src/main/resources/mapper/ # MyBatis XML
└─ web-module/
   ├─ src/main/java/com/womi/webmodule/
   │  ├─ config/          # Security、CORS、Redis、WebSocket、ShedLock
   │  ├─ controller/      # auth、user、admin、common HTTP 入口
   │  ├─ filter/          # JWT 认证 Filter
   │  ├─ handler/         # HTTP 全局异常与安全处理器
   │  ├─ interceptor/     # STOMP CONNECT/SUBSCRIBE 拦截
   │  ├─ mqtt/            # MQTT config、publisher、router、handlers
   │  ├─ scheduler/       # 定时清理/状态维护任务
   │  ├─ security/        # 用户身份、设备订阅授权
   │  ├─ service/         # 应用服务及实现
   │  └─ resources/
   │     ├─ application*.yml
   │     ├─ mapper/       # Web 模块 Mapper XML
   │     ├─ sql/smart_device.sql
   │     └─ certs/、python/、html/
   └─ pom.xml
├─ docs/
│  ├─ FRONTEND_API.md     # 前端接口与 WS 对接资料
│  ├─ PROJECT_REVIEW.md   # 架构评估（辅助资料，可能落后于源码）
│  └─ MQTT服务器配置步骤.docx
└─ pom.xml
```

工程依赖方向为 `web-module → business-module → common-module`。业务能力有一部分应用服务实现位于 `web-module`，修改前应先沿 Controller → Service → Mapper/Handler 核对实际调用，不应仅凭目录名判断职责归属。

## 5. 数据库设计

初始化脚本：`web-module/src/main/resources/sql/smart_device.sql`。当前没有 Flyway/Liquibase 迁移目录；升级已有环境前应先备份并核对 SQL 增量，不能把初始化脚本直接视为安全的在线迁移。

### 5.1 核心表清单

| 表 | 用途 / 主要字段 |
|---|---|
| `sys_user` | 用户：`username`、`password_hash`、昵称、邮箱、手机号、头像、状态、逻辑删除标记 |
| `sys_role` | 角色：`role_code`、`role_name`、`status`、`built_in`、`deleted` |
| `sys_role_info` | 用户—角色关系：`user_id`、`role_id`，两者组合唯一 |
| `sys_permission` | 权限：`perm_code`、`perm_type`、资源、动作、状态、逻辑删除 |
| `sys_role_permission` | 角色—权限关系：`role_id`、`permission_id`，两者组合唯一 |
| `sys_refresh_token` | RefreshToken 的 SHA-256 哈希、用户、设备类型、到期时间、撤销标志 |
| `sys_login_log` | 用户名、IP、UA、登录成败、说明、登录时间 |
| `device_info` | 设备主记录：MAC、产品、固件、在线信息、能力/状态 JSON、OTA 状态、配置版本、逻辑删除 |
| `device_binding` | 设备与用户关系：`device_id`、生成列 `active_device_id`、`user_id`、`bind_status`、绑定/解绑时间 |
| `device_mqtt_auth` | MQTT 账号、密码哈希/盐、启用状态、设备关联 |
| `device_group` | 设备分组 |
| `device_whitelist` | 设备白名单 |
| `device_sensor` | 设备传感器元数据：`device_id`、`sensor_key`、类型、来源、单位、规格 JSON |
| `device_sensor_record` | 传感器历史数据 |
| `device_sensor_threshold` | 传感器阈值配置 |
| `device_slave_data` | 设备下挂从机信息 |
| `device_heartbeat_record` | 心跳历史记录 |
| `device_state_record` | 外设状态变化历史 |
| `device_event_record` | 设备事件与错误记录 |
| `device_alert_record` | 告警等级、类型、值/阈值、处理状态及处理人 |
| `device_command` | 下行指令及其状态、重试、响应和时间信息 |
| `device_firmware` | 固件版本、产品、URL、MD5/SHA-256、大小、启用状态 |
| `device_ota_task` | 批量 OTA 任务与成功/失败/待处理统计 |
| `sys_dead_letter` | MQTT 失败消息原始主题、报文、异常摘要、重放状态及次数 |

### 5.2 约束与状态字段

- `device_info.device_id`、`device_info.bind_code` 与 `deleted` 组合唯一；设备 MAC 的业务格式为 12 位十六进制。
- `device_binding.active_device_id` 是 `bind_status=1` 时等于 `device_id`、否则为 `NULL` 的生成列，唯一索引保证设备最多一条有效绑定。
- `device_command.command_id` 唯一；`device_firmware` 的 `(version, product)` 唯一；角色编码、权限编码、RefreshToken 哈希均有唯一约束。
- `device_info.capabilities`、`current_state`、OTA 相关数据以及部分指令/事件扩展内容使用 JSON 列；不要假设设备 JSON 的内部属性在所有型号间完全相同。
- 内置角色为 `ADMIN`、`OPS`、`USER`，SQL 标记 `built_in=1`。服务层对内置角色的删除、改编码、禁用等操作有限制。
- MyBatis-Plus 全局逻辑删除字段为 `deleted`，默认逻辑删除值为 `1`、未删除值为 `0`；`device_info.deleted` 为 `bigint`，非零值记录删除时间戳/ID。绑定关系采用 `bind_status` 解绑，不等同于逻辑删除。
- 并非所有业务表都定义 `deleted` 字段；应以具体 Entity、Mapper 与 SQL 为准，不要推断所有删除操作均为逻辑删除。

### 5.3 数据表示例

以下传感器历史记录来自 SQL 脚本中的真实字段和值，截取为便于联调的 JSON 表示：

```json
{
  "device_id": "B4BFE90CDBA1",
  "source": "slave",
  "slave_address": 1,
  "sensor_key": "temp",
  "sensor_type": "temperature",
  "sensor_value": 35.5,
  "unit": "℃",
  "timestamp": "2026-11-05 15:49:37.316"
}
```

`device_command` 的字段形态示例（值为说明用途，不表示该指令已存在）：

```json
{
  "command_id": "示例指令ID",
  "device_id": "B4BFE90CDBA1",
  "action": "set",
  "target": "led",
  "channel": 1,
  "params": { "state": 1 },
  "status": 0,
  "source": "WEB"
}
```

`status=0` 表示 `PENDING`，其余指令状态见[第 13 章](#13-枚举与字典)。

## 6. 认证与权限体系

### 6.1 Spring Security 配置

- `SecurityConfig` 使用无状态 `SessionCreationPolicy.STATELESS`，关闭 CSRF，启用 CORS。
- `JwtAuthenticationFilter` 在用户名密码认证 Filter 前解析访问令牌；Spring Security 负责认证态，方法级授权由 `@EnableMethodSecurity` 与 `@PreAuthorize` 执行。
- 密码使用 BCrypt，强度 12。
- 登录、注册、刷新、验证码、WebSocket 握手端点、健康检查与头像资源按配置放行；其余 HTTP 请求要求认证。
- 未认证由 `JsonAuthenticationEntryPoint` 返回 401；接口权限不足由安全处理器或 `GlobalExceptionHandler` 返回 403。

### 6.2 AccessToken 与 RefreshToken

| 项 | 约定 |
|---|---|
| AccessToken | 登录返回字段名为 `token`；HTTP 请求使用 `Authorization: Bearer ${token}`；默认有效期 `my.jwt.expiration-ms=86400000`（24 小时） |
| RefreshToken | 登录返回 `refreshToken`，有效期 7 天；服务端在 `sys_refresh_token` 保存 SHA-256 哈希而非原始令牌 |
| 旋转 | `/api/auth/refresh` 原子消费旧 RefreshToken 并签发新的 AccessToken + RefreshToken |
| 黑名单 | 登出时可将 AccessToken 的 JTI 写入黑名单，并撤销请求携带的 RefreshToken |
| 设备类型 | 登录可选 `X-Device-Type`（默认 `web`），记录于 RefreshToken |

**并发刷新坑点：**同一 RefreshToken 并发请求只有一个可以成功消费；其余会收到 `4012`。前端必须实现单飞刷新锁：并发 401 请求等待同一次刷新结果，刷新成功后统一替换两个令牌并重放；刷新失败时清理令牌并转登录页。禁止多个拦截器各自并发刷新。

### 6.3 RBAC 与接口权限码

授权由角色、权限码、HTTP 路径角色范围三部分构成：

1. `sys_user` 经 `sys_role_info` 关联 `sys_role`。
2. 角色经 `sys_role_permission` 关联 `sys_permission.perm_code`。
3. 管理接口通过 `@PreAuthorize("hasAuthority('...')")` 检查权限码；`/api/admin/**` 还经过 Security 路径级角色过滤（`ADMIN` 或 `OPS`）。死信接口显式使用 `hasRole('ADMIN')`；角色/权限管理也依赖相应 `role:*` / `permission:*` 权限码。

当前权限码包括：

```text
user:list  user:create  user:update  user:delete
role:list  role:create  role:update  role:delete  role:assign-permission
permission:list  permission:create  permission:update  permission:delete
device:list  device:read  device:create  device:update  device:delete  device:unbind
command:send
firmware:upload  firmware:delete  ota:list  ota:create  ota:cancel
alert:list  alert:handle  system:config
```

管理端前端可使用登录响应中的 `roles`、`permissions` 做菜单和按钮展示；这只用于 UI 控制。**后端每次受保护接口调用仍须通过 Security 与权限校验，不能将前端菜单拦截视作鉴权。**

### 6.4 设备归属校验

用户侧设备接口在认证之外校验设备是否与当前用户存在有效绑定（`bind_status=1`）。普通用户只能读取或操作自己的设备；路径中的 `deviceId` 不能作为授权凭据。告警确认等跨设备资源也会检查归属。

管理员 WebSocket 订阅权限不等于任意用户 HTTP 权限；两套链路分别在 STOMP `SUBSCRIBE` 和 HTTP Controller/Service 处执行授权。

### 6.5 登录失败锁定与验证码

- 图片验证码在 `captcha.enabled=true` 时启用，登录需传 `captchaId` 与 `captchaCode`；验证码为一次性校验，校验通过后失效，过期或多次输入错误应重新获取。
- 用户名密码错误按账号计数：5 次失败锁定 15 分钟；达到更高失败阈值会延长锁定（风控常量为 10 次、1 小时）。账号锁定返回 `4013`。
- 验证码错误不计入密码错误的账号锁定；账号不存在按 IP/设备维度计入匿名失败，降低用户枚举风险。
- 注册密码规则见接口 DTO/校验；前端可预校验长度和组成，服务端校验为最终依据。

## 7. 限流与风控体系

服务端由 `RateLimitService` 与 Redis 计数实现三层保护。所有限流异常使用 HTTP `429`，响应仍为 `ApiResponse`；仅按 HTTP 200 处理业务结果的客户端会漏掉该分支。

### 7.1 第一层：验证码获取限流

接口：`POST /api/auth/captcha`

| 维度 | 阈值 | 返回 |
|---|---:|---|
| IP | 每分钟 10 次 | HTTP 429，业务码 `4600` |
| IP | 每小时 100 次 | HTTP 429，业务码 `4600` |
| `X-Device-Id` | 每分钟 5 次 | HTTP 429，业务码 `4600` |

### 7.2 第二层：登录请求限流

在验证码校验之前执行。

| 维度 | 阈值 / 动作 | 返回 |
|---|---|---|
| IP | 每分钟超过 10 次，临时封锁 15 分钟 | 首次 `4600`；封锁期间 `4602` |
| IP | 每小时超过 50 次，要求人机验证 | `4601` |
| `X-Device-Id` | 每分钟超过 5 次，要求人机验证 | `4601` |
| 账号 | 每分钟超过 5 次，仅做频率限制 | `4600` |

### 7.3 第三层：失败计数与风控升级

| 失败类型 | 计数维度与动作 |
|---|---|
| 验证码错误/过期 | IP、设备每小时 20 次触发 `4601` 人机验证；50 次临时封 IP 15 分钟 |
| 账号不存在 | 按 IP/设备失败计数，防止账号枚举 |
| 密码错误 | 账号 5 次锁定 15 分钟；10 次锁定 1 小时 |
| 验证码错误 | 不计入密码错误账号锁定 |

`4600` 表示请求频率超限；`4601` 表示需要人机验证；`4602` 表示 IP 当前受限。业务语义不可合并为单一错误提示。

### 7.4 `X-Device-Id` 与前端要求

- 前端生成稳定 UUID 并持久化；验证码和登录请求应始终携带相同的 `X-Device-Id`。
- 不携带时后端降级使用客户端 IP，IP 与设备维度计数可能叠加；该指纹仅用于限流，不是登录身份凭据。
- 前端对按钮倒计时、验证码刷新、滑块/行为验证提示和账号锁定倒计时负责；限流、计数、封禁与强制校验由后端负责。
- **当前 CORS 配置风险：**`CorsConfig` 的允许请求头列表包含 `Authorization`、`Content-Type` 等，但未包含 `X-Device-Id`。浏览器跨域预检可能因此拒绝登录/验证码请求。部署联调前应将其加入后端 CORS 白名单配置；文档不能替代该源码配置。

## 8. HTTP 接口规范

### 8.1 BaseURL、请求头、跨域与时间

- 本地 BaseURL：`http://localhost:8080`。生产地址由部署环境提供。
- 不存在全局 context-path；Controller 自身定义 `/api/...` 路径。
- 需认证的请求头：`Authorization` 的值为 `Bearer`、一个空格和登录返回的 `token`。登录/注册/刷新不要求 AccessToken。
- 登录可选 `X-Device-Type: web|app|mini`；验证码和登录建议传 `X-Device-Id`。
- JSON 请求使用 `Content-Type: application/json`；文件上传使用 `multipart/form-data`。
- CORS 使用 `cors.allowed-origins` 白名单。浏览器跨域请求必须将前端 Origin 加入该列表。
- 服务端 Jackson 时区为 `Asia/Shanghai`。常规日期时间多为 ISO-8601；登录响应的 `lastLoginTime`、`expiresAt` 使用 `yyyy-MM-dd HH:mm:ss`。

### 8.2 分页约定

分页参数为 `pageNum`、`pageSize`，缺省为 1、10（具体接口也可能有自己的默认值）。MyBatis-Plus 分页对象字段：

```json
{
  "records": [],
  "total": 25,
  "size": 10,
  "current": 1,
  "pages": 3
}
```

前端从 `data.records` 读取当前页，从 `data.total` 获取总数。

### 8.3 统一响应与状态码

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2026-11-05T10:30:00"
}
```

| 场景 | HTTP 状态 | 业务码 |
|---|---:|---:|
| 成功 | 200 | `200` |
| 大部分业务/参数校验异常 | 200 | 例如 `1000`、`2000`、`4200` |
| 未认证 / Token 失效 | 401 | `401` 或认证业务错误码 |
| 方法权限不足 | 403 | `401`（`FAIL`），message 为权限不足 |
| 限流 | 429 | `4600`、`4601`、`4602` |
| 静态资源不存在 | 404 | `404` |
| 系统兜底异常 | 由处理分支决定 | `5000` 等 |

**前端处理规则：**业务成功必须判断 `code === 200`，不能只判断 HTTP 200；遇 HTTP 401 应按令牌策略刷新或跳转；HTTP 403 应提示无权限；HTTP 429 必须按具体业务码区分。部分 API 会直接返回 CSV 或文件，不是 JSON。

### 8.4 主要业务码

错误码以 `common-module/.../ErrorCode.java` 为准。常用分组如下：

| 范围 / 码 | 含义 |
|---|---|
| `1000`–`1011` | 参数与密码校验 |
| `2000` | 通用业务异常 |
| `4000`–`4004` | 上传文件错误 |
| `4010`–`4015` | 登录、账号状态、RefreshToken、认证 |
| `4020`–`4024` | 权限管理业务错误 |
| `4030`–`4034` | 验证码过期、错误、必填、类型或生成失败 |
| `4100`–`4107` | 固件版本、文件、哈希错误 |
| `4200`–`4212` | 设备不存在、离线、绑定、MAC 等 |
| `4300`–`4303` | OTA 触发、进行中、兼容性、已是最新版本 |
| `4400`–`4404` | 角色管理 |
| `4500`–`4502` | 用户名、角色分配、用户状态 |
| `4600`–`4602` | 请求频率超限、人机验证、网络访问限制 |
| `5000`–`5003` | 系统、数据库、配置、网络异常 |

认证常用码：`4010` 凭据错误、`4011` 账号禁用、`4012` RefreshToken 无效/已消费、`4013` 账号锁定、`4014` Token 无效或过期。设备归属不足通常使用 `4209`/`4210`，OTA 已进行中为 `4301`。

### 8.5 全局异常处理、文档与健康检查

- `GlobalExceptionHandler` 将业务异常、校验异常、限流异常和兜底异常转换为 `ApiResponse`。业务异常大多 HTTP 200；限流显式 HTTP 429；权限异常 HTTP 403。
- Knife4j：开发环境 `http://localhost:8080/doc.html`；OpenAPI JSON：`/v3/api-docs`。生产 `knife4j.enable=false` 且关闭 Springdoc API 文档。
- 健康检查：`GET /actuator/health`，匿名可访问，details 不对外展示。

## 9. 接口模块说明

以下按当前 Controller 与 `docs/FRONTEND_API.md` 汇总。参数和响应字段以相应 DTO/VO 与 Knife4j 为准；省略的分页筛选项不代表服务端不支持。

| 模块 | 核心接口 | 权限与关键规则 |
|---|---|---|
| 认证模块 | `POST /api/auth/register`、`/login`、`/refresh`、`/logout`、`/captcha` | 登录注册/刷新匿名；登录需验证码（启用时）；刷新令牌串行消费 |
| 用户中心模块 | `GET/PUT /api/user/profile`、`PUT/POST /api/user/password`、`GET /api/user/login-logs` | 登录用户；改密码会撤销该用户 RefreshToken |
| 用户设备模块 | `POST /api/user/devices/bind`、`/unbind`；`GET /my`、`/{deviceId}`、`/{deviceId}/online`；`PUT /{deviceId}` | 登录 + 对需要设备 ID 的调用进行归属校验；绑定需要 `deviceId` 和机身绑定码 |
| 设备控制与指令 | `POST /api/user/devices/control`；`GET /api/user/commands`、`/{commandId}`；取消、统计、批量接口 | 登录 + 设备归属；操作成功仅代表受理，不代表设备执行成功；用 `commandId` 匹配 ACK 推送或轮询 |
| 传感器、事件、告警 | `/api/user/devices/{deviceId}/sensors`、`/sensors/latest`、`/events`、`/states`；`/api/user/alerts`、`/{id}/ack` | 登录 + 绑定设备检查；告警确认检查用户归属 |
| OTA 固件升级 | 用户端 `/api/user/ota/check/{deviceId}`、`/start/{deviceId}`、`/progress/{deviceId}`、`/records`、`/retry/{deviceId}`；管理端 `/api/admin/ota/firmware/**`、`/tasks/**`、`/batch-dispatch` | 用户端需登录与设备绑定；管理端按 `ota:*`、`firmware:*` 校验；开始升级前须确认在线、产品/版本兼容 |
| 管理端用户 | `/api/admin/users`、`/{id}`、`/{id}/status`、`/{id}/roles`、`/{id}/devices`、`/{id}/force-unbind` | 按 `user:list/create/update/delete` 和 `device:unbind` 等权限码 |
| 管理端角色/权限 | `/api/admin/roles/**`、`/api/admin/permissions/**` | 分别使用 `role:*`、`permission:*` 权限码；内置角色受保护；权限码被角色引用时不能删除 |
| 运维、仪表盘、审计、死信 | `/api/admin/dashboard/summary`、`/commands`、`/alerts`、`/audit-logs`、`/dead-letters/**` | 仪表盘/指令/告警/审计按相应 `device:list`、`alert:*` 等权限；死信接口要求 `ROLE_ADMIN` |
| 通用上传与字典 | `POST /api/common/upload/avatar`、`GET /api/common/dictionaries` | 登录用户；头像使用 multipart 字段 `file`，上传成功后需将 URL 写回资料 |
| 健康检查 | `GET /actuator/health` | 匿名；仅提供健康状态 |

### 9.1 精简 API 示例：下发设备控制

```http
POST /api/user/devices/control
Authorization: Bearer ${accessToken}
Content-Type: application/json
```

```json
{
  "deviceId": "B4BFE90CDBA1",
  "action": "set",
  "target": "led",
  "channel": 1,
  "params": { "state": 1 }
}
```

响应 `data` 为该条指令的 `commandId`。服务端校验身份、设备归属及设备状态；`action`/`target` 的可用组合仍需前端按 `capabilities` 展示，设备固件也必须按支持能力执行。

### 9.2 常用管理接口与权限码

| 方法与路径 | 权限码/角色 | 业务说明 |
|---|---|---|
| `GET /api/admin/devices` | `device:list` | 设备分页与关键字筛选 |
| `POST /api/admin/devices`、`PUT/DELETE /api/admin/devices/{id}` | `device:create/update/delete` | 管理设备记录 |
| `POST /api/admin/devices/{id}/command` | `command:send` | 管理端下发设备指令 |
| `POST /api/admin/ota/firmware/upload` | `firmware:upload` | 上传 `.bin` 固件 |
| `POST /api/admin/ota/batch-dispatch` | `ota:create` | 按固件/产品批量下发并生成任务 |
| `POST /api/admin/ota/tasks/{id}/cancel` | `ota:cancel` | 取消仍为 PENDING 的子指令 |
| `GET /api/admin/alerts`、`PUT /api/admin/alerts/{id}/status` | `alert:list` / `alert:handle` | 查询和处理告警 |
| `GET /api/admin/dead-letters`、`POST .../{id}/replay`、`POST .../{id}/ignore` | `ROLE_ADMIN` | 查看、重放或忽略死信 |

具体分页参数、筛选条件、导出内容、响应 VO 以 Controller/Knife4j 为准。`GET /api/admin/devices/export` 返回 CSV 文件流，不走统一 JSON 响应体。

## 10. MQTT 设备通信设计

### 10.1 Broker 与安全通道

后端有两套 TLS MQTT 连接，具体地址和账号来自 `mqtt.runtime`、`mqtt.provision`：

- **运行时 Broker：8883**，设备身份认证后使用，后端订阅心跳、状态、ACK、事件、传感器、OTA 进度及 `presence`。
- **注册 Broker：8884**，仅用于设备 `/register` 请求与后端 `/config` 响应。
- Java 客户端配置 CA、客户端证书 PKCS#12、证书密码；运行时 Broker 可额外配置用户名/密码。
- 注册响应中的设备 MQTT 凭据为单设备凭据；硬件固件不得复用服务端凭据，也不得将生产凭据写进 README 或固件仓库。

### 10.2 主题路径

| 方向 | Topic | 用途 |
|---|---|---|
| 设备→服务端 | `/provision/device/{mac}/register` | 首次注册/重新注册请求 |
| 服务端→设备 | `/provision/device/{mac}/config` | 注册响应、运行参数及 LWT 配置 |
| 设备→服务端 | `device/{mac}/presence` | 上线/离线状态；LWT 遗嘱也发布至该主题 |
| 设备→服务端 | `device/{mac}/heartbeat` | 心跳、运行时间 |
| 设备→服务端 | `device/{mac}/state` | 外设状态变化 |
| 设备→服务端 | `device/{mac}/ack` | 指令执行回执 |
| 设备→服务端 | `device/{mac}/event` | 事件/错误 |
| 设备→服务端 | `device/{mac}/sensor` | 传感器数据 |
| 设备→服务端 | `device/{mac}/ota_progress` | OTA 阶段与进度 |
| 服务端→设备 | `device/{mac}/command` | 单设备控制/OTA 指令 |

`{mac}` 使用设备 MAC 标识；例如 `B4BFE90CDBA1`。主题名、大小写、分隔符和报文字段是设备契约，禁止前端或固件自行改写。

### 10.3 注册与 LWT（遗嘱）

注册请求位于 `/provision/device/{mac}/register`。源码要求设备身份材料包含设备公钥、nonce、时间戳、签名；签名内容为 `deviceId|timestamp|nonce`。注册成功后服务端返回 MQTT 连接配置、LWT 配置及设备配置。私钥只保存在设备端，不能随普通业务消息传输。

注册成功响应中的 `will` 包括 `topic`、`qos`、`retain`、`payload`。设备端需将这组值原样配置为 MQTT CONNECT 的 LWT。当前服务端生成的 LWT topic 是 `device/{mac}/presence`，payload 形状如下：

```json
{
  "device": "B4BFE90CDBA1",
  "product": "SmartHome-v1",
  "type": "offline",
  "timestamp": 0,
  "data": { "reason": "mqtt_lwt" }
}
```

`timestamp` 的具体默认值由服务端常量提供，设备应使用返回的 `will.payload`，不要自行拼接。服务端同一 `presence` Handler 处理 `type=online|offline`，缺失离线原因时归为 `mqtt_lwt`。主动离线报文使用相同结构并由设备发布到 `presence`。

### 10.4 上行报文规则与示例

运行时消息通常包含 `device`、`type`、毫秒时间戳 `timestamp` 和业务 `data`。Topic 中的 MAC 用于路由；注册 Handler 还会校验报文 `device` 与 Topic 中的设备 ID 是否一致。其余 Handler 的字段要求以各自 Handler 的实际解析逻辑为准。

传感器示例（`device/{mac}/sensor`）：

```json
{
  "device": "B4BFE90CDBA1",
  "type": "sensor_batch",
  "timestamp": 1710000000000,
  "data": [
    {
      "source": "slave",
      "address": 1,
      "sensor_key": "temp",
      "sensor_type": "temperature",
      "value": 25.5,
      "unit": "℃"
    }
  ]
}
```

ACK 示例（`device/{mac}/ack`）：

```json
{
  "device": "B4BFE90CDBA1",
  "commandId": "服务端下发的commandId",
  "type": "ack",
  "success": true,
  "timestamp": 1710000000000,
  "data": { "state": 1 },
  "message": null
}
```

OTA 进度示例（`device/{mac}/ota_progress`）：

```json
{
  "device": "B4BFE90CDBA1",
  "type": "ota_progress",
  "commandId": "服务端下发的OTA commandId",
  "timestamp": 1710000000000,
  "data": {
    "otaState": "downloading",
    "progress": 45,
    "version": "1.0.30",
    "error": null
  }
}
```

OTA `otaState` 为必填；进度被服务端限制在 0–100，`success` 阶段归一为 100。失败原因优先使用 `data.error`，其次 `data.message` / 顶层 `message`。

### 10.5 下行指令与设备端处理

服务端在 `device/{mac}/command` 发布精简的 JSON 命令，字段包括 `commandId`、`action`、`target`、可选 `channel`、可选 `params` 与毫秒 `timestamp`。示例：

```json
{
  "commandId": "服务端生成的指令ID",
  "action": "set",
  "target": "led",
  "channel": 1,
  "params": { "state": 1 },
  "timestamp": 1710000000000
}
```

设备端应保留并原样回传 `commandId`，执行后发送 ACK；服务端按 `deviceId + commandId` 关联指令。HTTP 成功仅表示指令已受理/尝试下发，不表示硬件已完成动作。设备收到指令后还应按固件实际能力校验 `action`、`target`、`channel` 与参数。

### 10.6 消息消费、死信与重放

1. `MqttMessageReceiver` 取得 topic、payload、QoS，交给 `MqttMessageRouter`。
2. Router 选择第一个支持该 topic 的 Handler，执行校验、写入业务表及必要的 WS 推送。
3. 无 Handler 时记录警告，不自动生成业务结果。
4. Handler 抛异常时 Router 将原始 topic/payload、异常摘要与可重试标记写入 `sys_dead_letter`，捕获异常后让 MQTT 消费流程正常 ACK，避免“毒丸”消息无限投递。
5. `IllegalArgumentException` 被标为不可重试；其他异常可重试。管理员可以查询详情、重放或忽略；忽略状态为 `2` 后不再重放。

死信表保存原始报文，可能包含设备标识及业务数据；生产环境应限制访问并按数据保留策略处理。重放前应先修复导致失败的配置/代码问题，并确认该消息具备幂等处理条件。

## 11. WebSocket STOMP 实时推送

### 11.1 连接地址与鉴权

| HTTP BaseURL | WebSocket/SockJS endpoint |
|---|---|
| `http://localhost:8080` | `/ws`（SockJS，浏览器优先使用 SockJS） |
| `https://host.example` | `/ws`（使用 `wss`） |

连接先建立 SockJS，再发送 STOMP `CONNECT` 帧，Native Header 必须为 `Authorization: Bearer <AccessToken>`。不支持将 Token 放在 URL 查询参数或 Cookie 中。完成 `CONNECTED` 后再 `SUBSCRIBE`。

### 11.2 订阅主题与授权

每台设备的订阅路径：

```text
/topic/device/{deviceId}/state
/topic/device/{deviceId}/sensor
/topic/device/{deviceId}/alert
/topic/device/{deviceId}/ota
/topic/device/{deviceId}/command
```

服务端用 `/topic`、`/queue` 作为 Simple Broker 前缀，`/app` 是客户端发给后端的应用前缀；当前没有 `@MessageMapping` 接收业务消息，前端只需订阅。

- 管理员 `ADMIN` 可订阅 `/topic/**`。
- 非管理员只能订阅格式合法的设备主题，并且该设备必须是当前用户有效绑定设备；非设备主题、错误 topic、未绑定设备会拒绝并返回 STOMP ERROR。
- SUBSCRIBE 鉴权是后端强制校验；前端只对可订阅设备进行 UI 管理。

### 11.3 统一信封与五种消息

所有推送采用 `WebSocketMessageVO`：

```json
{
  "type": "command_result",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T10:30:00",
  "data": {
    "commandId": "服务端指令ID",
    "status": 2,
    "statusText": "成功",
    "success": true
  }
}
```

| `type` | 目标主题 | `data` 用途 |
|---|---|---|
| `state` | `/state` | `target`、`channel`、`state` 等外设状态 |
| `sensor` | `/sensor` | 传感器记录数组 |
| `alert` | `/alert` | 告警记录 |
| `ota_progress` | `/ota` | `otaState`、`otaStateText`、`progress`、`version`、`commandId`、`error`、`reportTime` |
| `command_result` | `/command` | `commandId`、指令状态/文案、成功标记、错误、设备 ACK 数据及时间 |

业务对象字段随具体 VO/设备上报而异；前端应按 `type` 做分发和可选字段容错。外层时间为服务端推送时间，OTA `data.reportTime` 为设备报告时间。

### 11.4 保活、重连与 Token 过期

- 服务端没有显式覆盖 STOMP 心跳配置。前端应配置 STOMP 心跳、连接超时和重连；重连后在 `onConnect` 中重新订阅，STOMP 不会自动恢复订阅。
- 重连前应确保 AccessToken 有效；Token 过期后通过 HTTP RefreshToken 流程换取新双 Token，再重连。订阅失败通常是权限/绑定问题，不应无限重连。
- 页面关闭、登出时应取消订阅并断开连接。
- Nginx 需允许 WebSocket `Upgrade` / `Connection` 头并设置合适的读超时；反向代理空闲超时必须配合客户端心跳。

**架构限制：**当前使用 Spring 内存 Simple Broker，消息只在产生消息的应用实例内广播。多实例部署时，连接在其他实例的前端无法保证收到推送；需要单实例、粘性会话（仍无法解决跨实例广播）或后续引入共享 Broker/外部消息代理。

## 12. OTA 升级全流程与状态机

### 12.1 单设备升级

```text
前端 GET /ota/check/{deviceId}
  → 校验设备/固件/版本
  → 先订阅 /topic/device/{deviceId}/ota（建议同时订阅 /command）
  → POST /ota/start/{deviceId}
  → 服务端写 device_command 并向 device/{mac}/command 发布 OTA 命令
  → 设备 ACK 和 ota_progress 上报
  → 服务端更新 device_info / device_command，WebSocket 推送
  → 前端收到 success/failed，刷新设备与 OTA 历史
```

`POST /api/user/ota/start/{deviceId}` 不返回 `commandId`。前端应先订阅，再从首个进度推送或 `GET /api/user/ota/progress/{deviceId}` 取得关联命令 ID。

### 12.2 OTA 阶段状态机

```text
accepted → downloading → verifying → flashing → rebooting → success
    └────────────── 任一阶段失败 ───────────────────────────→ failed
```

| `otaState` | 含义 |
|---|---|
| `accepted` | 设备已接受升级 |
| `downloading` | 下载固件 |
| `verifying` | 校验固件 |
| `flashing` | 写入固件 |
| `rebooting` | 设备重启 |
| `success` | 升级成功 |
| `failed` | 升级失败 |

运行中状态包括前五项；终态为 `success`、`failed`。进度范围 0–100，成功强制为 100；错误进度会归一化。服务端按阶段更新 `device_info.ota_*` 并向 WebSocket 推送进度；设备未发 ACK 时，OTA 进度仍可推进关联指令状态。已进入终态的指令不会被迟到的中间进度覆盖。

### 12.3 批量任务、取消、重试与校验

- 管理端 `POST /api/admin/ota/batch-dispatch` 同步执行目标设备筛选和指令生成，返回成功生成指令的设备数量；生成 `device_ota_task`，关联子指令参数中的 `taskId`。
- 任务统计包含总数、成功、失败、待处理。详情可关联设备状态；列表统计可能需要刷新后更新。
- 取消任务仅对仍为 `PENDING(0)` 的子指令生效；已下发或已执行指令不能通过任务取消撤回。
- 用户端重试仅允许最近一次 OTA 记录为 `FAILED(3)`、`TIMEOUT(4)` 或 `CANCELLED(5)`。
- 设备离线、无可用新版本、产品/固件不兼容、同一设备存在 OTA 运行状态时，服务端分别按业务规则拒绝，常见码为 `4201`、`4301`、`4302`、`4303`。
- 长时间未更新的运行态会按 5 分钟僵死阈值清理/协调；重新打开页面或重连时先拉取进度快照。

### 12.4 实时推送与轮询兜底

WebSocket 是实时通道，`GET /api/user/ota/progress/{deviceId}` 是恢复/补偿快照；升级历史通过 `/api/user/ota/records?deviceId=...` 获取。建议进行中每 1–2 秒轮询，页面打开/重连立即拉一次；得到终态后停止轮询。UI 可以按同一 `commandId` 防止进度回退，但后端状态是最终依据。

## 13. 枚举与字典

不要在前端复制一份长期不更新的状态映射。`GET /api/common/dictionaries` 返回通用字典 Map，建议启动/登录后缓存并按服务端返回值展示；该接口用于展示契约，不代替后端业务校验。

| 字典 | 取值 |
|---|---|
| 设备在线状态 | `0` 离线、`1` 在线、`2` 故障 |
| 指令状态 | `0` PENDING、`1` SENT、`2` SUCCESS、`3` FAILED、`4` TIMEOUT、`5` CANCELLED、`6` ACCEPTED |
| OTA 阶段 | `accepted`、`downloading`、`verifying`、`flashing`、`rebooting`、`success`、`failed` |
| OTA 批量任务 | `0` 进行中、`1` 完成、`2` 取消 |
| 固件状态 | `0` 禁用、`1` 启用 |
| 告警级别 | `1` 提示、`2` 一般、`3` 严重 |
| 告警状态 | `0` 未处理、`1` 已确认、`2` 已解决 |
| 死信状态 | `0` 未处理、`1` 重放成功、`2` 已忽略 |
| 绑定状态 | `1` 有效绑定、`0` 已解绑 |

绑定状态是数据关系状态；告警、固件、死信状态是各自数据表语义，不可互相套用。离线原因当前以字符串返回，应容忍未知值。

## 14. 配置文件说明

| 文件 | 用途 |
|---|---|
| `web-module/src/main/resources/application.yml` | 通用端口、MySQL 池、Redis 池、Jackson 时区、上传限制、MyBatis-Plus、MQTT 默认主题/QoS、验证码、JWT、Knife4j、Actuator |
| `application-dev.yml` | 本地 MySQL/Redis、运行时 MQTT/注册 MQTT、本地域名 CORS、固件目录与下载 BaseURL |
| `application-prod.yml` | 生产 DB/Redis/MQTT 环境变量、生产 CORS、固件路径与 URL、日志文件、关闭 Knife4j/OpenAPI |

关键配置项：

- **数据库**：生产 `DB_HOST`、`DB_USERNAME`、`DB_PASSWORD`；开发可覆盖 `DEV_DB_USER`、`DEV_DB_PASS`。
- **Redis**：生产 `REDIS_HOST`、`REDIS_PASSWORD`。
- **MQTT**：生产 `MQTT_HOST`、`MQTT_USERNAME`、`MQTT_PASSWORD`、`MQTT_PROVISION_USERNAME`、`MQTT_PROVISION_PASSWORD`。CA、客户端证书和证书密码也应按目标环境核验。
- **JWT**：通过 `JWT_SECRET` 提供生产签名密钥，不得使用仓库中的开发默认值。
- **CORS**：`cors.allowed-origins` 配置精确的前端 Origin；当前生产 YAML 使用示例域名，部署必须替换。还需按[第 7 章](#7-限流与风控体系)补齐 `X-Device-Id` 允许头。
- **文件**：`firmware.upload-dir`、`firmware.base-url` 及头像目录需保证服务进程有权限且对外下载地址可达；上传默认单文件 16 MB、请求 20 MB。
- **验证码**：`captcha.enabled`、有效期、图片尺寸等在通用配置定义。
- **Knife4j**：生产配置关闭 Knife4j 与 OpenAPI。
- **限流开关**：当前展示的 YAML 未定义限流总开关；不要假设通过配置项即可关闭限流，行为以 `RateLimitService` 实现为准。

**安全要求：**仓库中的开发 YAML 含本地演示账号/密码默认值和开发 JWT 默认值；这些仅为本地配置便利，不可用于生产。证书、私钥、数据库密码、MQTT 凭据均应由部署环境安全注入并进行轮换。

## 15. 打包、部署与启动

### 15.1 构建与启动

在仓库根目录执行：

```powershell
.\mvnw.cmd clean package
$env:SPRING_PROFILES_ACTIVE = "dev"
```

构建结束后，运行 `web-module` 模块生成的可执行 JAR。JAR 的确切文件名以 `web-module/target/` 中 Maven 产物为准：

```powershell
java -jar .\web-module\target\web-module-0.0.1-SNAPSHOT.jar
```

部署前先准备 MySQL（导入 `smart_device.sql`）、Redis、两个 MQTT TLS 监听端口、证书文件和可访问的固件/头像目录。开发 profile 默认使用本机服务地址；生产切换为 `SPRING_PROFILES_ACTIVE=prod` 并设置所需环境变量。不要把本机 SQL 密码或证书密码复制到生产环境。

### 15.2 Nginx 反向代理要点

- 普通 API 代理保留 Host、客户端 IP 与协议头；如服务端按真实 IP 限流，应配置可信代理来源及转发头处理，不能信任任意客户端自带的 `X-Forwarded-For`。
- `/ws` 必须允许 WebSocket Upgrade，并延长读超时；下例为配置要点，域名/证书/上游地址需替换：

```nginx
location /ws {
    proxy_pass http://127.0.0.1:8080/ws;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_read_timeout 3600s;
}
```

- SockJS 可能使用 `/ws/**` 的 HTTP 回退传输；反向代理需将该路径一并转发，不能只代理原生 WebSocket Upgrade。
- 生产应启用 HTTPS/WSS、关闭 Knife4j/OpenAPI、设置严格 CORS 白名单，并校验 MQTT、JWT、数据库及上传目录配置。

## 16. 已知限制与风险点

1. **WebSocket 使用内存 Simple Broker。**多实例之间不共享消息，扩容后可能丢失推送；需单实例运行或改造为共享消息代理。
2. **指令 `TIMEOUT(4)` 超时仅落库、不推送。**前端应设置超时后轮询 `GET /api/user/commands/{commandId}`。
3. **在线/离线状态没有 WebSocket 推送。**通过用户设备 `/online` 或管理端在线统计接口轮询刷新。
4. **审计日志不是全操作审计。**`/api/admin/audit-logs` 复用 `device_command` 指令流水，仅覆盖指令相关操作。
5. **前端权限 UI 不是安全边界。**后端 HTTP、设备归属与 STOMP 订阅均需要服务端校验。
6. **`X-Device-Id` 与 CORS 请求头清单不一致。**跨域浏览器联调可能因预检失败而无法使用设备维度风控。
7. **OTA 批量下发是同步请求。**设备数量增加时 HTTP 响应会变慢；任务列表计数可能滞后一轮刷新。
8. **业务异常多以 HTTP 200 返回。**客户端若只看 HTTP 状态码，会把失败误判为成功。
9. **传感器/设备 JSON 字段由设备能力决定。**前端需针对未知键与空值做兼容，不能将某一型号的数据结构当作全局 schema。
10. **数据库缺少迁移工具。**已有环境升级前需备份，并以当前 SQL/实际 Schema 制定增量迁移。
11. **测试密码未在仓库中以明文定义。**SQL 初始化数据只保存 `admin` 用户的 BCrypt 哈希；不能从哈希推出可用明文密码。

## 17. 开发规范与新增功能流程

### 17.1 新增 HTTP 接口

1. 在相应 Controller 添加路由、DTO 参数和 Jakarta Validation。
2. 将业务逻辑放入应用/领域 Service；数据访问经 Mapper/Service，不在 Controller 内拼接复杂数据库逻辑。
3. 需要认证、角色或权限码时更新 Security 规则及 `@PreAuthorize`，并验证失败响应状态码。
4. 用户侧设备数据需调用归属校验；不能只校验请求中的设备 ID 格式。
5. 新增/修改 VO、响应文档和 `docs/FRONTEND_API.md`，确保成功、业务异常和 401/403/429 等行为可对接。

### 17.2 新增权限码

1. 在 `PermissionConstants` 增加精确权限码，不随意改已有契约。
2. 更新 SQL 初始化权限与角色关联数据。
3. 为 Controller 方法添加 `@PreAuthorize`，确认 `ADMIN`/`OPS` 的角色范围与权限配置。
4. 更新登录权限返回、角色授权界面、字典/接口文档与测试数据。
5. 在旧数据库执行经过审核的增量迁移；初始化 SQL 的新增数据不会自动写入既有库。

### 17.3 新增 MQTT 消息或设备能力

1. 在 `DeviceMqttConstants` 定义稳定 topic/字段；与硬件团队先确认并冻结 topic、字段名、QoS、时间单位和错误处理。
2. 为新 topic 增加 `MqttMessageHandler`，实现 `supports`、字段/设备校验、幂等策略、落库和必要推送。
3. 更新 `application.yml` 对应订阅主题和 QoS；两份清单长度必须一致，否则应用拒绝启动。
4. 为预期异常验证死信内容、重放及不可重试语义；不要吞掉错误并返回成功状态。
5. 同步更新硬件报文示例、字典与前端 WS/HTTP 契约。

### 17.4 新增固件或设备产品

- 固件：管理端 `.bin` 上传、版本/产品唯一约束、哈希和大小、下载 URL、启停状态与设备兼容校验；生产固件需先验证完整性和下载链路。
- 设备：通过受信注册流程写设备身份与 MQTT 认证信息；绑定依赖设备 ID 和机身绑定码；检查 `capabilities`、产品型号、固件版本、LWT 和 MQTT ACL。
- 不要通过修改客户端 UI 绕过设备归属或后端支持的产品/固件校验。

### 17.5 Entity 与 VO

持久化 Entity 仅用于数据库映射；外部 API 使用 DTO/VO。除死信接口等当前实现直接返回 Entity 的既有契约外，禁止新增直接返回数据库实体的接口。若需变更既有返回结构，应同步评估兼容性并提供迁移方案。

## 18. 联调测试清单

### 后端与运维

- [ ] MySQL Schema 与 `smart_device.sql` 一致；数据库备份与升级方案已确认。
- [ ] Redis 可用；限流计数、令牌黑名单和刷新记录正常。
- [ ] runtime（8883）与 provision（8884）证书、账号、ACL、订阅 topic/QoS 配置匹配。
- [ ] `GET /actuator/health` 返回健康状态；Knife4j 开发环境可访问，生产已关闭。
- [ ] CORS 白名单包含前端域名，并允许 `X-Device-Id`。
- [ ] 上传目录可写；固件下载 BaseURL 可由设备访问。

### 前端

- [ ] 所有请求使用统一响应拦截，检查 `code === 200`。
- [ ] HTTP 401 刷新请求实现并发锁；刷新失败清空本地令牌。
- [ ] 登录验证码一次性使用；`4600/4601/4602` 和 `4013` 有不同提示与倒计时。
- [ ] 请求携带稳定 `X-Device-Id`；跨域预检允许该 Header。
- [ ] 用户设备接口、告警确认对 4209/4210 等归属错误给出提示。
- [ ] 控制操作先订阅 `/command` 再发 API；按 `commandId` 处理结果并轮询超时状态。
- [ ] WebSocket CONNECT 携带 Bearer Token；重连前刷新、连接后重新订阅。
- [ ] OTA 使用 WebSocket 实时进度和 `/progress` 轮询快照；页面重连恢复状态。
- [ ] CSV 导出按 Blob 处理；头像/固件 multipart 字段名与接口一致。
- [ ] 分页使用 `pageNum/pageSize`，消费 `records/total`。

### 硬件与 MQTT

- [ ] 设备 ID、Topic 中 MAC 与注册报文中的设备 ID 一致。
- [ ] 注册签名、公钥、nonce 与时间戳校验通过；注册响应 MQTT 配置可用。
- [ ] 设备按照响应中的 `will` 设置 presence topic、QoS、retain 和 payload；掉线可见 `mqtt_lwt` 离线状态。
- [ ] 心跳、presence、state、sensor、event、ack、ota_progress 报文时间戳单位与字段符合约定。
- [ ] 命令 ACK 原样回传 `commandId`；重复、错误或未知指令不会错误更新业务状态。
- [ ] 非法 JSON/字段缺失等消息进入 `sys_dead_letter`；可重放消息修复问题后处理，不可重试消息被拒绝重放。

## 19. 后续扩展方向

- 引入 Flyway/Liquibase 与自动化测试，覆盖鉴权、限流、MQTT Handler、设备指令和 OTA 状态机。
- 为多实例 WebSocket 引入共享 Broker 或 STOMP Broker Relay，并明确消息持久化、离线补偿与顺序策略。
- 以异步任务队列拆分批量 OTA，支持并发上限、分批灰度、暂停/恢复与任务幂等。
- 将 MQTT 报文解析、领域事件和持久化解耦，必要时引入消息流/事件总线。
- 设备规模增长后评估时序存储、分区归档、冷热数据策略及设备影子。
- 增加统一可观测性：traceId、设备维度日志、指标、告警、备份恢复演练与安全审计。
- 若面向多租户部署，需在用户、设备、绑定、权限、查询与缓存全链路设计租户隔离；当前数据模型未体现租户字段。

## 快速上手

### 启动步骤

1. 安装 JDK 17；准备 MySQL、Redis 和可用 MQTT TLS Broker。
2. 将 `web-module/src/main/resources/sql/smart_device.sql` 导入本地数据库，并按需修改 `application-dev.yml` 中数据库、Redis、MQTT、证书路径与 CORS。
3. 在仓库根目录执行：

   ```powershell
   .\mvnw.cmd clean package
   $env:SPRING_PROFILES_ACTIVE = "dev"
   java -jar .\web-module\target\<web-module-jar>.jar
   ```

4. 验证 `http://localhost:8080/actuator/health`，成功后使用 API 或前端联调。
5. 获取验证码：`POST http://localhost:8080/api/auth/captcha`；开发接口文档：`http://localhost:8080/doc.html`。

### 测试账号说明

初始化 SQL 中存在用户名 `admin`，并分配 `ADMIN` 角色；但脚本只包含 BCrypt 密码哈希，没有可确认的明文测试密码。**不要把猜测密码写入自动化配置或对外文档。**本地首次使用应通过受控的管理员密码初始化/重置流程，或注册一个普通 `USER` 账号进行用户侧接口联调；要测试管理接口，再由有权限的管理员分配角色。

### Knife4j

- 开发环境：`http://localhost:8080/doc.html`
- 生产环境：默认关闭；生产环境不要开放 Knife4j/OpenAPI 文档端点。
