package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.model.MosStateRecord;
import com.womi.businessmodule.service.DeviceDataService;
import com.womi.businessmodule.vo.DeviceData;
import com.womi.commonmodule.utils.JsonUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.HashMap;

@Slf4j
@Component
@RequiredArgsConstructor
public class DeviceMosStateHandler implements MqttMessageHandler {

    private static final String TOPIC_PATTERN = "device/+/mos_state";
    private final DeviceDataService deviceDataService;
    private final JsonUtils jsonUtils;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches("device/[^/]+/mos_state");
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

                // 更新MOS状态
                for (int i = 0; i <= 7; i++) {
                    String key = "mos" + i;
                    if (dataNode.has(key)) {
                        int value = dataNode.get(key).asInt();
                        deviceData.getMosStates().put(key, value);
                    }
                }

                // 保存历史记录
                MosStateRecord record = new MosStateRecord();
                record.setDeviceId(deviceId);
                record.setMosStates(deviceData.getMosStates());
                record.setTimestamp(LocalDateTime.now());
                deviceData.getMosStateHistory().add(record);

                // 限制历史记录数量
                if (deviceData.getMosStateHistory().size() > 100) {
                    deviceData.getMosStateHistory().remove(0);
                }

                // 保存数据
                deviceDataService.saveOrUpdateDevice(deviceData);

                log.info("MOS状态更新完成 - 设备: {}, 状态: {}",
                        deviceId, deviceData.getMosStates());
            } else {
                log.warn("MOS状态数据格式错误 - 缺少 data 字段");
            }
        } catch (Exception e) {
            log.error("处理MOS状态消息失败: {}", e.getMessage(), e);
        }
    }
}