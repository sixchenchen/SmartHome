package com.womi.commonmodule.enums;

/**
 * 离线原因
 *
 * <p>对应数据库 device_info.offline_reason (varchar)
 */
public enum OfflineReason {

    SHUTDOWN("shutdown", "正常关机"),
    FACTORY_RESET("factory_reset", "恢复出厂"),
    MQTT_LWT("mqtt_lwt", "MQTT 遗嘱（异常断线）"),
    HEARTBEAT_TIMEOUT("heartbeat_timeout", "心跳超时"),
    MANUAL("manual", "手动下线");

    private final String code;
    private final String message;

    OfflineReason(String code, String message) {
        this.code = code;
        this.message = message;
    }

    /** 数据库存储值 */
    public String getCode() {
        return code;
    }

    /** 描述信息 */
    public String getMessage() {
        return message;
    }

    /** 根据 code 反查枚举 */
    public static OfflineReason fromCode(String code) {
        if (code == null) {
            return null;
        }
        for (OfflineReason reason : values()) {
            if (reason.code.equals(code)) {
                return reason;
            }
        }
        return null;
    }
}