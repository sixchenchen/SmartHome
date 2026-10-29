package com.womi.webmodule.schedule;

import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.service.common.CommandSender;
import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.commonmodule.constants.DeviceCommandConstants;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.constants.ScheduleConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

import static com.womi.commonmodule.constants.DeviceCommandConstants.ERR_TIMEOUT_RETRY_EXCEEDED;

@Slf4j
@Component
@RequiredArgsConstructor
public class DeviceCommandScheduler {

    private final DeviceCommandService deviceCommandService;
    private final CommandSender commandSender;

    /**
     * 兜底扫描：立即下发失败的命令PENDING，每 2 秒扫一次
     */
    @SchedulerLock(name = "DeviceCommandScheduler_dispatchPending",
            lockAtMostFor = "10s", lockAtLeastFor = "2s")
    @Scheduled(fixedDelay = ScheduleConstants.DISPATCH_FIXED_DELAY)
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
                // 读取指令自身的 maxRetry，如果为空，兜底用默认值
                int maxRetry = command.getMaxRetry() != null ? command.getMaxRetry() : DeviceCommandConstants.DEFAULT_MAX_RETRY;

                if (command.getRetryCount() >= maxRetry) {
                    // 动态填充错误信息中的重试次数
                    String errorMsg = String.format(DeviceCommandConstants.ERR_FALLBACK_RETRY_EXCEEDED, maxRetry);
                    deviceCommandService.updateStatus(
                            command.getId(),
                            DeviceCommandStatus.FAILED.getCode(),
                            errorMsg);
                    log.warn("指令重试次数超限，标记失败 - commandId: {}, maxRetry: {}", command.getCommandId(), maxRetry);
                    continue;
                }

                // 发送（只做一件事：要么成功更新为 SENT，要么失败保持 PENDING）
                commandSender.send(command);
                deviceCommandService.updateStatus(
                        command.getId(),
                        DeviceCommandStatus.SENT.getCode(),
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
    @SchedulerLock(name = "DeviceCommandScheduler_retryTimeout",
            lockAtMostFor = "15s", lockAtLeastFor = "2s")
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
    @SchedulerLock(name = "DeviceCommandScheduler_markExpired",
            lockAtMostFor = "1m", lockAtLeastFor = "5s")
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

    @SchedulerLock(name = "DeviceCommandScheduler_markOtaExpired",
            lockAtMostFor = "1m", lockAtLeastFor = "5s")
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
}