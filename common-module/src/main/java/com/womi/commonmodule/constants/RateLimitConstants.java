package com.womi.commonmodule.constants;

/**
 * 三层限流常量
 *
 * <p>第一层：验证码获取接口限流，抵御脚本疯狂刷新；
 * 第二层：登录请求整体限流，位于验证码校验之前；
 * 第三层：失败计数与风控升级，验证码错误按 IP/设备维度计数，密码错误按账号维度锁定。</p>
 */
public final class RateLimitConstants {

    private RateLimitConstants() {
    }

    // ==================== 第一层：验证码获取 ====================
    /** 同一 IP 每分钟获取次数上限 */
    public static final int CAPTCHA_IP_PER_MINUTE = 10;

    /** 同一 IP 每小时获取次数上限 */
    public static final int CAPTCHA_IP_PER_HOUR = 100;

    /** 同一设备每分钟获取次数上限 */
    public static final int CAPTCHA_DEVICE_PER_MINUTE = 5;

    // ==================== 第二层：登录请求 ====================
    /** 同一 IP 每分钟登录尝试上限，超限临时封 IP */
    public static final int LOGIN_IP_PER_MINUTE = 10;

    /** 同一 IP 每小时登录尝试上限，超限升级人机验证 */
    public static final int LOGIN_IP_PER_HOUR = 50;

    /** 同一设备每分钟登录尝试上限，超限升级人机验证 */
    public static final int LOGIN_DEVICE_PER_MINUTE = 5;

    /** 同一账号每分钟登录尝试上限，仅频率限制，不锁定账号 */
    public static final int LOGIN_ACCOUNT_PER_MINUTE = 5;

    // ==================== 第三层：失败计数与风控 ====================
    /** IP/设备每小时失败次数达到该值，强制人机验证 */
    public static final int RISK_SLIDER_THRESHOLD = 20;

    /** IP/设备每小时失败次数达到该值，临时封锁 IP */
    public static final int RISK_BLOCK_THRESHOLD = 50;

    /** 密码错误达到该次数，账号临时锁定 */
    public static final int PASSWORD_LOCK_THRESHOLD = UserConstants.LOGIN_MAX_FAIL;

    /** 密码错误达到该次数，账号长时间锁定 */
    public static final int PASSWORD_LOCK_LONG_THRESHOLD = 10;

    // ==================== 时长（秒） ====================
    /** 1 分钟 */
    public static final long ONE_MINUTE_SECONDS = 60L;

    /** 1 小时 */
    public static final long ONE_HOUR_SECONDS = 3600L;

    /** IP 临时封锁时长：15 分钟 */
    public static final long IP_BLOCK_SECONDS = 15 * ONE_MINUTE_SECONDS;

    /** 人机验证标记有效期：1 小时 */
    public static final long SLIDER_FLAG_SECONDS = ONE_HOUR_SECONDS;

    /** 密码错误临时锁定时长：15 分钟 */
    public static final long PASSWORD_LOCK_SECONDS = UserConstants.LOGIN_LOCK_MINUTES * UserConstants.SECONDS_PER_MINUTE;

    /** 密码错误长时间锁定时长：1 小时 */
    public static final long PASSWORD_LOCK_LONG_SECONDS = ONE_HOUR_SECONDS;

    /** 风控失败计数窗口：1 小时 */
    public static final long RISK_FAIL_WINDOW_SECONDS = ONE_HOUR_SECONDS;

    // ==================== 标识长度限制 ====================
    /** 设备指纹最大长度，防止超长 Key */
    public static final int MAX_DEVICE_ID_LENGTH = 128;

    /** 限流 Key 中用户名最大长度 */
    public static final int MAX_USERNAME_LENGTH = 64;
}
