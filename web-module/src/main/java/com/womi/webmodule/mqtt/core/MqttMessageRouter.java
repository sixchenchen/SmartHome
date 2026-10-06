package com.womi.webmodule.mqtt.core;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class MqttMessageRouter {

    private final List<MqttMessageHandler> handlers;
    /**
     * 路由消息到对应的处理器
     */
    public void route(String topic, String payload, Integer qos) {
        try {
            MqttMessageHandler handler = findHandler(topic);
            if (handler == null) {
                log.warn("未找到匹配的处理器 - Topic: {}", topic);
                return;
            }
            handler.handle(topic, payload, qos);
        } catch (Exception e) {
            log.error("路由消息失败 - Topic: {}, Error: {}", topic, e.getMessage(), e);
        }
    }

    /**
     * 查找匹配的处理器（支持通配符匹配）
     */
    private MqttMessageHandler findHandler(String topic) {
        for (MqttMessageHandler handler : handlers) {
            if (handler.supports(topic)) {
                return handler;
            }
        }
        return null;
    }
}