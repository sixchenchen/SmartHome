package com.womi.commonmodule.constants;

import com.womi.commonmodule.enums.DeviceCommandStatus;

import java.util.Arrays;
import java.util.List;

/**
 * 指令领域常量
 */
public final class DeviceCommandConstants {
    // ==================== 状态集合 ====================

    /** 终态：不再变化，无需重试 */
    public static final List<Integer> FINISHED_STATUSES = Arrays.stream(DeviceCommandStatus.values())
            .filter(DeviceCommandStatus::isFinished)
            .map(DeviceCommandStatus::getCode)
            .toList();

    /** 中间态：可能继续流转 */
    public static final List<Integer> PENDING_STATUSES = List.of(
            DeviceCommandStatus.PENDING.getCode(),
            DeviceCommandStatus.SENT.getCode(),
            DeviceCommandStatus.ACCEPTED.getCode() // 视业务而定，如果有需要可以加上
    );

    // ==================== 默认参数 ====================

    /** 普通指令默认过期秒数：30 秒 */
    public static final int DEFAULT_EXPIRE_SECONDS = 30;

    /** 长流程指令过期秒数：5 分钟（配置下发等） */
    public static final int LONG_EXPIRE_SECONDS = 5 * 60;

    /** OTA 指令过期秒数：5 分钟 */
    public static final int OTA_EXPIRE_SECONDS = 5 * 60;

    /** 默认最大重试次数 */
    public static final int DEFAULT_MAX_RETRY = 3;

    /** 默认 QoS */
    public static final int DEFAULT_QOS = 1;

    /** 默认 retain */
    public static final int DEFAULT_RETAIN = 0;

    // ==================== 操作人与来源 ====================

    /** 系统默认操作人 */
    public static final String DEFAULT_OPERATOR = "system";

    /** Web 接口默认操作人 */
    public static final String WEB_DEFAULT_OPERATOR = "web-user";

    /** 指令来源：Web 接口 */
    public static final String SOURCE_WEB = "WEB";

    /** 指令来源：系统自动触发 */
    public static final String SOURCE_SYSTEM = "SYSTEM";

    /** 指令来源：规则引擎 */
    public static final String SOURCE_RULE = "RULE";
    // ==================== 错误消息 ====================

    /** ACK 失败时的默认原因 */
    public static final String DEFAULT_FAIL_MSG = "设备执行失败";

    // ==================== 错误消息（带占位符） ====================

    public static final String ERR_FALLBACK_RETRY_EXCEEDED = "兜底重试超过最大次数: %d";
    public static final String ERR_TIMEOUT_RETRY_EXCEEDED = "超时重试超过最大次数: %d";
    public static final String ERR_MQTT_SEND_FAILED = "MQTT 发送失败: %s";
    public static final String ERR_DEVICE_OFFLINE = "设备离线，无法下发指令";
    public static final String ERR_DEVICE_NOT_FOUND = "设备不存在";
    public static final String ERR_COMMAND_EXPIRED = "指令已过期";
    public static final String ERR_ACK_TIMEOUT = "等待设备 ACK 超时";
    public static final String ERR_DEVICE_RETURNED_FAILURE = "设备返回失败";
    public static final String ERR_CANCELLED_BY_USER = "用户主动取消";
}