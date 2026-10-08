package com.womi.webmodule.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

/**
 * Nonce 防重放服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class NonceService {

    private static final String KEY_PREFIX = "register:nonce:";
    private static final Duration TTL = Duration.ofMinutes(5);

    private final StringRedisTemplate redisTemplate;

    /**
     * 尝试占用 nonce（如果已被用过则返回 false）
     */
    public boolean tryAcquire(String nonce) {
        if (nonce == null || nonce.isBlank()) {
            return false;
        }
        String key = KEY_PREFIX + nonce;
        Boolean success = redisTemplate.opsForValue().setIfAbsent(key, "used", TTL);
        return Boolean.TRUE.equals(success);
    }
}