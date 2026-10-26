package com.womi.businessmodule.mapper.sys;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.sys.SysInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface SysInfoMapper extends BaseMapper<SysInfo> {
    SysInfo selectByUsername(@Param("username") String username);
}