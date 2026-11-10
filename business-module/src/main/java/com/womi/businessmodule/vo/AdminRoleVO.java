package com.womi.businessmodule.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 管理端角色列表项
 */
@Data
public class AdminRoleVO {

    private Long id;

    private String roleCode;

    private String roleName;

    private String description;

    private Integer status;

    /** 是否内置：1是，0否 */
    private Integer builtIn;

    /** 已分配用户数 */
    private Long userCount;

    /** 已分配权限数 */
    private Long permissionCount;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
