package com.womi.businessmodule.service.device.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.device.DeviceInfoMapper;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.commonmodule.constants.DeviceOtaStateConstants;
import com.womi.commonmodule.enums.DeviceOfflineReason;
import com.womi.commonmodule.utils.JsonUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Slf4j
@Service
public class DeviceInfoServiceImpl
        extends ServiceImpl<DeviceInfoMapper, DeviceInfo>
        implements DeviceInfoService {

    private final JsonUtils jsonUtils;

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
    public void markOnline(String deviceId, String product, String firmware, Map<String, Object> capabilities, Map<String, Object> currentState) {
        DeviceInfo device = getByDeviceId(deviceId);
        if (device == null) {
            log.warn("设备上线失败，设备不存在 - deviceId: {}", deviceId);
            return;
        }

        // 1. 直接给实体对象赋值
        device.setOnline(DeviceConstants.DEVICE_STATUS_ONLINE);
        device.setLastOnlineTime(LocalDateTime.now());
        device.setLastHeartbeatTime(LocalDateTime.now());
        device.setProduct(product);
        device.setOfflineReason(null);

        if (capabilities != null) device.setCapabilities(capabilities);
        if (currentState != null) device.setCurrentState(currentState);
        if (firmware != null) device.setFirmware(firmware);

        // 2. 调用 updateById，完美触发 TypeHandler
        updateById(device);

        log.info("设备上线 - deviceId: {}", deviceId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void markOffline(String deviceId, DeviceOfflineReason reason) {
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
                        DeviceOfflineReason.HEARTBEAT_TIMEOUT.getCode(),
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
     * <p>改为定向字段更新，避免 read-modify-write 整行覆盖导致并发丢失其他字段。</p>
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateOtaState(String deviceId, String state, Integer progress, String version) {
        int rows = baseMapper.updateOtaStateByDeviceId(deviceId, state, progress, version);
        if (rows == 0) {
            log.warn("设备不存在，OTA 状态未更新 - deviceId: {}", deviceId);
            return;
        }
        log.info("设备 OTA 状态更新 - deviceId: {}, state: {}, progress: {}", deviceId, state, progress);
    }

    /**
     * 同步设备固件版本为目标版本
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean syncFirmwareIfTarget(String deviceId, String targetVersion) {
        if (targetVersion == null || targetVersion.isBlank()) {
            return false;
        }
        String version = targetVersion.trim();
        // 定向 + 带前置条件：仅当 firmware 与目标版本不一致时才更新
        int rows = baseMapper.updateFirmwareByDeviceId(deviceId, version);
        if (rows > 0) {
            log.info("OTA 固件版本同步 - deviceId: {}, firmware → {}", deviceId, version);
            return true;
        }
        log.debug("固件版本同步更新完成 - deviceId: {}, version: {}", deviceId, version);
        return false;
    }

    /**
     * 设备上线后的 OTA 结果校验兜底
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void reconcileOtaOnOnline(String deviceId, String reportedFirmware) {
        if (reportedFirmware == null || reportedFirmware.isBlank()) {
            return;
        }
        DeviceInfo device = getByDeviceId(deviceId);
        if (device == null) {
            return;
        }
        String otaState = device.getOtaState();
        String otaVersion = device.getOtaVersion();
        if (otaVersion == null || otaVersion.isBlank()) {
            return;
        }
        // 设备已上报成功，但重启后运行版本与目标版本不一致 → 升级回滚，判定失败
        String version = reportedFirmware.trim();
        if (DeviceOtaStateConstants.SUCCESS.equals(otaState) && !version.equals(otaVersion.trim())) {
            baseMapper.updateOtaStateByDeviceId(deviceId, DeviceOtaStateConstants.FAILED, null, null);
            log.warn("OTA 版本校验不通过，判定升级回滚 - deviceId: {}, running: {}, target: {}", deviceId, version, otaVersion);
        }
    }

    /**
     * 清理设备 OTA 状态（定向更新）
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void clearOtaState(String deviceId) {
        baseMapper.clearOtaStateByDeviceId(deviceId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateSpecificState(String deviceId, String target, Integer channel, Integer state) {
        DeviceInfo device = getByDeviceId(deviceId);
        if (device == null) return;

        // 1. 获取现有的 Map 并创建副本
        Map<String, Object> stateMap = device.getCurrentState();
        if (stateMap == null) {
            stateMap = new HashMap<>();
        } else {
            stateMap = new HashMap<>(stateMap);
        }

        // 2. 组装键名
        String key = target;
        if (channel != null && channel > 0) {
            key = target + "_" + channel;
        }

        // 3. 更新 Map 并赋值给实体
        stateMap.put(key, state);
        device.setCurrentState(stateMap);

        // 4. 调用 updateById（不要传 String，直接传 Map）
        updateById(device);
    }
}