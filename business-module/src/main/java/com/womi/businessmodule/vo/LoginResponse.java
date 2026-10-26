package com.womi.businessmodule.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginResponse {
    private String token;
    private String username;
    private String nickname;
    private String refreshToken;
    /** 上次登录时间（如果是第一次登录，则为 null） */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime lastLoginTime;
    /** 角色列表，例如：["ADMIN", "USER"] */
    private List<String> roles;

    /** 权限编码列表，例如：["device:list", "command:send"] */
    private List<String> permissions;

    /** Token 过期时间（时间戳或格式化时间），用于前端判断何时刷新或登出 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime expiresAt;
}
