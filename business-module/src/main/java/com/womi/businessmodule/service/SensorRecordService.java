package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.SensorRecord;

import java.time.LocalDateTime;
import java.util.List;

public interface SensorRecordService extends IService<SensorRecord> {

    /**
     * 批量保存传感器数据
     */
    void saveBatchRecords(List<SensorRecord> records);

    /**
     * 保存主机直连传感器数据
     */
    void saveHostSensor(String deviceId, Integer sensorId, Integer channel,
                        String sensorKey, String sensorType,
                        Double value, String unit);

    /**
     * 保存从机传感器数据
     */
    void saveSlaveSensor(String deviceId, Integer slaveAddress, Integer channel,
                         String sensorKey, String sensorType,
                         Double value, String unit);

    /**
     * 按 sensor_key 查询时间范围
     */
    List<SensorRecord> listBySensorKey(String deviceId, String sensorKey,
                                       LocalDateTime start, LocalDateTime end);

    /**
     * 按从机地址 + 通道查询
     */
    List<SensorRecord> listBySlaveChannel(String deviceId, Integer slaveAddress,
                                          Integer channel, String sensorType,
                                          LocalDateTime start, LocalDateTime end);

    /**
     * 查询设备某传感器最近 N 条数据
     */
    List<SensorRecord> listLatest(String deviceId, String sensorKey, int limit);

    /**
     * 计算某传感器在时间范围内的平均值
     */
    Double avgBySensorKey(String deviceId, String sensorKey,
                          LocalDateTime start, LocalDateTime end);

    /**
     * 清理历史
     */
    int cleanHistory(int retentionDays);
}