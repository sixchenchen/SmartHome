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
        int rows = baseMapper.markOfflineByDeviceId(deviceId, reason.getCode());
        if (rows == 0) {
            log.debug("设备已离线或不存在，跳过 - deviceId: {}", deviceId);
        } else {
            log.info("设备离线 - deviceId: {}, reason: {}", deviceId, reason.getCode());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateHeartbeat(String deviceId, Long uptime, String payload) {
        int rows = baseMapper.updateHeartbeatByDeviceId(deviceId, uptime, payload);
        if (rows == 0) {
            log.warn("心跳更新失败，设备不存在 - deviceId: {}", deviceId);
        }
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

        int count = 0;
        for (DeviceInfo device : devices) {
            try {
                // 仅当 online=1 且 last_heartbeat_time 未变时才标记
                int rows = baseMapper.markOfflineIfTimeout(
                        device.getDeviceId(),
                        OfflineReason.HEARTBEAT_TIMEOUT.getCode(),
                        device.getLastHeartbeatTime());

                if (rows > 0) {
                    count++;
                    log.warn("设备心跳超时标记离线 - deviceId: {}, lastHeartbeat: {}", device.getDeviceId(), device.getLastHeartbeatTime());
                } else {
                    log.debug("设备已被心跳抢占，跳过离线标记 - deviceId: {}", device.getDeviceId());
                }
            } catch (Exception e) {
                log.error("标记离线失败 - deviceId: {}", device.getDeviceId(), e);
            }
        }
        if (count > 0) {
            log.warn("心跳超时标记离线 - 共 {} 台", count);
        }
        return count;
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
        info.setOtaUpdateTime(LocalDateTime.now());
        updateById(info);

        log.info("设备 OTA 状态更新 - deviceId: {}, state: {}, progress: {}", deviceId, state, progress);
    }
}