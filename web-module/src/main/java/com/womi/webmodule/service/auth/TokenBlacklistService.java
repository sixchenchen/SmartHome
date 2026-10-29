package com.womi.webmodule.service.auth;

import java.util.Date;

public interface TokenBlacklistService {
    /**
     * 将 Token 加入黑名单
     * @param jti Token 的唯一标识
     * @param expiration Token 的过期时间
     */
    public void blacklistToken(String jti, Date expiration) ;

    /**
     * 检查 Token 是否在黑名单中
     */
    public boolean isBlacklisted(String jti);
}
