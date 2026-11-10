package com.womi.webmodule.service.auth.impl;

import com.womi.commonmodule.constants.RateLimitConstants;
import com.womi.commonmodule.constants.RedisConstants;
import com.womi.commonmodule.constants.UserConstants;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.service.auth.LoginAttemptService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.List;

/**
 * 账号维度登录失败计数与锁定
 *
 * 失败计数窗口 1 小时；达到 5 次锁定 15 分钟，达到 10 次锁定 1 小时并清零计数
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class LoginAttemptServiceImpl implements LoginAttemptService {

    private static final Duration FAIL_WINDOW = Duration.ofSeconds(RateLimitConstants.RISK_FAIL_WINDOW_SECONDS);

    private final StringRedisTemplate redis;

    @Override
    public void checkNotLocked(String username) {
        long remainSeconds = getLockRemainSeconds(username);
        if (remainSeconds <= 0) {
            return;
        }
        long remainMinutes = Math.max(1,
                (remainSeconds + UserConstants.SECONDS_PER_MINUTE - 1) / UserConstants.SECONDS_PER_MINUTE);
        log.warn("登录被拒：账号已锁定, username={}, 剩余 {} 秒", username, remainSeconds);
        throw new BusinessException(ErrorCode.ACCOUNT_LOCKED, "密码错误次数过多，请 " + remainMinutes + " 分钟后再试");
    }

    @Override
    public void recordPasswordFailure(String username) {
        String failKey = failKey(username);
        Long count = redis.opsForValue().increment(failKey);
        if (count == null) {
            return;
        }
        if (count == 1L) {
            redis.expire(failKey, FAIL_WINDOW);
        }

        if (count >= RateLimitConstants.PASSWORD_LOCK_LONG_THRESHOLD) {
            lock(username, RateLimitConstants.PASSWORD_LOCK_LONG_SECONDS);
            redis.delete(failKey);
            log.warn("账号长时间锁定 - username={}, 失败次数={}", username, count);
        } else if (count >= RateLimitConstants.PASSWORD_LOCK_THRESHOLD) {
            lock(username, RateLimitConstants.PASSWORD_LOCK_SECONDS);
            log.warn("账号临时锁定 - username={}, 失败次数={}", username, count);
        }
    }

    @Override
    public void recordSuccess(String username) {
        redis.delete(List.of(failKey(username), lockKey(username)));
    }

    @Override
    public long getLockRemainSeconds(String username) {
        Long ttl = redis.getExpire(lockKey(username));
        return ttl != null && ttl > 0 ? ttl : 0;
    }

    private void lock(String username, long seconds) {
        redis.opsForValue().set(lockKey(username), RedisConstants.REDIS_LOCK_VALUE,
                Duration.ofSeconds(seconds));
    }

    private String failKey(String username) {
        return RedisConstants.REDIS_LOGIN_FAIL_PREFIX + RedisConstants.REDIS_ACCOUNT_SCOPE + username;
    }

    private String lockKey(String username) {
        return RedisConstants.REDIS_LOGIN_LOCK_PREFIX + RedisConstants.REDIS_ACCOUNT_SCOPE + username;
    }
}
