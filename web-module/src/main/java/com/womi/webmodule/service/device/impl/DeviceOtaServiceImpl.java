package com.womi.webmodule.service.device.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.model.device.DeviceFirmware;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.businessmodule.service.device.DeviceFirmwareService;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.commonmodule.constants.DeviceCommandConstants;
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.utils.DeviceOtaStateUtils;
import com.womi.businessmodule.dto.SendCommandRequest;
import com.womi.businessmodule.dto.DeviceOtaParam;
import com.womi.businessmodule.vo.DeviceOtaProgressVO;
import com.womi.businessmodule.vo.DeviceOtaStartResponse;
import com.womi.webmodule.service.device.DeviceControlService;
import com.womi.webmodule.service.device.DeviceOtaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

/**
 * OTA 升级服务：前端请求示例
 * POST /device/ota/start
 * {
 * "deviceId": "B4BFE90CDBA1",
 * "action": "start",
 * "target": "ota",
 * "params": { "firmwareId": 5 },
 * "operator": "admin",
 * "expireSeconds": 900
 * }
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceOtaServiceImpl implements DeviceOtaService {

    private final DeviceInfoService deviceInfoService;
    private final DeviceFirmwareService firmwareService;
    private final DeviceCommandService deviceCommandService;
    private final DeviceControlService deviceControlService;

    // ==================== 主入口 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceOtaStartResponse startOta(SendCommandRequest request) {
        String deviceId = request.getDeviceId();
        // 校验deviceId是否合法
        if (deviceId == null || deviceId.isBlank()) {
            throw new BusinessException(ErrorCode.PARAM_MISSING);
        }
        // 1. 查设备 + 校验 OTA 状态
        DeviceInfo device = getAndCheckDevice(deviceId);

        // 2. 校验无未完成的 OTA 指令
        checkNoRunningOtaCommand(deviceId);

        // 3. 查固件 + 校验
        Long firmwareId = parseFirmwareId(request.getParams());
        DeviceFirmware firmware = getAndCheckFirmware(firmwareId);

        // 4. 校验版本
        checkVersionDiff(device, firmware);

        // 5. 组装下发参数 + 下发
        DeviceCommand command = dispatchOta(deviceId, firmware, request);

        log.info("OTA 触发成功 - deviceId: {}, firmwareId: {}, version: {}, commandId: {}", deviceId, firmwareId, firmware.getVersion(), command.getCommandId());

        // 6. 组装响应
        DeviceOtaStartResponse response = new DeviceOtaStartResponse(1);
        response.addResult(deviceId, true, command.getCommandId(), firmware.getVersion(), null);
        return response;
    }

    @Override
    public DeviceOtaProgressVO getOtaProgress(String deviceId) {
        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) {
            return null;
        }
        DeviceOtaProgressVO vo = new DeviceOtaProgressVO();
        vo.setDeviceId(device.getDeviceId());
        vo.setOtaState(device.getOtaState());
        vo.setOtaProgress(device.getOtaProgress());
        vo.setOtaVersion(device.getOtaVersion());
        vo.setUpdateTime(device.getUpdateTime());
        return vo;
    }

    // ==================== 私有方法：校验 ====================

    /**
     * 查设备 + 校验 OTA 状态:返回最新设备信息
     */
    private DeviceInfo getAndCheckDevice(String deviceId) {
        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_FOUND);
        }

        // 不在 OTA 中 → 直接返回
        if (!DeviceOtaStateUtils.isRunning(device.getOtaState())) {
            return device;
        }

        // 僵死 → 自动清理
        if (DeviceOtaStateUtils.isStale(device.getOtaState(), device.getOtaUpdateTime())) {
            log.warn("检测到僵死 OTA 状态，自动清理 - deviceId: {}, otaState: {}, lastUpdate: {}", deviceId, device.getOtaState(), device.getOtaUpdateTime());
            cleanStaleOtaState(device);
            return deviceInfoService.getByDeviceId(deviceId);
        }

        // 真的在升级中 → 拒绝
        log.warn("OTA 拒绝：设备正在升级中 - deviceId: {}, otaState: {}", deviceId, device.getOtaState());
        throw new BusinessException(ErrorCode.OTA_IN_PROGRESS, "设备正在升级中，当前状态：" + device.getOtaState());
    }

    /**
     * 清理僵死 OTA 状态
     */
    private void cleanStaleOtaState(DeviceInfo device) {
        device.setOtaState(null);
        device.setOtaProgress(null);
        device.setOtaUpdateTime(null);
        deviceInfoService.updateById(device);
        log.info("已清理僵死 OTA 状态 - deviceId: {}", device.getDeviceId());
    }

    /**
     * 校验无未完成的 OTA 指令
     */
    private void checkNoRunningOtaCommand(String deviceId) {
        boolean exists = deviceCommandService.exists(
                new LambdaQueryWrapper<DeviceCommand>()
                        .eq(DeviceCommand::getDeviceId, deviceId)
                        .eq(DeviceCommand::getTarget, DeviceMqttConstants.TARGET_OTA)
                        .in(DeviceCommand::getStatus,
                                DeviceCommandStatus.PENDING.getCode(),
                                DeviceCommandStatus.SENT.getCode(),
                                DeviceCommandStatus.ACCEPTED.getCode()));
        if (exists) {
            log.warn("OTA 拒绝：存在未完成的 OTA 指令 - deviceId: {}", deviceId);
            throw new BusinessException(ErrorCode.OTA_IN_PROGRESS, "已有未完成的 OTA 指令，请等待完成或超时");
        }
    }

    /**
     * 查固件 + 校验状态
     */
    private DeviceFirmware getAndCheckFirmware(Long firmwareId) {
        DeviceFirmware firmware = firmwareService.getById(firmwareId);
        if (firmware == null) {
            throw new BusinessException(ErrorCode.FIRMWARE_NOT_FOUND);
        }
        if (firmware.getStatus() == null
                || firmware.getStatus() != DeviceConstants.FIRMWARE_STATUS_ENABLE) {
            throw new BusinessException(ErrorCode.FIRMWARE_DISABLED);
        }
        return firmware;
    }

    /**
     * 校验设备当前版本 ≠ 目标版本
     */
    private void checkVersionDiff(DeviceInfo device, DeviceFirmware firmware) {
        String current = device.getFirmware();
        if (current != null && !current.isBlank() && current.equals(firmware.getVersion())) {
            log.warn("OTA 拒绝：设备已是该版本 - deviceId: {}, version: {}", device.getDeviceId(), current);
            throw new BusinessException(ErrorCode.OTA_VERSION_INCOMPATIBLE, "设备已是版本 " + current + "，无需重复升级");
        }
    }

    /**
     * 组装参数 + 下发 OTA 指令
     */
    private DeviceCommand dispatchOta(String deviceId, DeviceFirmware firmware, SendCommandRequest request) {
        DeviceOtaParam deviceOtaParam = DeviceOtaParam.builder()
                .url(firmware.getUrl())
                .version(firmware.getVersion())
                .sha256(firmware.getSha256())
                .size(firmware.getSize())
                .build();
        String operator = (request.getOperator() != null && !request.getOperator().isBlank())
                ? request.getOperator() : DeviceCommandConstants.DEFAULT_OPERATOR;

        Integer reqExpire = request.getExpireSeconds();
        int expireSeconds = (reqExpire != null && reqExpire > 0)
                ? reqExpire : DeviceCommandConstants.OTA_EXPIRE_SECONDS;

        return deviceControlService.sendCommand(
                deviceId,
                DeviceMqttConstants.ACTION_START,
                DeviceMqttConstants.TARGET_OTA,
                null,
                deviceOtaParam.toMap(),
                operator,
                expireSeconds);
    }

    /**
     * 从 params 提取 firmwareId
     */
    private Long parseFirmwareId(Map<String, Object> params) {
        if (params == null || params.isEmpty()) {
            throw new BusinessException(ErrorCode.PARAM_MISSING, "OTA params 不能为空");
        }

        Object value = params.get(DeviceMqttConstants.FIELD_FIRMWARE_ID);
        if (value == null) {
            throw new BusinessException(ErrorCode.PARAM_MISSING, "OTA 缺少 firmwareId");
        }

        long id;
        try {
            id = Long.parseLong(value.toString().trim());
        } catch (NumberFormatException e) {
            throw new BusinessException(ErrorCode.PARAM_INVALID, "firmwareId 格式错误");
        }
        if (id <= 0) {
            throw new BusinessException(ErrorCode.PARAM_INVALID, "firmwareId 必须大于 0");
        }
        return id;
    }
}