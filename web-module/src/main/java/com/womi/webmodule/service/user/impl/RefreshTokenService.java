package com.womi.webmodule.service.user.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.womi.businessmodule.mapper.sys.SysRefreshTokenMapper;
import com.womi.businessmodule.model.sys.SysRefreshToken;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RefreshTokenService {

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
        entity.setDeviceType(deviceType != null && !deviceType.isEmpty() ? deviceType : "web");
        entity.setExpiresAt(LocalDateTime.now().plusDays(7)); // 7天有效
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
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 算法不存在", e);
        }
    }
}