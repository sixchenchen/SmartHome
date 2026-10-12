package com.womi.webmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.model.DeviceInfo;
import com.womi.businessmodule.model.Firmware;
import com.womi.businessmodule.service.DeviceCommandService;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.businessmodule.service.FirmwareService;
import com.womi.commonmodule.constants.CommandConstants;
import com.womi.commonmodule.constants.MqttConstants;
import com.womi.commonmodule.enums.CommandStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.dto.http.request.SendCommandRequest;
import com.womi.webmodule.dto.ota.request.OtaParam;
import com.womi.webmodule.dto.ota.response.OtaProgressVO;
import com.womi.webmodule.dto.ota.response.OtaStartResponse;
import com.womi.webmodule.service.DeviceControlService;
import com.womi.webmodule.service.DeviceOtaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Set;

/**
 * OTA 升级服务
 *
 * 前端请求示例：
 * POST /device/ota/start
 * {
 *   "deviceId": "B4BFE90CDBA1",
 *   "action": "start",
 *   "target": "ota",
 *   "params": { "firmwareId": 5 },
 *   "operator": "admin",
 *   "expireSeconds": 900
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

    /**
     * OTA 进行中的状态集合
     * <p>落在这几个状态的设备，拒绝再次发起 OTA
     */
    private static final Set<String> OTA_RUNNING_STATES = Set.of(
            "accepted", "downloading", "verifying", "flashing", "rebooting"
    );

    // ==================== 主入口 ====================

    @Override
    public OtaStartResponse startOta(SendCommandRequest request) {
        // ========== 1. 校验 deviceId ==========
        String deviceId = request.getDeviceId();
        if (deviceId == null || deviceId.isBlank()) {
            throw new BusinessException(ErrorCode.PARAM_MISSING, "deviceId 不能为空");
        }

        // ========== 2. 校验设备存在 ==========
        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_FOUND);
        }

        // ========== 3. 校验设备当前未在 OTA 中 ==========
        if (isOtaInProgress(device.getOtaState())) {
            log.warn("OTA 拒绝：设备正在升级中 - deviceId: {}, otaState: {}", deviceId, device.getOtaState());
            throw new BusinessException(ErrorCode.OTA_IN_PROGRESS, "设备正在升级中，当前状态：" + device.getOtaState());
        }

        // ========== 4. 校验 DB 中无未完成的 OTA 指令 ==========
        if (hasRunningOtaCommand(deviceId)) {
            log.warn("OTA 拒绝：存在未完成的 OTA 指令 - deviceId: {}", deviceId);
            throw new BusinessException(ErrorCode.OTA_IN_PROGRESS, "已有未完成的 OTA 指令，请等待完成或超时");
        }

        // ========== 5. 提取 firmwareId ==========
        Long firmwareId = extractFirmwareId(request.getParams());

        // ========== 6. 查固件 + 校验状态 ==========
        Firmware firmware = firmwareService.getById(firmwareId);
        if (firmware == null) {
            throw new BusinessException(ErrorCode.FIRMWARE_NOT_FOUND);
        }
        if (firmware.getStatus() == null || firmware.getStatus() != 1) {
            throw new BusinessException(ErrorCode.FIRMWARE_DISABLED);
        }

        // ========== 7. 校验版本：设备已是该版本则拒绝 ==========
        String currentFirmware = device.getFirmware();
        if (currentFirmware != null
                && !currentFirmware.isBlank()
                && currentFirmware.equals(firmware.getVersion())) {
            log.warn("OTA 拒绝：设备已是该版本 - deviceId: {}, version: {}", deviceId, currentFirmware);
            throw new BusinessException(ErrorCode.OTA_VERSION_INCOMPATIBLE, "设备已是版本 " + currentFirmware + "，无需重复升级");
        }

        // ========== 8. 组装下发参数 ==========
        OtaParam otaParam = new OtaParam(
                firmware.getUrl(),
                firmware.getVersion(),
                firmware.getSha256(),
                firmware.getSize());

        // ========== 9. 解析 operator / expireSeconds ==========
        String operator = (request.getOperator() != null && !request.getOperator().isBlank())
                ? request.getOperator()
                : CommandConstants.DEFAULT_OPERATOR;

        Integer reqExpire = request.getExpireSeconds();
        int expireSeconds = (reqExpire != null && reqExpire > 0)
                ? reqExpire
                : CommandConstants.OTA_EXPIRE_SECONDS;

        // ========== 10. 入库 + 下发 ==========
        DeviceCommand command = deviceControlService.sendCommand(
                deviceId,
                MqttConstants.ACTION_START,
                MqttConstants.TARGET_OTA,
                null,
                otaParam.toMap(),
                operator,
                expireSeconds);

        log.info("OTA 触发成功 - deviceId: {}, firmwareId: {}, version: {}, commandId: {}",
                deviceId, firmwareId, firmware.getVersion(), command.getCommandId());

        // ========== 11. 组装响应 ==========
        OtaStartResponse response = new OtaStartResponse(1);
        response.addResult(
                deviceId,
                true,
                command.getCommandId(),
                firmware.getVersion(),
                null
        );
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

    // ==================== 拦截工具方法 ====================

    /**
     * 判断设备是否在 OTA 进行中
     */
    private boolean isOtaInProgress(String otaState) {
        return otaState != null && OTA_RUNNING_STATES.contains(otaState);
    }

    /**
     * 判断 DB 中是否存在未完成的 OTA 指令
     * <p>只查 PENDING / SENT，终态（SUCCESS/FAILED/TIMEOUT/CANCELLED）不算
     */
    private boolean hasRunningOtaCommand(String deviceId) {
        return deviceCommandService.exists(
                new LambdaQueryWrapper<DeviceCommand>()
                        .eq(DeviceCommand::getDeviceId, deviceId)
                        .eq(DeviceCommand::getTarget, MqttConstants.TARGET_OTA)
                        .in(DeviceCommand::getStatus,
                                CommandStatus.PENDING.getCode(),
                                CommandStatus.SENT.getCode()));
    }

    /**
     * 从 params 提取 firmwareId
     */
    private Long extractFirmwareId(Map<String, Object> params) {
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