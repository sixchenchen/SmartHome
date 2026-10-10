package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.DeviceInfoMapper;
import com.womi.businessmodule.model.DeviceInfo;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.commonmodule.enums.OfflineReason;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;


@Slf4j
@Service
public class DeviceInfoServiceImpl
        extends ServiceImpl<DeviceInfoMapper, DeviceInfo>
        implements DeviceInfoService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceInfo getOrCreateDevice(String deviceId) {
        DeviceInfo info = getByDeviceId(deviceId);
        if (info == null) {
            info = new DeviceInfo();
            info.setDeviceId(deviceId);
            info.setOnline(DeviceConstants.DEVICE_STATUS_OFFLINE);
            save(info);
            log.info("创建新设备 - deviceId: {}", deviceId);
        }
        return info;
    }

    @Override
    public DeviceInfo getByDeviceId(String deviceId) {
        return getOne(new LambdaQueryWrapper<DeviceInfo>()
                .eq(DeviceInfo::getDeviceId, deviceId)
                .last("LIMIT 1"));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void markOnline(String deviceId, String product, String firmware, Map<String, Object> capabilities) {
        DeviceInfo info = getOrCreateDevice(deviceId);
        LocalDateTime now = LocalDateTime.now();
        info.setOnline(DeviceConstants.DEVICE_STATUS_ONLINE);
        info.setOfflineReason(null);
        info.setLastOnlineTime(now);
        info.setLastHeartbeatTime(now);
        if (product != null) info.setProduct(product);
        if (firmware != null) info.setFirmware(firmware);
        if (capabilities != null && !capabilities.isEmpty()) {
            info.setCapabilities(capabilities);
        }
        updateById(info);
        log.info("设备上线 - deviceId: {}", deviceId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void markOffline(String deviceId, OfflineReason reason) {
        DeviceInfo info = getOrCreateDevice(deviceId);
        LocalDateTime now = LocalDateTime.now();
        info.setOnline(DeviceConstants.DEVICE_STATUS_OFFLINE);
        info.setOfflineReason(reason.getCode());
        info.setLastOfflineTime(now);
        updateById(info);
        log.info("设备离线 - deviceId: {}, reason: {}", deviceId, reason);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateHeartbeat(String deviceId, Long uptime, String payload) {
        DeviceInfo info = getOrCreateDevice(deviceId);
        LocalDateTime now = LocalDateTime.now();
        info.setUptime(uptime);
        info.setLastHeartbeatTime(now);
        info.setLastPayload(payload);
        info.setOnline(DeviceConstants.DEVICE_STATUS_ONLINE);
        info.setOfflineReason(null);
        updateById(info);
    }

    @Override
    public List<DeviceInfo> listHeartbeatTimeoutDevices(int timeoutSeconds) {
        LocalDateTime threshold = LocalDateTime.now().minusSeconds(timeoutSeconds);
        return baseMapper.selectHeartbeatTimeoutDevices(threshold);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int markHeartbeatTimeoutOffline(int timeoutSeconds) {
        List<DeviceInfo> devices = listHeartbeatTimeoutDevices(timeoutSeconds);
        if (devices.isEmpty()) {
            return 0;
        }

        LocalDateTime now = LocalDateTime.now();
        for (DeviceInfo device : devices) {
            markAsTimeoutOffline(device, now);
        }
        updateBatchById(devices);

        log.warn("心跳超时标记离线 - 共 {} 台", devices.size());
        return devices.size();
    }


    /**
     * 把设备标记为"心跳超时离线"
     */
    private void markAsTimeoutOffline(DeviceInfo device, LocalDateTime now) {
        device.setOnline(DeviceConstants.DEVICE_STATUS_OFFLINE);
        device.setOfflineReason(OfflineReason.HEARTBEAT_TIMEOUT.getCode());
        device.setLastOfflineTime(now);
    }

    /**
     * 更新设备OTA状态
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateOtaState(String deviceId, String state, Integer progress, String version) {
        DeviceInfo info = getByDeviceId(deviceId);
        if (info == null) {
            log.warn("设备不存在 - deviceId: {}", deviceId);
            return;
        }

        info.setOtaState(state);
        if (progress != null) {
            info.setOtaProgress(progress);
        }
        if (version != null) {
            info.setOtaVersion(version);
        }
        updateById(info);

        log.info("设备 OTA 状态更新 - deviceId: {}, state: {}, progress: {}", deviceId, state, progress);
    }
}