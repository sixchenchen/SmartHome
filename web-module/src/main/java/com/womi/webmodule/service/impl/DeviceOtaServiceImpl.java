package com.womi.webmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.model.DeviceInfo;
import com.womi.businessmodule.model.Firmware;
import com.womi.businessmodule.service.DeviceCommandService;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.businessmodule.service.FirmwareService;
import com.womi.commonmodule.constants.CommandConstants;
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.commonmodule.constants.MqttConstants;
import com.womi.commonmodule.enums.CommandStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.utils.OtaStateUtils;
import com.womi.webmodule.dto.http.request.SendCommandRequest;
import com.womi.webmodule.dto.ota.request.OtaParam;
import com.womi.webmodule.dto.ota.response.OtaProgressVO;
import com.womi.webmodule.dto.ota.response.OtaStartResponse;
import com.womi.webmodule.service.DeviceControlService;
import com.womi.webmodule.service.DeviceOtaService;
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
    private final FirmwareService firmwareService;
    private final DeviceCommandService deviceCommandService;
    private final DeviceControlService deviceControlService;

    // ==================== 主入口 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public OtaStartResponse startOta(SendCommandRequest request) {
        String deviceId = request.getDeviceId();
        validateDeviceId(deviceId);

        // 1. 查设备 + 校验 OTA 状态（含僵死自愈）
        DeviceInfo device = getAndCheckDevice(deviceId);

        // 2. 校验无未完成的 OTA 指令
        checkNoRunningOtaCommand(deviceId);

        // 3. 查固件 + 校验
        Long firmwareId = parseFirmwareId(request.getParams());
        Firmware firmware = getAndCheckFirmware(firmwareId);

        // 4. 校验版本
        checkVersionDiff(device, firmware);

        // 5. 组装下发参数 + 下发
        DeviceCommand command = dispatchOta(deviceId, firmware, request);

        log.info("OTA 触发成功 - deviceId: {}, firmwareId: {}, version: {}, commandId: {}",
                deviceId, firmwareId, firmware.getVersion(), command.getCommandId());

        // 6. 组装响应
        OtaStartResponse response = new OtaStartResponse(1);
        response.addResult(deviceId, true, command.getCommandId(), firmware.getVersion(), null);
        return response;
    }

    @Override
    public OtaProgressVO getOtaProgress(String deviceId) {
        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) {
            return null;
        }
        OtaProgressVO vo = new OtaProgressVO();
        vo.setDeviceId(device.getDeviceId());
        vo.setOtaState(device.getOtaState());
        vo.setOtaProgress(device.getOtaProgress());
        vo.setOtaVersion(device.getOtaVersion());
        vo.setUpdateTime(device.getUpdateTime());
        return vo;
    }

    // ==================== 私有方法：校验 ====================

    /**
     * 校验 deviceId
     */
    private void validateDeviceId(String deviceId) {
        if (deviceId == null || deviceId.isBlank()) {
            throw new BusinessException(ErrorCode.PARAM_MISSING);
        }
    }

    /**
     * 查设备 + 校验 OTA 状态（含僵死自愈）:返回最新设备信息
     */
    private DeviceInfo getAndCheckDevice(String deviceId) {
        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_FOUND);
        }

        // 不在 OTA 中 → 直接返回
        if (!OtaStateUtils.isRunning(device.getOtaState())) {
            return device;
        }

        // 僵死 → 自动清理
        if (OtaStateUtils.isStale(device.getOtaState(), device.getOtaUpdateTime())) {
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
                        .eq(DeviceCommand::getTarget, MqttConstants.TARGET_OTA)
                        .in(DeviceCommand::getStatus,
                                CommandStatus.PENDING.getCode(),
                                CommandStatus.SENT.getCode(),
                                CommandStatus.ACCEPTED.getCode()));
        if (exists) {
            log.warn("OTA 拒绝：存在未完成的 OTA 指令 - deviceId: {}", deviceId);
            throw new BusinessException(ErrorCode.OTA_IN_PROGRESS,
                    "已有未完成的 OTA 指令，请等待完成或超时");
        }
    }

    /**
     * 查固件 + 校验状态
     */
    private Firmware getAndCheckFirmware(Long firmwareId) {
        Firmware firmware = firmwareService.getById(firmwareId);
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
    private void checkVersionDiff(DeviceInfo device, Firmware firmware) {
        String current = device.getFirmware();
        if (current != null && !current.isBlank() && current.equals(firmware.getVersion())) {
            log.warn("OTA 拒绝：设备已是该版本 - deviceId: {}, version: {}",
                    device.getDeviceId(), current);
            throw new BusinessException(ErrorCode.OTA_VERSION_INCOMPATIBLE,
                    "设备已是版本 " + current + "，无需重复升级");
        }
    }

    /**
     * 组装参数 + 下发 OTA 指令
     */
    private DeviceCommand dispatchOta(String deviceId, Firmware firmware, SendCommandRequest request) {
        OtaParam otaParam = new OtaParam(
                firmware.getUrl(),
                firmware.getVersion(),
                firmware.getSha256(),
                firmware.getSize());

        String operator = (request.getOperator() != null && !request.getOperator().isBlank())
                ? request.getOperator()
                : CommandConstants.DEFAULT_OPERATOR;

        Integer reqExpire = request.getExpireSeconds();
        int expireSeconds = (reqExpire != null && reqExpire > 0)
                ? reqExpire
                : CommandConstants.OTA_EXPIRE_SECONDS;

        return deviceControlService.sendCommand(
                deviceId,
                MqttConstants.ACTION_START,
                MqttConstants.TARGET_OTA,
                null,
                otaParam.toMap(),
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

        Object value = params.get(MqttConstants.FIELD_FIRMWARE_ID);
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