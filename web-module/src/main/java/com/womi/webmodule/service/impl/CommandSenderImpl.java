package com.womi.webmodule.service.impl;

import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.service.CommandSender;
import com.womi.webmodule.mqtt.core.MqttPublisher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 指令发送器实现（web 层）
 *
 * 实现 business 层的 CommandSender 接口，底层用 MqttPublisher。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class CommandSenderImpl implements CommandSender {

    private final MqttPublisher mqttPublisher;

    @Override
    public void send(DeviceCommand command) {
        mqttPublisher.sendControlCommand(
                command.getDeviceId(),
                command.getCommandId(),
                command.getAction(),
                command.getTarget(),
                command.getChannel(),
                command.getParams()
        );
        log.debug("指令已发送 - commandId: {}", command.getCommandId());
    }
}