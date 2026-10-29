# WM_LAOHUA 项目整体分析与不足点清单

> **性质**：只读分析文档。本次**未修改任何代码**。
> **范围**：common-module / business-module / web-module 全量源码、配置、SQL、MQTT 接入、认证授权、定时任务。
> **说明**：本文以**当前代码**为准，已逐条在源码中核实；与旧结论冲突处以本文为准。

---

## 一、项目现状概览

### 1.1 模块与依赖

| 模块 | 职责 | 依赖 |
|------|------|------|
| `common-module` | 常量、枚举、异常、响应、工具类、Properties | 无内部依赖 |
| `business-module` | 实体、Mapper、Service、VO/DTO | → common |
| `web-module` | Controller、MQTT 接入、Security、定时任务、WebSocket | → business → common |

依赖方向单一，分层清晰；`CommandSender` 用接口做依赖倒置（business 定义、web 实现），是项目里做得较好的设计。

### 1.2 已具备的核心能力

- 设备注册：白名单 + ECDSA 验签 + nonce 防重放 + 时间戳窗口
- 双 Broker：runtime（8883）/ provision（8884），mTLS
- MQTT 7 类主题：presence / heartbeat / state / ack / event / sensor / ota_progress，均有 Handler
- 指令状态机：PENDING / SENT / SUCCESS / FAILED / TIMEOUT / CANCELLED / ACCEPTED
- OTA：进度落库、成功双保险、上线回滚校验、过期清理
- 认证：JWT 双 Token + Refresh 旋转 + 黑名单 + 登录失败锁定
- 权限：`hasRole('ADMIN')` + `@PreAuthorize` 权限码
- 数据：MyBatis-Plus 分页、逻辑删除、JSON TypeHandler
- 实时推送：STOMP / SockJS

### 1.3 总体评价

架构骨架和功能覆盖面已经比较完整，属于“可运行、可持续演进”的中型物联网后端。**主要短板集中在四处**：

1. **授权粒度不完整**（认证做了，但“能不能操作这台设备”没做全）
2. **配置与部署边界不清**（dev/prod 差异、密钥、订阅主题继承）
3. **并发写入仍是 read-modify-write**（设备状态类字段）
4. **状态机/定时任务存在边界漏洞**（ACCEPTED、超时扫描竞争、事务内发消息）

---

## 二、不足点总览

| 级别 | 数量 | 主题 |
|------|------|------|
| **P0 严重** | 3 | 普通用户可越权控制任意设备；prod 未配置 MQTT 订阅主题；默认激活 dev |
| **P1 高** | 7 | WebSocket 匿名订阅、JWT 密钥硬编码、CORS 全开放、固件路径穿越、Refresh 并发双花、OTA/普通过期扫描竞争、事务内发 MQTT |
| **P2 中** | 12 | 并发覆盖、ACCEPTED 语义、统计漏算、N+1 查询、无分布式锁、事件时间错误、nonce 竞态等 |
| **P3 低** | 14 | 死代码/死 SQL、注释与实现不符、常量重复、日志噪音、无单测等 |

---

## 三、分维度详述

### 3.1 安全（最高优先级）

#### P0-1 普通登录用户可越权控制任意设备

- **位置**：`controller/device/DeviceCommandController.java:28`、`controller/device/DeviceOtaController.java:23`
- **现象**：两个 Controller 只有 `anyRequest().authenticated()` 保护，**没有 `@PreAuthorize`，也没有“当前用户是否绑定该设备”的校验**。而 `DeviceControlServiceImpl.checkDeviceOnline()` 仅校验设备存在与在线。
- **对比**：`DeviceUserServiceImpl.sendControlCommand()` 做了绑定校验，说明业务上是有归属概念的，但通用接口绕过了它。
- **影响**：任一注册用户（含普通 USER）可对**任意 MAC** 下发开关/舵机/OTA 指令，属于水平越权。
- **建议**：
  - 通用控制接口加设备归属校验（userId ↔ device_binding）；
  - 管理端与用户端接口分离，管理端用 `@PreAuthorize` 权限码；
  - 统一 `/api` 前缀（当前 `/device/command`、`/ota` 没有 `/api`，与 `/api/user/**`、`/api/admin/**` 不一致）。

