package com.womi.webmodule.service.mqtt.impl;

import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.commonmodule.constants.DeviceCommandConstants;
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.mqtt.core.MqttPublisher;
import com.womi.webmodule.service.mqtt.DeviceControlService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

import static com.womi.commonmodule.constants.DeviceCommandConstants.DEFAULT_EXPIRE_SECONDS;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceControlServiceImpl implements DeviceControlService {

    private final DeviceCommandService deviceCommandService;
    private final MqttPublisher mqttPublisher;
    private final DeviceInfoService deviceInfoService;

    // ==================== 通用入口 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceCommand sendCommand(String deviceId, String action, String target,
                                     Integer channel, Map<String, Object> params,
                                     String operator, int expireSeconds) {
        checkDeviceOnline(deviceId);

        // 1. 入库（PENDING）
        DeviceCommand command = deviceCommandService.prepareCommand(
                deviceId, action, target, channel, params,
                operator, DeviceCommandConstants.SOURCE_WEB,
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
                    DeviceCommandStatus.SENT.getCode(),
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
        params.put(DeviceMqttConstants.FIELD_STATE, state);
        return sendCommand(deviceId,
                DeviceMqttConstants.ACTION_SET,
                DeviceMqttConstants.TARGET_MOS,
                channel, params, operator, DEFAULT_EXPIRE_SECONDS);
    }

    @Override
    public DeviceCommand controlMosAll(String deviceId, int state, String operator) {
        return controlMos(deviceId, DeviceMqttConstants.CHANNEL_ALL, state, operator);
    }

    @Override
    public DeviceCommand queryMos(String deviceId, int channel, String operator) {
        return sendCommand(deviceId,
                DeviceMqttConstants.ACTION_GET,
                DeviceMqttConstants.TARGET_MOS,
                channel, null, operator, DEFAULT_EXPIRE_SECONDS);
    }

    // ==================== LED ====================

    @Override
    public DeviceCommand controlLed(String deviceId, int channel, int state,
                                    Integer brightness, String operator) {
        Map<String, Object> params = new HashMap<>();
        params.put(DeviceMqttConstants.FIELD_STATE, state);
        if (brightness != null) {
            params.put(DeviceMqttConstants.FIELD_BRIGHTNESS, brightness);
        }
        return sendCommand(deviceId,
                DeviceMqttConstants.ACTION_SET,
                DeviceMqttConstants.TARGET_LED,
                channel, params, operator, DEFAULT_EXPIRE_SECONDS);
    }

    // ==================== 舵机 ====================
    @Override
    public DeviceCommand controlServo(String deviceId, int channel, int angle, String operator) {
        Map<String, Object> params = new HashMap<>();
        params.put(DeviceMqttConstants.FIELD_ANGLE, angle);
        return sendCommand(deviceId,
                DeviceMqttConstants.ACTION_SET,
                DeviceMqttConstants.TARGET_SERVO,
                channel, params, operator, DEFAULT_EXPIRE_SECONDS);
    }


    // ==================== 配置 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceCommand sendConfig(String deviceId, Map<String, Object> config,
                                    Integer configVersion, String operator) {

        Map<String, Object> params = new LinkedHashMap<>();
        params.put(DeviceMqttConstants.FIELD_CONFIG, config);
        if (configVersion != null) {
            params.put(DeviceMqttConstants.FIELD_CONFIG_VERSION, configVersion);
        }
        params.put(DeviceMqttConstants.FIELD_PERSIST, true);

        return sendCommand(deviceId,
                DeviceMqttConstants.ACTION_SET,
                DeviceMqttConstants.TARGET_CONFIG,
                null, params, operator, DEFAULT_EXPIRE_SECONDS);
    }

    /**
     * 校验设备在线：
     * 1) 设备必须存在
     * 2) online 字段必须为 1
     * 3) 心跳未超时（防止 LWT 延迟导致误判在线）
     */
    private void checkDeviceOnline(String deviceId) {
        if (deviceId == null || deviceId.isBlank()) {
            throw new BusinessException(ErrorCode.PARAM_ERROR);
        }

        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_FOUND);
        }

        // 在线标志
        if (device.getOnline() == null
                || device.getOnline() != DeviceConstants.DEVICE_STATUS_ONLINE) {
            log.warn("指令拒绝：设备不在线 - deviceId: {}, online: {}", deviceId, device.getOnline());
            throw new BusinessException(ErrorCode.DEVICE_OFFLINE);
        }

        // 心跳兜底：防止 LWT 还没触发，online=1 但实际已断
        LocalDateTime last = device.getLastHeartbeatTime();
        if (last != null) {
            long gap = Duration.between(last, LocalDateTime.now()).getSeconds();
            if (gap > DeviceConstants.HEARTBEAT_OFFLINE_SECONDS) {
                log.warn("指令拒绝：心跳超时 - deviceId: {}, gap: {}s", deviceId, gap);
                throw new BusinessException(ErrorCode.DEVICE_OFFLINE, "设备心跳超时 " + gap + "s，视为离线");
            }
        }
    }
}