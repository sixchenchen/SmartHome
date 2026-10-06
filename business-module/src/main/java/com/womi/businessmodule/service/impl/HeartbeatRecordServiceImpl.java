package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.HeartbeatRecordMapper;
import com.womi.businessmodule.model.HeartbeatRecord;
import com.womi.businessmodule.service.HeartbeatRecordService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Service
public class HeartbeatRecordServiceImpl
        extends ServiceImpl<HeartbeatRecordMapper, HeartbeatRecord>
        implements HeartbeatRecordService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void recordHeartbeat(String deviceId, Long uptime, String payload) {
        HeartbeatRecord record = new HeartbeatRecord();
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