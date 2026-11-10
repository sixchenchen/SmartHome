package com.womi.webmodule.service.captcha.impl;

import com.womi.businessmodule.dto.CaptchaRequest;
import com.womi.businessmodule.vo.CaptchaVO;
import com.womi.commonmodule.constants.CaptchaConstants;
import com.womi.commonmodule.enums.CaptchaType;
import com.womi.commonmodule.properties.CaptchaProperties;
import com.womi.commonmodule.utils.CaptchaImageUtils;
import com.womi.webmodule.service.captcha.CaptchaHandler;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Base64;

/**
 * 图片验证码处理器
 */
@Component
@RequiredArgsConstructor
public class ImageCaptchaHandler implements CaptchaHandler {

    private final CaptchaProperties captchaProperties;

    @Override
    public CaptchaType getType() {
        return CaptchaType.IMAGE;
    }

    @Override
    public CaptchaVO generate(CaptchaRequest request, String code) {
        byte[] image = CaptchaImageUtils.render(code, captchaProperties.getWidth(),
                captchaProperties.getHeight(), captchaProperties.getNoiseLines());

        CaptchaVO vo = new CaptchaVO();
        vo.setCaptchaType(CaptchaType.IMAGE.getCode());
        vo.setImageBase64(CaptchaConstants.IMAGE_BASE64_PREFIX + Base64.getEncoder().encodeToString(image));
        return vo;
    }
}
