package com.womi.webmodule.service;

import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.service.DeviceCommandService;
import com.womi.webmodule.mqtt.core.MqttPublisher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceCommandSender {

    private final DeviceCommandService deviceCommandService;
    private final MqttPublisher mqttPublisher;

    /**
     * 创建并立即下发指令（供 Controller 调用）
     *
     * @return commandId
     */
    public String sendCommand(String deviceId, String commandType,
                              java.util.Map<String, Object> payload,
                              String operator, String source, int expireSeconds) {
        // 1. business 层入库
        DeviceCommand command = deviceCommandService.prepareCommand(
                deviceId, commandType, payload, operator, source, expireSeconds);

        // 2. web 层发送 MQTT
        try {
            mqttPublisher.sendCommandWithId(
                    command.getDeviceId(),
                    command.getCommandId(),
                    command.getCommandType(),
                    command.getPayload()
            );
            deviceCommandService.markAsSent(command.getId());
            log.info("指令下发成功 - commandId: {}", command.getCommandId());
        } catch (Exception e) {
            log.error("MQTT 下发失败，等待定时任务重试 - commandId: {}",command.getCommandId(), e);
        }

        return command.getCommandId();
    }
}