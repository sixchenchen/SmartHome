package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.enums.DeviceOfflineReason;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Map;

/*
  设备离线处理器
  topic: device/{mac}/offline  device/{mac}/will
  payload:
   {
    "device": "B4BFE90CDBA1",
    "type": "offline",
    "timestamp": 1710000000000,
    "data": {
      "product": "SmartHome-v1",
      "reason": "shutdown"
    }
  }
 */
@Slf4j
@Component
@Order(1)
@RequiredArgsConstructor
public class DevicePresenceMessageHandler implements MqttMessageHandler {

    private final JsonUtils jsonUtils;
    private final DeviceInfoService deviceInfoService;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(DeviceMqttConstants.PRESENCE_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        try {
            String deviceId = extractDeviceId(topic);
            if (deviceId == null) {
                log.warn("无法提取 deviceId - topic: {}", topic);
                return;
            }

            JsonNode json = jsonUtils.parse(payload);
            if (json == null) {
                log.warn("presence payload 解析失败 - topic: {}", topic);
                return;
            }

            String type = jsonUtils.getString(json, DeviceMqttConstants.FIELD_TYPE);
            JsonNode dataNode = json.path(DeviceMqttConstants.FIELD_DATA);

            if (DeviceMqttConstants.MSG_TYPE_ONLINE.equals(type)) {
                handleOnline(deviceId, dataNode);
            } else if (DeviceMqttConstants.MSG_TYPE_OFFLINE.equals(type)) {
                handleOffline(deviceId, dataNode);
            } else {
                log.warn("未知 presence type - deviceId: {}, type: {}", deviceId, type);
            }

        } catch (Exception e) {
            log.error("处理 presence 消息失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }

    private void handleOnline(String deviceId, JsonNode dataNode) {
        String product = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_PRODUCT);
        String firmware = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_FIRMWARE);
        Map<String, Object> capabilities = jsonUtils.nodeToMap(dataNode.path(DeviceMqttConstants.FIELD_CAPABILITIES));
        deviceInfoService.markOnline(deviceId, product, firmware, capabilities.isEmpty() ? null : capabilities);
        deviceInfoService.reconcileOtaOnOnline(deviceId, firmware);
        log.info("设备上线 - deviceId: {}, product: {}, firmware: {}", deviceId, product, firmware);
    }

    private void handleOffline(String deviceId, JsonNode dataNode) {
        String reason = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_REASON);
        if (reason == null || reason.isBlank()) {
            reason = DeviceOfflineReason.MQTT_LWT.getCode();
        }
        deviceInfoService.markOffline(deviceId, DeviceOfflineReason.fromCode(reason));
        log.info("设备离线 - deviceId: {}, reason: {}", deviceId, reason);
    }
}