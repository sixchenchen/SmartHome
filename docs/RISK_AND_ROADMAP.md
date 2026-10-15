# WM_LAOHUA 风险 · 计划 · 改造清单

> 说明
> - 本文档只用于**记录问题与规划**，编写过程中**未修改任何业务代码**。
> - 后续如需改代码，**仅限可读性与代码优雅性**（见第三章，均为不改动业务语义的安全改动）；**业务逻辑一律不动**，业务逻辑层面的问题统一记录在**第二章**。
> - 事实基线：以当前代码为准（`README.md` 为功能基线）。所有条目均已逐一在源码中核实。

---

## 一、风险清单（按优先级排序）

### P0 · 阻塞级（上线前必须处理）

| # | 风险 | 位置 | 影响 | 建议处置 |
|---|------|------|------|----------|
| P0-1 | **HTTP 接口完全无鉴权** | 全部 `web-module/**/controller`；全项目无 `spring-boot-starter-security` 依赖、无 `SecurityFilterChain`/`@EnableWebSecurity` | 任何人可直接调用 `/api/device/command/send`、`/api/ota/start`、`/api/firmware/upload`、`DELETE /api/firmware/{id}`，可远程下发指令、触发升级、上传/删除固件 | 引入 Spring Security 或前置网关鉴权（API Key / JWT / mTLS）；对写操作收敛暴露面 |

### P1 · 高危

| # | 风险 | 位置 | 影响 | 建议处置 |
|---|------|------|------|----------|
| P1-1 | **ACK 未校验 commandId 归属** | `AckMessageHandler.handle()` 第 88 行直接 `deviceCommandService.handleAck(commandId, success, data, msg)`；仅在第 83 行校验 `payload.device` 与 topic 一致，且**只告警不拦截** | 设备 A 可伪造/复用设备 B 的 `commandId`，篡改 B 的指令状态（横向越权） | 在 `handleAck` 前增加归属校验：`command.deviceId == topicDeviceId`，不匹配则丢弃并告警 |
| P1-2 | **state / event / sensor 三类主题订阅了但无处理器** | `application-dev.yml` 订阅 `device/+/state`、`device/+/event`、`device/+/sensor`；`mqtt/handler` 下仅 5 个 Handler（presence / heartbeat / ack / ota_progress / register）；`MqttMessageRouter.route()` 未匹配时仅 `log.warn("未找到匹配的处理器")` 后丢弃 | 设备状态、事件、传感器上报数据全部被静默丢弃；`device_state_record`、`device_event_record`、`sensor_record` 三张表长期无数据写入 | 新增 `StateMessageHandler` / `EventMessageHandler` / `SensorMessageHandler` 并落库；或先取消对应主题订阅避免误报 |
| P1-3 | **明文口令 + 默认激活 dev profile** | `application-dev.yml`：DB `password: 123456`、MQTT `RUNTIME_USER/PROVISION_USER` 密码 `123456`；`application.yml`：`spring.profiles.active: dev` | 凭据落在代码库中（易泄漏/进日志）；生产环境若未覆盖 profile 会误用 dev 配置 | 凭据改环境变量 / 配置中心 / 密钥管理；生产 profile 与之隔离；`spring.profiles.active` 不在基础配置写死 |
| P1-4 | **多实例定时任务无分布式锁** | `web-module/.../schedule`（心跳扫描、指令派发、重试、过期标记、OTA 过期、历史清理） | 多实例部署时同一任务被多实例重复执行（重复派发指令、重复置超时/过期） | 引入分布式锁（Redis 锁或 ShedLock），或明确约束单实例部署 |

### P2 · 中危

