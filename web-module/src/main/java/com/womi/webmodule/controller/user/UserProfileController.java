package com.womi.webmodule.controller.user;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.PasswordChangeRequest;
import com.womi.businessmodule.dto.UserProfileUpdateRequest;
import com.womi.businessmodule.vo.LoginLogVO;
import com.womi.businessmodule.vo.UserProfileVO;
import com.womi.commonmodule.constants.PageConstants;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.security.SecurityUser;
import com.womi.webmodule.service.user.UserProfileService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserProfileController {

    private final UserProfileService userProfileService;

    /**
     * 我的资料
     */
    @GetMapping("/profile")
    public ApiResponse<UserProfileVO> getProfile(@AuthenticationPrincipal SecurityUser securityUser) {
        return ApiResponse.success(userProfileService.getProfile(securityUser.sysUser().getId()));
    }

    /**
     * 修改我的资料
     */
    @PutMapping("/profile")
    public ApiResponse<UserProfileVO> updateProfile(@AuthenticationPrincipal SecurityUser securityUser,
                                                    @RequestBody @Valid UserProfileUpdateRequest request) {
        return ApiResponse.success(userProfileService.updateProfile(securityUser.sysUser().getId(), request));
    }

    /**
     * 修改密码（成功后强制下线）
     */
    @RequestMapping(value = "/password", method = {RequestMethod.PUT, RequestMethod.POST})
    public ApiResponse<Void> changePassword(@AuthenticationPrincipal SecurityUser securityUser,
                                            @RequestBody @Valid PasswordChangeRequest request) {
        userProfileService.changePassword(securityUser.sysUser().getId(), request);
        return ApiResponse.success(null);
    }

    /**
     * 我的登录记录
     */
    @GetMapping("/login-logs")
    public ApiResponse<Page<LoginLogVO>> pageLoginLogs(@AuthenticationPrincipal SecurityUser securityUser,
                                                      @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
                                                      @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize) {
        return ApiResponse.success(userProfileService.pageLoginLogs(securityUser.sysUser().getId(), pageNum, pageSize));
    }
}
