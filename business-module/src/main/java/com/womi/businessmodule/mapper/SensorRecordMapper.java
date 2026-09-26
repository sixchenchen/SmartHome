package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.SensorRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
public interface SensorRecordMapper extends BaseMapper<SensorRecord> {

    /**
     * 查询设备最近的传感器数据
     */
    List<SensorRecord> selectRecentByDeviceId(@Param("deviceId") String deviceId,
                                              @Param("limit") int limit);

    /**
     * 查询设备最新的传感器数据
     */
    SensorRecord selectLatestByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 查询设备指定时间段的传感器数据
     */
    List<SensorRecord> selectByTimeRange(@Param("deviceId") String deviceId,
                                         @Param("startTime") LocalDateTime startTime,
                                         @Param("endTime") LocalDateTime endTime);

    /**
     * 查询设备最新的传感器数据（解析特定字段）
     */
    String selectLatestSensorField(@Param("deviceId") String deviceId,
                                   @Param("fieldPath") String fieldPath);

    /**
     * 查询设备传感器数据中的从机列表
     */
    String selectLatestSlaves(@Param("deviceId") String deviceId);

    /**
     * 查询设备传感器数据中的特定从机地址
     */
    Map<String, Object> selectLatestSlaveByAddress(@Param("deviceId") String deviceId,
                                                   @Param("index") int index);

    /**
     * 统计设备传感器数据记录数
     */
    Long countByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 查询设备最近N小时的传感器数据
     */
    List<SensorRecord> selectRecentHours(@Param("deviceId") String deviceId,
                                         @Param("hours") int hours);
}