package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.SensorThreshold;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SensorThresholdMapper extends BaseMapper<SensorThreshold> {

    /**
     * 查询设备的阈值配置
     */
    List<SensorThreshold> selectByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 查询指定传感器的阈值配置
     */
    SensorThreshold selectBySensorKey(@Param("deviceId") String deviceId,
                                      @Param("sensorKey") String sensorKey);

    /**
     * 查询所有启用的阈值配置
     */
    List<SensorThreshold> selectAllEnabled();
}