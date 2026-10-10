package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.MqttAuth;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MqttAuthMapper extends BaseMapper<MqttAuth> {
}