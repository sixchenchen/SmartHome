package com.womi.webmodule.service.impl;

import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.model.DeviceInfo;
import com.womi.businessmodule.model.Firmware;
import com.womi.businessmodule.service.DeviceCommandService;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.businessmodule.service.FirmwareService;
import com.womi.commonmodule.constants.CommandConstants;
import com.womi.commonmodule.constants.ErrorInfoConstants;
import com.womi.commonmodule.constants.MqttConstants;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.dto.ota.request.OtaStartRequest;
import com.womi.webmodule.dto.ota.response.OtaProgressVO;
import com.womi.webmodule.dto.ota.response.OtaStartResponse;
import com.womi.webmodule.service.DeviceOtaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceOtaServiceImpl implements DeviceOtaService {

    /**
     * OTA 默认过期时间：10 分钟
     */
    private static final int DEFAULT_OTA_EXPIRE_SECONDS = 600;

    private final DeviceInfoService deviceInfoService;
    private final DeviceCommandService deviceCommandService;
    private final FirmwareService firmwareService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public OtaStartResponse startOta(OtaStartRequest request) {
        // 1. 校验固件
        if (request.getFirmwareId() == null) {
            throw new IllegalArgumentException("firmwareId 不能为空");
        }
        Firmware firmware = firmwareService.getById(request.getFirmwareId());
        if (firmware == null) {
            throw new IllegalArgumentException("固件不存在: id=" + request.getFirmwareId());
        }
        if (firmware.getStatus() == null || firmware.getStatus() != 1) {
            throw new IllegalArgumentException("固件已禁用: id=" + request.getFirmwareId());
        }

        // 2. 组装设备列表
        List<String> deviceIds = new ArrayList<>();
        if (request.getDeviceId() != null && !request.getDeviceId().isBlank()) {
            deviceIds.add(request.getDeviceId());
        }
        if (request.getDeviceIds() != null) {
            deviceIds.addAll(request.getDeviceIds());
        }
        if (deviceIds.isEmpty()) {
            throw new IllegalArgumentException("deviceId 或 deviceIds 不能为空");
        }

        // 3. 逐个下发
        OtaStartResponse response = new OtaStartResponse();
        response.setTotal(deviceIds.size());

        int expireSeconds = request.getExpireSeconds() != null && request.getExpireSeconds() > 0
                ? request.getExpireSeconds()
                : DEFAULT_OTA_EXPIRE_SECONDS;

        for (String deviceId : deviceIds) {
            try {
                DeviceCommand command = prepareOtaCommand(deviceId, firmware, request.getOperator(), expireSeconds);
                response.getCommandIds().add(command.getCommandId());
                response.setSuccess(response.getSuccess() + 1);

                log.info("OTA 触发成功 - deviceId: {}, version: {}, commandId: {}", deviceId, firmware.getVersion(), command.getCommandId());
            } catch (Exception e) {
                log.error("OTA 触发失败 - deviceId: {}, error: {}", deviceId, e.getMessage());
                response.getFailedDevices().add(deviceId);
                response.setFailed(response.getFailed() + 1);
            }
        }

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
        vo.setLastUpdateTime(device.getLastUpdateTime());
        return vo;
    }

    // ==================== 私有方法 ====================

    /**
     * 组装 OTA 指令（入库 + MQTT 下发）
     */
    private DeviceCommand prepareOtaCommand(String deviceId, Firmware firmware,
                                            String operator, int expireSeconds) {
        // 校验设备存在
        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_FOUND, ErrorInfoConstants.DEVICE_NOT_FOUND);
        }

        // 组装 params
        Map<String, Object> params = new LinkedHashMap<>();
        params.put(MqttConstants.FIELD_OTA_URL, firmware.getUrl());
        params.put(MqttConstants.FIELD_OTA_VERSION, firmware.getVersion());
        if (firmware.getMd5() != null) {
            params.put(MqttConstants.FIELD_OTA_MD5, firmware.getMd5());
        }
        if (firmware.getSize() != null) {
            params.put(MqttConstants.FIELD_OTA_SIZE, firmware.getSize());
        }

        // 入库 + MQTT 下发
        return deviceCommandService.prepareCommand(
                deviceId,
                MqttConstants.ACTION_START,
                MqttConstants.TARGET_OTA,
                null,
                params,
                operator != null ? operator : CommandConstants.DEFAULT_OPERATOR,
                CommandConstants.DEFAULT_SOURCE,
                expireSeconds
        );
    }
}