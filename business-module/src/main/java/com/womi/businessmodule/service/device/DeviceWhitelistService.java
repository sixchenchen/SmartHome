package com.womi.businessmodule.service.device;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.device.DeviceWhitelist;

public interface DeviceWhitelistService extends IService<DeviceWhitelist> {

    /**
     * 检查设备是否在白名单且已启用
     */
    boolean isAllowed(String deviceId);
}