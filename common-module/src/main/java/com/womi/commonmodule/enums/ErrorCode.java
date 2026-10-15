package com.womi.commonmodule.enums;

/**
 * 统一错误码
 */
public enum ErrorCode {

    // ==================== 通用 ====================
    SUCCESS(200, "success"),
    FAIL(401, "fail"),
    PARAM_ERROR(1000, "参数错误"),
    PARAM_MISSING(1001, "缺少必要参数"),
    PARAM_INVALID(1002, "参数值非法"),
    PARAM_EMPTY(1003, "参数不能为空"),

    PASSWORD_EMPTY(1010, "密码不能为空"),
    PASSWORD_TOO_SHORT(1011, "密码长度不能少于6位"),

    // ==================== 业务 ====================
    BUSINESS_ERROR(2000, "业务异常"),

    // ==================== 文件 ====================
    FILE_EMPTY(4000, "文件为空"),
    FILE_TOO_LARGE(4001, "文件超过大小限制"),
    FILE_FORMAT_ERROR(4002, "文件格式错误"),
    FILE_UPLOAD_FAILED(4003, "文件上传失败"),
    FILE_NOT_FOUND(4004, "文件不存在"),

    // 固件
    FIRMWARE_EXIST(4100, "固件版本已存在"),
    FIRMWARE_NOT_FOUND(4101, "固件不存在"),
    FIRMWARE_DISABLED(4102, "固件已禁用"),
    FIRMWARE_FILE_TOO_LARGE(4103, "固件文件超过大小限制"),
    FIRMWARE_FILE_NOT_FOUND(4104, "固件文件不存在"),
    FIRMWARE_VERSION_EMPTY(4105, "版本号不能为空"),
    FIRMWARE_FORMAT_MUST_BIN(4106, "文件格式必须是 .bin"),

    // 设备
    DEVICE_NOT_FOUND(4200, "设备不存在"),
    DEVICE_OFFLINE(4201, "设备离线"),
    DEVICE_ID_EMPTY(4202, "设备ID为空"),
    DEVICE_ID_FORMAT_ERROR(4203, "设备ID格式错误"),
    MAC_FORMAT_ERROR(4204, "MAC 格式错误"),

    // OTA
    OTA_START_FAILED(4300, "OTA 触发失败"),
    OTA_IN_PROGRESS(4301, "OTA 正在进行中"),
    OTA_VERSION_INCOMPATIBLE(4302, "OTA 版本不兼容"),

    // ==================== 系统 ====================
    SYSTEM_ERROR(5000, "系统异常"),
    DB_ERROR(5001, "数据库异常"),
    NETWORK_ERROR(5002, "网络异常");

    private final int code;
    private final String message;

    ErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}