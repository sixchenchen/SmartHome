package com.womi.webmodule.schedule;

import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.service.CommandSender;
import com.womi.businessmodule.service.DeviceCommandService;
import com.womi.commonmodule.enums.CommandStatus;
import com.womi.webmodule.schedule.constants.ScheduleConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

import static com.womi.commonmodule.constants.CommandConstants.ERR_TIMEOUT_RETRY_EXCEEDED;

@Slf4j
@Component
@RequiredArgsConstructor
public class CommandScheduler {

    private final DeviceCommandService deviceCommandService;
    private final CommandSender commandSender;

    /**
     * 兜底扫描：立即下发失败的命令PENDING，每 2 秒扫一次
     */
    @Scheduled(fixedDelay = ScheduleConstants.DISPATCH_FIXED_DELAY)
    public void dispatchPending() {
        List<DeviceCommand> pending = deviceCommandService.listStalePending(
                ScheduleConstants.DISPATCH_MIN_WAIT_SECONDS,
                ScheduleConstants.BATCH_SIZE);
        if (pending.isEmpty()) {
            return;
        }

        log.info("兜底扫描到 {} 条待下发指令", pending.size());

        for (DeviceCommand command : pending) {
            try {
                // 重试次数超上限 → 标记失败
                if (command.getRetryCount() >= ScheduleConstants.MAX_RETRY) {
                    deviceCommandService.updateStatus(
                            command.getId(),
                            CommandStatus.FAILED.getCode(),
                            ERR_TIMEOUT_RETRY_EXCEEDED);
                    log.warn("指令重试次数超限，标记失败 - commandId: {}", command.getCommandId());
                    continue;
                }

                // 发送（只做一件事：要么成功更新为 SENT，要么失败保持 PENDING）
                commandSender.send(command);
                deviceCommandService.updateStatus(
                        command.getId(),
                        CommandStatus.SENT.getCode(),
                        null);
                deviceCommandService.incrementRetryCount(command.getId());

                log.info("兜底下发成功 - commandId: {}, retry: {}", command.getCommandId(), command.getRetryCount() + 1);
            } catch (Exception e) {
                log.error("兜底下发失败 - commandId: {}, error: {}",
                        command.getCommandId(), e.getMessage(), e);
            }
        }
    }

    /**
     * 超时重试：已 SENT 但 30 秒内没 ACK 的指令，每 5 秒扫一次
     */
    @Scheduled(fixedDelay = ScheduleConstants.RETRY_FIXED_DELAY)
    public void retryTimeout() {
        List<DeviceCommand> retryable = deviceCommandService.listRetryable(
                ScheduleConstants.RETRY_TIMEOUT_SECONDS,
                ScheduleConstants.BATCH_SIZE);
        if (retryable.isEmpty()) {
            return;
        }
        log.info("扫描到 {} 条超时未 ACK 指令", retryable.size());
        for (DeviceCommand command : retryable) {
            try {
                commandSender.send(command);
                deviceCommandService.incrementRetryCount(command.getId());
                log.info("超时重试成功 - commandId: {}, 第 {}/{} 次", command.getCommandId(), command.getRetryCount() + 1, command.getMaxRetry());
                log.info("超时重试参数 : {}", command.getParams());
            } catch (Exception e) {
                log.error("超时重试失败 - commandId: {}, error: {}",command.getCommandId(), e.getMessage(), e);
            }
        }
    }

    /**
     * 标记过期指令：PENDING/SENT 但已超过 expire_time，每 60 秒一次
     */
    @Scheduled(fixedDelay = ScheduleConstants.MARK_EXPIRED_FIXED_DELAY)
    public void markExpired() {
        try {
            int count = deviceCommandService.markExpiredCommands();
            if (count > 0) {
                log.info("标记过期指令 - 共 {} 条", count);
            }
        } catch (Exception e) {
            log.error("标记过期指令失败", e);
        }
    }

    @Scheduled(fixedDelay = ScheduleConstants.OTA_EXPIRED_FIXED_DELAY)
    public void markOtaExpired() {
        try {
            int count = deviceCommandService.markOtaExpiredCommands();
            if (count > 0) {
                log.info("标记过期 OTA 指令 - 共 {} 条", count);
            }
        } catch (Exception e) {
            log.error("标记过期 OTA 指令失败", e);
        }
    }

    /**
     * 每天凌晨 2 点清理 30 天前的历史指令
     */
    @Scheduled(cron = ScheduleConstants.CLEAN_HISTORY_CRON)
    public void cleanHistory() {
        try {
            int count = deviceCommandService.cleanHistory(ScheduleConstants.CLEAN_RETENTION_DAYS);
            if (count > 0) {
                log.info("清理历史指令 - 共 {} 条", count);
            }
        } catch (Exception e) {
            log.error("清理历史指令失败", e);
        }
    }
}