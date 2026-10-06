package com.womi.webmodule.mqtt.core;

import com.womi.commonmodule.constants.MqttConstants;

/**
 * MQTT 消息处理器接口
 */
public interface MqttMessageHandler {

    /**
     * 判断是否支持该主题
     */
    boolean supports(String topic);

    /**
     * 处理消息
     */
    void handle(String topic, String payload, Integer qos);

    /**
     * 获取处理器名称（用于日志）
     */
    default String getHandlerName() {
        return this.getClass().getSimpleName();
    }

    // ==================== 设备 ID 提取 ====================

    /**
     * 提取设备 ID（普通 topic）
     * <p>例：device/B4BFE90CDBA0/heartbeat → B4BFE90CDBA0
     */
    default String extractDeviceId(String topic) {
        if (topic == null) return null;
        String[] parts = topic.split(MqttConstants.TOPIC_SEPARATOR);
        // parts = ["device", "{mac}", "xxx"]
        if (parts.length >= 3 && MqttConstants.DEVICE_TOPIC_PREFIX.equals(parts[0])) {
            return parts[1];
        }
        return null;
    }

    /**
     * 提取设备 ID（注册 topic）
     * <p>例：/provision/device/B4BFE90CDBA0/register → B4BFE90CDBA0
     */
    default String extractProvisionDeviceId(String topic) {
        if (topic == null) return null;
        String[] parts = topic.split(MqttConstants.TOPIC_SEPARATOR);
        // parts = ["", "provision", "device", "{mac}", "register"]
        if (parts.length >= 5
                && "provision".equals(parts[1])
                && MqttConstants.DEVICE_TOPIC_PREFIX.equals(parts[2])) {
            return parts[3];
        }
        return null;
    }

    // ==================== 消息类型提取 ====================

    /**
     * 提取消息类型（普通 topic）
     * <p>例：device/B4BFE90CDBA0/heartbeat → heartbeat
     */
    default String extractMessageType(String topic) {
        if (topic == null) return null;
        String[] parts = topic.split(MqttConstants.TOPIC_SEPARATOR);
        if (parts.length >= 3 && MqttConstants.DEVICE_TOPIC_PREFIX.equals(parts[0])) {
            return parts[2];
        }
        return null;
    }
}