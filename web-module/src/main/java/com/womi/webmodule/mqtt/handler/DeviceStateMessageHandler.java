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
            // 1. 从 topic 提取 deviceId
            String deviceId = extractDeviceId(topic);
            if (deviceId == null) {
                log.warn("无法提取设备ID - Topic: {}", topic);
                return;
            }

            // 2. 解析 payload
            JsonNode json = jsonUtils.parse(payload);
            if (json == null) return;

            // 3. 进入 data 节点，提取具体状态信息
            JsonNode dataNode = json.path(DeviceMqttConstants.FIELD_DATA);
            String target = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_TARGET); // 如 led
            Integer channel = jsonUtils.getInt(dataNode, DeviceMqttConstants.FIELD_CHANNEL); // 如 1
            Integer state = jsonUtils.getInt(dataNode, DeviceMqttConstants.FIELD_STATE);     // 如 1

            if (target == null || state == null) {
                log.warn("状态上报缺少必要字段 - deviceId: {}", deviceId);
                return;
            }

            // 4. 调用 Service 层更新主表的 current_state (精准更新某一路)
            deviceInfoService.updateSpecificState(deviceId, target, channel, state);

            // 5. 记录状态变更时序轨迹
            Map<String, Object> paramsMap = new HashMap<>();
            paramsMap.put(DeviceMqttConstants.FIELD_STATE, state);
            stateRecordService.recordState(deviceId, target, channel, paramsMap, LocalDateTime.now());

            log.info("设备状态变更落库 - deviceId: {}, target: {}, channel: {}, state: {}",
                    deviceId, target, channel, state);
            // 推送给前端
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