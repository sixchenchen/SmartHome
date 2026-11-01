# WM_LAOHUA 代码优化清单（v4 · 仅保留未优化项）

> **核验时间**：2026-11-01（第 4 轮复核，逐项对照当前代码）
> **核验方式**：全量关键词检索 + 关键文件读取，**本次未修改任何代码**
> **本版已删除上一轮全部已完成项**，仅保留 **❌ 未优化** 与 **⚠️ 部分优化**。
>
> **上一轮已在代码中确认完成的项（不再列出）**：
> N-1（`setSql` 拼接）、N-2（重复 `@Scheduled` 与锁名）、N-3（`plusMinutes`）、N-4/N-5（`UserOtaServiceImpl`）、N-6（锁定 TTL 双前缀）、N-7（ACK 归属校验）、N-9（重复核销）、N-10（`@Valid`）、N-11（接口注入）、N-12（类注释）、N-13（事件时间取顶层）、N-14（`System.exit`）、N-15（`markOfflineIfTimeout`）、N-17（删除设备清 Redis）、N-18（bindCode 碰撞重试）、N-19（provision topics/qos 校验）、N-20（OTA commandId 追踪）、P1-6（nonce 原子占位）、P2-17（死信表）、P3-2（端口注释）、P3-4（presence 死方法）、3.9-a（错误 import）、3.9-b（占位注释）、3.9-c（`ScheduleConstants` 私有构造）。

---

## 一、总览

| 状态 | 数量 | 编号 |
|------|------|------|
| **❌ 未优化** | 6 | N-8、N-16、P2-22、P2-23、P3-6、P3-7 |
| **⚠️ 部分优化** | 6 | P0-3、P1-2、P1-8、P2-2、P2-15、3.9-d |

---

## 二、❌ 未优化

### N-8 批量 OTA 循环内存在**多余**的逐台 `exists` 查询
- **位置**：`web-module/.../service/mqtt/impl/DeviceOtaServiceImpl.java`
  - 第 292-304 行：已用 `in(targetDeviceIds)` 批量查出 `runningDeviceIds`
  - 第 318-324 行：循环内已用 `runningDeviceIds.contains(...)` 判定
  - **第 326-334 行：又逐台执行一次 `deviceCommandService.exists(...)`**
- **现状**：批量判定与逐台 `exists` 结果完全等价，后者是重构后的**遗留重复查询**。
- **影响**：假设 1000 台设备，每轮批量下发多出 1000 次 `SELECT`；事务持有时间变长，且日志里会出现两条重复的"跳过设备"告警。
- **优化建议**：直接删除第 325-339 行整段（含 `existsRunning` 变量与 `if (existsRunning)` 分支），保留 `runningDeviceIds.contains(...)` 即可。

### N-16 `DeviceOtaTask` 整条链路仍未被引用
- **位置**：`business-module/.../model/device/DeviceOtaTask`、`mapper/device/DeviceOtaTaskMapper`、`service/device/DeviceOtaTaskService`、`service/device/impl/DeviceOtaTaskServiceImpl`
- **现状**：实体 / Mapper / Service 均存在，但**没有任何业务代码注入或调用**（全量检索仅命中这 4 个文件自身）。
- **影响**：数据库多一张空表、代码多一套死分层；后续维护者会误以为"任务维度统计已可用"。
- **优化建议**：二选一
  1. **接入**：`batchDispatchOta` 时创建一条 `DeviceOtaTask`（记录 firmwareId、targetProduct、总数），ACK/进度回写 `success/failed/pending`，管理端提供"任务详情"接口；`DeviceOtaProgressMessageHandler` 按 `commandId` 关联到任务。
  2. **删除**：移除实体、Mapper、Service、Impl（注意同步删除 `device_ota_task` 表与多点表结构）。

### P2-22 核心逻辑零单测
- **位置**：`**/src/test/**`（仅 `WebModuleApplicationTests`、`BusinessModuleApplicationTests` 两个 `contextLoads`）
- **影响**：状态机、验签、OTA 判定这类"一旦改错很难发现"的逻辑全靠人工验证。
- **优化建议**（按性价比排序）：
  1. `DeviceCommandStatusTest`：7 状态 × 迁移矩阵（`isFinished/isPending/isActive` 断言）；
  2. `SignatureVerifierUtilsTest`：正确签名 / 篡改内容 / 空签名 / 长度不合法；
  3. `DeviceOtaServiceImplTest`：版本比较、`isStale` 僵死清理、NULL 版本设备入选；
  4. `DeviceNonceServiceImplTest`：同一 nonce 两次 `tryAcquire`，第二次必须为 `false`。

### P2-23 无 MQTT 报文契约测试
- **位置**：同上
- **影响**：Handler 的字段名（`otaState`、`target`、`commandId`、顶层 `timestamp` 等）与设备固件/协议文档一旦错位，只能靠线上日志发现。
- **优化建议**：`src/test/resources/payloads/` 放 8 份 fixture（register / presence / heartbeat / state / ack / event / sensor / ota_progress），逐一调用 Handler 断言不抛异常且关键字段落库正确；报文结构变更时测试先红。

### P3-6 README 仍描述已删除的控制器
- **位置**：`README.md`
- **现状**（实测）：
  - 第 394 行：`### 5.1 设备指令 DeviceCommandController（/device/command）`
  - 第 404 行：`### 5.2 OTA DeviceOtaController（/ota）`
  - 第 9 行：`上下文路径 /api`
- **实际代码**：控制器已拆为 `/api/user/devices`、`/api/user/ota`、`/api/admin/devices`、`/api/admin/ota`；**没有 context-path**（`/api` 是控制器注解前缀）。
- **优化建议**：重写第 5 章接口清单与第 1 章架构说明，统一按当前类名（`UserDeviceController`、`AdminDeviceController`、`UserOtaController`、`AdminOtaController`）标注路径。

