package com.womi.businessmodule.service.device.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.device.DeviceSensorRecordMapper;
import com.womi.businessmodule.model.device.DeviceSensorRecord;
import com.womi.businessmodule.service.device.DeviceSensorRecordService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
public class DeviceSensorRecordServiceImpl
        extends ServiceImpl<DeviceSensorRecordMapper, DeviceSensorRecord>
        implements DeviceSensorRecordService {

    private static final String SOURCE_HOST  = "host";
    private static final String SOURCE_SLAVE = "slave";

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveBatchRecords(List<DeviceSensorRecord> records) {
        if (records == null || records.isEmpty()) return;
        saveBatch(records);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveHostSensor(String deviceId, Integer sensorId, Integer channel,
                               String sensorKey, String sensorType,
                               Double value, String unit) {
        DeviceSensorRecord record = new DeviceSensorRecord();
        record.setDeviceId(deviceId);
        record.setSource(SOURCE_HOST);
        record.setSlaveAddress(null);
        record.setSensorId(sensorId);
        record.setChannel(channel);
        record.setSensorKey(sensorKey);
        record.setSensorType(sensorType);
        record.setSensorValue(value);
        record.setUnit(unit);
        record.setTimestamp(LocalDateTime.now());
        save(record);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveSlaveSensor(String deviceId, Integer slaveAddress, Integer channel,
                                String sensorKey, String sensorType,
                                Double value, String unit) {
        DeviceSensorRecord record = new DeviceSensorRecord();
        record.setDeviceId(deviceId);
        record.setSource(SOURCE_SLAVE);
        record.setSlaveAddress(slaveAddress);
        record.setSensorId(null);
        record.setChannel(channel);
        record.setSensorKey(sensorKey);
        record.setSensorType(sensorType);
        record.setSensorValue(value);
        record.setUnit(unit);
        record.setTimestamp(LocalDateTime.now());
        save(record);
    }

    @Override
    public List<DeviceSensorRecord> listBySensorKey(String deviceId, String sensorKey,
                                              LocalDateTime start, LocalDateTime end) {
        return baseMapper.selectBySensorKey(deviceId, sensorKey, start, end);
    }

    @Override
    public List<DeviceSensorRecord> listBySlaveChannel(String deviceId, Integer slaveAddress,
                                                 Integer channel, String sensorType,
                                                 LocalDateTime start, LocalDateTime end) {
        return baseMapper.selectBySlaveChannel(deviceId, slaveAddress, channel, sensorType, start, end);
    }

    @Override
    public List<DeviceSensorRecord> listLatest(String deviceId, String sensorKey, int limit) {
        return list(new LambdaQueryWrapper<DeviceSensorRecord>()
                .eq(DeviceSensorRecord::getDeviceId, deviceId)
                .eq(DeviceSensorRecord::getSensorKey, sensorKey)
                .orderByDesc(DeviceSensorRecord::getTimestamp)
                .last("LIMIT " + limit));
    }

    @Override
    public Double avgBySensorKey(String deviceId, String sensorKey,
                                 LocalDateTime start, LocalDateTime end) {
        Double avg = baseMapper.selectAvgBySensorKey(deviceId, sensorKey, start, end);
        return avg == null ? 0.0 : avg;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int cleanHistory(int retentionDays) {
        LocalDateTime before = LocalDateTime.now().minusDays(retentionDays);
        int deleted = baseMapper.delete(new LambdaQueryWrapper<DeviceSensorRecord>()
                .lt(DeviceSensorRecord::getTimestamp, before));
        if (deleted > 0) {
            log.info("清理传感器历史数据 - 共 {} 条", deleted);
        }
        return deleted;
    }
}