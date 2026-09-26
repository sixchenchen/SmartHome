package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.model.SensorSlaveData;
import com.womi.businessmodule.service.DeviceDataService;
import com.womi.businessmodule.vo.DeviceData;
import com.womi.commonmodule.mqtt.MqttConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DeviceSensorHandler implements MqttMessageHandler {

    private static final String TOPIC_PATTERN = MqttConstants.SENSOR_TOPIC_PATTERN;
    private final DeviceDataService deviceDataService;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(MqttConstants.SENSOR_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        try {
            String deviceId = extractDeviceId(topic);
            if (deviceId == null) {
                log.warn("无法提取设备ID - Topic: {}", topic);
                return;
            }

            JsonNode jsonNode = parsePayload(payload);
            JsonNode dataNode = jsonNode.get(MqttConstants.FIELD_DATA);

            if (dataNode != null) {
                DeviceData deviceData = deviceDataService.getOrCreateDevice(deviceId);
                deviceData.setLastUpdateTime(LocalDateTime.now());
                deviceData.setLastPayload(payload);
                deviceData.setSensorData(dataNode.toString());

                // 解析从机数据
                List<SensorSlaveData> slaveList = parseSlaveData(dataNode);
                deviceData.setSlaveDataList(slaveList);

                // 保存数据
                deviceDataService.saveOrUpdateDevice(deviceData);

                log.info("传感器数据更新完成 - 设备: {}, 从机数量: {}",
                        deviceId, slaveList.size());
            } else {
                log.warn("传感器数据格式错误 - 缺少 data 字段");
            }
        } catch (Exception e) {
            log.error("处理传感器消息失败: {}", e.getMessage(), e);
        }
    }

    private List<SensorSlaveData> parseSlaveData(JsonNode dataNode) {
        List<SensorSlaveData> result = new ArrayList<>();

        try {
            if (dataNode.has(MqttConstants.FIELD_SLAVES) && dataNode.get(MqttConstants.FIELD_SLAVES).isArray()) {
                for (JsonNode slaveNode : dataNode.get(MqttConstants.FIELD_SLAVES)) {
                    SensorSlaveData slave = new SensorSlaveData();
                    if (slaveNode.has(MqttConstants.FIELD_ADDR)) {
                        slave.setAddress(slaveNode.get(MqttConstants.FIELD_ADDR).asInt());
                    }
                    if (slaveNode.has(MqttConstants.FIELD_ONLINE)) {
                        slave.setOnline(slaveNode.get(MqttConstants.FIELD_ONLINE).asInt());
                    }
                    if (slaveNode.has(MqttConstants.FIELD_COUNT)) {
                        slave.setCount(slaveNode.get(MqttConstants.FIELD_COUNT).asInt());
                    }
                    result.add(slave);
                }
            }
        } catch (Exception e) {
            log.error("解析从机数据失败: {}", e.getMessage());
        }

        return result;
    }
}
