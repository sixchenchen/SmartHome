package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.SensorSlaveData;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public interface SensorSlaveDataService extends IService<SensorSlaveData> {

    /**
     * 保存从机数据
     */
    boolean saveSlaveData(String deviceId, Integer address, Integer online, Integer count);

    /**
     * 查询设备最近的从机数据
     */
    List<SensorSlaveData> getRecentByDeviceId(String deviceId, int limit);

    /**
     * 查询设备最新的从机数据
     */
    SensorSlaveData getLatestByDeviceId(String deviceId);

    /**
     * 查询设备指定地址的从机数据
     */
    List<SensorSlaveData> getByAddress(String deviceId, int address, int limit);

    /**
     * 查询设备在线从机列表
     */
    List<SensorSlaveData> getOnlineSlaves(String deviceId);

    /**
     * 查询设备离线从机列表
     */
    List<SensorSlaveData> getOfflineSlaves(String deviceId);

    /**
     * 查询设备从机数据统计
     */
    Map<String, Object> getSlaveStatistics(String deviceId, int hours);

    /**
     * 查询设备最近N小时的从机数据
     */
    List<SensorSlaveData> getRecentHours(String deviceId, int hours);

    /**
     * 查询设备指定时间段的从机数据
     */
    List<SensorSlaveData> getByTimeRange(String deviceId, LocalDateTime startTime, LocalDateTime endTime);

    /**
     * 查询所有设备的最新从机数据
     */
    List<SensorSlaveData> getLatestForAllDevices();

    /**
     * 批量保存从机数据
     */
    int batchSave(List<SensorSlaveData> slaveDataList);

    /**
     * 清理过期从机数据
     */
    int cleanExpiredRecords(int days);

    /**
     * 根据设备ID删除从机数据
     */
    int deleteByDeviceId(String deviceId);

    /**
     * 更新从机在线状态
     */
    int updateOnlineStatus(String deviceId, Integer address, Integer online);
}