package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.womi.businessmodule.mapper.*;
import com.womi.businessmodule.model.*;
import com.womi.businessmodule.service.DeviceDataService;
import com.womi.businessmodule.vo.DeviceData;
import com.womi.commonmodule.device.DeviceConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceDataServiceImpl implements DeviceDataService {

    private final DeviceInfoMapper deviceInfoMapper;
    private final HeartbeatRecordMapper heartbeatRecordMapper;
    private final MosStateRecordMapper mosStateRecordMapper;
    private final SensorRecordMapper sensorRecordMapper;
    private final SensorSlaveDataMapper sensorSlaveDataMapper;
    private final ObjectMapper objectMapper;

    // 内存缓存（提高性能）
    private final Map<String, DeviceData> deviceCache = new ConcurrentHashMap<>();

    @Override
    public DeviceData getOrCreateDevice(String deviceId) {
        return deviceCache.computeIfAbsent(deviceId, id -> {
            // 从数据库加载
            DeviceInfo deviceInfo = deviceInfoMapper.selectByDeviceId(id);
            if (deviceInfo != null) {
                return loadDeviceDataFromDb(deviceInfo);
            }
            // 创建新设备
            return new DeviceData(deviceId);
        });
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveOrUpdateDevice(DeviceData deviceData) {
        if (deviceData == null || deviceData.getDeviceId() == null) {
            return;
        }

        try {
            String deviceId = deviceData.getDeviceId();

            // 1. 保存或更新设备信息
            DeviceInfo deviceInfo = deviceInfoMapper.selectByDeviceId(deviceId);
            if (deviceInfo == null) {
                deviceInfo = new DeviceInfo();
                deviceInfo.setDeviceId(deviceId);
                deviceInfo.setDeviceName(DeviceConstants.DEVICE_NAME_PREFIX + deviceId);
                deviceInfo.setStatus(DeviceConstants.DEVICE_STATUS_ONLINE);
                deviceInfo.setCreateTime(LocalDateTime.now());
            }

            deviceInfo.setUptime(deviceData.getUptime());
            deviceInfo.setLastHeartbeatTime(deviceData.getLastHeartbeatTime());
            deviceInfo.setLastUpdateTime(deviceData.getLastUpdateTime());
            deviceInfo.setLastPayload(deviceData.getLastPayload());
            deviceInfo.setSensorData(deviceData.getSensorData());
            deviceInfo.setStatus(deviceData.getStatus() != null ? deviceData.getStatus() : DeviceConstants.DEVICE_STATUS_ONLINE);
            deviceInfo.setUpdateTime(LocalDateTime.now());

            if (deviceInfo.getId() == null) {
                deviceInfoMapper.insert(deviceInfo);
            } else {
                deviceInfoMapper.updateById(deviceInfo);
            }

            // 2. 保存心跳记录
            if (deviceData.getHeartbeatHistory() != null && !deviceData.getHeartbeatHistory().isEmpty()) {
                // 只保存最近的一条（避免频繁插入）
                HeartbeatRecord latest = deviceData.getHeartbeatHistory().get(
                        deviceData.getHeartbeatHistory().size() - 1
                );
                if (latest.getId() == null) {
                    latest.setDeviceId(deviceId);
                    heartbeatRecordMapper.insert(latest);
                }
            }

            // 3. 保存MOS状态记录
            if (deviceData.getMosStateHistory() != null && !deviceData.getMosStateHistory().isEmpty()) {
                MosStateRecord latest = deviceData.getMosStateHistory().get(
                        deviceData.getMosStateHistory().size() - 1
                );
                if (latest.getId() == null) {
                    latest.setDeviceId(deviceId);
                    mosStateRecordMapper.insert(latest);
                }
            }

            // 4. 保存传感器数据
            if (deviceData.getSensorData() != null) {
                SensorRecord sensorRecord = new SensorRecord();
                sensorRecord.setDeviceId(deviceId);
                sensorRecord.setSensorData(deviceData.getSensorData());
                sensorRecord.setTimestamp(LocalDateTime.now());
                sensorRecordMapper.insert(sensorRecord);
            }

            // 5. 保存从机数据
            if (deviceData.getSlaveDataList() != null && !deviceData.getSlaveDataList().isEmpty()) {
                for (SensorSlaveData slave : deviceData.getSlaveDataList()) {
                    if (slave.getId() == null) {
                        slave.setDeviceId(deviceId);
                        slave.setTimestamp(LocalDateTime.now());
                        sensorSlaveDataMapper.insert(slave);
                    }
                }
            }

            // 6. 更新缓存
            deviceCache.put(deviceId, deviceData);

            log.debug("设备数据保存成功 - DeviceId: {}", deviceId);

        } catch (Exception e) {
            log.error("保存设备数据失败 - DeviceId: {}", deviceData.getDeviceId(), e);
            throw new RuntimeException("保存设备数据失败", e);
        }
    }

    @Override
    public DeviceData getDeviceData(String deviceId) {
        // 先从缓存获取
        DeviceData cached = deviceCache.get(deviceId);
        if (cached != null) {
            return cached;
        }

        // 从数据库加载
        DeviceInfo deviceInfo = deviceInfoMapper.selectByDeviceId(deviceId);
        if (deviceInfo != null) {
            return loadDeviceDataFromDb(deviceInfo);
        }

        return null;
    }

    @Override
    public List<DeviceData> getAllDevices() {
        List<DeviceInfo> deviceInfos = deviceInfoMapper.selectList(null);
        List<DeviceData> result = new ArrayList<>();
        for (DeviceInfo info : deviceInfos) {
            result.add(loadDeviceDataFromDb(info));
        }
        return result;
    }

    @Override
    public List<DeviceData> getOnlineDevices() {
        List<DeviceInfo> deviceInfos = deviceInfoMapper.selectOnlineDevices();
        List<DeviceData> result = new ArrayList<>();
        for (DeviceInfo info : deviceInfos) {
            result.add(loadDeviceDataFromDb(info));
        }
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveHeartbeatRecord(String deviceId, Long uptime, String payload) {
        HeartbeatRecord record = new HeartbeatRecord();
        record.setDeviceId(deviceId);
        record.setUptime(uptime);
        record.setPayload(payload);
        record.setTimestamp(LocalDateTime.now());
        heartbeatRecordMapper.insert(record);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveMosStateRecord(String deviceId, Map<String, Integer> mosStates) {
        MosStateRecord record = new MosStateRecord();
        record.setDeviceId(deviceId);
        record.setMosStates(mosStates);
        record.setTimestamp(LocalDateTime.now());
        mosStateRecordMapper.insert(record);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveSensorData(String deviceId, String sensorData, List<?> slaveDataList) {
        SensorRecord record = new SensorRecord();
        record.setDeviceId(deviceId);
        record.setSensorData(sensorData);
        record.setTimestamp(LocalDateTime.now());
        sensorRecordMapper.insert(record);
    }

    @Override
    public List<HeartbeatRecord> getHeartbeatHistory(String deviceId, int limit) {
        return heartbeatRecordMapper.selectRecentByDeviceId(deviceId, limit);
    }

    @Override
    public List<MosStateRecord> getMosStateHistory(String deviceId, int limit) {
        return mosStateRecordMapper.selectRecentByDeviceId(deviceId, limit);
    }

    @Override
    public List<SensorRecord> getSensorHistory(String deviceId, int limit) {
        return sensorRecordMapper.selectRecentByDeviceId(deviceId, limit);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateDeviceStatus(String deviceId, int status) {
        DeviceInfo deviceInfo = deviceInfoMapper.selectByDeviceId(deviceId);
        if (deviceInfo != null) {
            deviceInfo.setStatus(status);
            deviceInfo.setLastUpdateTime(LocalDateTime.now());
            deviceInfoMapper.updateById(deviceInfo);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cleanExpiredData() {
        // 清理30天前的历史数据
        LocalDateTime expireTime = LocalDateTime.now().minusDays(DeviceConstants.DATA_RETENTION_DAYS);

        LambdaQueryWrapper<HeartbeatRecord> heartbeatWrapper = new LambdaQueryWrapper<>();
        heartbeatWrapper.lt(HeartbeatRecord::getTimestamp, expireTime);
        heartbeatRecordMapper.delete(heartbeatWrapper);

        LambdaQueryWrapper<MosStateRecord> mosWrapper = new LambdaQueryWrapper<>();
        mosWrapper.lt(MosStateRecord::getTimestamp, expireTime);
        mosStateRecordMapper.delete(mosWrapper);

        LambdaQueryWrapper<SensorRecord> sensorWrapper = new LambdaQueryWrapper<>();
        sensorWrapper.lt(SensorRecord::getTimestamp, expireTime);
        sensorRecordMapper.delete(sensorWrapper);

        LambdaQueryWrapper<SensorSlaveData> slaveWrapper = new LambdaQueryWrapper<>();
        slaveWrapper.lt(SensorSlaveData::getTimestamp, expireTime);
        sensorSlaveDataMapper.delete(slaveWrapper);

        log.info("清理过期数据完成 - 过期时间: {}", expireTime);
    }

    /**
     * 从数据库加载设备数据
     */
    private DeviceData loadDeviceDataFromDb(DeviceInfo deviceInfo) {
        String deviceId = deviceInfo.getDeviceId();
        DeviceData deviceData = new DeviceData(deviceId);

        // 设置基础信息
        deviceData.setDeviceName(deviceInfo.getDeviceName());
        deviceData.setLocation(deviceInfo.getLocation());
        deviceData.setStatus(deviceInfo.getStatus());
        deviceData.setUptime(deviceInfo.getUptime());
        deviceData.setLastHeartbeatTime(deviceInfo.getLastHeartbeatTime());
        deviceData.setLastUpdateTime(deviceInfo.getLastUpdateTime());
        deviceData.setLastPayload(deviceInfo.getLastPayload());
        deviceData.setSensorData(deviceInfo.getSensorData());

        // 加载MOS状态
        MosStateRecord latestMos = mosStateRecordMapper.selectLatestByDeviceId(deviceId);
        if (latestMos != null && latestMos.getMosStates() != null) {
            deviceData.setMosStates(latestMos.getMosStates());
        }

        // 加载从机数据
        List<SensorSlaveData> slaveList = sensorSlaveDataMapper.selectRecentByDeviceId(deviceId, DeviceConstants.RECENT_SLAVE_LIMIT);
        deviceData.setSlaveDataList(slaveList);

        // 加载历史数据（最近100条）
        List<HeartbeatRecord> heartbeats = heartbeatRecordMapper.selectRecentByDeviceId(deviceId, DeviceConstants.HEARTBEAT_HISTORY_LIMIT);
        deviceData.setHeartbeatHistory(heartbeats);

        List<MosStateRecord> mosHistory = mosStateRecordMapper.selectRecentByDeviceId(deviceId, DeviceConstants.HEARTBEAT_HISTORY_LIMIT);
        deviceData.setMosStateHistory(mosHistory);

        List<SensorRecord> sensorHistory = sensorRecordMapper.selectRecentByDeviceId(deviceId, DeviceConstants.HEARTBEAT_HISTORY_LIMIT);
        deviceData.setSensorHistory(sensorHistory);

        // 加入缓存
        deviceCache.put(deviceId, deviceData);

        return deviceData;
    }
}