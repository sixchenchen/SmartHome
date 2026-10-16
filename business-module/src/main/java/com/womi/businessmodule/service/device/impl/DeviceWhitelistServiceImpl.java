package com.womi.businessmodule.service.device.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.device.DeviceWhitelistMapper;
import com.womi.businessmodule.model.device.DeviceWhitelist;
import com.womi.businessmodule.service.device.DeviceWhitelistService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class DeviceWhitelistServiceImpl
        extends ServiceImpl<DeviceWhitelistMapper, DeviceWhitelist>
        implements DeviceWhitelistService {

    @Override
    public boolean isAllowed(String deviceId) {
        if (deviceId == null || deviceId.isBlank()) return false;
        return count(new LambdaQueryWrapper<DeviceWhitelist>()
                .eq(DeviceWhitelist::getDeviceId, deviceId)
                .eq(DeviceWhitelist::getEnabled, 1)) > 0;
    }
}