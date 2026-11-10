package com.womi.webmodule.service.sys;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.AdminPermissionSaveRequest;
import com.womi.businessmodule.vo.AdminPermissionVO;

import java.util.List;

/**
 * 管理端权限管理服务
 */
public interface AdminPermissionService {

    Page<AdminPermissionVO> pagePermissions(Integer pageNum, Integer pageSize, String keyword,
                                            String permType, String resource, Integer status);

    /** 全部权限（用于角色授权时的树/分组展示） */
    List<AdminPermissionVO> listAllPermissions();

    AdminPermissionVO getPermission(Long permissionId);

    Long createPermission(AdminPermissionSaveRequest request);

    void updatePermission(Long permissionId, AdminPermissionSaveRequest request);

    void updateStatus(Long permissionId, Integer status);

    void deletePermission(Long permissionId);
}
