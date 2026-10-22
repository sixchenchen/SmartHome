package com.womi.webmodule.config;

import com.womi.commonmodule.constants.UserConstants;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Map;

@Component
public class JwtTokenProvider {


    @Value("${my.jwt.admin-secret-key}")
    private String adminSecretKey;

    @Value("${my.jwt.admin-ttl}")
    private long adminTtl;

    @Value("${my.jwt.user-secret-key}")
    private String userSecretKey;

    @Value("${my.jwt.user-ttl}")
    private long userTtl;

    public String generateToken(String username, String role, boolean isAdmin) {
        String secret = isAdmin ? adminSecretKey : userSecretKey;
        long ttl = isAdmin ? adminTtl : userTtl;

        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + ttl);

        // 统一使用 Keys.hmacShaKeyFor
        SecretKey key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));

        return Jwts.builder()
                .subject(username)
                .claim(UserConstants.USER_ROLE, role)
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(key)
                .compact();
    }

    public static String createJWT(String secretKey, long ttlMillis, Map<String, Object> claims) {
        long expMillis = System.currentTimeMillis() + ttlMillis;
        Date exp = new Date(expMillis);

        SecretKey key = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));

        JwtBuilder builder = Jwts.builder()
                .claims(claims)
                .expiration(exp)
                .signWith(key);

        return builder.compact();
    }

    public static Claims parseJWT(String secretKey, String token) {
        SecretKey key = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));

        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    // 验证 Token 是否有效
    public boolean validateToken(String token, boolean isAdmin) {
        try {
            getClaims(token, isAdmin);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            // 记录日志，Token 无效或已过期
            return false;
        }
    }

    private Claims getClaims(String token, boolean isAdmin) {
        String secret = isAdmin ? adminSecretKey : userSecretKey;
        SecretKey key = Keys.hmacShaKeyFor(Decoders.BASE64.decode(secret));
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
