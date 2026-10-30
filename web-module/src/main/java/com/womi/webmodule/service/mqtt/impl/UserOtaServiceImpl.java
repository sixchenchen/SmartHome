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
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.enums.BindStatus;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.enums.EnableStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.service.mqtt.UserOtaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
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
        // 1. 防越权：校验设备是否属于当前用户
        checkDeviceBinding(userId, deviceId);

        // 2. 查设备当前信息
        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_FOUND, ErrorCode.DEVICE_OFFLINE.getMessage());
        }

        // 3. 查询该产品最新启用的固件
        DeviceFirmware latest = firmwareService.getOne(
                new LambdaQueryWrapper<DeviceFirmware>()
                        .eq(DeviceFirmware::getProduct, device.getProduct())
                        .eq(DeviceFirmware::getStatus, EnableStatus.ENABLED)
                        .orderByDesc(DeviceFirmware::getCreateTime)
                        .last("LIMIT 1")
        );

        OtaCheckResponse resp = new OtaCheckResponse();

        // 4. 比对版本（如果没有固件，或者版本号一样，说明不需要更新）
        if (latest == null || latest.getVersion().equals(device.getFirmware())) {
            resp.setHasNewVersion(false);
            return resp;
        }

        // 5. 发现新版本，组装返回
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
        if (device == null) throw new BusinessException(ErrorCode.DEVICE_NOT_FOUND,ErrorCode.DEVICE_NOT_FOUND.getMessage());
        if (device.getOnline() != DeviceConstants.DEVICE_ONLINE) throw new BusinessException(ErrorCode.DEVICE_OFFLINE, "设备不在线，无法升级");

        // 2. 再次查最新固件（防止前端传假数据）
        DeviceFirmware latest = firmwareService.getOne(
                new LambdaQueryWrapper<DeviceFirmware>()
                        .eq(DeviceFirmware::getProduct, device.getProduct())
                        .eq(DeviceFirmware::getStatus, EnableStatus.ENABLED)
                        .orderByDesc(DeviceFirmware::getCreateTime)
                        .last("LIMIT 1")
        );
        if (latest == null || latest.getVersion().equals(device.getFirmware())) {
            throw new BusinessException(ErrorCode.OTA_ALREADY_LATEST, ErrorCode.OTA_ALREADY_LATEST.getMessage());
        }

        // 3. 防并发：检查该设备是否已有正在进行的 OTA
        boolean running = commandService.exists(
                new LambdaQueryWrapper<DeviceCommand>()
                        .eq(DeviceCommand::getDeviceId, deviceId)
                        .eq(DeviceCommand::getTarget, DeviceMqttConstants.TARGET_OTA)
                        .in(DeviceCommand::getStatus, 0, 1, 6)
        );
        if (running) {
            throw new BusinessException(ErrorCode.OTA_IN_PROGRESS, "该设备正在升级中，请耐心等待");
        }

        // 4. 组装 OTA 指令
        LocalDateTime now = LocalDateTime.now();
        DeviceCommand cmd = new DeviceCommand();
        cmd.setCommandId(UUID.randomUUID().toString().replace("-", ""));
        cmd.setDeviceId(deviceId);
        cmd.setAction(DeviceMqttConstants.FIELD_ACTION);
        cmd.setTarget(DeviceMqttConstants.TARGET_OTA);
        cmd.setParams(Map.of(
                DeviceMqttConstants.FIELD_OTA_URL, latest.getUrl(),
                DeviceMqttConstants.FIELD_OTA_VERSION, latest.getVersion(),
                DeviceMqttConstants.FIELD_OTA_SHA256, latest.getSha256(),
                DeviceMqttConstants.FIELD_OTA_SIZE, latest.getSize()
        ));
        cmd.setQos(DeviceCommandConstants.DEFAULT_QOS);
        cmd.setRetain(DeviceCommandConstants.DEFAULT_RETAIN);
        cmd.setStatus(DeviceCommandStatus.PENDING.getCode());
        cmd.setRetryCount(DeviceCommandConstants.DEFAULT_RETRY_COUNT);
        cmd.setMaxRetry(DeviceCommandConstants.DEFAULT_MAX_RETRY);
        cmd.setOperator("user_" + userId); // 标记是用户端发起的
        cmd.setSource(DeviceCommandConstants.SOURCE_WEB);
        cmd.setExpireTime(now.plusMinutes(DeviceCommandConstants.DEFAULT_EXPIRE_SECONDS));
        cmd.setCreateTime(now);
        cmd.setUpdateTime(now);

        commandService.save(cmd);

        // 5. 立即通过 MQTT 下发
        try {
            commandSender.send(cmd);
            commandService.updateStatus(cmd.getId(), DeviceCommandStatus.SENT.getCode(), null);
            commandService.incrementRetryCount(cmd.getId());
            log.info("用户端 OTA 指令下发成功 - userId: {}, deviceId: {}, commandId: {}", userId, deviceId, cmd.getCommandId());
        } catch (Exception e) {
            log.error("用户端 OTA 指令下发失败 - commandId: {}", cmd.getCommandId(), e);
        }
    }

    /**
     * 安全校验：校验设备归属权
     */
    private void checkDeviceBinding(Long userId, String deviceId) {
        DeviceBinding binding = bindingMapper.selectOne(
                new LambdaQueryWrapper<DeviceBinding>()
                        .eq(DeviceBinding::getDeviceId, deviceId)
                        .eq(DeviceBinding::getUserId, userId)
                        .eq(DeviceBinding::getBindStatus, BindStatus.BOUND)
        );
        if (binding == null) {
            throw new BusinessException(ErrorCode.DEVICE_NO_PERMISSION, ErrorCode.DEVICE_NO_PERMISSION.getMessage());
        }
    }
}