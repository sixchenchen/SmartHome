package com.womi.businessmodule.service.device.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.device.DeviceBindingMapper;
import com.womi.businessmodule.model.device.DeviceBinding;
import com.womi.businessmodule.service.device.DeviceBindingService;
import org.springframework.stereotype.Service;

@Service
public class DeviceBindingServiceImpl extends ServiceImpl<DeviceBindingMapper, DeviceBinding> implements DeviceBindingService {
}