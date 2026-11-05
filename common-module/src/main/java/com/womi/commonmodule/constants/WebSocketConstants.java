package com.womi.commonmodule.constants;

import java.util.List;

/**
 * WebSocket 通讯常量
 */
public final class WebSocketConstants {

    private WebSocketConstants() {
    }

    // ==================== 主题 ====================

    /** 主题根前缀 */
    public static final String TOPIC_PREFIX = "/topic/";

    /** 设备主题前缀：/topic/device/ */
    public static final String DEVICE_TOPIC_PREFIX = TOPIC_PREFIX + "device/";

    /** 设备主题格式：/topic/device/{deviceId}/{type} */
    public static final String DEVICE_TOPIC_FORMAT = DEVICE_TOPIC_PREFIX + "%s/%s";

    public static final String TOPIC_STATE = "state";
    public static final String TOPIC_SENSOR = "sensor";
    public static final String TOPIC_ALERT = "alert";
    public static final String TOPIC_OTA = "ota";
    public static final String TOPIC_COMMAND = "command";

    /** 普通用户可订阅的设备主题类型 */
    public static final List<String> DEVICE_TOPIC_TYPES = List.of(
            TOPIC_STATE, TOPIC_SENSOR, TOPIC_ALERT, TOPIC_OTA, TOPIC_COMMAND
    );

    /** 设备主题解析正则 */
    public static final String DEVICE_TOPIC_REGEX = "^" + DEVICE_TOPIC_PREFIX + "([^/]+)/([^/]+)$";

    // ==================== 消息类型 ====================

    public static final String MSG_TYPE_STATE = "state";
    public static final String MSG_TYPE_SENSOR = "sensor";
    public static final String MSG_TYPE_ALERT = "alert";
    public static final String MSG_TYPE_OTA_PROGRESS = "ota_progress";
    public static final String MSG_TYPE_COMMAND_RESULT = "command_result";

    // ==================== STOMP 会话属性 ====================

    /** 会话中的用户名（用户ID复用 UserConstants.USER_ID） */
    public static final String SESSION_USERNAME = "username";

    /** 会话中是否管理员 */
    public static final String SESSION_IS_ADMIN = "isAdmin";

    // ==================== 错误消息 ====================

    public static final String ERR_UNAUTHORIZED = "未认证，禁止订阅";
    public static final String ERR_DESTINATION_EMPTY = "订阅地址不能为空";
    public static final String ERR_DESTINATION_INVALID = "订阅地址不合法: %s";
    public static final String ERR_TOPIC_FORBIDDEN = "无权订阅该主题";
    public static final String ERR_DEVICE_FORBIDDEN = "无权订阅该设备的数据";
    public static final String ERR_DEVICE_ID_EMPTY = "设备ID不能为空";
    public static final String ERR_AUTH_MISSING = "缺少 Authorization Token";
    public static final String ERR_AUTH_FAILED = "认证失败，Token无效或已过期";
}
