package com.womi.businessmodule.vo;

import lombok.Data;

/**
 * 验证码响应
 */
@Data
public class CaptchaVO {

    /** 验证码唯一标识，登录时回传 */
    private String captchaId;

    /** 验证码类型：image/sms/email */
    private String captchaType;

    /** 图片验证码 Base64（含 data:image/png;base64, 前缀） */
    private String imageBase64;

    /** 有效期（秒） */
    private Long expireIn;
}
