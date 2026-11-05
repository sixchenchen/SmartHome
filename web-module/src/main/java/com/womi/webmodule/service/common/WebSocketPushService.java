package com.womi.webmodule.service.common;

import com.womi.businessmodule.vo.WebSocketMessageVO;
import com.womi.commonmodule.constants.WebSocketConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

/**
 * WebSocket 推送服务
 * <p>统一使用 {@link WebSocketMessageVO} 信封：{type, deviceId, timestamp, data}。</p>
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class WebSocketPushService {

    private final SimpMessagingTemplate messagingTemplate;

    /**
     * 推送设备状态变化
     */
    public void pushDeviceState(String deviceId, Object stateData) {
        send(deviceId, WebSocketConstants.MSG_TYPE_STATE, stateData);
    }

    /**
     * 推送实时传感器数据（前端画折线图）
     */
    public void pushSensorData(String deviceId, Object sensorData) {
        send(deviceId, WebSocketConstants.MSG_TYPE_SENSOR, sensorData);
    }

    /**
     * 推送告警信息
     */
    public void pushAlert(String deviceId, Object alertData) {
        send(deviceId, WebSocketConstants.MSG_TYPE_ALERT, alertData);
    }

    /**
     * 推送 OTA 升级进度
     */
    public void pushOtaProgress(String deviceId, Object progressData) {
        send(deviceId, WebSocketConstants.MSG_TYPE_OTA_PROGRESS, progressData);
    }

    /**
     * 推送控制指令执行结果（设备 ACK 回执）
     */
    public void pushCommandResult(String deviceId, Object resultData) {
        send(deviceId, WebSocketConstants.MSG_TYPE_COMMAND_RESULT, resultData);
    }

    private void send(String deviceId, String type, Object data) {
        String topic = String.format(WebSocketConstants.DEVICE_TOPIC_FORMAT, deviceId, topicOf(type));
        WebSocketMessageVO<Object> message = WebSocketMessageVO.of(type, deviceId, data);
        messagingTemplate.convertAndSend(topic, message);
        log.debug("WebSocket 推送 - topic: {}, type: {}", topic, type);
    }

    private String topicOf(String type) {
        return switch (type) {
            case WebSocketConstants.MSG_TYPE_STATE -> WebSocketConstants.TOPIC_STATE;
            case WebSocketConstants.MSG_TYPE_SENSOR -> WebSocketConstants.TOPIC_SENSOR;
            case WebSocketConstants.MSG_TYPE_ALERT -> WebSocketConstants.TOPIC_ALERT;
            case WebSocketConstants.MSG_TYPE_OTA_PROGRESS -> WebSocketConstants.TOPIC_OTA;
            case WebSocketConstants.MSG_TYPE_COMMAND_RESULT -> WebSocketConstants.TOPIC_COMMAND;
            default -> type;
        };
    }
}
