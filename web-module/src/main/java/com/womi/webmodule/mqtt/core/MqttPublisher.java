package com.womi.webmodule.mqtt.core;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.womi.commonmodule.mqtt.MqttConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.integration.support.MessageBuilder;
import org.springframework.messaging.MessageChannel;
import org.springframework.stereotype.Service;

import java.util.HashMap;
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
            String message = payload instanceof String ?
                    (String) payload : objectMapper.writeValueAsString(payload);

            Map<String, Object> headers = new HashMap<>();
            headers.put(MqttConstants.MQTT_HEADER_TOPIC, topic);
            headers.put(MqttConstants.MQTT_HEADER_QOS, qos);
            headers.put(MqttConstants.MQTT_HEADER_RETAINED, retained);

            mqttOutputChannel.send(
                    MessageBuilder.withPayload(message)
                            .copyHeaders(headers)
                            .build()
            );

            log.debug("MQTT 消息发布成功 - Topic: {}, QoS: {}, Retained: {}",
                    topic, qos, retained);
        } catch (JsonProcessingException e) {
            log.error("MQTT 消息发布失败 - Topic: {}, Error: {}", topic, e.getMessage());
        }
    }

    /**
     * 发布命令到设备
     */
    public void sendCommand(String deviceId, String command, Object data) {
        String topic = String.format(MqttConstants.COMMAND_TOPIC_FORMAT, deviceId);
        Map<String, Object> payload = new HashMap<>();
        payload.put(MqttConstants.FIELD_COMMAND, command);
        payload.put(MqttConstants.FIELD_DATA, data);
        payload.put(MqttConstants.FIELD_TIMESTAMP, System.currentTimeMillis());
        publish(topic, payload);
    }

    /**
     * 发布带 commandId 的控制指令（用于 ACK 匹配）
     *
     * @param deviceId    目标设备
     * @param commandId   指令唯一 ID（UUID），由 Service 生成
     * @param commandType 指令类型，如 MOS_CONTROL / REBOOT
     * @param data        指令参数
     */
    public void sendCommandWithId(String deviceId, String commandId,
                                  String commandType, Object data) {
        String topic = String.format(MqttConstants.COMMAND_TOPIC_FORMAT, deviceId);
        Map<String, Object> payload = new HashMap<>();
        payload.put(MqttConstants.FIELD_COMMAND_ID, commandId);
        payload.put(MqttConstants.FIELD_COMMAND, commandType);
        payload.put(MqttConstants.FIELD_DATA, data);
        payload.put(MqttConstants.FIELD_TIMESTAMP, System.currentTimeMillis());
        publish(topic, payload, MqttConstants.DEFAULT_QOS, MqttConstants.DEFAULT_RETAINED);

        log.info("MQTT 指令下发 - Topic: {}, commandId: {}, type: {}",
                topic, commandId, commandType);
    }
}