package com.womi.businessmodule.service.device.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.device.DeviceAlertRecordMapper;
import com.womi.businessmodule.model.device.DeviceAlertRecord;
import com.womi.businessmodule.service.device.DeviceAlertRecordService;
import org.springframework.stereotype.Service;

@Service
public class DeviceAlertRecordServiceImpl extends ServiceImpl<DeviceAlertRecordMapper, DeviceAlertRecord> implements DeviceAlertRecordService {
}