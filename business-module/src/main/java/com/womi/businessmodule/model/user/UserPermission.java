package com.womi.businessmodule.model.user;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 权限表
 */
@Data
@TableName(value = "user_permission")
public class UserPermission {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 权限编码，如 order:create */
    @TableField("perm_code")
    private String permCode;

    /** 权限名称 */
    @TableField("perm_name")
    private String permName;

    /** 权限类型：MENU/BUTTON/API/ACTION */
    @TableField("perm_type")
    private String permType;

    /** 资源，如 order */
    private String resource;

    /** 动作，如 create/update/delete/read */
    private String action;

    /** 描述 */
    private String description;

    /** 状态：1启用，0禁用 */
    private Integer status;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /** 逻辑删除：0否，1是 */
    private Integer deleted;
}