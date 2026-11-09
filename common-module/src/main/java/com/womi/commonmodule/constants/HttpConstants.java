package com.womi.commonmodule.constants;

public final class HttpConstants {

    public static final int SUCCESS_CODE = 200;
    public static final String SUCCESS_MESSAGE = "success";

    public static final int BAD_REQUEST_CODE = 400;
    public static final String BAD_REQUEST_MESSAGE = "Bad Request";

    public static final int UNAUTHORIZED_CODE = 401;
    public static final String UNAUTHORIZED_MESSAGE = "Unauthorized";

    public static final int INTERNAL_ERROR_CODE = 500;
    public static final String INTERNAL_ERROR_MESSAGE = "Internal Server Error";

    public static final String DEVICE_TYPE_HEAD = "X-Device-Type";
    public static final String FORWARDED_FOR = "X-Forwarded-For";
    public static final String REAL_IP = "X-Real-IP";
    public static final String UNKNOWN = "unknown";

    // ==================== 免认证路径 ====================
    public static final String ACTUATOR_HEALTH_PATH = "/actuator/health";
    public static final String WEBSOCKET_ENDPOINT_PATTERN = "/ws/**";
    public static final String ERROR_PATH = "/error";
    /** SockJS 降级传输（EventSource / SSE）的响应类型 */
    public static final String SSE_CONTENT_TYPE = "text/event-stream";

    /** SockJS 会话地址前缀（后端 WebSocket 端点下的传输请求） */
    public static final String WEBSOCKET_TRANSPORT_PREFIX = "/ws/";

    public static final String FAVICON_PATH = "/favicon.ico";

    // ==================== 认证接口路径 ====================
    public static final String AUTH_LOGIN_PATH = "/api/auth/login";
    public static final String AUTH_REGISTER_PATH = "/api/auth/register";
    public static final String AUTH_REFRESH_PATH = "/api/auth/refresh";

    // ==================== 管理端路径 ====================
    public static final String ADMIN_API_PATTERN = "/api/admin/**";

    // ==================== 接口文档静态资源 ====================
    public static final String DOC_HTML_PATH = "/doc.html";
    public static final String DOC_HTML_LOCATION = "classpath:/META-INF/resources/";
    public static final String WEBJARS_PATTERN = "/webjars/**";
    public static final String WEBJARS_LOCATION = "classpath:/META-INF/resources/webjars/";
    public static final String API_DOCS_PATTERN = "/v3/api-docs/**";
    public static final String SWAGGER_RESOURCES_PATTERN = "/swagger-resources/**";

    // ==================== 运行环境 ====================
    public static final String PROD_PROFILE = "prod";
}
