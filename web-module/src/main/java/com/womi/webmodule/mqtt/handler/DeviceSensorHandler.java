package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.model.SensorSlaveData;
import com.womi.businessmodule.service.DeviceDataService;
import com.womi.businessmodule.vo.DeviceData;
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

    private static final String TOPIC_PATTERN = "device/+/sensor";
    private final DeviceDataService deviceDataService;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches("device/[^/]+/sensor");
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
            JsonNode dataNode = jsonNode.get("data");

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
            if (dataNode.has("slaves") && dataNode.get("slaves").isArray()) {
                for (JsonNode slaveNode : dataNode.get("slaves")) {
                    SensorSlaveData slave = new SensorSlaveData();
                    if (slaveNode.has("addr")) {
                        slave.setAddress(slaveNode.get("addr").asInt());
                    }
                    if (slaveNode.has("online")) {
                        slave.setOnline(slaveNode.get("online").asInt());
                    }
                    if (slaveNode.has("count")) {
                        slave.setCount(slaveNode.get("count").asInt());
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
