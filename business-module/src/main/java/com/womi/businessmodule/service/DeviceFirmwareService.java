package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.DeviceFirmware;

import java.util.List;

public interface DeviceFirmwareService extends IService<DeviceFirmware> {

    /**
     * 按版本 + 产品查询
     */
    DeviceFirmware getByVersion(String version, String product);

    /**
     * 查询所有启用的固件
     */
    List<DeviceFirmware> listEnabled();

    /**
     * 查询最新固件
     */
    DeviceFirmware getLatestByProduct(String product);

    /**
     * 新增固件
     */
    DeviceFirmware saveFirmware(DeviceFirmware firmware);
}