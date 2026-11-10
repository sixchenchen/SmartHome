package com.womi.businessmodule.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 获取验证码请求
 */
@Data
public class CaptchaRequest {

    /** 验证码类型：image（默认）/sms/email */
    @Size(max = 16, message = "验证码类型长度不能超过 16 位")
    private String type;

    /** 接收目标（短信填手机号、邮箱填邮箱地址，图片验证码可不传） */
    @Size(max = 128, message = "接收目标长度不能超过 128 位")
    private String target;
}
