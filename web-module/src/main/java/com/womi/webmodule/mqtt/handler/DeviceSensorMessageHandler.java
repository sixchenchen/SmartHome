package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import com.womi.webmodule.service.device.DeviceSensorDataService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;


/**
 * 传感器数据上报处理器 (Sensor)
 * <p>Topic: device/{mac}/sensor</p>
 * <p>Payload:
 * <pre>
 * {
 *   "device": "B4BFE90CDBA1",
 *   "type": "sensor_batch",
 *   "timestamp": 1710000000000,
 *   "data": [
 *     {
 *       "source": "slave",
 *       "address": 1,
 *       "sensor_key": "temp",
 *       "sensor_type": "temperature",
 *       "value": 25.5,
 *       "unit": "℃"
 *     }
 *   ]
 * }
 * </pre>
 * </p>
 */

@Slf4j
@Component
@Order(4)
@RequiredArgsConstructor
public class DeviceSensorMessageHandler implements MqttMessageHandler {

    private final JsonUtils jsonUtils;
    private final DeviceSensorDataService deviceSensorDataService;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(DeviceMqttConstants.SENSOR_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        try {
            String deviceId = extractDeviceId(topic);
            if (deviceId == null) return;

            JsonNode json = jsonUtils.parse(payload);
            if (json == null) return;

            // 提取 data 数组节点
            JsonNode dataArray = json.path(DeviceMqttConstants.FIELD_DATA);
            if (!dataArray.isArray()) {
                log.warn("传感器数据格式错误，data 节点不是数组 - deviceId: {}", deviceId);
                return;
            }
            deviceSensorDataService.processSensorData(deviceId, dataArray);

        } catch (Exception e) {
            log.error("处理传感器数据失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }
}