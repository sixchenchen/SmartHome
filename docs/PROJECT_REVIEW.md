# WM_LAOHUA 项目全局评估与长期演进建议（v5）

> **性质**：架构与工程质量评估文档，**本次未修改任何代码**。
> **评估基准**：2026-11-04 当前代码树；已量化统计（221 个 Java 文件 / 10,276 行 / 3 模块 / 46 个 XML）。
> **与上一版差异**：v4 只列"未优化项"；本版从**可用性、维护成本、扩展性、结构合理性**四个大局维度重做评估，并把仍未修复项压缩为附录。

---

## 一、结论先行

### 1.1 能不能用？

**能用，但要看用在哪个场景。**

| 场景 | 结论 | 判断依据 |
|------|------|----------|
| 本地开发 / 联调演示 | ✅ **完全可用** | 设备注册、指令下发、OTA、实时推送、历史清理链路齐备；Knife4j 可查接口 |
| 小规模私有部署（几十~几百台设备、单实例） | ⚠️ **可用，但上线前需补 6 项**（见 1.2） | 安全与并发已收敛；缺备份/迁移/监控/健康检查 |
| 对外商用 / 多租户 SaaS | ❌ **暂不可用** | 无测试、无数据迁移、无租户隔离、无限流与审计、无灰度 |
| 大规模（万级设备 / 多 Broker / 多副本） | ❌ **需架构升级** | 单 Broker 双连接、单库、JSON 大字段状态、无设备影子 |

### 1.2 上线（小规模）前必须补的 6 项

1. **配置收敛**：`application.yml` 的明文 `123456`、`${JWT_SECRET:默认值}`、prod 的 `base-url # TODO` 与 `certs/cert.pem`。
2. **数据可恢复**：无迁移工具（无 Flyway/Liquibase），只有一份 `smart_device.sql`；上线后改表无版本、无回滚。
3. **健康检查与指标**：未引入 Actuator/Micrometer，容器无法探活，故障无指标可看。
4. **部署产物**：无 `Dockerfile` / `docker-compose` / CI，交付靠手工打 jar。
5. **死代码决策**：`DeviceOtaTask` 整条链路未被引用，上线前要么接入要么删除，避免"看起来有、实际没有"。
6. **日志可定位**：无 `traceId` / `deviceId` 的 MDC，跨设备问题排查成本高。

### 1.3 一句话评价

**这是一个"骨架正确、边界基本闭合、但缺少工程化护栏"的中小型 IoT 后端。** 代码量只有 1 万行却覆盖了注册、鉴权、指令状态机、OTA、MQTT 双 Broker、WebSocket、定时任务，说明抽象是有效的；短板不在业务实现，而在**测试、迁移、可观测性、模块边界**这四类"工程基建"。

---

## 二、维护难度评估

### 2.1 总体判断：中等偏低（但有 3 个"维护放大器"）

**有利因素**（决定了基线不会太差）：

- 依赖方向严格单向：`web → business → common`，没有循环依赖。
- 常量集中：`DeviceCommandConstants`、`DeviceMqttConstants`、`DeviceOtaStateConstants`、`ScheduleConstants`、`RedisConstants`。
- 异常与响应统一：`BusinessException` + `ErrorCode` + `ApiResponse`，Controller 无裸 `try/catch`。
- 关键写路径已改为**定向 UPDATE**（`updateOtaStateByDeviceId`、`updateFirmwareByDeviceId`、`markOfflineIfTimeout`），不会因并发整行覆盖。
- 1 万行 / 221 文件，平均 46 行/文件，没有明显的"上帝类"。

**维护放大器**（会让小改动变大成本）：

| 放大器 | 具体表现 | 维护代价 |
|--------|----------|----------|
| **零自动化测试** | 仅 2 个 `contextLoads` | 任何改动只能靠人工回归；状态机、OTA、验签三类逻辑一旦改错，线上才发现 |
| **同一领域服务分散在两个模块** | `DeviceInfoServiceImpl`、`DeviceCommandServiceImpl` 在 business；`DeviceUserServiceImpl`、`DeviceOtaServiceImpl`、`DeviceControlServiceImpl` 在 web | 改一个设备能力要跨模块找；新人难以判断"该写在哪" |
| **一处语义改动要同步 4~5 处** | 新增一个指令状态 → 枚举 + 常量（`FINISHED_STATUSES`/`PENDING_STATUSES`）+ Mapper XML 的 `status IN (...)` + 3 个调度器 + 前端 | 漏一处就产生状态不一致，且无测试兜底 |
| **XML 与 Wrapper 双份维护** | 部分查询在 `DeviceCommandMapper.xml`，部分在 `LambdaQueryWrapper` | 同一语义两处实现，改条件容易只改一边 |

