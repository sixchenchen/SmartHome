package com.womi.businessmodule.service.impl;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.DeviceInfoMapper;
import com.womi.businessmodule.model.DeviceInfo;
import com.womi.businessmodule.service.DeviceInfoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceInfoServiceImpl extends ServiceImpl<DeviceInfoMapper, DeviceInfo> implements DeviceInfoService {

    private final DeviceInfoMapper deviceInfoMapper;

    @Override
    public DeviceInfo getByDeviceId(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return null;
        }
        return deviceInfoMapper.selectByDeviceId(deviceId);
    }

    @Override
    public List<DeviceInfo> getOnlineDevices() {
        return deviceInfoMapper.selectOnlineDevices();
    }

    @Override
    public List<DeviceInfo> getByDeviceName(String deviceName) {
        if (!StringUtils.hasText(deviceName)) {
            return list();
        }
        return deviceInfoMapper.selectByDeviceName(deviceName);
    }

    @Override
    public List<DeviceInfo> getByStatus(Integer status) {
        if (status == null) {
            return list();
        }
        return deviceInfoMapper.selectByStatus(status);
    }

    @Override
    public List<DeviceInfo> getRecentDevices(int limit) {
        return deviceInfoMapper.selectRecentDevices(limit);
    }

    @Override
    public List<DeviceInfo> getOfflineDevices(int timeoutSeconds) {
        return deviceInfoMapper.selectOfflineDevices(timeoutSeconds);
    }

    @Override
    public int countByStatus(Integer status) {
        if (status == null) {
            return (int) count();
        }
        return deviceInfoMapper.countDevicesByStatus(status);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateStatus(String deviceId, Integer status,
                            LocalDateTime heartbeatTime, LocalDateTime updateTime) {
        if (!StringUtils.hasText(deviceId) || status == null) {
            return 0;
        }
        return deviceInfoMapper.updateStatus(deviceId, status, heartbeatTime, updateTime);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateDeviceInfo(DeviceInfo deviceInfo) {
        if (deviceInfo == null || !StringUtils.hasText(deviceInfo.getDeviceId())) {
            return 0;
        }
        return deviceInfoMapper.updateDeviceInfo(deviceInfo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int batchUpdateStatus(List<String> deviceIds, Integer status) {
        if (deviceIds == null || deviceIds.isEmpty() || status == null) {
            return 0;
        }
        return deviceInfoMapper.batchUpdateStatus(deviceIds, status);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertOrUpdateDevice(DeviceInfo deviceInfo) {
        if (deviceInfo == null || !StringUtils.hasText(deviceInfo.getDeviceId())) {
            return 0;
        }
        return deviceInfoMapper.insertOrUpdateDevice(deviceInfo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteByDeviceId(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return 0;
        }
        return deviceInfoMapper.deleteByDeviceId(deviceId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int batchDeleteDevices(List<String> deviceIds) {
        if (deviceIds == null || deviceIds.isEmpty()) {
            return 0;
        }
        return deviceInfoMapper.batchDeleteDevices(deviceIds);
    }

    @Override
    public boolean existsByDeviceId(String deviceId) {
        if (!StringUtils.hasText(deviceId)) {
            return false;
        }
        LambdaQueryWrapper<DeviceInfo> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DeviceInfo::getDeviceId, deviceId);
        return count(wrapper) > 0;
    }

    @Override
    public long getTotalCount() {
        return count();
    }
}