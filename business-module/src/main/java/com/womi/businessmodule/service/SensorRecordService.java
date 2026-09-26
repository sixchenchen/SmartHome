package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.SensorRecord;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public interface SensorRecordService extends IService<SensorRecord> {

    /**
     * 保存传感器数据
     */
    boolean saveSensorRecord(String deviceId, String sensorData);

    /**
     * 查询设备最近的传感器数据
     */
    List<SensorRecord> getRecentByDeviceId(String deviceId, int limit);

    /**
     * 查询设备最新的传感器数据
     */
    SensorRecord getLatestByDeviceId(String deviceId);

    /**
     * 查询设备指定时间段的传感器数据
     */
    List<SensorRecord> getByTimeRange(String deviceId, LocalDateTime startTime, LocalDateTime endTime);

    /**
     * 查询设备最新的传感器数据（解析特定字段）
     */
    String getLatestSensorField(String deviceId, String fieldPath);

    /**
     * 查询设备传感器数据中的从机列表
     */
    String getLatestSlaves(String deviceId);

    /**
     * 查询设备传感器数据中的特定从机地址
     */
    Map<String, Object> getLatestSlaveByAddress(String deviceId, int index);

    /**
     * 统计设备传感器数据记录数
     */
    Long countByDeviceId(String deviceId);

    /**
     * 查询设备最近N小时的传感器数据
     */
    List<SensorRecord> getRecentHours(String deviceId, int hours);

    /**
     * 批量保存传感器数据
     */
    boolean batchSave(List<SensorRecord> records);

    /**
     * 清理过期传感器数据
     */
    int cleanExpiredRecords(int days);
}