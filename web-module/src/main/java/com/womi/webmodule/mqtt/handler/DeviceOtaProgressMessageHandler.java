package com.womi.webmodule.mqtt.handler;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.commonmodule.constants.DeviceCommandConstants;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.constants.DeviceOtaStateConstants;
import com.womi.commonmodule.constants.ErrorInfoConstants;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.utils.DeviceOtaStateUtils;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import com.womi.webmodule.service.common.WebSocketPushService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.LinkedHashMap;
import java.util.Map;

/*
  OTA 进度上报处理器
  topic: device/{mac}/ota_progress
  payload:
  {
    "device": "B4BFE90CDBA1",
    "type": "ota_progress",
    "commandId": "f47ac10b58cc4372a5670e02b2c3d479",
    "timestamp": 1710000000000,
    "data": {
      "otaState": "downloading",
      "progress": 45,
      "version": "1.0.30",
      "error": "校验失败"
    }
  }
*/
@Slf4j
@Component
@Order(3)
@RequiredArgsConstructor
public class DeviceOtaProgressMessageHandler implements MqttMessageHandler {

    private final JsonUtils jsonUtils;
    private final DeviceInfoService deviceInfoService;
    private final DeviceCommandService deviceCommandService;
    private final WebSocketPushService webSocketPushService;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(DeviceMqttConstants.OTA_PROGRESS_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        String deviceId = extractDeviceId(topic);
        JsonNode json = jsonUtils.parse(payload);

        // 提取报文中顶层的 commandId
        String commandId = jsonUtils.getString(json, DeviceMqttConstants.FIELD_COMMAND_ID);

        JsonNode dataNode = json.path(DeviceMqttConstants.FIELD_DATA);

        String rawState = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_OTA_STATE);
        if (rawState == null || rawState.isBlank()) {
            throw new IllegalArgumentException(ErrorInfoConstants.OTA_STATE_MISSING);
        }
        String state = rawState.trim().toLowerCase();

        Integer progress = jsonUtils.getInt(dataNode, DeviceMqttConstants.FIELD_OTA_PROGRESS);
        if (progress == null) progress = 0;
        progress = Math.max(0, Math.min(100, progress));
        // 升级成功统一收敛为 100%，避免设备少报最后一个百分点
        if (DeviceOtaStateConstants.SUCCESS.equals(state)) {
            progress = 100;
        }

