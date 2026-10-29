package com.womi.webmodule.service.auth.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.womi.businessmodule.mapper.sys.SysRefreshTokenMapper;
import com.womi.businessmodule.model.sys.SysRefreshToken;
import com.womi.commonmodule.constants.UserConstants;
import com.womi.webmodule.service.auth.LoginAttemptService;
import com.womi.webmodule.service.auth.RefreshTokenService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RefreshTokenServiceImpl implements RefreshTokenService {

    private final SysRefreshTokenMapper refreshTokenMapper;

    /**
     * 生成并保存 RefreshToken（返回明文，数据库存哈希）
     */
    public String createRefreshToken(Long userId, String deviceType) {
        // 1. 生成随机 Token
        String rawToken = UUID.randomUUID().toString().replace("-", "")
                + UUID.randomUUID().toString().replace("-", ""); // 64位字符

        // 2. 存库
        SysRefreshToken entity = new SysRefreshToken();
        entity.setUserId(userId);
        entity.setTokenHash(hashToken(rawToken));
        entity.setDeviceType(StringUtils.hasText(deviceType) ? deviceType : UserConstants.DEFAULT_DEVICE_TYPE);
        entity.setExpiresAt(LocalDateTime.now().plusDays(UserConstants.REFRESH_TOKEN_EXPIRE_DAYS));
        entity.setRevoked(0);
        refreshTokenMapper.insert(entity);

        return rawToken;
    }

    /**
     * 验证 RefreshToken 是否有效
     */
    public SysRefreshToken verifyRefreshToken(String rawToken) {
        String hash = hashToken(rawToken);
        SysRefreshToken entity = refreshTokenMapper.selectOne(
                new LambdaQueryWrapper<SysRefreshToken>()
                        .eq(SysRefreshToken::getTokenHash, hash)
                        .eq(SysRefreshToken::getRevoked, 0)
        );

        if (entity == null || entity.getExpiresAt().isBefore(LocalDateTime.now())) {
            return null; // 无效或已过期
        }
        return entity;
    }

    /**
     * 原子核销 RefreshToken（防并发双花）
     * @return 核销成功返回实体，失败（已用、过期或不存在）返回 null
     */
    @Transactional(rollbackFor = Exception.class)
    public SysRefreshToken consumeRefreshToken(String rawToken) {
        if (!StringUtils.hasText(rawToken)) {
            return null;
        }
        String hash = hashToken(rawToken);
        LocalDateTime now = LocalDateTime.now();

        // 1. 原子更新：直接去数据库里抢占这个 Token
        int rows = refreshTokenMapper.update(null, new LambdaUpdateWrapper<SysRefreshToken>()
                .set(SysRefreshToken::getRevoked, 1)
                .set(SysRefreshToken::getUpdateTime, now)
                .eq(SysRefreshToken::getTokenHash, hash)
                .eq(SysRefreshToken::getRevoked, 0)           // 只能更新未作废的
                .gt(SysRefreshToken::getExpiresAt, now)       // 必须未过期
        );

        // 2. 如果 rows == 0，说明这个 Token 无效、过期，或者被另一个并发请求抢先用掉了
        if (rows == 0) {
            return null;
        }

        // 3. 抢占成功，查出记录并返回（供生成新 Token 使用）
        return refreshTokenMapper.selectOne(
                new LambdaQueryWrapper<SysRefreshToken>()
                        .eq(SysRefreshToken::getTokenHash, hash)
        );
    }

    /**
     * 撤销单个 RefreshToken（登出时用）
     */
    public void revokeToken(String rawToken) {
        String hash = hashToken(rawToken);
        refreshTokenMapper.update(null, new LambdaUpdateWrapper<SysRefreshToken>()
                .set(SysRefreshToken::getRevoked, 1)
                .eq(SysRefreshToken::getTokenHash, hash));
    }

    /**
     * 撤销用户的所有 RefreshToken（改密码或强制下线时用）
     */
    public void revokeAllUserTokens(Long userId) {
        refreshTokenMapper.update(null, new LambdaUpdateWrapper<SysRefreshToken>()
                .set(SysRefreshToken::getRevoked, 1)
                .eq(SysRefreshToken::getUserId, userId)
                .eq(SysRefreshToken::getRevoked, 0));
    }

    /**
     * SHA-256 哈希算法
     */
    private String hashToken(String token) {
        try {
            // 使用常量
            MessageDigest digest = MessageDigest.getInstance(UserConstants.HASH_ALGORITHM_SHA256);
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("系统缺少 " + UserConstants.HASH_ALGORITHM_SHA256 + " 算法", e);
        }
    }
}