| # | 风险 | 位置 | 影响 | 建议处置 |
|---|------|------|------|----------|
| P2-1 | **统计分项之和 ≠ total** | `DeviceCommandServiceImpl.statsByDevice()` 第 386 行 `case ACCEPTED -> { /* ACCEPTED 暂不计入统计 */ }`，而第 390 行 `vo.setTotal((long) commands.size())` | `ACCEPTED(6)` 指令既不计入任何分项、又被算进 total → 前端分项相加对不上总数 | ACCEPTED 归入某分项（如 sent），或为统计对象单列一列；或 total 改为分项累加 |
| P2-2 | **取消 OTA（ACCEPTED）后设备仍可能继续升级** | `cancelCommand()` 用 `status.isFinished()` 判定，而 `CommandStatus.isFinished()` 只含 SUCCESS/FAILED/TIMEOUT/CANCELLED，**ACCEPTED 非终态 → 可被取消**；但 `handleAck` 遇到 `CANCELLED` 终态会忽略（第 183 行） | 服务端把指令标记为"已取消"，设备端实际仍在下载/升级并可能成功 → `device_command.status` 与 `device_info.ota_state` 不一致 | 明确 ACCEPTED 语义：若不允许取消，则把它纳入 `isFinished()`；若允许，则取消时需同步通知设备或让后续 ACK/进度可覆盖 |
| P2-3 | **markOnline 整行 updateById（read-modify-write 并发覆盖）** | `DeviceInfoServiceImpl.markOnline()` 第 61 行 `updateById(info)`（先 `getOrCreateDevice` 读整行，改字段后整行回写） | 心跳/上线高频并发时，`capabilities`、`config_version`、`last_payload` 等字段可能被旧快照覆盖，丢失其它写入 | 参照已改造的 OTA 写法，改为**带前置条件的定向 UPDATE**（只更新本次变更字段） |
| P2-4 | **死常量** | `DeviceMqttConstants` 第 73/77/81 行 `ONLINE_TOPIC_FORMAT`、`OFFLINE_TOPIC_FORMAT`、`WILL_TOPIC_FORMAT`；全项目仅此定义处出现，无其它引用 | 已被 `device/+/presence`（含 `type=online/offline`）取代，残留常量易误导后续开发误用 | 确认无引用后删除 |
| P2-5 | **核心逻辑零单元测试** | 全项目仅 2 个 `*ApplicationTests`（contextLoads）；`src/main` 下验签、ACK 状态机、OTA 决策、非重放（nonce）等无测试 | 后续改动无回归保障，安全相关逻辑无法验证 | 补关键路径单测：`SignatureVerifierUtils`、`handleAck` 状态迁移、`syncFirmwareIfTarget`、`reconcileOtaOnOnline` |

### P3 · 低危 / 工程化

| # | 风险 | 位置 | 影响 | 建议处置 |
|---|------|------|------|----------|
| P3-1 | 固件路径/地址硬编码 | `application-dev.yml`：`firmware.upload-dir: D:/data/firmware/`、`firmware.base-url: http://192.168.1.15:8000/firmware/` | 换环境需改代码/配置、Windows 路径不通用 | 环境变量化；`base-url` 与部署域名对齐 |
| P3-2 | SQL 注释未同步新状态 | `sql/smart_device.sql` 第 34 行 `status` 注释为 `0-PENDING 1-SENT 2-SUCCESS 3-FAILED 4-TIMEOUT 5-CANCELLED`，遗漏 `6-ACCEPTED` | 文档与代码枚举不一致，易误读 | 注释补 `6-ACCEPTED`（仅注释，不动表结构） |
| P3-3 | 日志级别过宽 | `application-dev.yml`：`com.womi: debug`、`com.womi.business.mapper: debug` | 生产若沿用会产生大量 SQL/调试日志，影响性能与排查 | 生产用 `info`，mapper 用 `warn` 或按需开启 |
| P3-4 | `DeviceOtaController.start` 入参名不直观 | `DeviceOtaController.start(@RequestBody SendCommandRequest req)`，而 DTO 目录另有 `dto/ota/request/OtaStartRequest` | OTA 启动复用了通用指令请求体，另有专用 DTO 未使用，易混淆 | 统一为专用 `DeviceOtaStartRequest`（属可读性改动，见第三章） |

---

## 二、业务逻辑问题记录（仅记录，禁止直接改动）

> 以下为**业务语义层面**的疑点/缺陷，需产品/架构确认后再决定如何改；本阶段只登记，不修改。

1. **ACK 归属校验缺失导致的越权**（同 P1-1）
   - 现状：ACK 处理只信任 topic 中的 deviceId 作为日志，未与 `commandId` 所属设备做严格绑定。
   - 待确认：是否要求 ACK 必须"topic 设备 == 指令归属设备"，以及重复/过期 ACK 的处理策略。

2. **ACCEPTED 状态语义不完整**
   - 现状：`ACCEPTED(6)` 既非终态（可取消、可被 ACK 覆盖），又不进入统计（P2-1），且取消后无法再被设备结果覆盖（P2-2）。
   - 待确认：ACCEPTED 是否应作为终态？OTA 一旦受理是否允许取消？取消后设备继续升级如何对齐？

3. **`firmware` 与 `ota_version` 的语义边界**
   - 现状（已按"双保险"方案落地）：`firmware`=设备**实跑**版本（权威来源=设备上报 presence/ACK/进度），`ota_version`=**目标**版本。
   - 待确认：设备端上报的 `version` 是否始终可信？若设备上报错误版本，`syncFirmwareIfTarget` 会把目标版本写成实跑版本。
   - 回滚兜底：`reconcileOtaOnOnline` 在"声明 success 但实跑 ≠ 目标"时置 failed —— 需确认设备重启上报的 firmware 字段是否包含"刷写后"的真实版本。

