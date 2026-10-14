package com.womi.commonmodule.constants;

/**
 * 设备领域常量
 */
public final class DeviceConstants {


    private DeviceConstants() {} // 防止实例化
    /** 设备状态 - 离线 */
    public static final int DEVICE_STATUS_OFFLINE = 0;
    /** 设备状态 - 在线 */
    public static final int DEVICE_STATUS_ONLINE = 1;
    /** 设备状态 - 故障 */
    public static final int DEVICE_STATUS_FAULT = 2;
    /** MQTT状态 - 启用 */
    public static final int MQTT_STATUS_ENABLE = 1;
    /** Firmware状态 - 启用 */
    public static final int FIRMWARE_STATUS_ENABLE = 1;
    /** Firmware状态 - 禁用 */
    public static final int FIRMWARE_STATUS_DISABLE = 0;
    /** pubkey 最大长度 */
    public static final int MAX_PUBKEY_LENGTH = 1024;
    /** nonce 最大长度 */
    public static final int MAX_NONCE_LENGTH = 64;
    /** signature 最大长度 */
    public static final int MAX_SIGNATURE_LENGTH = 1024;
    /** MQTT状态 - 禁用 */
    public static final int MQTT_STATUS_DISABLE = 0;
    /** 新建设备默认名称前缀 */
    public static final String DEVICE_NAME_PREFIX = "设备-";
    /** 各历史记录保存上限 */
    public static final int HEARTBEAT_HISTORY_LIMIT = 100;
    /** 从机记录查询条数 */
    public static final int RECENT_SLAVE_LIMIT = 20;
    /** 历史数据保留天数 */
    public static final int DATA_RETENTION_DAYS = 30;
}