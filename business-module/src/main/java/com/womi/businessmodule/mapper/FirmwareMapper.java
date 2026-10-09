package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.Firmware;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FirmwareMapper extends BaseMapper<Firmware> {

    /**
     * 按版本 + 产品查询
     */
    Firmware selectByVersionAndProduct(@Param("version") String version, @Param("product") String product);

    /**
     * 查询所有启用的固件
     */
    List<Firmware> selectAllEnabled();

    /**
     * 按产品查询最新固件
     */
    Firmware selectLatestByProduct(@Param("product") String product);
}