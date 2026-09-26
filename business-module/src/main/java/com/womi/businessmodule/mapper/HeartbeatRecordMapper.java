package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.HeartbeatRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
public interface HeartbeatRecordMapper extends BaseMapper<HeartbeatRecord> {

    /**
     * 查询设备最近的心跳记录
     */
    List<HeartbeatRecord> selectRecentByDeviceId(@Param("deviceId") String deviceId,
                                                 @Param("limit") int limit);

    /**
     * 查询设备指定时间段的心跳记录
     */
    List<HeartbeatRecord> selectByTimeRange(@Param("deviceId") String deviceId,
                                            @Param("startTime") LocalDateTime startTime,
                                            @Param("endTime") LocalDateTime endTime);

    /**
     * 查询设备最新的心跳记录
     */
    HeartbeatRecord selectLatestByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 查询设备心跳记录总数
     */
    Long countByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 查询指定时间段的心跳记录数量
     */
    Long countByTimeRange(@Param("deviceId") String deviceId,
                          @Param("startTime") LocalDateTime startTime,
                          @Param("endTime") LocalDateTime endTime);

    /**
     * 查询所有设备的最新心跳记录
     */
    List<HeartbeatRecord> selectLatestHeartbeatForAllDevices();

    /**
     * 查询设备最近N小时的心跳记录
     */
    List<HeartbeatRecord> selectRecentHours(@Param("deviceId") String deviceId,
                                            @Param("hours") int hours);

    /**
     * 查询设备今日心跳记录
     */
    List<HeartbeatRecord> selectTodayByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 统计设备在线率（最近N天）
     */
    Double calculateOnlineRate(@Param("deviceId") String deviceId,
                               @Param("days") int days);

    /**
     * 统计每小时心跳数量
     */
    List<Map<String, Object>> countByHour(@Param("deviceId") String deviceId,
                                          @Param("hours") int hours);
}