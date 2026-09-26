package com.womi.commonmodule.schedule;

/**
 * 调度参数常量
 */
public final class ScheduleConstants {
    private ScheduleConstants() {} // 防止实例化

    /** 待下发指令扫描间隔（毫秒） */
    public static final long DISPATCH_FIXED_DELAY = 5000L;

    /** 超时未 ACK 指令重试间隔（毫秒） */
    public static final long RETRY_FIXED_DELAY = 30000L;

    /** 过期指令标记间隔（毫秒） */
    public static final long MARK_EXPIRED_FIXED_DELAY = 60000L;

    /** 单批处理条数 */
    public static final int BATCH_SIZE = 50;

    /** 重试超时阈值（秒） */
    public static final int RETRY_TIMEOUT_SECONDS = 30;

    /** 历史指令清理保留天数 */
    public static final int CLEAN_RETENTION_DAYS = 30;

    /** 每日清理历史指令 cron */
    public static final String CLEAN_HISTORY_CRON = "0 0 2 * * ?";
}