package com.womi.webmodule.mqtt;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.womi.commonmodule.mqtt.MqttConstants;

/**
 * MQTT 消息处理器接口
 */
public interface MqttMessageHandler {

    /**
     * 判断是否支持该主题
     * @param topic MQTT 主题
     * @return true-支持，false-不支持
     */
    boolean supports(String topic);

    /**
     * 处理消息
     * @param topic MQTT 主题
     * @param payload 消息内容
     * @param qos 服务质量等级
     */
    void handle(String topic, String payload, Integer qos);

    /**
     * 获取处理器名称（用于日志）
     */
    default String getHandlerName() {
        return this.getClass().getSimpleName();
    }

    /**
     * 解析 JSON 消息
     */
    default JsonNode parsePayload(String payload) {
        try {
            return new ObjectMapper().readTree(payload);
        } catch (Exception e) {
            throw new RuntimeException("解析 JSON 失败: " + e.getMessage(), e);
        }
    }

    /**
     * 提取设备ID（从主题中）
     * 例如: device/123456/heart -> 123456
     */
    default String extractDeviceId(String topic) {
        if (topic == null) return null;
        String[] parts = topic.split("/");
        if (parts.length >= 3 && MqttConstants.DEVICE_TOPIC_PREFIX.equals(parts[0])) {
            return parts[1];
        }
        return null;
    }

    /**
     * 提取消息类型（从主题中）
     * 例如: device/123456/heart -> heart
     */
    default String extractMessageType(String topic) {
        if (topic == null) return null;
        String[] parts = topic.split("/");
        if (parts.length >= 3) {
            return parts[2];
        }
        return null;
    }
}