package com.womi.webmodule.service.ops;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.model.device.DeviceAlertRecord;
import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.vo.DashboardSummaryVO;

import java.time.LocalDateTime;

/**
 * 管理端运维服务（概览、指令、告警、审计）
 */
public interface AdminOpsService {

    DashboardSummaryVO getDashboardSummary();

    Page<DeviceCommand> pageCommands(Integer pageNum, Integer pageSize, String deviceId, Integer status,
                                    LocalDateTime from, LocalDateTime to);

    Page<DeviceAlertRecord> pageAlerts(Integer pageNum, Integer pageSize, String deviceId, Integer status,
                                       Integer level, LocalDateTime from, LocalDateTime to);

    Page<DeviceCommand> pageAuditLogs(Integer pageNum, Integer pageSize, String deviceId, String operator,
                                      String source, LocalDateTime from, LocalDateTime to);

    /**
     * 处理告警
     */
    void handleAlert(Long id, Integer status, String operator);
}
