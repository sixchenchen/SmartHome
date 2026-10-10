package com.womi.commonmodule.utils;

/**
 * 时间戳校验工具
 */
public final class TimestampValidatorUtils {

    private TimestampValidatorUtils() {}

    /**
     * 校验时间戳是否在指定窗口内
     *
     * @param timestamp 毫秒时间戳
     * @param windowMs  允许的时间窗口（毫秒）
     * @return true 有效
     */
    public static boolean isWithinWindow(Long timestamp, long windowMs) {
        if (timestamp == null) {
            return false;
        }
        return Math.abs(System.currentTimeMillis() - timestamp) <= windowMs;
    }
}