4. **state / event / sensor 数据链路缺失**（同 P1-2）
   - 现状：主题已订阅但无 Handler，数据落不了库。
   - 待确认：这三类数据是"当前未实现"还是"已迁走"；若需保留应补 Handler。

5. **离线判定阈值与心跳周期匹配**
   - 现状：`ScheduleConstants.HEARTBEAT_TIMEOUT_SECONDS=60`、扫描间隔 30s；设备心跳周期需 ≤ 阈值的一半以下才稳妥。
   - 待确认：设备端心跳周期是否已知/固定，避免误判离线。

6. **取消/重试/超时三者的优先级**
   - 现状：重试（`MAX_RETRY=3`）与超时标记、手动取消并发时，最终状态取决于执行顺序。
   - 待确认：是否需要一个统一的状态迁移矩阵。

7. **OTA 过期清理与"仍在升级"的竞态**
   - 现状：`OTA_EXPIRED_FIXED_DELAY=5000`、`STALE_OTA_MINUTES=5`；若设备升级耗时超阈值但仍在推进，可能被误判过期。
   - 待确认：过期判定是否应参考最近一次 `ota_progress` 上报时间（心跳式续期）。

8. **`cleanHistory` 硬删除不可逆**
   - 现状：`cleanHistory` 对终态指令做物理删除（保留 30 天），而 `device_command` 有外键被引用语义。
   - 待确认：是否需要改为软删除/归档，保留审计。

---

## 三、可读性 / 代码优雅性改进项（不改业务逻辑，可安全改动）

> 原则：**只动"怎么写得更好看/更好维护"，不动"做什么"**。以下均不改变输入输出与业务语义。

1. **统一常量注解风格**
   - `DeviceMqttConstants` 等常量类注释存在中英混排与空行不齐（如 `ScheduleConstants` 第 9-10 行 `private ScheduleConstants() {}` 与 `// 防止实例化` 换行错位）。
   - 建议：统一为"字段上方单行中文注释 + 私有构造私有化"，参照 `ResponseConstants` 风格。

2. **消除魔法值与裸数字**
   - `DeviceInfoServiceImpl` 中 `log.warn("...")` 等日志文案可抽为 `ErrorInfoConstants`/消息常量；`schedule` 中的延迟值已收敛到 `ScheduleConstants`，保持一致。
   - 注意：仅抽**文案与展示**，不改判断条件。

3. **DTO 命名与用途对齐**
   - `DeviceOtaController` 用 `SendCommandRequest` 承接 OTA 请求，而同目录已有 `DeviceOtaStartRequest`（见 P3-4）。
   - 建议：统一到一个专用 DTO，命名自解释；不改字段含义与校验规则。

4. **方法抽取与职责单一**
   - `DeviceCommandServiceImpl.handleAck` 内状态决策分支较长（第 133-183 行），可把"计算目标状态"抽成一个私有方法 `decideNextStatus(...)`，返回决策对象（已存在 `AckDecision` 可复用），提升可读性。
   - 不改状态迁移结果。

5. **日志规范**
   - 统一日志前缀/占位符风格（当前混用 `-` 与 `,`，如 `"设备上线 - deviceId: {}"` vs `"OTA 进度上报 - deviceId: {}, state: {}"`）。
   - 建议：统一为 `业务描述 - key: {}, key: {}`。

6. **注释与 Javadoc 补齐**
   - 新增的定向更新 Mapper 方法（`updateOtaStateByDeviceId` / `updateFirmwareByDeviceId` / `clearOtaStateByDeviceId`）建议补一行中文说明其前置条件（尤其 `updateFirmwareByDeviceId` 的"仅当版本不同才更新"）。

7. **消灭死常量与死代码**
   - 删除 P2-4 的死常量；顺带核对未使用的 import / 私有方法。

8. **`ApiResponse` 使用一致性**
   - 统一"成功返回"写法（有的 `ApiResponse.success(null)`，有的 `ApiResponse.success(x)`），可读性统一即可。

> 以上改动均可在"不改业务逻辑"的前提下独立进行，建议**单独提交、逐个验证**。

---

## 四、后续计划（分阶段）

### 阶段 0 · 基线巩固（与本章三同步）
- [ ] 删除死常量 / 死代码（P2-4）
- [ ] 统一常量与日志风格（第三章 1、5）
- [ ] SQL 状态注释补全（P3-2）
- [ ] 输出"当前事实"文档并冻结（本文档 + README）

