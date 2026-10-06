package com.womi.webmodule.schedule.constants;

/**
 * 调度参数常量
 */
public final class ScheduleConstants {


    private ScheduleConstants() {
    } // 防止实例化

    /**
     * 心跳超时阈值（秒）：连续 3 个心跳周期未收到，判定离线
     */
    public static final int HEARTBEAT_TIMEOUT_SECONDS = 90;

    /**
     * 心跳超时扫描间隔（毫秒）：每 30 秒扫描一次
     */
    public static final long HEARTBEAT_SCAN_FIXED_DELAY = 30_000L;

    /**
     * 待下发指令扫描间隔（毫秒）
     */
    public static final long DISPATCH_FIXED_DELAY = 5000L;

    /**
     * 超时未 ACK 指令重试间隔（毫秒）
     */
    public static final long RETRY_FIXED_DELAY = 30000L;

    /**
     * 过期指令标记间隔（毫秒）
     */
    public static final long MARK_EXPIRED_FIXED_DELAY = 60000L;

    /**
     * 单批处理条数
     */
    public static final int BATCH_SIZE = 50;

    /**
     * 重试超时阈值（秒）
     */
    public static final int RETRY_TIMEOUT_SECONDS = 30;

    /**
     * 历史指令清理保留天数
     */
    public static final int CLEAN_RETENTION_DAYS = 30;

    /**
     * 每日清理历史指令 cron
     */
    public static final String CLEAN_HISTORY_CRON = "0 0 2 * * ?";
}