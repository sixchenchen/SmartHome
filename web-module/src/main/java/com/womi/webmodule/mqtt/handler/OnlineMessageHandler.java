package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.commonmodule.constants.MqttConstants;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * 设备上线处理器
 * topic: device/{mac}/online
 * <p>
 * payload:
 * {
 * "device": "B4BFE90CDBA0",
 * "product": "SmartHome-v1",
 * "type": "online",
 * "timestamp": 1710000000000,
 * "data": {
 * "firmware": "1.0.29",
 * "capabilities": {
 * "mos": 8,
 * "led": 3,
 * "servo": 2
 * }
 * }
 * }
 */
@Slf4j
@Component
@Order(1)
@RequiredArgsConstructor
public class OnlineMessageHandler implements MqttMessageHandler {


    private final JsonUtils jsonUtils;
    private final ObjectMapper objectMapper;
    private final DeviceInfoService deviceInfoService;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(MqttConstants.ONLINE_TOPIC_PATTERN);
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
            String product = jsonUtils.getString(json, MqttConstants.FIELD_PRODUCT);
            JsonNode dataNode = json.path(MqttConstants.FIELD_DATA);
            String firmware = jsonUtils.getString(dataNode, MqttConstants.FIELD_FIRMWARE);
            // 3. 解析 capabilities（JSON 对象）
            Map<String, Object> capabilities = jsonUtils.nodeToMap(dataNode.path(MqttConstants.FIELD_CAPABILITIES));
            // 4. 标记设备上线
            deviceInfoService.markOnline(deviceId, product, firmware, capabilities.isEmpty() ? null : capabilities);
            log.info("设备上线 - deviceId: {}, product: {}, firmware: {}, capabilities: {}", deviceId, product, firmware, capabilities);
        } catch (Exception e) {
            log.error("处理上线消息失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}