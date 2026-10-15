package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.DeviceSensorThreshold;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface DeviceSensorThresholdMapper extends BaseMapper<DeviceSensorThreshold> {

    /**
     * 查询设备的阈值配置
     */
    List<DeviceSensorThreshold> selectByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 查询指定传感器的阈值配置
     */
    DeviceSensorThreshold selectBySensorKey(@Param("deviceId") String deviceId,
                                      @Param("sensorKey") String sensorKey);

    /**
     * 查询所有启用的阈值配置
     */
    List<DeviceSensorThreshold> selectAllEnabled();
}