package com.womi.businessmodule.service.impl;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.SensorSlaveDataMapper;
import com.womi.businessmodule.model.SensorSlaveData;
import com.womi.businessmodule.service.SensorSlaveDataService;
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
public class SensorSlaveDataServiceImpl extends ServiceImpl<SensorSlaveDataMapper, SensorSlaveData>
        implements SensorSlaveDataService {

    private final SensorSlaveDataMapper sensorSlaveDataMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveSlaveData(String deviceId, Integer address, Integer online, Integer count) {
        if (!StringUtils.hasText(deviceId) || address == null) {
            log.warn("从机数据参数不完整 - deviceId: {}, address: {}", deviceId, address);
            return false;
        }

        SensorSlaveData slaveData = new SensorSlaveData();
        slaveData.setDeviceId(deviceId);
        slaveData.setAddress(address);
        slaveData.setOnline(online != null ? online : 0);
        slaveData.setCount(count != null ? count : 0);
        slaveData.setTimestamp(LocalDateTime.now());

        return save(slaveData);
    }

    @Override
    public List<SensorSlaveData> getRecentByDeviceId(String deviceId, int limit) {
        if (!StringUtils.hasText(deviceId)) {
            return List.of();
        }
        return sensorSlaveDataMapper.selectRecentByDeviceId(deviceId, limit);
    }

    @Override
    public SensorSlaveData getLatestByDeviceId(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return null;
        }
        return sensorSlaveDataMapper.selectLatestByDeviceId(deviceId);
    }

    @Override
    public List<SensorSlaveData> getByAddress(String deviceId, int address, int limit) {
        if (!StringUtils.hasText(deviceId)) {
            return List.of();
        }
        return sensorSlaveDataMapper.selectByAddress(deviceId, address, limit);
    }

    @Override
    public List<SensorSlaveData> getOnlineSlaves(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return List.of();
        }
        return sensorSlaveDataMapper.selectOnlineSlaves(deviceId);
    }

    @Override
    public List<SensorSlaveData> getOfflineSlaves(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return List.of();
        }
        return sensorSlaveDataMapper.selectOfflineSlaves(deviceId);
    }

    @Override
    public Map<String, Object> getSlaveStatistics(String deviceId, int hours) {
        if (!StringUtils.hasText(deviceId) || hours <= 0) {
            return null;
        }
        return sensorSlaveDataMapper.selectSlaveStatistics(deviceId, hours);
    }

    @Override
    public List<SensorSlaveData> getRecentHours(String deviceId, int hours) {
        if (!StringUtils.hasText(deviceId) || hours <= 0) {
            return List.of();
        }
        return sensorSlaveDataMapper.selectRecentHours(deviceId, hours);
    }

    @Override
    public List<SensorSlaveData> getByTimeRange(String deviceId, LocalDateTime startTime, LocalDateTime endTime) {
        if (!StringUtils.hasText(deviceId) || startTime == null || endTime == null) {
            return List.of();
        }
        return sensorSlaveDataMapper.selectByTimeRange(deviceId, startTime, endTime);
    }

    @Override
    public List<SensorSlaveData> getLatestForAllDevices() {
        return sensorSlaveDataMapper.selectLatestForAllDevices();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int batchSave(List<SensorSlaveData> slaveDataList) {
        if (slaveDataList == null || slaveDataList.isEmpty()) {
            return 0;
        }
        return sensorSlaveDataMapper.batchInsert(slaveDataList);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int cleanExpiredRecords(int days) {
        if (days <= 0) {
            return 0;
        }
        LocalDateTime expireTime = LocalDateTime.now().minusDays(days);
        LambdaQueryWrapper<SensorSlaveData> wrapper = new LambdaQueryWrapper<>();
        wrapper.lt(SensorSlaveData::getTimestamp, expireTime);
        int deleted = baseMapper.delete(wrapper);
        log.info("清理过期从机数据完成 - 删除 {} 条记录", deleted);
        return deleted;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteByDeviceId(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return 0;
        }
        LambdaQueryWrapper<SensorSlaveData> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SensorSlaveData::getDeviceId, deviceId);
        return baseMapper.delete(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateOnlineStatus(String deviceId, Integer address, Integer online) {
        if (!StringUtils.hasText(deviceId) || address == null || online == null) {
            return 0;
        }

        // 先查询是否存在该从机数据
        LambdaQueryWrapper<SensorSlaveData> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(SensorSlaveData::getDeviceId, deviceId)
                .eq(SensorSlaveData::getAddress, address);
        SensorSlaveData existing = getOne(queryWrapper);

        if (existing != null) {
            existing.setOnline(online);
            existing.setTimestamp(LocalDateTime.now());
            return updateById(existing) ? 1 : 0;
        }

        // 不存在则创建
        return saveSlaveData(deviceId, address, online, 0) ? 1 : 0;
    }
}