package com.womi.businessmodule.model.user;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 角色-权限关联表
 */
@Data
@TableName(value = "sys_role_permission")
public class UserRolePermission {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 角色ID */
    @TableField("role_id")
    private Long roleId;

    /** 权限ID */
    @TableField("permission_id")
    private Long permissionId;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}