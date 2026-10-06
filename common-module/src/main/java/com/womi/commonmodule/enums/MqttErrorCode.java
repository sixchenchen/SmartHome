package com.womi.commonmodule.enums;

/**
 * MQTT 错误码
 */
public enum MqttErrorCode {

    // ==================== 通用 ====================
    INVALID_PAYLOAD("INVALID_PAYLOAD", "payload 格式错误"),
    SERVER_ERROR("SERVER_ERROR", "服务器处理失败"),
    UNKNOWN_ERROR("UNKNOWN_ERROR", "未知错误"),

    // ==================== 注册相关 ====================
    INVALID_DEVICE_ID("INVALID_DEVICE_ID", "设备ID为空"),
    DEVICE_NOT_REGISTERED("DEVICE_NOT_REGISTERED", "设备未注册"),
    DEVICE_BLACKLISTED("DEVICE_BLACKLISTED", "设备已被拉黑"),
    DEVICE_ALREADY_REGISTERED("DEVICE_ALREADY_REGISTERED", "设备已注册"),
    FIRMWARE_TOO_OLD("FIRMWARE_TOO_OLD", "固件版本过低"),
    INVALID_SIGNATURE("INVALID_SIGNATURE", "签名验证失败"),
    INVALID_TIMESTAMP("INVALID_TIMESTAMP", "时间戳无效或已过期"),
    REPLAY_ATTACK("REPLAY_ATTACK", "重放攻击"),
    INVALID_PUBKEY("INVALID_PUBKEY", "公钥格式错误"),

    // ==================== 指令相关 ====================
    UNKNOWN_ACTION("UNKNOWN_ACTION", "不支持的动作"),
    UNKNOWN_TARGET("UNKNOWN_TARGET", "不支持的目标"),
    CHANNEL_NOT_FOUND("CHANNEL_NOT_FOUND", "通道不存在"),
    CHANNEL_OUT_OF_RANGE("CHANNEL_OUT_OF_RANGE", "通道号超出范围"),
    PARAM_MISSING("PARAM_MISSING", "缺少必要参数"),
    PARAM_INVALID("PARAM_INVALID", "参数值非法"),
    DEVICE_BUSY("DEVICE_BUSY", "设备忙"),
    EXECUTE_FAILED("EXECUTE_FAILED", "执行失败"),
    TIMEOUT("TIMEOUT", "执行超时"),
    COMMAND_NOT_FOUND("COMMAND_NOT_FOUND", "指令不存在"),

    // ==================== OTA 相关 ====================
    URL_UNREACHABLE("URL_UNREACHABLE", "URL 不可达"),
    MD5_MISMATCH("MD5_MISMATCH", "MD5 校验失败"),
    NO_SPACE("NO_SPACE", "空间不足"),
    VERSION_INCOMPATIBLE("VERSION_INCOMPATIBLE", "版本不兼容"),
    FLASH_FAILED("FLASH_FAILED", "刷写失败"),
    OTA_TIMEOUT("OTA_TIMEOUT", "OTA 超时");

    private final String code;
    private final String defaultMessage;

    MqttErrorCode(String code, String defaultMessage) {
        this.code = code;
        this.defaultMessage = defaultMessage;
    }

    public String getCode() {
        return code;
    }

    public String getDefaultMessage() {
        return defaultMessage;
    }

    /**
     * 根据 code 查找枚举
     */
    public static MqttErrorCode fromCode(String code) {
        for (MqttErrorCode e : values()) {
            if (e.code.equals(code)) {
                return e;
            }
        }
        return UNKNOWN_ERROR;
    }
}