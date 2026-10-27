package com.womi.commonmodule.constants;

public final class UserConstants {

    /**
     * 用户状态
     */
    public static final Integer ENABLE_USER = 1;
    public static final Integer DISENABLE_USER = 0;

    /**
     * 逻辑删除
     */
    public static final Integer NOT_DELETED = 0;
    public static final Integer LOGIC_DELETE_USER = 1;
    public static final String DELETE_USER_NAME = "#DEL#";

    /**
     * 角色与权限
     */
    public static final String DEFAULT_ROLE_CODE = "USER";
    public static final String ROLE_PREFIX = "ROLE_";

    // ==================== 登录日志相关 ====================
    public static final Integer LOGIN_STATUS_SUCCESS = 1;
    public static final Integer LOGIN_STATUS_FAILURE = 0;
    public static final String MSG_LOGIN_SUCCESS = "登录成功";

    // ==================== 通用常量 ====================
    public static final Integer USER_AGENT_MAX_LENGTH = 512; // UA 截断长度
    public static final String DEFAULT_DEVICE_TYPE = "web";  // 默认设备类型
    public static final long NANOS_PER_MILLI = 1_000_000L;   // 1毫秒对应的纳秒数
    // ==================== 安全策略相关 ====================
    public static final int LOGIN_MAX_FAIL = 5;                  // 最大失败次数
    public static final long LOGIN_LOCK_MINUTES = 15;            // 锁定时长(分钟)
    public static final long SECONDS_PER_MINUTE = 60;            // 1分钟对应的秒数



    // ==================== RefreshToken 相关 ====================
    public static final long REFRESH_TOKEN_EXPIRE_DAYS = 7; // 刷新令牌有效天数
    public static final Integer REVOKED_YES = 1;             // 已撤销
    public static final Integer REVOKED_NO = 0;              // 未撤销
    public static final String HASH_ALGORITHM_SHA256 = "SHA-256"; // 哈希算法

    // ==================== 缓存相关 ====================
    public static final String REDIS_TOKEN_BLACKLIST_PREFIX = "token:blacklist:";
    public static final String REDIS_BLACKLIST_VALUE = "1";  // 黑名单占位值

}