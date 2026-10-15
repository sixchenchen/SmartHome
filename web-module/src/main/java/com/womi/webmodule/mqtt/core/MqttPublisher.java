package com.womi.webmodule.mqtt.core;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.integration.support.MessageBuilder;
import org.springframework.messaging.MessageChannel;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

@Slf4j
@Service
public class MqttPublisher {

    private final MessageChannel runtimeOutputChannel;
    private final MessageChannel provisionOutputChannel;
    private final ObjectMapper objectMapper;

    public MqttPublisher(
            @Qualifier("runtimeOutputChannel") MessageChannel runtimeOutputChannel,
            @Qualifier("provisionOutputChannel") MessageChannel provisionOutputChannel,
            ObjectMapper objectMapper) {
        this.runtimeOutputChannel = runtimeOutputChannel;
        this.provisionOutputChannel = provisionOutputChannel;
        this.objectMapper = objectMapper;
    }

    // ==================== 运行时：发布 ====================

    public void publish(String topic, Object payload) {
        publish(topic, payload, DeviceMqttConstants.DEFAULT_QOS, DeviceMqttConstants.DEFAULT_RETAINED);
    }

    public void publish(String topic, Object payload, int qos) {
        publish(topic, payload, qos, false);
    }

    /**
     * 运行时发布（走 1883）
     */
    public void publish(String topic, Object payload, int qos, boolean retained) {
        doPublish(runtimeOutputChannel, topic, payload, qos, retained, "RUNTIME");
    }

    // ==================== 注册：发布 ====================
    /**
     * 注册响应发布（走 1884）
     */
    public void publishProvision(String topic, Object payload, int qos, boolean retained) {
        doPublish(provisionOutputChannel, topic, payload, qos, retained, "PROVISION");
    }

    // ==================== 内部方法 ====================
    private void doPublish(MessageChannel channel, String topic, Object payload, int qos, boolean retained, String label) {
        try {
            String message = payload instanceof String
                    ? (String) payload
                    : objectMapper.writeValueAsString(payload);

            Map<String, Object> headers = new HashMap<>();
            headers.put(DeviceMqttConstants.MQTT_HEADER_TOPIC, topic);
            headers.put(DeviceMqttConstants.MQTT_HEADER_QOS, qos);
            headers.put(DeviceMqttConstants.MQTT_HEADER_RETAINED, retained);

            channel.send(MessageBuilder.withPayload(message).copyHeaders(headers).build());

            log.debug("[{}] MQTT 消息发布成功 - Topic: {}, QoS: {}, Retained: {}", label, topic, qos, retained);
        } catch (JsonProcessingException e) {
            log.error("[{}] MQTT 消息发布失败 - Topic: {}, Error: {}", label, topic, e.getMessage());
        }
    }

    // ==================== 业务方法 ====================
    public void sendControlCommand(String deviceId, String commandId,
                                   String action, String target,
                                   Integer channel, Map<String, Object> params) {
        String topic = String.format(DeviceMqttConstants.COMMAND_TOPIC_FORMAT, deviceId);

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put(DeviceMqttConstants.FIELD_COMMAND_ID, commandId);
        payload.put(DeviceMqttConstants.FIELD_ACTION, action);
        payload.put(DeviceMqttConstants.FIELD_TARGET, target);
        if (channel != null) {
            payload.put(DeviceMqttConstants.FIELD_CHANNEL, channel);
        }
        if (params != null && !params.isEmpty()) {
            payload.put(DeviceMqttConstants.FIELD_PARAMS, params);
        }
        payload.put(DeviceMqttConstants.FIELD_TIMESTAMP, System.currentTimeMillis());
        publish(topic, payload, DeviceMqttConstants.DEFAULT_QOS, false);
        log.info("MQTT 控制指令下发 - Topic: {}, commandId: {}, action: {}, target: {}, channel: {}", topic, commandId, action, target, channel);
    }

    public void sendConfigCommand(String deviceId, String commandId,
                                  Map<String, Object> config, Integer configVersion) {
        Map<String, Object> params = new LinkedHashMap<>();
        params.put(DeviceMqttConstants.FIELD_CONFIG, config);
        if (configVersion != null) {
            params.put(DeviceMqttConstants.FIELD_CONFIG_VERSION, configVersion);
        }
        params.put(DeviceMqttConstants.FIELD_PERSIST, true);

        sendControlCommand(deviceId, commandId, DeviceMqttConstants.ACTION_SET, DeviceMqttConstants.TARGET_CONFIG, null, params);
    }
}