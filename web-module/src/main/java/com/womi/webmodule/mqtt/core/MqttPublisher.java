package com.womi.webmodule.mqtt.core;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.womi.commonmodule.constants.MqttConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.integration.support.MessageBuilder;
import org.springframework.messaging.MessageChannel;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class MqttPublisher {

    private final MessageChannel mqttOutputChannel;
    private final ObjectMapper objectMapper;

    /**
     * 发布消息
     */
    public void publish(String topic, Object payload) {
        publish(topic, payload, MqttConstants.DEFAULT_QOS, MqttConstants.DEFAULT_RETAINED);
    }

    /**
     * 发布消息（指定QoS）
     */
    public void publish(String topic, Object payload, int qos) {
        publish(topic, payload, qos, false);
    }

    /**
     * 发布消息（完整参数）
     */
    public void publish(String topic, Object payload, int qos, boolean retained) {
        try {
            String message = payload instanceof String ? (String) payload : objectMapper.writeValueAsString(payload);

            Map<String, Object> headers = new HashMap<>();
            headers.put(MqttConstants.MQTT_HEADER_TOPIC, topic);
            headers.put(MqttConstants.MQTT_HEADER_QOS, qos);
            headers.put(MqttConstants.MQTT_HEADER_RETAINED, retained);
            mqttOutputChannel.send(MessageBuilder.withPayload(message).copyHeaders(headers).build()
            );

            log.debug("MQTT 消息发布成功 - Topic: {}, QoS: {}, Retained: {}",
                    topic, qos, retained);
        } catch (JsonProcessingException e) {
            log.error("MQTT 消息发布失败 - Topic: {}, Error: {}", topic, e.getMessage());
        }
    }

    /**
     * 下发控制指令
     *
     * <p>payload 结构:
     * <pre>
     * {
     *   "commandId": "uuid",
     *   "action": "set",
     *   "target": "mos",
     *   "channel": 1,
     *   "params": { "state": 1 },
     *   "timestamp": 1710000000000
     * }
     * </pre>
     */
    public void sendControlCommand(String deviceId,
                                   String commandId,
                                   String action,
                                   String target,
                                   Integer channel,
                                   Map<String, Object> params) {
        String topic = String.format(MqttConstants.COMMAND_TOPIC_FORMAT, deviceId);

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put(MqttConstants.FIELD_COMMAND_ID, commandId);
        payload.put(MqttConstants.FIELD_ACTION, action);
        payload.put(MqttConstants.FIELD_TARGET, target);
        if (channel != null) {
            payload.put(MqttConstants.FIELD_CHANNEL, channel);
        }
        if (params != null && !params.isEmpty()) {
            payload.put(MqttConstants.FIELD_PARAMS, params);
        }
        payload.put(MqttConstants.FIELD_TIMESTAMP, System.currentTimeMillis());

        publish(topic, payload, MqttConstants.DEFAULT_QOS, false);

        log.info("MQTT 控制指令下发 - Topic: {}, commandId: {}, action: {}, target: {}, channel: {}",
                topic, commandId, action, target, channel);
    }

    /**
     * 下发 OTA 指令（复用 command topic）
     */
    public void sendOtaCommand(String deviceId,
                               String commandId,
                               String url,
                               String version,
                               String md5,
                               Long size) {
        Map<String, Object> params = new LinkedHashMap<>();
        params.put(MqttConstants.FIELD_OTA_URL, url);
        params.put(MqttConstants.FIELD_OTA_VERSION, version);
        if (md5 != null) params.put(MqttConstants.FIELD_OTA_MD5, md5);
        if (size != null) params.put(MqttConstants.FIELD_OTA_SIZE, size);

        sendControlCommand(deviceId, commandId,
                MqttConstants.ACTION_START,
                MqttConstants.TARGET_OTA,
                null,
                params);
    }

    /**
     * 下发配置指令（复用 command topic）
     */
    public void sendConfigCommand(String deviceId,
                                  String commandId,
                                  Map<String, Object> config,
                                  Integer configVersion) {
        Map<String, Object> params = new LinkedHashMap<>();
        params.put(MqttConstants.FIELD_CONFIG, config);
        if (configVersion != null) {
            params.put(MqttConstants.FIELD_CONFIG_VERSION, configVersion);
        }
        params.put(MqttConstants.FIELD_PERSIST, true);

        sendControlCommand(deviceId, commandId,
                MqttConstants.ACTION_SET,
                MqttConstants.TARGET_CONFIG,
                null,
                params);
    }
}