### P3-7 缺少部署手册
- **位置**：`docs/`（仅有 `PROJECT_REVIEW.md`）
- **影响**：环境变量、证书、EMQX ACL、`shedlock` 表这些上线必需项散落在 README 与注释里，交付/交接容易漏。
- **优化建议**：新增 `docs/DEPLOYMENT.md`，至少包含：
  1. 环境变量全表（`DB_*`、`REDIS_*`、`MQTT_*`、`JWT_SECRET`、`FIRMWARE_BASE_URL`）
  2. 证书放置路径与权限（runtime / provision 两套 PKCS12）
  3. EMQX ACL 规则（设备仅能订阅自身主题）
  4. `shedlock` 建表 DDL
  5. 启动自检项（profile、订阅主题数、固件目录可写）

---

## 三、⚠️ 部分优化

### P0-3 ⚠️ 默认激活 dev profile
- **位置**：`application.yml:6` — `spring.profiles.default: dev`
- **已改**：由 `active: dev` 改为 `default: dev`，可被 `--spring.profiles.active` 覆盖。
- **残留**：未显式指定 profile 时仍会连 `localhost` 的 DB/MQTT。
- **建议**：启动时打印 `activeProfiles`；部署文档强制注入 `SPRING_PROFILES_ACTIVE`；条件成熟后删除 `default: dev`。

### P1-2 ⚠️ JWT 默认密钥仍在仓库
- **位置**：`application.yml:121` — `secret: ${JWT_SECRET:默认Base64}`
- **已改**：已环境变量化；`SecurityStartupChecker` 不再 `System.exit`（已改为抛异常路径）。
- **残留**：`${JWT_SECRET:...}` 的冒号后仍带默认值，prod 未强制覆盖。
- **建议**：`application-prod.yml` 中显式写 `secret: ${JWT_SECRET}`（无默认值），缺失即启动失败；`SecurityStartupChecker` 增加解码后长度 ≥ 32 字节校验。

### P1-8 ⚠️ prod 仍有两处占位
- **位置**：`application-prod.yml:23`、`:28`
- **现状**：
  - `mqtt.provision.ca-cert: certs/cert.pem`（与 runtime 的 `certs/iot-ca.crt` 不一致）
  - `firmware.base-url: https://ota.yourdomain.com/firmware/ # TODO 服务器地址`
- **建议**：CA 统一为 `certs/iot-ca.crt`（或确认 provision 确实使用独立 CA 后写清注释）；`base-url` 改 `${FIRMWARE_BASE_URL}` 并在部署清单中要求配置。

### P2-2 ⚠️ 仍有明文凭据
- **位置**（实测仍存在）：
  - `application.yml:69` — runtime `password: "123456"`
  - `application.yml:72`、`:102` — `client-cert-password: "123456"`
  - `application-dev.yml:30` — provision `client-cert-password: "123456"`
- **已改**：`application-dev.yml` 的 DB/账号/证书密码多数已 `${DEV_*:123456}`。
- **建议**：基础 `application.yml` 的 MQTT 口令也改 `${MQTT_PASSWORD:}`；dev provision 证书密码改 `${DEV_PROVISION_CERT_PASS:123456}`；确保 `.env` 在 `.gitignore`，仓库只保留 `.env.example`。

### P2-15 ⚠️ 待处理状态的两套口径
- **位置**：`common-module/.../enums/DeviceCommandStatus`（第 61-63 行）、`common-module/.../constants/DeviceCommandConstants`（第 21-24 行）
- **现状**：
  - `isPending()` 只含 `PENDING / SENT`
  - `PENDING_STATUSES` 却包含 `ACCEPTED`，且第 24 行注释仍是"视业务而定，如果有需要可以加上"
  - 新增的 `isActive()` = `!isFinished()`（含 ACCEPTED），语义正确
- **影响**：调用方若用 `PENDING_STATUSES` 与 `isActive()` 判定"进行中"，两者一致；但用 `isPending()` 会漏掉 ACCEPTED，容易在新增校验时踩坑。
- **建议**：把 `PENDING_STATUSES` 改为由 `isActive()` 派生（`DeviceCommandStatus.values().stream().filter(DeviceCommandStatus::isActive)`），删除"视业务而定"的模糊注释；并在枚举 Javadoc 中明确 `isPending()` 与 `isActive()` 的区别。

### 3.9-d ⚠️ `RedisConstants` 缺私有构造
- **位置**：`common-module/.../constants/RedisConstants.java:8` — `public final class RedisConstants {`
- **现状**：已 `final`，但没有私有构造（`ScheduleConstants` 已补，本类遗漏）。
- **建议**：补 `private RedisConstants() {}`，与 `ScheduleConstants`、`DeviceCommandConstants` 保持一致的常量类规范。

---

## 四、建议顺序

1. **N-8**——删掉 15 行冗余查询，零风险，立刻减少 N+1
2. **P2-2 / P1-8 / P1-2 / P0-3**——配置项一次性收敛（4 个文件、十余行）
3. **P2-15 / 3.9-d**——两处小重构，避免后续误用
4. **N-16**——`DeviceOtaTask` 接入或删除（需先确认产品是否需要"批量任务"维度）
5. **P2-22 / P2-23**——先补状态机与 nonce 两个最高价值用例
6. **P3-6 / P3-7**——README 与部署手册收尾

---

## 五、说明

- 本轮清单的"位置"均已完成实测：`N-8` 的冗余 `exists`、README 的 `DeviceCommandController`、`application.yml` 的 `123456` 均为直接读取确认。
- 若后续再次调整，请以**类名 + 方法名**检索定位，行号会随重构位移。
