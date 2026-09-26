package com.womi.businessmodule.service.impl;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.SensorRecordMapper;
import com.womi.businessmodule.model.SensorRecord;
import com.womi.businessmodule.service.SensorRecordService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class SensorRecordServiceImpl extends ServiceImpl<SensorRecordMapper, SensorRecord>
        implements SensorRecordService {

    private final SensorRecordMapper sensorRecordMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveSensorRecord(String deviceId, String sensorData) {
        if (!StringUtils.hasText(deviceId) || !StringUtils.hasText(sensorData)) {
            log.warn("传感器数据参数不完整 - deviceId: {}, sensorData: {}", deviceId, sensorData);
            return false;
        }

        SensorRecord record = new SensorRecord();
        record.setDeviceId(deviceId);
        record.setSensorData(sensorData);
        record.setTimestamp(LocalDateTime.now());

        return save(record);
    }

    @Override
    public List<SensorRecord> getRecentByDeviceId(String deviceId, int limit) {
        if (!StringUtils.hasText(deviceId)) {
            return List.of();
        }
        return sensorRecordMapper.selectRecentByDeviceId(deviceId, limit);
    }

    @Override
    public SensorRecord getLatestByDeviceId(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return null;
        }
        return sensorRecordMapper.selectLatestByDeviceId(deviceId);
    }

    @Override
    public List<SensorRecord> getByTimeRange(String deviceId, LocalDateTime startTime, LocalDateTime endTime) {
        if (!StringUtils.hasText(deviceId) || startTime == null || endTime == null) {
            return List.of();
        }
        return sensorRecordMapper.selectByTimeRange(deviceId, startTime, endTime);
    }

    @Override
    public String getLatestSensorField(String deviceId, String fieldPath) {
        if (!StringUtils.hasText(deviceId) || !StringUtils.hasText(fieldPath)) {
            return null;
        }
        return sensorRecordMapper.selectLatestSensorField(deviceId, fieldPath);
    }

    @Override
    public String getLatestSlaves(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return null;
        }
        return sensorRecordMapper.selectLatestSlaves(deviceId);
    }

    @Override
    public Map<String, Object> getLatestSlaveByAddress(String deviceId, int index) {
        if (!StringUtils.hasText(deviceId) || index < 0) {
            return null;
        }
        return sensorRecordMapper.selectLatestSlaveByAddress(deviceId, index);
    }

    @Override
    public Long countByDeviceId(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return 0L;
        }
        return sensorRecordMapper.countByDeviceId(deviceId);
    }

    @Override
    public List<SensorRecord> getRecentHours(String deviceId, int hours) {
        if (!StringUtils.hasText(deviceId) || hours <= 0) {
            return List.of();
        }
        return sensorRecordMapper.selectRecentHours(deviceId, hours);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean batchSave(List<SensorRecord> records) {
        if (records == null || records.isEmpty()) {
            return false;
        }
        return saveBatch(records);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int cleanExpiredRecords(int days) {
        if (days <= 0) {
            return 0;
        }
        LocalDateTime expireTime = LocalDateTime.now().minusDays(days);
        LambdaQueryWrapper<SensorRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.lt(SensorRecord::getTimestamp, expireTime);
        int deleted = baseMapper.delete(wrapper);
        log.info("清理过期传感器数据完成 - 删除 {} 条记录", deleted);
        return deleted;
    }
}