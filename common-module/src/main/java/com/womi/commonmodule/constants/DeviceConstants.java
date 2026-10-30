package com.womi.commonmodule.constants;

/**
 * 设备领域常量
 */

public final class DeviceConstants {

    public static final int DEVICE_OFFLINE = 0;
    public static final int DEVICE_ONLINE = 1;
    /**
     * pubkey 最大长度
     */
    public static final int MAX_PUBKEY_LENGTH = 1024;
    /**
     * nonce 最大长度
     */
    public static final int MAX_NONCE_LENGTH = 64;
    /**
     * signature 最大长度
     */
    public static final int MAX_SIGNATURE_LENGTH = 1024;
    /**
     * 新建设备默认名称前缀
     */
    public static final String DEVICE_NAME_PREFIX = "设备-";
    /**
     * 各历史记录保存上限
     */
    public static final int HEARTBEAT_HISTORY_LIMIT = 100;
    /**
     * 从机记录查询条数
     */
    public static final int RECENT_SLAVE_LIMIT = 20;
    /**
     * 历史数据保留天数
     */
    public static final int DATA_RETENTION_DAYS = 30;
    /**
     * 心跳超时时间90秒
     */
    public static final long HEARTBEAT_OFFLINE_SECONDS = 90;
    /**
     * 传感器警告类型
     */
    public static final String DEVICE_SENSOR_ALERT_TYPE = "threshold";
    /** 白名单来源备注 */
    public static final String WHITELIST_REMARK_ADMIN_OVERRIDE = "管理员后台录入覆盖更新";
    public static final String WHITELIST_REMARK_ADMIN_CREATE   = "管理员后台录入自动生成";
    /** 指令来源：APP 用户端 */
    public static final String SOURCE_APP = "APP";
    /** 用户操作人前缀 */
    public static final String OPERATOR_USER_PREFIX = "user_";
    /** 初始重试次数 */
    public static final int INITIAL_RETRY_COUNT = 0;
}