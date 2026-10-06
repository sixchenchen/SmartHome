package com.womi.webmodule.mqtt.core;

import com.womi.commonmodule.constants.MqttConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.messaging.Message;
import org.springframework.stereotype.Component;

/**
 * MQTT 入站消息接收器
 *
 * 监听  mqttInputChannel，把消息转发给 MqttMessageRouter。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class MqttMessageReceiver {

    private final MqttMessageRouter messageRouter;

    @ServiceActivator(inputChannel = "mqttInputChannel")
    public void handleMessage(Message<?> message) {
        try {
            String payload = message.getPayload().toString();
            String topic = (String) message.getHeaders().get(MqttConstants.MQTT_RECEIVED_TOPIC);
            Integer qos = (Integer) message.getHeaders().get(MqttConstants.MQTT_RECEIVED_QOS);

            log.debug("收到 MQTT 消息 - Topic: {}, QoS: {}", topic, qos);
            messageRouter.route(topic, payload, qos);

        } catch (Exception e) {
            log.error("处理 MQTT 入站消息失败", e);
        }
    }
}