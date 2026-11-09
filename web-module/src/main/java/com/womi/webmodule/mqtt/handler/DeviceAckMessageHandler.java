package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.businessmodule.vo.device.CommandResultVO;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import com.womi.webmodule.service.common.WebSocketPushService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * 设备 ACK 处理器
 * topic: {@code device/{mac}/ack}
 * {
 *   "device": "B4BFE90CDBA0",
 *   "commandId": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
 *   "type": "ack",
 *   "success": true,
 *   "timestamp": 1710000000000,
 *   "data": { "state": 1, "brightness": 80 },
 *   "message": null
 * }
 * 处理完成后通过 WebSocket 推送 {@code command_result}，让前端实时感知指令最终结果
 */
@Slf4j
@Component
@Order(3)
@RequiredArgsConstructor
public class DeviceAckMessageHandler implements MqttMessageHandler {

    private final JsonUtils jsonUtils;
    private final DeviceCommandService deviceCommandService;
    private final WebSocketPushService webSocketPushService;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(DeviceMqttConstants.ACK_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        String deviceId = extractDeviceId(topic);
        JsonNode json = jsonUtils.parse(payload);

        String commandId = jsonUtils.getString(json, DeviceMqttConstants.FIELD_COMMAND_ID);
        if (commandId == null || commandId.isBlank()) {
            throw new IllegalArgumentException("ACK 缺少 commandId");
        }
        log.info("设备 ACK 接收 - commandId: [{}], deviceId: {}", commandId, deviceId);

        Boolean success = jsonUtils.getBoolean(json, DeviceMqttConstants.FIELD_SUCCESS);
        if (success == null) {
            success = false; // 默认按失败处理
        }
        String msg = jsonUtils.getString(json, DeviceMqttConstants.FIELD_MESSAGE);
        Map<String, Object> data = jsonUtils.nodeToMap(json.path(DeviceMqttConstants.FIELD_DATA));

        DeviceCommand command = deviceCommandService.handleAck(deviceId, commandId, success, data, msg);
        if (command == null) {
            // 指令不存在、越权 ACK 或重复 ACK：不推送，避免前端收到错误结果
            return;
        }
        pushResult(deviceId, command);
    }

    /**
     * 推送指令结果；推送失败不影响 ACK 主流程（状态已落库）。
     */
    private void pushResult(String deviceId, DeviceCommand command) {
        try {
            webSocketPushService.pushCommandResult(deviceId, CommandResultVO.of(command));
        } catch (Exception e) {
            log.error("指令结果 WebSocket 推送失败 - commandId: {}", command.getCommandId(), e);
        }
    }
}
