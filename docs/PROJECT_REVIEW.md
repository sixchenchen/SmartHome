# WM_LAOHUA 代码优化清单（v3 · 仅保留未优化项）

> **说明**
> - 核验时间：2026-10-30；核验方式：按当前代码树逐文件读取 + 关键词全量检索，**未修改任何代码**。
> - 本版**已删除全部已完成项**，只保留 **⚠️ 部分优化** 与 **❌ 未优化**。
> - 已确认完成、不再列出的项：越权控制、WebSocket 鉴权、CORS 白名单、JWT 外置（部分）、RefreshToken 原子旋转、固件路径校验、OTA 过期扫描隔离、ACCEPTED 取消语义、统计 SQL 化、整行 RMW、事务内发 MQTT（4 处全部改完）、ShedLock、Redis 差量同步、传感器批量查询、Claims 单次解析、`AdminController` 权限码、`UserOtaServiceImpl` 在线判定与 `afterCommit`。

---

## 一、总览

| 优先级 | 数量 | 编号 |
|--------|------|------|
| **高** | 5 | N-1、N-2、N-3、P1-6、P2-17 |
| **中** | 12 | N-6、N-7、N-8、N-14、N-15、N-16、N-17、P0-3、P1-2、P1-8、P2-2、P2-15 |
| **低** | 15 | N-9、N-10、N-11、N-12、N-13、N-18、N-19、N-20、P2-22、P2-23、P3-2、P3-4、P3-6、P3-7、3.9 可读性 4 项 |

---

## 二、高优先级

### N-1 `updateSpecificState` 把设备数据拼进 SQL
- **位置**：`business-module/.../service/device/impl/DeviceInfoServiceImpl.java`（`updateSpecificState`，第 221 行）
- **现状**：
  ```java
  .setSql("current_state = JSON_SET(IFNULL(current_state, '{}'), '$.\"" + key + "\"', " + state + ")")
  ```
  `key` 来自 MQTT `state` 报文的 `data.target`，**设备可控**。
- **影响**：设备上报 `target` 含 `"`、`)`、`;` 即可篡改 SQL；即使设备可信，含点/引号也会写坏 JSON。
- **优化建议**：
  1. 入参先做白名单：`if (!key.matches("^[A-Za-z0-9_]{1,32}$")) { log.warn(...); return; }`
  2. 或改为参数绑定（`JSON_SET(..., CONCAT('$."', #{key}, '"'), #{state})`）。

### N-2 定时任务重复 `@Scheduled` + 锁名错配
- **位置**：`web-module/.../schedule/DeviceCommandScheduler.java:32-33`、`schedule/DeviceHistoryDataCleanScheduler.java:30/32、50/52、70/72、87`
- **现状**：`@Scheduled` 是 `@Repeatable`，重复标注不报错但会注册两个触发器；`cleanCommandHistory`（第 87 行）**完全没有** `@SchedulerLock`，而上一个方法 `cleanStateHistory` 的锁名却被写成 `CleanScheduler_cleanStateHistory` 并占用了两行 `@Scheduled`。
- **影响**：兜底下发与 4 个清理任务每周期执行两遍；`cleanCommandHistory` 多实例下无锁并发执行。
- **优化建议**：每个方法只保留一个 `@Scheduled`；给 `cleanCommandHistory` 补 `@SchedulerLock(name = "CleanScheduler_cleanCommandHistory", lockAtMostFor = "30m")`；核对 4 个方法的锁名与 cron 是否一一对应。

### N-3 用户端 OTA 过期时间放大 60 倍
- **位置**：`web-module/.../service/mqtt/impl/UserOtaServiceImpl.java:133`
- **现状**：`now.plusMinutes(DeviceCommandConstants.DEFAULT_EXPIRE_SECONDS)`，而该常量是 **30（秒）**。
- **影响**：OTA 指令过期从 30 秒变成 30 分钟；设备无响应时用户 30 分钟内无法重试（`checkNoRunningOtaCommand` 期间一直判定升级中）。
- **优化建议**：`now.plusSeconds(DeviceCommandConstants.OTA_EXPIRE_SECONDS)`（与 `DeviceOtaServiceImpl`、`DeviceUserServiceImpl` 保持一致）。

### P1-6 nonce 校验与消费分离（重放窗口）
- **位置**：`web-module/.../service/mqtt/impl/DeviceRegisterServiceImpl.java`（`exists()` 预检 + 第 182 行 `afterCommit` 内 `tryAcquire`）
- **现状**：并发注册时两个请求都可能通过 `exists`；提交后占位失败只 `log.warn`，不回滚、不拒绝。
- **影响**：同一 nonce 可在窗口内被使用两次。
- **优化建议**：在业务校验**最前面**原子占位：
  ```java
  if (!nonceService.tryAcquire(nonce)) throw new BusinessException(ErrorCode.REPLAY_ATTACK);
  ```
  之后再做验签/入库；`catch` 中 `nonceService.release(nonce)`；删除 `afterCommit` 里的二次占位。

