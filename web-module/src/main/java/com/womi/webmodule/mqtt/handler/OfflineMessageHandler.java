package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.businessmodule.service.DeviceSlaveDataService;
import com.womi.commonmodule.enums.OfflineReason;
import com.womi.commonmodule.constants.MqttConstants;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * 设备离线处理器
 * topic: device/{mac}/offline
 * <p>
 * payload:
 * {
 * "device": "B4BFE90CDBA0",
 * "product": "SmartHome-v1",
 * "type": "offline",
 * "timestamp": 1710000000000,
 * "data": {
 * "reason": "shutdown"
 * }
 * }
 */
@Slf4j
@Component
@Order(1)
@RequiredArgsConstructor
public class OfflineMessageHandler implements MqttMessageHandler {


    private final JsonUtils jsonUtils;
    private final DeviceInfoService deviceInfoService;
    private final DeviceSlaveDataService deviceSlaveDataService;

    @Override
    public boolean supports(String topic) {
        return topic != null && (topic.matches(MqttConstants.OFFLINE_TOPIC_PATTERN) || topic.matches(MqttConstants.WILL_TOPIC_PATTERN));
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

            // 2. 判断 topic 类型
            boolean isWill = topic.matches(MqttConstants.WILL_TOPIC_PATTERN);

            // 3. 解析 payload
            OfflineReason reason = null;
            JsonNode json = jsonUtils.parse(payload);
            if (json != null) {
                JsonNode dataNode = json.path(MqttConstants.FIELD_DATA);
                String reasonCode = jsonUtils.getString(dataNode, MqttConstants.FIELD_REASON);
                reason = OfflineReason.fromCode(reasonCode);   // ← 用 fromCode 反查
            }

            // 4. 兜底
            if (reason == null) {
                reason = isWill ? OfflineReason.MQTT_LWT : OfflineReason.SHUTDOWN;
                log.warn("离线原因缺失，使用兜底值 - deviceId: {}, topic: {}, reason: {}",
                        deviceId, topic, reason.getCode());
            }

            // 5. 标记离线
            deviceInfoService.markOffline(deviceId, reason);

            log.info("设备离线 - deviceId: {}, reason: {}, topic: {}",
                    deviceId, reason.getCode(), topic);

        } catch (Exception e) {
            log.error("处理离线消息失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}