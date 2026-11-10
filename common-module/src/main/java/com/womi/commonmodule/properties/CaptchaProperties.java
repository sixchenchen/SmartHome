package com.womi.commonmodule.properties;

import com.womi.commonmodule.constants.CaptchaConstants;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 验证码配置
 */
@Data
@ConfigurationProperties(prefix = "captcha")
public class CaptchaProperties {

    /** 是否启用验证码校验（关闭后登录不再校验，验证码接口仍可获取） */
    private boolean enabled = true;

    /** 有效期（秒） */
    private long ttlSeconds = CaptchaConstants.DEFAULT_TTL_SECONDS;

    /** 字符长度 */
    private int length = CaptchaConstants.DEFAULT_LENGTH;

    /** 图片宽度 */
    private int width = CaptchaConstants.DEFAULT_WIDTH;

    /** 图片高度 */
    private int height = CaptchaConstants.DEFAULT_HEIGHT;

    /** 干扰线数量 */
    private int noiseLines = CaptchaConstants.DEFAULT_NOISE_LINES;
}
