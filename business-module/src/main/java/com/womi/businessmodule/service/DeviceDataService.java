package com.womi.businessmodule.service;



import com.womi.businessmodule.vo.DeviceData;

import java.time.LocalDateTime;
import java.util.List;

public interface DeviceDataService {

    /**
     * 获取或创建设备数据
     */
    DeviceData getOrCreateDevice(String deviceId);

    /**
     * 保存或更新设备数据
     */
    void saveOrUpdateDevice(DeviceData deviceData);

    /**
     * 根据设备ID获取设备数据
     */
    DeviceData getDeviceData(String deviceId);

    /**
     * 获取所有设备数据
     */
    List<DeviceData> getAllDevices();

    /**
     * 获取所有在线设备
     */
    List<DeviceData> getOnlineDevices();

    /**
     * 保存心跳记录
     */
    void saveHeartbeatRecord(String deviceId, Long uptime, String payload);

    /**
     * 保存MOS状态记录
     */
    void saveMosStateRecord(String deviceId, java.util.Map<String, Integer> mosStates);

    /**
     * 保存传感器数据
     */
    void saveSensorData(String deviceId, String sensorData, List<?> slaveDataList);

    /**
     * 获取设备心跳历史
     */
    List<?> getHeartbeatHistory(String deviceId, int limit);

    /**
     * 获取设备MOS状态历史
     */
    List<?> getMosStateHistory(String deviceId, int limit);

    /**
     * 获取设备传感器历史
     */
    List<?> getSensorHistory(String deviceId, int limit);

    /**
     * 更新设备在线状态
     */
    void updateDeviceStatus(String deviceId, int status);

    /**
     * 清理过期设备数据（定时任务）
     */
    void cleanExpiredData();
}