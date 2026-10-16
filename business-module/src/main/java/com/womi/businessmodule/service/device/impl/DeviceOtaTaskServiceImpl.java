package com.womi.businessmodule.service.device.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.device.DeviceOtaTaskMapper;
import com.womi.businessmodule.model.device.DeviceOtaTask;
import com.womi.businessmodule.service.device.DeviceOtaTaskService;
import org.springframework.stereotype.Service;

@Service
public class DeviceOtaTaskServiceImpl extends ServiceImpl<DeviceOtaTaskMapper, DeviceOtaTask> implements DeviceOtaTaskService {
}