package com.womi.webmodule.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.AdminUserUpdateRequest;
import com.womi.businessmodule.dto.UserDeviceUnbindRequest;
import com.womi.businessmodule.dto.UserRolesUpdateRequest;
import com.womi.businessmodule.dto.UserStatusUpdateRequest;
import com.womi.businessmodule.service.sys.SysUserService;
import com.womi.businessmodule.vo.AdminUserDetailVO;
import com.womi.businessmodule.vo.AdminUserVO;
import com.womi.businessmodule.vo.device.DeviceInfoVO;
import com.womi.commonmodule.constants.PageConstants;
import com.womi.commonmodule.constants.PermissionConstants;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.user.AdminUserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
public class AdminController {

    private final SysUserService sysUserService;
    private final AdminUserService adminUserService;

    /**
     * 用户分页（支持用户名/昵称/手机号模糊搜索、状态、角色筛选）
     */
    @GetMapping
    @PreAuthorize("hasAuthority('" + PermissionConstants.USER_LIST + "')")
    public ApiResponse<Page<AdminUserVO>> pageUsers(
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String roleCode) {
        String roleFilter = role != null && !role.isBlank() ? role : roleCode;
        return ApiResponse.success(adminUserService.pageUsers(pageNum, pageSize, keyword, status, roleFilter));
    }

    /**
     * 用户详情（含角色、权限、设备数、登录次数）
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.USER_LIST + "')")
    public ApiResponse<AdminUserDetailVO> getUserDetail(@PathVariable Long id) {
        return ApiResponse.success(adminUserService.getUserDetail(id));
    }

    /**
     * 编辑用户资料
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.USER_UPDATE + "')")
    public ApiResponse<Void> updateUser(@PathVariable Long id, @RequestBody @Valid AdminUserUpdateRequest request) {
        adminUserService.updateUser(id, request);
        return ApiResponse.success(null);
    }

    /**
     * 启用/禁用用户
     */
    @PutMapping("/{id}/status")
    @PreAuthorize("hasAuthority('" + PermissionConstants.USER_UPDATE + "')")
    public ApiResponse<Void> updateStatus(@PathVariable Long id, @RequestBody @Valid UserStatusUpdateRequest request) {
        adminUserService.updateStatus(id, request.getStatus());
        return ApiResponse.success(null);
    }

    /**
     * 分配角色
     */
    @PutMapping("/{id}/roles")
    @PreAuthorize("hasAuthority('" + PermissionConstants.USER_UPDATE + "')")
    public ApiResponse<Void> updateRoles(@PathVariable Long id, @RequestBody @Valid UserRolesUpdateRequest request) {
        adminUserService.updateRoles(id, request.getRoleCodes());
        return ApiResponse.success(null);
    }

    /**
     * 用户绑定的设备
     */
    @GetMapping("/{id}/devices")
    @PreAuthorize("hasAuthority('" + PermissionConstants.USER_LIST + "')")
    public ApiResponse<Page<DeviceInfoVO>> pageUserDevices(
            @PathVariable Long id,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize) {
        return ApiResponse.success(adminUserService.pageUserDevices(id, pageNum, pageSize));
    }

    /**
     * 强制解绑用户设备
     */
    @PostMapping("/{id}/force-unbind")
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_UNBIND + "')")
    public ApiResponse<Void> forceUnbind(@PathVariable Long id, @RequestBody @Valid UserDeviceUnbindRequest request) {
        adminUserService.forceUnbind(id, request.getDeviceId());
        return ApiResponse.success(null);
    }

    /**
     * 删除用户（逻辑删除）
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.USER_DELETE + "')")
    public ApiResponse<Void> deleteUser(@PathVariable Long id) {
        sysUserService.logicDeleteUser(id);
        return ApiResponse.success(null);
    }
}
