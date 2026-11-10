package com.womi.webmodule.controller.auth;

import com.womi.businessmodule.dto.CaptchaRequest;
import com.womi.businessmodule.vo.CaptchaVO;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.captcha.CaptchaService;
import com.womi.webmodule.service.security.RateLimitService;
import com.womi.webmodule.util.ClientRequestUtils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class CaptchaController {

    private final CaptchaService captchaService;
    private final RateLimitService rateLimitService;

    /**
     * 获取验证码（当前支持图片验证码，短信/邮箱验证码预留）
     */
    @PostMapping("/captcha")
    public ApiResponse<CaptchaVO> generate(@RequestBody(required = false) @Valid CaptchaRequest request,
                                           HttpServletRequest httpRequest) {
        String ip = ClientRequestUtils.getClientIp(httpRequest);
        String deviceId = ClientRequestUtils.resolveDeviceId(httpRequest, ip);
        rateLimitService.checkCaptchaAccess(ip, deviceId);
        return ApiResponse.success(captchaService.generate(request));
    }
}
