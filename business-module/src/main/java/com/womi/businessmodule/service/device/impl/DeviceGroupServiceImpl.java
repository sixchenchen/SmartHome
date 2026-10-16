package com.womi.businessmodule.service.device.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.device.DeviceGroupMapper;
import com.womi.businessmodule.model.device.DeviceGroup;
import com.womi.businessmodule.service.device.DeviceGroupService;
import org.springframework.stereotype.Service;

@Service
public class DeviceGroupServiceImpl extends ServiceImpl<DeviceGroupMapper, DeviceGroup> implements DeviceGroupService {
}