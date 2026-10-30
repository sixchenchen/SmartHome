package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Map;

/*
  设备 ACK 处理器
  topic: device/{mac}/ack
  payload:
  {
    "device": "B4BFE90CDBA0",
    "commandId": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "type": "ack",
    "success": true,
    "timestamp": 1710000000000,
    "data": { "state": 1, "brightness": 80 },
    "message": null
  }
*/
@Slf4j
@Component
@Order(3)
@RequiredArgsConstructor
public class DeviceAckMessageHandler implements MqttMessageHandler {

    private final JsonUtils jsonUtils;
    private final DeviceCommandService deviceCommandService;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(DeviceMqttConstants.ACK_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        try {
            String deviceId = extractDeviceId(topic);
            JsonNode json = jsonUtils.parse(payload);

            String commandId = jsonUtils.getString(json, DeviceMqttConstants.FIELD_COMMAND_ID);
            if (commandId == null || commandId.isBlank()) {
                throw new IllegalArgumentException("ACK 缺少 commandId");
            }

            Boolean success = jsonUtils.getBoolean(json, DeviceMqttConstants.FIELD_SUCCESS);
            if (success == null) success = false; // 默认按失败处理

            String msg = jsonUtils.getString(json, DeviceMqttConstants.FIELD_MESSAGE);
            Map<String, Object> data = jsonUtils.nodeToMap(json.path(DeviceMqttConstants.FIELD_DATA));

            // 调用 Service
            deviceCommandService.handleAck(commandId, success, data, msg);
        } catch (Exception e) {
            log.error("处理 ACK 消息失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}