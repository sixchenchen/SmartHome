package com.womi.businessmodule.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 管理端权限列表项
 */
@Data
public class AdminPermissionVO {

    private Long id;

    private String permCode;

    private String permName;

    /** MENU/BUTTON/API/ACTION */
    private String permType;

    private String resource;

    private String action;

    private String description;

    private Integer status;

    /** 已关联角色数 */
    private Long roleCount;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
