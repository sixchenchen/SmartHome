package com.womi.webmodule.controller.user;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.DeviceBindRequest;
import com.womi.businessmodule.dto.DeviceControlRequest;
import com.womi.businessmodule.vo.device.DeviceInfoVO;
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
    public ApiResponse<Void> bindDevice(@AuthenticationPrincipal SecurityUser securityUser, @RequestBody DeviceBindRequest request) {
        deviceUserService.bindDevice(securityUser.sysUser().getId(), request.getDeviceId(), request.getBindCode());
        return ApiResponse.success(null);
    }

    /**
     * 解绑设备
     */
    @PostMapping("/unbind")
    public ApiResponse<Void> unbindDevice(@AuthenticationPrincipal SecurityUser securityUser, @RequestBody DeviceBindRequest request) {
        deviceUserService.unbindDevice(securityUser.sysUser().getId(), request.getDeviceId());
        return ApiResponse.success(null);
    }

    /**
     * 查询我的设备列表（只返回自己绑定的设备）
     */
    /**
     * 查询我的设备列表（只返回自己绑定的设备）
     */
    @GetMapping("/my")
    public ApiResponse<Page<DeviceInfoVO>> getMyDevices(
            @AuthenticationPrincipal SecurityUser securityUser,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {

        // 直接从参数里拿
        Long userId = securityUser.sysUser().getId();

        Page<DeviceInfoVO> result = deviceUserService.getMyDevices(userId, pageNum, pageSize);
        return ApiResponse.success(result);
    }

    /**
     * 控制设备（开灯、关灯等）
     */
    @PostMapping("/control")
    public ApiResponse<Void> controlDevice(@AuthenticationPrincipal SecurityUser securityUser, @RequestBody @Valid DeviceControlRequest request) {
        deviceUserService.sendControlCommand(securityUser.sysUser().getId(), request);
        return ApiResponse.success(null);
    }
}