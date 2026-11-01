package com.womi.webmodule.service.mqtt.impl;

import com.womi.webmodule.service.mqtt.NonceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

/**
 * Nonce 防重放服务实现
 *
 * <p>基于 Redis 存储已使用的 nonce，TTL 内不可重复使用。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceNonceServiceImpl implements NonceService {

    /** Redis Key 前缀 */
    private static final String KEY_PREFIX = "register:nonce:";

    /** Nonce 有效期：5 分钟 */
    private static final Duration TTL = Duration.ofMinutes(5);

    private final StringRedisTemplate redisTemplate;

    @Override
    public boolean exists(String nonce) {
        if (nonce == null || nonce.isBlank()) {
            return false;
        }
        String key = KEY_PREFIX + nonce;
        Boolean has = redisTemplate.hasKey(key);
        return Boolean.TRUE.equals(has);
    }

    @Override
    public boolean tryAcquire(String nonce) {
        if (nonce == null || nonce.isBlank()) {
            return false;
        }
        String key = KEY_PREFIX + nonce;
        Boolean success = redisTemplate.opsForValue().setIfAbsent(key, "used", TTL);
        return Boolean.TRUE.equals(success);
    }

    @Override
    public void release(String nonce) {
        if (nonce == null || nonce.isBlank()) {
            return;
        }

        try {
            redisTemplate.delete(KEY_PREFIX + nonce);
            log.debug("已释放 nonce - nonce: {}", nonce);
        } catch (Exception e) {
            // 吞掉异常，防止因为释放失败导致原本的业务异常被覆盖
            log.error("释放 nonce 失败（请检查 Redis 连接） - nonce: {}", nonce, e);
        }
    }
}