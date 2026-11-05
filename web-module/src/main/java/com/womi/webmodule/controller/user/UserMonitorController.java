package com.womi.webmodule.controller.user;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.model.device.DeviceAlertRecord;
import com.womi.businessmodule.model.device.DeviceEventRecord;
import com.womi.businessmodule.model.device.DeviceSensorRecord;
import com.womi.businessmodule.model.device.DeviceStateRecord;
import com.womi.businessmodule.vo.device.SensorLatestVO;
import com.womi.commonmodule.constants.PageConstants;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.security.SecurityUser;
import com.womi.webmodule.service.device.UserMonitorService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserMonitorController {

    private final UserMonitorService userMonitorService;

    /**
     * 传感器历史数据
     */
    @GetMapping("/devices/{deviceId}/sensors")
    public ApiResponse<Page<DeviceSensorRecord>> pageSensorRecords(
            @AuthenticationPrincipal SecurityUser securityUser,
            @PathVariable String deviceId,
            @RequestParam(required = false) String sensorKey,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime to,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_DETAIL_PAGE_SIZE) Integer pageSize) {
        return ApiResponse.success(userMonitorService.pageSensorRecords(
                securityUser.sysUser().getId(), deviceId, sensorKey, type, from, to, pageNum, pageSize));
    }

    /**
     * 传感器最新值
     */
    @GetMapping("/devices/{deviceId}/sensors/latest")
    public ApiResponse<List<SensorLatestVO>> listLatestSensors(@AuthenticationPrincipal SecurityUser securityUser,
                                                               @PathVariable String deviceId) {
        return ApiResponse.success(userMonitorService.listLatestSensors(securityUser.sysUser().getId(), deviceId));
    }

    /**
     * 设备事件
     */
    @GetMapping("/devices/{deviceId}/events")
    public ApiResponse<Page<DeviceEventRecord>> pageEvents(
            @AuthenticationPrincipal SecurityUser securityUser,
            @PathVariable String deviceId,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime to,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_DETAIL_PAGE_SIZE) Integer pageSize) {
        return ApiResponse.success(userMonitorService.pageEvents(
                securityUser.sysUser().getId(), deviceId, type, from, to, pageNum, pageSize));
    }

    /**
     * 设备状态变更
     */
    @GetMapping("/devices/{deviceId}/states")
    public ApiResponse<Page<DeviceStateRecord>> pageStates(
            @AuthenticationPrincipal SecurityUser securityUser,
            @PathVariable String deviceId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime to,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_DETAIL_PAGE_SIZE) Integer pageSize) {
        return ApiResponse.success(userMonitorService.pageStates(
                securityUser.sysUser().getId(), deviceId, from, to, pageNum, pageSize));
    }

    /**
     * 我的告警列表
     */
    @GetMapping("/alerts")
    public ApiResponse<Page<DeviceAlertRecord>> pageAlerts(
            @AuthenticationPrincipal SecurityUser securityUser,
            @RequestParam(required = false) String deviceId,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Integer level,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime to,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize) {
        return ApiResponse.success(userMonitorService.pageAlerts(
                securityUser.sysUser().getId(), deviceId, status, level, from, to, pageNum, pageSize));
    }

    /**
     * 确认告警（标记已处理）
     */
    @PostMapping("/alerts/{id}/ack")
    public ApiResponse<Void> ackAlert(@AuthenticationPrincipal SecurityUser securityUser, @PathVariable Long id) {
        userMonitorService.ackAlert(securityUser.sysUser().getId(), id, securityUser.getUsername());
        return ApiResponse.success(null);
    }
}
