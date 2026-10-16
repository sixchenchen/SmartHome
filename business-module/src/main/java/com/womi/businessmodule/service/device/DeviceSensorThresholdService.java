package com.womi.businessmodule.service.device;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.device.DeviceSensorThreshold;

import java.util.List;

public interface DeviceSensorThresholdService extends IService<DeviceSensorThreshold> {

    /**
     * 查询设备的所有阈值配置
     */
    List<DeviceSensorThreshold> listByDeviceId(String deviceId);

    /**
     * 查询指定传感器的阈值配置
     */
    DeviceSensorThreshold getBySensorKey(String deviceId, String sensorKey);

    /**
     * 查询所有启用的阈值配置
     */
    List<DeviceSensorThreshold> listAllEnabled();

    /**
     * 保存或更新阈值配置
     */
    void saveOrUpdateThreshold(DeviceSensorThreshold threshold);
}