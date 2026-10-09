package com.womi.webmodule.controller;


import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.mqtt.core.MqttPublisher;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/mqtt")
@RequiredArgsConstructor
public class MqttTestController {

    private final MqttPublisher mqttPublisher;

    /**
     * 发送命令到设备
     */
    @PostMapping("/command/{deviceId}")
    public ApiResponse<Void> sendCommand(
            @PathVariable String deviceId,
            @RequestParam String command,
            @RequestBody Map<String, Object> data) {
        return null;
    }

    /**
     * 发布自定义消息
     */
    @PostMapping("/publish")
    public ApiResponse<Void> publish(
            @RequestParam String topic,
            @RequestBody Map<String, Object> payload) {
        mqttPublisher.publish(topic, payload);
        return ApiResponse.success("消息发布成功", null);
    }

    /**
     * 测试发布控制命令
     */
    @PostMapping("/test/control")
    public ApiResponse<Void> testControl(@RequestParam String deviceId) {
        return null;
    }
}