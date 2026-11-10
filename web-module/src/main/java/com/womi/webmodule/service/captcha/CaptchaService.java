package com.womi.webmodule.service.captcha;

import com.womi.businessmodule.dto.CaptchaRequest;
import com.womi.businessmodule.vo.CaptchaVO;

/**
 * 统一验证码服务
 */
public interface CaptchaService {

    /** 生成验证码（当前支持图片验证码） */
    CaptchaVO generate(CaptchaRequest request);

    /**
     * 校验验证码，成功后立即失效
     *
     * @param captchaId   验证码唯一标识
     * @param captchaCode 用户输入的验证码
     */
    void verify(String captchaId, String captchaCode);
}
