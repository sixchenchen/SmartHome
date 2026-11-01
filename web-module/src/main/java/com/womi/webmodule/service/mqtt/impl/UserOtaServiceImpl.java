package com.womi.webmodule.service.mqtt.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.womi.businessmodule.mapper.device.DeviceBindingMapper;
import com.womi.businessmodule.model.device.DeviceBinding;
import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.model.device.DeviceFirmware;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.service.common.CommandSender;
import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.businessmodule.service.device.DeviceFirmwareService;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.businessmodule.vo.OtaCheckResponse;
import com.womi.commonmodule.constants.DeviceCommandConstants;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.constants.ScheduleConstants;
import com.womi.commonmodule.enums.BindStatus;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.enums.EnableStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.utils.TransactionUtils;
import com.womi.webmodule.service.mqtt.UserOtaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserOtaServiceImpl implements UserOtaService {

    private final DeviceInfoService deviceInfoService;
    private final DeviceFirmwareService firmwareService;
    private final DeviceBindingMapper bindingMapper;
    private final DeviceCommandService commandService;
    private final CommandSender commandSender;

    @Override
    public OtaCheckResponse checkUpdate(Long userId, String deviceId) {
        // 1. 防越权
        checkDeviceBinding(userId, deviceId);

        // 2. 查设备
        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_FOUND, ErrorCode.DEVICE_NOT_FOUND.getMessage());
        }

        // 3. 查最新固件
        DeviceFirmware latest = getLatestFirmware(device.getProduct());

        OtaCheckResponse resp = new OtaCheckResponse();
        if (latest == null || latest.getVersion().equals(device.getFirmware())) {
            resp.setHasNewVersion(false);
            return resp;
        }

        resp.setHasNewVersion(true);
        resp.setFirmwareId(latest.getId());
        resp.setLatestVersion(latest.getVersion());
        resp.setReleaseNotes(latest.getReleaseNotes());
        resp.setSize(latest.getSize());
        return resp;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void startOta(Long userId, String deviceId) {
        // 1. 防越权
        checkDeviceBinding(userId, deviceId);

        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_FOUND, ErrorCode.DEVICE_NOT_FOUND.getMessage());
        }

        // 安全的在线判定
        if (!deviceInfoService.isDeviceActuallyOnline(device, ScheduleConstants.HEARTBEAT_TIMEOUT_SECONDS)) {
            throw new BusinessException(ErrorCode.DEVICE_OFFLINE, "设备不在线或网络异常，无法升级");
        }

        // 2. 查最新固件
        DeviceFirmware latest = getLatestFirmware(device.getProduct());
        if (latest == null || latest.getVersion().equals(device.getFirmware())) {
            throw new BusinessException(ErrorCode.OTA_ALREADY_LATEST, ErrorCode.OTA_ALREADY_LATEST.getMessage());
        }

        // 3. 防并发
        boolean running = commandService.exists(
                new LambdaQueryWrapper<DeviceCommand>()
                        .eq(DeviceCommand::getDeviceId, deviceId)
                        .eq(DeviceCommand::getTarget, DeviceMqttConstants.TARGET_OTA)
                        .in(DeviceCommand::getStatus,
                                DeviceCommandStatus.PENDING.getCode(),
                                DeviceCommandStatus.SENT.getCode(),
                                DeviceCommandStatus.ACCEPTED.getCode())
        );
        if (running) {
            throw new BusinessException(ErrorCode.OTA_IN_PROGRESS, "该设备正在升级中，请耐心等待");
        }

        // 4. 组装指令
        LocalDateTime now = LocalDateTime.now();
        DeviceCommand cmd = new DeviceCommand();
        cmd.setCommandId(UUID.randomUUID().toString().replace("-", ""));
        cmd.setDeviceId(deviceId);
        cmd.setAction(DeviceMqttConstants.ACTION_START);
        cmd.setTarget(DeviceMqttConstants.TARGET_OTA);

        Map<String, Object> otaParams = new HashMap<>();
        otaParams.put(DeviceMqttConstants.FIELD_OTA_URL, latest.getUrl());
        otaParams.put(DeviceMqttConstants.FIELD_OTA_VERSION, latest.getVersion());
        otaParams.put(DeviceMqttConstants.FIELD_OTA_SHA256, latest.getSha256());
        otaParams.put(DeviceMqttConstants.FIELD_OTA_SIZE, latest.getSize());
        cmd.setParams(otaParams);

        cmd.setQos(DeviceCommandConstants.DEFAULT_QOS);
        cmd.setRetain(DeviceCommandConstants.DEFAULT_RETAIN);
        cmd.setStatus(DeviceCommandStatus.PENDING.getCode());
        cmd.setRetryCount(DeviceCommandConstants.DEFAULT_RETRY_COUNT);
        cmd.setMaxRetry(DeviceCommandConstants.DEFAULT_MAX_RETRY);
        cmd.setOperator("user_" + userId);
        cmd.setSource(DeviceCommandConstants.SOURCE_WEB);
        cmd.setExpireTime(now.plusSeconds(DeviceCommandConstants.OTA_EXPIRE_SECONDS));
        cmd.setCreateTime(now);
        cmd.setUpdateTime(now);

        commandService.save(cmd);

        // 5. 事务提交后再发 MQTT
        TransactionUtils.afterCommit(() -> {
            try {
                commandSender.send(cmd);
                commandService.updateStatus(cmd.getId(), DeviceCommandStatus.SENT.getCode(), null);
                commandService.incrementRetryCount(cmd.getId());
                log.info("用户端 OTA 指令下发成功 - userId: {}, deviceId: {}, commandId: {}", userId, deviceId, cmd.getCommandId());
            } catch (Exception e) {
                log.error("用户端 OTA 指令下发失败，等待定时任务兜底 - commandId: {}", cmd.getCommandId(), e);
            }
        });
    }

    /**
     * 安全校验：校验设备归属权
     */
    private void checkDeviceBinding(Long userId, String deviceId) {
        DeviceBinding binding = bindingMapper.selectOne(
                new LambdaQueryWrapper<DeviceBinding>()
                        .eq(DeviceBinding::getDeviceId, deviceId)
                        .eq(DeviceBinding::getUserId, userId)
                        .eq(DeviceBinding::getBindStatus, BindStatus.BOUND.getCode())
        );
        if (binding == null) {
            throw new BusinessException(ErrorCode.DEVICE_NO_PERMISSION, ErrorCode.DEVICE_NO_PERMISSION.getMessage());
        }
    }

    /**
     * 抽取查最新固件方法
     */
    private DeviceFirmware getLatestFirmware(String product) {
        return firmwareService.getOne(
                new LambdaQueryWrapper<DeviceFirmware>()
                        .eq(DeviceFirmware::getProduct, product)
                        .eq(DeviceFirmware::getStatus, EnableStatus.ENABLED.getCode())
                        .orderByDesc(DeviceFirmware::getCreateTime)
                        .last("LIMIT 1")
        );
    }
}