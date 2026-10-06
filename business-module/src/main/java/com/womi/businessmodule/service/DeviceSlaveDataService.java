package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.DeviceSlaveData;

import java.util.List;
import java.util.Map;

public interface DeviceSlaveDataService extends IService<DeviceSlaveData> {

    List<DeviceSlaveData> listByDeviceId(String deviceId);

    void syncSlaveData(String deviceId, List<Map<String, Object>> slaves);

    int clearByDeviceId(String deviceId);
}