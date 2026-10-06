package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.businessmodule.service.HeartbeatRecordService;
import com.womi.commonmodule.constants.MqttConstants;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * 心跳处理器
 * topic: device/{mac}/heartbeat
 * <p>
 * payload:
 * {
 * "device": "B4BFE90CDBA0",
 * "product": "SmartHome-v1",
 * "type": "heartbeat",
 * "timestamp": 1710000000000,
 * "data": { "uptime": 1234, "rssi": -65 }
 * }
 */
@Slf4j
@Component
@Order(3)
@RequiredArgsConstructor
public class HeartbeatMessageHandler implements MqttMessageHandler {

    private final JsonUtils jsonUtils;
    private final ObjectMapper objectMapper;
    private final DeviceInfoService deviceInfoService;
    private final HeartbeatRecordService heartbeatRecordService;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(MqttConstants.HEARTBEAT_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        try {
            // 1. 提取 deviceId
            String deviceId = extractDeviceId(topic);
            if (deviceId == null) {
                log.warn("无法提取设备ID - Topic: {}", topic);
                return;
            }

            // 2. 解析 payload
            JsonNode json = jsonUtils.parse(payload);
            if (json == null) {
                log.warn("payload 解析失败 - Topic: {}", topic);
                return;
            }
            JsonNode dataNode = json.path(MqttConstants.FIELD_DATA);
            Long uptime = jsonUtils.getLong(dataNode, MqttConstants.FIELD_UPTIME);
            // 3. 更新设备心跳（同时把设备标记为在线）
            deviceInfoService.updateHeartbeat(deviceId, uptime, payload);
            // 4. 写心跳历史
            heartbeatRecordService.recordHeartbeat(deviceId, uptime, payload);
            log.debug("心跳处理完成 - deviceId: {}, uptime: {}", deviceId, uptime);
        } catch (Exception e) {
            log.error("处理心跳消息失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}