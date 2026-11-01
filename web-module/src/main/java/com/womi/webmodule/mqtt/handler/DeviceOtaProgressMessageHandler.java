package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.constants.DeviceOtaStateConstants;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/*
  OTA 进度上报处理器
  topic: device/{mac}/ota_progress
  payload:
  {
    "device": "B4BFE90CDBA1",
    "type": "ota_progress",
    "commandId": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "timestamp": 1710000000000,
    "data": {
      "otaState": "downloading",
      "progress": 45,
      "version": "1.0.30"
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

        String state = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_OTA_STATE);
        if (state == null || state.isBlank()) {
            throw new IllegalArgumentException("OTA 进度缺少 state");
        }

        Integer progress = jsonUtils.getInt(dataNode, DeviceMqttConstants.FIELD_OTA_PROGRESS);
        if (progress == null) progress = 0;
        progress = Math.max(0, Math.min(100, progress));

        String version = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_OTA_VERSION);

        // 1. 更新设备主表的实时状态（供前端实时看板展示）
        deviceInfoService.updateOtaState(deviceId, state, progress, version);

        // 2. OTA 成功 → 兜底同步固件版本
        if (DeviceOtaStateConstants.SUCCESS.equals(state)) {
            deviceInfoService.syncFirmwareIfTarget(deviceId, version);
        }

        // 3. 日志中带上 commandId，方便排查追踪
        log.info("OTA 进度上报 - deviceId: {}, commandId: {}, state: {}, progress: {}, version: {}",
                deviceId, commandId != null ? commandId : "未知", state, progress, version);

    }
}