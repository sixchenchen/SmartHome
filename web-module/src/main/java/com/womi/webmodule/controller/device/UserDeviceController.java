package com.womi.webmodule.controller.device;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.auth.SecurityUser;
import com.womi.webmodule.service.device.DeviceUserService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user/devices")
@RequiredArgsConstructor
public class UserDeviceController {

    private final DeviceUserService deviceUserService;


    @Data
    public static class BindRequest {
        private String deviceId;
    }

    /**
     * 绑定设备
     */
    @PostMapping("/bind")
    public ApiResponse<Void> bindDevice(@RequestBody BindRequest request) {
        deviceUserService.bindDevice(getCurrentUserId(), request.getDeviceId());
        return ApiResponse.success(null);
    }

    /**
     * 解绑设备
     */
    @PostMapping("/unbind")
    public ApiResponse<Void> unbindDevice(@RequestBody BindRequest request) {
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
     * 内部工具方法：获取当前登录用户的 ID
     */
    private Long getCurrentUserId() {
        SecurityUser securityUser = (SecurityUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return securityUser.getSysUser().getId();
    }
}