package com.womi.webmodule.mqtt.core;

import com.womi.commonmodule.constants.DeviceMqttConstants;
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

    /** 运行时消息（8883） */
    @ServiceActivator(inputChannel = "runtimeInputChannel")
    public void handleRuntimeMessage(Message<?> message) {
        log.debug("[RUNTIME] 收到 MQTT 消息");
        route(message);
    }

    /** 注册消息（8884） */
    @ServiceActivator(inputChannel = "provisionInputChannel")
    public void handleProvisionMessage(Message<?> message) {
        log.debug("[PROVISION] 收到 MQTT 消息");
        route(message);
    }

    /** 统一路由 */
    private void route(Message<?> message) {
        String payload = message.getPayload().toString();
        String topic = (String) message.getHeaders().get(DeviceMqttConstants.MQTT_RECEIVED_TOPIC);
        Integer qos = (Integer) message.getHeaders().get(DeviceMqttConstants.MQTT_RECEIVED_QOS);

        log.debug("收到 MQTT 消息 - Topic: {}, QoS: {}", topic, qos);

        // Router 内部已经吞掉异常了
        boolean success = messageRouter.route(topic, payload, qos);

        if (!success) {
            log.warn("MQTT 消息处理失败或未找到 Handler - Topic: {}", topic);
        }
    }
}