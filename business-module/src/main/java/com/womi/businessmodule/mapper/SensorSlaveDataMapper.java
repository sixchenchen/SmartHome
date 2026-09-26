package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.SensorSlaveData;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
public interface SensorSlaveDataMapper extends BaseMapper<SensorSlaveData> {

    /**
     * 查询设备最近的从机数据
     */
    List<SensorSlaveData> selectRecentByDeviceId(@Param("deviceId") String deviceId,
                                                 @Param("limit") int limit);

    /**
     * 查询设备最新的从机数据
     */
    SensorSlaveData selectLatestByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 查询设备指定地址的从机数据
     */
    List<SensorSlaveData> selectByAddress(@Param("deviceId") String deviceId,
                                          @Param("address") int address,
                                          @Param("limit") int limit);

    /**
     * 查询设备在线从机列表
     */
    List<SensorSlaveData> selectOnlineSlaves(@Param("deviceId") String deviceId);

    /**
     * 查询设备离线从机列表
     */
    List<SensorSlaveData> selectOfflineSlaves(@Param("deviceId") String deviceId);

    /**
     * 查询设备从机数据统计
     */
    Map<String, Object> selectSlaveStatistics(@Param("deviceId") String deviceId,
                                              @Param("hours") int hours);

    /**
     * 查询设备最近N小时的从机数据
     */
    List<SensorSlaveData> selectRecentHours(@Param("deviceId") String deviceId,
                                            @Param("hours") int hours);

    /**
     * 查询设备指定时间段的从机数据
     */
    List<SensorSlaveData> selectByTimeRange(@Param("deviceId") String deviceId,
                                            @Param("startTime") LocalDateTime startTime,
                                            @Param("endTime") LocalDateTime endTime);

    /**
     * 查询所有设备的最新从机数据
     */
    List<SensorSlaveData> selectLatestForAllDevices();

    /**
     * 批量插入从机数据
     */
    int batchInsert(@Param("list") List<SensorSlaveData> slaveDataList);
}