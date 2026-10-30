package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.businessmodule.service.device.DeviceStateRecordService;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import com.womi.webmodule.service.common.WebSocketPushService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 设备外设状态变更处理器
 * Topic: device/{mac}/state
 * {
 *   "device": "B4BFE90CDBA1",
 *   "type": "state",
 *   "timestamp": 1710000000000,
 *   "data": {
 *     "target": "led",
 *     "channel": 1,
 *     "state": 1
 *   }
 * }
 */


@Slf4j
@Component
@Order(4) // 排在心跳之后
@RequiredArgsConstructor
public class DeviceStateMessageHandler implements MqttMessageHandler {

    private final JsonUtils jsonUtils;
    private final DeviceInfoService deviceInfoService;
    private final DeviceStateRecordService stateRecordService;
    private final WebSocketPushService webSocketPushService;
    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(DeviceMqttConstants.STATE_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        try {
            String deviceId = extractDeviceId(topic);
            JsonNode json = jsonUtils.parse(payload);
            JsonNode dataNode = json.path(DeviceMqttConstants.FIELD_DATA);

            String target = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_TARGET);
            Integer channel = jsonUtils.getInt(dataNode, DeviceMqttConstants.FIELD_CHANNEL);
            Integer state = jsonUtils.getInt(dataNode, DeviceMqttConstants.FIELD_STATE);

            if (target == null || state == null) {
                throw new IllegalArgumentException("状态上报缺少 target 或 state");
            }

            deviceInfoService.updateSpecificState(deviceId, target, channel, state);

            Map<String, Object> paramsMap = new HashMap<>();
            paramsMap.put(DeviceMqttConstants.FIELD_STATE, state);
            stateRecordService.recordState(deviceId, target, channel, paramsMap, LocalDateTime.now());

            Map<String, Object> pushData = new HashMap<>();
            pushData.put("target", target);
            pushData.put("channel", channel);
            pushData.put("state", state);
            webSocketPushService.pushDeviceState(deviceId, pushData);

        } catch (Exception e) {
            log.error("处理设备状态失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}