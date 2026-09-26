package com.womi.webmodule.mqtt.core;

import com.womi.webmodule.mqtt.MqttMessageHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Component
@RequiredArgsConstructor
public class MqttMessageRouter {

    private final List<MqttMessageHandler> handlers;
    private final Map<String, MqttMessageHandler> handlerCache = new ConcurrentHashMap<>();

    /**
     * 路由消息到对应的处理器
     */
    public void route(String topic, String payload, Integer qos) {
        try {
            // 1. 查找匹配的处理器
            MqttMessageHandler handler = findHandler(topic);
            if (handler == null) {
                log.warn("未找到匹配的处理器 - Topic: {}", topic);
                return;
            }

            // 2. 检查是否支持该主题
            if (!handler.supports(topic)) {
                log.warn("处理器不支持该主题 - Topic: {}, Handler: {}",
                        topic, handler.getClass().getSimpleName());
                return;
            }

            // 3. 处理消息
            handler.handle(topic, payload, qos);

        } catch (Exception e) {
            log.error("路由消息失败 - Topic: {}, Error: {}", topic, e.getMessage(), e);
        }
    }

    /**
     * 查找匹配的处理器（支持通配符匹配）
     */
    private MqttMessageHandler findHandler(String topic) {
        // 1. 精确匹配缓存
        if (handlerCache.containsKey(topic)) {
            return handlerCache.get(topic);
        }
        // 2. 遍历处理器查找匹配
        for (MqttMessageHandler handler : handlers) {
            if (handler.supports(topic)) {
                // 缓存匹配结果（提高性能）
                handlerCache.put(topic, handler);
                return handler;
            }
        }

        return null;
    }
}