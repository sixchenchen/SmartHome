package com.womi.webmodule.service.captcha;

import com.womi.businessmodule.dto.CaptchaRequest;
import com.womi.businessmodule.vo.CaptchaVO;
import com.womi.commonmodule.enums.CaptchaType;

/**
 * 验证码处理器（策略接口）
 *
 *  图片验证码由 {@code ImageCaptchaHandler} 实现；
 * 后续接入短信/邮箱验证码时，新增对应实现并注册为 Spring Bean 即可，无需改动统一服务
 */
public interface CaptchaHandler {

    /** 支持的验证码类型 */
    CaptchaType getType();

    /**
     * 生成验证码载体
     *
     * @param request 请求参数（短信/邮箱类型可从中读取 target）
     * @param code    验证码文本
     * @return 响应（不含 captchaId 与 expireIn，由统一服务填充）
     */
    CaptchaVO generate(CaptchaRequest request, String code);
}
