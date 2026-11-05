package com.womi.webmodule.service.sys;

import java.util.List;

/**
 * 用户角色与权限装配服务
 * <p>统一收口用户角色的读取与替换，避免各业务服务重复实现。</p>
 */
public interface UserGrantService {

    /**
     * 查询用户角色编码
     */
    List<String> getRoleCodes(Long userId);

    /**
     * 查询用户权限码
     */
    List<String> getPermissionCodes(Long userId);

    /**
     * 覆盖式替换用户角色
     */
    void replaceRoles(Long userId, List<String> roleCodes);
}
