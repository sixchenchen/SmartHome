package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.SensorRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface SensorRecordMapper extends BaseMapper<SensorRecord> {

    /**
     * 按 sensor_key 查询指定时间范围的数据
     */
    List<SensorRecord> selectBySensorKey(@Param("deviceId") String deviceId,
                                         @Param("sensorKey") String sensorKey,
                                         @Param("start") LocalDateTime start,
                                         @Param("end") LocalDateTime end);

    /**
     * 按从机地址 + 通道查询
     */
    List<SensorRecord> selectBySlaveChannel(@Param("deviceId") String deviceId,
                                            @Param("slaveAddress") Integer slaveAddress,
                                            @Param("channel") Integer channel,
                                            @Param("sensorType") String sensorType,
                                            @Param("start") LocalDateTime start,
                                            @Param("end") LocalDateTime end);

    /**
     * 删除指定时间之前的数据
     */
    int deleteBefore(@Param("time") LocalDateTime time);

    /**
     * 统计某传感器在指定时间范围内的平均值
     */
    Double selectAvgBySensorKey(@Param("deviceId") String deviceId,
                                @Param("sensorKey") String sensorKey,
                                @Param("start") LocalDateTime start,
                                @Param("end") LocalDateTime end);
}