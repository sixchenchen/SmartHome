package com.womi.webmodule.service.security;

/**
 * 限流与风控服务
 *
 * <p>负责第一层（验证码获取限流）、第二层（登录请求限流）以及第三层中
 * 属于 IP/设备维度的失败计数与风控升级；账号维度由 {@code LoginAttemptService} 负责。</p>
 */
public interface RateLimitService {

    /** 第一层：校验验证码获取频率，超限抛限流异常 */
    void checkCaptchaAccess(String ip, String deviceId);

    /** 第二层：校验登录请求频率，超限抛限流异常（发生在验证码校验之前） */
    void checkLoginAccess(String ip, String deviceId, String username);

    /** 第三层：验证码错误，计入 IP/设备失败计数并触发风控升级 */
    void recordCaptchaFailure(String ip, String deviceId);

    /** 第三层：账号不存在，计入 IP/设备失败计数（防用户枚举） */
    void recordAnonymousFailure(String ip, String deviceId);
}
