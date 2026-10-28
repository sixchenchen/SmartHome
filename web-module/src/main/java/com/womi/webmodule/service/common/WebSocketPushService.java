package com.womi.webmodule.service.common;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class WebSocketPushService {

    private final SimpMessagingTemplate messagingTemplate;

    /**
     * 推送设备状态变化
     */
    public void pushDeviceState(String deviceId, Object stateData) {
        String topic = "/topic/device/" + deviceId + "/state";
        messagingTemplate.convertAndSend(topic, stateData);
        log.debug("WebSocket 推送设备状态 - topic: {}", topic);
    }

    /**
     * 推送实时传感器数据（前端画折线图）
     */
    public void pushSensorData(String deviceId, Object sensorData) {
        String topic = "/topic/device/" + deviceId + "/sensor";
        messagingTemplate.convertAndSend(topic, sensorData);
        log.debug("WebSocket 推送传感器数据 - topic: {}", topic);
    }

    /**
     * 推送告警信息
     */
    public void pushAlert(String deviceId, Object alertData) {
        String topic = "/topic/device/" + deviceId + "/alert";
        messagingTemplate.convertAndSend(topic, alertData);
        log.warn("WebSocket 推送告警 - topic: {}", topic);
    }
}