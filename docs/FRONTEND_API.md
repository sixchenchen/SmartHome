# WM_LAOHUA 前端对接文档

> **文档版本**：v1.4　**编写日期**：2026-11-04　**最近更新**：2026-11-10　**适用代码**：当前 `main` 工作区
> **性质**：前后端对接文档。**v1.4 新增三层限流与风控（验证码获取、登录请求、失败计数），详见第 12 章**。
> **标注约定**：
> - ✅ **已实现**：后端接口已存在，可直接联调（路径、参数、响应均按当前代码逐字段核对）。
> - ⚠️ **已实现但有限制**：接口存在，但字段/校验/返回结构有坑，前端需注意。
> - 原 v1.0 的"❌ 未实现"清单（第 8 章）**已全部实现**，对应章节已改为实际契约。

---

## 目录

1. [接入准备](#1-接入准备)
2. [统一响应与错误码](#2-统一响应与错误码)
3. [认证与权限](#3-认证与权限)
4. [已实现接口总览](#4-已实现接口总览原有-20-个--本轮新增-52-个)
5. [接口详情](#5-接口详情)
6. [WebSocket 实时推送](#6-websocket-实时推送)
7. [枚举字典](#7-枚举字典)
8. [本轮新增接口详情（已实现）](#8-本轮新增接口详情-全部已实现)
9. [前端对接风险与待确认项](#9-前端对接风险与待确认项)
10. [联调检查清单](#10-联调检查清单)
11. [OTA 升级全流程与实时进度（前端必读）](#11-ota-升级全流程与实时进度前端必读)
12. [三层限流与风控（前端必读）](#12-三层限流与风控前端必读)

---

## 1. 接入准备

### 1.1 服务地址

| 环境 | Base URL | 说明 |
|------|----------|------|
| 本地开发 | `http://localhost:8080` | `server.port: 8080` |
| 生产 | 由部署方提供 | `application-prod.yml`，需运维确认域名与是否启用 HTTPS |

**重要**：项目**没有配置 `server.servlet.context-path`**（不存在 `/api` 作为全局前缀）。所有接口的 `/api/...` 前缀来自 Controller 上的 `@RequestMapping`，前端直接拼接即可：

```
http://localhost:8080/api/auth/login
http://localhost:8080/api/user/devices/my
```

### 1.2 接口文档与调试

- Knife4j：`http://localhost:8080/doc.html`（开发环境开放；生产环境默认关闭，需运维确认）
- OpenAPI JSON：`/v3/api-docs`

### 1.3 公共请求头

| Header | 必填 | 说明 |
|--------|------|------|
| `Authorization` | 除登录/注册/刷新外**必填** | 值：`Bearer <accessToken>`（注意 `Bearer` 后有**一个空格**） |
| `Content-Type` | 视接口 | JSON 用 `application/json`；固件上传用 `multipart/form-data` |
| `X-Device-Type` | 否（仅登录时读取） | 登录时传入 `web` / `app` / `mini`，会写入 RefreshToken 记录；不传默认 `web` |
| `X-Device-Id` | 否（强烈建议） | 设备指纹，前端生成并持久化（如 UUID）；用于设备维度限流。不传时后端降级使用 IP |

> 后端 CORS 已改为**配置化白名单**，前端联调前必须把本地域名（如 `http://localhost:5173`）加入后端配置，否则浏览器会拦截。

### 1.4 时间与时区

- 服务端统一 `Asia/Shanghai`。
- 普通 `LocalDateTime` 字段按 Spring Boot 默认序列化为 **ISO-8601 字符串**，例如 `"2026-11-04T10:30:00"`。
- `LoginResponse` 中的 `lastLoginTime`、`expiresAt` 使用注解格式：`"2026-11-04 10:30:00"`。
- 前端展示时统一按本地时区解析，不要用 `new Date("2026-11-04T10:30:00")` 之外的自定义解析。

### 1.5 分页约定

分页接口统一使用 `pageNum` / `pageSize`（不是 `page` / `size`），默认 `1` / `10`。

响应为 MyBatis-Plus `Page` 直出，字段为：

```json
{
  "records": [ ... ],
  "total": 25,
  "size": 10,
  "current": 1,
  "pages": 3
}
```

> 前端取列表用 `data.records`，总数用 `data.total`。

---

## 2. 统一响应与错误码

### 2.1 响应结构（✅ 所有业务接口）

```json
{
  "code": 200,
  "message": "success",
  "data": { },
  "timestamp": "2026-11-04T10:30:00"
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `code` | int | 业务码，`200` 为成功 |
| `message` | string | 提示信息，可直接展示 |
| `data` | T | 业务数据，可能为 `null` |
| `timestamp` | string | 服务端时间，ISO-8601 |

### 2.2 HTTP 状态与业务码的关系（⚠️ 前端必须理解）

| 场景 | HTTP 状态 | `code` | 说明 |
|------|-----------|--------|------|
| 正常 | 200 | 200 | 成功 |
| 参数/业务异常 | **200** | 1000/2000/42xx… | `GlobalExceptionHandler` 统一返回 HTTP 200 + 业务码，**不能只看 HTTP 状态** |
| 未登录 / Token 无效 | **401** | 401 | 由 `JsonAuthenticationEntryPoint` 返回 |
| 无权限 | **403** | 401（复用 FAIL） | 由 `JsonAccessDeniedHandler` 返回 |
| 系统异常 | 200 或 500 | 5000 | 兜底分支返回业务码 5000 |

**前端判断规则**：`if (res.code !== 200) 走错误分支`；HTTP 401 时触发刷新或跳登录页；HTTP 403 提示无权限。

### 2.3 错误码全表（✅ 与 `ErrorCode` 一致）

| code | message | 前端建议处理 |
|------|---------|--------------|
| 200 | success | 正常 |
| 401 | fail | 通用失败 |
| 404 | 资源不存在 | 提示 |
| **1000** | 参数错误 | 表单提示 |
| **1001** | 缺少必要参数 | 表单提示 |
| **1002** | 参数值非法 | 表单提示 |
| **1003** | 参数不能为空 | 表单提示 |
| **1010** | 密码不能为空 | 表单提示 |
| **1011** | 密码长度不能少于6位 | 表单提示 |
| **2000** | 业务异常 | 展示 message |
| **4000** | 文件为空 | 上传组件拦截 |
| **4001** | 文件超过大小限制 | 上传组件拦截 |
| **4002** | 文件格式错误 | 提示 |
| **4003** | 文件上传失败 | 重试 |
| **4004** | 文件不存在 | 提示 |
| **4010** | 用户名或密码错误 | 提示 |
| **4011** | 账号已禁用，请联系管理员 | 提示，禁止重试 |
| **4012** | RefreshToken 无效或已过期，请重新登录 | **跳转登录页** |
| **4013** | 账号已锁定 | 提示"账号已锁定，请 15 分钟后再试" |
| **4014** | 未登录或 token 已过期 | **触发刷新 / 跳登录** |
| **4015** | 用户不存在 | 跳登录 |
| **4020** | 权限不存在 | 刷新权限列表 |
| **4021** | 权限编码已存在 | 提示更换编码 |
| **4022** | 权限已被角色引用，无法删除 | 提示先解除角色授权 |
| **4023** | 权限类型非法 | 表单提示（MENU/BUTTON/API/ACTION） |
| **4024** | 权限编码不允许修改 | 编码只读 |
| **4030** | 验证码已过期，请重新获取 | 刷新验证码图片 |
| **4031** | 验证码错误 | 提示并刷新验证码 |
| **4032** | 请输入验证码 | 表单提示 |
| **4033** | 暂不支持该验证码类型 | 仅使用 `image` |
| **4034** | 验证码生成失败 | 重试 |
| **4100** | 固件版本已存在 | 提示换版本号 |
| **4101** | 固件不存在 | 刷新列表 |
| **4102** | 固件已禁用 | 提示 |
| **4103** | 固件文件超过大小限制 | 上传组件拦截 |
| **4104** | 固件文件不存在 | 提示 |
| **4105** | 版本号不能为空 | 表单提示 |
| **4106** | 文件格式必须是 .bin | 上传组件限制 `accept=".bin"` |
| **4107** | 计算文件哈希失败 | 重试 |
| **4200** | 设备不存在 | 提示 |
| **4201** | 设备当前为离线状态，请检查电源后重试 | 提示，禁用控制按钮 |
| **4202** | 设备ID为空 | 表单提示 |
| **4203** | 设备ID格式错误 | 表单提示（MAC 12 位十六进制） |
| **4204** | MAC 格式错误 | 表单提示 |
| **4205** | 设备绑定码错误，请扫描设备机身上的二维码 | 提示 |
| **4206** | 您已经绑定了该设备 | 提示 |
| **4207** | 该设备已被其他用户绑定 | 提示 |
| **4208** | 该设备已被绑定，请刷新重试 | 刷新列表 |
| **4209** | 您尚未绑定该设备，或已被解绑 | 刷新 |
| **4210** | 您未绑定该设备，无权操作 | 提示 |
| **4211** | 设备心跳超时或网络异常，请稍后重试 | 提示 |
| **4212** | 设备MAC地址已存在 | 提示 |
| **4300** | OTA 触发失败 | 重试 |
| **4301** | OTA 正在进行中 | 禁用升级按钮 |
| **4302** | OTA 版本不兼容 | 提示 |
| **4303** | 当前已是最新版本，无需升级 | 提示 |
| **4400** | 角色不存在 | 刷新角色列表 |
| **4401** | 角色编码已存在 | 提示更换编码 |
| **4402** | 角色已分配给用户，无法删除 | 提示先解除用户角色 |
| **4403** | 内置角色不允许该操作 | 禁用删除/禁用/改编码按钮 |
| **4404** | 角色已禁用 | 提示 |
| **4500** | 用户名已存在 | 表单提示 |
| **4501** | 至少需要分配一个角色 | 表单提示 |
| **4502** | 用户状态非法 | 表单提示 |
| **4600** | 请求过于频繁，请稍后再试 | HTTP 429；按钮倒计时 |
| **4601** | 请求过于频繁，请完成人机验证 | HTTP 429；展示滑块/行为验证（预留） |
| **4602** | 当前网络访问受限，请稍后再试 | HTTP 429；提示稍后再试 |
| **5000** | 系统异常 | 通用错误页 |
| **5001** | 数据库异常 | 通用错误页 |
| **5002** | 系统配置缺失 | 联系运维 |
| **5003** | 网络异常 | 重试 |

---

## 3. 认证与权限

### 3.1 双 Token 机制（✅）

| 项 | 说明 |
|----|------|
| Access Token | 登录/刷新返回，放在 `Authorization` 头 |
| Refresh Token | 登录/刷新返回，有效期 **7 天**，**一次一换**（旋转） |
| 失效规则 | 刷新成功后**旧 RefreshToken 立即作废**；登出会把 AccessToken 加入黑名单并撤销 RefreshToken |
| 前端存储 | 建议 `localStorage` 存两个 token；不要只存一个 |
| 有效期 | 以 `LoginResponse.expiresAt` 为准，前端据此提前 5 分钟刷新 |

### 3.2 推荐流程

```
登录 → 保存 token + refreshToken + roles + permissions
   ↓
业务请求带 Authorization
   ↓
code=4014 或 HTTP 401 → 调用 /api/auth/refresh（带 refreshToken）
   ↓
成功：替换两个 token，重放原请求
失败（4012）：清空本地，跳登录页
```

### 3.3 ⚠️ 刷新并发限制（必须处理）

后端刷新是**原子核销**：同一个 `refreshToken` 并发调用只会成功一次，其余返回 `4012`。

**前端必须加"刷新锁"**：多个请求同时收到 401 时，只允许一个请求去刷新，其余挂起等待结果，成功后统一重放。

### 3.4 登录失败锁定（✅）

- 维度：**同一 IP + 同一用户名**
- 阈值：5 次失败
- 锁定时长：15 分钟
- 返回码：`4013`
- 前端：登录页展示锁定提示并倒计时，避免用户连续点击。

### 3.5 角色与权限码（✅）

角色：`ADMIN`、`OPS`、`USER`（注册用户默认 `USER`）。
`LoginResponse.permissions` 为权限码数组（如 `["device:list","firmware:upload"]`）。

> `ADMIN`、`OPS`、`USER` 为内置角色（`builtIn=1`）：不允许删除、不允许修改角色编码、不允许禁用。
> **升级提示**：已有数据库需执行 `web-module/src/main/resources/sql/smart_device.sql` 中 `sys_permission` id `21~30` 及 `sys_role_permission` id `40~49` 的增量记录，否则 ADMIN 调用角色/权限管理接口会返回 403。

| 接口 | 角色要求 | 权限码要求 |
|------|----------|------------|
| `/api/admin/**` | `ADMIN`（`hasRole('ADMIN')`） | 见下 |
| `GET /api/admin/users`、`GET /{id}`、`GET /{id}/devices` | ADMIN | `user:list` |
| `POST /api/admin/users` | ADMIN | `user:create` |
| `PUT /api/admin/users/{id}`、`/status`、`/roles` | ADMIN | `user:update` |
| `DELETE /api/admin/users/{id}` | ADMIN | `user:delete` |
| `POST /api/admin/users/{id}/force-unbind` | ADMIN | `device:unbind` |
| `GET /api/admin/roles`、`/all`、`/{id}`、`/{id}/permissions` | ADMIN | `role:list` |
| `POST /api/admin/roles` | ADMIN | `role:create` |
| `PUT /api/admin/roles/{id}`、`/{id}/status` | ADMIN | `role:update` |
| `DELETE /api/admin/roles/{id}` | ADMIN | `role:delete` |
| `PUT /api/admin/roles/{id}/permissions` | ADMIN | `role:assign-permission` |
| `GET /api/admin/permissions`、`/all`、`/{id}` | ADMIN | `permission:list` |
| `POST /api/admin/permissions` | ADMIN | `permission:create` |
| `PUT /api/admin/permissions/{id}`、`/{id}/status` | ADMIN | `permission:update` |
| `DELETE /api/admin/permissions/{id}` | ADMIN | `permission:delete` |
| `GET /api/admin/devices`、`/online-stats`、`/export` | ADMIN | `device:list` |
| `GET /api/admin/devices/{id}`、`/{id}/bindings` | ADMIN | `device:read` |
| `PUT /api/admin/devices/{id}` | ADMIN | `device:update` |
| `POST /api/admin/devices` | ADMIN | `device:create` |
| `DELETE /api/admin/devices/{id}` | ADMIN | `device:delete` |
| `POST /api/admin/devices/{id}/unbind` | ADMIN | `device:unbind` |
| `POST /api/admin/devices/{id}/command` | ADMIN | `command:send` |
| `POST /api/admin/ota/firmware/upload`、`PUT /firmware/{id}/status` | ADMIN | `firmware:upload` |
| `GET /api/admin/ota/firmware`、`/firmware/list`、`/firmware/{id}`、`/tasks`、`/tasks/{id}` | ADMIN | `ota:list` |
| `DELETE /api/admin/ota/firmware/{id}` | ADMIN | `firmware:delete` |
| `POST /api/admin/ota/batch-dispatch` | ADMIN | `ota:create` |
| `POST /api/admin/ota/tasks/{id}/cancel` | ADMIN | `ota:cancel` |
| `GET /api/admin/dashboard/summary`、`/commands`、`/audit-logs` | ADMIN | `device:list` |
| `GET /api/admin/alerts` | ADMIN | `alert:list` |
| `PUT /api/admin/alerts/{id}/status` | ADMIN | `alert:handle` |
| `GET/POST /api/admin/dead-letters**` | ADMIN | 仅角色，无权限码 |
| `/api/user/**` | 登录用户 | 无权限码，走设备归属校验 |
| `/api/common/**` | 登录用户 | 无权限码 |

> 前端菜单/按钮建议按 `permissions` 渲染；注意 `dead-letters` 只校验角色。

---

## 4. 已实现接口总览（原有 20 个 + 本轮新增 52 个）

> 本轮已完成 **第 8 章全部待实现接口**，后端已全部落地并通过编译。下面按模块汇总，详细字段见第 5 章与第 8 章。

### 4.1 原有接口（20 个，本轮已修正限制）

| # | 方法 | 路径 | 权限 | 状态 |
|---|------|------|------|------|
| 1 | POST | `/api/auth/register` | 匿名 | ✅ |
| 2 | POST | `/api/auth/login` | 匿名 | ✅ |
| 3 | POST | `/api/auth/refresh` | 匿名 | ✅ |
| 4 | POST | `/api/auth/logout` | 登录 | ✅ |
| 5 | POST | `/api/user/devices/bind` | 登录 | ✅ 已加 `@Valid`（`deviceId` 必填） |
| 6 | POST | `/api/user/devices/unbind` | 登录 | ✅ 已加 `@Valid`（`deviceId` 必填） |
| 7 | GET | `/api/user/devices/my` | 登录 | ✅ 已补 OTA 字段 |
| 8 | POST | `/api/user/devices/control` | 登录 | ✅ 现返回 `commandId` |
| 9 | GET | `/api/user/ota/check/{deviceId}` | 登录 | ✅ |
| 10 | POST | `/api/user/ota/start/{deviceId}` | 登录 | ✅ |
| 11 | DELETE | `/api/admin/users/{id}` | ADMIN + `user:delete` | ✅ |
| 12 | GET | `/api/admin/devices` | ADMIN + `device:list` | ✅ 现返回 `AdminDeviceVO`（不再暴露实体） |
| 13 | POST | `/api/admin/devices` | ADMIN + `device:create` | ✅ |
| 14 | DELETE | `/api/admin/devices/{id}` | ADMIN + `device:delete` | ✅ |
| 15 | POST | `/api/admin/ota/firmware/upload` | ADMIN + `firmware:upload` | ✅ |
| 16 | GET | `/api/admin/ota/firmware/list` | ADMIN + `ota:list` | ✅（不分页，保留兼容） |
| 17 | DELETE | `/api/admin/ota/firmware/{id}` | ADMIN + `firmware:delete` | ✅ |
| 18 | POST | `/api/admin/ota/batch-dispatch` | ADMIN + `ota:create` | ✅ 现同时生成批量任务 |
| 19 | GET | `/api/admin/dead-letters` | ADMIN | ✅ |
| 20 | POST | `/api/admin/dead-letters/{id}/replay` | ADMIN | ✅ |

### 4.2 本轮新增接口（52 个，另含用户/角色/权限管理 17 个）

**用户中心（4）**

| # | 方法 | 路径 | 权限 |
|---|------|------|------|
| 1 | GET | `/api/user/profile` | 登录 |
| 2 | PUT | `/api/user/profile` | 登录 |
| 3 | PUT / POST | `/api/user/password` | 登录 |
| 4 | GET | `/api/user/login-logs` | 登录 |

**用户设备 / 指令（9）**

| # | 方法 | 路径 | 权限 |
|---|------|------|------|
| 5 | GET | `/api/user/devices/{deviceId}` | 登录 + 绑定校验 |
| 6 | GET | `/api/user/devices/{deviceId}/online` | 登录 + 绑定校验 |
| 7 | PUT | `/api/user/devices/{deviceId}` | 登录 + 绑定校验 |
| 8 | GET | `/api/user/devices/{deviceId}/commands` | 登录 + 绑定校验 |
| 9 | GET | `/api/user/devices/{deviceId}/commands/stats` | 登录 + 绑定校验 |
| 10 | POST | `/api/user/devices/{deviceId}/commands/batch` | 登录 + 绑定校验 |
| 11 | GET | `/api/user/commands` | 登录 |
| 12 | GET | `/api/user/commands/{commandId}` | 登录 |
| 13 | POST | `/api/user/commands/{commandId}/cancel` | 登录 |

**传感器 / 事件 / 告警（6）**

| # | 方法 | 路径 | 权限 |
|---|------|------|------|
| 14 | GET | `/api/user/devices/{deviceId}/sensors` | 登录 + 绑定校验 |
| 15 | GET | `/api/user/devices/{deviceId}/sensors/latest` | 登录 + 绑定校验 |
| 16 | GET | `/api/user/devices/{deviceId}/events` | 登录 + 绑定校验 |
| 17 | GET | `/api/user/devices/{deviceId}/states` | 登录 + 绑定校验 |
| 18 | GET | `/api/user/alerts` | 登录 |
| 19 | POST | `/api/user/alerts/{id}/ack` | 登录 + 归属校验 |

**用户 OTA（3）**

| # | 方法 | 路径 | 权限 |
|---|------|------|------|
| 20 | GET | `/api/user/ota/progress/{deviceId}` | 登录 + 绑定校验 |
| 21 | GET | `/api/user/ota/records` | 登录 |
| 22 | POST | `/api/user/ota/retry/{deviceId}` | 登录 + 绑定校验 |

**管理端用户（7）**

| # | 方法 | 路径 | 权限码 |
|---|------|------|--------|
| 23 | GET | `/api/admin/users` | `user:list` |
| 24 | GET | `/api/admin/users/{id}` | `user:list` |
| 25 | PUT | `/api/admin/users/{id}` | `user:update` |
| 26 | PUT | `/api/admin/users/{id}/status` | `user:update` |
| 27 | PUT | `/api/admin/users/{id}/roles` | `user:update` |
| 28 | GET | `/api/admin/users/{id}/devices` | `user:list` |
| 29 | POST | `/api/admin/users/{id}/force-unbind` | `device:unbind` |

**管理端设备（7）**

| # | 方法 | 路径 | 权限码 |
|---|------|------|--------|
| 30 | GET | `/api/admin/devices/{id}` | `device:read` |
| 31 | PUT | `/api/admin/devices/{id}` | `device:update` |
| 32 | GET | `/api/admin/devices/{id}/bindings` | `device:read` |
| 33 | POST | `/api/admin/devices/{id}/unbind` | `device:unbind` |
| 34 | GET | `/api/admin/devices/online-stats` | `device:list`（兼容 `/stats/online`） |
| 35 | POST | `/api/admin/devices/{id}/command` | `command:send` |
| 36 | GET | `/api/admin/devices/export` | `device:list`（直接下载 CSV） |

**管理端固件 / OTA 任务（6）**

| # | 方法 | 路径 | 权限码 |
|---|------|------|--------|
| 37 | GET | `/api/admin/ota/firmware` | `ota:list` |
| 38 | GET | `/api/admin/ota/firmware/{id}` | `ota:list` |
| 39 | PUT | `/api/admin/ota/firmware/{id}/status` | `firmware:upload` |
| 40 | GET | `/api/admin/ota/tasks` | `ota:list` |
| 41 | GET | `/api/admin/ota/tasks/{id}` | `ota:list` |
| 42 | POST | `/api/admin/ota/tasks/{id}/cancel` | `ota:cancel` |

**管理端运维 / 死信（7）**

| # | 方法 | 路径 | 权限码 |
|---|------|------|--------|
| 43 | GET | `/api/admin/dashboard/summary` | `device:list` |
| 44 | GET | `/api/admin/commands` | `device:list` |
| 45 | GET | `/api/admin/alerts` | `alert:list` |
| 46 | PUT | `/api/admin/alerts/{id}/status` | `alert:handle` |
| 47 | GET | `/api/admin/audit-logs` | `device:list` |
| 48 | GET | `/api/admin/dead-letters/{id}` | ADMIN |
| 49 | POST | `/api/admin/dead-letters/{id}/ignore` | ADMIN |

**通用能力（3）**

| # | 方法 | 路径 | 说明 |
|---|------|------|------|
| 50 | POST | `/api/common/upload/avatar` | 头像上传 |
| 51 | GET | `/api/common/dictionaries` | 字典下发 |
| 52 | GET | `/actuator/health` | 健康检查（免认证） |
| 53 | POST | `/api/auth/captcha` | 获取验证码（免认证） |

---

## 5. 接口详情

### 5.1 用户注册 ✅

`POST /api/auth/register`　无需 Token

**请求体**

| 字段 | 类型 | 必填 | 校验规则 |
|------|------|------|----------|
| username | string | 是 | 4~32 位，仅字母/数字/下划线 |
| password | string | 是 | 8~64 位，必须同时含字母和数字 |
| nickname | string | 否 | ≤64 位 |
| email | string | 否 | 邮箱格式，≤128 位 |
| phone | string | 否 | `^1[3-9]\\d{9}$` 或空 |

```json
{ "username": "test001", "password": "abc12345", "nickname": "测试", "email": "a@b.com", "phone": "13800138000" }
```

**响应**

```json
{ "code": 200, "message": "success", "data": { "userId": 12, "username": "test001", "nickname": "测试" }, "timestamp": "..." }
```

**错误码**：1001/1002/1003（参数）、2000（业务，如用户名重复）。

> 注册成功后**不自动登录**，需前端再调登录接口。

---

### 5.2 登录 ✅

`POST /api/auth/login`

**前置：获取验证码**（`captcha.enabled=true` 时登录必须携带验证码）

`POST /api/auth/captcha`　无需 Token

请求体（可省略，默认图片验证码）：

```json
{ "type": "image" }
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | string | 否 | `image`（默认）；`sms`/`email` 为预留类型，当前返回 4033 |
| target | string | 否 | 短信/邮箱接收目标，图片验证码无需传 |

> **限流**：同一 IP 每分钟 ≤ 10 次、每小时 ≤ 100 次；同一设备每分钟 ≤ 5 次。超限返回 **HTTP 429**（`code=4600`），不返回具体触发维度，前端做按钮倒计时即可。

响应 `data`：

| 字段 | 类型 | 说明 |
|------|------|------|
| captchaId | string | 验证码唯一标识，登录时回传 |
| captchaType | string | `image` |
| imageBase64 | string | 图片 Base64，含 `data:image/png;base64,` 前缀，可直接作为 `img.src` |
| expireIn | number | 有效期（秒），默认 300 |

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "captchaId": "8f3c2a9e4b7d41c6a1f0e5d2c9b8a7f6",
    "captchaType": "image",
    "imageBase64": "data:image/png;base64,iVBORw0KGgo...",
    "expireIn": 300
  }
}
```

**请求头**：`X-Device-Type`（可选，`web`/`app`，默认 `web`）

**请求体**

| 字段 | 类型 | 必填 |
|------|------|------|
| username | string | 是 |
| password | string | 是 |
| captchaId | string | `captcha.enabled=true` 时必填 |
| captchaCode | string | `captcha.enabled=true` 时必填，忽略大小写 |

**响应 `data`（LoginResponse）**

| 字段 | 类型 | 说明 |
|------|------|------|
| token | string | Access Token（注意字段名是 `token`，不是 `accessToken`） |
| refreshToken | string | 刷新令牌，7 天 |
| username | string | 用户名 |
| nickname | string | 昵称 |
| avatar | string \| null | 头像 URL，未设置时为 `null` |
| roles | string[] | 如 `["USER"]` |
| permissions | string[] | 权限码 |
| lastLoginTime | string | `yyyy-MM-dd HH:mm:ss`，首次登录为 `null` |
| expiresAt | string | `yyyy-MM-dd HH:mm:ss`，Access Token 过期时间 |

**错误码**：4010（用户名或密码错误）、4011（禁用）、4013（锁定）、4030（验证码过期）、4031（验证码错误）、4032（未填验证码）。

> 验证码校验成功后立即失效，同一 `captchaId` 不能重复使用；连续输错 5 次验证码立即失效，需重新获取。
> **限流**：登录请求在验证码校验之前先经过第二层限流（IP 10 次/分钟、50 次/小时；设备 5 次/分钟；账号 5 次/分钟），超限返回 **HTTP 429**。详见 [第 12 章](#12-三层限流与风控前端必读)。

---

### 5.3 刷新 Token ✅

`POST /api/auth/refresh`

**请求体**：`{ "refreshToken": "xxx" }`

**响应**：与登录相同的 `LoginResponse`（新的 `token` + 新的 `refreshToken`）。

**错误码**：4012（无效/已过期/已被并发核销）、4015（用户不存在）。

> 旧 `refreshToken` 刷新后立即失效，前端必须用返回值覆盖两个 token。

---

### 5.4 登出 ✅

`POST /api/auth/logout`

- 请求头 `Authorization`：可选，传了才把 AccessToken 加入黑名单
- 请求体：`{ "refreshToken": "xxx" }`（可传 `null`）

**响应**：`data: null`

> 前端登出后清空本地 token；即使接口失败也建议本地清理。

---

### 5.5 绑定设备 ✅

`POST /api/user/devices/bind`

**请求体**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| deviceId | string | 是 | 设备 MAC（12 位十六进制，后端会统一大小写/去分隔符）；`@NotBlank` 校验，空值返回 1003 |
| bindCode | string | 是 | 设备绑定码（机身二维码，6 位）；Service 层校验 |

**响应**：`data: null`

**错误码**：1003（deviceId 为空）、4200/4204/4205/4206/4207/4209

---

### 5.6 解绑设备 ✅

`POST /api/user/devices/unbind`

**请求体**：`{ "deviceId": "A1B2C3D4E5F6" }`（`bindCode` 可忽略；`deviceId` 受 `@NotBlank` 校验）

**响应**：`data: null`

**错误码**：1003（deviceId 为空）、4209（未绑定）

---

### 5.7 我的设备列表 ✅

`GET /api/user/devices/my?pageNum=1&pageSize=10`

**响应**：`Page<DeviceInfoVO>`，`records` 元素字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | number | 主键 |
| deviceId | string | MAC |
| deviceName | string | 设备名 |
| product | string | 产品型号 |
| firmware | string | 当前固件版本 |
| location | string | 位置 |
| online | number | `1` 在线 / `0` 离线 |
| lastOnlineTime | string | ISO 时间 |
| lastOfflineTime | string | ISO 时间 |
| lastHeartbeatTime | string | 最后心跳 |
| uptime | number | 运行时长（秒） |
| capabilities | object | 能力集，JSON |
| currentState | object | 当前状态，JSON（结构随设备而定） |
| otaState | string | OTA 阶段（`accepted/downloading/...`），**本轮新增** |
| otaProgress | number | OTA 进度 0~100，**本轮新增** |
| otaVersion | string | 目标版本号，**本轮新增** |
| otaUpdateTime | string | OTA 状态更新时间，**本轮新增** |
| createTime / updateTime | string | ISO 时间 |

> 本轮已为 `DeviceInfoVO` 补齐 OTA 四个字段，列表页可直接展示升级进度。

---

### 5.8 控制设备 ✅

`POST /api/user/devices/control`

**响应**：`data` 为本次指令的 `commandId`（字符串）。

> ⚠️ **重要**：该接口返回成功仅表示"指令已受理并进入下发流程"，**不代表设备已真正执行成功**。
> 设备执行结果由设备 ACK 回执决定，前端需订阅 WebSocket `/topic/device/{deviceId}/command`
> 的 `command_result` 消息（见 6.8），或用 `GET /api/user/commands/{commandId}` 轮询兜底。

**请求体（DeviceControlRequest）**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| deviceId | string | 是 | MAC |
| action | string | 是 | 见下方取值 |
| target | string | 是 | `mos` / `led` / `servo` / `relay` / `ota` / `config` |
| channel | number | 否 | 通道号，`0` 表示全部（MOS 共 8 路，编号 1~8） |
| params | object | 是 | 如 `{"state":1}`、`{"brightness":80}`、`{"angle":90}` |

`action` 建议取值：`set` / `get` / `toggle` / `start` / `reset` / `cancel`

**响应**：`data: null`（**指令是异步的**，接口成功只代表已入库并尝试下发，最终结果需通过 WebSocket 或指令查询接口获取）

**错误码**：4200（设备不存在）、4201/4211（离线）、4210（未绑定）

> ⚠️ 后端只校验 `action`/`target` 非空，不做枚举校验；前端需按设备 `capabilities` 动态渲染可用按钮，避免下发非法组合。

---

### 5.9 检查设备是否有新固件 ✅

`GET /api/user/ota/check/{deviceId}`

**响应 `data`（OtaCheckResponse）**

| 字段 | 类型 | 说明 |
|------|------|------|
| hasNewVersion | boolean | 是否有新版本 |
| firmwareId | number | 新固件 ID |
| latestVersion | string | 最新版本号 |
| releaseNotes | string | 更新说明 |
| size | number | 固件字节数 |

**错误码**：4200、4210（未绑定）、4104（固件文件缺失）、4302（版本不兼容）

> 完整的升级流程、状态机与实时数据处理见 [第 11 章](#11-ota-升级全流程与实时进度前端必读)。

---

### 5.10 发起单设备升级 ✅

`POST /api/user/ota/start/{deviceId}`

无请求体。**响应**：`data: null`

**错误码**：4200/4201/4210/4300/4301（已在升级）/4302/4303（已最新）

> 进度获取方式（本轮已补齐，二选一）：
> 1. 轮询 `GET /api/user/ota/progress/{deviceId}`（见 8.5）；
> 2. 订阅 WebSocket `/topic/device/{deviceId}/ota`（`type = ota_progress`，见 6.8）。
>
> ⚠️ 该接口**不返回 commandId**。前端应**先订阅 WebSocket，再调用 start**；首个 `ota_progress` 或
> `GET /progress` 返回中的 `commandId` 即本次升级的指令 ID，用它匹配推送与升级记录。
> 详细时序见 [11.3](#113-触发升级推荐时序)。

---

### 5.11 删除用户 ✅（管理端）

`DELETE /api/admin/users/{id}`　需要 `user:delete`

**响应**：`data: null`（逻辑删除，用户名会被改写为 `#DEL#` 前缀）

---

### 5.12 分页查询设备 ✅（管理端）

`GET /api/admin/devices?pageNum=1&pageSize=10&keyword=xxx`　需要 `device:list`

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| pageNum | number | 否 | 默认 1 |
| pageSize | number | 否 | 默认 10 |
| keyword | string | 否 | MAC / 设备名 / 产品模糊匹配 |

**响应**：`Page<AdminDeviceVO>`（本轮已由数据库实体改为专用 VO）

`AdminDeviceVO` 字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | number | 主键 |
| deviceId | string | MAC |
| deviceName | string | 设备名 |
| product | string | 产品型号 |
| firmware | string | 当前固件版本 |
| location | string | 位置 |
| bindCode | string | 绑定码（管理端可见） |
| groupId | number | 分组 ID |
| online | boolean | 是否在线 |
| offlineReason | string | 离线原因 |
| lastOnlineTime / lastOfflineTime / lastHeartbeatTime | string | ISO 时间 |
| uptime | number | 运行时长（秒） |
| capabilities / currentState | object | JSON |
| otaState / otaProgress / otaVersion / otaUpdateTime | - | OTA 状态 |
| configVersion | number | 配置版本 |
| createTime / updateTime | string | ISO 时间 |

---

### 5.13 新增设备 ✅（管理端）

`POST /api/admin/devices`　需要 `device:create`

| 字段 | 类型 | 必填 |
|------|------|------|
| deviceId | string | 是（MAC） |
| deviceName | string | 否 |
| product | string | 否 |
| location | string | 否 |

**响应**：`data: null`　**错误码**：4204/4212

---

### 5.14 删除设备 ✅（管理端）

`DELETE /api/admin/devices/{id}`　需要 `device:delete`

**响应**：`data: null`

> 删除时会同时移除 Redis 绑定集合成员；已绑定的用户会失去该设备。

---

### 5.15 上传固件 ✅（管理端）

`POST /api/admin/ota/firmware/upload`　需要 `firmware:upload`
`Content-Type: multipart/form-data`

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | file | 是 | 必须是 `.bin`，大小受 `spring.servlet.multipart` 限制（默认 16MB/20MB） |
| version | string | 是 | 版本号（服务端只用它拼文件名，建议 `1.2.3` 这种格式） |
| product | string | 是 | 适用产品型号 |
| releaseNotes | string | 否 | 更新说明 |
| operator | string | 否 | 操作人 |

**响应 `data`（FirmwareUploadResponse）**：包含固件 ID、版本、URL、md5、sha256、大小等（以后端实际返回为准）。

**错误码**：4000/4001/4002/4100（版本重复）/4103/4105/4106/4107

---

### 5.16 固件列表 ✅（管理端）

`GET /api/admin/ota/firmware/list`　需要 `ota:list`

**响应 `data`: `FirmwareVO[]`**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | number | 固件 ID |
| version | string | 版本号 |
| product | string | 产品 |
| releaseNotes | string | 说明 |
| url | string | 下载地址 |
| md5 | string | MD5 |
| sha256 | string | SHA-256 |
| size | number | 字节 |
| sizeText | string | 已格式化（如 `1.2 MB`） |
| uploadedBy | string | 上传人 |
| uploadTime | string | ISO 时间 |
| status | number | 状态（1 启用 / 0 禁用，以后端为准） |

> 该接口**不分页**，返回全部启用固件；固件多时需后端加分页（见 8.8）。

---

### 5.17 删除固件 ✅（管理端）

`DELETE /api/admin/ota/firmware/{id}`　需要 `firmware:delete`

**响应**：`data: null`　**错误码**：4101/4104

---

### 5.18 批量下发 OTA ✅（管理端）

`POST /api/admin/ota/batch-dispatch?firmwareId=1&targetProduct=XXX&operator=admin`　需要 `ota:create`

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| firmwareId | number | 是 | 固件 ID |
| targetProduct | string | 否 | 限定产品型号；不传则按固件版本筛选 |
| operator | string | 否 | 操作人 |

**响应**：`data: number`（本次成功生成指令的设备数）

> ⚠️ 该接口**同步执行**，设备量大时响应可能较慢。本轮已接入 `DeviceOtaTask`：每次批量下发都会生成 `taskId` 与任务记录，可在管理端 `GET /api/admin/ota/tasks` 查看任务进度（见 8.8）。

---

### 5.19 死信列表 ✅（管理端）

`GET /api/admin/dead-letters?pageNum=1&pageSize=10`　需要 `ROLE_ADMIN`

**响应**：`Page<SysDeadLetter>`

| 字段 | 类型 | 说明 |
|------|------|------|
| id | number | 主键 |
| topic | string | MQTT 主题 |
| payload | string | 原始报文 |
| errorMsg | string | 异常信息 |
| isRetryable | number | 1 可重试 / 0 不可 |
| status | number | 0 未处理 / 1 已重放成功 / 2 已忽略 |
| retryCount | number | 重试次数 |
| createTime / updateTime | string | ISO 时间 |

---

### 5.20 重放死信 ✅（管理端）

`POST /api/admin/dead-letters/{id}/replay`　需要 `ROLE_ADMIN`

**响应**：`data: null`

---

## 6. WebSocket 实时推送（前端接入指南）

> 本章可独立作为前端接入规范。以下结论均按 `WebSocketConfig`、`WebSocketAuthInterceptor`、`WebSocketPushService` 当前实现逐项核对。

### 6.1 服务端能力清单（✅ 全部已实现）

| 项 | 当前实现 | 前端需要知道 |
|----|----------|--------------|
| 端点 | `/ws`，通过 `.withSockJS()` 注册 | 浏览器端**优先用 SockJS**；原生 `ws://` 直连在部分反向代理下会 404 |
| 传输协议 | STOMP 1.2 over WebSocket | 必须按 STOMP 帧发送 `CONNECT` |
| Broker | Spring `SimpleBroker`，启用 `/topic`、`/queue` | 仅内存，**不跨实例**（见 6.10 第 5 条） |
| 应用前缀 | `/app` | 后端目前**没有** `@MessageMapping`，前端**不需要发消息**，只订阅 |
| 跨域 | `cors.allowed-origins` 配置项 | 未加入白名单时握手直接被拒（HTTP 403） |
| 连接鉴权 | `CONNECT` 帧校验 `Authorization` | 见 6.5 |
| 订阅鉴权 | 仅对 `/topic/device/**` 做 "用户是否绑定该设备" 校验 | 见 6.7 |
| 心跳 | 未显式配置，使用 Spring 默认 | 客户端仍要配 `heartbeatIncoming/Outgoing` 保活 |
| 推送点 | 外设状态、传感器、告警、OTA 进度、控制指令结果 | 上下线**仍不推送**，需轮询；OTA 进度见 6.8 与第 11 章 |

### 6.2 地址推导

WebSocket 地址与 HTTP API **同源**，只换协议：

| HTTP Base URL | WebSocket 地址 |
|---------------|----------------|
| `http://localhost:8080` | `ws://localhost:8080/ws` |
| `https://iot.example.com` | `wss://iot.example.com/ws` |

> 注意：**没有** `/api` 前缀，也**没有** context-path。错误写法：`/api/ws`、`/ws/websocket`（后者是 SockJS 内部路径，不要手写）。

### 6.3 前置条件（满足这 3 条才能连上）

1. **已通过 HTTP 登录拿到 `token`**（`POST /api/auth/login`），且 token 未过期。
2. **前端域名已加入后端 `cors.allowed-origins`**，否则握手阶段就失败。
3. 安装依赖：

```bash
npm i @stomp/stompjs sockjs-client
# TypeScript 项目再加
npm i -D @types/sockjs-client
```

### 6.4 建立连接的完整步骤（7 步）

```
前端                                          后端
 1. POST /api/auth/login              ──────▶  返回 token / refreshToken
 2. new Client(...) + activate()
 3. SockJS 握手（HTTP 升级）          ──────▶  /ws  校验 Origin
 4. STOMP CONNECT 帧
    headers: Authorization: Bearer xxx ──────▶  WebSocketAuthInterceptor
                                                 ├─ 解析 JWT
                                                 ├─ loadUserByUsername
                                                 ├─ validateToken
                                                 └─ 写入 sessionAttributes(userId, isAdmin)
 5. CONNECTED 帧                     ◀──────
 6. SUBSCRIBE
    /topic/device/{mac}/state        ──────▶  校验绑定关系（bind_status=1）
                                                 ├─ 管理员：放行
                                                 └─ 普通用户：未绑定 → ERROR
 7. MESSAGE 帧                       ◀──────  设备上传 MQTT → 后端推送
```

**顺序不可颠倒**：必须先 `CONNECTED` 再 `SUBSCRIBE`；`activate()` 之后不要立刻订阅，要在 `onConnect` 回调里订阅。

### 6.5 连接参数要求（逐项）

| 参数 | 要求 | 说明 |
|------|------|------|
| `webSocketFactory` | 使用 SockJS | 与 `brokerURL` **二选一**，同时设置会冲突 |
| `connectHeaders.Authorization` | **必须** `Bearer ` + token（`Bearer` 后有 1 个空格） | 后端用 `startsWith("Bearer ")` 判断；漏空格直接报 "缺少 Authorization Token" |
| Token 位置 | 只能放 STOMP 头 | **不支持** `?token=xxx` 查询参数，也不支持 Cookie |
| `reconnectDelay` | `5000`（或设为 0 自行控制） | 内建重连不会自动刷新 token，见 6.10 |
| `heartbeatIncoming` | `10000` | 客户端 10s 收心跳，用于发现假连接 |
| `heartbeatOutgoing` | `10000` | 客户端 10s 发心跳，防止 Nginx 60s 空闲断开 |
| `connectionTimeout` | `10000` | 超时视为失败并重连 |
| `debug` | 联调时 `console.log` | 上线关闭，避免日志噪音 |
| `beforeConnect` | 可用 async 刷新 token | 每次（重）连接前确保 token 有效 |

### 6.6 最小可用代码（可直接运行）

```javascript
import { Client } from '@stomp/stompjs';
import SockJS from 'sockjs-client';

export class DeviceWsClient {
  constructor({ wsUrl, getToken, refreshToken, onState, onSensor, onAlert, onAuthFail }) {
    this.wsUrl = wsUrl;                 // 例：http://localhost:8080/ws
    this.getToken = getToken;           // () => localStorage.getItem('token')
    this.refreshToken = refreshToken;   // async () => 新 token 或 throw
    this.onState = onState;
    this.onSensor = onSensor;
    this.onAlert = onAlert;
    this.onAuthFail = onAuthFail;       // 刷新失败 → 跳登录
    this.subscriptions = new Map();     // deviceId -> [StompSubscription]
    this.topics = new Set();            // 需要订阅的 deviceId 集合
  }

  connect() {
    this.client = new Client({
      webSocketFactory: () => new SockJS(this.wsUrl),
      connectHeaders: { Authorization: 'Bearer ' + this.getToken() },
      reconnectDelay: 5000,
      heartbeatIncoming: 10000,
      heartbeatOutgoing: 10000,
      connectionTimeout: 10000,
      debug: () => {},                       // 联调时打开
      beforeConnect: async () => {
        // 每次（重）连前刷新 token，避免用过期 token 重连失败
        const token = await this.refreshToken();
        this.client.connectHeaders = { Authorization: 'Bearer ' + token };
      },
      onConnect: () => {
        // 重连成功后必须重新订阅（STOMP 不会自动恢复）
        this.topics.forEach((deviceId) => this._subscribe(deviceId));
      },
      onStompError: (frame) => {
        const msg = frame.headers['message'] || frame.body || 'WebSocket 错误';
        if (msg.includes('无权订阅')) {
          console.warn('[WS] 越权订阅，请检查绑定关系：', msg);
          return;                             // 不要重试，重连也没用
        }
        if (msg.includes('未认证') || msg.includes('Token')) {
          this.onAuthFail?.(msg);             // 跳登录页
        }
      },
      onWebSocketClose: (evt) => {
        console.warn('[WS] 连接关闭', evt.code, evt.reason);
        this.subscriptions.clear();
      }
    });
    this.client.activate();
  }

  /** 订阅某台设备的五个主题（已订阅则跳过） */
  subscribeDevice(deviceId) {
    const mac = deviceId.toUpperCase();
    this.topics.add(mac);
    if (this.client?.connected) this._subscribe(mac);
  }

  unsubscribeDevice(deviceId) {
    const mac = deviceId.toUpperCase();
    this.topics.delete(mac);
    (this.subscriptions.get(mac) || []).forEach((s) => s.unsubscribe());
    this.subscriptions.delete(mac);
  }

  disconnect() {
    this.topics.clear();
    this.subscriptions.clear();
    this.client?.deactivate();                // 登出/离开页面时调用
  }

  _subscribe(mac) {
    if (this.subscriptions.has(mac)) return;
    const base = `/topic/device/${mac}`;
    const subs = [
      this.client.subscribe(`${base}/state`, (m) => this._dispatch(mac, m)),
      this.client.subscribe(`${base}/sensor`, (m) => this._dispatch(mac, m)),
      this.client.subscribe(`${base}/alert`, (m) => this._dispatch(mac, m)),
      this.client.subscribe(`${base}/ota`, (m) => this._dispatch(mac, m)),
      this.client.subscribe(`${base}/command`, (m) => this._dispatch(mac, m))
    ];
    this.subscriptions.set(mac, subs);
    console.info('[WS] 已订阅设备', mac);
  }

  /** 统一信封分发：{type, deviceId, timestamp, data} */
  _dispatch(mac, m) {
    let msg;
    try {
      msg = JSON.parse(m.body);
    } catch (e) {
      console.warn('[WS] 非 JSON 消息', m.body);
      return;
    }
    const data = msg && msg.data !== undefined ? msg.data : msg; // 兼容旧扁平结构
    switch (msg?.type) {
      case 'state':        this.onState?.(mac, data); break;
      case 'sensor':       this.onSensor?.(mac, data); break;
      case 'alert':        this.onAlert?.(mac, data); break;
      case 'ota_progress': this.onOtaProgress?.(mac, data); break;
      case 'command_result': this.onCommandResult?.(mac, data); break;
      default:             this.onUnknown?.(mac, msg);
    }
  }
}
```

**使用（Vue / React 通用）**

```javascript
const ws = new DeviceWsClient({
  wsUrl: 'http://localhost:8080/ws',
  getToken: () => localStorage.getItem('token'),
  refreshToken: async () => {
    // 必须复用 HTTP 层的"刷新锁"，避免并发刷新把 refreshToken 用废
    const res = await http.post('/api/auth/refresh', { refreshToken: localStorage.getItem('refreshToken') });
    if (res.code !== 200) throw new Error('refresh failed');
    localStorage.setItem('token', res.data.token);
    localStorage.setItem('refreshToken', res.data.refreshToken);
    return res.data.token;
  },
  onAuthFail: () => { localStorage.clear(); location.href = '/login'; },
  onState: (mac, data) => console.log(mac, '状态变化', data),
  onSensor: (mac, list) => console.log(mac, '传感器', list),
  onAlert: (mac, alert) => console.log(mac, '告警', alert),
  onOtaProgress: (mac, progress) => console.log(mac, 'OTA 进度', progress),
  onCommandResult: (mac, result) => console.log(mac, '指令结果', result),
  onUnknown: (mac, msg) => console.warn(mac, '未知消息类型', msg)
});

ws.connect();
ws.subscribeDevice('B4BFE90CDBA1');
```

### 6.7 订阅规则与权限

**destination 格式（必须完全一致，区分大小写）**

```
/topic/device/{deviceId}/state       外设状态变化（type=state）
/topic/device/{deviceId}/sensor      传感器上报（type=sensor，data 为数组）
/topic/device/{deviceId}/alert       告警（type=alert）
/topic/device/{deviceId}/ota         OTA 进度（type=ota_progress）
/topic/device/{deviceId}/command     控制指令执行结果（type=command_result，本轮新增）
```

| 规则 | 说明 |
|------|------|
| deviceId 取值 | 用接口返回的 `deviceId`（MAC）；后端统一标准化（去分隔符、转大写）后再匹配绑定记录 |
| 管理员 | 拥有全部 `/topic/**` 订阅权限，不做设备归属校验 |
| 普通用户 | 仅允许 `/topic/device/{deviceId}/{state\|sensor\|alert\|ota\|command}`，且必须有 `device_binding.bind_status = 1` 的有效绑定，否则 ERROR |
| 主题类型校验 | 普通用户只允许 `state/sensor/alert/ota/command` 五种后缀，其它后缀视为非法地址 |
| 未认证 | 若 `CONNECT` 未通过，`SUBSCRIBE` 一律被拒 |
| 不支持通配 | 普通用户不能订阅 `/topic/device/*` 或一次性订阅多台，需逐台订阅 |
| 不支持发送 | 后端无 `@MessageMapping`，前端 `publish` 不会生效 |

> 订阅鉴权在 STOMP `SUBSCRIBE` 阶段统一处理：管理员放开全部主题，普通用户按"绑定关系 + 主题白名单"校验；非法地址与越权订阅都会收到 ERROR 帧并断开连接。

### 6.8 推送内容（✅ 已按后端实现核对，统一信封）

**所有主题共用同一信封结构**（`WebSocketMessageVO`），前端只需一层解析：

```json
{
  "type": "state | sensor | alert | ota_progress | command_result",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T10:30:00",
  "data": { }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| type | string | 消息类型，前端据此分发 |
| deviceId | string | 设备 MAC（大写） |
| timestamp | string | 推送时间（ISO-8601） |
| data | any | 业务数据，结构见下 |

#### `state` —— 外设状态变化（topic `/state`）

`data` 是扁平对象：

| 字段 | 类型 | 说明 |
|------|------|------|
| target | string | `led` / `mos` / `servo` / `relay` 等 |
| channel | number | 通道号；`null` 表示整体 |
| state | number | `1` 开 / `0` 关（具体含义按 target 而定） |

```json
{
  "type": "state",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T10:30:00",
  "data": { "target": "led", "channel": 1, "state": 1 }
}
```

#### `sensor` —— 传感器数据（topic `/sensor`）

`data` 是**数组**，元素为 `DeviceSensorRecord`：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | number | 记录 ID |
| deviceId | string | 设备 MAC |
| source | string | 数据来源 |
| slaveAddress | number | 从机地址（RS485） |
| sensorId | number | 传感器编号 |
| channel | number | 通道 |
| sensorKey | string | 传感器键（如 `temperature`） |
| sensorType | string | 类型（如 `temp`/`hum`） |
| sensorValue | number | 数值 |
| unit | string | 单位 |
| extra | object | 扩展字段 |
| sensorData | string | 原始数据串 |
| timestamp | string | 采集时间（ISO-8601） |
| createTime | string | 入库时间（ISO-8601） |

```json
{
  "type": "sensor",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T10:30:00",
  "data": [ { "deviceId": "B4BFE90CDBA1", "sensorKey": "temperature", "sensorValue": 25.3, "unit": "℃", "timestamp": "2026-11-05T10:30:00" } ]
}
```

#### `alert` —— 告警（topic `/alert`）

`data` 是单个 `DeviceAlertRecord`：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | number | 告警 ID |
| deviceId | string | 设备 MAC |
| sensorKey | string | 触发告警的传感器键 |
| alertLevel | number | 告警级别 |
| alertType | string | 告警类型 |
| message | string | 告警文案 |
| value | number | 触发值 |
| threshold | number | 阈值 |
| status | number | 状态码（0 待处理，与 `AlertStatus.PENDING` 一致） |
| handledBy / handledTime | string | 处理人 / 处理时间（推送时为 `null`） |
| timestamp / createTime | string | 触发时间 / 入库时间 |

> 告警查询与确认接口已补齐：`GET /api/user/alerts`、`POST /api/user/alerts/{id}/ack`（见 8.4）；管理端处理见 `/api/admin/alerts/{id}/status`。收到推送后前端应刷新或合并列表。

#### `ota_progress` —— OTA 实时进度（topic `/ota`）

设备每进入一个升级阶段或进度有明显变化时上报，后端落库后立即转发给订阅者。
**同一设备一次升级期间会收到多条**，`data` 始终是"最新快照"。

`data` 字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| otaState | string | `accepted/downloading/verifying/flashing/rebooting/success/failed` |
| otaStateText | string | 阶段中文文案（后端已转好，可直接展示） |
| progress | number | 0~100（后端已夹紧；`success` 强制为 `100`） |
| version | string | 目标版本号 |
| commandId | string \| null | 关联 OTA 指令 ID；设备未上报时后端会回填最近活跃指令 |
| error | string \| null | 失败原因（仅 `failed` 时通常有值，来自设备 `data.error` / `message`） |
| reportTime | string \| null | 设备上报时间（ISO-8601，来自报文顶层 `timestamp`）；为 `null` 时说明设备未带时间 |

> 外层信封的 `timestamp` 是**服务端推送时间**，`data.reportTime` 是**设备发生时间**，两者可用于判断
> "设备是否长时间没上报"。前端排序/去重请优先使用 `data.reportTime`。
> 完整状态机与处理建议见 [第 11 章](#11-ota-升级全流程与实时进度前端必读)。

```json
{
  "type": "ota_progress",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T10:30:12",
  "data": {
    "otaState": "downloading",
    "otaStateText": "下载中",
    "progress": 45,
    "version": "1.0.30",
    "commandId": "b624660c30e546efb7808b746453c4d6",
    "error": null,
    "reportTime": "2026-11-05T10:30:10"
  }
}
```

失败示例：

```json
{
  "type": "ota_progress",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T10:31:05",
  "data": {
    "otaState": "failed",
    "otaStateText": "升级失败",
    "progress": 92,
    "version": "1.0.30",
    "commandId": "b624660c30e546efb7808b746453c4d6",
    "error": "固件校验失败（sha256 不匹配）",
    "reportTime": "2026-11-05T10:31:03"
  }
}
```

> 断线期间可能丢失进度：重连后先用 `GET /api/user/ota/progress/{deviceId}` 拉一次快照，再继续接收推送。
> 当收到 `success` / `failed` 后可停止轮询。

#### `command_result` —— 控制指令执行结果（topic `/command`，本轮新增）

`data` 为 `CommandResultVO`，对应设备 ACK 回执处理后的最终状态：

| 字段 | 类型 | 说明 |
|------|------|------|
| commandId | string | 指令 ID（与 `POST /control` 返回值一致） |
| deviceId | string | 设备 MAC |
| action | string | `set/get/toggle/...` |
| target | string | `mos/led/servo/relay/ota/config` |
| channel | number | 通道号；`0` 表示全部 |
| status | number | 0 待下发 / 1 已下发 / 2 成功 / 3 失败 / 4 超时 / 5 取消 / 6 已接收 |
| statusText | string | 状态文案（可直接展示） |
| success | boolean \| null | `true` 成功；`false` 失败/超时/取消；`null` 执行中（如 OTA 已接收） |
| errorMsg | string \| null | 失败原因 |
| responsePayload | object \| null | 设备 ACK 的 `data`（如 `{"state":1,"brightness":80}`） |
| ackTime | string \| null | 设备响应时间（ISO-8601） |

**成功示例**

```json
{
  "type": "command_result",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T13:47:34",
  "data": {
    "commandId": "b624660c30e546efb7808b746453c4d6",
    "deviceId": "B4BFE90CDBA1",
    "action": "set",
    "target": "mos",
    "channel": 0,
    "status": 2,
    "statusText": "成功",
    "success": true,
    "errorMsg": null,
    "responsePayload": { "state": 1 },
    "ackTime": "2026-11-05T13:47:34"
  }
}
```

**失败示例**

```json
{
  "type": "command_result",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T13:47:34",
  "data": {
    "commandId": "b624660c30e546efb7808b746453c4d6",
    "status": 3,
    "statusText": "失败",
    "success": false,
    "errorMsg": "设备执行失败：通道无响应"
  }
}
```

**推荐交互顺序（务必按此实现）**

1. **先订阅** `/topic/device/{deviceId}/command`，再调用 `POST /api/user/devices/control`，避免极快的 ACK 丢失；
2. 调用控制接口拿到 `commandId`，先把按钮置为"下发中"；
3. 收到 `command_result` 且 `commandId` 匹配后，按 `success` 更新 UI，并可用 `responsePayload` 立即刷新外设状态；
4. 前端设置兜底超时（建议 10 秒）：仍未收到结果则轮询 `GET /api/user/commands/{commandId}`，以接口状态为准；
5. 指令若最终 `TIMEOUT(4)`，由后端定时任务落库，**不会额外推送**，需依赖第 4 步的轮询兜底。

> 说明：设备执行成功后通常还会单独上报 `/state`（`type=state`），这是更新 `current_state` 的权威来源；`command_result` 只表示"该条指令执行结果"，两者独立，前端可同时处理。
> `responsePayload` 结构由设备固件决定，前端应按 `target` 做容错展示。

> 说明：在线/离线状态暂未通过 WebSocket 推送，前端可用 5.7/8.2 的在线接口轮询。

### 6.9 错误帧对照表（⚠️ 必读）

后端抛出 `MessagingException` 后，Spring 会下发 **ERROR 帧并关闭连接**。前端按 `frame.headers.message` 匹配：

| 触发场景 | ERROR message | 前端动作 |
|----------|---------------|----------|
| CONNECT 未带 `Authorization` 或格式不是 `Bearer ` | `缺少 Authorization Token` | 检查 header；刷新 token 后重连 |
| Token 解析失败 / 过期 / 用户被删 | `认证失败，Token无效或已过期` | 刷新 token；失败则跳登录 |
| 连接未认证就订阅 | `未认证，禁止订阅` | 不应出现；说明 CONNECT 未成功 |
| 订阅未绑定的设备 | `无权订阅该设备的数据` | **不要重试**，提示"请先绑定设备" |
| 跨域未放行 | 握手 HTTP 403（无 STOMP 帧） | 联系后端加 `cors.allowed-origins` |

**注意**：ERROR 帧到达后连接即断开，`onWebSocketClose` 会紧跟触发；如果是"越权订阅"，应立即 `unsubscribeDevice` 并从待订阅集合中移除，否则重连后会再次触发。

### 6.10 保活、重连与 Token 过期

1. **心跳**：客户端 `heartbeatIncoming/Outgoing = 10000`。Nginx 默认 `proxy_read_timeout 60s`，10s 心跳可避免被断开；若前面还有网关，需允许 `Upgrade: websocket` 并放宽超时。
2. **重连退避**：建议 `1s → 2s → 5s → 10s → 30s` 封顶；`@stomp/stompjs` 内建 `reconnectDelay` 是固定间隔，需要指数退避时在 `onWebSocketClose` 里自己调整值。
3. **Token 过期**：已建立的连接**不会**因 token 过期而断开（只在 CONNECT 时校验）。但一旦重连就会失败，所以重连前必须走 `beforeConnect` 刷新。
4. **刷新失败**：`/api/auth/refresh` 返回 4012（refreshToken 失效）→ 停止重连、清空本地、跳登录，避免"无限重连"。
5. **多副本限制（重要）**：后端用的是内存 SimpleBroker。若后端部署多个实例，WebSocket 连接落在 A 实例、而 MQTT 消息在 B 实例处理，A 上的用户**收不到推送**。当前方案只适用于单实例部署；扩容需加 Redis 广播或外部 Broker Relay。
6. **页面切换**：`visibilitychange` 隐藏时可保留连接；`offline` 事件主动 `deactivate()`，`online` 时重建。
7. **多标签页**：同一浏览器多标签会各自建立连接（各自消耗一条 session）；如需限制，可用 `BroadcastChannel` 选主，只让一个标签保持连接。
8. **登出**：先 `ws.disconnect()` 再调 `/api/auth/logout`，避免连接残留。

### 6.11 调试方法

| 手段 | 用法 |
|------|------|
| Chrome DevTools | Network → 筛选 WS → 点开连接 → Messages，可看到 `CONNECT`/`CONNECTED`/`SUBSCRIBE`/`MESSAGE`/`ERROR` 原始帧 |
| `debug` 回调 | `debug: (str) => console.log('[STOMP]', str)`，联调必开 |
| 后端日志 | 搜 `WebSocket 认证成功` / `用户越权订阅被拦截`，可对照前端时间点 |
| 验证推送链路 | 用 MQTT 客户端向 `device/{mac}/sensor` 发一条报文，观察浏览器是否收到 MESSAGE |

**常见现象排查**

| 现象 | 可能原因 |
|------|----------|
| 握手 403 | 前端域名不在 `cors.allowed-origins` |
| 连上立即断开，ERROR "缺少 Authorization Token" | `Bearer` 后少空格 / header 没传 |
| CONNECTED 但没有消息 | 订阅的 MAC 与实际设备不一致（大小写/分隔符）；或设备未上线 |
| 订阅后 ERROR "无权订阅" | 当前用户未绑定该设备（管理员除外） |
| 一段时间后静默断开 | 代理空闲超时，未开心跳 |

### 6.12 前端验收清单

- [ ] 登录后 `activate()`，3 秒内收到 `CONNECTED`（Network 里可见）
- [ ] `onConnect` 中完成订阅，订阅后能收到至少一条 `state`/`sensor`
- [ ] 用未绑定账号订阅他人设备，能收到 `无权订阅该设备的数据` 且**不自动重试**
- [ ] 手动失效 token 后重连，能触发刷新；刷新失败跳登录且停止重连
- [ ] 断网 30 秒恢复后，连接自动重建且**重新订阅成功**
- [ ] 页面隐藏/恢复、多标签页表现符合预期
- [ ] 登出后连接已断开（Network 中 WS 状态为 closed）
- [ ] 解析 `state`/`sensor`/`alert` 三种结构不报错，且对未知字段容错

---

## 7. 枚举字典

### 7.1 设备在线状态 ✅

| 值 | 含义 |
|----|------|
| 1 | 在线 |
| 0 | 离线 |

### 7.2 指令状态（`device_command.status`）✅

| 值 | 常量 | 含义 |
|----|------|------|
| 0 | PENDING | 待下发 |
| 1 | SENT | 已下发 |
| 2 | SUCCESS | 成功 |
| 3 | FAILED | 失败 |
| 4 | TIMEOUT | 超时 |
| 5 | CANCELLED | 已取消 |
| 6 | ACCEPTED | 设备已受理（OTA 场景） |

> 前端统计时注意：`ACCEPTED` 属于"进行中"，不是终态。

### 7.3 OTA 阶段状态（`otaState`，字符串）✅

| 值 | 中文 | 典型进度区间 | 终态 |
|----|------|-------------|------|
| `accepted` | 已接受 | 0~5 | 否 |
| `downloading` | 下载中 | 5~80 | 否 |
| `verifying` | 校验中 | 80~90 | 否 |
| `flashing` | 写入中 | 90~98 | 否 |
| `rebooting` | 重启中 | 98~99 | 否 |
| `success` | 升级成功 | 100（后端强制） | 是 |
| `failed` | 升级失败 | 任意 | 是 |

> 进行中：`accepted/downloading/verifying/flashing/rebooting`；终态：`success/failed`。
> 状态码统一小写，设备上报大写时后端会自动归一化。中文文案也随推送返回（`otaStateText`）。

### 7.4 固件状态（`FirmwareVO.status`）⚠️

`1` 启用、`0` 禁用（以 `DeviceFirmwareUploadServiceImpl` 写入值为准，前端按数值展示即可）。

### 7.5 死信状态 ✅

| 值 | 含义 |
|----|------|
| 0 | 未处理 |
| 1 | 已重放成功 |
| 2 | 已忽略 |

### 7.6 离线原因（`offlineReason`）⚠️ 待后端确认

当前已知会出现 `MQTT_LWT`（遗嘱消息）与心跳超时原因，具体枚举未统一导出。前端请**按字符串直接展示**并预留默认文案，不要硬编码判断。

### 7.7 绑定状态 ⚠️ 内部字段

`device_binding.bind_status`：`1` 表示有效绑定（0 / 其他值前端不需要关心，接口已过滤）。

### 7.8 告警级别与状态 ✅

**告警级别 `alertLevel`**

| 值 | 含义 |
|----|------|
| 1 | 提示 |
| 2 | 一般 |
| 3 | 严重 |

**告警状态 `status`**

| 值 | 含义 | 可执行操作 |
|----|------|------------|
| 0 | 未处理 | `POST /api/user/alerts/{id}/ack`、`PUT /api/admin/alerts/{id}/status` |
| 1 | 已确认 | 管理端可改为 2 |
| 2 | 已解决 | 再次确认会幂等成功 |

> 级别与状态也可从 `GET /api/common/dictionaries` 的 `alertLevel` / `alertStatus` 获取，避免前端硬编码。

---

## 8. 本轮新增接口详情（✅ 全部已实现）

> 本章原为"未实现接口建议契约"，本轮 **8.1～8.12 全部落地**。以下路径、参数、响应字段均按当前代码核对，前端可直接联调。

### 8.1 用户中心 ✅

| 接口 | 说明 |
|------|------|
| ✅ `GET /api/user/profile` | 获取当前用户资料 |
| ✅ `PUT /api/user/profile` | 修改昵称/邮箱/手机号，返回最新资料 |
| ✅ `PUT / POST /api/user/password` | 修改密码，成功后强制下线 |
| ✅ `GET /api/user/login-logs?pageNum=&pageSize=` | 我的登录记录 |

**GET /api/user/profile → `UserProfileVO`**

| 字段 | 类型 | 说明 |
|------|------|------|
| userId | number | 用户 ID |
| username | string | 用户名 |
| nickname | string | 昵称 |
| email | string | 邮箱 |
| phone | string | 手机号 |
| avatar | string \| null | 头像 URL；未设置时 `null`（先调上传接口，再通过 PUT profile 保存） |
| status | number | 1 启用 / 0 禁用 |
| roles | string[] | 角色编码 |
| permissions | string[] | 权限码 |
| lastLoginTime | string | 上次登录时间 |
| createTime | string | 注册时间 |

**PUT /api/user/profile** 请求体 `UserProfileUpdateRequest`（均可选，传 `null` 表示不改）：

| 字段 | 校验 |
|------|------|
| nickname | ≤64 位 |
| email | 邮箱格式，≤128 位 |
| phone | `^1[3-9]\d{9}$` 或空 |
| avatar | `/files/avatar/{uuid}.jpg\|png\|webp`（来自上传接口）或空串（清除头像） |

**PUT/POST /api/user/password** 请求体 `PasswordChangeRequest`：

| 字段 | 校验 |
|------|------|
| oldPassword | 必填；与原密码不匹配返回业务异常 |
| newPassword | 8~64 位，必须同时含字母和数字；不得与原密码相同 |

> 修改成功后会将该用户所有 RefreshToken 置为 `revoked`，**前端必须清空本地 token 并跳登录页**。

**GET /api/user/login-logs → `Page<LoginLogVO>`**：`id`、`username`、`ip`、`userAgent`、`status`、`message`、`loginTime`。

---

### 8.2 用户设备 ✅

| 接口 | 说明 |
|------|------|
| ✅ `GET /api/user/devices/{deviceId}` | 设备详情（`DeviceDetailVO`） |
| ✅ `GET /api/user/devices/{deviceId}/online` | 轻量在线查询（`DeviceOnlineVO`） |
| ✅ `PUT /api/user/devices/{deviceId}` | 修改设备名/位置 |
| ✅ `GET /api/user/devices/{deviceId}/commands?status=&pageNum=&pageSize=` | 该设备指令历史 |

**`DeviceDetailVO`**

| 字段 | 类型 |
|------|------|
| id / deviceId / deviceName / product / firmware / location | - |
| online | boolean |
| offlineReason | string |
| lastOnlineTime / lastOfflineTime / lastHeartbeatTime | string |
| uptime | number |
| capabilities / currentState | object |
| configVersion | number |
| otaState / otaProgress / otaVersion / otaUpdateTime | OTA 状态 |
| bindTime | string |
| createTime | string |

**`DeviceOnlineVO`**：`deviceId`、`online`(boolean)、`lastHeartbeatTime`、`offlineReason`。

**PUT 请求体 `UserDeviceUpdateRequest`**：`deviceName`（≤64）、`location`（≤128），均可选。

> 所有用户侧设备接口都会校验"该设备当前确实绑定在当前登录用户名下"，未绑定返回 4209/4210。

---

### 8.3 指令中心 ✅

| 接口 | 说明 |
|------|------|
| ✅ `GET /api/user/commands?deviceId=&status=&pageNum=&pageSize=` | 我的指令列表 |
| ✅ `GET /api/user/commands/{commandId}` | 指令详情 |
| ✅ `POST /api/user/commands/{commandId}/cancel` | 取消未完成指令，返回 `true/false` |
| ✅ `GET /api/user/devices/{deviceId}/commands/stats` | 各状态数量 |
| ✅ `POST /api/user/devices/{deviceId}/commands/batch` | 批量控制 |

**指令对象 `DeviceCommand` 主要字段**：`id`、`commandId`、`deviceId`、`action`、`target`、`channel`、`params`、`status`、`retryCount`、`maxRetry`、`errorMsg`、`responsePayload`、`operator`、`source`、`expireTime`、`sendTime`、`ackTime`、`createTime`、`updateTime`。

`GET /api/user/commands` 的 `deviceId` 可选；**不传时返回当前用户全部已绑定设备的指令**（内部先解析绑定集合）。

取消规则：只有 `PENDING(0)` 的指令可取消；返回 `false` 表示不可取消（已下发/已终态/OTA 已受理）。

> 指令执行结果的实时通知：订阅 `/topic/device/{deviceId}/command` 的 `command_result`（见 6.8）；断线或超时场景用本组接口轮询兜底。

**`CommandStatsVO`**：`pending/sent/success/failed/timeout/cancelled/total`（均为 number）。

**批量控制** `POST /api/user/devices/{deviceId}/commands/batch`：

```json
{
  "items": [
    { "action": "set", "target": "mos", "channel": 1, "params": { "state": 1 } },
    { "action": "set", "target": "led", "channel": 1, "params": { "state": 0 } }
  ]
}
```

返回 `data` 为 `string[]`（每条指令的 `commandId`，按提交顺序）。

> 批量控制不是"设备侧一次执行"，而是后端顺序下发多条指令；任一条失败会抛业务异常并整体回滚。

---

### 8.4 传感器 / 事件 / 告警 ✅

| 接口 | 说明 |
|------|------|
| ✅ `GET /api/user/devices/{deviceId}/sensors?sensorKey=&type=&from=&to=&pageNum=&pageSize=` | 传感器历史（默认每页 20） |
| ✅ `GET /api/user/devices/{deviceId}/sensors/latest` | 各传感器最新值 |
| ✅ `GET /api/user/devices/{deviceId}/events?type=&from=&to=&pageNum=&pageSize=` | 设备事件 |
| ✅ `GET /api/user/devices/{deviceId}/states?from=&to=&pageNum=&pageSize=` | 状态变更历史 |
| ✅ `GET /api/user/alerts?deviceId=&status=&level=&from=&to=&pageNum=&pageSize=` | 我的告警列表（默认每页 10） |
| ✅ `POST /api/user/alerts/{id}/ack` | 标记已处理（status→1） |

**传感器历史**返回 `Page<DeviceSensorRecord>`：`id`、`deviceId`、`source`、`slaveAddress`、`sensorId`、`channel`、`sensorKey`、`sensorType`、`sensorValue`、`unit`、`extra`、`sensorData`、`timestamp`、`createTime`。

> `type` 与 `sensorKey` 都可作为筛选条件：`sensorKey` 精确匹配传感器键，`type` 匹配 `sensor_type`。

**最新值 `SensorLatestVO`**：`sensorKey`、`sensorType`、`sensorName`、`unit`、`value`(number)、`timestamp`。

**事件 `DeviceEventRecord`**：`id`、`deviceId`、`type`、`event`、`code`、`message`、`context`、`target`、`channel`、`triggerSource`、`payload`、`timestamp`、`createTime`。

**状态历史 `DeviceStateRecord`**：`id`、`deviceId`、`target`、`channel`、`params`(object)、`timestamp`、`createTime`。

**告警 `DeviceAlertRecord`**：`id`、`deviceId`、`sensorKey`、`alertLevel`(1/2/3)、`alertType`、`message`、`value`、`threshold`、`status`(0 未处理/1 已确认/2 已解决)、`handledBy`、`handledTime`、`timestamp`、`createTime`。

确认告警规则：
- 只有"当前用户已绑定设备"产生的告警才能确认；
- `status=2` 再次调用会**幂等成功**（不报错）；
- 确认后 `status=1`、`handledBy=当前用户`、`handledTime=当前时间`。

---

### 8.5 OTA ✅

| 接口 | 说明 |
|------|------|
| ✅ `GET /api/user/ota/progress/{deviceId}` | 进度轮询（`DeviceOtaProgressVO`） |
| ✅ `GET /api/user/ota/records?deviceId=&pageNum=&pageSize=` | 升级历史（`OtaRecordVO`） |
| ✅ `POST /api/user/ota/retry/{deviceId}` | 失败重试 |

**`DeviceOtaProgressVO`**（`GET /api/user/ota/progress/{deviceId}` 的 `data`）：

| 字段 | 类型 | 说明 |
|------|------|------|
| deviceId | string | 设备 MAC |
| otaState | string \| null | OTA 阶段（`accepted/.../failed`），无升级记录时为 `null` |
| otaStateText | string \| null | 阶段中文文案 |
| otaProgress | number \| null | 0~100 |
| otaVersion | string \| null | 目标版本号 |
| commandId | string \| null | 最近一次 OTA 指令 ID |
| commandStatus | number \| null | 指令状态（见 7.2） |
| commandStatusText | string \| null | 指令状态文案 |
| errorMsg | string \| null | 失败原因（来自 OTA 指令） |
| otaUpdateTime | string \| null | OTA 状态最后更新时间 |
| running | boolean | 是否升级进行中 |
| finished | boolean | 是否已到终态（成功/失败） |
| serverTime | string | 服务端当前时间，用于计算数据新鲜度 |

> 轮询建议：`running=true` 时每 1~2 秒拉一次；收到 `finished=true` 后停止。
> WebSocket 断线重连后先调用本接口补齐快照，再继续接收 `ota_progress`。

**`OtaRecordVO`**：`id`、`commandId`、`deviceId`、`version`、`status`(number)、`statusText`、`otaState`、`progress`、`errorMsg`、`createTime`、`sendTime`、`ackTime`。

> `records` 的 `deviceId` 为**必填**（不传返回参数错误）；记录按创建时间倒序，只返回 `target=ota` 的指令。
> `otaState` / `progress` 仅在记录版本等于设备当前 `otaVersion` 时填充（即"最近一次升级"）。

重试规则：仅当该设备最近一条 OTA 指令处于 `FAILED(3) / TIMEOUT(4) / CANCELLED(5)` 时才允许重试；否则返回业务异常（避免重复升级）。

---

### 8.6 管理端：用户管理 ✅（全部需要 ADMIN 角色）

| 接口 | 权限码 | 说明 |
|------|--------|------|
| ✅ `GET /api/admin/users?pageNum=&pageSize=&keyword=&status=&role=` | `user:list` | 用户列表 |
| ✅ `POST /api/admin/users` | `user:create` | 新增用户并分配角色 |
| ✅ `GET /api/admin/users/{id}` | `user:list` | 用户详情 |
| ✅ `PUT /api/admin/users/{id}` | `user:update` | 编辑资料 |
| ✅ `PUT /api/admin/users/{id}/status` | `user:update` | 启用/禁用 |
| ✅ `PUT /api/admin/users/{id}/roles` | `user:update` | 分配角色 |
| ✅ `GET /api/admin/users/{id}/devices?pageNum=&pageSize=` | `user:list` | 用户绑定设备 |
| ✅ `POST /api/admin/users/{id}/force-unbind` | `device:unbind` | 强制解绑 |

**列表筛选参数**：`keyword`（用户名/昵称/手机号模糊）、`status`(0/1)、`role`（角色编码，兼容旧参数名 `roleCode`）。

**`AdminUserVO`**：`id`、`username`、`nickname`、`email`、`phone`、`status`、`roles`、`lastLoginTime`、`createTime`。

**`AdminUserDetailVO`** = 上述字段 + `deviceCount`(number)、`loginCount`(number)、`permissions`(string[])、`updateTime`。

**请求体**

- `POST /api/admin/users` →

```json
{
  "username": "operator01",
  "password": "Passw0rd123",
  "nickname": "运维一号",
  "email": "ops01@example.com",
  "phone": "13800138000",
  "roleCodes": ["OPS"],
  "status": 1
}
```

  字段约束：`username` 4-32 位字母/数字/下划线；`password` 8-64 位且同时包含字母和数字；`roleCodes` 为空时默认分配 `USER`；`status` 缺省为 1。
  返回 `data` 为新用户 ID（number）。

- `PUT /{id}` → `{ nickname?, email?, phone? }`
- `PUT /{id}/status` → `{ "status": 0 | 1 }`
- `PUT /{id}/roles` → `{ "roleCodes": ["ADMIN"] }`（不能为空；会整体替换角色）
- `POST /{id}/force-unbind` → `{ "deviceId": "A1B2C3D4E5F6" }`

> 强制解绑会把绑定记录置为解绑状态，并从 Redis 绑定集合移除该 MAC，便于设备转绑其他用户。

---

### 8.7 管理端：设备管理 ✅

| 接口 | 权限码 | 说明 |
|------|--------|------|
| ✅ `GET /api/admin/devices/{id}` | `device:read` | 设备详情（`AdminDeviceVO`） |
| ✅ `PUT /api/admin/devices/{id}` | `device:update` | 编辑设备名/产品/位置 |
| ✅ `GET /api/admin/devices/{id}/bindings?pageNum=&pageSize=` | `device:read` | 绑定用户列表 |
| ✅ `POST /api/admin/devices/{id}/unbind` | `device:unbind` | 解绑指定用户 |
| ✅ `GET /api/admin/devices/online-stats`（兼容 `/stats/online`） | `device:list` | 在线统计 |
| ✅ `POST /api/admin/devices/{id}/command` | `command:send` | 管理员下发指令 |
| ✅ `GET /api/admin/devices/export?keyword=` | `device:list` | 导出 CSV |

**在线统计 `DeviceOnlineStatsVO`**：`total`、`online`、`offline`、`abnormal`（标记在线但心跳超时的设备数）。

**绑定列表 `DeviceBindingVO`**：`bindingId`、`userId`、`username`、`nickname`、`bindTime`、`bindStatus`。

**请求体**

- `PUT /{id}` → `{ deviceName?, product?, location? }`
- `POST /{id}/unbind` → `{ "userId": 12 }`
- `POST /{id}/command` →

```json
{ "action": "set", "target": "mos", "channel": 1, "params": { "state": 1 } }
```

  返回 `data` 为 `commandId`（字符串）。

**导出说明**：直接返回 `text/csv` 文件流（不是 JSON），带 UTF-8 BOM，列头为
`ID,设备MAC,设备名称,产品,固件版本,位置,绑定码,在线状态,最后在线时间,最后心跳时间,创建时间`。
前端需用 `responseType: 'blob'` 并用 `Content-Disposition: attachment;filename=devices.csv` 触发下载。

---

### 8.8 管理端：固件与 OTA 任务 ✅

| 接口 | 权限码 | 说明 |
|------|--------|------|
| ✅ `GET /api/admin/ota/firmware?pageNum=&pageSize=&product=&status=&keyword=` | `ota:list` | 固件分页 |
| ✅ `GET /api/admin/ota/firmware/{id}` | `ota:list` | 固件详情 |
| ✅ `PUT /api/admin/ota/firmware/{id}/status` | `firmware:upload` | 启用/禁用 |
| ✅ `GET /api/admin/ota/tasks?pageNum=&pageSize=&status=` | `ota:list` | 批量任务列表 |
| ✅ `GET /api/admin/ota/tasks/{id}` | `ota:list` | 任务详情 |
| ✅ `POST /api/admin/ota/tasks/{id}/cancel` | `ota:cancel` | 取消未下发子任务 |

**`FirmwareVO`**：`id`、`version`、`product`、`releaseNotes`、`url`、`md5`、`sha256`、`size`、`sizeText`、`uploadedBy`、`uploadTime`、`status`。

**`OtaTaskVO`**：`id`、`firmwareId`、`targetVersion`、`totalCount`、`successCount`、`failedCount`、`pendingCount`、`status`、`operator`、`createTime`、`updateTime`。

**`OtaTaskDetailVO`** = `OtaTaskVO` + `devices: OtaTaskDeviceVO[]`：

| 字段 | 说明 |
|------|------|
| deviceId / deviceName / firmware | 设备信息 |
| otaState / otaProgress | 设备实时 OTA 状态 |
| commandStatus / commandStatusText | 指令状态码与文案 |
| errorMsg | 失败原因 |
| updateTime | 更新时间 |

**请求体**：`PUT /firmware/{id}/status` → `{ "status": 0 | 1 }`。

**任务与指令关联方式（重要）**：`batch-dispatch` 会生成 `taskId` 并写入每条 OTA 指令的 `params.taskId`；任务详情按该 `taskId` 过滤子指令并回写统计（成功/失败/待处理）。取消任务只会把仍为 `PENDING(0)` 的子指令改为 `CANCELLED(5)`，返回取消条数。

**批量下发返回**：`data` 为本次成功生成指令的设备台数（number）。若所有设备都已有未完成 OTA 指令，返回 `0` 且**不会**创建空任务。

---

### 8.9 管理端：运维与审计 ✅

| 接口 | 权限码 | 说明 |
|------|--------|------|
| ✅ `GET /api/admin/dashboard/summary` | `device:list` | 首页概览 |
| ✅ `GET /api/admin/commands?pageNum=&pageSize=&deviceId=&status=&from=&to=` | `device:list` | 全局指令 |
| ✅ `GET /api/admin/alerts?pageNum=&pageSize=&deviceId=&status=&level=&from=&to=` | `alert:list` | 全局告警 |
| ✅ `PUT /api/admin/alerts/{id}/status` | `alert:handle` | 处理告警 |
| ✅ `GET /api/admin/audit-logs?pageNum=&pageSize=&deviceId=&operator=&source=&from=&to=` | `device:list` | 操作审计 |
| ✅ `GET /api/admin/dead-letters/{id}` | ADMIN | 死信详情 |
| ✅ `POST /api/admin/dead-letters/{id}/ignore` | ADMIN | 忽略死信 |

**`DashboardSummaryVO`**：`deviceTotal`、`onlineCount`、`offlineCount`、`todayCommandCount`、`todayFailedCount`、`failureRate`(number, 百分比两位小数)、`otaRunningCount`、`unhandledAlertCount`。

**处理告警**：`PUT /alerts/{id}/status` → `{ "status": 1 | 2 }`（1 已确认 / 2 已解决），处理人取当前登录管理员。

**审计日志说明（已知限制）**：项目暂无独立审计表，`/audit-logs` 复用 `device_command` 流水，返回 `Page<DeviceCommand>`；筛选参数中 `operator` 为操作人、`source` 为 `WEB/API/SCHEDULE/SYSTEM`。

**忽略死信**：`POST /dead-letters/{id}/ignore` 将 `status` 置为 `2`（已忽略），之后不能再重放。

---

### 8.10 通用能力 ✅

| 接口 | 说明 |
|------|------|
| ✅ `POST /api/common/upload/avatar` | 头像上传（`multipart/form-data`，字段名 `file`） |
| ✅ `GET /api/common/dictionaries` | 字典下发 |
| ✅ `GET /actuator/health` | 健康检查（免认证） |
| ✅ WebSocket 统一信封 | 已统一为 `{type, deviceId, timestamp, data}`（见 6.8） |

**头像上传限制**：≤2MB；仅 `image/jpeg` / `image/png` / `image/webp`；返回 `{ url, size, contentType }`，其中 `url` 形如 `/files/avatar/{uuid}.jpg`，可直接用于 `<img src>`。

**头像持久化流程（已补齐）：**

1. `POST /api/common/upload/avatar` 拿到 `url`；
2. 调用 `PUT /api/user/profile`，请求体带上 `{ "avatar": "<上一步的 url>" }`；
3. 后端把 URL 写入 `sys_user.avatar`，再次登录/刷新时 `LoginResponse.avatar` 与 `GET /api/user/profile` 的 `avatar` 都会返回该地址；
4. 传 `"avatar": ""` 表示清除头像；替换头像时后端会在事务提交后删除旧文件。

> `avatar` 只接受本服务上传接口返回的地址（`/files/avatar/{uuid}.jpg\|png\|webp`），传外部链接会返回参数校验错误。

**字典结构**（`data` 为对象）：

| key | 结构 |
|-----|------|
| roles | `[{code,name}]`（来自 `sys_role`） |
| userStatus | `[{value:1,label:"启用"},{value:0,label:"禁用"}]` |
| deviceOnline | `[{value:1,label:"在线"},{value:0,label:"离线"}]` |
| commandStatus | `[{value,label}]`（与 `DeviceCommandStatus` 一致） |
| otaState | `[{value:"accepted",label:"已接受"} …]` |
| alertLevel | `[{value:1,label:"提示"},{value:2,label:"一般"},{value:3,label:"严重"}]` |
| alertStatus | `[{value:0,label:"未处理"},{value:1,label:"已确认"},{value:2,label:"已解决"}]` |
| products | `string[]`（设备表去重后的产品型号） |

---

### 8.11 管理端：角色管理 ✅（全部需要 ADMIN 角色）

| 接口 | 权限码 | 说明 |
|------|--------|------|
| ✅ `GET /api/admin/roles?pageNum=&pageSize=&keyword=&status=` | `role:list` | 角色分页（编码/名称模糊） |
| ✅ `GET /api/admin/roles/all` | `role:list` | 全部角色（下拉选择） |
| ✅ `GET /api/admin/roles/{id}` | `role:list` | 角色详情（含权限） |
| ✅ `POST /api/admin/roles` | `role:create` | 新增角色 |
| ✅ `PUT /api/admin/roles/{id}` | `role:update` | 编辑角色 |
| ✅ `PUT /api/admin/roles/{id}/status` | `role:update` | 启用/禁用角色 |
| ✅ `DELETE /api/admin/roles/{id}` | `role:delete` | 删除角色 |
| ✅ `GET /api/admin/roles/{id}/permissions` | `role:list` | 查询角色权限 |
| ✅ `PUT /api/admin/roles/{id}/permissions` | `role:assign-permission` | 覆盖式分配权限 |

**`AdminRoleVO`**：`id`、`roleCode`、`roleName`、`description`、`status`、`builtIn`(1 内置/0 自定义)、`userCount`、`permissionCount`、`createTime`、`updateTime`。

**`AdminRoleDetailVO`** = 上述字段 + `permissionIds`(number[])、`permCodes`(string[])。

**请求体**

- `POST /api/admin/roles` / `PUT /api/admin/roles/{id}` →

```json
{
  "roleCode": "AUDITOR",
  "roleName": "审计员",
  "description": "只读查看设备与告警",
  "status": 1
}
```

  约束：`roleCode` 3-32 位，以大写字母开头，仅包含大写字母、数字、下划线；`roleName` 必填且 ≤64 位。
  返回 `data` 为新建角色 ID（number）。

- `PUT /api/admin/roles/{id}/status` → `{ "status": 0 | 1 }`
- `PUT /api/admin/roles/{id}/permissions` → `{ "permissionIds": [1, 2, 9] }`（传空数组表示清空）

**内置角色保护（重要）**：`builtIn=1` 的角色（ADMIN/OPS/USER）不允许删除、不允许修改 `roleCode`、不允许禁用；前端应对这些操作置灰。
删除自定义角色前需先解除该角色与用户的绑定，否则返回 `4402`。

---

### 8.12 管理端：权限管理 ✅（全部需要 ADMIN 角色）

| 接口 | 权限码 | 说明 |
|------|--------|------|
| ✅ `GET /api/admin/permissions?pageNum=&pageSize=&keyword=&permType=&resource=&status=` | `permission:list` | 权限分页 |
| ✅ `GET /api/admin/permissions/all` | `permission:list` | 全部权限（授权树/分组） |
| ✅ `GET /api/admin/permissions/{id}` | `permission:list` | 权限详情 |
| ✅ `POST /api/admin/permissions` | `permission:create` | 新增权限 |
| ✅ `PUT /api/admin/permissions/{id}` | `permission:update` | 编辑权限 |
| ✅ `PUT /api/admin/permissions/{id}/status` | `permission:update` | 启用/禁用权限 |
| ✅ `DELETE /api/admin/permissions/{id}` | `permission:delete` | 删除权限 |

**`AdminPermissionVO`**：`id`、`permCode`、`permName`、`permType`、`resource`、`action`、`description`、`status`、`roleCount`、`createTime`、`updateTime`。

**请求体**

- `POST /api/admin/permissions` / `PUT /api/admin/permissions/{id}` →

```json
{
  "permCode": "report:export",
  "permName": "导出报表",
  "permType": "API",
  "resource": "report",
  "action": "export",
  "description": "导出运营报表",
  "status": 1
}
```

  约束：`permCode` 必须符合 `resource:action` 小写格式；`permType` 取值 `MENU` / `BUTTON` / `API` / `ACTION`；`resource`、`action` 不传时自动从 `permCode` 拆分。
  返回 `data` 为新建权限 ID（number）。

- `PUT /api/admin/permissions/{id}/status` → `{ "status": 0 | 1 }`

**规则（重要）**：
- **权限编码创建后不可修改**，修改时传不同 `permCode` 会返回 `4024`。
- 权限被任一角色引用时禁止删除（`4022`），需先在角色授权中移除。
- 权限删除为逻辑删除，前端列表不再展示。

---

### 8.13 已知限制（本轮实现后仍存在）

| # | 限制 | 影响 | 前端应对 |
|---|------|------|----------|
| 1 | ~~用户资料无 `avatar` 字段~~ | ✅ 已补齐：`sys_user.avatar` 已持久化，登录与资料接口均返回 | 上传后调用 `PUT /api/user/profile` 保存 `avatar` |
| 2 | 无独立审计表 | `/audit-logs` 只能反映"指令类操作" | 页面标题注明"指令审计"，不要承诺覆盖所有操作 |
| 3 | OTA 任务统计在详情查询时回写 | 列表页统计可能滞后一次刷新 | 进入详情/刷新后为准；列表展示 `pendingCount` 仅作参考 |
| 4 | 在线/离线无 WebSocket 推送 | 状态卡片不能实时变 | 轮询 `/{deviceId}/online` 或 `/online-stats` |
| 5 | WebSocket 使用内存 Broker | 多实例部署会丢推送 | 单实例部署；扩容前接入 Redis/外部 Broker |
| 6 | 指令 `TIMEOUT(4)` 仅落库、不推送 | 设备长时间不 ACK 时前端收不到终态 | 前端 10 秒兜底超时后轮询 `GET /api/user/commands/{commandId}` |

---

## 9. 前端对接风险与待确认项

> 表中标"已解决"的项是本轮后端补齐的，前端可按新契约实现。

| # | 问题 | 状态 | 前端应对 / 建议 |
|---|------|------|-----------------|
| 1 | 业务异常返回 **HTTP 200** | 保持 | 统一拦截器判断 `code !== 200` |
| 2 | 控制指令不返回 commandId | **已解决** | `POST /control` 返回 commandId；订阅 `command_result` 获取设备执行结果，轮询为兜底 |
| 3 | `/my` 不含 OTA 字段、进度不可见 | **已解决** | `/my` 已含 OTA 四字段；进度见 `/progress` 或 WS `ota_progress` |
| 4 | 传感器/事件/告警无查询接口 | **已解决** | 使用 8.4 接口画历史曲线与告警列表 |
| 5 | `bind`/`unbind` 无 `@Valid` | **已解决** | `deviceId` 已加 `@NotBlank`；前端仍建议做 MAC 格式校验 |
| 6 | `action`/`target` 无枚举校验 | 保持 | 按 `capabilities` 渲染；维护前端白名单 |
| 7 | `GET /api/admin/devices` 返回实体 | **已解决** | 现返回 `AdminDeviceVO`，字段稳定 |
| 8 | 刷新 Token 不可并发 | 保持 | **必须加刷新锁**（见 3.3） |
| 9 | WebSocket 推送无统一信封 | **已解决** | 统一 `{type, deviceId, timestamp, data}`，见 6.8 |
| 10 | 离线原因枚举未导出 | 保持 | 字符串直出 + 默认兜底文案 |
| 11 | 固件列表不分页 | **已解决** | 新增 `/api/admin/ota/firmware` 分页；旧 `/firmware/list` 保留兼容 |
| 12 | 死信接口只用 `hasRole('ADMIN')` | 保持 | 前端菜单按角色控制即可 |
| 13 | ~~头像 URL 无法持久化~~ | **已解决** | 上传后调用 `PUT /api/user/profile` 保存 `avatar`，登录与资料接口都会返回 |
| 14 | 审计日志仅覆盖指令流水 | **已知限制** | 页面注明口径，避免误解为全量审计 |

---

## 10. 联调检查清单

### 后端需先确认
- [ ] CORS 白名单是否包含前端本地地址
- [ ] 开发环境是否启用 `dev` profile（默认 dev，注意别连到生产库）
- [ ] Knife4j 是否可访问：`/doc.html`
- [ ] `GET /actuator/health` 是否返回 `{"status":"UP"}`
- [ ] MQTT Broker 是否可连（心跳/在线状态才能在页面上体现）
- [ ] 测试账号是否有 `ADMIN` 角色与所需权限码（`user:list`、`device:list`、`ota:list` 等）

### 前端实现清单
- [ ] 统一响应拦截（`code !== 200`）
- [ ] 401 → 刷新（含刷新锁）→ 重放；4012 → 跳登录
- [ ] Token 存储与过期前 5 分钟自动刷新
- [ ] 登录失败锁定提示（4013，15 分钟）
- [ ] 设备列表/详情/控制按钮按 `capabilities` 渲染
- [ ] 控制指令后用 `commandId` 匹配 `command_result`，并以轮询为兜底
- [ ] WebSocket：CONNECT 带 `Authorization`、订阅 `state/sensor/alert/ota/command` 五个主题、断线重连后重新订阅
- [ ] 控制指令前先订阅 `/command`，用 `commandId` 匹配结果并处理失败/超时兜底
- [ ] WebSocket 消息按统一信封 `type` 分发
- [ ] 传感器历史/最新值、告警列表与确认已接入
- [ ] OTA 进度用 WS + `/progress` 双通道兜底
- [ ] 管理端菜单按 `permissions` 渲染，死信页按角色
- [ ] 设备导出使用 blob 下载（非 JSON）
- [ ] OTA 上传限制 `.bin` + 大小校验
- [ ] 分页统一 `pageNum/pageSize`，读 `records/total`

---

## 11. OTA 升级全流程与实时进度（前端必读）

### 11.1 数据流总览

```
前端                后端                      设备
 │  POST /start ──────▶ 写 device_command ──▶ MQTT device/{mac}/command (target=ota)
 │                                                │
 │                                                ├─▶ device/{mac}/ack {success:true, data:{toVersion:...}}
 │                                                │      └─▶ 指令状态 SENT → ACCEPTED（推送 command_result）
 │                                                │
 │                                                ├─▶ device/{mac}/ota_progress（多次）
 │                                                │      └─▶ 更新 device_info.ota_state/ota_progress/ota_version
 │                                                │      └─▶ 推进指令状态（ACCEPTED/SUCCESS/FAILED）
 │ ◀── WS /topic/device/{mac}/ota (ota_progress) ─┘      └─▶ 推送前端
 │
 │  GET /api/user/ota/progress/{deviceId} ─▶ device_info + 最近指令快照（轮询兜底）
```

后端职责：
- 设备上报的每个阶段都会**落库**（`device_info.ota_state / ota_progress / ota_version / ota_update_time`）；
- 同一条数据**立即**通过 WebSocket 转发，前端无需等到轮询；
- 设备未发 ACK 时，依据进度把 `device_command` 推进到 `ACCEPTED / SUCCESS / FAILED`，保证"升级记录"与"实时进度"一致。

### 11.2 状态机

```
accepted → downloading → verifying → flashing → rebooting → success
    └─────────────── 任意阶段失败 ───────────────┴─▶ failed
```

| 阶段 | 中文 | 前端建议文案 |
|------|------|-------------|
| `accepted` | 已接受 | 设备已受理升级请求 |
| `downloading` | 下载中 | 正在下载固件 |
| `verifying` | 校验中 | 正在校验固件完整性 |
| `flashing` | 写入中 | 正在写入固件，请勿断电 |
| `rebooting` | 重启中 | 设备重启中，连接可能短暂中断 |
| `success` | 升级成功 | 升级完成，版本已更新 |
| `failed` | 升级失败 | 升级失败，可查看原因后重试 |

规则（后端已实现，前端可按此展示）：
- `progress` 永远在 `0~100`；`success` 强制 `100`；
- `failed` 时 `error` 一般非空；
- 到达 `success/failed` 后，同一 `commandId` 不会回退（指令层面是"终态粘性"）；
- 命令状态 `SUCCESS/FAILED` 与 `TIMEOUT/CANCELLED` 都视为终态，前端应停止进度动画。

### 11.3 触发升级（推荐时序）

1. `GET /api/user/ota/check/{deviceId}` 判断是否有新版本（拿到 `firmwareId / latestVersion`）。
2. **先连 WebSocket**，订阅 `/topic/device/{deviceId}/ota`（强烈建议同时订阅 `/command`）。
3. 调用 `POST /api/user/ota/start/{deviceId}`。
4. 从首个 `ota_progress` 或 `GET /progress` 中拿到 `commandId`，把它作为本次升级的关联 ID。
5. 进度展示：以 WS 为主通道，`GET /progress` 为兜底（重连、页面重新打开时必须先拉一次快照）。
6. 收到 `success` / `failed` → 停止轮询，刷新设备列表（`firmware` 已由后端同步）与升级记录。

错误码速查：
- `4301` 已在升级中 → 禁止再点，按 `GET /progress` 展示当前进度；
- `4201` 设备离线 → 提示设备需在线才能升级；
- `4303` 已是最新版本 → 隐藏升级按钮；
- `4300` 触发失败 → 允许重试（`POST /api/user/ota/retry/{deviceId}`，仅当最近一次为失败/超时/取消时可用）。

### 11.4 实时数据的正确消费方式

| 要点 | 说明 |
|------|------|
| 以 `data.reportTime` 排序 | 外层 `timestamp` 是服务端推送时间，设备时间才是业务时间 |
| 同一 `commandId` 内进度不回退 | 极端情况下可对 `progress` 取 `Math.max`，避免 UI 抖动 |
| `otaState` 已归一化 | 后端统一小写；文案直接用 `otaStateText` |
| 终态停止动画 | `success/failed` 到达后停止计时器与轮询 |
| 断线补齐 | 重连后先 `GET /progress` 再继续订阅，避免中间阶段丢失 |
| 多设备 | 以 `deviceId + commandId` 为键维护各自进度，不要用全局单例 |

最小处理示例（JavaScript）：

```js
const otaStore = new Map(); // key = deviceId

function onOtaProgress(mac, data) {
  const key = mac;
  const prev = otaStore.get(key);
  let next = { ...(prev || {}), ...data, deviceId: mac };

  // 终态粘性：已成功/失败则忽略迟到的中间态
  if (prev && (prev.otaState === 'success' || prev.otaState === 'failed')) {
    return;
  }
  // 进度不回退（同一次升级）
  if (prev && prev.commandId && prev.commandId === data.commandId) {
    next.progress = Math.max(prev.progress ?? 0, data.progress ?? 0);
  }
  otaStore.set(key, next);
  renderOtaCard(next); // otaStateText + progress + error

  if (next.otaState === 'success' || next.otaState === 'failed') {
    stopPolling(mac);
    refreshDevice(mac);   // firmware / otaVersion 已更新
    refreshOtaRecords(mac);
  }
}

function onOtaPush(msg) { // msg = {type, deviceId, timestamp, data}
  if (msg.type === 'ota_progress') onOtaProgress(msg.deviceId, msg.data);
}
```

### 11.5 轮询兜底

`GET /api/user/ota/progress/{deviceId}` 返回 [8.5](#85-ota-) 中的 `DeviceOtaProgressVO`。

| 场景 | 建议 |
|------|------|
| 升级进行中 | 1~2 秒轮询一次 |
| 页面首次打开 / 重连 | 立即拉一次，恢复快照 |
| `finished=true` | 停止轮询 |
| `serverTime - otaUpdateTime > 5 分钟` 且 `running=true` | 展示"升级可能已超时"，建议用户稍后重试；后端超过 5 分钟会自动清理僵死状态 |

> 后端清理僵死状态后再次发起升级不会被 `4301` 拦截；指令超时（`TIMEOUT`）时 `device_info` 的 OTA 字段也会被清空。

### 11.6 与 `command_result` 的关系

- `ota_progress` 负责**阶段与百分比**；
- `command_result` 负责**指令最终结果**（`status=2` 成功 / `3` 失败 / `4` 超时 / `5` 取消；`6` 表示 OTA 已受理、仍在执行）。

前端建议：进度条用 `ota_progress`；"升级任务成功/失败"徽标以 `command_result` 或 `/progress.finished` 为准，二者会保持一致。

### 11.7 升级记录与重试

- `GET /api/user/ota/records?deviceId=...`：按时间倒序；`statusText`、`errorMsg` 可直接展示；
- 最近一条记录会带 `otaState/progress`（与设备当前 `otaVersion` 匹配时）；
- 重试：`POST /api/user/ota/retry/{deviceId}`，仅当最近一条为 `FAILED/TIMEOUT/CANCELLED` 时可用。

### 11.8 管理端实时查看

管理端订阅方式与用户端完全一致：管理员可订阅 `/topic/device/{任意设备}/ota`，不受绑定关系限制。
管理端批量任务（`/api/admin/ota/tasks*`）展示的是任务维度统计；单台设备的实时进度仍以 `ota_progress` 与 `/progress` 为准。

---

## 附：本轮实现结果汇总（原建议清单）

| 优先级 | 接口 | 状态 |
|--------|------|------|
| **P0** | `GET /api/user/profile` | ✅ 已实现 |
| **P0** | 设备详情（含 OTA 字段） | ✅ 已实现 |
| **P0** | 指令列表 / 指令详情 | ✅ 已实现 |
| **P0** | 传感器最新值 + 历史 | ✅ 已实现 |
| **P0** | 告警列表 + 标记处理 | ✅ 已实现 |
| **P0** | 管理端用户列表/详情/启停/改角色 | ✅ 已实现 |
| **P0** | 管理端设备详情/编辑/绑定查询 | ✅ 已实现 |
| **P1** | 指令取消、指令统计、批量控制 | ✅ 已实现 |
| **P0** | OTA 进度轮询、升级记录、重试 | ✅ 已实现（并新增 WS 推送） |
| **P1** | OTA 任务列表/详情/取消 | ✅ 已实现 |
| **P1** | 全局指令/告警查询、审计日志 | ✅ 已实现 |
| **P2** | 字典、头像上传、健康检查、WebSocket 统一信封 | ✅ 已实现 |

> 本轮共新增 **52 个接口**，后端已通过 `mvnw compile` 编译验证；文档与实际路径已逐项核对。

---

## 12. 三层限流与风控（前端必读）

> 服务端已实现三层独立限流，各层互不替代。所有超限响应均为 **HTTP 429**，响应体仍是统一 `ApiResponse`；前端需同时判断 HTTP 状态码与 `code`。

### 12.1 设备指纹 `X-Device-Id`

- 前端首次访问时生成稳定 UUID，持久化到 `localStorage`，之后所有 `/api/auth/captcha`、`/api/auth/login` 请求都带上 `X-Device-Id`。
- 未携带时后端降级用客户端 IP 作为设备标识，设备维度阈值会与 IP 维度叠加，更严格。
- 设备指纹仅用于限流，不参与身份认证。

### 12.2 第一层：验证码获取限流

接口：`POST /api/auth/captcha`

| 维度 | 阈值 | 超限动作 |
|------|------|----------|
| 同一 IP | 每分钟 ≤ 10 次 | HTTP 429 + `4600` |
| 同一 IP | 每小时 ≤ 100 次 | HTTP 429 + `4600` |
| 同一设备指纹 | 每分钟 ≤ 5 次 | HTTP 429 + `4600` |

> 超限不返回空图、不暴露具体维度；前端收到 429 后停止自动刷新并倒计时。

### 12.3 第二层：登录请求限流（验证码校验之前）

接口：`POST /api/auth/login`

| 维度 | 阈值 | 触发动作 | 响应 |
|------|------|----------|------|
| 同一 IP | 每分钟 > 10 次 | 临时封 IP 15 分钟 | 429 + `4600`；再次请求返回 429 + `4602` |
| 同一 IP | 每小时 > 50 次 | 升级人机验证 | 429 + `4601` |
| 同一设备指纹 | 每分钟 > 5 次 | 升级人机验证 | 429 + `4601` |
| 同一账号 | 每分钟 > 5 次 | 仅频率限制，不锁定账号 | 429 + `4600` |

> 本层发生在验证码校验之前，即使验证码正确也会被拦截；超限不写明细日志。

### 12.4 第三层：失败计数与风控升级

| 失败类型 | 计数维度 | 触发动作 |
|----------|----------|----------|
| 验证码错误 / 已过期 | IP、设备 | 1 小时内累计 20 次 → `4601` 强制人机验证；累计 50 次 → 临时封 IP 15 分钟 |
| 账号不存在 | IP、设备 | 同验证码错误，防用户枚举 |
| 密码错误 | 账号 | 5 次 → 锁定 15 分钟；10 次 → 锁定 1 小时 |
| 验证码错误 | 账号 | **不计入**，不触发账号锁定 |

关键区别：
- 验证码错误是"人机识别失败"，风险信号归属 IP/设备，不归属账号；
- 密码错误才是"身份认证失败"，按账号计数并锁定；
- 账号锁定返回 `4013`，`message` 中包含剩余分钟数；登录成功后账号失败计数自动清零；
- IP/设备风控计数不会因某次成功登录而清零。

### 12.5 前端处理建议

| HTTP 状态 | code | 建议处理 |
|-----------|------|----------|
| 429 | `4600` | 按钮倒计时（60 秒），提示"请求过于频繁，请稍后再试" |
| 429 | `4601` | 展示滑块/行为验证组件（后端已预留标记）；暂未接入时提示稍后重试 |
| 429 | `4602` | 提示"当前网络访问受限，请稍后再试"，不要提示"被封 IP" |
| 200 | `4013` | 账号锁定，直接展示 `message` 中的剩余分钟数 |
| 200 | `4030/4031` | 验证码失效或错误，自动刷新验证码图片 |

> 建议前端在登录、获取验证码请求上统一封装 429 处理，避免每个页面重复实现。
