package com.womi.webmodule.service.device.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.model.device.*;
import com.womi.businessmodule.service.device.*;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.service.common.WebSocketPushService;
import com.womi.webmodule.service.device.DeviceSensorDataService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

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

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void processSensorData(String deviceId, JsonNode dataArray) {
        List<DeviceSensorRecord> records = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        for (JsonNode node : dataArray) {
            String sensorType = jsonUtils.getString(node, "sensor_type");
            if (sensorType == null) continue;

            String sensorKey = jsonUtils.getString(node, "sensor_key");
            Double value = jsonUtils.getDouble(node, "value");
            String unit = jsonUtils.getString(node, "unit");
            String source = jsonUtils.getString(node, "source");

            // 1. 提取从机地址和通道号
            Integer address = jsonUtils.getInt(node, "address");
            Integer channel = jsonUtils.getInt(node, "channel");

            // 2. 组装历史记录
            DeviceSensorRecord record = new DeviceSensorRecord();
            record.setDeviceId(deviceId);
            record.setSensorKey(sensorKey);
            record.setSensorType(sensorType);
            record.setSensorValue(value);
            record.setUnit(unit);
            record.setSource(source);

            // 3. 将地址和通道号赋给实体（前提是你的实体类里叫 slaveAddress 和 channel）
            if (address != null) record.setSlaveAddress(address);
            if (channel != null) record.setChannel(channel);

            record.setTimestamp(now);
            record.setCreateTime(now);
            records.add(record);

            // 4. 更新从机实时值（如果是从机数据）
            if ("slave".equals(source) && address != null) {
                // 5. 把 channel 也传给更新方法
                slaveDataService.updateSlaveValue(deviceId, address, channel, sensorType, value, now);
            }

            // 5. 触发阈值告警
            checkThresholdAndAlert(deviceId, sensorKey, value);
        }

        // 6. 批量保存历史
        if (!records.isEmpty()) {
            sensorRecordService.saveBatch(records);
            webSocketPushService.pushSensorData(deviceId, records);
        }
    }

    private void checkThresholdAndAlert(String deviceId, String sensorKey, Double value) {
        if (value == null || sensorKey == null) return;

        DeviceSensorThreshold threshold = thresholdService.getOne(
                new LambdaQueryWrapper<DeviceSensorThreshold>()
                        .eq(DeviceSensorThreshold::getDeviceId, deviceId)
                        .eq(DeviceSensorThreshold::getSensorKey, sensorKey)
                        .eq(DeviceSensorThreshold::getEnabled, 1)
        );

        if (threshold == null) return;

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

        if (isAlarm) {
            DeviceAlertRecord alert = new DeviceAlertRecord();
            alert.setDeviceId(deviceId);
            alert.setSensorKey(sensorKey);
            alert.setAlertLevel(threshold.getAlarmLevel() != null ? threshold.getAlarmLevel() : 3);
            alert.setAlertType("threshold");
            alert.setMessage(msg);
            alert.setValue(value);
            alert.setThreshold(triggerThreshold);
            alert.setStatus(0);
            alert.setTimestamp(LocalDateTime.now());
            alert.setCreateTime(LocalDateTime.now());

            alertRecordService.save(alert);
            webSocketPushService.pushAlert(deviceId, alert);
            log.warn("触发告警 - deviceId: {}, 原因: {}", deviceId, msg);
        }
    }
}