### 2.2 新人上手成本

- **可上手**：3 个模块 + 一套统一响应，跑通 `application-dev.yml` 即可联调；README 有协议说明。
- **障碍**：README 的第 5 章接口清单**仍写已删除的 `DeviceCommandController` / `DeviceOtaController`**，且写"上下文路径 `/api`"（实际无 context-path），新人按文档找接口会扑空。
- **估计**：熟悉 Spring Boot + MyBatis-Plus 的工程师，约 2~3 天可独立改小需求；改 OTA/状态机类需求需要 1 周以上（因为要同时理解 4 个类和 3 个调度器）。

### 2.3 维护成本最高的三个位置（按"改一次要读多少文件"排序）

1. **OTA 全链路**：`DeviceOtaServiceImpl` + `DeviceControlServiceImpl` + `DeviceCommandServiceImpl.handleAck` + `DeviceOtaProgressMessageHandler` + `DevicePresenceMessageHandler.reconcileOtaOnOnline` + `DeviceCommandScheduler.markOtaExpired` + `DeviceInfoServiceImpl`（6~7 个类）。
2. **指令状态机**：`DeviceCommandStatus` + `DeviceCommandConstants` + `DeviceCommandMapper.xml` + `DeviceCommandServiceImpl` + 2 个调度器（5 个位置）。
3. **设备注册与凭证**：`DeviceRegisterServiceImpl` + `DeviceRegisterMessageHandler` + `NonceService` + `MqttCredentialGenerator` + `SignatureVerifierUtils` + `TimestampValidatorUtils`（安全关键，改错代价高）。

> **建议**：这三处优先补测试与文档（时序图），它们是"改动风险 × 业务重要性"最高的区域。

---

## 三、长期发展与扩展难度

### 3.1 当前架构的规模上限

| 维度 | 当前形态 | 现实上限 |
|------|----------|----------|
| MQTT | 单个 EMQX，runtime/provision 两条 mTLS 连接 | 单实例万级设备可撑；再往上需 Broker 集群 + 共享订阅 |
| 数据库 | 单 MySQL，设备状态存 `current_state` JSON 大字段 | 十万级设备时 JSON 更新与查询会成为瓶颈 |
| 应用 | 单实例可跑，多实例有 ShedLock | 可水平扩展，但 WebSocket 需粘性会话或 Redis 广播 |
| 时序数据 | 与业务库同库（`device_sensor_record` 等） | 数据量上 TB 后必须拆时序库 |
| 权限 | 单层 RBAC（角色 + 权限码） | 无租户维度，无法做 SaaS |

### 3.2 扩展点难度评级

| 未来需求 | 难度 | 现有基础 | 需要动的部分 |
|----------|------|----------|--------------|
| 新增一种设备/产品 | **低** | `product` 字段、白名单、按 product 批量 OTA | 加固件 + 加前端展示 |
| 新增一个 MQTT 主题或指令 | **低** | `MqttMessageHandler.supports(topic)` + 常量集中 | 加 Handler + 常量 + 前端 |
| 新增用户端接口 | **低** | `/api/user/**` 已隔离，绑定校验已抽 | 加 Controller + Service 方法 |
| 接入第二种协议（HTTP 直连设备 / CoAP） | **中高** | 业务逻辑部分下沉，但 Handler 仍绑 MQTT 报文格式 | 需要把"报文解析"与"业务处理"彻底分离（见 4.1） |
| 加规则引擎 / 告警升级 / 通知 | **中** | 已有 `device_alert_record`、事件记录 | 新增规则模型与执行器；`DeviceSensorDataServiceImpl` 里硬编码的阈值判断要抽出来 |
| 换时序库（TDengine / InfluxDB） | **中高** | 传感器写入集中在 `DeviceSensorRecordServiceImpl` | 需抽象 Repository 接口，避免业务直接依赖 MyBatis Mapper |
| 引入 Kafka 解耦 MQTT 与业务 | **中** | `MqttMessageRouter` 是单点分发 | Router 改为投递到 stream，Handler 改为消费者；需处理顺序与幂等 |
| 设备影子 / 物模型（Thing Model） | **中高** | 只有 `current_state` 自由 JSON + 约定 `target` | 需定义属性 schema、期望值/上报值双份、版本号 |
| 多租户 SaaS | **高** | 所有表无 `tenant_id`，`device_id` 全局唯一 | 全表加租户列 + 唯一索引改造 + 全链路过滤 + 数据迁移 |
| 水平扩展 WebSocket | **中** | STOMP + 简单 Broker，订阅鉴权已做 | 需 Redis 广播或外部 Broker Relay |
| 灰度发布 / 固件分批灰度 | **中** | 已有按 product 批量下发 | 需任务分组、比例控制、失败率熔断 |

