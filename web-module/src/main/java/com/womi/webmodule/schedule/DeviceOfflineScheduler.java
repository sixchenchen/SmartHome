package com.womi.webmodule.schedule;

import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.businessmodule.service.device.DeviceSlaveDataService;
import com.womi.commonmodule.enums.DeviceOfflineReason;
import com.womi.commonmodule.constants.ScheduleConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 心跳超时扫描
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DeviceOfflineScheduler {

    private final DeviceInfoService deviceInfoService;
    private final DeviceSlaveDataService deviceSlaveDataService;

    /**
     * 每 30 秒扫描一次心跳超时设备
     */
    @SchedulerLock(name = "DeviceOfflineScheduler_scanHeartbeatTimeout",
            lockAtMostFor = "1m", lockAtLeastFor = "10s")
    @Scheduled(fixedDelay = ScheduleConstants.HEARTBEAT_SCAN_FIXED_DELAY)
    public void scanHeartbeatTimeout() {
        try {
            int timeoutSeconds = ScheduleConstants.HEARTBEAT_TIMEOUT_SECONDS;
            // 1. 查出超时设备
            List<DeviceInfo> timeoutDevices = deviceInfoService.listHeartbeatTimeoutDevices(timeoutSeconds);
            if (timeoutDevices.isEmpty()) {
                return;
            }

            log.warn("发现心跳超时设备 - 共 {} 台", timeoutDevices.size());

            // 2. 逐个处理
            for (DeviceInfo device : timeoutDevices) {
                try {
                    handleTimeoutDevice(device);
                } catch (Exception e) {
                    log.error("处理心跳超时设备失败 - deviceId: {}", device.getDeviceId(), e);
                }
            }

        } catch (Exception e) {
            log.error("心跳超时扫描任务异常", e);
        }
    }

    /**
     * 处理单个超时设备
     */
    /**
     * 处理单个超时设备
     */
    private void handleTimeoutDevice(DeviceInfo device) {
        String deviceId = device.getDeviceId();
        LocalDateTime lastHeartbeat = device.getLastHeartbeatTime();
        boolean markedOffline = deviceInfoService.markOfflineIfTimeout(
                deviceId,
                DeviceOfflineReason.HEARTBEAT_TIMEOUT.getCode(),
                lastHeartbeat);

        if (markedOffline) {
            // 只有真正成功标记离线的，才记录日志并清理从机数据
            log.warn("设备心跳超时标记离线 - deviceId: {}, lastHeartbeat: {}", deviceId, lastHeartbeat);

            int cleared = deviceSlaveDataService.clearByDeviceId(deviceId);
            if (cleared > 0) {
                log.info("清空离线设备的从机数据 - deviceId: {}, 数量: {}", deviceId, cleared);
            }
        } else {
            // 影响行数为 0：说明在扫描和更新期间，设备发来了心跳续命了！
            log.info("设备已被心跳抢占，放弃标记离线 - deviceId: {}", deviceId);
        }
    }
}