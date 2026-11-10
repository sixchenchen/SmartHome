package com.womi.businessmodule.vo;

import lombok.Data;

import java.util.List;

/**
 * 管理端角色详情（含权限）
 */
@Data
public class AdminRoleDetailVO extends AdminRoleVO {

    /** 已分配权限ID列表 */
    private List<Long> permissionIds;

    /** 已分配权限编码列表 */
    private List<String> permCodes;
}
