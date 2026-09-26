package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.womi.businessmodule.mapper.MosStateRecordMapper;
import com.womi.businessmodule.model.MosStateRecord;
import com.womi.businessmodule.service.MosStateRecordService;
import com.womi.commonmodule.utils.JsonUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class MosStateRecordServiceImpl extends ServiceImpl<MosStateRecordMapper, MosStateRecord>
        implements MosStateRecordService {

    private final MosStateRecordMapper mosStateRecordMapper;
    private final JsonUtils jsonUtils;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveMosStateRecord(String deviceId, Map<String, Integer> mosStates) {
        if (!StringUtils.hasText(deviceId) || mosStates == null || mosStates.isEmpty()) {
            log.warn("MOS状态记录参数不完整 - deviceId: {}, mosStates: {}", deviceId, mosStates);
            return false;
        }

        MosStateRecord record = new MosStateRecord();
        record.setDeviceId(deviceId);
        record.setTimestamp(LocalDateTime.now());
        record.setMosStates(mosStates);

        return save(record);
    }

    @Override
    public List<MosStateRecord> getRecentByDeviceId(String deviceId, int limit) {
        if (!StringUtils.hasText(deviceId)) {
            return List.of();
        }
        return mosStateRecordMapper.selectRecentByDeviceId(deviceId, limit);
    }

    @Override
    public MosStateRecord getLatestByDeviceId(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return null;
        }
        return mosStateRecordMapper.selectLatestByDeviceId(deviceId);
    }

    @Override
    public List<MosStateRecord> getByTimeRange(String deviceId, LocalDateTime startTime, LocalDateTime endTime) {
        if (!StringUtils.hasText(deviceId) || startTime == null || endTime == null) {
            return List.of();
        }
        return mosStateRecordMapper.selectByTimeRange(deviceId, startTime, endTime);
    }

    @Override
    public MosStateRecord getLatestWithParsedJson(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return null;
        }
        return mosStateRecordMapper.selectLatestWithParsedJson(deviceId);
    }

    @Override
    public List<Map<String, Object>> getMosChannelHistory(String deviceId, int mosIndex, int limit) {
        if (!StringUtils.hasText(deviceId) || mosIndex < 0 || mosIndex > 7 || limit <= 0) {
            return List.of();
        }
        return mosStateRecordMapper.selectMosChannelHistory(deviceId, mosIndex, limit);
    }

    @Override
    public List<Map<String, Object>> countMosStatesDistribution(String deviceId, int mosIndex, int days) {
        if (!StringUtils.hasText(deviceId) || mosIndex < 0 || mosIndex > 7 || days <= 0) {
            return List.of();
        }
        return mosStateRecordMapper.countMosStatesDistribution(deviceId, mosIndex, days);
    }

    @Override
    public Integer getLatestMosChannel(String deviceId, int mosIndex) {
        if (!StringUtils.hasText(deviceId) || mosIndex < 0 || mosIndex > 7) {
            return null;
        }
        return mosStateRecordMapper.selectLatestMosChannel(deviceId, mosIndex);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean batchSave(List<MosStateRecord> records) {
        if (records == null || records.isEmpty()) {
            return false;
        }
        return saveBatch(records);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int cleanExpiredRecords(int days) {
        if (days <= 0) {
            return 0;
        }
        LocalDateTime expireTime = LocalDateTime.now().minusDays(days);
        LambdaQueryWrapper<MosStateRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.lt(MosStateRecord::getTimestamp, expireTime);
        int deleted = baseMapper.delete(wrapper);
        log.info("清理过期MOS状态记录完成 - 删除 {} 条记录", deleted);
        return deleted;
    }
}
