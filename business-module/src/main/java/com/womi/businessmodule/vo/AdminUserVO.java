package com.womi.businessmodule.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 管理端用户列表项
 */
@Data
public class AdminUserVO {

    private Long id;

    private String username;

    private String nickname;

    private String email;

    private String phone;

    private Integer status;

    private List<String> roles;

    private LocalDateTime lastLoginTime;

    private LocalDateTime createTime;
}
