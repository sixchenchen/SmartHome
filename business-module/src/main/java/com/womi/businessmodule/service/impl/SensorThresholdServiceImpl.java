package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.SensorThresholdMapper;
import com.womi.businessmodule.model.SensorThreshold;
import com.womi.businessmodule.service.SensorThresholdService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
public class SensorThresholdServiceImpl
        extends ServiceImpl<SensorThresholdMapper, SensorThreshold>
        implements SensorThresholdService {

    @Override
    public List<SensorThreshold> listByDeviceId(String deviceId) {
        return baseMapper.selectByDeviceId(deviceId);
    }

    @Override
    public SensorThreshold getBySensorKey(String deviceId, String sensorKey) {
        return baseMapper.selectBySensorKey(deviceId, sensorKey);
    }

    @Override
    public List<SensorThreshold> listAllEnabled() {
        return baseMapper.selectAllEnabled();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveOrUpdateThreshold(SensorThreshold threshold) {
        if (threshold.getDeviceId() == null || threshold.getSensorKey() == null) {
            throw new IllegalArgumentException("deviceId 和 sensorKey 不能为空");
        }

        SensorThreshold existing = getBySensorKey(threshold.getDeviceId(), threshold.getSensorKey());

        if (existing == null) {
            if (threshold.getEnabled() == null) {
                threshold.setEnabled(1);
            }
            if (threshold.getAlarmLevel() == null) {
                threshold.setAlarmLevel(1);
            }
            save(threshold);
            log.info("新增阈值配置 - deviceId: {}, sensorKey: {}",
                    threshold.getDeviceId(), threshold.getSensorKey());
        } else {
            threshold.setId(existing.getId());
            updateById(threshold);
            log.info("更新阈值配置 - deviceId: {}, sensorKey: {}",
                    threshold.getDeviceId(), threshold.getSensorKey());
        }
    }
}