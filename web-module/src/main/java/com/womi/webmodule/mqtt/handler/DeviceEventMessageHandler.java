package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.model.device.DeviceEventRecord;
import com.womi.businessmodule.service.device.DeviceEventRecordService;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;

/*
  事件处理器
  topic: device/{mac}/event
  payload:
  {
  "device": "B4BFE90CDBA1",
  "type": "event",
  "timestamp": 1710000000000,
  "data": {
    "type": "error",
    "code": "ERR_SENSOR_001",
    "message": "地址为2的湿度传感器通信超时"
      }
   }
*/

@Slf4j
@Component
@Order(4)
@RequiredArgsConstructor
public class DeviceEventMessageHandler implements MqttMessageHandler {

    private final JsonUtils jsonUtils;
    private final DeviceEventRecordService eventRecordService;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(DeviceMqttConstants.EVENT_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        try {
            String deviceId = extractDeviceId(topic);
            JsonNode json = jsonUtils.parse(payload);
            if (deviceId == null || json == null) return;

            JsonNode dataNode = json.path(DeviceMqttConstants.FIELD_DATA);

            eventRecordService.processDeviceEvent(deviceId, dataNode);

        } catch (Exception e) {
            log.error("处理设备事件消息失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}