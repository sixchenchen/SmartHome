package com.womi.webmodule.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.AdminPermissionSaveRequest;
import com.womi.businessmodule.dto.StatusUpdateRequest;
import com.womi.businessmodule.vo.AdminPermissionVO;
import com.womi.commonmodule.constants.PageConstants;
import com.womi.commonmodule.constants.PermissionConstants;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.sys.AdminPermissionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/permissions")
@RequiredArgsConstructor
public class AdminPermissionController {

    private final AdminPermissionService adminPermissionService;

    /**
     * 权限分页（支持编码/名称模糊搜索、类型、资源、状态筛选）
     */
    @GetMapping
    @PreAuthorize("hasAuthority('" + PermissionConstants.PERMISSION_LIST + "')")
    public ApiResponse<Page<AdminPermissionVO>> pagePermissions(
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String permType,
            @RequestParam(required = false) String resource,
            @RequestParam(required = false) Integer status) {
        return ApiResponse.success(
                adminPermissionService.pagePermissions(pageNum, pageSize, keyword, permType, resource, status));
    }

    /**
     * 全部权限（用于角色授权树/分组）
     */
    @GetMapping("/all")
    @PreAuthorize("hasAuthority('" + PermissionConstants.PERMISSION_LIST + "')")
    public ApiResponse<List<AdminPermissionVO>> listAllPermissions() {
        return ApiResponse.success(adminPermissionService.listAllPermissions());
    }

    /**
     * 权限详情
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.PERMISSION_LIST + "')")
    public ApiResponse<AdminPermissionVO> getPermission(@PathVariable Long id) {
        return ApiResponse.success(adminPermissionService.getPermission(id));
    }

    /**
     * 新增权限
     */
    @PostMapping
    @PreAuthorize("hasAuthority('" + PermissionConstants.PERMISSION_CREATE + "')")
    public ApiResponse<Long> createPermission(@RequestBody @Valid AdminPermissionSaveRequest request) {
        return ApiResponse.success(adminPermissionService.createPermission(request));
    }

    /**
     * 编辑权限（权限编码不可修改）
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.PERMISSION_UPDATE + "')")
    public ApiResponse<Void> updatePermission(@PathVariable Long id,
                                              @RequestBody @Valid AdminPermissionSaveRequest request) {
        adminPermissionService.updatePermission(id, request);
        return ApiResponse.success(null);
    }

    /**
     * 启用/禁用权限
     */
    @PutMapping("/{id}/status")
    @PreAuthorize("hasAuthority('" + PermissionConstants.PERMISSION_UPDATE + "')")
    public ApiResponse<Void> updateStatus(@PathVariable Long id,
                                          @RequestBody @Valid StatusUpdateRequest request) {
        adminPermissionService.updateStatus(id, request.getStatus());
        return ApiResponse.success(null);
    }

    /**
     * 删除权限（被角色引用时禁止删除）
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.PERMISSION_DELETE + "')")
    public ApiResponse<Void> deletePermission(@PathVariable Long id) {
        adminPermissionService.deletePermission(id);
        return ApiResponse.success(null);
    }
}
