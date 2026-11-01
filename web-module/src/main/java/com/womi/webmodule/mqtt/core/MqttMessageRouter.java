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
            boolean isRetryable = !(e instanceof IllegalArgumentException);

            // 存入死信表（把 isRetryable 传给 Service，或者打上 type 标签）
            deadLetterService.saveDeadLetter(topic, payload, e, isRetryable);

            log.warn("MQTT消息处理失败，已存入死信队列 - topic: {}, 可重试: {}, 错误: {}",
                    topic, isRetryable, e.getMessage());
            return false; // 异常被吞掉，MQTT 正常 ACK，防止毒丸重发
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