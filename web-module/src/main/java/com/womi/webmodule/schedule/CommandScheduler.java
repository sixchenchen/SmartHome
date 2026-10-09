package com.womi.webmodule.schedule;

import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.service.CommandSender;
import com.womi.businessmodule.service.DeviceCommandService;
import com.womi.webmodule.mqtt.core.MqttPublisher;
import com.womi.webmodule.schedule.constants.ScheduleConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class CommandScheduler {

    private final DeviceCommandService deviceCommandService;
    private final CommandSender commandSender;

    /**
     * 每 5 秒扫描待下发指令
     */
    @Scheduled(fixedDelay = ScheduleConstants.DISPATCH_FIXED_DELAY)
    public void dispatchPending() {
        List<DeviceCommand> pending = deviceCommandService.listPending(ScheduleConstants.BATCH_SIZE);
        if (pending.isEmpty()) return;

        for (DeviceCommand command : pending) {
            try {
                commandSender.send(command);
                deviceCommandService.markAsSent(command.getId());
                log.info("定时下发成功 - commandId: {}", command.getCommandId());
            } catch (Exception e) {
                log.error("定时下发失败 - commandId: {}", command.getCommandId(), e);
            }
        }
    }

    /**
     * 每 30 秒检查一次超时未 ACK 的指令并重试
     */
    @Scheduled(fixedDelay = ScheduleConstants.RETRY_FIXED_DELAY)
    public void retryTimeout() {
        List<DeviceCommand> retryable = deviceCommandService.listRetryable(
                ScheduleConstants.RETRY_TIMEOUT_SECONDS,
                ScheduleConstants.BATCH_SIZE);
        if (retryable.isEmpty()) return;

        for (DeviceCommand command : retryable) {
            try {
                commandSender.send(command);
                deviceCommandService.incrementRetryCount(command.getId());
                log.info("指令重试成功 - commandId: {}, 第 {} 次",
                        command.getCommandId(), command.getRetryCount() + 1);
            } catch (Exception e) {
                log.error("指令重试失败 - commandId: {}", command.getCommandId(), e);
            }
        }
    }

    /**
     * 每 60 秒标记一次过期指令
     */
    @Scheduled(fixedDelay = ScheduleConstants.MARK_EXPIRED_FIXED_DELAY)
    public void markExpired() {
        try {
            deviceCommandService.markExpiredCommands();
        } catch (Exception e) {
            log.error("标记过期指令失败", e);
        }
    }

    /**
     * 每天凌晨 2 点清理 30 天前的历史指令
     */
    @Scheduled(cron = ScheduleConstants.CLEAN_HISTORY_CRON)
    public void cleanHistory() {
        try {
            deviceCommandService.cleanHistory(ScheduleConstants.CLEAN_RETENTION_DAYS);
        } catch (Exception e) {
            log.error("清理历史指令失败", e);
        }
    }
}