#### P1-1 WebSocket 完全匿名

- **位置**：`config/SecurityConfig.java:69`（`/ws/**` permitAll）、`config/WebSocketConfig.java:24-26`（`setAllowedOriginPatterns("*")`）
- **影响**：任何人不登录即可连接 `/ws` 并订阅 `/topic/device/{deviceId}/state|sensor|alert`，实时数据全量泄露。
- **建议**：STOMP 握手阶段做 JWT 校验（`ChannelInterceptor`），订阅路径按用户绑定关系做鉴权，限制 Origin。

#### P1-2 JWT 密钥硬编码且生产未覆盖

- **位置**：`application.yml:72-76`（`my.jwt.secret` 为固定 Base64 字符串）
- **影响**：密钥进入代码库；任何人拿到仓库即可伪造任意用户 Token。`application-prod.yml` 未覆盖该配置。
- **建议**：改为 `${JWT_SECRET}` 环境变量/密钥管理，生产强制覆盖，并增加启动校验（长度/非默认值）。

#### P1-3 CORS 全开放 + 允许携带凭证

- **位置**：`config/CorsConfig.java:18-24`（`allowedOriginPattern("*")` + `allowCredentials(true)`）
- **影响**：任意站点可发起带凭证的跨域请求。
- **建议**：改为显式域名白名单（按环境区分），`allowedHeaders`/`methods` 收敛。

#### P1-4 固件上传存在路径穿越风险

- **位置**：`service/mqtt/impl/DeviceFirmwareUploadServiceImpl.java:72-77`
- **现象**：`fileName = String.format(fileNamePattern, version, timestamp)`，`version` 直接来自请求参数，未做字符白名单；随后 `dirPath.resolve(fileName)`。
- **影响**：构造含 `..` 或路径分隔符的 version，可写到上传目录之外。
- **建议**：version 只允许 `[0-9A-Za-z._-]`，落盘名由服务端生成（如 UUID），并校验最终 `targetPath.normalize().startsWith(dirPath)`。

#### P1-5 RefreshToken 并发双花

- **位置**：`service/auth/RefreshTokenService.java:48-70`、`controller/user/UserAuthController.java:83-89`
- **现象**：先 `verifyRefreshToken` 查询，再 `revokeToken` 更新，**非原子**。
- **影响**：同一 refreshToken 并发请求可两次刷新成功，违背“旋转即作废”。
- **建议**：改为条件更新 `UPDATE ... SET revoked=1 WHERE token_hash=? AND revoked=0`，以影响行数判定，行数为 0 即拒绝。

#### P1-6 nonce 校验与消费分离（重放窗口）

- **位置**：`service/mqtt/impl/DeviceRegisterServiceImpl.java:111-113、173-191`
- **现象**：`exists()` 检查通过后，真正的 `tryAcquire()` 放到 `afterCommit` 执行；并发注册时两个请求都可能通过 `exists`。
- **影响**：同一 nonce 在极小窗口内可被使用两次；且提交后 acquire 失败只记日志、不回滚。
- **建议**：在业务事务前用 `setIfAbsent` 原子占位（失败即拒绝），失败时释放；或接受“占位成功才继续”。

#### P1-7 登录锁定可被用于拒绝服务

- **位置**：`service/auth/LoginAttemptService.java:33-66`
- **现象**：按“用户名”计数并锁定，不区分 IP/设备。
- **影响**：攻击者故意输错可锁死任意已知账号 15 分钟。
- **建议**：改为“用户名 + IP”双维度，或引入验证码/延迟退避。

#### P2-1 方法级权限与角色约束双重绑定

