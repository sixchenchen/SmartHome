package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.DeviceInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface DeviceInfoMapper extends BaseMapper<DeviceInfo> {

    /**
     * 查询心跳超时的在线设备
     */
    List<DeviceInfo> selectHeartbeatTimeoutDevices(@Param("threshold") LocalDateTime threshold);
}