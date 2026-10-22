package com.womi.businessmodule.model.user;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 角色表
 */
@Data
@TableName(value = "user_role_info")
public class UserRoleInfo {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 角色编码，如 ADMIN、OPS、USER */
    @TableField("role_code")
    private String roleCode;

    /** 角色名称 */
    @TableField("role_name")
    private String roleName;

    /** 描述 */
    private String description;

    /** 状态：1启用，0禁用 */
    private Integer status;

    /** 是否内置：1是，0否 */
    @TableField("built_in")
    private Integer builtIn;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /** 逻辑删除：0否，1是 */
    private Integer deleted;
}