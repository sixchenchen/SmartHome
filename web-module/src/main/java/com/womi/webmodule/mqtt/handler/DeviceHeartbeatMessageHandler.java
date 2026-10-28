package com.womi.webmodule.mqtt.handler;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.mapper.device.DeviceBindingMapper;
import com.womi.businessmodule.model.device.DeviceBinding;
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
            // 1. 提取 deviceId
            String deviceId = extractDeviceId(topic);
            if (deviceId == null) {
                log.warn("无法提取设备ID - Topic: {}", topic);
                return;
            }

            // 2. 解析 payload
            JsonNode json = jsonUtils.parse(payload);
            if (json == null) {
                log.warn("payload 解析失败 - Topic: {}", topic);
                return;
            }
            JsonNode dataNode = json.path(DeviceMqttConstants.FIELD_DATA);
            Long uptime = jsonUtils.getLong(dataNode, DeviceMqttConstants.FIELD_UPTIME);
            // 3. 更新设备心跳（同时把设备标记为在线）
            deviceInfoService.updateHeartbeat(deviceId, uptime, payload);
            // 4. 写心跳历史
            Boolean isBound = redisTemplate.opsForSet().isMember(RedisConstants.BOUND_DEVICES_KEY, deviceId);

            if (Boolean.TRUE.equals(isBound)) {
                // 5. 只有被绑定的设备，才记录心跳明细
                heartbeatRecordService.recordHeartbeat(deviceId, uptime, payload);
                log.debug("心跳处理完成（已绑定） - deviceId: {}", deviceId);
            } else {
                log.debug("未绑定设备心跳，仅更新主表状态 - deviceId: {}", deviceId);
            }
        } catch (Exception e) {
            log.error("处理心跳消息失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}