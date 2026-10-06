package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.DeviceStateRecordMapper;
import com.womi.businessmodule.model.DeviceStateRecord;
import com.womi.businessmodule.service.DeviceStateRecordService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class DeviceStateRecordServiceImpl
        extends ServiceImpl<DeviceStateRecordMapper, DeviceStateRecord>
        implements DeviceStateRecordService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void recordState(String deviceId, String target, Integer channel,
                            Map<String, Object> params, LocalDateTime timestamp) {
        DeviceStateRecord record = new DeviceStateRecord();
        record.setDeviceId(deviceId);
        record.setTarget(target);
        record.setChannel(channel);
        record.setParams(params);
        record.setTimestamp(timestamp != null ? timestamp : LocalDateTime.now());
        save(record);
    }

    @Override
    public List<DeviceStateRecord> listByDeviceAndTarget(String deviceId, String target,
                                                         LocalDateTime start, LocalDateTime end) {
        return list(new LambdaQueryWrapper<DeviceStateRecord>()
                .eq(DeviceStateRecord::getDeviceId, deviceId)
                .eq(target != null, DeviceStateRecord::getTarget, target)
                .ge(start != null, DeviceStateRecord::getTimestamp, start)
                .le(end != null, DeviceStateRecord::getTimestamp, end)
                .orderByDesc(DeviceStateRecord::getTimestamp));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int cleanHistory(int retentionDays) {
        LocalDateTime before = LocalDateTime.now().minusDays(retentionDays);
        int deleted = baseMapper.delete(new LambdaQueryWrapper<DeviceStateRecord>()
                .lt(DeviceStateRecord::getTimestamp, before));
        if (deleted > 0) log.info("清理状态历史 - 共 {} 条", deleted);
        return deleted;
    }
}