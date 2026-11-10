package com.womi.webmodule.service.sys;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.AdminRoleSaveRequest;
import com.womi.businessmodule.vo.AdminRoleDetailVO;
import com.womi.businessmodule.vo.AdminRoleVO;

import java.util.List;

/**
 * 管理端角色管理服务
 */
public interface AdminRoleService {

    Page<AdminRoleVO> pageRoles(Integer pageNum, Integer pageSize, String keyword, Integer status);

    /** 全部角色（用于下拉选择） */
    List<AdminRoleVO> listAllRoles();

    AdminRoleDetailVO getRoleDetail(Long roleId);

    Long createRole(AdminRoleSaveRequest request);

    void updateRole(Long roleId, AdminRoleSaveRequest request);

    void updateStatus(Long roleId, Integer status);

    void deleteRole(Long roleId);

    AdminRoleDetailVO getRolePermissions(Long roleId);

    /** 覆盖式分配权限（传空列表表示清空） */
    void updateRolePermissions(Long roleId, List<Long> permissionIds);
}
