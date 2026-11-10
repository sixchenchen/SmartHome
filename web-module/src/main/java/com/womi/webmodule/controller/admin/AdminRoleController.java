package com.womi.webmodule.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.AdminRolePermissionUpdateRequest;
import com.womi.businessmodule.dto.AdminRoleSaveRequest;
import com.womi.businessmodule.dto.StatusUpdateRequest;
import com.womi.businessmodule.vo.AdminRoleDetailVO;
import com.womi.businessmodule.vo.AdminRoleVO;
import com.womi.commonmodule.constants.PageConstants;
import com.womi.commonmodule.constants.PermissionConstants;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.sys.AdminRoleService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/roles")
@RequiredArgsConstructor
public class AdminRoleController {

    private final AdminRoleService adminRoleService;

    /**
     * 角色分页（支持角色编码/名称模糊搜索、状态筛选）
     */
    @GetMapping
    @PreAuthorize("hasAuthority('" + PermissionConstants.ROLE_LIST + "')")
    public ApiResponse<Page<AdminRoleVO>> pageRoles(
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status) {
        return ApiResponse.success(adminRoleService.pageRoles(pageNum, pageSize, keyword, status));
    }

    /**
     * 全部角色（下拉选择）
     */
    @GetMapping("/all")
    @PreAuthorize("hasAuthority('" + PermissionConstants.ROLE_LIST + "')")
    public ApiResponse<List<AdminRoleVO>> listAllRoles() {
        return ApiResponse.success(adminRoleService.listAllRoles());
    }

    /**
     * 角色详情（含已分配权限）
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.ROLE_LIST + "')")
    public ApiResponse<AdminRoleDetailVO> getRoleDetail(@PathVariable Long id) {
        return ApiResponse.success(adminRoleService.getRoleDetail(id));
    }

    /**
     * 新增角色
     */
    @PostMapping
    @PreAuthorize("hasAuthority('" + PermissionConstants.ROLE_CREATE + "')")
    public ApiResponse<Long> createRole(@RequestBody @Valid AdminRoleSaveRequest request) {
        return ApiResponse.success(adminRoleService.createRole(request));
    }

    /**
     * 编辑角色
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.ROLE_UPDATE + "')")
    public ApiResponse<Void> updateRole(@PathVariable Long id,
                                        @RequestBody @Valid AdminRoleSaveRequest request) {
        adminRoleService.updateRole(id, request);
        return ApiResponse.success(null);
    }

    /**
     * 启用/禁用角色
     */
    @PutMapping("/{id}/status")
    @PreAuthorize("hasAuthority('" + PermissionConstants.ROLE_UPDATE + "')")
    public ApiResponse<Void> updateStatus(@PathVariable Long id,
                                          @RequestBody @Valid StatusUpdateRequest request) {
        adminRoleService.updateStatus(id, request.getStatus());
        return ApiResponse.success(null);
    }

    /**
     * 删除角色
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.ROLE_DELETE + "')")
    public ApiResponse<Void> deleteRole(@PathVariable Long id) {
        adminRoleService.deleteRole(id);
        return ApiResponse.success(null);
    }

    /**
     * 查询角色已分配权限
     */
    @GetMapping("/{id}/permissions")
    @PreAuthorize("hasAuthority('" + PermissionConstants.ROLE_LIST + "')")
    public ApiResponse<AdminRoleDetailVO> getRolePermissions(@PathVariable Long id) {
        return ApiResponse.success(adminRoleService.getRolePermissions(id));
    }

    /**
     * 覆盖式分配角色权限（传空数组表示清空）
     */
    @PutMapping("/{id}/permissions")
    @PreAuthorize("hasAuthority('" + PermissionConstants.ROLE_ASSIGN_PERMISSION + "')")
    public ApiResponse<Void> updateRolePermissions(@PathVariable Long id,
                                                   @RequestBody @Valid AdminRolePermissionUpdateRequest request) {
        adminRoleService.updateRolePermissions(id, request.getPermissionIds());
        return ApiResponse.success(null);
    }
}