- **位置**：`SecurityConfig.java:68` + `AdminOtaController.java:30/46/55/66`
- **现象**：`/api/admin/**` 要求 `ROLE_ADMIN`，方法上又要求 `firmware:upload` 等权限码。
- **影响**：若角色未同时授予权限码，管理员会被 403；若权限码配置错误，功能静默不可用。两套模型未在文档中约束。
- **建议**：明确“角色只做路由隔离、权限码做能力控制”，并提供初始化 SQL 校验。

---

### 3.2 配置与部署

#### P0-2 生产环境未配置 MQTT 订阅主题

- **位置**：`application-prod.yml:14-27` vs `application-dev.yml:24-39`
- **现象**：`application.yml` 中**没有** `mqtt` 节点；`mqtt.runtime.topics/qos` 只写在 `application-dev.yml`。切到 `prod` profile 后，`MqttProperties.Broker.topics` 为空列表。
- **影响**：生产启动后 `MqttPahoMessageDrivenChannelAdapter` 订阅 0 个主题，设备消息全部收不到（且不一定报错）。
- **建议**：把主题清单放到 `application.yml`（与 profile 无关），或 prod 显式配置并加启动自检（订阅数为 0 直接 fail-fast）。

#### P0-3 默认激活 dev profile

- **位置**：`application.yml:5-6`（`spring.profiles.active: dev`）
- **影响**：生产误启动时连接 `localhost`、根口令 `123456`、MQTT `127.0.0.1`。
- **建议**：基础配置不写 `active`，由启动参数/容器环境变量指定；dev 凭据移出仓库。

#### P1-8 生产占位符未替换

- **位置**：`application-prod.yml:3`（`生产数据库IP` 为中文占位）
- **影响**：prod 直接启动必然失败或连错库。
- **建议**：改为 `${DB_HOST}` 并纳入部署检查清单。

#### P2-2 明文凭据

- **位置**：`application-dev.yml:5`（DB 密码）、`:20/23`（MQTT 口令）、`client-cert-password: "123456"`
- **影响**：凭据入库、易泄漏。
- **建议**：全部环境变量化；开发环境用本地 `.env` 且加入 `.gitignore`。

#### P2-3 生产仍开放 Swagger

- **位置**：`application.yml:77-80`（`knife4j.enable: true`）、`SecurityConfig.java:71-77`（匿名放行 `/doc.html`、`/v3/api-docs/**`）
- **影响**：生产暴露完整接口清单，降低攻击成本。
- **建议**：prod 关闭 `knife4j.enable` 或加鉴权。

#### P2-4 日志级别与 SQL 日志

- **位置**：`application.yml:82-85`（`com.womi: debug`、mapper `debug`）
- **影响**：prod 若未覆盖（当前 prod 覆盖为 info，是对的），但仍建议明确 mapper 生产为 `warn`。

#### P3-1 firmware 路径硬编码

- **位置**：`application.yml:69-70`（`D:/data/firmware/`、`http://localhost:8000/firmware/`）
- **影响**：换环境需改配置；Windows 路径不可移植；`base-url` 与实际部署不一致时设备下载失败。

---

### 3.3 业务逻辑

#### P1-9 普通过期扫描会“抢走”OTA 指令且不清 OTA 状态

- **位置**：`DeviceCommandServiceImpl.markExpiredCommands()`（select + batch 更新）、`DeviceCommandMapper.xml:70-75`
- **现象**：`selectExpiredCommands` 条件为 `status IN (0,1,6) AND expire_time < now`，**没有排除 `target='ota'`**；而 XML 里另有 `markExpiredCommands` update 是排除 OTA 的，但 Service 没有调用它。
- **影响**：
  1. 普通扫描（30s）可能先把过期 OTA 指令置为 TIMEOUT；
  2. 之后 OTA 专用扫描（5s）的 `status IN (1,6)` 不再命中，`device_info.ota_state` 残留 running；
  3. 只能依赖下次发起 OTA 时的 `isStale` 兜底清理。
- **建议**：统一由 OTA 专用扫描处理 OTA；普通扫描的 select 增加 `target != 'ota'`。

#### P2-5 ACCEPTED 状态语义不完整

