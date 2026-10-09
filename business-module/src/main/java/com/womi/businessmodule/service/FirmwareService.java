package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.Firmware;

import java.util.List;

public interface FirmwareService extends IService<Firmware> {

    /**
     * 按版本 + 产品查询
     */
    Firmware getByVersion(String version, String product);

    /**
     * 查询所有启用的固件
     */
    List<Firmware> listEnabled();

    /**
     * 查询最新固件
     */
    Firmware getLatestByProduct(String product);

    /**
     * 新增固件
     */
    Firmware saveFirmware(Firmware firmware);
}