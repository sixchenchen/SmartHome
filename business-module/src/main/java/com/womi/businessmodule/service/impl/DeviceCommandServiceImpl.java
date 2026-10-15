package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.DeviceCommandMapper;
import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.model.DeviceInfo;
import com.womi.businessmodule.service.DeviceCommandService;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.businessmodule.vo.CommandStatsVO;
import com.womi.commonmodule.constants.DeviceCommandConstants;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.constants.DeviceOtaStateConstants;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceCommandServiceImpl
        extends ServiceImpl<DeviceCommandMapper, DeviceCommand>
        implements DeviceCommandService {

    /** 终态集合：进入后不再变化 */
    private static final List<Integer> FINAL_STATUSES = List.of(
            DeviceCommandStatus.SUCCESS.getCode(),
            DeviceCommandStatus.FAILED.getCode(),
            DeviceCommandStatus.TIMEOUT.getCode(),
            DeviceCommandStatus.CANCELLED.getCode());

    private final DeviceInfoService deviceInfoService;

    // ==================== 指令准备 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceCommand prepareCommand(String deviceId, String action, String target,
                                        Integer channel, Map<String, Object> params,
                                        String operator, String source, int expireSeconds) {
        if (deviceId == null || action == null || target == null) {
            throw new BusinessException(ErrorCode.PARAM_EMPTY);
        }

        String commandId = UUID.randomUUID().toString();
        LocalDateTime now = LocalDateTime.now();
        int actualExpire = expireSeconds > 0
                ? expireSeconds : DeviceCommandConstants.DEFAULT_EXPIRE_SECONDS;

        DeviceCommand cmd = DeviceCommand.builder()
                .commandId(commandId)
                .deviceId(deviceId)
                .action(action)
                .target(target)
                .channel(channel)
                .params(params != null ? params : Collections.emptyMap())
                .qos(DeviceCommandConstants.DEFAULT_QOS)
                .retain(DeviceCommandConstants.DEFAULT_RETAIN)
                .status(DeviceCommandStatus.PENDING.getCode())
                .retryCount(0)
                .maxRetry(DeviceCommandConstants.DEFAULT_MAX_RETRY)
                .operator(operator != null ? operator : DeviceCommandConstants.DEFAULT_OPERATOR)
                .source(source != null ? source : DeviceCommandConstants.SOURCE_WEB)
                .expireTime(now.plusSeconds(actualExpire))
                .build();

        save(cmd);
        log.info("指令已入库 - commandId: {}, deviceId: {}, action: {}, target: {}, params: {}",
                commandId, deviceId, action, target, params);
        return cmd;
    }

    // ==================== 状态更新 ====================

    @Override
    public void updateStatus(Long id, Integer status, String errorMsg) {
        LocalDateTime now = LocalDateTime.now();

        DeviceCommand update = DeviceCommand.builder()
                .id(id)
                .status(status)
                .errorMsg(errorMsg)
                .sendTime(status == DeviceCommandStatus.SENT.getCode() ? now : null)
                .ackTime(FINAL_STATUSES.contains(status) ? now : null)
                .build();

        updateById(update);
        log.debug("指令状态更新 - id: {}, status: {}, errorMsg: {}", id, status, errorMsg);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void incrementRetryCount(Long id) {
        baseMapper.incrementRetryCount(id, LocalDateTime.now());
    }

    // ==================== ACK 处理（核心重构）====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleAck(String commandId, boolean success,
                          Map<String, Object> payload, String errorMsg) {
        // 1. 查询指令
        DeviceCommand command = getByCommandId(commandId);
        if (command == null) {
            log.warn("ACK 对应的指令不存在 - commandId: {}", commandId);
            return;
        }

        // 2. 决策：根据当前状态 + payload 判断是否需要变更
        AckDecision decision = decideAckTransition(command, success, payload, errorMsg);
        if (decision == null) {
            return;   // 忽略
        }

        // 3. 执行状态更新
        updateStatus(command.getId(), decision.newStatus(), decision.errorMsg());

        // 4. 保存 response_payload
        if (payload != null && !payload.isEmpty()) {
            updateResponsePayload(command.getId(), payload);
        }

        // 5. OTA 最终成功 → 兜底更新 firmware
        if (decision.isOtaFinalAck() && decision.newStatus() == DeviceCommandStatus.SUCCESS.getCode()) {
            updateFirmwareFromAck(command.getDeviceId(), payload);
        }

        log.info("ACK 处理完成 - commandId: {}, 状态 {} → {}, success: {}",
                commandId, command.getStatus(), decision.newStatus(), success);
    }

    /**
     * 决策：判断 ACK 引起的状态转换
     *
     * @return 需要更新时返回 {@link AckDecision}；忽略时返回 {@code null}
     */
    private AckDecision decideAckTransition(DeviceCommand command, boolean success,
                                            Map<String, Object> payload, String errorMsg) {
        Integer current = command.getStatus();
        if (current == null) {
            log.warn("ACK 指令状态为空 - commandId: {}", command.getCommandId());
            return null;
        }

        boolean isOta = DeviceMqttConstants.TARGET_OTA.equals(command.getTarget());
        boolean isAcceptAck = isOta && isOtaAcceptAck(payload);

        // ---------- 情况 1：SENT + OTA 接收确认 → ACCEPTED ----------
        if (current == DeviceCommandStatus.SENT.getCode() && isAcceptAck) {
            log.info("OTA 接收确认 - commandId: {}, deviceId: {}",
                    command.getCommandId(), command.getDeviceId());
            return new AckDecision(DeviceCommandStatus.ACCEPTED.getCode(), null, false);
        }

        // ---------- 情况 2：SENT 或 ACCEPTED + 最终结果 → SUCCESS/FAILED ----------
        if (current == DeviceCommandStatus.SENT.getCode()
                || current == DeviceCommandStatus.ACCEPTED.getCode()) {
            // 排除"ACCEPTED + 重复接收确认"的干扰
            if (current == DeviceCommandStatus.ACCEPTED.getCode() && isAcceptAck) {
                log.debug("重复的 OTA 接收确认 ACK，忽略 - commandId: {}", command.getCommandId());
                return null;
            }

            Integer newStatus = success
                    ? DeviceCommandStatus.SUCCESS.getCode() : DeviceCommandStatus.FAILED.getCode();
            String finalMsg = success ? null : resolveErrorMsg(errorMsg);
            boolean isFinalAck = isOta;
            return new AckDecision(newStatus, finalMsg, isFinalAck);
        }

        // ---------- 情况 3：终态 → 忽略 ----------
        log.debug("ACK 状态非 SENT/ACCEPTED，忽略 - commandId: {}, status: {}",command.getCommandId(), current);
        return null;
    }

    /**
     * 更新 response_payload 字段
     */
    private void updateResponsePayload(Long id, Map<String, Object> payload) {
        DeviceCommand update = DeviceCommand.builder().id(id).responsePayload(payload).build();
        updateById(update);
    }

    /**
     * OTA 最终 ACK 成功时，从 payload.toVersion 同步 device_info.firmware（双保险之一）
     * <p>另一处触发点是 ota_progress 上报 success，两者共用 {@code syncFirmwareIfTarget}，
     * 即使设备重启后没发 online，也能通过最终 ACK 收敛版本号。</p>
     */
    private void updateFirmwareFromAck(String deviceId, Map<String, Object> payload) {
        if (payload == null || payload.isEmpty()) {
            return;
        }
        Object toVersionObj = payload.get(DeviceMqttConstants.FIELD_TO_VERSION);
        if (toVersionObj == null) {
            return;
        }
        try {
            deviceInfoService.syncFirmwareIfTarget(deviceId, toVersionObj.toString());
        } catch (Exception e) {
            // 兜底失败不影响主流程（online 消息还会再更新一次）
            log.error("OTA 最终 ACK 同步固件版本失败 - deviceId: {}, toVersion: {}", deviceId, toVersionObj, e);
        }
    }
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int markOtaExpiredCommands() {
        List<DeviceCommand> expired = baseMapper.selectExpiredOtaCommands(LocalDateTime.now());
        if (expired.isEmpty()) {
            return 0;
        }

        int count = 0;
        for (DeviceCommand command : expired) {
            // 1. 标记指令为 TIMEOUT
            updateStatus(command.getId(), DeviceCommandStatus.TIMEOUT.getCode(), "OTA 指令超时");
            // 2. 联动清理 device_info.ota_state
            clearOtaState(command.getDeviceId());
            count++;
        }
        log.warn("标记过期 OTA 指令 - 共 {} 条", count);
        return count;
    }

    /** 清理 device_info 的 OTA 状态（只在进行中时才清，定向更新避免整行覆盖） */
    private void clearOtaState(String deviceId) {
        DeviceInfo device = deviceInfoService.getByDeviceId(deviceId);
        if (device == null) return;

        String otaState = device.getOtaState();
        if (otaState == null || otaState.isBlank()) return;
        if (DeviceOtaStateConstants.FINAL_STATES.contains(otaState)) return;

        deviceInfoService.clearOtaState(deviceId);
        log.info("清理卡住的 OTA 状态 - deviceId: {}, 原 otaState: {}", deviceId, otaState);
    }

    /**
     * 判断是否是 OTA 的"接收确认" ACK
     */
    private boolean isOtaAcceptAck(Map<String, Object> payload) {
        if (payload == null) {
            return false;
        }
        return DeviceOtaStateConstants.ACCEPTED.equals(payload.get(DeviceMqttConstants.FIELD_OTA_STATE));
    }

    /**
     * 解析失败原因（errorMsg 为空时用默认值）
     */
    private String resolveErrorMsg(String errorMsg) {
        return (errorMsg != null && !errorMsg.isBlank())
                ? errorMsg
                : DeviceCommandConstants.DEFAULT_FAIL_MSG;
    }

    /**
     * ACK 决策结果
     *
     * @param newStatus      新的状态码
     * @param errorMsg       错误信息（成功时为 null）
     * @param isOtaFinalAck  是否为"OTA 最终 ACK"（用于触发 firmware 更新）
     */
    private record AckDecision(Integer newStatus, String errorMsg, boolean isOtaFinalAck) {
    }

    // ==================== 查询方法 ====================

    @Override
    public List<DeviceCommand> listStalePending(int minWaitSeconds, int batchSize) {
        return baseMapper.selectStalePendingCommands(minWaitSeconds, batchSize);
    }

    @Override
    public List<DeviceCommand> listPending(int limit) {
        return baseMapper.selectPendingCommands(limit);
    }

    @Override
    public List<DeviceCommand> listRetryable(int timeoutSeconds, int limit) {
        return baseMapper.selectRetryableCommands(timeoutSeconds, limit);
    }

    @Override
    public List<DeviceCommand> listExpired() {
        return baseMapper.selectExpiredCommands(LocalDateTime.now());
    }

    @Override
    public DeviceCommand getByCommandId(String commandId) {
        return baseMapper.selectByCommandId(commandId);
    }

    @Override
    public List<DeviceCommand> listByDeviceAndStatus(String deviceId, Integer status) {
        return list(new LambdaQueryWrapper<DeviceCommand>()
                .eq(DeviceCommand::getDeviceId, deviceId)
                .eq(status != null, DeviceCommand::getStatus, status)
                .orderByDesc(DeviceCommand::getCreateTime));
    }

    // ==================== 取消 / 过期 / 清理 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean cancelCommand(Long id, String operator) {
        DeviceCommand cmd = getById(id);
        if (cmd == null) {
            return false;
        }
        // 只有中间态才能取消
        DeviceCommandStatus status = DeviceCommandStatus.fromCode(cmd.getStatus());
        if (status == null || status.isFinished()) {
            log.warn("指令已进入终态，无法取消 - id: {}, status: {}", id, cmd.getStatus());
            return false;
        }

        cmd.setStatus(DeviceCommandStatus.CANCELLED.getCode());
        cmd.setErrorMsg(DeviceCommandConstants.ERR_CANCELLED_BY_USER);
        cmd.setOperator(operator);
        return updateById(cmd);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int markExpiredCommands() {
        List<DeviceCommand> expired = baseMapper.selectExpiredCommands(LocalDateTime.now());
        if (expired.isEmpty()) {
            return 0;
        }
        List<Long> ids = expired.stream().map(DeviceCommand::getId).toList();
        int updated = baseMapper.batchUpdateStatus(ids, DeviceCommandStatus.TIMEOUT.getCode());
        log.warn("标记超时指令 - 共 {} 条", updated);
        return updated;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int cleanHistory(int retentionDays) {
        LocalDateTime before = LocalDateTime.now().minusDays(retentionDays);
        int deleted = baseMapper.delete(new LambdaQueryWrapper<DeviceCommand>()
                .lt(DeviceCommand::getUpdateTime, before)
                .in(DeviceCommand::getStatus, FINAL_STATUSES));
        if (deleted > 0) {
            log.info("清理历史指令 - 共 {} 条", deleted);
        }
        return deleted;
    }

    // ==================== 统计 ====================

    @Override
    public CommandStatsVO statsByDevice(String deviceId) {
        List<DeviceCommand> commands = list(new LambdaQueryWrapper<DeviceCommand>()
                .eq(DeviceCommand::getDeviceId, deviceId)
                .select(DeviceCommand::getStatus));

        CommandStatsVO vo = new CommandStatsVO();
        vo.setPending(0L);
        vo.setSent(0L);
        vo.setSuccess(0L);
        vo.setFailed(0L);
        vo.setTimeout(0L);
        vo.setCancelled(0L);

        for (DeviceCommand cmd : commands) {
            DeviceCommandStatus status = DeviceCommandStatus.fromCode(cmd.getStatus());
            if (status == null) continue;
            switch (status) {
                case PENDING   -> vo.setPending(vo.getPending() + 1);
                case SENT      -> vo.setSent(vo.getSent() + 1);
                case SUCCESS   -> vo.setSuccess(vo.getSuccess() + 1);
                case FAILED    -> vo.setFailed(vo.getFailed() + 1);
                case TIMEOUT   -> vo.setTimeout(vo.getTimeout() + 1);
                case CANCELLED -> vo.setCancelled(vo.getCancelled() + 1);
                case ACCEPTED  -> { /* ACCEPTED 暂不计入统计 */ }
            }
        }

        vo.setTotal((long) commands.size());
        return vo;
    }
}