- **位置**：`enums/DeviceCommandStatus.java:59-61`、`DeviceCommandServiceImpl.cancelCommand()`、`statsByDevice()`
- **现象**：`isFinished()` 不含 ACCEPTED → 允许取消；取消后设备仍在升级，后续 ACK 因当前状态为 CANCELLED 被忽略。
- **影响**：`device_command.status` 与 `device_info.ota_state` 长期不一致。
- **建议**：明确“OTA 受理后是否可取消”；若不可取消，将 ACCEPTED 纳入终态/禁止取消；若可取消，需通知设备并允许结果覆盖。

#### P2-6 统计分项之和 ≠ total

- **位置**：`DeviceCommandServiceImpl.statsByDevice()` 第 386 行
- **现象**：`case ACCEPTED -> {}`，但 `total = commands.size()`。
- **影响**：前端各状态相加与总数对不上。
- **建议**：ACCEPTED 单列字段，或并入 sent，或 total 改为分项累加。

#### P2-7 事件上报时间被覆盖

- **位置**：`mqtt/handler/DeviceEventMessageHandler.java:81-82`
- **现象**：`record.setTimestamp(LocalDateTime.now())`，忽略 payload 顶层 `timestamp`。
- **影响**：设备离线缓存后补报的事件，入库时间全部变成“收到时间”，时序失真。
- **建议**：优先用 payload `timestamp`（毫秒 → LocalDateTime），缺失/异常才回退当前时间。

#### P2-8 批量 OTA 漏掉 firmware 为 NULL 的设备

- **位置**：`service/mqtt/impl/DeviceOtaServiceImpl.java:264-266`
- **现象**：`ne(DeviceInfo::getFirmware, version)` 在 MySQL 中对 NULL 不成立（三值逻辑）。
- **影响**：从未上报过版本的设备不会被批量升级。
- **建议**：改为 `(firmware IS NULL OR firmware <> #{version})` 的显式条件。

#### P2-9 用户控制接口状态判断可能 NPE

- **位置**：`service/device/impl/DeviceUserServiceImpl.java:154`
- **现象**：`device.getOnline() != 1` 对 `Integer` 自动拆箱。
- **影响**：`online` 为 NULL 时抛 NPE（500）。
- **建议**：`!Integer.valueOf(1).equals(device.getOnline())`。

#### P2-10 用户控制未做心跳兜底

- **位置**：`DeviceUserServiceImpl.sendControlCommand()` vs `DeviceControlServiceImpl.checkDeviceOnline()`
- **现象**：后者有“心跳超时视为离线”，前者只看 `online` 字段。
- **影响**：LWT 延迟时用户端会把指令发给已断设备。
- **建议**：抽出统一的在线判定方法供两处复用。

---

### 3.4 并发与数据一致性

#### P2-11 设备状态类写入仍是整行 read-modify-write

- **位置**：
  - `DeviceInfoServiceImpl.markOnline()` 第 56-74 行（`updateById(device)`）
  - `DeviceInfoServiceImpl.updateSpecificState()` 第 210-233 行（读 `current_state` → 改 Map → 整行写回）
  - `DeviceOtaServiceImpl.cleanStaleOtaState()` 第 141-147 行
- **影响**：同一设备的 state 上报、presence、心跳并发时，`current_state`/`capabilities`/`last_payload` 可能被旧快照覆盖。
- **建议**：OTA 已改成定向 UPDATE，其余三处按同样方式收敛（业务语义不变）。

#### P2-12 MQTT 发送发生在数据库事务内

- **位置**：`DeviceControlServiceImpl.sendCommand()`、`DeviceOtaServiceImpl.batchDispatchOta()`、`DeviceUserServiceImpl.sendControlCommand()`
- **现象**：`save()` 后立即 `commandSender.send()`，整体处于 `@Transactional` 中。
- **影响**：事务后续回滚时 MQTT 已发出，设备执行了但库里没记录；反之 DB 成功但发送失败时依赖定时器兜底（可接受）。
- **建议**：改用 `TransactionSynchronization.afterCommit` 或事务外发送。

#### P2-13 多实例定时任务无分布式锁

