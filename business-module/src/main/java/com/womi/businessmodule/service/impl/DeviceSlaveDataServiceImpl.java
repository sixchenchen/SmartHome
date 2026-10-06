package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.DeviceSlaveDataMapper;
import com.womi.businessmodule.model.DeviceSlaveData;
import com.womi.businessmodule.service.DeviceSlaveDataService;
import com.womi.businessmodule.service.SensorRecordService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceSlaveDataServiceImpl
        extends ServiceImpl<DeviceSlaveDataMapper, DeviceSlaveData>
        implements DeviceSlaveDataService {

    private final SensorRecordService sensorRecordService;

    private static final String SOURCE_SLAVE = "slave";

    @Override
    public List<DeviceSlaveData> listByDeviceId(String deviceId) {
        return baseMapper.selectByDeviceId(deviceId);
    }

    /**
     * 核心同步逻辑：upsert + 差异删除 + 写历史
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void syncSlaveData(String deviceId, List<Map<String, Object>> slaves) {
        LocalDateTime now = LocalDateTime.now();

        // 1. 查现有从机
        List<DeviceSlaveData> existing = baseMapper.selectByDeviceId(deviceId);
        Map<String, DeviceSlaveData> existingMap = existing.stream()
                .collect(Collectors.toMap(
                        e -> key(e.getAddress(), e.getSlaveType(), e.getChannel()),
                        e -> e,
                        (a, b) -> a));

        Set<String> reportedKeys = new HashSet<>();
        List<DeviceSlaveData> toInsert = new ArrayList<>();
        List<DeviceSlaveData> toUpdate = new ArrayList<>();
        List<com.womi.businessmodule.model.SensorRecord> historyRecords = new ArrayList<>();

        // 2. 处理上报的从机
        if (slaves != null) {
            for (Map<String, Object> s : slaves) {
                Integer address = toInt(s.get("address"));
                String slaveType = toString(s.get("slave_type"));
                Integer channel = toInt(s.get("channel"));
                if (address == null || slaveType == null) continue;

                String k = key(address, slaveType, channel);
                reportedKeys.add(k);

                Double value = toDouble(s.get("value"));
                String unit = toString(s.get("unit"));
                String sensorKey = toString(s.get("sensor_key"));
                if (sensorKey == null) {
                    sensorKey = "slave-" + address + "-" + slaveType
                            + (channel != null ? "-ch" + channel : "");
                }

                DeviceSlaveData exist = existingMap.get(k);
                if (exist != null) {
                    // 更新：online_since 保持不变
                    exist.setValue(value);
                    exist.setUnit(unit);
                    exist.setTimestamp(now);
                    toUpdate.add(exist);
                } else {
                    // 新增：online_since = now
                    DeviceSlaveData data = new DeviceSlaveData();
                    data.setDeviceId(deviceId);
                    data.setAddress(address);
                    data.setSlaveType(slaveType);
                    data.setChannel(channel);
                    data.setOnlineSince(now);
                    data.setValue(value);
                    data.setUnit(unit);
                    data.setTimestamp(now);
                    toInsert.add(data);
                }

                // 组装历史记录
                com.womi.businessmodule.model.SensorRecord record =
                        new com.womi.businessmodule.model.SensorRecord();
                record.setDeviceId(deviceId);
                record.setSource(SOURCE_SLAVE);
                record.setSlaveAddress(address);
                record.setChannel(channel);
                record.setSensorKey(sensorKey);
                record.setSensorType(slaveType);
                record.setSensorValue(value);
                record.setUnit(unit);
                record.setTimestamp(now);
                historyRecords.add(record);
            }
        }

        // 3. 差异删除
        List<Long> toDeleteIds = new ArrayList<>();
        for (DeviceSlaveData old : existing) {
            String k = key(old.getAddress(), old.getSlaveType(), old.getChannel());
            if (!reportedKeys.contains(k)) {
                toDeleteIds.add(old.getId());
            }
        }

        // 4. 执行
        if (!toInsert.isEmpty()) {
            saveBatch(toInsert);
            log.info("从机数据新增 - deviceId: {}, 数量: {}", deviceId, toInsert.size());
        }
        if (!toUpdate.isEmpty()) {
            updateBatchById(toUpdate);
        }
        if (!toDeleteIds.isEmpty()) {
            removeByIds(toDeleteIds);
            log.info("从机离线删除 - deviceId: {}, 数量: {}", deviceId, toDeleteIds.size());
        }

        // 5. 写历史
        if (!historyRecords.isEmpty()) {
            sensorRecordService.saveBatchRecords(historyRecords);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int clearByDeviceId(String deviceId) {
        int deleted = baseMapper.deleteByDeviceId(deviceId);
        if (deleted > 0) {
            log.info("清空设备从机数据 - deviceId: {}, 数量: {}", deviceId, deleted);
        }
        return deleted;
    }

    // ---------- 工具方法 ----------
    private String key(Integer address, String slaveType, Integer channel) {
        return address + ":" + slaveType + ":" + (channel == null ? "null" : channel);
    }

    private Integer toInt(Object o) {
        if (o == null) return null;
        if (o instanceof Number) return ((Number) o).intValue();
        try { return Integer.parseInt(o.toString()); } catch (Exception e) { return null; }
    }

    private Double toDouble(Object o) {
        if (o == null) return null;
        if (o instanceof Number) return ((Number) o).doubleValue();
        try { return Double.parseDouble(o.toString()); } catch (Exception e) { return null; }
    }

    private String toString(Object o) {
        return o == null ? null : o.toString();
    }
}