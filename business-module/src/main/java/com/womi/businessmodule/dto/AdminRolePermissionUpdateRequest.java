package com.womi.businessmodule.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

/**
 * 角色分配权限请求
 */
@Data
public class AdminRolePermissionUpdateRequest {

    @NotNull(message = "权限ID列表不能为空")
    private List<Long> permissionIds;
}
