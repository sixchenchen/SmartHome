package com.womi.webmodule.service.auth;

import com.womi.businessmodule.model.sys.SysRefreshToken;

public interface RefreshTokenService {

    /**
     * 生成并保存 RefreshToken（返回明文，数据库存哈希）
     */
    public String createRefreshToken(Long userId, String deviceType);

    /**
     * 验证 RefreshToken 是否有效
     */
    public SysRefreshToken verifyRefreshToken(String rawToken);

    /**
     * 原子核销 RefreshToken（防并发双花）
     *
     * @return 核销成功返回实体，失败（已用、过期或不存在）返回 null
     */
    public SysRefreshToken consumeRefreshToken(String rawToken);

    /**
     * 撤销单个 RefreshToken（登出时用）
     */
    public void revokeToken(String rawToken);

    /**
     * 撤销用户的所有 RefreshToken（改密码或强制下线时用）
     */
    public void revokeAllUserTokens(Long userId);

}