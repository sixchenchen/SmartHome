package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.SensorThreshold;

import java.util.List;

public interface SensorThresholdService extends IService<SensorThreshold> {

    /**
     * 查询设备的所有阈值配置
     */
    List<SensorThreshold> listByDeviceId(String deviceId);

    /**
     * 查询指定传感器的阈值配置
     */
    SensorThreshold getBySensorKey(String deviceId, String sensorKey);

    /**
     * 查询所有启用的阈值配置
     */
    List<SensorThreshold> listAllEnabled();

    /**
     * 保存或更新阈值配置
     */
    void saveOrUpdateThreshold(SensorThreshold threshold);
}