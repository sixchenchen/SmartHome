package com.womi.commonmodule.constants;

/**
 * 错误信息常量
 *
 * <p>统一管理业务错误提示文案，避免散落各处。
 */
public final class ErrorInfoConstants {

    private ErrorInfoConstants() {}

    // ==================== 通用 ====================
    /** 参数错误 */
    public static final String PARAM_ERROR = "参数错误";
    /** 参数为空 */
    public static final String PARAM_EMPTY = "参数不能为空";
    /** 缺少必要参数 */
    public static final String PARAM_MISSING = "缺少必要参数";
    /** 参数非法 */
    public static final String PARAM_INVALID = "参数值非法";
    /** 密码长度不能少于6位 */
    public static final String PASSWORD_TOO_SHOW = "密码长度不能少于6位";
    /** 密码为空 */
    public static final String PASSWORD_EMPTY = "密码不能为空";

    // ==================== 文件相关 ====================
    /** 文件为空 */
    public static final String FILE_EMPTY = "文件为空";
    /** 固件文件过大 */
    public static final String FIRMWARE_FILE_TOO_LARGE = "固件文件超过10MB";
    /** 版本号不能为空 */
    public static final String VERSION_EMPTY = "版本号不能为空";
    /** 文件格式必须是 .bin */
    public static final String FILE_FORMAT_MUST_BIN = "文件格式必须是 .bin";
    /** 固件已存在 */
    public static final String FIRMWARE_EXIST = "固件已存在";
    /** 固件上传失败 */
    public static final String FIRMWARE_UPLOAD_FAILED = "固件上传失败";
    /** 固件不存在 */
    public static final String FIRMWARE_NOT_FOUND = "固件不存在";
    /** 固件已禁用 */
    public static final String FIRMWARE_DISABLED = "固件已禁用";
    /** 固件文件不存在 */
    public static final String FIRMWARE_FILE_NOT_FOUND = "固件文件不存在";

    // ==================== 设备相关 ====================
    /** 设备不存在 */
    public static final String DEVICE_NOT_FOUND = "设备不存在";
    /** 设备离线 */
    public static final String DEVICE_OFFLINE = "设备离线";
    /** 设备ID为空 */
    public static final String DEVICE_ID_EMPTY = "设备ID为空";
    /** 设备ID格式错误 */
    public static final String DEVICE_ID_FORMAT_ERROR = "设备ID格式错误";
    /** MAC 格式错误 */
    public static final String MAC_FORMAT_ERROR = "MAC 格式错误";

    // ==================== OTA 相关 ====================
    /** OTA 触发失败 */
    public static final String OTA_START_FAILED = "OTA 触发失败";
    /** OTA 正在进行中 */
    public static final String OTA_IN_PROGRESS = "OTA 正在进行中";
    /** OTA 版本不兼容 */
    public static final String OTA_VERSION_INCOMPATIBLE = "OTA 版本不兼容";

    // ==================== 系统 ====================
    /** 系统异常 */
    public static final String SYSTEM_ERROR = "系统异常";
    /** 数据库异常 */
    public static final String DB_ERROR = "数据库异常";
    /** 网络异常 */
    public static final String NETWORK_ERROR = "网络异常";

    /**
     * 格式化：拼接自定义信息
     *
     * <p>例：{@code format(FIRMWARE_EXIST, "version=1.0.1")}
     * → {@code "固件已存在: version=1.0.1"}
     */
    public static String format(String message, String detail) {
        if (detail == null || detail.isBlank()) {
            return message;
        }
        return message + ": " + detail;
    }
}