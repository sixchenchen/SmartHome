package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.DeviceSlaveData;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface DeviceSlaveDataMapper extends BaseMapper<DeviceSlaveData> {

    List<DeviceSlaveData> selectByDeviceId(@Param("deviceId") String deviceId);

    int deleteByDeviceAndAddress(@Param("deviceId") String deviceId,
                                 @Param("address") Integer address);

    int deleteByDeviceId(@Param("deviceId") String deviceId);
}