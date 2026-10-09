package com.womi.commonmodule.utils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 日期时间工具
 *
 * <p>统一管理时间格式化和常用格式。
 */
public final class DateTimeUtils {

    private DateTimeUtils() {}

    // ==================== 常用格式 ====================

    /** 标准日期时间：yyyy-MM-dd HH:mm:ss */
    public static final String PATTERN_DATETIME = "yyyy-MM-dd HH:mm:ss";

    /** 紧凑日期时间（用于文件名）：yyyyMMddHHmmss */
    public static final String PATTERN_COMPACT = "yyyyMMddHHmmss";

    /** 仅日期：yyyy-MM-dd */
    public static final String PATTERN_DATE = "yyyy-MM-dd";

    /** 仅时间：HH:mm:ss */
    public static final String PATTERN_TIME = "HH:mm:ss";

    /** 带毫秒：yyyy-MM-dd HH:mm:ss.SSS */
    public static final String PATTERN_DATETIME_MS = "yyyy-MM-dd HH:mm:ss.SSS";

    // ==================== Formatter 缓存（线程安全） ====================

    private static final DateTimeFormatter FORMATTER_DATETIME =
            DateTimeFormatter.ofPattern(PATTERN_DATETIME);
    private static final DateTimeFormatter FORMATTER_COMPACT =
            DateTimeFormatter.ofPattern(PATTERN_COMPACT);
    private static final DateTimeFormatter FORMATTER_DATE =
            DateTimeFormatter.ofPattern(PATTERN_DATE);
    private static final DateTimeFormatter FORMATTER_TIME =
            DateTimeFormatter.ofPattern(PATTERN_TIME);
    private static final DateTimeFormatter FORMATTER_DATETIME_MS =
            DateTimeFormatter.ofPattern(PATTERN_DATETIME_MS);

    // ==================== 格式化 ====================

    /** 格式化为 yyyy-MM-dd HH:mm:ss */
    public static String formatDateTime(LocalDateTime time) {
        return time == null ? null : time.format(FORMATTER_DATETIME);
    }

    /** 格式化为 yyyyMMddHHmmss */
    public static String formatCompact(LocalDateTime time) {
        return time == null ? null : time.format(FORMATTER_COMPACT);
    }

    /** 格式化为 yyyy-MM-dd */
    public static String formatDate(LocalDateTime time) {
        return time == null ? null : time.format(FORMATTER_DATE);
    }

    /** 格式化为 HH:mm:ss */
    public static String formatTime(LocalDateTime time) {
        return time == null ? null : time.format(FORMATTER_TIME);
    }

    /** 格式化为 yyyy-MM-dd HH:mm:ss.SSS */
    public static String formatDateTimeMs(LocalDateTime time) {
        return time == null ? null : time.format(FORMATTER_DATETIME_MS);
    }

    /** 使用自定义格式 */
    public static String format(LocalDateTime time, String pattern) {
        if (time == null) return null;
        return time.format(DateTimeFormatter.ofPattern(pattern));
    }

    // ==================== 当前时间快捷方法 ====================
    /** 当前时间的紧凑格式（yyyyMMddHHmmss） */
    public static String nowCompact() {
        return LocalDateTime.now().format(FORMATTER_COMPACT);
    }

    /** 当前时间的标准格式 */
    public static String nowDateTime() {
        return LocalDateTime.now().format(FORMATTER_DATETIME);
    }
}