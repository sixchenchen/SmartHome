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

import java.time.LocalDateTime;

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

            // 提取 data 节点中的事件信息
            String eventType = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_TYPE); // error 或 event
            String eventName = jsonUtils.getString(dataNode, "event");
            String code = jsonUtils.getString(dataNode, "code");
            String message = jsonUtils.getString(dataNode, "message");
            String context = jsonUtils.getString(dataNode, "context");
            String target = jsonUtils.getString(dataNode, "target");
            Integer channel = jsonUtils.getInt(dataNode, "channel");
            String triggerSource = jsonUtils.getString(dataNode, "trigger_source");

            // 组装实体
            DeviceEventRecord record = new DeviceEventRecord();
            record.setDeviceId(deviceId);
            // 如果 data.type 没传，默认按 event 存
            record.setType(eventType != null ? eventType : "event");
            record.setEvent(eventName);
            record.setCode(code);
            record.setMessage(message);
            record.setContext(context);
            record.setTarget(target);
            record.setChannel(channel);
            record.setTriggerSource(triggerSource);

            // 将完整的原始 data 报文作为一个 JSON 存入库中，方便日后排查问题
            record.setPayload(jsonUtils.nodeToMap(dataNode));

            record.setTimestamp(LocalDateTime.now());
            record.setCreateTime(LocalDateTime.now());

            // 落库
            eventRecordService.save(record);

            // 根据级别打印不同的日志
            if ("error".equalsIgnoreCase(eventType)) {
                log.error("🚨 设备上报错误 - deviceId: {}, code: {}, message: {}", deviceId, code, message);
            } else {
                log.info("设备上报事件 - deviceId: {}, event: {}", deviceId, eventName);
            }

        } catch (Exception e) {
            log.error("处理设备事件消息失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}