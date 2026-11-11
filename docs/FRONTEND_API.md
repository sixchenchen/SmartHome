# WM_LAOHUA 前后端对接文档

> 文档版本：v1.4　最近核对：2026-11-11
> 适用代码：当前工作区后端实现；工程版本为 `0.0.1-SNAPSHOT`。
> 适用对象：前端开发、后端开发、运维部署及设备固件开发人员。

## 目录

1. [文档说明](#1-文档说明)
2. [接入准备](#2-接入准备)
3. [统一响应结构与错误码体系](#3-统一响应结构与错误码体系)
4. [认证与权限体系](#4-认证与权限体系)
5. [限流与风控体系](#5-限流与风控体系)
6. [接口总览](#6-接口总览)
7. [接口详细契约](#7-接口详细契约)
8. [WebSocket STOMP 实时推送](#8-websocket-stomp-实时推送)
9. [OTA 升级完整业务流程与状态机](#9-ota-升级完整业务流程与状态机)
10. [枚举与字典说明](#10-枚举与字典说明)
11. [系统已知限制与注意事项](#11-系统已知限制与注意事项)
12. [联调与验收 Checklist](#12-联调与验收-checklist)
13. [数据库核心表简要说明](#13-数据库核心表简要说明)
14. [后端配置文件说明](#14-后端配置文件说明)
15. [部署与 Nginx 配置要求](#15-部署与-nginx-配置要求)
16. [常见故障排查指南](#16-常见故障排查指南)

---

## 1. 文档说明

本文档描述 WM_LAOHUA 当前后端对外 HTTP API、WebSocket STOMP、MQTT 设备报文、OTA、鉴权与部署对接规则。契约以当前 Controller、DTO/VO、Security 配置、MQTT Handler、配置文件和 SQL 为准。

| 标记 | 含义 |
|---|---|
| ✅ | 当前源码中已实现，可按契约联调 |
| ⚠️ | 实现存在限制、边界条件或与旧文档有差异 |
| **后端强制** | 服务端实际执行的校验；前端不能替代 |
| **前端处理** | UI、请求重试、刷新锁、展示或轮询逻辑 |
| **设备端契约** | 固件与 MQTT Broker/后端之间必须一致的主题和报文 |

### 更新记录

| 版本 | 更新内容 |
|---|---|
| v1.4 | 按当前实现重整接口目录；核对错误码、RBAC、三层限流、WebSocket、OTA、数据库及部署约束；补充勘误与故障定位说明 |

> ⚠️ **勘误：原文档称“原有 20 + 新增 52 个接口”，但新增接口清单编号实际列到 53，其中验证码和健康检查也被列入清单。**本版按实际路由逐项列出，不以该数字限制接口范围；验收时应以本版路由和 Knife4j/Controller 为准。

---

## 2. 接入准备

### 2.1 服务地址与接口文档

| 环境 | Base URL | 说明 |
|---|---|---|
| 本地开发 | `http://localhost:8080` | 默认 `server.port=8080` |
| 生产 | 由运维提供 | 使用 HTTPS 时前端请求 HTTPS，WebSocket 使用 WSS |

项目未配置全局 `server.servlet.context-path`；`/api` 是各 Controller 自身路由前缀，不要额外重复添加 context path。

- Knife4j：`http://localhost:8080/doc.html`（开发环境）。
- OpenAPI JSON：`/v3/api-docs`（非生产 profile）。
- 健康检查：`GET /actuator/health`，匿名可访问，返回简要健康状态。
- 生产默认关闭 Knife4j、Springdoc API Docs 和 Swagger UI。

### 2.2 公共请求头

| Header | 适用范围 | 说明 |
|---|---|---|
| `Authorization` | 除登录、注册、刷新外的认证接口 | 值为 Bearer、一个空格和 AccessToken |
| `Content-Type` | 按请求类型 | JSON 使用 `application/json`；文件上传使用 `multipart/form-data` |
| `X-Device-Type` | 登录可选 | `web`、`app`、`mini` 等客户端标识；不传默认 `web`，写入 RefreshToken 记录 |
| `X-Device-Id` | 验证码、登录建议携带 | 前端生成并稳定持久化的设备指纹，仅用于限流，不是认证凭据 |

### 2.3 时间、时区与分页

- 服务端 Jackson 时区：`Asia/Shanghai`。
- 多数 `LocalDateTime` 字段序列化为 ISO-8601 字符串，例如 `2026-11-04T10:30:00`。
- 登录响应的 `lastLoginTime`、`expiresAt` 为 `yyyy-MM-dd HH:mm:ss` 格式。
- 分页参数为 `pageNum`、`pageSize`，通常默认 `1`、`10`；个别接口默认值不同，以接口说明为准。
- MyBatis-Plus `Page` 常见字段：`records`、`total`、`size`、`current`、`pages`。列表取 `data.records`，总数取 `data.total`。

### 2.4 CORS 跨域

运维通过 `cors.allowed-origins` 配置精确的前端 Origin，包含协议、域名和端口，例如 `http://localhost:5173`。浏览器预检通过后才能发送跨域请求。

> ⚠️ **风险提示：当前 `CorsConfig` 的允许请求头列表没有 `X-Device-Id`（也没有 `X-Device-Type`）。**若浏览器跨域请求携带这些头，预检可能返回 403。部署前端风控功能时，后端必须把实际使用的自定义 Header 加入 CORS 允许列表；仅设置 `cors.allowed-origins` 不能解决 Header 未放行问题。此项是当前源码限制，不是前端可绕过的校验。

---

## 3. 统一响应结构与错误码体系

### 3.1 统一 JSON 响应

大多数业务接口响应采用 `ApiResponse<T>`：

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2026-11-04T10:30:00"
}
```

| 字段 | 类型 | 说明 |
|---|---|---|
| `code` | number | 业务码；`200` 表示业务成功 |
| `message` | string | 状态或错误说明 |
| `data` | object / array / primitive / null | 业务数据 |
| `timestamp` | string | 服务端响应时间 |

分页数据通常放在 `data` 中；CSV 导出和部分文件响应是原始文件流，不使用 JSON 信封。

### 3.2 HTTP 状态码与业务码

| 场景 | HTTP 状态 | 业务 `code` | 处理要求 |
|---|---:|---:|---|
| 正常业务响应 | 200 | 200 | 按 `data` 处理 |
| 参数、业务校验失败 | 通常 200 | 1xxx/2xxx/4xxx | 检查响应体 `code`，不能仅按 HTTP 状态判断 |
| 未认证 / AccessToken 无效 | 401 | 通常 401 | 按令牌策略刷新或跳转登录 |
| 方法权限不足 | 403 | 401（`FAIL`） | 展示无权限，不应自动重试 |
| 限流 | 429 | 4600/4601/4602 | 按限流原因提示、等待或进入人机校验流程 |
| 资源不存在 | 404 | 404 | 提示资源不存在 |
| 未处理服务异常 | 通常 500 | 5000 等 | 记录请求上下文并联系运维 |

> ⚠️ **风险提示：业务异常常以 HTTP 200 返回。**前端响应拦截器必须判断 `res.code === 200`；仅判断 HTTP 2xx 会把业务失败当作成功。另一方面，401/403/429 必须同时处理 HTTP 状态和响应体业务码。

### 3.3 完整业务错误码表

表中触发条件按 `ErrorCode`、`GlobalExceptionHandler` 及调用该错误码的业务服务整理。参数错误的具体字段以对应 DTO/校验注解为准。

| code | message | 后端触发条件 | 前端建议 |
|---:|---|---|---|
| 200 | success | 业务处理成功 | 正常处理 `data` |
| 401 | fail | 通用认证失败或方法授权失败时的统一失败码 | 结合 HTTP 401/403 及 `message` 判断 |
| 404 | 资源不存在 | 请求资源不存在 / 静态资源路由未命中 | 提示并刷新资源 |
| 1000 | 参数错误 | 非法参数或被全局处理的参数异常 | 标记表单错误 |
| 1001 | 缺少必要参数 | 必填请求参数缺失 | 补齐参数 |
| 1002 | 参数值非法 | DTO/业务字段值不符合约束 | 修正字段 |
| 1003 | 参数不能为空 | 必填字段为空，如设备绑定的空 `deviceId` | 校验输入 |
| 1010 | 密码不能为空 | 密码字段为空 | 提示输入密码 |
| 1011 | 密码长度不能少于6位 | 通用密码长度校验不通过；注册/改密 DTO 还可能要求 8–64 位 | 以前端提示为辅，后端校验为准 |
| 2000 | 业务异常 | 无更具体业务码的业务规则拒绝 | 展示 `message` |
| 4000 | 文件为空 | 上传文件为空 | 选择文件 |
| 4001 | 文件超过大小限制 | Multipart 上传超出配置限制 | 提示文件大小限制 |
| 4002 | 文件格式错误 | 文件类型/扩展名不符合接口要求 | 选择支持格式 |
| 4003 | 文件上传失败 | 上传/写文件失败 | 提示重试并检查服务端 |
| 4004 | 文件不存在 | 请求引用的上传文件不存在 | 刷新或重新上传 |
| 4010 | 用户名或密码错误 | 登录凭据认证失败 | 提示凭据错误 |
| 4011 | 账号已禁用，请联系管理员 | 用户账号状态为禁用 | 联系管理员，不要自动重试 |
| 4012 | RefreshToken 无效或已过期，请重新登录 | RefreshToken 不存在、过期、已撤销或已被并发消费 | 清除本地令牌并重新登录 |
| 4013 | 账号已锁定 | 账号密码失败计数触发锁定 | 展示服务端 message 中剩余时间 |
| 4014 | 未登录或 token 已过期 | HTTP API AccessToken 缺失、无效或过期 | 尝试单次刷新；失败后跳登录 |
| 4015 | 用户不存在 | RefreshToken 对应的用户已不存在 | 清除令牌并重新登录 |
| 4020 | 权限不存在 | 管理端引用的权限记录不存在 | 刷新权限数据 |
| 4021 | 权限编码已存在 | 创建重复权限码 | 修改权限码 |
| 4022 | 权限已被角色引用，无法删除 | 删除仍被角色关联的权限 | 先解除角色授权 |
| 4023 | 权限类型非法 | `permType` 非 `MENU/BUTTON/API/ACTION` | 使用允许值 |
| 4024 | 权限编码不允许修改 | 更新时尝试修改既有 `permCode` | 编码不可编辑 |
| 4030 | 验证码已过期，请重新获取 | 验证码不存在或过期 | 重新获取验证码 |
| 4031 | 验证码错误 | 验证码内容不匹配 | 提示并刷新验证码 |
| 4032 | 请输入验证码 | 启用验证码时缺少验证码参数 | 补齐验证码 |
| 4033 | 暂不支持该验证码类型 | 请求当前未支持的短信/邮件验证码类型 | 使用 `image` |
| 4034 | 验证码生成失败 | 图形验证码生成失败 | 提示重试 |
| 4100 | 固件版本已存在 | 同产品固件版本重复 | 修改版本或产品 |
| 4101 | 固件不存在 | 固件 ID 无对应记录 | 刷新固件列表 |
| 4102 | 固件已禁用 | 使用禁用固件 | 选择启用固件 |
| 4103 | 固件文件超过大小限制 | 固件超过固件上传业务限制 | 降低文件大小 |
| 4104 | 固件文件不存在 | 固件记录引用的文件路径不可用 | 联系运维检查文件存储 |
| 4105 | 版本号不能为空 | 上传固件缺少版本号 | 填写版本号 |
| 4106 | 文件格式必须是 .bin | 固件扩展名不为 `.bin` | 仅选择 `.bin` |
| 4107 | 计算文件哈希失败 | 服务端计算固件摘要失败 | 联系运维检查文件读写 |
| 4200 | 设备不存在 | 设备记录不存在 | 刷新设备列表 |
| 4201 | 设备当前为离线状态，请检查电源后重试 | 需在线的控制/OTA 操作遇到离线设备 | 展示离线状态并轮询 |
| 4202 | 设备ID为空 | 服务端业务层收到空设备 ID | 补齐设备 ID |
| 4203 | 设备ID格式错误 | 设备 ID 格式不符合业务约束 | 校验设备 ID |
| 4204 | MAC 格式错误 | MAC 地址格式不符合要求 | 使用 12 位十六进制 MAC |
| 4205 | 设备绑定码错误，请扫描设备机身上的二维码 | 绑定码不匹配 | 重新扫描机身二维码 |
| 4206 | 您已经绑定了该设备 | 当前用户重复绑定同一设备 | 刷新设备列表 |
| 4207 | 该设备已被其他用户绑定 | 设备已被其他账号有效绑定 | 联系设备所有者/管理员 |
| 4208 | 该设备已被绑定，请刷新重试 | 并发绑定导致唯一约束冲突 | 刷新后再操作 |
| 4209 | 您尚未绑定该设备，或已被解绑 | 用户设备归属关系无效 | 刷新绑定列表 |
| 4210 | 您未绑定该设备，无权操作 | 当前用户不拥有目标设备 | 禁止继续操作 |
| 4211 | 设备心跳超时或网络异常，请稍后重试 | 设备心跳/网络状态不满足业务要求 | 等待后重试或检查设备网络 |
| 4212 | 设备MAC地址已存在 | 管理端新增重复 MAC | 使用未登记设备 |
| 4300 | OTA 触发失败 | 创建/触发升级指令失败 | 查询进度后谨慎重试 |
| 4301 | OTA 正在进行中 | 设备已有运行中的 OTA 状态或任务 | 展示当前进度，不重复启动 |
| 4302 | OTA 版本不兼容 | 固件产品或版本不适用于目标设备 | 选择兼容固件 |
| 4303 | 当前已是最新版本，无需升级 | 当前固件已是最新版本 | 隐藏/禁用升级入口 |
| 4400 | 角色不存在 | 角色 ID 无对应记录 | 刷新角色列表 |
| 4401 | 角色编码已存在 | 创建重复角色编码 | 修改编码 |
| 4402 | 角色已分配给用户，无法删除 | 删除仍分配给用户的角色 | 先解除用户角色关系 |
| 4403 | 内置角色不允许该操作 | 对 `builtIn=1` 角色执行受保护操作 | 禁用对应 UI 操作 |
| 4404 | 角色已禁用 | 使用或分配禁用角色 | 选择启用角色 |
| 4500 | 用户名已存在 | 注册或管理端新增重复用户名 | 修改用户名 |
| 4501 | 至少需要分配一个角色 | 用户角色更新结果为空 | 至少分配一个角色 |
| 4502 | 用户状态非法 | 用户状态值不在允许范围 | 使用接口允许状态 |
| 4600 | 请求过于频繁，请稍后再试 | 验证码/登录请求超过频率限制 | 等待后重试 |
| 4601 | 请求过于频繁，请完成人机验证 | IP/设备失败计数触发风控升级 | 当前无实际滑块校验契约，按提示等待或联系后端 |
| 4602 | 当前网络访问受限，请稍后再试 | IP 临时封锁期间继续请求 | 停止请求并等待封锁到期 |
| 5000 | 系统异常 | 未分类的服务端异常 | 提示稍后重试并记录请求时间 |
| 5001 | 数据库异常 | 数据库访问异常映射 | 联系运维 |
| 5002 | 系统配置缺失 | 必需配置缺失 | 联系运维补齐配置 |
| 5003 | 网络异常 | 后端依赖或网络访问异常映射 | 检查网络并重试 |

> 说明：有些错误码在 `ErrorCode` 中定义，但并非每个 Controller 都会主动返回。表格中的“触发条件”描述通用业务含义，不保证所有底层异常都映射到同一业务码。

---

## 4. 认证与权限体系

### 4.1 RBAC 模型与角色

授权关系：`sys_user` → `sys_role_info` → `sys_role` → `sys_role_permission` → `sys_permission.perm_code`。登录响应包含 `roles` 与 `permissions`，供前端控制菜单和按钮。

| 角色 | 用途 | 约束 |
|---|---|---|
| `ADMIN` | 系统管理 | 内置角色，不允许删除、改角色编码或禁用 |
| `OPS` | 运维管理 | 内置角色；仅能访问其被分配角色/权限允许的管理操作 |
| `USER` | 普通用户 | 注册默认角色；用户端设备操作受设备绑定归属检查 |

上述角色 SQL 中标记 `built_in=1`。管理端路径 `/api/admin/**` 首先要求 `ADMIN` 或 `OPS`，方法上的 `@PreAuthorize` 再检查具体权限码；部分接口只允许 `ADMIN`。

当前常见权限码：

```text
user:list  user:create  user:update  user:delete
role:list  role:create  role:update  role:delete  role:assign-permission
permission:list  permission:create  permission:update  permission:delete
device:list  device:read  device:create  device:update  device:delete  device:unbind
command:send
firmware:upload  firmware:delete  ota:list  ota:create  ota:cancel
alert:list  alert:handle  system:config
```

### 4.2 后端鉴权与前端 UI 边界

- **后端强制鉴权：**Spring Security JWT Filter、`/api/admin/**` 角色限制、方法级 `@PreAuthorize` 权限码校验、用户设备绑定归属校验、STOMP 连接和订阅鉴权。
- **前端 UI：**根据 `roles`、`permissions` 隐藏菜单/按钮；依据设备 `capabilities` 展示可用操作；这些措施不构成安全边界。
- **后端兜底：**客户端即使绕过 UI 直接请求接口，后端仍必须校验身份、权限、设备归属及业务状态。

> ⚠️ **风险提示：前端权限只用于 UI 控制。**用户端设备操作必须在服务端确认当前用户与设备存在有效绑定；不得以客户端传入 `deviceId` 作为所有权证明。管理员 WebSocket 全量订阅权限也不代表其拥有所有 HTTP 方法权限。

### 4.3 AccessToken / RefreshToken

| 项 | 机制 |
|---|---|
| AccessToken | 登录响应字段名为 `token`；HTTP 请求头 `Authorization` 的值为 Bearer、空格和 `token`；默认过期时间 24 小时 |
| RefreshToken | 登录响应字段 `refreshToken`；有效期 7 天；数据库保存其 SHA-256 哈希和 `deviceType` |
| 旋转刷新 | `/api/auth/refresh` 原子消费旧 RefreshToken 后返回一组新的 `token` 与 `refreshToken` |
| 撤销 | 登出可将 AccessToken 的 JTI 加入黑名单并撤销请求中的 RefreshToken；改密会撤销该用户的 RefreshToken |

### 4.4 登录、刷新、登出流程

```text
获取验证码（captcha.enabled=true）
  → POST /api/auth/login
  → 保存 token、refreshToken、roles、permissions、expiresAt
  → HTTP 请求携带 Authorization Header（认证方案 + 空格 + token）
  → AccessToken 过期/4014：单次刷新锁 → POST /api/auth/refresh
  → 成功：原子替换两个 Token 并重放等待请求
  → 失败/4012：清理本地凭据并跳转登录
  → 登出：断开 WebSocket → POST /api/auth/logout → 清理本地凭据
```

登出请求头可选；若带有效 AccessToken，服务端尝试将其加入黑名单。请求体可以传 `{"refreshToken":"..."}`，也可以为空。前端即使登出请求失败，也应清除本地令牌。

### 4.5 并发刷新锁

> ⚠️ **风险提示：同一个 RefreshToken 只能原子消费一次。**若多个 API 请求同时遇到 401 并并发刷新，只有一个刷新可成功，其余请求将收到 `4012`，且原 RefreshToken 已失效。

**前端必须**实现单飞刷新锁：同时发生的 401 请求共用一个刷新 Promise；其他请求等待刷新完成；成功后替换 AccessToken 和 RefreshToken 并重放请求；失败时停止重试、清理凭据并跳登录。WebSocket 重连刷新也应复用同一刷新锁。

### 4.6 登录失败锁定

密码错误按用户名维度计数，失败窗口为 1 小时：

| 密码失败次数 | 后端动作 |
|---:|---|
| 5 次 | 锁定 15 分钟 |
| 10 次 | 锁定 1 小时，并清理失败计数 |

成功登录会清除账号失败计数和锁定记录。验证码错误不计入密码错误账号锁定；账号不存在按 IP/设备失败计数，降低用户枚举风险。锁定返回 `4013`，message 可包含剩余等待分钟数。

### 4.7 权限校验规则

1. `/api/admin/**` 要求 `ADMIN` 或 `OPS` 角色。
2. 管理 Controller 方法继续以 `@PreAuthorize` 检查细粒度权限码。
3. 用户侧设备 API 要求已登录，并由后端校验目标设备当前绑定关系。
4. 死信管理接口使用 `hasRole('ADMIN')`；角色和权限管理接口另有对应 `role:*` / `permission:*` 权限码。
5. 用户角色/权限变化后建议重新登录以获取最新的登录权限快照。

---

## 5. 限流与风控体系

所有限流异常由后端以 HTTP `429` 返回统一 `ApiResponse`。前端必须同时读取 HTTP 状态与业务码。

### 5.1 `X-Device-Id` 设备指纹

- 前端首次访问生成 UUID，持久化并在验证码、登录请求中重复使用。
- 后端用它进行设备维度限流，不将其作为身份认证信息。
- 未携带时后端降级使用客户端 IP；IP 与设备计数可能叠加。
- Header 长度上限由后端常量限制为 128。

### 5.2 第一层：验证码接口限流

接口：`POST /api/auth/captcha`

| 维度 | 阈值 | 超限 |
|---|---:|---|
| 同一 IP | 每分钟 10 次 | HTTP 429 + `4600` |
| 同一 IP | 每小时 100 次 | HTTP 429 + `4600` |
| 同一设备指纹 | 每分钟 5 次 | HTTP 429 + `4600` |

超限时后端不提供可用于绕过限流的维度细节。前端应停止自动刷新验证码并进行等待倒计时。

### 5.3 第二层：登录请求限流

限流发生在登录验证码校验之前。

| 维度 | 阈值/动作 | 响应 |
|---|---|---|
| IP | 每分钟超过 10 次，临时封锁 15 分钟 | 首次超限 `4600`；封锁中 `4602` |
| IP | 每小时超过 50 次 | `4601` 人机验证风控标记 |
| 设备指纹 | 每分钟超过 5 次 | `4601` |
| 账号 | 每分钟超过 5 次，仅做频率限制 | `4600` |

### 5.4 第三层：失败计数与风控升级

| 失败类型 | 计数维度 | 后端升级动作 |
|---|---|---|
| 验证码错误或过期 | IP、设备；1 小时窗口 | 达 20 次返回 `4601`；达 50 次临时封 IP 15 分钟 |
| 账号不存在 | IP、设备 | 计入匿名失败计数，避免账号枚举 |
| 密码错误 | 账号 | 5 次锁定 15 分钟；10 次锁定 1 小时 |
| 验证码错误 | 不计入密码失败账号计数 | 不触发账号密码锁定 |

> ⚠️ **风险提示：`4601` 代表后端风控要求，不等于已有可完成挑战的滑块接口。**当前验证码接口只支持图片验证码；前端没有可提交的人机验证凭据契约时，应提示稍后重试并由产品/后端另行确认，不能伪造字段提交。

### 5.5 前后端处理边界

| HTTP / code | 后端含义 | 前端处理 |
|---|---|---|
| 429 / `4600` | 当前频率限制 | 停止连续请求，做合理倒计时后重试 |
| 429 / `4601` | 需要人机验证的风控升级 | 显示风控提示；当前没有可用 challenge 提交 API |
| 429 / `4602` | IP 网络访问受限 | 停止请求，提示稍后重试，不自动轮询 |
| 200 / `4013` | 账号被锁定 | 展示服务端 message 与剩余时间 |
| 200 / `4030`、`4031` | 验证码过期/错误 | 重新获取图片验证码 |

前端 UI 可以避免误触和高频请求；限流计数、锁定、封 IP 和业务拒绝均由后端强制执行。

---

## 6. 接口总览

鉴权简写：**匿名**表示无需 AccessToken；**登录**表示需要有效 AccessToken；**归属**表示登录外还需要服务端设备绑定/资源归属检查；**角色+权限码**表示同时满足管理路径角色和方法权限；**ADMIN**表示仅管理员角色。

### 6.1 认证与用户端接口

| 模块 | 方法 | URL | 鉴权 |
|---|---|---|---|
| 认证 | POST | `/api/auth/register` | 匿名 |
| 认证 | POST | `/api/auth/login` | 匿名 |
| 认证 | POST | `/api/auth/refresh` | 匿名 |
| 认证 | POST | `/api/auth/logout` | AccessToken 可选；可撤销 RefreshToken |
| 验证码 | POST | `/api/auth/captcha` | 匿名 |
| 用户中心 | GET / PUT | `/api/user/profile` | 登录 |
| 用户中心 | PUT / POST | `/api/user/password` | 登录 |
| 用户中心 | GET | `/api/user/login-logs` | 登录 |
| 用户设备 | POST | `/api/user/devices/bind`、`/unbind` | 登录 |
| 用户设备 | GET | `/api/user/devices/my` | 登录 |
| 用户设备 | GET / PUT | `/api/user/devices/{deviceId}` | 登录 + 归属 |
| 用户设备 | GET | `/api/user/devices/{deviceId}/online` | 登录 + 归属 |
| 用户设备 | POST | `/api/user/devices/control` | 登录 + 归属 |
| 指令 | GET | `/api/user/commands`、`/api/user/commands/{commandId}` | 登录 + 用户数据范围 |
| 指令 | POST | `/api/user/commands/{commandId}/cancel` | 登录 + 用户数据范围 |
| 指令 | GET | `/api/user/devices/{deviceId}/commands`、`/commands/stats` | 登录 + 归属 |
| 指令 | POST | `/api/user/devices/{deviceId}/commands/batch` | 登录 + 归属 |
| 传感器 | GET | `/api/user/devices/{deviceId}/sensors`、`/sensors/latest` | 登录 + 归属 |
| 事件/状态 | GET | `/api/user/devices/{deviceId}/events`、`/states` | 登录 + 归属 |
| 告警 | GET | `/api/user/alerts` | 登录 + 用户数据范围 |
| 告警 | POST | `/api/user/alerts/{id}/ack` | 登录 + 设备归属 |
| 用户 OTA | GET | `/api/user/ota/check/{deviceId}`、`/progress/{deviceId}` | 登录 + 归属 |
| 用户 OTA | POST | `/api/user/ota/start/{deviceId}`、`/retry/{deviceId}` | 登录 + 归属 |
| 用户 OTA | GET | `/api/user/ota/records` | 登录；必须传 `deviceId` |

### 6.2 管理端、通用接口与统计口径

| 模块 | 方法 | URL | 鉴权 |
|---|---|---|---|
| 管理用户 | GET / POST | `/api/admin/users` | `user:list` / `user:create` |
| 管理用户 | GET / PUT / DELETE | `/api/admin/users/{id}` | `user:list` / `user:update` / `user:delete` |
| 管理用户 | PUT | `/api/admin/users/{id}/status`、`/roles` | `user:update` |
| 管理用户 | GET | `/api/admin/users/{id}/devices` | `user:list` |
| 管理用户 | POST | `/api/admin/users/{id}/force-unbind` | `device:unbind` |
| 管理设备 | GET / POST | `/api/admin/devices` | `device:list` / `device:create` |
| 管理设备 | GET / PUT / DELETE | `/api/admin/devices/{id}` | `device:read` / `device:update` / `device:delete` |
| 管理设备 | GET / POST | `/api/admin/devices/{id}/bindings`、`/{id}/unbind` | `device:read` / `device:unbind` |
| 管理设备 | GET | `/api/admin/devices/online-stats`、`/export` | `device:list` |
| 管理设备 | POST | `/api/admin/devices/{id}/command` | `command:send` |
| 固件/OTA | POST | `/api/admin/ota/firmware/upload` | `firmware:upload` |
| 固件/OTA | GET | `/api/admin/ota/firmware`、`/firmware/list`、`/firmware/{id}` | `ota:list` |
| 固件/OTA | PUT / DELETE | `/api/admin/ota/firmware/{id}/status`、`/firmware/{id}` | `firmware:upload` / `firmware:delete` |
| 固件/OTA | POST | `/api/admin/ota/batch-dispatch` | `ota:create` |
| 固件/OTA | GET / POST | `/api/admin/ota/tasks`、`/tasks/{id}`、`/tasks/{id}/cancel` | `ota:list` / `ota:cancel` |
| 角色 | GET / POST | `/api/admin/roles`、`/roles/all`、`/roles/{id}` | `role:list` / `role:create` |
| 角色 | PUT / DELETE | `/api/admin/roles/{id}`、`/{id}/status`、`/{id}/permissions` | `role:update` / `role:delete` / `role:assign-permission` |
| 角色 | GET | `/api/admin/roles/{id}/permissions` | `role:list` |
| 权限 | GET / POST | `/api/admin/permissions`、`/permissions/all`、`/permissions/{id}` | `permission:list` / `permission:create` |
| 权限 | PUT / DELETE | `/api/admin/permissions/{id}`、`/{id}/status` | `permission:update` / `permission:delete` |
| 运维 | GET | `/api/admin/dashboard/summary`、`/api/admin/commands`、`/api/admin/audit-logs` | `device:list` |
| 运维告警 | GET / PUT | `/api/admin/alerts`、`/api/admin/alerts/{id}/status` | `alert:list` / `alert:handle` |
| 死信 | GET / POST | `/api/admin/dead-letters`、`/{id}`、`/{id}/replay`、`/{id}/ignore` | ADMIN |
| 通用 | POST | `/api/common/upload/avatar` | 登录 |
| 通用 | GET | `/api/common/dictionaries` | 登录 |
| 健康 | GET | `/actuator/health` | 匿名 |

> ⚠️ **计数勘误：原文档称“20 + 52”，新增接口表实际编号到 53（把 `/api/auth/captcha` 与 `/actuator/health` 一并列入）。**上表以路由为准完整列出，不把“20+52”作为接口总数承诺。兼容旧路由 `/api/admin/devices/stats/online` 是否启用，以当前 Controller/Knife4j 为准；规范路由为 `/online-stats`。

---

## 7. 接口详细契约

### 7.1 认证模块

#### 注册

| 项 | 契约 |
|---|---|
| 方法 / URL | `POST /api/auth/register` |
| 鉴权 | 匿名；成功后不自动登录 |
| 入参 | JSON：`username` 必填（4–32 位字母/数字/下划线）；`password` 必填（8–64 位且含字母和数字）；`nickname` 可选 ≤64；`email` 可选邮箱格式 ≤128；`phone` 可选，符合手机号格式或空 |
| 出参 | `data: { userId, username, nickname }` |
| 常见错误 | `1001`/`1002`/`1003`、`2000`、`4500` |
| 特殊规则 | 注册成功后另调登录接口 |

```http
POST /api/auth/register
Content-Type: application/json
```

```json
{
  "username": "test001",
  "password": "abc12345",
  "nickname": "测试",
  "email": "a@example.com",
  "phone": "13800138000"
}
```

#### 获取验证码

| 项 | 契约 |
|---|---|
| 方法 / URL | `POST /api/auth/captcha` |
| 鉴权 | 匿名 |
| 入参 | 可选 JSON：`type` 默认为 `image`；短信/邮件为预留类型；`target` 仅预留 |
| 出参 | `captchaId`、`captchaType`、`imageBase64`、`expireIn` |
| 常见错误 | `4033`、`4034`、HTTP 429 + `4600` |
| 特殊规则 | 图片验证码默认 300 秒；请求频率限制见第 5 章 |

```json
{
  "type": "image"
}
```

响应 `imageBase64` 含 `data:image/png;base64,` 前缀，可直接用于图片显示。

#### 登录

| 项 | 契约 |
|---|---|
| 方法 / URL | `POST /api/auth/login` |
| 鉴权 | 匿名 |
| Header | 可选 `X-Device-Type`；推荐 `X-Device-Id` |
| 入参 | JSON：`username`、`password`；启用验证码时还需 `captchaId`、`captchaCode` |
| 出参 | `LoginResponse`：`token`、`refreshToken`、`username`、`nickname`、`avatar`、`roles`、`permissions`、`lastLoginTime`、`expiresAt` |
| 常见错误 | `4010`、`4011`、`4013`、`4030`–`4032`、HTTP 429 + `4600`–`4602` |
| 特殊规则 | CAPTCHA 校验成功后一次性失效；密码错误按账号锁定；限流先于验证码校验 |

#### 刷新 Token

| 项 | 契约 |
|---|---|
| 方法 / URL | `POST /api/auth/refresh` |
| 鉴权 | 不要求 AccessToken |
| 入参 | JSON：`refreshToken` |
| 出参 | 新 `LoginResponse`，必须同时替换 `token` 与 `refreshToken` |
| 常见错误 | `4012`、`4015` |
| 特殊规则 | 旧 RefreshToken 原子消费，不能复用 |

#### 登出

| 项 | 契约 |
|---|---|
| 方法 / URL | `POST /api/auth/logout` |
| 鉴权 | Authorization 可选；RefreshToken 可选 |
| 入参 | 可选 JSON：`refreshToken` |
| 出参 | `data: null` |
| 特殊规则 | 若提供 AccessToken，后端尝试加入黑名单；提供 RefreshToken 时撤销该令牌 |

### 7.2 用户个人中心模块

| 方法 / URL | 鉴权 | 入参 | 出参 | 业务错误/规则 |
|---|---|---|---|---|
| `GET /api/user/profile` | 登录 | 无 | `UserProfileVO`：`userId`、`username`、`nickname`、`email`、`phone`、`avatar`、`status`、`roles`、`permissions`、`lastLoginTime`、`createTime` | 4014；读取当前用户 |
| `PUT /api/user/profile` | 登录 | 可选 `nickname`、`email`、`phone`、`avatar` | 更新后的用户资料 | 1002/业务错误；头像 URL 需来自上传接口，空串可清除 |
| `PUT /api/user/password`、`POST /api/user/password` | 登录 | `oldPassword`、`newPassword` | `data: null` | 参数/业务异常；新密码 8–64 位、含字母数字且不能与旧密码相同；撤销该用户 RefreshToken |
| `GET /api/user/login-logs?pageNum=&pageSize=` | 登录 | 分页参数 | `Page<LoginLogVO>` | 4014；只返回当前用户记录 |

**前端要求：**修改密码成功后清除本地双 Token 并跳转登录；改昵称/头像后刷新资料。

### 7.3 用户设备模块

| 方法 / URL | 鉴权 | 入参 | 出参 | 业务错误 / 规则 |
|---|---|---|---|---|
| `POST /api/user/devices/bind` | 登录 | `deviceId`、`bindCode` | `null` | `1003`、`4200`、`4204`–`4209`；设备 ID 与二维码绑定码均由后端校验 |
| `POST /api/user/devices/unbind` | 登录 | `deviceId` | `null` | `1003`、`4209`；只解绑当前用户关系 |
| `GET /api/user/devices/my?pageNum=&pageSize=` | 登录 | 分页 | `Page<DeviceInfoVO>` | 当前用户绑定设备；包含 OTA 四字段 |
| `GET /api/user/devices/{deviceId}` | 登录 + 归属 | 路径设备 ID | `DeviceDetailVO` | `4200`、`4209`/`4210` |
| `GET /api/user/devices/{deviceId}/online` | 登录 + 归属 | 路径设备 ID | `DeviceOnlineVO`：设备 ID、在线值、心跳时间、离线原因 | 在线状态需轮询，暂无 WS 在线/离线推送 |
| `PUT /api/user/devices/{deviceId}` | 登录 + 归属 | 可选 `deviceName`（≤64）、`location`（≤128） | 更新后的设备信息 | 后端校验设备归属和字段约束 |

`DeviceInfoVO` 的常用字段包括 `id`、`deviceId`、`deviceName`、`product`、`firmware`、`location`、`online`、在线/心跳时间、`uptime`、`capabilities`、`currentState`、`otaState`、`otaProgress`、`otaVersion`、`otaUpdateTime`。

> ⚠️ **设备归属由后端强制校验。**前端可先做 MAC 格式检查，但不得将客户端校验当作授权。

### 7.4 设备指令控制模块

#### 下发单条控制指令

| 项 | 契约 |
|---|---|
| 方法 / URL | `POST /api/user/devices/control` |
| 鉴权 | 登录 + 设备绑定归属 |
| 请求体 | `deviceId`、`action`、`target`、可选 `channel`、`params` |
| 出参 | `data` 为字符串 `commandId`（当前 Controller 返回 `ApiResponse<String>`） |
| 常见错误 | `4200`、`4201`、`4210`、参数业务错误 |
| 特殊规则 | 接口成功不等于设备执行成功；等待 `command_result` 或轮询指令详情 |

```json
{
  "deviceId": "B4BFE90CDBA1",
  "action": "set",
  "target": "led",
  "channel": 1,
  "params": {
    "state": 1
  }
}
```

`target` 常见值：`mos`、`led`、`servo`、`relay`、`ota`、`config`。常见 `action`：`set`、`get`、`toggle`、`start`、`reset`、`cancel`。**后端当前只校验部分字段非空，并不对所有 action/target 组合做统一枚举校验；前端按 `capabilities` 控制 UI，设备端仍需校验自身支持范围。**

> ⚠️ **勘误：原文档对控制接口出参同时写过“返回 commandId”和“data:null”。**当前 `UserDeviceController` 返回 `ApiResponse<String>`，`data` 为 `commandId`；旧的 `data:null` 描述不适用于当前实现。接口成功仍不代表硬件执行成功。

#### 指令查询、统计、批量与取消

| 方法 / URL | 鉴权 | 入参 | 出参 | 规则 |
|---|---|---|---|---|
| `GET /api/user/commands?deviceId=&status=&pageNum=&pageSize=` | 登录 | 可选设备、状态及分页 | 指令分页 | 不传设备时按当前用户绑定设备范围查询 |
| `GET /api/user/commands/{commandId}` | 登录 | commandId | 指令详情 | 只能访问当前用户数据范围 |
| `POST /api/user/commands/{commandId}/cancel` | 登录 | 路径 commandId | boolean | 仅 PENDING(0) 可取消；false 表示当前状态不可取消 |
| `GET /api/user/devices/{deviceId}/commands?status=&pageNum=&pageSize=` | 登录 + 归属 | 状态/分页 | 指令分页 | 目标设备必须归属当前用户 |
| `GET /api/user/devices/{deviceId}/commands/stats` | 登录 + 归属 | 路径 deviceId | `CommandStatsVO` | 包含待下发、已发、成功、失败、超时、取消、总数 |
| `POST /api/user/devices/{deviceId}/commands/batch` | 登录 + 归属 | `items` 指令数组 | `string[]` commandId | 后端顺序生成/下发多条；不是设备原子批量命令 |

批量请求示例：

```json
{
  "items": [
    {
      "action": "set",
      "target": "mos",
      "channel": 1,
      "params": {
        "state": 1
      }
    },
    {
      "action": "set",
      "target": "led",
      "channel": 1,
      "params": {
        "state": 0
      }
    }
  ]
}
```

### 7.5 传感器、事件、告警模块

| 方法 / URL | 鉴权 | 查询/请求参数 | 出参 | 业务规则 |
|---|---|---|---|---|
| `GET /api/user/devices/{deviceId}/sensors` | 登录 + 归属 | `sensorKey`、`type`、`from`、`to`、分页 | `Page<DeviceSensorRecord>` | 默认每页大小按接口实现 |
| `GET /api/user/devices/{deviceId}/sensors/latest` | 登录 + 归属 | deviceId | 最新值列表 | 每个已知传感器的最新值 |
| `GET /api/user/devices/{deviceId}/events` | 登录 + 归属 | `type`、`from`、`to`、分页 | 设备事件分页 | `type` 用于事件筛选 |
| `GET /api/user/devices/{deviceId}/states` | 登录 + 归属 | `from`、`to`、分页 | 状态变更分页 | 返回状态历史 |
| `GET /api/user/alerts` | 登录 | `deviceId`、`status`、`level`、`from`、`to`、分页 | 用户设备范围内告警分页 | 只能查询授权范围 |
| `POST /api/user/alerts/{id}/ack` | 登录 + 告警设备归属 | 告警 ID | `null` | 标记为已确认；已解决状态重复确认幂等 |
| `GET /api/admin/alerts` | 管理路径角色 + `alert:list` | 设备、状态、级别、时间、分页 | 告警分页 | 管理端全局查询 |
| `PUT /api/admin/alerts/{id}/status` | 管理路径角色 + `alert:handle` | `status` 为 1 或 2 | `null` | 当前处理人取登录管理员 |

传感器记录常见字段：`id`、`deviceId`、`source`、`slaveAddress`、`sensorId`、`channel`、`sensorKey`、`sensorType`、`sensorValue`、`unit`、`extra`、`sensorData`、`timestamp`、`createTime`。

### 7.6 用户 OTA 升级模块

| 方法 / URL | 鉴权 | 入参 | 出参 | 规则/错误 |
|---|---|---|---|---|
| `GET /api/user/ota/check/{deviceId}` | 登录 + 归属 | deviceId | `hasNewVersion`、`firmwareId`、`latestVersion`、`releaseNotes`、`size` | 可能 `4200`、`4210`、`4104`、`4302` |
| `POST /api/user/ota/start/{deviceId}` | 登录 + 归属 | 无请求体 | `null` | 可能 `4201`、`4300`–`4303`；不返回 commandId |
| `GET /api/user/ota/progress/{deviceId}` | 登录 + 归属 | deviceId | `DeviceOtaProgressVO` | 轮询快照；无记录时 OTA 字段可为 null |
| `GET /api/user/ota/records?deviceId=&pageNum=&pageSize=` | 登录 | `deviceId` 必填 | OTA 指令记录分页 | 只返回该设备 `target=ota` 记录，按创建时间倒序 |
| `POST /api/user/ota/retry/{deviceId}` | 登录 + 归属 | deviceId | 按 Controller 返回 | 最近 OTA 状态仅 FAILED/TIMEOUT/CANCELLED 时允许重试 |

### 7.7 管理端—用户管理

`/api/admin/**` 还需要 `ADMIN` 或 `OPS` 角色；以下细粒度权限以方法注解为准。

| 方法 / URL | 权限码 | 请求参数 / Body | 出参 | 规则 |
|---|---|---|---|---|
| `GET /api/admin/users` | `user:list` | `pageNum`、`pageSize`、`keyword`、`status`、`role` | 用户分页 | 支持用户名/昵称/手机号等筛选 |
| `POST /api/admin/users` | `user:create` | 用户名、密码、资料、`roleCodes`、状态 | 新用户 ID | 角色为空时服务按业务默认值处理 |
| `GET /api/admin/users/{id}` | `user:list` | id | `AdminUserDetailVO` | 用户详情 |
| `PUT /api/admin/users/{id}` | `user:update` | 昵称、邮箱、手机号 | `null` | 资料字段校验 |
| `PUT /api/admin/users/{id}/status` | `user:update` | `{"status":0}` 或 `{"status":1}` | `null` | 状态只允许有效值 |
| `PUT /api/admin/users/{id}/roles` | `user:update` | `{"roleCodes":["OPS"]}` | `null` | 覆盖角色；不能为空 |
| `GET /api/admin/users/{id}/devices` | `user:list` | 分页 | 用户设备分页 | 管理查询 |
| `POST /api/admin/users/{id}/force-unbind` | `device:unbind` | `deviceId` | `null` | 解除该用户与设备绑定 |
| `DELETE /api/admin/users/{id}` | `user:delete` | id | `null` | 逻辑删除；用户名可能加 `#DEL#` 前缀 |

### 7.8 管理端—设备管理

| 方法 / URL | 权限码 | 入参 | 出参 | 规则 |
|---|---|---|---|---|
| `GET /api/admin/devices` | `device:list` | `pageNum`、`pageSize`、`keyword` | `Page<AdminDeviceVO>` | keyword 可匹配 MAC/名称/产品 |
| `POST /api/admin/devices` | `device:create` | `deviceId` 必填；名称、产品、位置可选 | `null` | MAC 格式与唯一性由后端检查 |
| `GET /api/admin/devices/{id}` | `device:read` | id | `AdminDeviceVO` | 管理端设备详情 |
| `PUT /api/admin/devices/{id}` | `device:update` | 设备名称、产品、位置 | `null` | 只更新支持字段 |
| `DELETE /api/admin/devices/{id}` | `device:delete` | id | `null` | 删除设备记录并清理相关 Redis 绑定成员 |
| `GET /api/admin/devices/{id}/bindings` | `device:read` | 分页 | 绑定关系列表 | 查绑定用户 |
| `POST /api/admin/devices/{id}/unbind` | `device:unbind` | `userId` | `null` | 指定用户解绑 |
| `GET /api/admin/devices/online-stats` | `device:list` | 无 | 在线统计 VO | 当前在线数据快照 |
| `POST /api/admin/devices/{id}/command` | `command:send` | action/target/channel/params | commandId | 设备命令异步执行 |
| `GET /api/admin/devices/export?keyword=` | `device:list` | 可选 keyword | CSV 文件流 | 不是 ApiResponse；客户端按 Blob 下载 |

### 7.9 管理端—固件与 OTA 批量任务管理

| 方法 / URL | 权限码 | 入参 | 出参 | 规则 |
|---|---|---|---|---|
| `POST /api/admin/ota/firmware/upload` | `firmware:upload` | multipart：`file`、`version`、`product`，可选 `releaseNotes`、`operator` | 固件上传响应 | `.bin`；摘要/大小由后端计算；受 multipart 与业务上限约束 |
| `GET /api/admin/ota/firmware` | `ota:list` | 分页、product/status/keyword | 固件分页 | 新分页接口 |
| `GET /api/admin/ota/firmware/list` | `ota:list` | 无 | 启用固件列表 | 兼容接口，不分页 |
| `GET /api/admin/ota/firmware/{id}` | `ota:list` | id | 固件详情 | 不存在返回 `4101` |
| `PUT /api/admin/ota/firmware/{id}/status` | `firmware:upload` | `status` 0/1 | `null` | 启用/禁用固件 |
| `DELETE /api/admin/ota/firmware/{id}` | `firmware:delete` | id | `null` | 删除固件；有引用/文件问题时按服务端错误返回 |
| `POST /api/admin/ota/batch-dispatch?firmwareId=&targetProduct=&operator=` | `ota:create` | 固件 ID 必填，产品和操作人可选 | 成功生成指令设备数 | 同步执行；无可下发设备时可返回 0 |
| `GET /api/admin/ota/tasks` | `ota:list` | 分页、可选 status | OTA 任务分页 | 任务统计可能滞后一轮详情刷新 |
| `GET /api/admin/ota/tasks/{id}` | `ota:list` | 任务 ID | 任务详情及设备状态 | 按 taskId 汇总子指令 |
| `POST /api/admin/ota/tasks/{id}/cancel` | `ota:cancel` | task ID | 取消条数 | 只取消 PENDING 子指令 |

### 7.10 管理端—角色、权限管理

#### 角色

| 方法 / URL | 权限码 | 入参 | 出参/规则 |
|---|---|---|---|
| `GET /api/admin/roles` | `role:list` | 分页、keyword、status | 角色分页 |
| `GET /api/admin/roles/all` | `role:list` | 无 | 角色列表 |
| `GET /api/admin/roles/{id}` | `role:list` | id | 角色详情 |
| `GET /api/admin/roles/{id}/permissions` | `role:list` | id | 角色权限 |
| `POST /api/admin/roles` | `role:create` | roleCode、roleName、description、status | 新角色 ID |
| `PUT /api/admin/roles/{id}` | `role:update` | 同角色资料 | `null`；内置角色受保护 |
| `PUT /api/admin/roles/{id}/status` | `role:update` | status 0/1 | `null`；内置角色不可禁用 |
| `PUT /api/admin/roles/{id}/permissions` | `role:assign-permission` | `permissionIds`，空数组代表清空 | `null`；覆盖式分配 |
| `DELETE /api/admin/roles/{id}` | `role:delete` | id | `null`；内置角色及已分配用户角色受保护 |

内置角色不能删除、修改编码或禁用；删除仍分配给用户的自定义角色会返回 `4402`。

#### 权限

| 方法 / URL | 权限码 | 入参 | 出参/规则 |
|---|---|---|---|
| `GET /api/admin/permissions` | `permission:list` | 分页、keyword、permType、resource、status | 权限分页 |
| `GET /api/admin/permissions/all` | `permission:list` | 无 | 权限列表 |
| `GET /api/admin/permissions/{id}` | `permission:list` | id | 权限详情 |
| `POST /api/admin/permissions` | `permission:create` | permCode、permName、permType、resource、action、description、status | 新权限 ID |
| `PUT /api/admin/permissions/{id}` | `permission:update` | 权限资料 | `permCode` 不可修改，违反返回 `4024` |
| `PUT /api/admin/permissions/{id}/status` | `permission:update` | status 0/1 | `null` |
| `DELETE /api/admin/permissions/{id}` | `permission:delete` | id | 被角色引用时 `4022` |

### 7.11 管理端—运维仪表盘、告警、审计日志、死信管理

| 方法 / URL | 权限 | 入参 | 出参 | 注意事项 |
|---|---|---|---|---|
| `GET /api/admin/dashboard/summary` | `device:list` | 无 | `DashboardSummaryVO` | 汇总设备、指令、OTA、告警数据 |
| `GET /api/admin/commands` | `device:list` | 分页、deviceId、status、from、to | 指令分页 | 管理查询 |
| `GET /api/admin/alerts` | `alert:list` | 分页及设备、状态、级别、时间筛选 | 告警分页 | 管理全局范围 |
| `PUT /api/admin/alerts/{id}/status` | `alert:handle` | status=1/2 | `null` | 操作人取登录管理员 |
| `GET /api/admin/audit-logs` | `device:list` | 分页、deviceId、operator、source、时间筛选 | 指令流水分页 | 不是全操作审计 |
| `GET /api/admin/dead-letters` | ADMIN | 分页 | 死信分页 | 访问报文应按敏感数据处理 |
| `GET /api/admin/dead-letters/{id}` | ADMIN | id | 死信详情 | 原始 MQTT payload |
| `POST /api/admin/dead-letters/{id}/replay` | ADMIN | id | `null` | 只重放允许处理的消息；先修复原因 |
| `POST /api/admin/dead-letters/{id}/ignore` | ADMIN | id | `null` | status 置为 2，之后不可重放 |

### 7.12 通用能力接口

| 方法 / URL | 鉴权 | 入参 | 出参 | 规则 |
|---|---|---|---|---|
| `POST /api/common/upload/avatar` | 登录 | multipart 字段 `file` | AvatarUploadResponse，含头像 URL | 上传后再调用 profile 保存 URL |
| `GET /api/common/dictionaries` | 登录 | 无 | 字典 Map | 供 UI 展示；以响应实际键和值为准 |
| `GET /actuator/health` | 匿名 | 无 | Actuator 健康 JSON | details 默认不展示 |

---

## 8. WebSocket STOMP 实时推送

### 8.1 能力和部署边界

- Endpoint：`/ws`，通过 SockJS 注册。
- STOMP Simple Broker destinations：`/topic`、`/queue`；客户端应用前缀 `/app`。
- 当前无 `@MessageMapping` 业务接收端点，前端只需连接和订阅，不需要发布业务消息。
- 服务端没有显式覆盖 STOMP 心跳配置；客户端仍需配置心跳与代理超时。

> ⚠️ **风险提示：SimpleBroker 是单实例内存 Broker。**MQTT 在实例 B 消费、前端连接在实例 A 时，实例 A 不会自动收到 B 的推送。当前不能依赖多实例广播；水平扩容需引入共享消息代理/Broker Relay，并明确离线补偿。

### 8.2 地址、依赖与连接时序

| HTTP 地址 | SockJS 地址 |
|---|---|
| `http://localhost:8080` | `http://localhost:8080/ws` |
| `https://iot.example.com` | `https://iot.example.com/ws`（底层使用 WSS） |

前端可使用：

```bash
npm install @stomp/stompjs sockjs-client
npm install --save-dev @types/sockjs-client
```

```text
前端登录取得 token
  → SockJS 握手 /ws（Origin 必须被允许）
  → STOMP CONNECT，Header Authorization（认证方案 + 空格 + token）
  → 后端解析 JWT 并创建 STOMP Principal
  → CONNECTED
  → SUBSCRIBE /topic/device/{deviceId}/{type}
  → 后端校验管理员角色或用户设备有效绑定
  → MQTT Handler 产生消息，后端向对应 topic 推送
```

必须等 `CONNECTED` 后再订阅。SockJS 握手路径由客户端库处理，不要手工拼 `/ws/websocket`。

### 8.3 连接鉴权与订阅鉴权

- Token 只能放在 STOMP `CONNECT` Native Header，Authorization 值为 Bearer + 空格 + token；不支持 URL query token。
- 管理员允许订阅 `/topic/**`。
- 普通用户只允许订阅其有效绑定设备的以下精确主题类型：`state`、`sensor`、`alert`、`ota`、`command`。
- 普通用户不允许通配设备主题；需逐台订阅。
- 未认证、topic 格式错误或无设备归属时，服务端返回 STOMP ERROR 并关闭连接。
- 鉴权在服务端强制执行；前端菜单/订阅筛选只是 UI 辅助。

### 8.4 全部设备 Topic

| Destination | `type` | 内容 |
|---|---|---|
| `/topic/device/{deviceId}/state` | `state` | 外设状态变化 |
| `/topic/device/{deviceId}/sensor` | `sensor` | 传感器记录数组 |
| `/topic/device/{deviceId}/alert` | `alert` | 告警记录 |
| `/topic/device/{deviceId}/ota` | `ota_progress` | OTA 阶段进度 |
| `/topic/device/{deviceId}/command` | `command_result` | 指令 ACK 处理结果 |

### 8.5 统一消息信封与类型示例

通用外层结构：

```json
{
  "type": "state",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T10:30:00",
  "data": {}
}
```

#### `state`

`data` 为状态变更对象，字段依据设备目标而定：

```json
{
  "type": "state",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T10:30:00",
  "data": {
    "target": "led",
    "channel": 1,
    "state": 1
  }
}
```

#### `sensor`

`data` 为 `DeviceSensorRecord` 数组；元素常见字段为 `id`、`deviceId`、`source`、`slaveAddress`、`sensorId`、`channel`、`sensorKey`、`sensorType`、`sensorValue`、`unit`、`extra`、`sensorData`、`timestamp`、`createTime`。

```json
{
  "type": "sensor",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T10:30:00",
  "data": [
    {
      "deviceId": "B4BFE90CDBA1",
      "sensorKey": "temp",
      "sensorType": "temperature",
      "sensorValue": 25.3,
      "unit": "℃",
      "timestamp": "2026-11-05T10:30:00"
    }
  ]
}
```

#### `alert`

`data` 为告警对象；常见字段：`id`、`deviceId`、`sensorKey`、`alertLevel`、`alertType`、`message`、`value`、`threshold`、`status`、`handledBy`、`handledTime`、`timestamp`、`createTime`。

```json
{
  "type": "alert",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T10:30:00",
  "data": {
    "id": 18,
    "deviceId": "B4BFE90CDBA1",
    "sensorKey": "temp",
    "alertLevel": 2,
    "alertType": "threshold",
    "message": "温度超过阈值",
    "value": 35.5,
    "threshold": 35.0,
    "status": 0
  }
}
```

#### `ota_progress`

`data` 常见字段：`otaState`、`otaStateText`、`progress`、`version`、`commandId`、`error`、`reportTime`。外层时间是服务端推送时间，`reportTime` 来源于设备上报时间。

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

#### `command_result`

`data` 为 `CommandResultVO`。主要字段：`commandId`、`deviceId`、`action`、`target`、`channel`、`status`、`statusText`、`success`、`errorMsg`、`responsePayload`、`ackTime`。

```json
{
  "type": "command_result",
  "deviceId": "B4BFE90CDBA1",
  "timestamp": "2026-11-05T13:47:34",
  "data": {
    "commandId": "b624660c30e546efb7808b746453c4d6",
    "deviceId": "B4BFE90CDBA1",
    "action": "set",
    "target": "led",
    "channel": 1,
    "status": 2,
    "statusText": "成功",
    "success": true,
    "errorMsg": null,
    "responsePayload": {
      "state": 1
    },
    "ackTime": "2026-11-05T13:47:34"
  }
}
```

**交互顺序：**先订阅 `/command`，再调用控制 API；收到 API 返回的 commandId 后匹配 `command_result`。指令状态以服务端查询结果为准；`responsePayload` 由固件决定。

### 8.6 STOMP 错误帧

| 场景 | 错误内容/信号 | 处理 |
|---|---|---|
| CONNECT 缺少 Authorization Token | `缺少 Authorization Token` | 检查 STOMP Native Header 和空格 |
| Token 无效或过期 | `认证失败，Token无效或已过期` | 刷新后重新 CONNECT；刷新失败转登录 |
| 未认证即订阅 | `未认证，禁止订阅` | 等待 CONNECTED，不要提前订阅 |
| 未绑定设备 | `无权订阅该设备的数据` | 不重试；引导绑定或切换设备 |
| 非法 destination | 订阅地址不合法/不能为空 | 修正 topic，不要重试原地址 |
| 握手跨域失败 | HTTP 403，无 STOMP ERROR 帧 | 检查 CORS Origin、代理及握手请求 |

### 8.7 保活、重连、Token 过期与最小示例

- 推荐客户端心跳 `heartbeatIncoming/Outgoing: 10000`，连接超时约 10 秒。
- 重连后必须重新订阅；连接建立时的 Token 不会自动更新。
- Token 过期时现有连接不会被主动强制断开，但断线重连需使用新 Token。
- 建议退避重连；权限错误/未绑定错误不要无限重试。
- 当前 SimpleBroker 多实例限制见 [第 11 章](#11-系统已知限制与注意事项)。

最小示例（调用方需提供复用 HTTP 刷新锁的 `getValidAccessToken`，并实现 `dispatchDeviceMessage` 消息处理函数）：

```javascript
import { Client } from '@stomp/stompjs';
import SockJS from 'sockjs-client';

async function connectDeviceWs() {
  const client = new Client({
    webSocketFactory: () => new SockJS('http://localhost:8080/ws'),
    connectHeaders: {},
    reconnectDelay: 5000,
    heartbeatIncoming: 10000,
    heartbeatOutgoing: 10000,
    connectionTimeout: 10000,
    beforeConnect: async () => {
      const token = await getValidAccessToken();
      client.connectHeaders = {
        Authorization: 'Bearer ' + token
      };
    },
    onConnect: () => {
      const base = '/topic/device/B4BFE90CDBA1';
      for (const suffix of ['state', 'sensor', 'alert', 'ota', 'command']) {
        client.subscribe(`${base}/${suffix}`, (frame) => {
          dispatchDeviceMessage(JSON.parse(frame.body));
        });
      }
    },
    onStompError: (frame) => {
      console.error(frame.headers.message, frame.body);
    }
  });
  client.activate();
  return client;
}

connectDeviceWs().catch(console.error);
```

`await` 需放在 async 初始化函数中执行。生产使用 HTTPS 时替换为对应 HTTPS SockJS 地址。登出时调用 `client.deactivate()`。

### 8.8 调试与验收

- 浏览器 DevTools → Network → WS/SockJS 请求，检查握手与 STOMP CONNECTED/SUBSCRIBE/MESSAGE/ERROR 帧。
- 开发时开启 STOMP `debug` 回调；生产关闭调试日志，避免输出敏感消息。
- MQTT 设备未在线、消息未到服务端、topic 不匹配、订阅未授权都可能导致无推送。
- 断线重连后，控制结果可通过指令详情轮询；OTA 进度先获取 HTTP 快照再继续订阅。

---

## 9. OTA 升级完整业务流程与状态机

### 9.1 端到端数据流

```text
前端 GET /api/user/ota/check/{deviceId}
  → 服务端确认设备、固件、版本条件
  → 前端先订阅 /topic/device/{deviceId}/ota（建议同时订阅 /command）
  → 前端 POST /api/user/ota/start/{deviceId}
  → 服务端创建 device_command 并发布 device/{mac}/command
  → 设备 ACK 和 device/{mac}/ota_progress 上报
  → MQTT Handler 更新 device_info / device_command
  → WebSocket 推送 ota_progress / command_result
  → 前端终态刷新设备与 OTA 历史；断线用 HTTP 快照补齐
```

### 9.2 `otaState` 状态机

```text
accepted → downloading → verifying → flashing → rebooting → success
    └──────────────── 任意升级阶段失败 ───────────────────→ failed
```

| 状态 | 含义 | 终态 |
|---|---|---|
| `accepted` | 已接受 | 否 |
| `downloading` | 下载中 | 否 |
| `verifying` | 校验中 | 否 |
| `flashing` | 写入中 | 否 |
| `rebooting` | 重启中 | 否 |
| `success` | 升级成功 | 是 |
| `failed` | 升级失败 | 是 |

后端把状态归一化为小写，将进度限制在 0–100；`success` 强制为 100。运行态超过约 5 分钟没有更新会进入僵死状态处理逻辑。设备上报的阶段可在未收到 ACK 时推进 OTA 指令状态；指令终态不会被迟到的中间进度覆盖。

### 9.3 单设备升级时序

1. `GET /api/user/ota/check/{deviceId}` 获取是否有新版本及固件信息。
2. 建立 WebSocket 并订阅 `/ota`（建议同时订阅 `/command`）。
3. 调用 `POST /api/user/ota/start/{deviceId}`。
4. 此接口不返回 commandId；从后续 OTA 进度或 `GET /progress` 快照获取关联 commandId。
5. 以 `ota_progress` 驱动阶段/进度展示；断线、重连、重新打开页面时用 `GET /progress` 恢复快照。
6. 到 `success`/`failed` 后停止进度轮询，刷新设备固件与升级记录。

### 9.4 批量 OTA 任务

- 管理端 `POST /api/admin/ota/batch-dispatch` 按固件/产品筛选设备并同步生成命令，响应为成功生成命令的设备数量。
- 后端生成 `device_ota_task`，批次 `taskId` 与子指令关联。
- `GET /api/admin/ota/tasks` 查询任务列表；`GET /tasks/{id}` 查询设备级详情。
- 取消任务只处理仍处于 `PENDING(0)` 的子指令；已发给设备的命令不能通过任务取消撤回。
- 批量派发是同步请求，设备数量较大时可能耗时；任务统计可能滞后一轮刷新。

### 9.5 状态、指令结果与轮询兜底

OTA 阶段状态和设备命令状态是两套状态：

- `otaState` 表示固件升级阶段。
- `device_command.status` 表示命令生命周期；`ACCEPTED(6)` 代表设备已受理但仍可能升级中。
- `ota_progress` 用于阶段与百分比；`command_result` 用于命令回执结果。

轮询策略建议：进行中每 1–2 秒请求一次；首次打开页面/重连后立即请求；`finished=true` 或 OTA 达到终态后停止。以 `deviceId + commandId` 关联同一次升级，设备时间优先使用 `reportTime`。

### 9.6 重试、取消及异常状态

- 用户端重试：最近一次 OTA 指令为 `FAILED(3)`、`TIMEOUT(4)`、`CANCELLED(5)` 时允许。
- 管理端取消：仅取消任务中的 PENDING 子指令。
- `4301`：已存在运行中升级；应展示当前进度而不是重复点击。
- `4201`：设备离线；上线状态通过 HTTP 轮询确认。
- `4302`：产品/版本不兼容；`4303`：已是最新版本。
- **TIMEOUT(4) 仅落库、不额外推送。**前端应在等待超时后调用 `GET /api/user/commands/{commandId}` 或 OTA progress 接口确认最终状态。

---

## 10. 枚举与字典说明

`GET /api/common/dictionaries` 用于向 UI 下发角色、状态、OTA、告警和产品等展示字典。建议前端优先读取并缓存字典，避免重复维护映射；字典只用于展示，不代替后端业务校验。枚举编码和值以接口响应及当前枚举源码为准。

| 字典 | 编码 |
|---|---|
| 设备在线状态 | `0` 离线、`1` 在线、`2` 故障（列表字段也可能以 boolean/number 表达，以具体 VO 为准） |
| 指令状态 | `0` PENDING、`1` SENT、`2` SUCCESS、`3` FAILED、`4` TIMEOUT、`5` CANCELLED、`6` ACCEPTED |
| OTA 阶段 | `accepted`、`downloading`、`verifying`、`flashing`、`rebooting`、`success`、`failed` |
| OTA 批量任务 | `0` 进行中、`1` 完成、`2` 取消 |
| 固件启用状态 | `0` 禁用、`1` 启用 |
| 告警级别 | `1` 提示、`2` 一般、`3` 严重 |
| 告警状态 | `0` 未处理、`1` 已确认、`2` 已解决 |
| 死信状态 | `0` 未处理、`1` 重放成功、`2` 已忽略 |
| 绑定状态 | `1` 有效、`0` 已解绑（内部数据库字段） |

**易混淆项：**OTA 阶段字符串不是 command status 数字；告警状态与设备在线状态共用数字但语义完全不同。离线原因以字符串形式返回，前端应为未知值提供兜底文案。

---

## 11. 系统已知限制与注意事项

| 限制 | 影响范围 | 应对方案 |
|---|---|---|
| WebSocket 使用内存 SimpleBroker | 多实例时跨实例推送不可达，消息可能丢失 | 当前按单实例部署；扩容前引入共享 Broker/Relay |
| 指令 TIMEOUT 只落库、不推送 | 前端可能收不到最终超时状态 | 设置 UI 等待上限后轮询 command 详情 |
| 在线/离线状态不经 WebSocket 推送 | 在线状态卡片不能依赖 WS 实时刷新 | 轮询用户设备 online 或管理端 online-stats |
| 审计日志复用 `device_command` | 只覆盖指令相关记录，不是全操作审计 | 页面和报表明确标注“指令审计”；需要完整审计应新增独立审计能力 |
| 用户界面权限仅是 UI 控制 | 直接构造请求仍可绕过菜单限制 | 服务端每次 HTTP 请求和 STOMP SUBSCRIBE 都要鉴权 |
| CORS 请求头清单缺少 `X-Device-Id` / `X-Device-Type` | 浏览器跨域预检可能失败，设备维度限流头无法到达 | 后端更新 allowed headers，并在部署环境验证 OPTIONS |
| 批量 OTA 同步派发 | 目标设备多时接口响应慢 | 前端显示处理中；后续可改异步任务队列 |
| 设备 `action`/`target` 组合未完全枚举校验 | 错误组合可能到达设备端 | UI 按 capabilities 限定；固件端仍需校验 |
| OTA 管理任务统计可能滞后 | 列表与设备最新状态短暂不一致 | 查询详情/刷新列表；逐设备进度用 OTA progress 查询 |
| 业务异常大多 HTTP 200 | 客户端仅看 HTTP 状态会误判成功 | 必须判断统一响应 `code` |
| 数据库未采用迁移框架 | 已部署数据库不会自动应用新表/权限种子 | 先备份并制定增量 SQL，避免直接重放初始化脚本 |
| `4601` 对应人机验证标记，当前无 challenge API | 前端无法完成服务端挑战闭环 | 暂停重试并提示；由后端另行定义可用挑战契约 |
| 测试账号明文密码未在 SQL 中定义 | 初始化数据库的 admin 密码不可由文档确认 | 通过受控密码初始化/重置流程获得测试凭据 |

---

## 12. 联调与验收 Checklist

### 12.1 后端与运维

- [ ] 确认当前实例使用正确 `dev`/`prod` profile，生产密钥不使用仓库默认值。
- [ ] 检查 MySQL Schema 与部署版本 SQL 一致，已备份并有增量迁移方案。
- [ ] 检查 Redis 连接与限流/令牌功能。
- [ ] 检查 MQTT runtime（8883）与 provision（8884）连接、证书、账号、ACL、订阅 topic/QoS。
- [ ] 确认前端 Origin 已加入 `cors.allowed-origins`。
- [ ] 确认 CORS 允许真实请求头 `Authorization`、`Content-Type` 以及前端使用的 `X-Device-Id` / `X-Device-Type`。
- [ ] 验证 `GET /actuator/health` 返回健康状态。
- [ ] 开发环境可访问 `/doc.html`；生产确认 Knife4j/OpenAPI 已关闭。
- [ ] 固件上传目录可写，固件下载 URL 可被设备访问。
- [ ] 如部署多实例，已确认 WebSocket 跨实例推送限制及临时部署方案。

### 12.2 前端实现

- [ ] HTTP 拦截器按 `code === 200` 判断业务成功，并单独处理 HTTP 401/403/429。
- [ ] AccessToken 使用 Authorization Header，值为 Bearer + 一个空格 + token。
- [ ] 401 并发请求共用刷新锁，刷新成功同时覆盖两个 Token，失败停止重试并跳登录。
- [ ] 验证码、登录请求携带同一个持久化 `X-Device-Id`。
- [ ] 验证码一次性消费；4030/4031 后重新获取。
- [ ] 4600/4601/4602 分别展示频率限制、人机风控、网络受限提示。
- [ ] 4013 展示服务端返回的剩余锁定时间。
- [ ] 菜单/按钮按 `permissions` 做 UI 控制，但不将 UI 当作后端授权。
- [ ] 设备控制按 `capabilities` 渲染，并先订阅 `/command` 再发命令。
- [ ] 控制结果按 `commandId` 匹配 `command_result`；超时后轮询命令详情。
- [ ] WebSocket CONNECT 在 Native Header 中传 Authorization（Bearer + 空格 + token）；仅在 CONNECTED 后订阅。
- [ ] WebSocket 重连前确保 Token 有效；重连后恢复订阅。
- [ ] 用户重连/重新打开 OTA 页面时先 GET progress 快照，再消费推送。
- [ ] 在线/离线状态通过 HTTP 轮询更新。
- [ ] 分页使用 `pageNum/pageSize`，读取 `records/total`。
- [ ] 设备导出以 Blob 处理；头像/固件上传使用 multipart 正确字段名。

### 12.3 硬件与 MQTT

- [ ] Topic 中 MAC 与报文 `device` 字段一致，设备 ID 格式符合注册要求。
- [ ] 注册签名材料 `deviceId|timestamp|nonce` 与设备私钥签名匹配。
- [ ] 使用注册响应中的 MQTT 连接信息，不复用服务器端账号或凭据。
- [ ] 按注册响应的 `will` 配置 presence topic、QoS、retain、payload。
- [ ] 验证 heartbeat、presence、state、sensor、event、ack、ota_progress 报文及时间戳单位。
- [ ] ACK 原样回传服务端 `commandId`，重复/非法 ACK 不造成错误状态覆盖。
- [ ] OTA 上报合法 `otaState`、0–100 progress、目标 version 和失败原因。
- [ ] 验证格式错误消息进入死信表，修复后可重放或标记忽略。

---

## 13. 数据库核心表简要说明

初始化脚本为 `web-module/src/main/resources/sql/smart_device.sql`。具体列以脚本和实体类为准。

| 表 | 核心用途与关键字段 |
|---|---|
| `sys_user` | 用户名、密码哈希、昵称、联系方式、头像、状态、`deleted` |
| `sys_role` | 角色编码/名称、状态、`built_in`、`deleted` |
| `sys_role_info` | 用户-角色关系；`user_id + role_id` 唯一 |
| `sys_permission` | 权限码、类型、资源、动作、状态、逻辑删除 |
| `sys_role_permission` | 角色-权限关系；角色与权限组合唯一 |
| `sys_refresh_token` | 用户、RefreshToken SHA-256 哈希、到期、撤销、设备类型 |
| `sys_login_log` | 用户名、IP、UA、成功/失败、时间 |
| `device_info` | MAC、产品、固件、公钥、绑定码、在线信息、capabilities/current_state JSON、OTA 状态、`deleted` |
| `device_binding` | device_id、user_id、bind_status、绑定/解绑时间；active_device_id 生成列确保设备只有一条有效绑定 |
| `device_mqtt_auth` | 设备 MQTT 用户名、密码哈希与盐、启用状态 |
| `device_sensor` | 传感器元数据与设备、传感器键、类型、数据来源、单位 |
| `device_sensor_record` | 传感器历史值、来源/从机/通道、采集时间、扩展 JSON |
| `device_heartbeat_record` | 心跳历史数据 |
| `device_state_record` | 状态变化历史 |
| `device_event_record` | 设备事件/错误、代码、上下文、原始 JSON |
| `device_alert_record` | 告警级别、类型、value/threshold、处理状态和操作人 |
| `device_command` | 唯一 commandId、deviceId、action/target/channel、params JSON、状态、ACK/重试时间 |
| `device_firmware` | 固件版本/产品、URL/路径、MD5/SHA-256、大小、状态 |
| `device_ota_task` | 批量任务 ID、固件版本、总量/成功/失败/待处理数、状态 |
| `sys_dead_letter` | MQTT topic、原始 payload、异常摘要、可重试标记、状态、重试次数 |

### 13.1 逻辑删除、唯一约束与内置角色

- MyBatis-Plus 默认逻辑删除字段 `deleted`，通常 0 未删除、1 已删除；`device_info.deleted` 为 BIGINT，非零值可承载删除时间戳/ID。
- 不是所有表都带 `deleted`。设备绑定使用 `bind_status` 记录解绑，不能当作逻辑删除。
- `device_info.device_id + deleted`、`bind_code + deleted` 有唯一索引；`device_binding.active_device_id` 对有效绑定唯一。
- `device_command.command_id`、固件 `(version, product)`、角色码、权限码、RefreshToken 哈希有唯一约束。
- `ADMIN`、`OPS`、`USER` 是 SQL 中 `built_in=1` 的内置角色；服务层禁止删除、改编码或禁用等受保护操作。

### 13.2 数据形状示例

以下字段结构对应 SQL 表 `device_sensor_record`：

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

`device_command` 关键字段示例：

```json
{
  "command_id": "example-command-id",
  "device_id": "B4BFE90CDBA1",
  "action": "set",
  "target": "led",
  "channel": 1,
  "params": {
    "state": 1
  },
  "status": 0,
  "source": "WEB"
}
```

示例值仅说明字段，不代表该行已存在。

---

## 14. 后端配置文件说明

| 配置文件 | 主要内容 |
|---|---|
| `application.yml` | 端口、MySQL/Druid、Redis 池、Jackson 时区、Multipart、MyBatis-Plus、MQTT Topic/QoS、验证码、JWT、Knife4j、Actuator |
| `application-dev.yml` | 本地 MySQL/Redis/MQTT、证书、开发 CORS Origin、固件目录与 URL |
| `application-prod.yml` | 生产 DB/Redis/MQTT 环境变量、生产 Origin、文件目录、日志、关闭 Knife4j/Springdoc |

### 14.1 重点配置项

- **MySQL**：生产使用 `DB_HOST`、`DB_USERNAME`、`DB_PASSWORD`；开发可覆盖 `DEV_DB_USER`、`DEV_DB_PASS`。
- **Redis**：生产使用 `REDIS_HOST`、`REDIS_PASSWORD`。
- **MQTT**：运行时 Broker 8883、注册 Broker 8884；生产变量包括 `MQTT_HOST`、`MQTT_USERNAME`、`MQTT_PASSWORD`、`MQTT_PROVISION_USERNAME`、`MQTT_PROVISION_PASSWORD`。CA、客户端证书和密码路径需与部署一致。
- **CORS**：`cors.allowed-origins` 必须填写正式前端 Origin。源码允许 Header 列表还需确认是否包含业务自定义 Header。
- **限流开关**：当前 yml 未定义统一限流开关。**不得在部署文档中声称可通过配置关闭**；是否启用由当前服务实现决定。
- **Knife4j**：dev 可用；prod `knife4j.enable=false` 且关闭 OpenAPI/Swagger。
- **文件上传**：默认单文件上限 `16MB`、请求上限 `20MB`；固件和头像目录由配置指定，需保证写入权限与外部下载可达。
- **JWT**：通过 `JWT_SECRET` 注入强随机生产密钥；不能使用仓库中的开发默认值。
- **WebSocket**：端点 `/ws`，Origin 采用配置的跨域白名单；Nginx 代理需支持 Upgrade 和 SockJS 回退路径。

### 14.2 凭据管理

仓库开发配置含本地演示默认账号/密码及开发 JWT 默认值，不得复制到生产。生产数据库密码、MQTT 密码、证书私钥、JWT 密钥应通过部署密钥管理注入并进行轮换，不提交到源码仓库。

---

## 15. 部署与 Nginx 配置要求

### 15.1 部署前检查

1. 准备 MySQL、Redis、MQTT TLS 运行时/注册 Broker 和证书。
2. 按当前 Schema 版本备份并执行审核过的数据库初始化/增量脚本。
3. 设置 `SPRING_PROFILES_ACTIVE=prod` 和所需环境变量。
4. 准备固件存储目录、头像目录和可被设备访问的下载域名。
5. 配置 HTTPS、CORS Origin 白名单并关闭生产 Knife4j/OpenAPI。
6. 当前实现适用于单实例 WebSocket 推送；多实例部署前先解决 Broker 广播问题。

### 15.2 Nginx WebSocket 与 SockJS

需转发 `/ws` 及 `/ws/**` SockJS HTTP 回退请求，保留 HTTP/1.1 Upgrade，并设置长读超时。以下为配置要点，域名、证书和 upstream 需替换：

```nginx
location /ws/ {
    proxy_pass http://127.0.0.1:8080/ws/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
}

location = /ws {
    return 301 /ws/;
}
```

若实际 SockJS 配置或代理 path mapping 不同，应以浏览器 Network 中 SockJS 实际请求路径和后端 endpoint 为准，避免错误地只代理原生 WebSocket Upgrade。

### 15.3 HTTP、静态文件、CORS 与生产文档

- API 代理保留 Host、客户端 IP 和协议头；真实 IP 仅信任受控的代理链路。
- 头像 URL 路径为后端静态资源映射；固件 `base-url` 必须指向可被设备访问的文件服务。确认 Nginx/static location 与后端目录映射对应，不能仅代理 API 后就假设固件文件可下载。
- CORS 白名单由应用配置；Nginx 转发不应重复写入冲突的 `Access-Control-Allow-*` 头。
- 生产必须关闭 Knife4j、Swagger UI 和 OpenAPI 文档端点。
- 配置前端实际需要的 `Authorization`、`Content-Type`、`X-Device-Id` 等 Header；当前后端 CORS 配置尚未放行设备指纹 Header。
- 上传请求大小限制需同时满足 Nginx body size 与 Spring Multipart/固件业务大小限制。

---

## 16. 常见故障排查指南

| 现象 | 常见根因 | 排查步骤 | 处理 |
|---|---|---|---|
| 浏览器 CORS 403 / OPTIONS 失败 | Origin 不在白名单；或自定义 Header 不在 allowed headers | Network 查看 OPTIONS 的 `Access-Control-Request-Headers`；核对 `cors.allowed-origins` 与 `CorsConfig` Header 列表 | 后端配置正确 Origin 和 Header；重点检查 `X-Device-Id`、`X-Device-Type` |
| WebSocket 握手 HTTP 403 | WebSocket Origin 未允许、Nginx 未正确代理 `/ws`/SockJS 路径 | 查看握手状态、Origin、代理 access/error log；区分 HTTP 握手失败与 STOMP ERROR | 配置 CORS Origin、Upgrade 头及 `/ws/**` 代理；不能只检查 STOMP Token |
| WebSocket CONNECT 后立即断开 | `Authorization` 缺失、Token 空格错误、JWT 无效/过期 | 浏览器 STOMP debug 与后端 `WebSocketAuthInterceptor` 日志 | CONNECT Native Header 使用 Authorization（Bearer + 空格 + token）；刷新后重连 |
| 订阅 STOMP ERROR“无权订阅设备” | 用户无有效设备绑定、订阅主题格式错误或使用通配符 | 检查当前账号绑定关系、deviceId 规范化结果及完整 destination | 绑定设备后逐个订阅合法后缀；不要反复重试越权主题 |
| HTTP 刷新返回 `4012` | RefreshToken 已过期/撤销/已消费，或多个并发请求共用一个 token 刷新 | 检查 refresh 请求数量、刷新锁及本地双 Token 是否同步替换 | 清空凭据重新登录；前端统一使用单飞刷新锁 |
| 收到 4014 后仍循环重试 | 刷新接口也被拦截或刷新失败后仍重放请求 | 检查 HTTP 拦截器对 refresh endpoint 的排除规则及重试标记 | refresh endpoint 不进入同一递归刷新逻辑；失败后停止队列并转登录 |
| OTA 已启动但 WebSocket 无进度 | 未提前订阅、订阅错设备/主题、设备未发 `ota_progress`、MQTT 没到达消费端 | 先调用 progress API；核对 `/topic/device/{mac}/ota`、MQTT `device/{mac}/ota_progress`、后端 Handler 日志 | 重连后先拉快照；检查设备固件、Broker ACL、MQTT 订阅和死信 |
| OTA progress 只有部分阶段/页面重连后空白 | WS 中断期间 SimpleBroker 不缓存历史消息 | 调用 `GET /api/user/ota/progress/{deviceId}` 与 records | 以 HTTP 快照补齐；终态后停止轮询 |
| 指令已受理但 UI 未显示 TIMEOUT | TIMEOUT 定时任务只更新数据库，不推送 command_result | 调用 `GET /api/user/commands/{commandId}` 检查状态；核对 command timeout 任务日志 | 前端在等待超时后轮询，不等待 WS 超时通知 |
| MQTT 死信持续增加 | 报文 JSON/字段不符合 Handler、设备 ID 与 Topic 不一致、DB/依赖异常、重放后根因未修复 | 按死信 topic、errorMsg、retryable、payload 查看；核对对应 Handler 日志和 Broker | 先修复根因并验证单条；仅对可重试消息重放；无法修复或无效消息标记 ignore |
| MQTT 死信重放失败 | 报文不可重试或 `IllegalArgumentException`，状态已忽略/已处理 | 查看 `isRetryable`、status、retryCount、原始报文 | 修复格式/数据后按业务规则处理；不要对 poison message 无限重放 |
| 业务失败但 HTTP 显示 200 | `GlobalExceptionHandler` 对业务异常按 HTTP 200 返回 | 检查响应体 `code`、`message` | 前端按 `code === 200` 判断成功 |
| 设备在线/离线不即时变化 | 当前没有在线状态 WebSocket 推送 | 查询设备 online 接口/管理端 online-stats，检查心跳和 presence | 使用轮询；检查 Broker LWT 与设备 heartbeat |
| 头像/固件上传失败或设备下载失败 | Multipart/Nginx 限制、目录权限、URL/静态映射错误 | 对照上传错误码、应用日志、文件系统和下载 URL | 检查 Nginx body size、Spring 限额、目录权限和静态文件路径 |
| 生产环境无法打开 Knife4j | 生产有意关闭 Springdoc/Knife4j | 确认 `prod` profile 与 `knife4j.enable=false` | 使用开发/受控环境调试；不要为线上排障长期开放文档端点 |
