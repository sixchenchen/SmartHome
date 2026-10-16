package com.womi.businessmodule.service.device.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.device.DeviceSensorThresholdMapper;
import com.womi.businessmodule.model.device.DeviceSensorThreshold;
import com.womi.businessmodule.service.device.DeviceSensorThresholdService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
public class DeviceSensorThresholdServiceImpl
        extends ServiceImpl<DeviceSensorThresholdMapper, DeviceSensorThreshold>
        implements DeviceSensorThresholdService {

    @Override
    public List<DeviceSensorThreshold> listByDeviceId(String deviceId) {
        return baseMapper.selectByDeviceId(deviceId);
    }

    @Override
    public DeviceSensorThreshold getBySensorKey(String deviceId, String sensorKey) {
        return baseMapper.selectBySensorKey(deviceId, sensorKey);
    }

    @Override
    public List<DeviceSensorThreshold> listAllEnabled() {
        return baseMapper.selectAllEnabled();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveOrUpdateThreshold(DeviceSensorThreshold threshold) {
        if (threshold.getDeviceId() == null || threshold.getSensorKey() == null) {
            throw new IllegalArgumentException("deviceId 和 sensorKey 不能为空");
        }

        DeviceSensorThreshold existing = getBySensorKey(threshold.getDeviceId(), threshold.getSensorKey());

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