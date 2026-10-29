package com.womi.webmodule.service.auth.impl;

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

/**
 * 登录失败计数 & 账号锁定
 * 策略：同一用户名连续失败 5 次，锁定 15 分钟
 * 存储：Redis
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class LoginAttemptServiceImpl implements LoginAttemptService {

    private static final Duration LOCK_DURATION = Duration.ofMinutes(UserConstants.LOGIN_LOCK_MINUTES);
    private static final int MAX_FAIL = UserConstants.LOGIN_MAX_FAIL;
    private static final int MAX_FAIL_IP = 20;
    private static final int MAX_FAIL_USER = UserConstants.LOGIN_MAX_FAIL;
    private final StringRedisTemplate redis;

    /**
     * 检查账号是否处于锁定状态。命中锁定直接抛，不进入 authenticate。
     */
    public void checkNotLocked(String ip, String username) {
        // 1. 检查 IP + 账号 是否被锁
        String userLockKey = RedisConstants.REDIS_LOGIN_LOCK_PREFIX + "user:" + ip + ":" + username;
        if (Boolean.TRUE.equals(redis.hasKey(userLockKey))) {
            long remainSeconds = getLockRemainSeconds(userLockKey);
            long remainMinutes = Math.max(1, (remainSeconds + UserConstants.SECONDS_PER_MINUTE - 1) / UserConstants.SECONDS_PER_MINUTE);
            log.warn("登录被拒：IP+账号已锁定, ip={}, username={}, 剩余 {} 秒", ip, username, remainSeconds);
            throw new BusinessException(ErrorCode.ACCOUNT_LOCKED, "密码错误次数过多，请 " + remainMinutes + " 分钟后再试");
        }

        // 2. 检查 单IP 是否被全局封锁
        String ipLockKey = RedisConstants.REDIS_LOGIN_LOCK_PREFIX + "ip:" + ip;
        if (Boolean.TRUE.equals(redis.hasKey(ipLockKey))) {
            long remainSeconds = getLockRemainSeconds(ipLockKey);
            long remainMinutes = Math.max(1, (remainSeconds + UserConstants.SECONDS_PER_MINUTE - 1) / UserConstants.SECONDS_PER_MINUTE);
            log.warn("登录被拒：当前 IP 已被全局封锁, ip={}", ip);
            throw new BusinessException(ErrorCode.ACCOUNT_LOCKED, "当前网络环境异常，请 " + remainMinutes + " 分钟后再试");
        }
    }

    /**
     * 记录一次失败。达到阈值自动锁定。
     */
    public void recordFailure(String ip, String username) {
        // ==================== 维度 1：IP + 账号 ====================
        String userFailKey = RedisConstants.REDIS_LOGIN_FAIL_PREFIX + "user:" + ip + ":" + username;
        Long countUser = redis.opsForValue().increment(userFailKey);
        if (countUser != null) {
            if (countUser == 1) {
                redis.expire(userFailKey, LOCK_DURATION);
            }
            log.info("登录失败计数 ip={}, username={}, 次数={}/{}", ip, username, countUser, MAX_FAIL_USER);
            if (countUser >= MAX_FAIL_USER) {
                String userLockKey = RedisConstants.REDIS_LOGIN_LOCK_PREFIX + "user:" + ip + ":" + username;
                redis.opsForValue().set(userLockKey, RedisConstants.REDIS_LOCK_VALUE, LOCK_DURATION);
                redis.delete(userFailKey); // 锁定后清零
                log.warn("账号被临时锁定 - ip={}, username={}", ip, username);
            }
        }

        // ==================== 维度 2：单 IP 总次数 ====================
        String ipFailKey = RedisConstants.REDIS_LOGIN_FAIL_PREFIX + "ip:" + ip;
        Long countIp = redis.opsForValue().increment(ipFailKey);
        if (countIp != null) {
            if (countIp == 1) {
                redis.expire(ipFailKey, LOCK_DURATION);
            }
            if (countIp >= MAX_FAIL_IP) {
                String ipLockKey = RedisConstants.REDIS_LOGIN_LOCK_PREFIX + "ip:" + ip;
                redis.opsForValue().set(ipLockKey, RedisConstants.REDIS_LOCK_VALUE, LOCK_DURATION);
                redis.delete(ipFailKey);
                log.warn("IP 因异常频繁请求被全局封锁 - ip={}", ip);
            }
        }
    }

    /**
     * 记录一次成功。清空该 IP 下针对该账号的失败计数。
     */
    public void recordSuccess(String ip, String username) {
        redis.delete(RedisConstants.REDIS_LOGIN_FAIL_PREFIX + "user:" + ip + ":" + username);
        redis.delete(RedisConstants.REDIS_LOGIN_LOCK_PREFIX + "user:" + ip + ":" + username);
    }


    /**
     * 查询剩余锁定秒数（0 表示未锁定）。
     */
    public long getLockRemainSeconds(String username) {
        Long ttl = redis.getExpire(RedisConstants.REDIS_LOGIN_LOCK_PREFIX + username);
        return (ttl != null && ttl > 0) ? ttl : 0;
    }
}