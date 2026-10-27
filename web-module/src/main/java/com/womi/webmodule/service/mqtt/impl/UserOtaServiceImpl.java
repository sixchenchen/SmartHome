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
import com.womi.commonmodule.enums.DeviceCommandStatus;
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
        // 1. 👈 防越权：校验设备是否属于当前用户
        checkDeviceBinding(userId, deviceId);

        // 2. 查设备当前信息
        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) {
            throw new BusinessException(400, "设备不存在");
        }

        // 3. 查询该产品最新启用的固件
        DeviceFirmware latest = firmwareService.getOne(
                new LambdaQueryWrapper<DeviceFirmware>()
                        .eq(DeviceFirmware::getProduct, device.getProduct())
                        .eq(DeviceFirmware::getStatus, 1)
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
        // 1. 👈 防越权
        checkDeviceBinding(userId, deviceId);

        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) throw new BusinessException(400, "设备不存在");
        if (device.getOnline() != 1) throw new BusinessException(400, "设备不在线，无法升级");

        // 2. 再次查最新固件（防止前端传假数据）
        DeviceFirmware latest = firmwareService.getOne(
                new LambdaQueryWrapper<DeviceFirmware>()
                        .eq(DeviceFirmware::getProduct, device.getProduct())
                        .eq(DeviceFirmware::getStatus, 1)
                        .orderByDesc(DeviceFirmware::getCreateTime)
                        .last("LIMIT 1")
        );
        if (latest == null || latest.getVersion().equals(device.getFirmware())) {
            throw new BusinessException(400, "当前已是最新版本，无需升级");
        }

        // 3. 防并发：检查该设备是否已有正在进行的 OTA
        boolean running = commandService.exists(
                new LambdaQueryWrapper<DeviceCommand>()
                        .eq(DeviceCommand::getDeviceId, deviceId)
                        .eq(DeviceCommand::getTarget, "ota")
                        .in(DeviceCommand::getStatus, 0, 1, 6)
        );
        if (running) {
            throw new BusinessException(400, "该设备正在升级中，请耐心等待");
        }

        // 4. 组装 OTA 指令
        LocalDateTime now = LocalDateTime.now();
        DeviceCommand cmd = new DeviceCommand();
        cmd.setCommandId(UUID.randomUUID().toString().replace("-", ""));
        cmd.setDeviceId(deviceId);
        cmd.setAction("start");
        cmd.setTarget("ota");
        cmd.setParams(Map.of(
                "url", latest.getUrl(),
                "version", latest.getVersion(),
                "sha256", latest.getSha256(),
                "size", latest.getSize()
        ));
        cmd.setQos(1);
        cmd.setRetain(0);
        cmd.setStatus(DeviceCommandStatus.PENDING.getCode());
        cmd.setRetryCount(0);
        cmd.setMaxRetry(3);
        cmd.setOperator("user_" + userId); // 标记是用户端发起的
        cmd.setSource("APP");
        cmd.setExpireTime(now.plusMinutes(30));
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
     * 👈 核心安全校验：校验设备归属权
     */
    private void checkDeviceBinding(Long userId, String deviceId) {
        DeviceBinding binding = bindingMapper.selectOne(
                new LambdaQueryWrapper<DeviceBinding>()
                        .eq(DeviceBinding::getDeviceId, deviceId)
                        .eq(DeviceBinding::getUserId, userId)
                        .eq(DeviceBinding::getBindStatus, 1)
        );
        if (binding == null) {
            throw new BusinessException(403, "您未绑定该设备，无权操作");
        }
    }
}