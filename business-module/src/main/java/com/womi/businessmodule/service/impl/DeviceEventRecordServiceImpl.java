package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.DeviceEventRecordMapper;
import com.womi.businessmodule.model.DeviceEventRecord;
import com.womi.businessmodule.service.DeviceEventRecordService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
public class DeviceEventRecordServiceImpl
        extends ServiceImpl<DeviceEventRecordMapper, DeviceEventRecord>
        implements DeviceEventRecordService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void recordEvent(DeviceEventRecord event) {
        if (event.getTimestamp() == null) {
            event.setTimestamp(java.time.LocalDateTime.now());
        }
        save(event);
    }

    @Override
    public List<DeviceEventRecord> listRecentByDevice(String deviceId, int limit) {
        return list(new LambdaQueryWrapper<DeviceEventRecord>()
                .eq(DeviceEventRecord::getDeviceId, deviceId)
                .orderByDesc(DeviceEventRecord::getTimestamp)
                .last("LIMIT " + limit));
    }
}