package com.womi.webmodule.service.impl;

import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.service.DeviceCommandService;
import com.womi.commonmodule.constants.CommandConstants;
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.commonmodule.constants.MqttConstants;
import com.womi.webmodule.mqtt.core.MqttPublisher;
import com.womi.webmodule.service.DeviceControlService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceControlServiceImpl implements DeviceControlService {

    private static final int DEFAULT_EXPIRE_SECONDS = 30;

    private final DeviceCommandService deviceCommandService;
    private final MqttPublisher mqttPublisher;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceCommand sendCommand(String deviceId, String action, String target,
                                     Integer channel, Map<String, Object> params,
                                     String operator, int expireSeconds) {
        // 1. 入库
        DeviceCommand command = deviceCommandService.prepareCommand(
                deviceId, action, target, channel, params,
                operator, CommandConstants.DEFAULT_SOURCE,
                expireSeconds > 0 ? expireSeconds : DEFAULT_EXPIRE_SECONDS);

        // 2. MQTT 下发
        try {
            mqttPublisher.sendControlCommand(
                    command.getDeviceId(),
                    command.getCommandId(),
                    command.getAction(),
                    command.getTarget(),
                    command.getChannel(),
                    command.getParams()
            );
            deviceCommandService.markAsSent(command.getId());
            log.info("指令下发成功 - commandId: {}", command.getCommandId());
        } catch (Exception e) {
            // 下发失败不抛异常，让定时任务重试
            log.error("MQTT 下发失败，等待定时任务重试 - commandId: {}", command.getCommandId(), e);
        }

        return command;
    }

    // ==================== MOS ====================

    @Override
    public DeviceCommand controlMos(String deviceId, int channel, int state, String operator) {
        Map<String, Object> params = new HashMap<>();
        params.put(MqttConstants.FIELD_STATE, state);
        return sendCommand(deviceId,
                MqttConstants.ACTION_SET,
                MqttConstants.TARGET_MOS,
                channel, params, operator, DEFAULT_EXPIRE_SECONDS);
    }

    @Override
    public DeviceCommand controlMosAll(String deviceId, int state, String operator) {
        return controlMos(deviceId, MqttConstants.CHANNEL_ALL, state, operator);
    }

    @Override
    public DeviceCommand queryMos(String deviceId, int channel, String operator) {
        return sendCommand(deviceId,
                MqttConstants.ACTION_GET,
                MqttConstants.TARGET_MOS,
                channel, null, operator, DEFAULT_EXPIRE_SECONDS);
    }

    // ==================== LED ====================

    @Override
    public DeviceCommand controlLed(String deviceId, int channel, int state,
                                    Integer brightness, String operator) {
        Map<String, Object> params = new HashMap<>();
        params.put(MqttConstants.FIELD_STATE, state);
        if (brightness != null) {
            params.put("brightness", brightness);
        }
        return sendCommand(deviceId,
                MqttConstants.ACTION_SET,
                MqttConstants.TARGET_LED,
                channel, params, operator, DEFAULT_EXPIRE_SECONDS);
    }

    // ==================== 舵机 ====================

    @Override
    public DeviceCommand controlServo(String deviceId, int channel, int angle, String operator) {
        Map<String, Object> params = new HashMap<>();
        params.put("angle", angle);
        return sendCommand(deviceId,
                MqttConstants.ACTION_SET,
                MqttConstants.TARGET_SERVO,
                channel, params, operator, DEFAULT_EXPIRE_SECONDS);
    }

    // ==================== OTA ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceCommand startOta(String deviceId, String url, String version,
                                  String md5, Long size, String operator) {
        // OTA 是长流程，超时时间设长一点
        int expireSeconds = 10 * 60;

        Map<String, Object> params = new LinkedHashMap<>();
        params.put(MqttConstants.FIELD_OTA_URL, url);
        params.put(MqttConstants.FIELD_OTA_VERSION, version);
        if (md5 != null) params.put(MqttConstants.FIELD_OTA_MD5, md5);
        if (size != null) params.put(MqttConstants.FIELD_OTA_SIZE, size);

        DeviceCommand command = deviceCommandService.prepareCommand(
                deviceId,
                MqttConstants.ACTION_START,
                MqttConstants.TARGET_OTA,
                null, params,
                operator, "WEB",
                expireSeconds);

        try {
            mqttPublisher.sendControlCommand(
                    command.getDeviceId(),
                    command.getCommandId(),
                    command.getAction(),
                    command.getTarget(),
                    command.getChannel(),
                    command.getParams()
            );
            deviceCommandService.markAsSent(command.getId());
            log.info("OTA 下发成功 - commandId: {}, version: {}", command.getCommandId(), version);
        } catch (Exception e) {
            log.error("OTA 下发失败 - commandId: {}", command.getCommandId(), e);
        }

        return command;
    }

    // ==================== 配置 ====================
    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceCommand sendConfig(String deviceId, Map<String, Object> config,
                                    Integer configVersion, String operator) {
        Map<String, Object> params = new LinkedHashMap<>();
        params.put(MqttConstants.FIELD_CONFIG, config);
        if (configVersion != null) {
            params.put(MqttConstants.FIELD_CONFIG_VERSION, configVersion);
        }
        params.put(MqttConstants.FIELD_PERSIST, true);
        return sendCommand(deviceId,
                MqttConstants.ACTION_SET,
                MqttConstants.TARGET_CONFIG,
                null, params, operator, DEFAULT_EXPIRE_SECONDS);
    }
}