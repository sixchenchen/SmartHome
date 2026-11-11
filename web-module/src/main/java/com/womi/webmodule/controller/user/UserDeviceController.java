package com.womi.webmodule.controller.user;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.DeviceBatchControlRequest;
import com.womi.businessmodule.dto.DeviceBindRequest;
import com.womi.businessmodule.dto.DeviceControlRequest;
import com.womi.businessmodule.dto.UserDeviceUpdateRequest;
import com.womi.businessmodule.vo.CommandStatsVO;
import com.womi.businessmodule.vo.device.DeviceDetailVO;
import com.womi.businessmodule.vo.device.DeviceInfoVO;
import com.womi.businessmodule.vo.device.DeviceOnlineVO;
import com.womi.commonmodule.constants.PageConstants;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.security.SecurityUser;
import com.womi.webmodule.service.device.DeviceUserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user/devices")
@RequiredArgsConstructor
public class UserDeviceController {

    private final DeviceUserService deviceUserService;

    /**
     * 绑定设备
     */
    @PostMapping("/bind")
    public ApiResponse<Void> bindDevice(@AuthenticationPrincipal SecurityUser securityUser, @RequestBody @Valid DeviceBindRequest request) {
        deviceUserService.bindDevice(securityUser.sysUser().getId(), request.getDeviceId(), request.getBindCode());
        return ApiResponse.success(null);
    }

    /**
     * 解绑设备
     */
    @PostMapping("/unbind")
    public ApiResponse<Void> unbindDevice(@AuthenticationPrincipal SecurityUser securityUser, @RequestBody @Valid DeviceBindRequest request) {
        deviceUserService.unbindDevice(securityUser.sysUser().getId(), request.getDeviceId());
        return ApiResponse.success(null);
    }

    /**
     * 查询我的设备列表（只返回自己绑定的设备）
     */
    @GetMapping("/my")
    public ApiResponse<Page<DeviceInfoVO>> getMyDevices(
            @AuthenticationPrincipal SecurityUser securityUser,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize) {

        // 直接从参数里拿
        Long userId = securityUser.sysUser().getId();

        Page<DeviceInfoVO> result = deviceUserService.getMyDevices(userId, pageNum, pageSize);
        return ApiResponse.success(result);
    }

    /**
     * 控制设备（开灯、关灯等）
     */
    @PostMapping("/control")
    public ApiResponse<String> controlDevice(@AuthenticationPrincipal SecurityUser securityUser, @RequestBody @Valid DeviceControlRequest request) {
        return ApiResponse.success(deviceUserService.sendControlCommand(securityUser.sysUser().getId(), request));
    }

    /**
     * 设备指令历史
     */
    @GetMapping("/{deviceId}/commands")
    public ApiResponse<Page<com.womi.businessmodule.model.device.DeviceCommand>> pageDeviceCommands(
            @AuthenticationPrincipal SecurityUser securityUser,
            @PathVariable String deviceId,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize) {
        return ApiResponse.success(deviceUserService.pageCommands(
                securityUser.sysUser().getId(), deviceId, status, pageNum, pageSize));
    }

    /**
     * 设备详情
     */
    @GetMapping("/{deviceId}")
    public ApiResponse<DeviceDetailVO> getDeviceDetail(@AuthenticationPrincipal SecurityUser securityUser,
                                                       @PathVariable String deviceId) {
        return ApiResponse.success(deviceUserService.getDeviceDetail(securityUser.sysUser().getId(), deviceId));
    }

    /**
     * 设备在线状态
     */
    @GetMapping("/{deviceId}/online")
    public ApiResponse<DeviceOnlineVO> getOnlineStatus(@AuthenticationPrincipal SecurityUser securityUser,
                                                       @PathVariable String deviceId) {
        return ApiResponse.success(deviceUserService.getOnlineStatus(securityUser.sysUser().getId(), deviceId));
    }

    /**
     * 修改设备名称/位置
     */
    @PutMapping("/{deviceId}")
    public ApiResponse<Void> updateDevice(@AuthenticationPrincipal SecurityUser securityUser,
                                          @PathVariable String deviceId,
                                          @RequestBody @Valid UserDeviceUpdateRequest request) {
        deviceUserService.updateDevice(securityUser.sysUser().getId(), deviceId, request);
        return ApiResponse.success(null);
    }

    /**
     * 批量控制（同一设备下连续下发多条指令）
     */
    @PostMapping("/{deviceId}/commands/batch")
    public ApiResponse<java.util.List<String>> batchControl(@AuthenticationPrincipal SecurityUser securityUser,
                                                            @PathVariable String deviceId,
                                                            @RequestBody @Valid DeviceBatchControlRequest request) {
        return ApiResponse.success(deviceUserService.batchControl(securityUser.sysUser().getId(), deviceId, request));
    }

    /**
     * 设备指令统计
     */
    @GetMapping("/{deviceId}/commands/stats")
    public ApiResponse<CommandStatsVO> getCommandStats(@AuthenticationPrincipal SecurityUser securityUser,
                                                       @PathVariable String deviceId) {
        return ApiResponse.success(deviceUserService.getCommandStats(securityUser.sysUser().getId(), deviceId));
    }
}