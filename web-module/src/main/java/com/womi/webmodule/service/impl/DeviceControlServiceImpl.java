package com.womi.webmodule.service.impl;

import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.service.DeviceCommandService;
import com.womi.commonmodule.constants.CommandConstants;
import com.womi.commonmodule.constants.MqttConstants;
import com.womi.commonmodule.enums.CommandStatus;
import com.womi.webmodule.mqtt.core.MqttPublisher;
import com.womi.webmodule.service.DeviceControlService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

import static com.womi.commonmodule.constants.CommandConstants.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceControlServiceImpl implements DeviceControlService {

    private final DeviceCommandService deviceCommandService;
    private final MqttPublisher mqttPublisher;

    // ==================== 通用入口 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceCommand sendCommand(String deviceId, String action, String target,
                                     Integer channel, Map<String, Object> params,
                                     String operator, int expireSeconds) {
        // 1. 入库（PENDING）
        DeviceCommand command = deviceCommandService.prepareCommand(
                deviceId, action, target, channel, params,
                operator, CommandConstants.SOURCE_WEB,
                expireSeconds > 0 ? expireSeconds : DEFAULT_EXPIRE_SECONDS);

        // 2. 立即下发
        trySendImmediately(command);
        return command;
    }

    /**
     * 立即发送：成功 → SENT；失败 → 保持 PENDING，由定时器兜底
     */
    private void trySendImmediately(DeviceCommand command) {
        try {
            mqttPublisher.sendControlCommand(
                    command.getDeviceId(),
                    command.getCommandId(),
                    command.getAction(),
                    command.getTarget(),
                    command.getChannel(),
                    command.getParams()
            );
            deviceCommandService.updateStatus(
                    command.getId(),
                    CommandStatus.SENT.getCode(),
                    null);
            log.info("指令立即下发成功 - commandId: {}, deviceId: {}, target: {}", command.getCommandId(), command.getDeviceId(), command.getTarget());
        } catch (Exception e) {
            // 保持 PENDING，让定时器兜底重试
            log.error("指令立即下发失败，等待定时器兜底 - commandId: {}, error: {}", command.getCommandId(), e.getMessage(), e);
        }
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
            params.put(MqttConstants.FIELD_BRIGHTNESS, brightness);
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
        params.put(MqttConstants.FIELD_ANGLE, angle);
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
        Map<String, Object> params = new LinkedHashMap<>();
        params.put(MqttConstants.FIELD_OTA_URL, url);
        params.put(MqttConstants.FIELD_OTA_VERSION, version);
        if (md5 != null) {
            params.put(MqttConstants.FIELD_OTA_MD5, md5);
        }
        if (size != null) {
            params.put(MqttConstants.FIELD_OTA_SIZE, size);
        }

        DeviceCommand command = deviceCommandService.prepareCommand(
                deviceId,
                MqttConstants.ACTION_START,
                MqttConstants.TARGET_OTA,
                null, params,
                operator, SOURCE_WEB,
                OTA_EXPIRE_SECONDS);

        trySendImmediately(command);
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