package com.womi.webmodule.controller.user;

import com.womi.businessmodule.vo.OtaCheckResponse;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.security.SecurityUser;
import com.womi.webmodule.service.mqtt.UserOtaService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user/ota")
@RequiredArgsConstructor
public class UserOtaController {

    private final UserOtaService userOtaService;

    /**
     * 检查设备是否有新版本
     */
    @GetMapping("/check/{deviceId}")
    public ApiResponse<OtaCheckResponse> checkUpdate(@AuthenticationPrincipal SecurityUser securityUser, @PathVariable String deviceId) {
        OtaCheckResponse resp = userOtaService.checkUpdate(securityUser.sysUser().getId(), deviceId);
        return ApiResponse.success(resp);
    }

    /**
     * 用户主动发起单设备升级
     */
    @PostMapping("/start/{deviceId}")
    public ApiResponse<Void> startOta(@AuthenticationPrincipal SecurityUser securityUser,@PathVariable String deviceId) {
        userOtaService.startOta(securityUser.sysUser().getId(), deviceId);
        return ApiResponse.success(null);
    }
}