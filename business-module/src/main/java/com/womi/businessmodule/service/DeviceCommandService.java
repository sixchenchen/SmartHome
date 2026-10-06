package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.DeviceCommand;

import java.util.List;
import java.util.Map;

public interface DeviceCommandService extends IService<DeviceCommand> {

    /**
     * 准备一条待下发指令
     */
    DeviceCommand prepareCommand(String deviceId, String action, String target,
                                 Integer channel, Map<String, Object> params,
                                 String operator, String source, int expireSeconds);

    /**
     * 标记已发送
     */
    void markAsSent(Long id);

    /**
     * 增加重试次数
     */
    void incrementRetryCount(Long id);

    /**
     * 处理 ACK 回执
     */
    void handleAck(String commandId, boolean success, Map<String, Object> payload, String errorMsg);

    /**
     * 查询待下发指令
     */
    List<DeviceCommand> listPending(int limit);

    /**
     * 查询需要重试的指令
     */
    List<DeviceCommand> listRetryable(int timeoutSeconds, int limit);

    /**
     * 查询已过期指令
     */
    List<DeviceCommand> listExpired();

    /**
     * 根据 commandId 查询
     */
    DeviceCommand getByCommandId(String commandId);

    /**
     * 查询设备的指令列表
     */
    List<DeviceCommand> listByDeviceAndStatus(String deviceId, Integer status);

    /**
     * 取消指令
     */
    boolean cancelCommand(Long id, String operator);

    /**
     * 标记超时指令
     */
    int markExpiredCommands();

    /**
     * 清理历史指令
     */
    int cleanHistory(int retentionDays);
}