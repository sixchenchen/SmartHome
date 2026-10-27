package com.womi.webmodule.service.mqtt.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.model.device.DeviceFirmware;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.service.common.CommandSender;
import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.businessmodule.service.device.DeviceFirmwareService;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.commonmodule.constants.DeviceCommandConstants;
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.constants.FirmwareConstants;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.utils.DeviceOtaStateUtils;
import com.womi.businessmodule.dto.SendCommandRequest;
import com.womi.businessmodule.dto.DeviceOtaParam;
import com.womi.businessmodule.vo.DeviceOtaProgressVO;
import com.womi.businessmodule.vo.DeviceOtaStartResponse;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.service.mqtt.DeviceControlService;
import com.womi.webmodule.service.mqtt.DeviceOtaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

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
    private final CommandSender commandSender;

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
    /**
     * 管理员批量下发 OTA 升级
     * @param firmwareId 固件ID
     * @param targetProduct 目标产品型号（如果为空，代表全量）
     * @param operator 操作人
     * @return 本次涉及升级的指令数量
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int batchDispatchOta(Long firmwareId, String targetProduct, String operator) {
        // 1. 校验固件状态
        DeviceFirmware firmware = firmwareService.getById(firmwareId);
        if (firmware == null || firmware.getStatus() != FirmwareConstants.FIRMWARE_ENABLE) {
            log.warn("批量 OTA 失败：固件不存在或未启用 - firmwareId: {}", firmwareId);
            throw new BusinessException(ErrorCode.FIRMWARE_NOT_FOUND, "固件不存在或已被禁用");
        }
        log.info("[OTA-Dispatch] 开始执行批量下发 - 目标固件: {}, 目标版本: {}, 目标产品: {}",
                firmwareId, firmware.getVersion(), StringUtils.hasText(targetProduct) ? targetProduct : "全部");

        // 2. 筛选目标设备 (必须在线的，且当前版本不等于目标版本的)
        LambdaQueryWrapper<DeviceInfo> wrapper = new LambdaQueryWrapper<DeviceInfo>()
                .eq(DeviceInfo::getOnline, DeviceConstants.DEVICE_STATUS_ONLINE) // 条件 A: 必须在线
                .ne(DeviceInfo::getFirmware, firmware.getVersion()); // 条件 B: 版本不一致

        if (StringUtils.hasText(targetProduct)) {
            wrapper.eq(DeviceInfo::getProduct, targetProduct); // 条件 C: 产品匹配
        }

        List<DeviceInfo> devices = deviceInfoService.list(wrapper);

        // 日志：打印在线且满足条件的设备数量
        log.info("[OTA-Dispatch] 筛选到 {} 台在线且版本不匹配的设备", devices.size());

        if (devices.isEmpty()) {
            log.info("[OTA-Dispatch] 结束：没有符合条件的设备可升级");
            return 0;
        }

        // 3. 组装 OTA 参数
        DeviceOtaParam otaParam = DeviceOtaParam.builder()
                .url(firmware.getUrl())
                .version(firmware.getVersion())
                .sha256(firmware.getSha256())
                .size(firmware.getSize())
                .build();

        // 4. 批量生成指令记录
        List<DeviceCommand> commands = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        for (DeviceInfo device : devices) {
            // 日志：打印当前处理的设备
            log.info("[OTA-Dispatch] 正在检查设备: {}, 当前版本: {}", device.getDeviceId(), device.getFirmware());

            // 5. 防并发检查：检查该设备是否有未完成的 OTA 指令
            boolean existsRunning = deviceCommandService.exists(
                    new LambdaQueryWrapper<DeviceCommand>()
                            .eq(DeviceCommand::getDeviceId, device.getDeviceId())
                            .eq(DeviceCommand::getTarget, DeviceMqttConstants.TARGET_OTA)
                            .in(DeviceCommand::getStatus,
                                    DeviceCommandStatus.PENDING.getCode(),
                                    DeviceCommandStatus.SENT.getCode(),
                                    DeviceCommandStatus.ACCEPTED.getCode())
            );
            if (existsRunning) {
                // 日志：记录被跳过的设备及原因
                log.warn("[OTA-Dispatch] 跳过设备 {}：存在未完成的 OTA 指令", device.getDeviceId());
                continue;
            }

            DeviceCommand cmd = new DeviceCommand();
            cmd.setCommandId(UUID.randomUUID().toString().replace("-", ""));
            cmd.setDeviceId(device.getDeviceId());
            cmd.setAction(DeviceMqttConstants.ACTION_START);
            cmd.setTarget(DeviceMqttConstants.TARGET_OTA);
            cmd.setChannel(null);
            cmd.setParams(otaParam.toMap());
            cmd.setQos(1);
            cmd.setRetain(0);
            cmd.setStatus(DeviceCommandStatus.PENDING.getCode());
            cmd.setRetryCount(0);
            cmd.setMaxRetry(3);
            cmd.setOperator(operator != null ? operator : DeviceCommandConstants.DEFAULT_OPERATOR);
            cmd.setSource(DeviceCommandConstants.SOURCE_WEB);
            cmd.setExpireTime(now.plusMinutes(30));
            cmd.setCreateTime(now);
            cmd.setUpdateTime(now);

            commands.add(cmd);
        }

        if (commands.isEmpty()) {
            // 日志：虽然有设备，但全被防并发检查拦截了
            log.info("[OTA-Dispatch] 结束：所有符合条件的设备都存在未完成的 OTA 指令，无需重新生成");
            return 0;
        }

        // 6. 批量落库
        deviceCommandService.saveBatch(commands);

        log.info("[OTA-Dispatch] 成功生成 {} 条 OTA 升级指令，等待定时任务下发", commands.size());
        // 落库后立即发送 MQTT 并更新状态
        for (DeviceCommand cmd : commands) {
            try {
                // 调用发送器把消息发出去
                commandSender.send(cmd);

                // 发送成功，把状态从 0(PENDING) 改为 1(SENT)
                deviceCommandService.updateStatus(cmd.getId(), DeviceCommandStatus.SENT.getCode(), null);
                // 增加一次重试计数（代表已经发了一次）
                deviceCommandService.incrementRetryCount(cmd.getId());

                log.info("[OTA-Dispatch] OTA 指令立即下发成功 - commandId: {}", cmd.getCommandId());
            } catch (Exception e) {
                // 发送失败不用管，状态依然是 0(PENDING)，后面要靠定时任务兜底
                log.error("[OTA-Dispatch] OTA 指令立即下发失败 - commandId: {}", cmd.getCommandId(), e);
            }
        }
        return commands.size();
    }
}