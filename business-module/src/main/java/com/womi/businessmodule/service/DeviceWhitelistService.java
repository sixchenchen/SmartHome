package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.DeviceWhitelist;

public interface DeviceWhitelistService extends IService<DeviceWhitelist> {

    /**
     * 检查设备是否在白名单且已启用
     */
    boolean isAllowed(String deviceId);
}