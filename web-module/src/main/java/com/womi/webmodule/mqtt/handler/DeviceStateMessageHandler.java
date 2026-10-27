package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@Order(4) // 排在心跳之后
@RequiredArgsConstructor
public class DeviceStateMessageHandler implements MqttMessageHandler {

    private final JsonUtils jsonUtils;
    private final DeviceInfoService deviceInfoService; // 用于更新主表状态

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(DeviceMqttConstants.STATE_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        try {
            String deviceId = extractDeviceId(topic);
            JsonNode json = jsonUtils.parse(payload);
            if (deviceId == null || json == null) return;

            // 提取 data 部分（比如 {"led": 1, "mos": 0}）
            JsonNode dataNode = json.path(DeviceMqttConstants.FIELD_DATA);
            String currentState = dataNode.toString(); // 转成 JSON 字符串

            // 更新主表的 current_state 字段
            deviceInfoService.updateCurrentState(deviceId, currentState);

            //  进阶想法：这里就是触发 WebSocket 推送给前端的绝佳位置！
            // webSocketService.sendToUser(deviceId, currentState);

            log.info("设备状态更新 - deviceId: {}, state: {}", deviceId, currentState);

        } catch (Exception e) {
            log.error("处理设备状态失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}