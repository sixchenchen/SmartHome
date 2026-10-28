package com.womi.businessmodule.service.device;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.model.device.DeviceSlaveData;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public interface DeviceSlaveDataService extends IService<DeviceSlaveData> {

    List<DeviceSlaveData> listByDeviceId(String deviceId);

    void syncSlaveData(String deviceId, List<Map<String, Object>> slaves);

    int clearByDeviceId(String deviceId);

    void updateSlaveValue(String deviceId, Integer address, Integer channel, String slaveType, Double value, LocalDateTime timestamp);
}