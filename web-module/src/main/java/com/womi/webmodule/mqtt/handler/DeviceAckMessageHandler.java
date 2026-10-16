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
            // 1. 提取 deviceId
            String deviceId = extractDeviceId(topic);
            if (deviceId == null) {
                log.warn("无法提取设备ID - Topic: {}", topic);
                return;
            }

            // 2. 解析 payload
            JsonNode json = jsonUtils.parse(payload);
            if (json == null) {
                log.warn("ACK payload 解析失败 - Topic: {}", topic);
                return;
            }

            // 3. 提取 commandId
            String commandId = jsonUtils.getString(json, DeviceMqttConstants.FIELD_COMMAND_ID);
            if (commandId == null || commandId.isBlank()) {
                log.warn("ACK 缺少 commandId - deviceId: {}", deviceId);
                return;
            }

            // 4. 提取 success（缺失时按失败处理）
            Boolean success = jsonUtils.getBoolean(json, DeviceMqttConstants.FIELD_SUCCESS);
            if (success == null) {
                log.warn("ACK 缺少 success 字段，按失败处理 - commandId: {}", commandId);
                success = false;
            }

            // 5. 提取 msg
            String msg = jsonUtils.getString(json, DeviceMqttConstants.FIELD_MESSAGE);

            // 6. 提取 data 节点 → Map
            JsonNode dataNode = json.path(DeviceMqttConstants.FIELD_DATA);
            Map<String, Object> data = jsonUtils.nodeToMap(dataNode);

            // 7. 校验 device 与 topic 是否一致（仅告警，以 topic 为准）
            String payloadDevice = jsonUtils.getString(json, DeviceMqttConstants.FIELD_DEVICE);
            if (payloadDevice != null && !payloadDevice.equals(deviceId)) {
                log.warn("ACK device 与 topic 不一致 - topic: {}, payload.device: {}", topic, payloadDevice);
            }

            // 8. 调 Service 处理
            deviceCommandService.handleAck(commandId, success, data, msg);

            log.info("设备 ACK 已处理 - commandId: {}, deviceId: {}, success: {}", commandId, deviceId, success);

        } catch (Exception e) {
            log.error("处理 ACK 消息失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}