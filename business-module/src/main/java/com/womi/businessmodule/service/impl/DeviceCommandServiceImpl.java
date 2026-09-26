package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.womi.businessmodule.mapper.DeviceCommandMapper;
import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.service.DeviceCommandService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceCommandServiceImpl extends ServiceImpl<DeviceCommandMapper, DeviceCommand>
        implements DeviceCommandService {

    /** 注意：这里已经没有任何 MqttPublisher / MqttGateway 的引用！ */
    private final ObjectMapper objectMapper;

    private static final int DEFAULT_EXPIRE_SECONDS = 300;
    private static final int DEFAULT_MAX_RETRY = 3;

    // ==================== 仅入库 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceCommand prepareCommand(String deviceId, String commandType,
                                        Map<String, Object> payload,
                                        String operator, String source, int expireSeconds) {
        if (deviceId == null || commandType == null) {
            throw new IllegalArgumentException("deviceId 和 commandType 不能为空");
        }

        String commandId = UUID.randomUUID().toString();
        LocalDateTime now = LocalDateTime.now();
        int expire = expireSeconds > 0 ? expireSeconds : DEFAULT_EXPIRE_SECONDS;

        DeviceCommand command = new DeviceCommand();
        command.setCommandId(commandId);
        command.setDeviceId(deviceId);
        command.setCommandType(commandType);
        command.setPayload(payload != null ? payload : Collections.emptyMap());
        command.setQos(1);
        command.setRetain(0);
        command.setStatus(0); // 待下发
        command.setRetryCount(0);
        command.setMaxRetry(DEFAULT_MAX_RETRY);
        command.setOperator(operator != null ? operator : "system");
        command.setSource(source != null ? source : "WEB");
        command.setExpireTime(now.plusSeconds(expire));

        save(command);
        log.info("指令已入库待下发 - commandId: {}, deviceId: {}, type: {}",
                commandId, deviceId, commandType);

        return command;
    }

    // ==================== 状态更新（供 web 层调用） ====================

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

    // ==================== 查询（供 web 层调度器调用） ====================

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

    // ==================== ACK 处理 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleAck(String commandId, boolean success, Map<String, Object> payload, String errorMsg) {
        DeviceCommand command = baseMapper.selectByCommandId(commandId);
        if (command == null) {
            log.warn("收到未知指令的 ACK - commandId: {}", commandId);
            return;
        }
        if (command.getStatus() >= 3) {
            log.debug("指令已处于终态，忽略 ACK - commandId: {}, status: {}",
                    commandId, command.getStatus());
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
                    errorMsg != null ? errorMsg : "设备执行失败");
            log.warn("指令执行失败 - commandId: {}, error: {}", commandId, errorMsg);
        }
    }

    // ==================== 查询 ====================

    @Override
    public DeviceCommand getByCommandId(String commandId) {
        return baseMapper.selectByCommandId(commandId);
    }

    @Override
    public List<DeviceCommand> listByDeviceAndStatus(String deviceId, Integer status) {
        return baseMapper.selectByDeviceAndStatus(deviceId, status);
    }

    @Override
    public List<DeviceCommand> listByTimeRange(String deviceId, LocalDateTime start, LocalDateTime end) {
        return baseMapper.selectByTimeRange(deviceId, start, end);
    }

    // ==================== 取消 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean cancelCommand(Long id, String operator) {
        DeviceCommand command = getById(id);
        if (command == null) return false;
        if (command.getStatus() >= 3) {
            log.warn("指令已进入终态，无法取消 - id: {}, status: {}", id, command.getStatus());
            return false;
        }
        return baseMapper.cancelCommand(id, operator) > 0;
    }

    // ==================== 过期标记（纯数据操作） ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int markExpiredCommands() {
        List<DeviceCommand> expired = baseMapper.selectExpiredCommands(LocalDateTime.now());
        if (expired.isEmpty()) return 0;

        List<Long> ids = new ArrayList<>();
        for (DeviceCommand c : expired) {
            ids.add(c.getId());
        }
        int updated = baseMapper.batchUpdateStatus(ids, 5); // 5 = 已超时
        log.warn("标记超时指令 - 共 {} 条", updated);
        return updated;
    }

    // ==================== 清理历史 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int cleanHistory(int retentionDays) {
        LocalDateTime beforeTime = LocalDateTime.now().minusDays(retentionDays);
        List<Integer> finishedStatuses = Arrays.asList(3, 4, 5, 6);
        int deleted = baseMapper.deleteFinishedBefore(beforeTime, finishedStatuses);
        if (deleted > 0) {
            log.info("清理历史指令 - 共 {} 条", deleted);
        }
        return deleted;
    }

    // ==================== 统计 ====================

    @Override
    public Map<Integer, Long> countByStatus(String deviceId) {
        List<Map<String, Object>> rows = baseMapper.countByStatus(deviceId);
        Map<Integer, Long> result = new HashMap<>();
        for (Map<String, Object> row : rows) {
            Integer status = ((Number) row.get("status")).intValue();
            Long count = ((Number) row.get("count")).longValue();
            result.put(status, count);
        }
        return result;
    }

    @Override
    public List<Map<String, Object>> countByType(LocalDateTime start, LocalDateTime end) {
        return baseMapper.countByType(start, end);
    }
}