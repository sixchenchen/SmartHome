package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.DeviceSensor;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface DeviceSensorMapper extends BaseMapper<DeviceSensor> {

    /**
     * 查询设备的所有传感器
     */
    List<DeviceSensor> selectByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 查询从机的传感器
     */
    List<DeviceSensor> selectBySlaveAddress(@Param("deviceId") String deviceId,
                                            @Param("slaveAddress") Integer slaveAddress);
}