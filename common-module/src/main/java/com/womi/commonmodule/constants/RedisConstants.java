package com.womi.commonmodule.constants;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@Slf4j
public final class RedisConstants {
    /** 已绑定设备的 MAC 集合 */
    public static final String BOUND_DEVICES_KEY = "iot:bound:devices";
    public static final String REDIS_LOGIN_FAIL_PREFIX = "login:fail:";
    public static final String REDIS_LOGIN_LOCK_PREFIX = "login:lock:";
    public static final String REDIS_TOKEN_BLACKLIST_PREFIX = "token:blacklist:";
    public static final String REDIS_SHED_LOCK_PREFIX = "my-iot-lock";
    public static final String REDIS_LOCK_VALUE = "1";  // 锁定的占位值
    public static final String REDIS_BLACKLIST_VALUE = "1";  // 黑名单占位值
    /** 验证码缓存：captcha:{captchaId} */
    public static final String REDIS_CAPTCHA_PREFIX = "captcha:";
    /** 验证码校验失败次数：captcha:fail:{captchaId} */
    public static final String REDIS_CAPTCHA_FAIL_PREFIX = "captcha:fail:";
    /** 验证码获取限流：rate:captcha:{维度}:{窗口}:{标识} */
    public static final String REDIS_RATE_CAPTCHA_PREFIX = "rate:captcha:";
    /** 登录请求限流：rate:login:{维度}:{窗口}:{标识} */
    public static final String REDIS_RATE_LOGIN_PREFIX = "rate:login:";
    /** 风险失败计数：risk:fail:{维度}:{标识} */
    public static final String REDIS_RISK_FAIL_PREFIX = "risk:fail:";
    /** 人机验证标记：risk:slider:{标识} */
    public static final String REDIS_RISK_SLIDER_PREFIX = "risk:slider:";
    /** IP 临时封锁：risk:block:{标识} */
    public static final String REDIS_RISK_BLOCK_PREFIX = "risk:block:";
    /** 账号锁定标识后缀 */
    public static final String REDIS_ACCOUNT_SCOPE = "account:";
    /** IP 维度后缀 */
    public static final String REDIS_IP_SCOPE = "ip:";
    /** 设备维度后缀 */
    public static final String REDIS_DEVICE_SCOPE = "device:";
    /** 分钟窗口后缀 */
    public static final String REDIS_WINDOW_MINUTE = "min:";
    /** 小时窗口后缀 */
    public static final String REDIS_WINDOW_HOUR = "hour:";
    public static final String REGISTER_USER = "user";
}
