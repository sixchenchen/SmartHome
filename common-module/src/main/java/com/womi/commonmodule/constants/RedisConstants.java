package com.womi.commonmodule.constants;

public class RedisConstants {
    /** 已绑定设备的 MAC 集合 */
    public static final String BOUND_DEVICES_KEY = "iot:bound:devices";
    public static final String REDIS_LOGIN_FAIL_PREFIX = "login:fail:";
    public static final String REDIS_LOGIN_LOCK_PREFIX = "login:lock:";
    public static final String REDIS_LOCK_VALUE = "1";           // 锁定的占位值
}
