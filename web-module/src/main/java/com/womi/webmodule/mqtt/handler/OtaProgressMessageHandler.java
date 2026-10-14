package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.commonmodule.constants.MqttConstants;
import com.womi.commonmodule.constants.OtaStateConstants;
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
public class OtaProgressMessageHandler implements MqttMessageHandler {

    private final JsonUtils jsonUtils;
    private final DeviceInfoService deviceInfoService;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(MqttConstants.OTA_PROGRESS_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        try {
            // 1. 提取 deviceId
            String deviceId = extractDeviceId(topic);
            if (deviceId == null) {
                log.warn("无法提取设备ID - Topic: {}", topic);
                return;
            }
            // 2. 解析 payload
            JsonNode json = jsonUtils.parse(payload);
            if (json == null) {
                log.warn("OTA 进度 payload 解析失败 - Topic: {}", topic);
                return;
            }
            // 3. 进入 data 节点
            JsonNode dataNode = json.path(MqttConstants.FIELD_DATA);
            if (dataNode.isMissingNode() || !dataNode.isObject()) {
                log.warn("OTA 进度缺少 data 节点 - deviceId: {}", deviceId);
                return;
            }
            // 4. 从 data 里读 otaState / progress / version
            String state = jsonUtils.getString(dataNode, MqttConstants.FIELD_OTA_STATE);
            if (state == null || state.isBlank()) {
                log.warn("OTA 进度缺少 state - deviceId: {}", deviceId);
                return;
            }
            Integer progress = jsonUtils.getInt(dataNode, MqttConstants.FIELD_OTA_PROGRESS);
            if (progress == null) {
                progress = 0;
            }
            progress = Math.max(0, Math.min(100, progress));
            String version = jsonUtils.getString(dataNode, MqttConstants.FIELD_OTA_VERSION);
            // 5. 更新设备 OTA 状态
            deviceInfoService.updateOtaState(deviceId, state, progress, version);
            // 6. OTA 成功 → 兜底同步固件版本（双保险：即使最终 ACK 丢失也能收敛）
            if (OtaStateConstants.SUCCESS.equals(state)) {
                deviceInfoService.syncFirmwareIfTarget(deviceId, version);
            }
            log.info("OTA 进度上报 - deviceId: {}, state: {}, progress: {}, version: {}",deviceId, state, progress, version);
        } catch (Exception e) {
            log.error("处理 OTA 进度失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}