- **位置**：`schedule/DeviceCommandScheduler`、`DeviceOfflineScheduler`、`DeviceHistoryDataCleanScheduler`
- **影响**：多副本部署时同一批指令被重复下发、同一设备被重复置离线、清理任务重复执行。
- **建议**：ShedLock / Redis 锁；或明确声明单实例部署。

#### P2-14 应用启动会清空 Redis 绑定集合

- **位置**：`config/RedisCacheInitializer.java:30-44`
- **现象**：每次启动先 `delete(BOUND_DEVICES_KEY)` 再全量重建。
- **影响**：多实例滚动发布期间，其他实例的 `isMember` 判断短暂为空 → 心跳明细漏记。
- **建议**：改为差量同步或带版本号的双写切换，避免 delete-then-fill。

#### P2-15 终态定义有三套

- **位置**：`DeviceCommandStatus.isFinished()`、`DeviceCommandConstants.FINISHED_STATUSES`、`DeviceCommandServiceImpl.FINAL_STATUSES`
- **影响**：后续新增状态时极易漏改其中一处。
- **建议**：只保留枚举内的判定，常量集合引用枚举生成。

#### P2-16 重试参数两套

- **位置**：`ScheduleConstants.MAX_RETRY`（调度使用）与 `DeviceCommandConstants.DEFAULT_MAX_RETRY`（入库使用）
- **影响**：调整其一会导致“入库 3 次、调度按 5 次”这类不一致。
- **建议**：单一来源。

---

### 3.5 可靠性

#### P2-17 Handler 内部吞异常

- **位置**：所有 `mqtt/handler/*` 的 `handle()` 外层 `try/catch(Exception)` 仅记日志
- **影响**：消息处理失败后不会重投（QoS1 已 ACK 给 Broker），数据永久丢失。
- **建议**：区分“可重试/不可重试”；不可重试落死信表，可重试抛出让上层重投。

#### P2-18 传感器处理 N+1 查询且无告警去重

- **位置**：`service/device/impl/DeviceSensorDataServiceImpl.java:37-126`
- **现象**：每条传感器数据都单独查一次阈值、单独 insert 告警、逐条 `updateSlaveValue`。
- **影响**：批量上报时数据库压力大；持续超限会每帧生成一条告警，告警洪泛。
- **建议**：阈值批量查询 + 告警去重（同 sensorKey 在 N 分钟内只报一次）。

#### P3-2 MQTT 配置注释与实际端口不符

- **位置**：`mqtt/core/MqttConfig.java:20-22、77、130`（注释写 1883/1884，实际 8883/8884）
- **影响**：误导排查。

#### P3-3 类注释复制粘贴错误

- **位置**：
  - `DeviceStateMessageHandler.java:22-37`（类注释写“OTA 进度上报处理器”）
  - `DeviceSensorMessageHandler.java:15-30`（同上）
  - `DevicePresenceMessageHandler.java:18-31`（写 `online/offline/will`，实际是 `presence` 单主题）
- **影响**：阅读者无法快速判断职责。

#### P3-4 死字段/死依赖

- **位置**：`DeviceSensorMessageHandler.java:39-40`（`thresholdService`、`alertRecordService` 注入未使用）；`DeviceStateMessageHandler.java:3`（未使用的 `LambdaUpdateWrapper` import）
- **影响**：误导“阈值逻辑在此处”的判断。

---

### 3.6 性能

| 编号 | 问题 | 位置 | 影响 | 建议 |
|------|------|------|------|------|
| P2-19 | 每个请求都查 4 张表加载权限 | `JwtAuthenticationFilter` + `UserDetailsServiceImpl.loadUserByUsername` | 高频接口放大 DB 压力 | 用户权限缓存（Redis/Caffeine），Token 内携带权限快照 |
| P2-20 | Token 被重复解析 3 次 | `JwtAuthenticationFilter.java:45/52/55` | 每次请求多 2 次 HMAC 校验 | 一次 parse 取 Claims 复用 |
| P2-21 | 统计接口全量查回内存再计数 | `DeviceCommandServiceImpl.statsByDevice()` | 指令量大时内存/CPU 浪费 | 改为 `GROUP BY status` |
| P3-5 | RedisTemplate 裸类型 + 仅设 key 序列化 | `config/RedisConfiguration.java:14-21` | 默认 JDK 序列化，与 `StringRedisTemplate` 混用易乱码 | 明确 value/hash 序列化器并使用 `RedisTemplate<String,Object>` |

