package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.DeviceSensor;

import java.util.List;

public interface DeviceSensorService extends IService<DeviceSensor> {

    /**
     * 查询设备的所有传感器
     */
    List<DeviceSensor> listByDeviceId(String deviceId);

    /**
     * 查询从机的传感器
     */
    List<DeviceSensor> listBySlaveAddress(String deviceId, Integer slaveAddress);

    /**
     * 同步设备传感器（设备上报后调用）
     */
    void syncSensors(String deviceId, List<DeviceSensor> sensors);
}