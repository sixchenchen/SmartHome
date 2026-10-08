package com.womi.webmodule.mqtt.core;

import com.womi.commonmodule.constants.MqttConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.messaging.Message;
import org.springframework.stereotype.Component;

/**
 * MQTT 入站消息接收器
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class MqttMessageReceiver {

    private final MqttMessageRouter messageRouter;

    /** 运行时消息（1883） */
    @ServiceActivator(inputChannel = "runtimeInputChannel")
    public void handleRuntimeMessage(Message<?> message) {
        log.debug("[RUNTIME] 收到 MQTT 消息");
        route(message);
    }

    /** 注册消息（1884） */
    @ServiceActivator(inputChannel = "provisionInputChannel")
    public void handleProvisionMessage(Message<?> message) {
        log.debug("[PROVISION] 收到 MQTT 消息");
        route(message);
    }

    /** 统一路由 */
    private void route(Message<?> message) {
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