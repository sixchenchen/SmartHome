package com.womi.webmodule.controller.user;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.DeviceBindRequest;
import com.womi.businessmodule.dto.DeviceControlRequest;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.auth.SecurityUser;
import com.womi.webmodule.service.device.DeviceUserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
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
    public ApiResponse<Void> bindDevice(@RequestBody DeviceBindRequest request) {
        deviceUserService.bindDevice(getCurrentUserId(), request.getDeviceId(), request.getBindCode());
        return ApiResponse.success(null);
    }

    /**
     * 解绑设备
     */
    @PostMapping("/unbind")
    public ApiResponse<Void> unbindDevice(@RequestBody DeviceBindRequest request) {
        deviceUserService.unbindDevice(getCurrentUserId(), request.getDeviceId());
        return ApiResponse.success(null);
    }

    /**
     * 查询我的设备列表（只返回自己绑定的设备）
     */
    @GetMapping("/my")
    public ApiResponse<Page<DeviceInfo>> getMyDevices(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        return ApiResponse.success(deviceUserService.getMyDevices(getCurrentUserId(), pageNum, pageSize));
    }

    /**
     * 控制设备（开灯、关灯等）
     */
    @PostMapping("/control")
    public ApiResponse<Void> controlDevice(@RequestBody @Valid DeviceControlRequest request) {
        deviceUserService.sendControlCommand(getCurrentUserId(), request);
        return ApiResponse.success(null);
    }

    /**
     * 内部工具方法：获取当前登录用户的 ID
     */
    private Long getCurrentUserId() {
        SecurityUser securityUser = (SecurityUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return securityUser.sysUser().getId();
    }
}