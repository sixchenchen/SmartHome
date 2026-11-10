package com.womi.webmodule.service.security.impl;

import com.womi.commonmodule.constants.RateLimitConstants;
import com.womi.commonmodule.constants.RedisConstants;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.RateLimitException;
import com.womi.webmodule.service.security.RateLimitService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Collections;

/**
 * 限流与风控服务实现
 *
 * <p>采用 Redis 固定窗口计数，INCR + EXPIRE 通过 Lua 脚本保证原子性。</p>
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class RateLimitServiceImpl implements RateLimitService {

    /** INCR 并在首次写入时设置过期时间，保证计数与 TTL 原子生效 */
    private static final DefaultRedisScript<Long> INCR_WITH_TTL_SCRIPT = new DefaultRedisScript<>(
            "local c = redis.call('INCR', KEYS[1]); "
                    + "if c == 1 then redis.call('EXPIRE', KEYS[1], ARGV[1]); end; "
                    + "return c;",
            Long.class);

    private final StringRedisTemplate redis;

    @Override
    public void checkCaptchaAccess(String ip, String deviceId) {
        boolean ipMinute = exceeded(captchaKey(RedisConstants.REDIS_IP_SCOPE, RedisConstants.REDIS_WINDOW_MINUTE, ip),
                RateLimitConstants.CAPTCHA_IP_PER_MINUTE, RateLimitConstants.ONE_MINUTE_SECONDS);
        boolean ipHour = exceeded(captchaKey(RedisConstants.REDIS_IP_SCOPE, RedisConstants.REDIS_WINDOW_HOUR, ip),
                RateLimitConstants.CAPTCHA_IP_PER_HOUR, RateLimitConstants.ONE_HOUR_SECONDS);
        boolean deviceMinute = exceeded(
                captchaKey(RedisConstants.REDIS_DEVICE_SCOPE, RedisConstants.REDIS_WINDOW_MINUTE, deviceId),
                RateLimitConstants.CAPTCHA_DEVICE_PER_MINUTE, RateLimitConstants.ONE_MINUTE_SECONDS);

        if (ipMinute || ipHour || deviceMinute) {
            log.debug("验证码获取触发限流 - ipMinute={}, ipHour={}, deviceMinute={}", ipMinute, ipHour, deviceMinute);
            throw new RateLimitException(ErrorCode.RATE_LIMIT_EXCEEDED);
        }
    }

    @Override
    public void checkLoginAccess(String ip, String deviceId, String username) {
        if (Boolean.TRUE.equals(redis.hasKey(blockKey(ip)))) {
            throw new RateLimitException(ErrorCode.IP_TEMPORARILY_BLOCKED);
        }
        if (Boolean.TRUE.equals(redis.hasKey(sliderKey(ip)))
                || Boolean.TRUE.equals(redis.hasKey(sliderKey(deviceId)))) {
            throw new RateLimitException(ErrorCode.RISK_VERIFICATION_REQUIRED);
        }

        boolean ipMinute = exceeded(loginKey(RedisConstants.REDIS_IP_SCOPE, RedisConstants.REDIS_WINDOW_MINUTE, ip),
                RateLimitConstants.LOGIN_IP_PER_MINUTE, RateLimitConstants.ONE_MINUTE_SECONDS);
        boolean ipHour = exceeded(loginKey(RedisConstants.REDIS_IP_SCOPE, RedisConstants.REDIS_WINDOW_HOUR, ip),
                RateLimitConstants.LOGIN_IP_PER_HOUR, RateLimitConstants.ONE_HOUR_SECONDS);
        boolean deviceMinute = exceeded(
                loginKey(RedisConstants.REDIS_DEVICE_SCOPE, RedisConstants.REDIS_WINDOW_MINUTE, deviceId),
                RateLimitConstants.LOGIN_DEVICE_PER_MINUTE, RateLimitConstants.ONE_MINUTE_SECONDS);
        boolean accountMinute = exceeded(
                loginKey(RedisConstants.REDIS_ACCOUNT_SCOPE, RedisConstants.REDIS_WINDOW_MINUTE, normalizeUsername(username)),
                RateLimitConstants.LOGIN_ACCOUNT_PER_MINUTE, RateLimitConstants.ONE_MINUTE_SECONDS);

        if (ipMinute) {
            redis.opsForValue().set(blockKey(ip), RedisConstants.REDIS_LOCK_VALUE,
                    Duration.ofSeconds(RateLimitConstants.IP_BLOCK_SECONDS));
            log.warn("登录请求超限，IP 临时封锁 {} 秒", RateLimitConstants.IP_BLOCK_SECONDS);
            throw new RateLimitException(ErrorCode.RATE_LIMIT_EXCEEDED);
        }
        if (ipHour || deviceMinute) {
            markSlider(ip);
            markSlider(deviceId);
            throw new RateLimitException(ErrorCode.RISK_VERIFICATION_REQUIRED);
        }
        if (accountMinute) {
            throw new RateLimitException(ErrorCode.RATE_LIMIT_EXCEEDED);
        }
    }

    @Override
    public void recordCaptchaFailure(String ip, String deviceId) {
        long ipFailures = increment(riskFailKey(RedisConstants.REDIS_IP_SCOPE, ip),
                RateLimitConstants.RISK_FAIL_WINDOW_SECONDS);
        long deviceFailures = increment(riskFailKey(RedisConstants.REDIS_DEVICE_SCOPE, deviceId),
                RateLimitConstants.RISK_FAIL_WINDOW_SECONDS);

        if (ipFailures >= RateLimitConstants.RISK_BLOCK_THRESHOLD
                || deviceFailures >= RateLimitConstants.RISK_BLOCK_THRESHOLD) {
            redis.opsForValue().set(blockKey(ip), RedisConstants.REDIS_LOCK_VALUE,
                    Duration.ofSeconds(RateLimitConstants.IP_BLOCK_SECONDS));
            log.warn("验证码失败次数过高，IP 临时封锁 - ipFailures={}, deviceFailures={}", ipFailures, deviceFailures);
            return;
        }
        if (ipFailures >= RateLimitConstants.RISK_SLIDER_THRESHOLD
                || deviceFailures >= RateLimitConstants.RISK_SLIDER_THRESHOLD) {
            markSlider(ip);
            markSlider(deviceId);
        }
    }

    @Override
    public void recordAnonymousFailure(String ip, String deviceId) {
        recordCaptchaFailure(ip, deviceId);
    }

    // ==================== Redis Key ====================

    private String captchaKey(String scope, String window, String value) {
        return RedisConstants.REDIS_RATE_CAPTCHA_PREFIX + scope + window + value;
    }

    private String loginKey(String scope, String window, String value) {
        return RedisConstants.REDIS_RATE_LOGIN_PREFIX + scope + window + value;
    }

    private String riskFailKey(String scope, String value) {
        return RedisConstants.REDIS_RISK_FAIL_PREFIX + scope + value;
    }

    private String sliderKey(String identity) {
        return RedisConstants.REDIS_RISK_SLIDER_PREFIX + identity;
    }

    private void markSlider(String identity) {
        redis.opsForValue().set(sliderKey(identity), RedisConstants.REDIS_LOCK_VALUE,
                Duration.ofSeconds(RateLimitConstants.SLIDER_FLAG_SECONDS));
    }

    private String blockKey(String ip) {
        return RedisConstants.REDIS_RISK_BLOCK_PREFIX + ip;
    }

    private String normalizeUsername(String username) {
        if (username == null) {
            return "";
        }
        String trimmed = username.trim();
        return trimmed.length() > RateLimitConstants.MAX_USERNAME_LENGTH
                ? trimmed.substring(0, RateLimitConstants.MAX_USERNAME_LENGTH)
                : trimmed;
    }

    // ==================== 计数 ====================

    private boolean exceeded(String key, int limit, long windowSeconds) {
        return increment(key, windowSeconds) > limit;
    }

    private long increment(String key, long windowSeconds) {
        Long value = redis.execute(INCR_WITH_TTL_SCRIPT, Collections.singletonList(key),
                String.valueOf(windowSeconds));
        return value == null ? 0L : value;
    }
}