        String version = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_OTA_VERSION);

        // 失败原因：优先取 data.error，其次 data.message / 顶层 message
        String errorMsg = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_ERROR);
        if (!StringUtils.hasText(errorMsg)) {
            errorMsg = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_MESSAGE);
        }
        if (!StringUtils.hasText(errorMsg)) {
            errorMsg = jsonUtils.getString(json, DeviceMqttConstants.FIELD_MESSAGE);
        }

        // 设备上报时间（毫秒时间戳），用于前端判断进度是否"太久没更新"
        Long reportTs = jsonUtils.getLong(json, DeviceMqttConstants.FIELD_TIMESTAMP);

        // 1. 更新设备主表的实时状态（供前端实时看板展示）
        deviceInfoService.updateOtaState(deviceId, state, progress, version);

        // 2. OTA 成功 → 兜底同步固件版本
        if (DeviceOtaStateConstants.SUCCESS.equals(state)) {
            deviceInfoService.syncFirmwareIfTarget(deviceId, version);
        }

        // 3. 关联并推进 OTA 指令状态（设备未发 ACK 时也能让记录/进度保持一致）
        DeviceCommand command = resolveOtaCommand(deviceId, commandId);
        if (command != null) {
            commandId = command.getCommandId();
            syncCommandStatus(command, state, errorMsg);
        }

        // 4. 实时推送给已订阅该设备的前端
        Map<String, Object> pushData = new LinkedHashMap<>();
        pushData.put(DeviceMqttConstants.FIELD_OTA_STATE, state);
        pushData.put(DeviceMqttConstants.FIELD_OTA_STATE_TEXT, DeviceOtaStateUtils.textOf(state));
        pushData.put(DeviceMqttConstants.FIELD_OTA_PROGRESS, progress);
        pushData.put(DeviceMqttConstants.FIELD_OTA_VERSION, version);
        pushData.put(DeviceMqttConstants.FIELD_COMMAND_ID, commandId);
        pushData.put(DeviceMqttConstants.FIELD_ERROR, errorMsg);
        pushData.put(DeviceMqttConstants.FIELD_REPORT_TIME, reportTs == null ? null : toLocalDateTime(reportTs));
        webSocketPushService.pushOtaProgress(deviceId, pushData);

        // 5. 日志中带上 commandId，方便排查追踪
        log.info("OTA 进度上报 - deviceId: {}, commandId: {}, state: {}, progress: {}, version: {}, error: {}",
                deviceId, commandId != null ? commandId : "未知", state, progress, version, errorMsg);
    }

    /**
     * 定位本次进度对应的 OTA 指令：优先使用报文中 commandId，缺失时回退到该设备最近的活跃 OTA 指令。
     */
    private DeviceCommand resolveOtaCommand(String deviceId, String commandId) {
        if (StringUtils.hasText(commandId)) {
            DeviceCommand command = deviceCommandService.getByCommandId(commandId);
            if (command != null && deviceId.equals(command.getDeviceId())
                    && DeviceMqttConstants.TARGET_OTA.equals(command.getTarget())) {
                return command;
            }
            log.warn("OTA 进度中的 commandId 无效或不属于该设备 - deviceId: {}, commandId: {}", deviceId, commandId);
        }
        return deviceCommandService.getOne(new LambdaQueryWrapper<DeviceCommand>()
                .eq(DeviceCommand::getDeviceId, deviceId)
                .eq(DeviceCommand::getTarget, DeviceMqttConstants.TARGET_OTA)
                .in(DeviceCommand::getStatus, DeviceCommandConstants.ACTIVE_STATUSES)
                .orderByDesc(DeviceCommand::getCreateTime)
                .last("LIMIT 1"));
    }

    /**
     * 按进度阶段推进指令状态，只允许向前流转，避免覆盖终态或迟到的旧进度。
     */
    private void syncCommandStatus(DeviceCommand command, String state, String errorMsg) {
        Integer current = command.getStatus();
        DeviceCommandStatus currentStatus = DeviceCommandStatus.fromCode(current);
        if (currentStatus == null || currentStatus.isFinished()) {
            return;
        }

        if (DeviceOtaStateConstants.SUCCESS.equals(state)) {
            deviceCommandService.updateStatus(command.getId(), DeviceCommandStatus.SUCCESS.getCode(), null);
            log.info("OTA 进度到达成功，指令状态同步为 SUCCESS - commandId: {}", command.getCommandId());
            return;
        }

        if (DeviceOtaStateConstants.FAILED.equals(state)) {
            String reason = StringUtils.hasText(errorMsg) ? errorMsg : ErrorInfoConstants.OTA_FAILED_REPORTED;
            deviceCommandService.updateStatus(command.getId(), DeviceCommandStatus.FAILED.getCode(), reason);
            log.info("OTA 进度到达失败，指令状态同步为 FAILED - commandId: {}, reason: {}",
                    command.getCommandId(), reason);
            return;
        }

        // 设备已开始处理升级流程（accepted/downloading/...），未 ACK 时也标记为已接收
        if (currentStatus == DeviceCommandStatus.PENDING || currentStatus == DeviceCommandStatus.SENT) {
            deviceCommandService.updateStatus(command.getId(), DeviceCommandStatus.ACCEPTED.getCode(), null);
        }
    }

    private LocalDateTime toLocalDateTime(Long epochMillis) {
        return Instant.ofEpochMilli(epochMillis).atZone(ZoneId.systemDefault()).toLocalDateTime();
    }
}
