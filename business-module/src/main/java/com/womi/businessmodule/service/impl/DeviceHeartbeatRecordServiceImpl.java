package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.DeviceHeartbeatRecordMapper;
import com.womi.businessmodule.model.DeviceHeartbeatRecord;
import com.womi.businessmodule.service.DeviceHeartbeatRecordService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Service
public class DeviceHeartbeatRecordServiceImpl
        extends ServiceImpl<DeviceHeartbeatRecordMapper, DeviceHeartbeatRecord>
        implements DeviceHeartbeatRecordService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void recordHeartbeat(String deviceId, Long uptime, String payload) {
        DeviceHeartbeatRecord record = new DeviceHeartbeatRecord();
        record.setDeviceId(deviceId);
        record.setUptime(uptime);
        record.setPayload(payload);
        record.setTimestamp(LocalDateTime.now());
        save(record);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int cleanHistory(int retentionDays) {
        LocalDateTime before = LocalDateTime.now().minusDays(retentionDays);
        int deleted = baseMapper.deleteBefore(before);
        if (deleted > 0) log.info("清理心跳历史 - 共 {} 条", deleted);
        return deleted;
    }
}