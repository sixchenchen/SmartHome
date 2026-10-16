package com.womi.businessmodule.mapper.device;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.device.DeviceHeartbeatRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;

@Mapper
public interface DeviceHeartbeatRecordMapper extends BaseMapper<DeviceHeartbeatRecord> {

    /**
     * 删除指定时间之前的心跳记录
     */
    int deleteBefore(@Param("time") LocalDateTime time);
}