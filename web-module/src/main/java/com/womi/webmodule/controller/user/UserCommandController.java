package com.womi.webmodule.controller.user;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.commonmodule.constants.PageConstants;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.security.SecurityUser;
import com.womi.webmodule.service.device.DeviceUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user/commands")
@RequiredArgsConstructor
public class UserCommandController {

    private final DeviceUserService deviceUserService;

    /**
     * 我的指令列表
     */
    @GetMapping
    public ApiResponse<Page<DeviceCommand>> pageCommands(@AuthenticationPrincipal SecurityUser securityUser,
                                                         @RequestParam(required = false) String deviceId,
                                                         @RequestParam(required = false) Integer status,
                                                         @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
                                                         @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize) {
        return ApiResponse.success(deviceUserService.pageCommands(
                securityUser.sysUser().getId(), deviceId, status, pageNum, pageSize));
    }

    /**
     * 指令详情
     */
    @GetMapping("/{commandId}")
    public ApiResponse<DeviceCommand> getCommand(@AuthenticationPrincipal SecurityUser securityUser,
                                                 @PathVariable String commandId) {
        return ApiResponse.success(deviceUserService.getCommand(securityUser.sysUser().getId(), commandId));
    }

    /**
     * 取消未下发指令
     */
    @PostMapping("/{commandId}/cancel")
    public ApiResponse<Boolean> cancelCommand(@AuthenticationPrincipal SecurityUser securityUser,
                                              @PathVariable String commandId) {
        return ApiResponse.success(deviceUserService.cancelCommandByCommandId(securityUser.sysUser().getId(), commandId));
    }
}