### 3.3 现在**不建议**做的（避免过度设计）

- 拆微服务：1 万行代码拆开只会增加部署与联调成本。
- 引入 CQRS / 事件溯源：当前设备状态是"最终一致即可"，没有审计追溯的强需求。
- 自研 MQTT Broker / 接入层：EMQX 已足够，自研是负收益。
- 过早引入 DDD 分层（domain/application/infrastructure 四层）：对这个体量属于过度设计。

---

## 四、架构与目录结构问题

### 4.1 核心问题：web-module 在做三层的事

当前 `web-module` 同时承担：**HTTP 适配**（controller）、**安全**（filter/config）、**MQTT 适配**（mqtt/core、handler）、**领域服务**（service/auth、service/device、service/mqtt）、**定时任务**（schedule）。而 `business-module` 只放了实体、Mapper 和一部分领域服务。

**结果**：同一个"设备"领域，服务被劈成两半——`DeviceInfoServiceImpl` / `DeviceCommandServiceImpl` 在 business，`DeviceUserServiceImpl` / `DeviceOtaServiceImpl` / `DeviceControlServiceImpl` 在 web。这是维护成本的第一来源。

**建议的目录结构（不要求现在改，但应作为方向）**：

```
com.womi
├── common-module
│   ├── constants / enums / exception / response / utils / properties
│   └── （只放"任何模块都能用"的东西，不放业务语义）
├── business-module          # 领域层：纯业务，不依赖 HTTP / MQTT
│   ├── device  (model / mapper / service / dto)
│   ├── ota     (model / mapper / service / dto)
│   ├── auth    (model / mapper / service)
│   └── common  (CommandSender 等跨领域抽象)
└── web-module               # 适配层：只做协议与编排
    ├── controller/{user,admin}
    ├── mqtt/{core,handler}   # 报文解析 → 调领域服务
    ├── security / config / schedule
    └── （service 包应逐步清空，方法下沉到 business）
```

**先做成本最低的一步**：把 `web-module/service/{device,ota}` 的**领域逻辑**（不含 Controller 依赖）下沉到 `business-module` 的 `device/ota` 包，web 只保留"组装请求/响应 + 事务边界"。

### 4.2 包结构是"按层分"而不是"按域分"

现状：`model/device`、`mapper/device`、`service/device`、`controller/user`、`mqtt/handler` —— 同一领域横跨 5 个包、3 个模块。需求一多，"改一个功能要开 6 个目录"。

**建议**：至少在同一模块内保持 `device` 域自洽；跨模块下沉后，`controller` 仍可按端（user/admin）分，但领域代码按 feature 聚合。

### 4.3 数据层问题：只有一份初始化 SQL，没有迁移

- 现状：`web-module/src/main/resources/sql/smart_device.sql` 一份建表脚本。
- 风险：上线后任何加字段/加索引都没有版本记录，回滚只能靠 DBA 手工。
- **建议**：引入 Flyway（Spring Boot 原生支持，零额外运维），把现有 SQL 归档为 `V1__init.sql`，后续变更按 `V2__add_xxx.sql` 递增；生产环境配置 `baseline-on-migrate` 保护存量库。

### 4.4 接口与契约

- 无 API 版本化（`/api/user/...` 一旦改字段，前端无法平滑升级）。
- 无统一错误码文档（`ErrorCode` 有定义，但没有对外清单）。
- **建议**：非破坏性阶段可不做；一旦有外部客户端接入，至少加 `/api/v1` 前缀预留。

---

## 五、代码质量评估

### 5.1 做得好的地方（应保持）

1. `CommandSender` 依赖倒置：business 定义、web 实现，MQTT 细节不外泄。
2. `MqttMessageHandler` 接口 + `supports(topic)`：新增主题是"加一个类"。
3. `MqttConfig` 启动即校验主题清单（空清单/数量不一致直接失败），配置错误不静默。
4. 设备注册链路完整：白名单 → 验签 → nonce → 时间窗 → 凭证下发，且工具类已抽到 common。
5. 定向 UPDATE 的并发范式已在 OTA/离线场景落地。
6. 常量类按设备域拆分，`ScheduleConstants`/`RedisConstants` 已收敛为不可实例化工具类。

