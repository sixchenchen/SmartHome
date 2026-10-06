package com.womi.webmodule.schedule;

import com.womi.businessmodule.model.DeviceInfo;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.businessmodule.service.DeviceSlaveDataService;
import com.womi.commonmodule.enums.OfflineReason;
import com.womi.webmodule.schedule.constants.ScheduleConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
    private void handleTimeoutDevice(DeviceInfo device) {
        String deviceId = device.getDeviceId();
        LocalDateTime lastHeartbeat = device.getLastHeartbeatTime();

        log.warn("设备心跳超时 - deviceId: {}, lastHeartbeat: {}, 超时: {}秒",
                deviceId, lastHeartbeat, ScheduleConstants.HEARTBEAT_TIMEOUT_SECONDS);

        // 1. 标记设备离线
        deviceInfoService.markOffline(deviceId, OfflineReason.HEARTBEAT_TIMEOUT);

        // 2. 清空该设备所有从机数据（主机离线，从机也视为离线）
        int cleared = deviceSlaveDataService.clearByDeviceId(deviceId);
        if (cleared > 0) {
            log.info("清空离线设备的从机数据 - deviceId: {}, 数量: {}", deviceId, cleared);
        }
    }
}