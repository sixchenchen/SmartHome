package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.HeartbeatRecord;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public interface HeartbeatRecordService extends IService<HeartbeatRecord> {

    /**
     * 保存心跳记录
     */
    boolean saveHeartbeatRecord(String deviceId, Long uptime, String payload);

    /**
     * 查询设备最近的心跳记录
     */
    List<HeartbeatRecord> getRecentByDeviceId(String deviceId, int limit);

    /**
     * 查询设备指定时间段的心跳记录
     */
    List<HeartbeatRecord> getByTimeRange(String deviceId, LocalDateTime startTime, LocalDateTime endTime);

    /**
     * 查询设备最新的心跳记录
     */
    HeartbeatRecord getLatestByDeviceId(String deviceId);

    /**
     * 查询设备心跳记录总数
     */
    Long countByDeviceId(String deviceId);

    /**
     * 查询指定时间段的心跳记录数量
     */
    Long countByTimeRange(String deviceId, LocalDateTime startTime, LocalDateTime endTime);

    /**
     * 查询所有设备的最新心跳记录
     */
    List<HeartbeatRecord> getLatestHeartbeatForAllDevices();

    /**
     * 查询设备最近N小时的心跳记录
     */
    List<HeartbeatRecord> getRecentHours(String deviceId, int hours);

    /**
     * 查询设备今日心跳记录
     */
    List<HeartbeatRecord> getTodayByDeviceId(String deviceId);

    /**
     * 统计设备在线率（最近N天）
     */
    Double calculateOnlineRate(String deviceId, int days);

    /**
     * 统计每小时心跳数量
     */
    List<Map<String, Object>> countByHour(String deviceId, int hours);

    /**
     * 批量保存心跳记录
     */
    boolean batchSave(List<HeartbeatRecord> records);

    /**
     * 清理过期心跳记录
     */
    int cleanExpiredRecords(int days);
}