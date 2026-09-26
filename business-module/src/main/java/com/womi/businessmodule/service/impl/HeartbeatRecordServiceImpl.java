package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.HeartbeatRecordMapper;
import com.womi.businessmodule.model.HeartbeatRecord;
import com.womi.businessmodule.service.HeartbeatRecordService;
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
public class HeartbeatRecordServiceImpl extends ServiceImpl<HeartbeatRecordMapper, HeartbeatRecord> implements HeartbeatRecordService {

    private final HeartbeatRecordMapper heartbeatRecordMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveHeartbeatRecord(String deviceId, Long uptime, String payload) {
        if (!StringUtils.hasText(deviceId) || uptime == null) {
            log.warn("心跳记录参数不完整 - deviceId: {}, uptime: {}", deviceId, uptime);
            return false;
        }

        HeartbeatRecord record = new HeartbeatRecord();
        record.setDeviceId(deviceId);
        record.setUptime(uptime);
        record.setPayload(payload);
        record.setTimestamp(LocalDateTime.now());

        return save(record);
    }

    @Override
    public List<HeartbeatRecord> getRecentByDeviceId(String deviceId, int limit) {
        if (!StringUtils.hasText(deviceId)) {
            return List.of();
        }
        return heartbeatRecordMapper.selectRecentByDeviceId(deviceId, limit);
    }

    @Override
    public List<HeartbeatRecord> getByTimeRange(String deviceId, LocalDateTime startTime, LocalDateTime endTime) {
        if (!StringUtils.hasText(deviceId) || startTime == null || endTime == null) {
            return List.of();
        }
        return heartbeatRecordMapper.selectByTimeRange(deviceId, startTime, endTime);
    }

    @Override
    public HeartbeatRecord getLatestByDeviceId(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return null;
        }
        return heartbeatRecordMapper.selectLatestByDeviceId(deviceId);
    }

    @Override
    public Long countByDeviceId(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return 0L;
        }
        return heartbeatRecordMapper.countByDeviceId(deviceId);
    }

    @Override
    public Long countByTimeRange(String deviceId, LocalDateTime startTime, LocalDateTime endTime) {
        if (!StringUtils.hasText(deviceId) || startTime == null || endTime == null) {
            return 0L;
        }
        return heartbeatRecordMapper.countByTimeRange(deviceId, startTime, endTime);
    }

    @Override
    public List<HeartbeatRecord> getLatestHeartbeatForAllDevices() {
        return heartbeatRecordMapper.selectLatestHeartbeatForAllDevices();
    }

    @Override
    public List<HeartbeatRecord> getRecentHours(String deviceId, int hours) {
        if (!StringUtils.hasText(deviceId) || hours <= 0) {
            return List.of();
        }
        return heartbeatRecordMapper.selectRecentHours(deviceId, hours);
    }

    @Override
    public List<HeartbeatRecord> getTodayByDeviceId(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return List.of();
        }
        return heartbeatRecordMapper.selectTodayByDeviceId(deviceId);
    }

    @Override
    public Double calculateOnlineRate(String deviceId, int days) {
        if (!StringUtils.hasText(deviceId) || days <= 0) {
            return 0.0;
        }
        Double rate = heartbeatRecordMapper.calculateOnlineRate(deviceId, days);
        return rate != null ? rate : 0.0;
    }

    @Override
    public List<Map<String, Object>> countByHour(String deviceId, int hours) {
        if (!StringUtils.hasText(deviceId) || hours <= 0) {
            return List.of();
        }
        return heartbeatRecordMapper.countByHour(deviceId, hours);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean batchSave(List<HeartbeatRecord> records) {
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
        LambdaQueryWrapper<HeartbeatRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.lt(HeartbeatRecord::getTimestamp, expireTime);
        int deleted = baseMapper.delete(wrapper);
        log.info("清理过期心跳记录完成 - 删除 {} 条记录", deleted);
        return deleted;
    }
}
