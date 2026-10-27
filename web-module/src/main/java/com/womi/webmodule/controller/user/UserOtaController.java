package com.womi.webmodule.controller.user;

import com.womi.businessmodule.vo.OtaCheckResponse;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.auth.SecurityUser;
import com.womi.webmodule.service.mqtt.UserOtaService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user/ota")
@RequiredArgsConstructor
public class UserOtaController {

    private final UserOtaService userOtaService;

    /**
     * 获取当前登录用户的 ID
     */
    private Long getCurrentUserId() {
        SecurityUser user = (SecurityUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return user.getSysUser().getId();
    }

    /**
     * 检查设备是否有新版本
     */
    @GetMapping("/check/{deviceId}")
    public ApiResponse<OtaCheckResponse> checkUpdate(@PathVariable String deviceId) {
        OtaCheckResponse resp = userOtaService.checkUpdate(getCurrentUserId(), deviceId);
        return ApiResponse.success(resp);
    }

    /**
     * 用户主动发起单设备升级
     */
    @PostMapping("/start/{deviceId}")
    public ApiResponse<Void> startOta(@PathVariable String deviceId) {
        userOtaService.startOta(getCurrentUserId(), deviceId);
        return ApiResponse.success(null);
    }
}