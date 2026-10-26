package com.womi.webmodule.service.user.impl;

import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

/**
 * 登录失败计数 & 账号锁定
 * 策略：同一用户名连续失败 5 次，锁定 15 分钟
 * 存储：Redis，key = login:fail:{username} / login:lock:{username}
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class LoginAttemptService {

    private static final int MAX_FAIL = 5;
    private static final Duration LOCK_DURATION = Duration.ofMinutes(15);
    private static final String FAIL_KEY_PREFIX = "login:fail:";
    private static final String LOCK_KEY_PREFIX = "login:lock:";

    private final StringRedisTemplate redis;

    /**
     * 检查账号是否处于锁定状态。命中锁定直接抛，不进入 authenticate。
     */
    public void checkNotLocked(String username) {
        if (redis.hasKey(LOCK_KEY_PREFIX + username)) {
            long remainSeconds = getLockRemainSeconds(username);
            long remainMinutes = Math.max(1, (remainSeconds + 59) / 60);   // 向上取整
            log.warn("登录被拒：账号已锁定, username={}, 剩余 {} 秒", username, remainSeconds);
            throw new BusinessException(ErrorCode.ACCOUNT_LOCKED,
                    "账号已锁定，请 " + remainMinutes + " 分钟后再试");
        }
    }

    /**
     * 记录一次失败。达到阈值自动锁定。
     */
    public void recordFailure(String username) {
        String failKey = FAIL_KEY_PREFIX + username;
        Long count = redis.opsForValue().increment(failKey);
        if (count == null) {
            log.error("Redis INCR 返回 null, username={}", username);
            return;
        }

        // 首次失败：设置 TTL，避免 key 永久堆积
        if (count == 1) {
            redis.expire(failKey, LOCK_DURATION);
        }

        log.info("登录失败计数 username={}, 当前失败次数={}/{}", username, count, MAX_FAIL);

        if (count >= MAX_FAIL) {
            String lockKey = LOCK_KEY_PREFIX + username;
            redis.opsForValue().set(lockKey, "1", LOCK_DURATION);
            redis.delete(failKey);   // 计数清零，解锁后重新累计
            log.warn("账号 [{}] 连续失败 {} 次，已锁定 {} 分钟", username, count, LOCK_DURATION.toMinutes());
        }
    }

    /**
     * 记录一次成功。清空失败计数和锁定标记。
     */
    public void recordSuccess(String username) {
        redis.delete(FAIL_KEY_PREFIX + username);
        redis.delete(LOCK_KEY_PREFIX + username);
    }

    /**
     * 查询剩余锁定秒数（0 表示未锁定）。
     */
    public long getLockRemainSeconds(String username) {
        Long ttl = redis.getExpire(LOCK_KEY_PREFIX + username);
        return ttl > 0 ? ttl : 0;
    }
}