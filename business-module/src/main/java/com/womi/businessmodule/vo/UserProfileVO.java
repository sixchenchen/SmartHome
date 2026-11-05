package com.womi.businessmodule.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 当前用户资料
 */
@Data
public class UserProfileVO {

    private Long userId;

    private String username;

    private String nickname;

    private String email;

    private String phone;

    /**
     * 头像地址（当前由前端保存，后端仅提供上传接口）
     */
    private String avatar;

    private Integer status;

    private List<String> roles;

    private List<String> permissions;

    private LocalDateTime lastLoginTime;

    private LocalDateTime createTime;
}
