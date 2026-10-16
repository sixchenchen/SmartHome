package com.womi.businessmodule.service.device.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.device.DeviceSensorMapper;
import com.womi.businessmodule.model.device.DeviceSensor;
import com.womi.businessmodule.service.device.DeviceSensorService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
public class DeviceSensorServiceImpl
        extends ServiceImpl<DeviceSensorMapper, DeviceSensor>
        implements DeviceSensorService {

    @Override
    public List<DeviceSensor> listByDeviceId(String deviceId) {
        return baseMapper.selectByDeviceId(deviceId);
    }

    @Override
    public List<DeviceSensor> listBySlaveAddress(String deviceId, Integer slaveAddress) {
        return baseMapper.selectBySlaveAddress(deviceId, slaveAddress);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void syncSensors(String deviceId, List<DeviceSensor> sensors) {
        if (sensors == null || sensors.isEmpty()) return;
        for (DeviceSensor sensor : sensors) {
            sensor.setDeviceId(deviceId);
        }
        saveOrUpdateBatch(sensors);
    }
}