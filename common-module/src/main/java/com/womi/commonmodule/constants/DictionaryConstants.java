package com.womi.commonmodule.constants;

import java.util.List;
import java.util.Map;

/**
 * 字典下发常量
 */
public final class DictionaryConstants {

    private DictionaryConstants() {
    }

    // ==================== 字典 key ====================

    public static final String KEY_ROLES = "roles";
    public static final String KEY_USER_STATUS = "userStatus";
    public static final String KEY_DEVICE_ONLINE = "deviceOnline";
    public static final String KEY_COMMAND_STATUS = "commandStatus";
    public static final String KEY_OTA_STATE = "otaState";
    public static final String KEY_ALERT_LEVEL = "alertLevel";
    public static final String KEY_ALERT_STATUS = "alertStatus";
    public static final String KEY_PRODUCTS = "products";

    // ==================== 字典项字段 ====================

    public static final String FIELD_CODE = "code";
    public static final String FIELD_NAME = "name";
    public static final String FIELD_VALUE = "value";
    public static final String FIELD_LABEL = "label";

    // ==================== 告警级别（暂无独立枚举，集中在此维护） ====================

    public static final int ALERT_LEVEL_INFO = 1;
    public static final int ALERT_LEVEL_WARNING = 2;
    public static final int ALERT_LEVEL_CRITICAL = 3;

    /** 告警级别与文案 */
    public static final List<Map.Entry<Integer, String>> ALERT_LEVELS = List.of(
            Map.entry(ALERT_LEVEL_INFO, "提示"),
            Map.entry(ALERT_LEVEL_WARNING, "一般"),
            Map.entry(ALERT_LEVEL_CRITICAL, "严重")
    );
}
