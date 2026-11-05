package com.womi.commonmodule.constants;

/**
 * 权限码常量
 */
public final class PermissionConstants {

    private PermissionConstants() {
    }

    // ==================== 用户管理 ====================
    public static final String USER_LIST = "user:list";
    public static final String USER_UPDATE = "user:update";
    public static final String USER_DELETE = "user:delete";

    // ==================== 设备管理 ====================
    public static final String DEVICE_LIST = "device:list";
    public static final String DEVICE_READ = "device:read";
    public static final String DEVICE_CREATE = "device:create";
    public static final String DEVICE_UPDATE = "device:update";
    public static final String DEVICE_DELETE = "device:delete";
    public static final String DEVICE_UNBIND = "device:unbind";

    // ==================== 指令 ====================
    public static final String COMMAND_SEND = "command:send";

    // ==================== 固件与 OTA ====================
    public static final String FIRMWARE_UPLOAD = "firmware:upload";
    public static final String FIRMWARE_DELETE = "firmware:delete";
    public static final String OTA_LIST = "ota:list";
    public static final String OTA_CREATE = "ota:create";
    public static final String OTA_CANCEL = "ota:cancel";

    // ==================== 告警 ====================
    public static final String ALERT_LIST = "alert:list";
    public static final String ALERT_HANDLE = "alert:handle";

    // ==================== 系统配置 ====================
    public static final String SYSTEM_CONFIG = "system:config";
}
