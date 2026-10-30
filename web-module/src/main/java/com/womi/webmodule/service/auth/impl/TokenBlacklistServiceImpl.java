package com.womi.webmodule.service.auth.impl;

import com.womi.commonmodule.constants.RedisConstants;
import com.womi.commonmodule.constants.UserConstants;
import com.womi.webmodule.service.auth.LoginAttemptService;
import com.womi.webmodule.service.auth.TokenBlacklistService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Date;

@Service
@RequiredArgsConstructor
public class TokenBlacklistServiceImpl implements TokenBlacklistService {
    private final StringRedisTemplate redisTemplate;

    /**
     * 将 Token 加入黑名单
     * @param jti Token 的唯一标识
     * @param expiration Token 的过期时间
     */
    public void blacklistToken(String jti, Date expiration) {
        long ttlMillis = expiration.getTime() - System.currentTimeMillis();
        if (ttlMillis > 0) {
            // 将 jti 存入 Redis，过期时间与 Token 的剩余寿命一致，过期后自动清理
            redisTemplate.opsForValue().set(
                    RedisConstants.REDIS_TOKEN_BLACKLIST_PREFIX + jti,
                    RedisConstants.REDIS_BLACKLIST_VALUE,
                    Duration.ofMillis(ttlMillis)
            );
        }
    }

    /**
     * 检查 Token 是否在黑名单中
     */
    public boolean isBlacklisted(String jti) {
        return Boolean.TRUE.equals(redisTemplate.hasKey(RedisConstants.REDIS_TOKEN_BLACKLIST_PREFIX + jti));
    }
}