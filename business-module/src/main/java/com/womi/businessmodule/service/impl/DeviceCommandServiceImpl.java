package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.womi.businessmodule.mapper.DeviceCommandMapper;
import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.service.DeviceCommandService;
import com.womi.commonmodule.enums.CommandStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceCommandServiceImpl
        extends ServiceImpl<DeviceCommandMapper, DeviceCommand>
        implements DeviceCommandService {

    private final ObjectMapper objectMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceCommand prepareCommand(String deviceId, String action, String target,
                                        Integer channel, Map<String, Object> params,
                                        String operator, String source, int expireSeconds) {
        if (deviceId == null || action == null || target == null) {
            throw new IllegalArgumentException("deviceId/action/target 不能为空");
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
        cmd.setQos(1);
        cmd.setRetain(0);
        cmd.setStatus(CommandStatus.PENDING.getCode());
        cmd.setRetryCount(0);
        cmd.setMaxRetry(3);
        cmd.setOperator(operator != null ? operator : "system");
        cmd.setSource(source != null ? source : "WEB");
        cmd.setExpireTime(now.plusSeconds(expireSeconds > 0 ? expireSeconds : 30));

        save(cmd);
        log.info("指令已入库 - commandId: {}, deviceId: {}, action: {}, target: {}",
                commandId, deviceId, action, target);
        return cmd;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void markAsSent(Long id) {
        baseMapper.markAsSent(id, LocalDateTime.now());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void incrementRetryCount(Long id) {
        baseMapper.incrementRetryCount(id, LocalDateTime.now());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleAck(String commandId, boolean success, Map<String, Object> payload, String errorMsg) {
        DeviceCommand cmd = baseMapper.selectByCommandId(commandId);
        if (cmd == null) {
            log.warn("收到未知指令的 ACK - commandId: {}", commandId);
            return;
        }
        if (cmd.getStatus() != null
                && (cmd.getStatus() == CommandStatus.SUCCESS.getCode()
                || cmd.getStatus() == CommandStatus.FAILED.getCode()
                || cmd.getStatus() == CommandStatus.TIMEOUT.getCode()
                || cmd.getStatus() == CommandStatus.CANCELLED.getCode())) {
            log.debug("指令已处于终态，忽略 ACK - commandId: {}, status: {}", commandId, cmd.getStatus());
            return;
        }

        String responseJson = null;
        if (payload != null) {
            try {
                responseJson = objectMapper.writeValueAsString(payload);
            } catch (Exception e) {
                log.error("序列化响应失败", e);
            }
        }

        LocalDateTime now = LocalDateTime.now();
        if (success) {
            baseMapper.markAsSuccess(commandId, now, responseJson);
            log.info("指令执行成功 - commandId: {}", commandId);
        } else {
            baseMapper.markAsFailed(commandId, now,
                    errorMsg != null ? errorMsg : "UNKNOWN_ERROR");
            log.warn("指令执行失败 - commandId: {}, error: {}", commandId, errorMsg);
        }
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
        LambdaQueryWrapper<DeviceCommand> wrapper = new LambdaQueryWrapper<DeviceCommand>()
                .eq(DeviceCommand::getDeviceId, deviceId)
                .eq(status != null, DeviceCommand::getStatus, status)
                .orderByDesc(DeviceCommand::getCreateTime);
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
        List<Integer> finalStatus = Arrays.asList(
                CommandStatus.SUCCESS.getCode(), CommandStatus.FAILED.getCode(),
                CommandStatus.TIMEOUT.getCode(), CommandStatus.CANCELLED.getCode());
        LambdaQueryWrapper<DeviceCommand> wrapper = new LambdaQueryWrapper<DeviceCommand>()
                .lt(DeviceCommand::getUpdateTime, before)
                .in(DeviceCommand::getStatus, finalStatus);
        int deleted = baseMapper.delete(wrapper);
        if (deleted > 0) log.info("清理历史指令 - 共 {} 条", deleted);
        return deleted;
    }
}