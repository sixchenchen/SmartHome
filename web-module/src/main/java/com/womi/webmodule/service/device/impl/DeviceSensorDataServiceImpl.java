package com.womi.webmodule.service.device.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.model.device.*;
import com.womi.businessmodule.service.device.*;
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.enums.AlertStatus;
import com.womi.commonmodule.enums.EnableStatus;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.service.common.WebSocketPushService;
import com.womi.webmodule.service.device.DeviceSensorDataService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceSensorDataServiceImpl implements DeviceSensorDataService {

    private final JsonUtils jsonUtils;
    private final DeviceSensorRecordService sensorRecordService;
    private final DeviceSlaveDataService slaveDataService;
    private final DeviceSensorThresholdService thresholdService;
    private final DeviceAlertRecordService alertRecordService;
    private final WebSocketPushService webSocketPushService;
    private final StringRedisTemplate redisTemplate;

    /** 告警防抖前缀 */
    private static final String ALERT_DEDUP_KEY = "iot:alert:dedup:";
    /** 告警防抖窗口（分钟） */
    private static final long ALERT_DEDUP_WINDOW_MINUTES = 5;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void processSensorData(String deviceId, JsonNode dataArray) {
        List<DeviceSensorRecord> records = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        // ==================== 1. 提前提取所有 sensorKey ====================
        List<String> sensorKeys = new ArrayList<>();
        for (JsonNode node : dataArray) {
            String key = jsonUtils.getString(node, DeviceMqttConstants.FIELD_SENSOR_KEY);
            if (key != null) sensorKeys.add(key);
        }

        if (sensorKeys.isEmpty()) return;

        // ==================== 2. N+1 优化：批量查询阈值 ====================
        // 一次性查出这批数据涉及的所有阈值配置
        List<DeviceSensorThreshold> thresholds = thresholdService.list(
                new LambdaQueryWrapper<DeviceSensorThreshold>()
                        .eq(DeviceSensorThreshold::getDeviceId, deviceId)
                        .in(DeviceSensorThreshold::getSensorKey, sensorKeys)
                        .eq(DeviceSensorThreshold::getEnabled, EnableStatus.ENABLED.getCode())
        );
        // 转换为 Map，方便 O(1) 查找
        Map<String, DeviceSensorThreshold> thresholdMap = thresholds.stream()
                .collect(Collectors.toMap(DeviceSensorThreshold::getSensorKey, t -> t));

        // ==================== 3. 遍历处理 ====================
        for (JsonNode node : dataArray) {
            String sensorType = jsonUtils.getString(node, DeviceMqttConstants.FIELD_SENSOR_TYPE);
            if (sensorType == null) continue;

            String sensorKey = jsonUtils.getString(node, DeviceMqttConstants.FIELD_SENSOR_KEY);
            Double value = jsonUtils.getDouble(node, DeviceMqttConstants.FIELD_VALUE);
            String unit = jsonUtils.getString(node, DeviceMqttConstants.FIELD_UNIT);
            String source = jsonUtils.getString(node, DeviceMqttConstants.SOURCE);

            Integer address = jsonUtils.getInt(node, DeviceMqttConstants.FIELD_ADDRESS);
            Integer channel = jsonUtils.getInt(node, DeviceMqttConstants.FIELD_CHANNEL);

            // 3.1 组装历史记录
            DeviceSensorRecord record = new DeviceSensorRecord();
            record.setDeviceId(deviceId);
            record.setSensorKey(sensorKey);
            record.setSensorType(sensorType);
            record.setSensorValue(value);
            record.setUnit(unit);
            record.setSource(source);
            if (address != null) record.setSlaveAddress(address);
            if (channel != null) record.setChannel(channel);
            record.setTimestamp(now);
            record.setCreateTime(now);
            records.add(record);

            // 3.2 更新从机实时值
            if (DeviceMqttConstants.FIELD_SLAVE.equals(source) && address != null) {
                slaveDataService.updateSlaveValue(deviceId, address, channel, sensorType, value, now);
            }

            // 3.3 触发阈值告警（从提前查好的 Map 里取配置）
            checkThresholdAndAlert(deviceId, sensorKey, value, thresholdMap.get(sensorKey));
        }

        // ==================== 4. 批量落库 + WebSocket 推送 ====================
        if (!records.isEmpty()) {
            sensorRecordService.saveBatch(records);
            webSocketPushService.pushSensorData(deviceId, records);
        }
    }

    /**
     * 阈值判定与告警触发（带 Redis 去重）
     */
    private void checkThresholdAndAlert(String deviceId, String sensorKey, Double value, DeviceSensorThreshold threshold) {
        if (value == null || sensorKey == null || threshold == null) {
            return;
        }

        boolean isAlarm = false;
        String msg = "";
        Double triggerThreshold = null;

        if (threshold.getMaxValue() != null && value > threshold.getMaxValue()) {
            isAlarm = true;
            triggerThreshold = threshold.getMaxValue();
            msg = String.format("数值 %.1f 超过上限 %.1f", value, triggerThreshold);
        } else if (threshold.getMinValue() != null && value < threshold.getMinValue()) {
            isAlarm = true;
            triggerThreshold = threshold.getMinValue();
            msg = String.format("数值 %.1f 低于下限 %.1f", value, triggerThreshold);
        }

        if (!isAlarm) {
            return;
        }

        // Redis 告警防抖（同一设备，同一传感器，5 分钟内只报一次）
        String dedupKey = ALERT_DEDUP_KEY + deviceId + ":" + sensorKey;
        Boolean isFirstAlarm = redisTemplate.opsForValue().setIfAbsent(
                dedupKey, "1", Duration.ofMinutes(ALERT_DEDUP_WINDOW_MINUTES));

        if (!Boolean.TRUE.equals(isFirstAlarm)) {
            // 如果在防抖窗口内，仅打 debug 日志，不重复入库/推送
            log.debug("告警被防抖拦截 - deviceId: {}, sensorKey: {}, value: {}", deviceId, sensorKey, value);
            return;
        }

        // 组装并保存告警
        DeviceAlertRecord alert = new DeviceAlertRecord();
        alert.setDeviceId(deviceId);
        alert.setSensorKey(sensorKey);
        alert.setAlertLevel(threshold.getAlarmLevel() != null ? threshold.getAlarmLevel() : 3);
        alert.setAlertType(DeviceConstants.DEVICE_SENSOR_ALERT_TYPE);
        alert.setMessage(msg);
        alert.setValue(value);
        alert.setThreshold(triggerThreshold);
        alert.setStatus(AlertStatus.PENDING.getCode());
        alert.setTimestamp(LocalDateTime.now());

        alertRecordService.save(alert);
        webSocketPushService.pushAlert(deviceId, alert);
        log.warn("触发告警 - deviceId: {}, 原因: {}", deviceId, msg);
    }
}