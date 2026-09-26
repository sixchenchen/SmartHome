package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.DeviceCommand;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public interface DeviceCommandService extends IService<DeviceCommand> {

    /**
     * 仅入库：生成指令记录，状态为"待下发"
     * <p>MQTT 发送由 web 层负责调用</p>
     *
     * @return 完整的 DeviceCommand（含 commandId 和 id）
     */
    DeviceCommand prepareCommand(String deviceId, String commandType,
                                 Map<String, Object> payload,
                                 String operator, String source, int expireSeconds);

    /**
     * 标记为已下发（MQTT 发送成功后由 web 层调用）
     */
    void markAsSent(Long id);

    /**
     * 增加重试次数（MQTT 重试成功后由 web 层调用）
     */
    void incrementRetryCount(Long id);

    /**
     * 查询待下发指令（web 层调度器调用）
     */
    List<DeviceCommand> listPending(int limit);

    /**
     * 查询可重试指令（web 层调度器调用）
     */
    List<DeviceCommand> listRetryable(int timeoutSeconds, int limit);

    /**
     * 查询超时未完成指令（web 层调度器调用）
     */
    List<DeviceCommand> listExpired();

    /**
     * 批量标记为超时
     */
    int markExpiredCommands();

    /**
     * 处理设备 ACK
     */
    void handleAck(String commandId, boolean success, Map<String, Object> payload, String errorMsg);

    /**
     * 按 commandId 查询
     */
    DeviceCommand getByCommandId(String commandId);

    /**
     * 按设备 + 状态查询
     */
    List<DeviceCommand> listByDeviceAndStatus(String deviceId, Integer status);

    /**
     * 按时间段查询
     */
    List<DeviceCommand> listByTimeRange(String deviceId, LocalDateTime start, LocalDateTime end);

    /**
     * 取消指令
     */
    boolean cancelCommand(Long id, String operator);

    /**
     * 清理历史
     */
    int cleanHistory(int retentionDays);

    /**
     * 状态统计
     */
    Map<Integer, Long> countByStatus(String deviceId);

    /**
     * 类型统计
     */
    List<Map<String, Object>> countByType(LocalDateTime start, LocalDateTime end);
}