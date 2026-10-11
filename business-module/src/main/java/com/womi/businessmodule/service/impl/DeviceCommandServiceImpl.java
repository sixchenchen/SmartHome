package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.womi.businessmodule.mapper.DeviceCommandMapper;
import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.service.DeviceCommandService;
import com.womi.businessmodule.vo.CommandStatsVO;
import com.womi.commonmodule.constants.CommandConstants;
import com.womi.commonmodule.enums.CommandStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceCommandServiceImpl extends ServiceImpl<DeviceCommandMapper, DeviceCommand> implements DeviceCommandService {

    private final ObjectMapper objectMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceCommand prepareCommand(String deviceId, String action, String target, Integer channel, Map<String, Object> params, String operator, String source, int expireSeconds) {
        if (deviceId == null || action == null || target == null) {
            throw new BusinessException(ErrorCode.PARAM_EMPTY);
        }
        String commandId = UUID.randomUUID().toString();
        LocalDateTime now = LocalDateTime.now();

        DeviceCommand cmd = new DeviceCommand();
        cmd.setCommandId(commandId);
        cmd.setDeviceId(deviceId);
        cmd.setAction(action);
        cmd.setTarget(target);
        cmd.setChannel(channel);
        cmd.setParams(params != null ? params : Collections.emptyMap());
        cmd.setQos(CommandConstants.DEFAULT_QOS);
        cmd.setRetain(CommandConstants.DEFAULT_RETAIN);
        cmd.setStatus(CommandStatus.PENDING.getCode());
        cmd.setRetryCount(0);
        cmd.setMaxRetry(CommandConstants.DEFAULT_MAX_RETRY);
        cmd.setOperator(operator != null ? operator : CommandConstants.DEFAULT_OPERATOR);
        cmd.setSource(source != null ? source : CommandConstants.SOURCE_WEB);
        cmd.setExpireTime(now.plusSeconds(expireSeconds > 0 ? expireSeconds : CommandConstants.DEFAULT_EXPIRE_SECONDS));

        save(cmd);
        log.info("指令已入库 - commandId: {}, deviceId: {}, action: {}, target: {}, params: {}", commandId, deviceId, action, target, params);
        return cmd;
    }

    @Override
    public void updateStatus(Long id, Integer status, String errorMsg) {
        DeviceCommand update = new DeviceCommand();
        update.setId(id);
        update.setStatus(status);

        if (errorMsg != null) {
            update.setErrorMsg(errorMsg);
        }

        LocalDateTime now = LocalDateTime.now();
        if (status == CommandStatus.SENT.getCode()) {
            // 已发出：记录发送时间
            update.setSendTime(now);
        } else if (status == CommandStatus.SUCCESS.getCode() || status == CommandStatus.FAILED.getCode() || status == CommandStatus.TIMEOUT.getCode()) {
            // 终态：记录响应时间
            update.setAckTime(now);
        }
        updateById(update);
        log.debug("指令状态更新 - id: {}, status: {}, errorMsg: {}", id, status, errorMsg);
    }


    @Override
    @Transactional(rollbackFor = Exception.class)
    public void incrementRetryCount(Long id) {
        baseMapper.incrementRetryCount(id, LocalDateTime.now());
    }

    @Override
    public List<DeviceCommand> listStalePending(int minWaitSeconds, int batchSize) {
        return baseMapper.selectStalePendingCommands(minWaitSeconds, batchSize);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleAck(String commandId, boolean success, Map<String, Object> payload, String errorMsg) {
        // 1. 参数校验
        if (commandId == null || commandId.isBlank()) {
            log.warn("ACK commandId 为空");
            return;
        }

        // 2. 查询指令
        DeviceCommand command = getByCommandId(commandId);
        if (command == null) {
            log.warn("ACK 对应的指令不存在 - commandId: {}", commandId);
            return;
        }

        // 3. 幂等：只处理 SENT 状态，其他状态全部忽略
        if (command.getStatus() == null || !command.getStatus().equals(CommandStatus.SENT.getCode())) {
            log.debug("ACK 状态非 SENT，忽略 - commandId: {}, status: {}", commandId, command.getStatus());
            return;
        }

        // 4. 计算新状态
        Integer newStatus = success ? CommandStatus.SUCCESS.getCode() : CommandStatus.FAILED.getCode();

        String finalErrorMsg = success ? null : (errorMsg != null && !errorMsg.isBlank() ? errorMsg : CommandConstants.DEFAULT_FAIL_MSG);

        // 5. 更新状态（内部会更新 ack_time）
        updateStatus(command.getId(), newStatus, finalErrorMsg);

        // 6. 更新 response_payload（如果有）
        if (payload != null && !payload.isEmpty()) {
            DeviceCommand update = new DeviceCommand();
            update.setId(command.getId());
            update.setResponsePayload(payload);
            updateById(update);
        }

        log.info("设备 ACK 处理完成 - commandId: {}, deviceId: {}, success: {}, newStatus: {}", commandId, command.getDeviceId(), success, newStatus);
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
        LambdaQueryWrapper<DeviceCommand> wrapper = new LambdaQueryWrapper<DeviceCommand>().eq(DeviceCommand::getDeviceId, deviceId).eq(status != null, DeviceCommand::getStatus, status).orderByDesc(DeviceCommand::getCreateTime);
        return list(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean cancelCommand(Long id, String operator) {
        DeviceCommand cmd = getById(id);
        if (cmd == null) return false;
        if (cmd.getStatus() != null && cmd.getStatus() >= CommandStatus.SUCCESS.getCode()) {
            log.warn("指令已进入终态，无法取消 - id: {}, status: {}", id, cmd.getStatus());
            return false;
        }
        cmd.setStatus(CommandStatus.CANCELLED.getCode());
        cmd.setErrorMsg("用户取消");
        cmd.setOperator(operator);
        return updateById(cmd);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int markExpiredCommands() {
        List<DeviceCommand> expired = baseMapper.selectExpiredCommands(LocalDateTime.now());
        if (expired.isEmpty()) return 0;
        List<Long> ids = new ArrayList<>();
        for (DeviceCommand c : expired) ids.add(c.getId());
        int updated = baseMapper.batchUpdateStatus(ids, CommandStatus.TIMEOUT.getCode());
        log.warn("标记超时指令 - 共 {} 条", updated);
        return updated;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int cleanHistory(int retentionDays) {
        LocalDateTime before = LocalDateTime.now().minusDays(retentionDays);
        List<Integer> finalStatus = Arrays.asList(CommandStatus.SUCCESS.getCode(), CommandStatus.FAILED.getCode(), CommandStatus.TIMEOUT.getCode(), CommandStatus.CANCELLED.getCode());
        LambdaQueryWrapper<DeviceCommand> wrapper = new LambdaQueryWrapper<DeviceCommand>().lt(DeviceCommand::getUpdateTime, before).in(DeviceCommand::getStatus, finalStatus);
        int deleted = baseMapper.delete(wrapper);
        if (deleted > 0) log.info("清理历史指令 - 共 {} 条", deleted);
        return deleted;
    }

    @Override
    public CommandStatsVO statsByDevice(String deviceId) {
        // 一次性查出该设备的所有指令，在内存里分组统计
        List<DeviceCommand> commands = list(new LambdaQueryWrapper<DeviceCommand>().eq(DeviceCommand::getDeviceId, deviceId).select(DeviceCommand::getStatus));

        CommandStatsVO vo = new CommandStatsVO();
        vo.setPending(0L);
        vo.setSent(0L);
        vo.setSuccess(0L);
        vo.setFailed(0L);
        vo.setTimeout(0L);
        vo.setCancelled(0L);

        for (DeviceCommand cmd : commands) {
            CommandStatus status = CommandStatus.fromCode(cmd.getStatus());
            if (status == null) {
                continue;
            }
            switch (status) {
                case PENDING -> vo.setPending(vo.getPending() + 1);
                case SENT -> vo.setSent(vo.getSent() + 1);
                case SUCCESS -> vo.setSuccess(vo.getSuccess() + 1);
                case FAILED -> vo.setFailed(vo.getFailed() + 1);
                case TIMEOUT -> vo.setTimeout(vo.getTimeout() + 1);
                case CANCELLED -> vo.setCancelled(vo.getCancelled() + 1);
            }
        }

        long total = commands.size();
        vo.setTotal(total);
        return vo;
    }
}