---

### 3.7 架构与可维护性

1. **Controller 路径风格不统一**：`/api/user/**`、`/api/admin/**`、`/api/auth/**` 与 `/device/command`、`/ota` 混用，且没有统一 `context-path`。
2. **DTO 归属混乱**：`business-module/dto` 中同时存在 `SendCommandRequest`、`DeviceOtaStartRequest`、`DeviceOtaParam`，而 `web-module` 又有自己的 `dto` 包（`SendCommandRequest` 等），存在同名/近义类型并存。
3. **AuthService 命名与分层不一致**：其余服务是 `XxxService` + `impl/XxxServiceImpl`，而 `AuthServiceImpl` 直接是 `@Service` 类。
4. **业务逻辑泄漏到 MQTT Handler**：`DeviceEventMessageHandler` 直接组装实体并 `save()`，未经过 Service，后续换存储或加校验要改多处。
5. **Mapper 存在死方法与死 SQL**：
   - `DeviceCommandMapper.markAsSent / markAsSuccess / markAsFailed / markAsTimeout / selectPendingCommands / markExpiredCommands(update)` 无调用方；
   - `DeviceInfoService.markHeartbeatTimeoutOffline()` 无调用方；
   - `DeviceCommandService.listPending()` 无调用方。
6. **XML 中重复语义的 SQL**：`selectStalePending` 与 `selectStalePendingCommands` 并存。
7. **魔法值与常量重复**：`batchDispatchOta` 中 `maxRetry=3`、`expire=30min`、`qos=1` 硬编码；`DeviceUserServiceImpl` 中同样（`30s`、`3`、`"APP"`）；`DeviceNonceServiceImpl` 中 `KEY_PREFIX`/`TTL` 硬编码。
8. **commandId 格式不统一**：`prepareCommand` 用带横线 UUID，`batchDispatchOta`/`DeviceUserServiceImpl` 用去横线 UUID。
9. **`BusinessException` 直接使用数字 code**：`DeviceUserServiceImpl` 里 `new BusinessException(400/403/500, ...)`，应使用 `ErrorCode`。
10. **`AuthService.recordLoginSuccess` 注释与实现不符**：注释说“显式设 update_time”，实际只 set 了 `lastLoginTime`。
11. **`RedisConstants` 非 final 且无私有构造**，与项目其它常量类风格不一致。

---

### 3.8 测试与文档

| 编号 | 问题 | 影响 |
|------|------|------|
| P2-22 | 仅 2 个 `contextLoads` 测试 | 验签、状态机、OTA 决策、nonce 全部零覆盖 |
| P2-23 | 无接口/协议契约测试 | 设备侧字段变更无法提前发现 |
| P3-6 | README 与代码存在少量漂移（路径、端口、handler 名称） | 新人上手成本高 |
| P3-7 | 缺少部署手册（EMQX 配置、证书、环境变量清单） | 生产部署依赖口头传递 |

---

### 3.9 代码可读性（可安全改动，不影响业务逻辑）

> 以下改动**不改变任何输入输出与状态迁移**，可单独提交、逐个验证。

