package com.womi.businessmodule.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String username;
    private String password;

    /** 验证码唯一标识（captcha.enabled=true 时必填） */
    private String captchaId;

    /** 验证码（captcha.enabled=true 时必填） */
    private String captchaCode;
}
