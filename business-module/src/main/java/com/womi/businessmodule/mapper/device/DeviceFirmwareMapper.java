package com.womi.businessmodule.mapper.device;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.device.DeviceFirmware;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface DeviceFirmwareMapper extends BaseMapper<DeviceFirmware> {

    /**
     * 按版本 + 产品查询
     */
    DeviceFirmware selectByVersionAndProduct(@Param("version") String version, @Param("product") String product);

    /**
     * 查询所有启用的固件
     */
    List<DeviceFirmware> selectAllEnabled();

    /**
     * 按产品查询最新固件
     */
    DeviceFirmware selectLatestByProduct(@Param("product") String product);
}