1. 修正 `DeviceStateMessageHandler` / `DeviceSensorMessageHandler` 的类注释（复制自 OTA）。
2. 修正 `DevicePresenceMessageHandler` 注释（presence 单主题，不是 online/offline/will）。
3. 修正 `MqttConfig` 端口注释（8883/8884）。
4. 删除未使用的 import 与未使用的注入字段。
5. `GlobalExceptionHandler` 对 `AccessDeniedException` 的引用是 `java.nio.file` 包，应改为 Spring Security 的同类；当前 Security 的 AccessDeniedException 会落到兜底 500（**注意：这条同时是缺陷，修复需确认语义**）。
6. `GlobalExceptionHandler.java:153` 注释“请根据实际调整”属于未完成代码，应确定 code。
7. `UserAuthController.java:61` 硬编码 `4013` 应改用 `ErrorCode.ACCOUNT_LOCKED`。
8. `ScheduleConstants` 私有构造与注释错行（第 9-10 行）。
9. `RedisConstants` 改为 `final class` + 私有构造。
10. 统一日志格式为“业务描述 - key: {}, key: {}”。
11. 抽出重复的“在线判定”“终态判定”方法，减少三套定义。
12. 统一 commandId 生成方式（建议集中到一个 `CommandIdGenerator`）。

---

## 四、整改路线建议

### 阶段 1：安全与可用性（建议优先）
1. 修复 `/device/command`、`/ota` 的设备归属校验与权限码（P0-1）
2. prod 补齐 MQTT topics/qos + 取消默认 dev profile（P0-2、P0-3）
3. WebSocket 鉴权与 CORS 白名单（P1-1、P1-3）
4. JWT 密钥外置（P1-2）
5. 固件版本白名单 + 路径校验（P1-4）
6. RefreshToken 原子旋转 + nonce 原子占位（P1-5、P1-6）

### 阶段 2：一致性与状态机
1. 普通过期扫描排除 OTA（P1-9）
2. 明确 ACCEPTED 语义并修正取消/统计（P2-5、P2-6）
3. `markOnline` / `updateSpecificState` / `cleanStaleOtaState` 改定向更新（P2-11）
4. MQTT 发送移出事务（P2-12）
5. 定时任务加分布式锁（P2-13）

### 阶段 3：可靠性与性能
1. Handler 异常分级 + 死信（P2-17）
2. 传感器批量查询 + 告警去重（P2-18）
3. 权限缓存、Claims 单次解析、统计 SQL 化（P2-19~P2-21）
4. 事件时间改用 payload timestamp（P2-7）
5. 批量 OTA 的 NULL 版本处理（P2-8）

### 阶段 4：工程化
1. 死代码/死 SQL 清理（3.7-5、3.7-6）
2. 常量与日志统一（3.9）
3. 核心单测（验签、状态机、OTA、nonce）
4. 部署手册与环境变量清单

---

## 五、值得保留的优点

- 模块依赖方向单一，`CommandSender` 依赖倒置是加分项。
- OTA 的“firmware（实跑版本）/ ota_version（目标版本）”语义分离正确，双保险 + 上线回滚校验设计合理。
- 指令状态机显式建模（`DeviceCommandStatus`），ACK 决策抽成 `AckDecision`，可测试性好。
- 注册安全四件套（白名单、验签、nonce、时间戳）完整。
- `markOfflineIfTimeout` 用了乐观条件（心跳时间未变才置离线），避免与心跳并发竞争，这个思路可以推广到其它状态写入。
- 全局异常处理覆盖较全，响应结构统一。

---

## 附：本次核实中纠正的旧结论

| 旧结论 | 当前事实 |
|--------|----------|
| HTTP 接口无任何鉴权 | **已修复**：`SecurityConfig` + JWT + `@PreAuthorize` 已存在（但存在 P0-1 越权缺口） |
| state/event/sensor 无 Handler | **已修复**：3 个 Handler 均存在并落库 |
| 兜底扫描未排除 OTA | 部分修复：`selectStalePendingCommands`/`selectRetryableCommands` 已排除；但 `selectExpiredCommands` **仍未排除**（见 P1-9） |
| 端口 8765 / context-path `/api` | 实际 `server.port=8080`，**无 context-path**；路径前缀由 Controller 自行书写 |
| 两套 OTA 常量并存 | 已统一为 `DeviceOtaStateConstants` |
| `device_info` 缺索引 | 实际 `uk_device_id`、`idx_online`、`idx_last_heartbeat`、`idx_ota_state` 齐全 |