### 阶段 1 · 安全加固（对应 P0 / P1）
- [ ] 引入 HTTP 鉴权（P0-1）
- [ ] ACK 归属校验（P1-1）
- [ ] 凭据外置 + profile 分离（P1-3）
- [ ] 分布式锁或单实例约束（P1-4）
- [ ] 复核 MQTT 端口级认证隔离与 ACL 最小化

### 阶段 2 · 功能补全（对应 P1-2 / P2）
- [ ] 补 State / Event / Sensor Handler 落库（P1-2）
- [ ] 明确并修正 ACCEPTED 语义（P2-1、P2-2）
- [ ] markOnline 改定向更新（P2-3）
- [ ] OTA 过期/取消/重试状态矩阵梳理（第二章 2、6、7）

### 阶段 3 · 工程化与质量
- [ ] 补核心单测（P2-5）：验签、状态机、OTA 决策
- [ ] 固件路径/地址环境变量化（P3-1）
- [ ] 生产日志级别收敛（P3-3）
- [ ] 完善 README / 接口文档与变更记录

### 阶段 4 · 可观测与部署
- [ ] 监控指标（指令成功率、超时率、在线率、OTA 成功率）
- [ ] 告警（设备异常离线、批量指令失败）
- [ ] 部署形态确认（单/多实例）+ 灰度发布

---

## 五、改造清单（Checklist）

### A. 安全类
- [ ] `[P0]` 增加 HTTP 鉴权（Spring Security / 网关 / API Key）
- [ ] `[P1]` `AckMessageHandler` 增加 commandId 归属校验（topic 设备 == 指令设备）
- [ ] `[P1]` DB / MQTT 凭据改环境变量或配置中心
- [ ] `[P1]` `spring.profiles.active` 不写死，生产独立 profile
- [ ] `[P1]` 定时任务加分布式锁或约束单实例
- [ ] `[P3]` 复核 EMQX 端口认证隔离 / ACL / TLS SAN

### B. 功能类
- [ ] `[P1]` 新增 `StateMessageHandler` 并写 `device_state_record`
- [ ] `[P1]` 新增 `EventMessageHandler` 并写 `device_event_record`
- [ ] `[P1]` 新增 `SensorMessageHandler` 并写 `sensor_record/device_sensor`
- [ ] `[P2]` `statsByDevice` 计入 ACCEPTED 或修正 total
- [ ] `[P2]` 明确 ACCEPTED 是否终态，修 `cancelCommand` / `isFinished()`
- [ ] `[P2]` `markOnline` 改定向 UPDATE

### C. 清理与可读性（不影响业务逻辑）
- [ ] `[P2]` 删除 `ONLINE/OFFLINE/WILL_TOPIC_FORMAT` 死常量
- [ ] `[P3]` 补 SQL `status` 注释 `6-ACCEPTED`
- [ ] `[P3]` OTA 启动统一使用 `DeviceOtaStartRequest`
- [ ] `[P3]` 统一常量/日志/注释风格
- [ ] `[P3]` `handleAck` 决策逻辑抽私有方法

### D. 质量与运维
- [ ] `[P2]` 补验签 / 状态机 / OTA 决策单测
- [ ] `[P3]` 固件路径与 base-url 环境变量化
- [ ] `[P3]` 生产日志级别收敛为 info/warn
- [ ] `[P4]` 指标与告警接入
- [ ] `[P4]` 部署形态与灰度方案确认

---

## 附：本次核验结论（与旧结论的差异修正）

- `cancelCommand` 实际用 `CommandStatus.isFinished()`（枚举判断），**ACCEPTED(6) 不属于终态 → 可被取消**。
  - 修正：旧说法"`status >= SUCCESS(2)` 导致 ACCEPTED 无法取消"**不成立**，真实问题见 P2-2（取消后设备仍可能继续升级）。
- `DeviceCommandMapper.xml` 扫描语句已含 `target != 'ota'`（第 53、65、148 行共 3 处），**"兜底扫描未排除 OTA"已修复**。
- `MqttPublisher` 仅有 `sendControlCommand` / `sendConfigCommand`，**不存在 `sendOtaCommand`**；`DeviceControlServiceImpl.startOta` 亦不存在 → 早期死代码已清理。
- `device_info`（`uk_device_id`/`idx_online`/`idx_last_heartbeat`/`idx_ota_state`）与 `device_command`（多组合索引）**索引齐全** → "索引缺失"风险**不成立**。
- `DeviceMqttConstants` 中已无 `OTA_STATE_*` 常量（已统一到 `DeviceOtaStateConstants`）→ "两套 OTA 常量并存"风险**已消除**。
- `AckMessageHandler` 已有 `payload.device` 与 topic 一致性校验，但**仅告警不拦截**，且**未校验 commandId 归属** → P1-1 成立。