### 5.2 仍然存在的质量问题

| 类别 | 问题 | 影响 | 建议 |
|------|------|------|------|
| **测试** | 仅 2 个 `contextLoads` | 无回归能力，改动靠人工 | 先补状态机、验签、nonce、OTA 判定 4 组；再做报文 fixture 契约测试 |
| **可观测性** | 无 `traceId`/`deviceId` MDC、无指标、无健康检查 | 线上排障靠 `grep` 日志；容器无法探活 | 加 MDC 过滤器 + Actuator + Micrometer（HTTP 延迟、MQTT 消息量、指令成功率） |
| **重复代码** | `DeviceOtaServiceImpl.batchDispatchOta` 内已有 `runningDeviceIds` 批量判定，循环里又逐台 `exists` | 每轮多 N 次 SQL，日志重复 | 删除循环内冗余查询（**N-8**） |
| **死代码** | `DeviceOtaTask` 实体/Mapper/Service/Impl 全链路无引用 | 误以为有"任务维度"，实际空表 | 接入或删除（**N-16**） |
| **配置安全** | 基础 `application.yml` 仍有明文 `123456`、`${JWT_SECRET:默认值}` | 仓库泄露即密钥泄露 | 全部改环境变量且不带默认值 |
| **文档一致性** | README 仍描述已删除的控制器与 context-path | 新人按文档找不到接口 | 重写第 1、5 章（**P3-6**） |
| **语义一致性** | `PENDING_STATUSES` 含 ACCEPTED，`isPending()` 不含 | 新增校验时容易漏判 | 统一由 `isActive()` 派生（**P2-15**） |
| **异常可观测** | Handler 已接死信表，但无"死信数量"指标与告警 | 消息丢失需人工查表 | 暴露死信计数指标 + 阈值告警 |
| **时间处理** | 设备毫秒时间与 `LocalDateTime` 混用，时区硬编码 Asia/Shanghai | 跨时区/夏令时隐患 | 统一 `DateTimeUtils`，设备时间用 `Instant` 存储 |
| **静态检查** | 无 Checkstyle / SpotBugs / ArchUnit | 分层约束靠人自觉 | 引入 ArchUnit 断言"web 不得被 business 依赖""controller 不得依赖 mapper" |

### 5.3 框架选型评估

| 选型 | 评价 | 建议 |
|------|------|------|
| Spring Boot 3.4.4 / Java 17 | ✅ 主流，生态完整；3.4 的 OSS 支持窗口有限 | 规划升级到 3.5/4.x；Java 21 的虚拟线程对 MQTT 回调与 DB IO 有收益 |
| MyBatis-Plus 3.5.7 | ✅ 够用；但 XML + Wrapper 双份维护 | 复杂查询固定放 XML，简单查询固定用 Wrapper，写进规范 |
| Paho 1.2.5 + Spring Integration | ✅ 单机足够；客户端较老 | 大规模换 EMQX 共享订阅；或评估 HiveMQ client |
| Spring Security + 自写 JWT Filter | ⚠️ 可控但重复造轮子 | 可选 `spring-security-oauth2-resource-server`（JWT 解码与校验标准化，减少安全缺陷面） |
| Druid 1.2.23 | ⚠️ 监控未配置时收益低 | 要么配置 StatViewServlet 监控，要么退回 HikariCP（少一个依赖） |
| Knife4j 4.4 | ✅ 开发体验好；prod 已关闭 | 保持 |
| ShedLock 5.10 | ✅ 多实例定时任务已解决 | 保持 |
| 无 Flyway / 无 Testcontainers / 无 Testcontainers | ❌ 基建缺失 | 优先补迁移；测试可用 Testcontainers 起 MySQL/Redis |
| 无 MapStruct | ⚠️ 手写 Entity↔VO 转换 | 字段增多后引入，减少样板代码 |

---

## 六、演进路线（按时间维度）

### 阶段 0：上线前（1~2 周，做完即可私有部署）
1. 配置收敛：明文口令、JWT 默认值、prod 占位符（`base-url`、`ca-cert`）。
2. 删除 `batchDispatchOta` 循环内冗余 `exists`（N-8）。
3. 决策 `DeviceOtaTask`：接入或删除（N-16）。
4. 引入 Actuator 健康检查 + 基础指标（HTTP 5xx、MQTT 连接状态、指令成功率）。
5. 补 `Dockerfile` + `docker-compose`（app + mysql + redis + emqx）。
6. 重写 README 第 1/5 章 + 新增 `docs/DEPLOYMENT.md`（环境变量、证书、EMQX ACL、`shedlock` DDL）。
7. 数据库备份策略与回滚脚本（至少每日全备 + binlog）。

