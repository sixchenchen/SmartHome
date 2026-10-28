package com.womi.commonmodule.utils;

import com.womi.commonmodule.constants.ErrorInfoConstants;
import com.womi.commonmodule.constants.JWTConstants;
import com.womi.commonmodule.exception.BusinessException;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.UUID;

@Component
public class JwtTokenUtil {

    private final SecretKey key;
    private final long expirationMs;
    public JwtTokenUtil(@Value("${my.jwt.secret}") String secret,
                        @Value("${my.jwt.expiration-ms:86400000}") long expirationMs) {
        if (secret == null || secret.isBlank()) {
            throw new BusinessException(ErrorInfoConstants.JWT_SECRET_NOT_CONFIG);
        }
        byte[] keyBytes;
        keyBytes = Decoders.BASE64.decode(secret);
        if (keyBytes.length < JWTConstants.KEY_LENGTH) {
            throw new BusinessException(ErrorInfoConstants.JWT_SECRET_TOO_SHORT);
        }
        this.key = Keys.hmacShaKeyFor(keyBytes);
        this.expirationMs = expirationMs;
    }

    public String generateToken(UserDetails userDetails) {
        Date now = new Date();
        return Jwts.builder()
                .id(UUID.randomUUID().toString())
                .subject(userDetails.getUsername())
                .issuedAt(now)
                .expiration(new Date(now.getTime() + expirationMs))
                .signWith(key)
                .compact();
    }

    public String extractUsername(String token) {
        return parseClaims(token).getSubject();
    }

    public boolean validateToken(String token, UserDetails userDetails) {
        try {
            Claims claims = parseClaims(token);
            return claims.getSubject().equals(userDetails.getUsername())
                    && claims.getExpiration().after(new Date());
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    private Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public long getExpirationMs() {
        return expirationMs;
    }

    public String extractJti(String token) {
        return parseClaims(token).getId();
    }

    public Date extractExpiration(String token) {
        return parseClaims(token).getExpiration();
    }

}