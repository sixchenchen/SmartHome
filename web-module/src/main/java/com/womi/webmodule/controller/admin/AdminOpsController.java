package com.womi.webmodule.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.AlertHandleRequest;
import com.womi.businessmodule.model.device.DeviceAlertRecord;
import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.vo.DashboardSummaryVO;
import com.womi.commonmodule.constants.PageConstants;
import com.womi.commonmodule.constants.PermissionConstants;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.ops.AdminOpsService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminOpsController {

    private final AdminOpsService adminOpsService;

    /**
     * 首页概览
     */
    @GetMapping("/dashboard/summary")
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_LIST + "')")
    public ApiResponse<DashboardSummaryVO> getDashboardSummary() {
        return ApiResponse.success(adminOpsService.getDashboardSummary());
    }

    /**
     * 全局指令列表
     */
    @GetMapping("/commands")
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_LIST + "')")
    public ApiResponse<Page<DeviceCommand>> pageCommands(
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize,
            @RequestParam(required = false) String deviceId,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime to) {
        return ApiResponse.success(adminOpsService.pageCommands(pageNum, pageSize, deviceId, status, from, to));
    }

    /**
     * 全局告警列表
     */
    @GetMapping("/alerts")
    @PreAuthorize("hasAuthority('" + PermissionConstants.ALERT_LIST + "')")
    public ApiResponse<Page<DeviceAlertRecord>> pageAlerts(
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize,
            @RequestParam(required = false) String deviceId,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Integer level,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime to) {
        return ApiResponse.success(adminOpsService.pageAlerts(pageNum, pageSize, deviceId, status, level, from, to));
    }

    /**
     * 处理告警（1-已确认 2-已解决）
     */
    @PutMapping("/alerts/{id}/status")
    @PreAuthorize("hasAuthority('" + PermissionConstants.ALERT_HANDLE + "')")
    public ApiResponse<Void> handleAlert(@PathVariable Long id,
                                         @RequestBody @Valid AlertHandleRequest request,
                                         Principal principal) {
        adminOpsService.handleAlert(id, request.getStatus(), principal.getName());
        return ApiResponse.success(null);
    }

    /**
     * 操作审计（基于指令流水：操作人/来源/设备/时间）
     */
    @GetMapping("/audit-logs")
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_LIST + "')")
    public ApiResponse<Page<DeviceCommand>> pageAuditLogs(
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize,
            @RequestParam(required = false) String deviceId,
            @RequestParam(required = false) String operator,
            @RequestParam(required = false) String source,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime to) {
        return ApiResponse.success(adminOpsService.pageAuditLogs(
                pageNum, pageSize, deviceId, operator, source, from, to));
    }
}