### P2-17 Handler 吞异常，消息静默丢失
- **位置**：`web-module/.../mqtt/core/MqttMessageRouter.java` + `mqtt/handler/*`
- **现状**：外层 `catch (Exception)` 仅 `log.error`；QoS1 已向 Broker ACK，消息不会重投。
- **影响**：落库失败、字段缺失等异常都被"吃掉"，无痕迹、无法补偿。
- **优化建议**：① 建 `mqtt_dead_letter` 表（topic / device_id / payload / error / create_time）；② Router 捕获后落库；③ 管理端提供重放接口；④ 区分可重试（DB 超时）与不可重试（报文非法）。

---

## 三、中优先级

| 编号 | 位置 | 问题 | 优化建议 |
|------|------|------|----------|
| **N-6** | `LoginAttemptServiceImpl.getLockRemainSeconds`（第 102-103 行） | 入参已是完整 key，方法内又拼 `REDIS_LOGIN_LOCK_PREFIX`，TTL 永远取不到 | 去掉内部拼接，直接 `redis.getExpire(fullKey)`；或改入参为裸 `username` |
| **N-7** | `DeviceAckMessageHandler` + `DeviceCommandServiceImpl.handleAck` | 解析出的 deviceId 未使用，未校验 `command.deviceId` | `handleAck` 增 deviceId 参数，`Objects.equals` 不一致则告警丢弃 |
| **N-8** | `DeviceOtaServiceImpl.batchDispatchOta` | 循环内逐台 `exists` 查询（N+1） | 循环前一次 `IN` 查询"已有未完成 OTA"的设备集合，循环内 `Set.contains` |
| **N-14** | `config/SecurityStartupChecker`（第 38 行 `System.exit(1)`） | ① `warn` 写在 `for/else` 分支，条件不成立不提示；② 无 active profile 时完全不校验；③ 用 `System.exit` 硬杀进程 | 无条件计算 `isDefault`；`isDefault` 时 `warn`；`prod && isDefault` 抛 `IllegalStateException`；补充 secret 解码长度 ≥ 32 字节校验 |
| **N-15** | `DeviceOfflineScheduler.handleTimeoutDevice` | 直接 `markOffline`，未用已存在的乐观方法 `markOfflineIfTimeout` | 改用 `markOfflineIfTimeout(deviceId, reason, lastHeartbeatTime)`，影响行数 0 表示期间有心跳，直接跳过 |
| **N-16** | `DeviceOtaTask` / `DeviceOtaTaskMapper` / `DeviceOtaTaskService(+Impl)` | 整条链路**无任何引用**（死表死代码） | 二选一：接入 `batchDispatchOta` 做任务维度进度统计；或删除 |
| **N-17** | `DeviceAdminServiceImpl.deleteDevice` | 已清理 4 张表，但未移除 Redis `BOUND_DEVICES_KEY` 成员 | 补 `redisTemplate.opsForSet().remove(RedisConstants.BOUND_DEVICES_KEY, mac)` |
| **P0-3** ⚠️ | `application.yml:6`（`spring.profiles.default: dev`） | 未显式指定 profile 时仍连本地 DB/MQTT | 启动日志打印 active profiles；部署文档强制注入 `SPRING_PROFILES_ACTIVE` |
| **P1-2** ⚠️ | `application.yml:121`（`${JWT_SECRET:默认值}`） | 默认密钥仍在仓库；prod 未强制覆盖 | prod 写 `${JWT_SECRET}` 不带默认值；配合 N-14 修复 |
| **P1-8** ⚠️ | `application-prod.yml:24、28` | `ca-cert: certs/cert.pem`、`base-url: https://ota.yourdomain.com/firmware/ # TODO` | 固件域名改 `${FIRMWARE_BASE_URL}`；provision CA 与 runtime 统一为 `certs/iot-ca.crt` |
| **P2-2** ⚠️ | `application.yml:69、72、102`、`application-dev.yml:30` | 基础节点仍写死 `"123456"`；dev provision 证书密码未外置 | 改 `${MQTT_PASSWORD:}` / `${DEV_PROVISION_CERT_PASS:123456}`；补 `.env.example` 并加入 `.gitignore` |
| **P2-15** ⚠️ | `DeviceCommandStatus`（第 25、59、64 行）、`DeviceCommandConstants.PENDING_STATUSES`（第 21-24 行） | 枚举 Javadoc 只列 0-5；`PENDING_STATUSES` 含 ACCEPTED 而 `isPending()` 不含，且注释写"视业务而定" | 补 Javadoc 第 6 项；`PENDING_STATUSES` 改为枚举过滤生成；统一 `isPending()` 语义 |

---

## 四、低优先级

