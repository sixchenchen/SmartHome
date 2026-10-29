package com.womi.webmodule.service.mqtt.impl;

import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.commonmodule.constants.DeviceCommandConstants;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.constants.ScheduleConstants;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.utils.MacUtils;
import com.womi.webmodule.mqtt.core.MqttPublisher;
import com.womi.webmodule.service.mqtt.DeviceControlService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.util.StringUtils;

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

        // 1. 统一清洗 MAC 地址
        String cleanMac = MacUtils.normalize(deviceId);
        if (!StringUtils.hasText(cleanMac)) {
            throw new BusinessException(ErrorCode.PARAM_ERROR, "无效的设备ID");
        }

        // 2. 查出设备实体，并校验真实在线状态
        DeviceInfo device = deviceInfoService.getByDeviceId(cleanMac);
        if (device == null) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_FOUND);
        }
        checkDeviceOnline(device);

        // 3. 入库（PENDING）
        DeviceCommand command = deviceCommandService.prepareCommand(
                cleanMac, action, target, channel, params,
                operator, DeviceCommandConstants.SOURCE_WEB,
                expireSeconds > 0 ? expireSeconds : DEFAULT_EXPIRE_SECONDS);

        // 4. 立即下发
        executeAfterCommit(() -> trySendImmediately(command));
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
     * 校验设备真实在线
     */
    private void checkDeviceOnline(DeviceInfo device) {
        if (!deviceInfoService.isDeviceActuallyOnline(device, ScheduleConstants.HEARTBEAT_TIMEOUT_SECONDS)) {
            throw new BusinessException(ErrorCode.DEVICE_OFFLINE);
        }
    }
    /**
     * 事务提交后执行（如果当前没有事务，则立即执行）
     */
    private void executeAfterCommit(Runnable action) {
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    action.run();
                }
            });
        } else {
            action.run();
        }
    }
}