package com.womi.webmodule.mqtt.handler;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.womi.businessmodule.model.HeartbeatRecord;
import com.womi.businessmodule.service.DeviceDataService;
import com.womi.businessmodule.vo.DeviceData;
import com.womi.commonmodule.device.DeviceConstants;
import com.womi.commonmodule.mqtt.MqttConstants;
import com.womi.webmodule.mqtt.MqttMessageHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Slf4j
@Component
@RequiredArgsConstructor
public class DeviceHeartbeatHandler implements MqttMessageHandler {

    private final DeviceDataService deviceDataService;
    private final ObjectMapper objectMapper;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(MqttConstants.HEART_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        try {
            String deviceId = extractDeviceId(topic);
            if (deviceId == null) {
                log.warn("无法提取设备ID - Topic: {}", topic);
                return;
            }

            JsonNode jsonNode = objectMapper.readTree(payload);
            JsonNode dataNode = jsonNode.get(MqttConstants.FIELD_DATA);

            if (dataNode != null && dataNode.has(MqttConstants.FIELD_UPTIME)) {
                long uptime = dataNode.get(MqttConstants.FIELD_UPTIME).asLong();

                // 获取或创建设备数据
                DeviceData deviceData = deviceDataService.getOrCreateDevice(deviceId);
                deviceData.setUptime(uptime);
                deviceData.setLastHeartbeatTime(LocalDateTime.now());
                deviceData.setLastUpdateTime(LocalDateTime.now());
                deviceData.setLastPayload(payload);

                // 保存心跳记录
                HeartbeatRecord record = new HeartbeatRecord();
                record.setDeviceId(deviceId);
                record.setUptime(uptime);
                record.setTimestamp(LocalDateTime.now());
                deviceData.getHeartbeatHistory().add(record);

                // 限制历史记录数量
                if (deviceData.getHeartbeatHistory().size() > DeviceConstants.HEARTBEAT_HISTORY_LIMIT) {
                    deviceData.getHeartbeatHistory().remove(0);
                }

                // 保存数据
                deviceDataService.saveOrUpdateDevice(deviceData);

                log.info("心跳处理完成 - 设备: {}, 运行时间: {}秒", deviceId, uptime);
            } else {
                log.warn("心跳数据格式错误 - 缺少 uptime 字段");
            }
        } catch (Exception e) {
            log.error("处理心跳消息失败: {}", e.getMessage(), e);
        }
    }
}