### 阶段 1：稳定性护栏（1~2 个月）
1. 测试金字塔：状态机矩阵、验签、nonce、OTA 判定 → 报文契约测试 → 关键 Service 集成测试。
2. 引入 Flyway，把现有 SQL 纳入版本管理。
3. 日志加 MDC（traceId + deviceId），死信数量指标 + 告警。
4. 引入 ArchUnit 固化分层约束；Checkstyle/SpotBugs 接入构建。
5. 限流（登录、注册、控制指令）与操作审计表。

### 阶段 2：结构治理（3~6 个月）
1. `web-module/service/{device,ota}` 领域逻辑下沉到 `business-module`，web 只留适配层。
2. 把 `DeviceSensorRecordService` 的写入抽象为 Repository 接口，为时序库留出替换点。
3. `current_state` 引入物模型（属性 schema + 期望值/上报值），为设备影子做准备。
4. 规则/告警从 `DeviceSensorDataServiceImpl` 抽出独立模块（规则模型 + 执行器 + 通知渠道）。

### 阶段 3：规模化（6~12 个月，视业务量）
1. EMQX 集群 + 共享订阅；MQTT 接入层可独立部署。
2. 读写分离；传感器/心跳历史迁移时序库。
3. 若做 SaaS：全表加 `tenant_id`（这一步越晚成本越高，需提前确认产品方向）。
4. WebSocket 用 Redis 广播或 Broker Relay 支持多实例。

---

## 七、附：仍未修复的具体项（承接 v4）

| 编号 | 状态 | 位置 | 说明 |
|------|------|------|------|
| N-8 | ❌ | `DeviceOtaServiceImpl.batchDispatchOta` | 已有 `runningDeviceIds` 批量判定，循环内仍逐台 `exists`（重复查询，N+1） |
| N-16 | ❌ | `DeviceOtaTask` 全链路 | 实体/Mapper/Service/Impl 无任何引用 |
| P2-22 | ❌ | `**/src/test/**` | 仅 2 个 `contextLoads` |
| P2-23 | ❌ | 同上 | 无 MQTT 报文契约测试 |
| P3-6 | ❌ | `README.md` | 仍写 `DeviceCommandController`/`DeviceOtaController` 与"上下文路径 /api" |
| P3-7 | ❌ | `docs/` | 无 `DEPLOYMENT.md` |
| P0-3 | ⚠️ | `application.yml:6` | `spring.profiles.default: dev` |
| P1-2 | ⚠️ | `application.yml:121` | `${JWT_SECRET:默认值}` 仍带默认值 |
| P1-8 | ⚠️ | `application-prod.yml` | `base-url # TODO`、`ca-cert: certs/cert.pem` |
| P2-2 | ⚠️ | `application.yml`、`application-dev.yml` | 仍有多处明文 `123456` |
| P2-15 | ⚠️ | `DeviceCommandStatus` / `DeviceCommandConstants` | `PENDING_STATUSES` 含 ACCEPTED，`isPending()` 不含 |
| 3.9-d | ⚠️ | `RedisConstants` | 已 `final`，缺私有构造 |

---

## 八、最终判断

| 维度 | 评分 | 说明 |
|------|------|------|
| 功能完整度 | ★★★★☆ | 设备全生命周期闭环，缺规则引擎与设备影子 |
| 安全性 | ★★★★☆ | 认证/授权/绑定/WebSocket 均已闭环，差配置项与限流 |
| 可维护性 | ★★★☆☆ | 分层方向正确，但领域服务跨模块、无测试拉低分数 |
| 可扩展性 | ★★★★☆ | 新增设备/主题/指令成本低；多租户与物模型成本高 |
| 工程质量 | ★★☆☆☆ | 无测试、无迁移、无监控、无 CI —— 最大短板 |
| **综合** | **★★★☆☆** | **可私有部署，不宜直接商用；补完阶段 0 即可稳定运行** |

**如果只做三件事**：① 配置收敛 + 健康检查；② 状态机与验签的测试；③ 把 `web-module/service/device|ota` 下沉到 business。这三件做完，项目的维护成本和扩展成本会下降一个台阶。
