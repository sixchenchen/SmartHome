package com.womi.webmodule.service.captcha.impl;

import com.womi.businessmodule.dto.CaptchaRequest;
import com.womi.businessmodule.vo.CaptchaVO;
import com.womi.commonmodule.constants.CaptchaConstants;
import com.womi.commonmodule.constants.RedisConstants;
import com.womi.commonmodule.enums.CaptchaType;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.properties.CaptchaProperties;
import com.womi.commonmodule.utils.CaptchaUtils;
import com.womi.webmodule.service.captcha.CaptchaHandler;
import com.womi.webmodule.service.captcha.CaptchaService;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.Duration;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

/**
 * 统一验证码服务实现
 *
 * 验证码文本统一存放 Redis，键：{@code captcha:{captchaId}}；
 * 校验失败次数键：{@code captcha:fail:{captchaId}}，超过上限后验证码立即失效
 */
@Service
@RequiredArgsConstructor
public class CaptchaServiceImpl implements CaptchaService {

    private final StringRedisTemplate redisTemplate;
    private final CaptchaProperties captchaProperties;
    private final List<CaptchaHandler> captchaHandlers;

    private final Map<CaptchaType, CaptchaHandler> handlerMap = new EnumMap<>(CaptchaType.class);

    @PostConstruct
    public void init() {
        for (CaptchaHandler handler : captchaHandlers) {
            handlerMap.put(handler.getType(), handler);
        }
    }

    @Override
    public CaptchaVO generate(CaptchaRequest request) {
        CaptchaType type = resolveType(request);
        CaptchaHandler handler = handlerMap.get(type);
        if (handler == null) {
            throw new BusinessException(ErrorCode.CAPTCHA_TYPE_UNSUPPORTED, "暂不支持该验证码类型: " + type.getCode());
        }

        String code = CaptchaUtils.randomCode(captchaProperties.getLength());
        String captchaId = CaptchaUtils.randomId();

        CaptchaVO vo = handler.generate(request, code);
        vo.setCaptchaId(captchaId);
        vo.setExpireIn(captchaProperties.getTtlSeconds());

        redisTemplate.opsForValue().set(buildCodeKey(captchaId), code,
                Duration.ofSeconds(captchaProperties.getTtlSeconds()));
        return vo;
    }

    @Override
    public void verify(String captchaId, String captchaCode) {
        if (!captchaProperties.isEnabled()) {
            return;
        }
        if (!StringUtils.hasText(captchaId) || !StringUtils.hasText(captchaCode)) {
            throw new BusinessException(ErrorCode.CAPTCHA_REQUIRED);
        }

        String codeKey = buildCodeKey(captchaId);
        String expected = redisTemplate.opsForValue().get(codeKey);
        if (!StringUtils.hasText(expected)) {
            throw new BusinessException(ErrorCode.CAPTCHA_EXPIRED);
        }

        if (CaptchaUtils.matches(expected, captchaCode)) {
            redisTemplate.delete(List.of(codeKey, buildFailKey(captchaId)));
            return;
        }

        Long failedTimes = redisTemplate.opsForValue().increment(buildFailKey(captchaId));
        if (failedTimes != null && failedTimes == 1L) {
            redisTemplate.expire(buildFailKey(captchaId),
                    Duration.ofSeconds(captchaProperties.getTtlSeconds()));
        }
        if (failedTimes != null && failedTimes >= CaptchaConstants.MAX_VERIFY_ATTEMPTS) {
            redisTemplate.delete(List.of(codeKey, buildFailKey(captchaId)));
            throw new BusinessException(ErrorCode.CAPTCHA_EXPIRED, "验证码错误次数过多，请重新获取");
        }
        throw new BusinessException(ErrorCode.CAPTCHA_INVALID);
    }

    private CaptchaType resolveType(CaptchaRequest request) {
        if (request == null || !StringUtils.hasText(request.getType())) {
            return CaptchaType.IMAGE;
        }
        CaptchaType type = CaptchaType.fromCode(request.getType());
        if (type == null) {
            throw new BusinessException(ErrorCode.CAPTCHA_TYPE_UNSUPPORTED);
        }
        return type;
    }

    private String buildCodeKey(String captchaId) {
        return RedisConstants.REDIS_CAPTCHA_PREFIX + captchaId;
    }

    private String buildFailKey(String captchaId) {
        return RedisConstants.REDIS_CAPTCHA_FAIL_PREFIX + captchaId;
    }
}
