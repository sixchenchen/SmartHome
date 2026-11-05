package com.womi.webmodule.controller.user;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.vo.OtaCheckResponse;
import com.womi.businessmodule.vo.device.DeviceOtaProgressVO;
import com.womi.businessmodule.vo.device.OtaRecordVO;
import com.womi.commonmodule.constants.PageConstants;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.security.SecurityUser;
import com.womi.webmodule.service.mqtt.UserOtaService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
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

    /**
     * 查询设备 OTA 进度
     */
    @GetMapping("/progress/{deviceId}")
    public ApiResponse<DeviceOtaProgressVO> getProgress(@AuthenticationPrincipal SecurityUser securityUser,
                                                        @PathVariable String deviceId) {
        return ApiResponse.success(userOtaService.getProgress(securityUser.sysUser().getId(), deviceId));
    }

    /**
     * 我的 OTA 升级记录
     */
    @GetMapping("/records")
    public ApiResponse<Page<OtaRecordVO>> pageRecords(@AuthenticationPrincipal SecurityUser securityUser,
                                                      @RequestParam String deviceId,
                                                      @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
                                                      @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize) {
        return ApiResponse.success(userOtaService.pageRecords(
                securityUser.sysUser().getId(), deviceId, pageNum, pageSize));
    }

    /**
     * 升级失败重试
     */
    @PostMapping("/retry/{deviceId}")
    public ApiResponse<Void> retry(@AuthenticationPrincipal SecurityUser securityUser, @PathVariable String deviceId) {
        userOtaService.retry(securityUser.sysUser().getId(), deviceId);
        return ApiResponse.success(null);
    }
}