### 安全与校验
| 编号 | 位置 | 问题 | 优化建议 |
|------|------|------|----------|
| **N-18** | `DeviceAdminServiceImpl.createDevice:71` | `bindCode` 取 UUID 前 6 位，无唯一性校验 | `bind_code` 唯一索引 + 冲突重试（≤3 次） |
| **N-19** | `MqttConfig.provisionInbound` | 只校验非空，未校验 `topics.size() == qos.size()`（runtime 有） | 补齐一致性校验 |

### 一致性与可追踪
| 编号 | 位置 | 问题 | 优化建议 |
|------|------|------|----------|
| **N-13** | `DeviceEventRecordServiceImpl.recordEvent` | 只取 `data.timestamp`，协议示例把 `timestamp` 放顶层 | 取时间顺序：顶层 → `data` → `now` |
| **N-20** | `DeviceOtaProgressMessageHandler` | 进度按 `deviceId + version` 更新，无 `commandId` 关联 | 若设备能上报 `commandId` 则关联；否则在协议文档写明限制 |
| **N-12** | `DeviceOtaServiceImpl` 类注释 | 仍写 `POST /device/ota/start` | 改为 `/api/admin/ota/batch-dispatch`、`/api/user/ota/start` |

### 代码整洁
| 编号 | 位置 | 问题 | 优化建议 |
|------|------|------|----------|
| **N-9** | `UserAuthController.java:101` | `consumeRefreshToken` 已核销，下一行又 `revokeToken` | 删除第 101 行 |
| **N-10** | `UserAuthController.login` | 缺 `@Valid`（`register` 有） | `@RequestBody @Valid LoginRequest` |
| **N-11** | `UserAuthController.java:37-41` | 直接注入 5 个 `*ServiceImpl` | 改为注入接口 |
| **P3-4** ⚠️ | `DevicePresenceMessageHandler.java:90-120` | `handleOnline` / `handleOffline` 为未调用的私有方法 | 删除（逻辑已在 Service 层） |

### 注释与结构
| 编号 | 位置 | 问题 | 优化建议 |
|------|------|------|----------|
| **P3-2** | `MqttPublisher`、`MqttMessageReceiver` | 注释仍写 1883/1884 | 改为 8883/8884，对齐 `MqttConfig` |
| **3.9-a** | `handler/GlobalExceptionHandler.java:24` | `import java.nio.file.AccessDeniedException`，与安全权限无关，该分支永不命中 | 改为 `org.springframework.security.access.AccessDeniedException`（或删除该分支，由 `JsonAccessDeniedHandler` 兜底） |
| **3.9-b** | `GlobalExceptionHandler` | 仍有"请根据实际调整"类占位注释 | 删除或写实 |
| **3.9-c** | `ScheduleConstants` | 私有构造方法位置与注释错行 | 调整到常量区之后 |
| **3.9-d** ⚠️ | `RedisConstants` | 已 `final`，但无私有构造 | 补私有构造 |

### 测试与文档
| 编号 | 位置 | 问题 | 优化建议 |
|------|------|------|----------|
| **P2-22** | `**/src/test/**` | 只有 `contextLoads` | 补 4 组：验签、状态迁移矩阵、OTA 版本比较与僵死清理、nonce 并发占位 |
| **P2-23** | 同上 | 无报文契约测试 | 8 类主题各一份 JSON fixture，断言解析不抛异常 |
| **P3-6** | `README.md` | 仍是重构前结构 | 按真实目录树 + 接口清单（`/api/auth`、`/api/user/**`、`/api/admin/**`）重写 |
| **P3-7** | `docs/` | 无部署手册 | 新增 `docs/DEPLOYMENT.md`：环境变量表、EMQX ACL、证书、`shedlock` 表 DDL |

---

## 五、建议顺序

1. **N-2**（重复 `@Scheduled` + 缺锁）——改动最小，先消除双跑
2. **N-3**（`plusMinutes` → `plusSeconds`）——一行
3. **N-1**（`setSql` 白名单）——一处校验
4. **N-14 / P1-2**（启动密钥校验）——一起改
5. **N-6 / N-9 / N-10 / N-11 / N-12**——登录链路小修
6. **N-15 / N-17 / N-18**——离线判定与设备删除一致性
7. **N-7 / N-8**——ACK 归属与批量 OTA 性能
8. **P1-6 / P2-17**——nonce 原子占位、死信表
9. **N-16**——`DeviceOtaTask` 接入或删除（需确认产品意图）
10. **P2-22 / P2-23 / P3-2 / P3-4 / P3-6 / P3-7**——测试与文档收尾

---

## 六、补充说明

- **N-4 / N-5 已在本次核验中确认修复**（`UserOtaServiceImpl` 已改用 `TransactionUtils.afterCommit` 与 `deviceInfoService.isDeviceActuallyOnline`），故从清单删除。
- `TransactionUtils` 已替代原先三处重复的 `TransactionSynchronizationManager` 写法，4 处调用统一，此项无需再改。
- 本清单中的"位置"均指向当前真实存在的文件与方法；如后续再次重命名，请以类名 + 方法名检索定位，不要依赖行号。
