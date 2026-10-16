package com.womi.businessmodule.mapper.device;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.device.DeviceMqttAuth;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface DeviceMqttAuthMapper extends BaseMapper<DeviceMqttAuth> {
}