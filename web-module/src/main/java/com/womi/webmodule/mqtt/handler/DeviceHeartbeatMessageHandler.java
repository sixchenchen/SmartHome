package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.service.device.DeviceHeartbeatRecordService;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.constants.RedisConstants;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

/*
 心跳处理器
 topic: device/{mac}/heartbeat
 payload:
  {
    "device": "B4BFE90CDBA1",
    "type": "heartbeat",
    "timestamp": 1710000000000,
    "data": {
      "product": "SmartHome-v1",
      "uptime": 1234,
      "rssi": -65
    }
  }
*/
@Slf4j
@Component
@Order(3)
@RequiredArgsConstructor
public class DeviceHeartbeatMessageHandler implements MqttMessageHandler {

    private final JsonUtils jsonUtils;
    private final DeviceInfoService deviceInfoService;
    private final DeviceHeartbeatRecordService heartbeatRecordService;
    private final StringRedisTemplate redisTemplate;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(DeviceMqttConstants.HEARTBEAT_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        try {
            String deviceId = extractDeviceId(topic);
            JsonNode json = jsonUtils.parse(payload);
            JsonNode dataNode = json.path(DeviceMqttConstants.FIELD_DATA);
            Long uptime = jsonUtils.getLong(dataNode, DeviceMqttConstants.FIELD_UPTIME);

            // 1. 更新主表 (必须做)
            deviceInfoService.updateHeartbeat(deviceId, uptime, payload);

            // 2. 校验绑定关系，决定是否写明细
            Boolean isBound = redisTemplate.opsForSet().isMember(RedisConstants.BOUND_DEVICES_KEY, deviceId);
            if (Boolean.TRUE.equals(isBound)) {
                heartbeatRecordService.recordHeartbeat(deviceId, uptime, payload);
            }
        } catch (Exception e) {
            log.error("处理心跳消息失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}