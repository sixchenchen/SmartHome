package com.womi.webmodule.schedule;

import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.businessmodule.service.device.DeviceHeartbeatRecordService;
import com.womi.businessmodule.service.device.DeviceSensorRecordService;
import com.womi.businessmodule.service.device.DeviceStateRecordService;
import com.womi.commonmodule.constants.ScheduleConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 历史数据清理定时任务
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DeviceHistoryDataCleanScheduler {

    private final DeviceSensorRecordService sensorRecordService;
    private final DeviceHeartbeatRecordService heartbeatRecordService;
    private final DeviceCommandService deviceCommandService;
    private final DeviceStateRecordService stateRecordService;

    /**
     * 每天凌晨 3 点清理 7 天前的传感器数据
     */
    @Scheduled(cron = ScheduleConstants.CLEAN_RECORD_CRON)
    public void cleanSensorHistory() {
        try {
            log.info("开始清理过期传感器历史数据...");
            int count = sensorRecordService.cleanHistory(ScheduleConstants.SENSOR_RECORD_RETENTION_DAYS);
            if (count > 0) {
                log.info("传感器历史数据清理完成 - 共 {} 条", count);
            } else {
                log.info("传感器历史数据清理完成 - 无过期数据");
            }
        } catch (Exception e) {
            log.error("清理传感器历史数据失败", e);
        }
    }

    /**
     * 每天凌晨 3 点清理 3 天前的心跳数据
     */
    @Scheduled(cron = ScheduleConstants.CLEAN_RECORD_CRON)
    public void cleanHeartbeatHistory() {
        try {
            log.info("开始清理过期心跳历史数据...");
            int count = heartbeatRecordService.cleanHistory(ScheduleConstants.HEARTBEAT_RECORD_RETENTION_DAYS);
            if (count > 0) {
                log.info("心跳历史数据清理完成 - 共 {} 条", count);
            } else {
                log.info("心跳历史数据清理完成 - 无过期数据");
            }
        } catch (Exception e) {
            log.error("清理心跳历史数据失败", e);
        }
    }

    /**
     * 每天凌晨 2 点清理 30 天前的历史指令
     */
    @Scheduled(cron = ScheduleConstants.CLEAN_HISTORY_CRON)
    public void cleanCommandHistory() {
        try {
            int count = deviceCommandService.cleanHistory(ScheduleConstants.CLEAN_RETENTION_DAYS);
            if (count > 0) {
                log.info("清理历史指令 - 共 {} 条", count);
            }
        } catch (Exception e) {
            log.error("清理历史指令失败", e);
        }
    }

    /**
     * 每天凌晨 3 点清理 30 天前的设备状态轨迹数据
     */
    @Scheduled(cron = ScheduleConstants.CLEAN_RECORD_CRON)
    public void cleanStateHistory() {
        try {
            log.info("开始清理过期设备状态轨迹数据...");
            int count = stateRecordService.cleanHistory(ScheduleConstants.STATE_RECORD_RETENTION_DAYS);
            if (count > 0) {
                log.info("设备状态轨迹清理完成 - 共 {} 条", count);
            } else {
                log.info("设备状态轨迹清理完成 - 无过期数据");
            }
        } catch (Exception e) {
            log.error("清理设备状态轨迹失败", e);
        }
    }
}