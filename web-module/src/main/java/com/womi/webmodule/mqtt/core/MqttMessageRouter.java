package com.womi.webmodule.mqtt.core;

import com.womi.webmodule.service.mqtt.SysDeadLetterService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class MqttMessageRouter {

    private final List<MqttMessageHandler> handlers;
    private final SysDeadLetterService deadLetterService;

    public boolean route(String topic, String payload, Integer qos) {
        MqttMessageHandler handler = findHandler(topic);
        if (handler == null) {
            log.warn("未找到匹配的处理器 - Topic: {}", topic);
            return false;
        }

        try {
            handler.handle(topic, payload, qos);
            return true; // 处理成功
        } catch (Exception e) {
            // 存入死信表
            deadLetterService.saveDeadLetter(topic, payload, e);
            return false; // 处理失败，但异常被吞掉，MQTT 正常 ACK
        }
    }

    private MqttMessageHandler findHandler(String topic) {
        for (MqttMessageHandler handler : handlers) {
            if (handler.supports(topic)) {
                return handler;
            }
        }
        return null;
    }
}