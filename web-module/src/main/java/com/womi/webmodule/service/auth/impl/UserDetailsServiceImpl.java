package com.womi.webmodule.service.auth.impl;

import com.womi.businessmodule.mapper.sys.SysUserMapper;
import com.womi.businessmodule.mapper.sys.SysPermissionMapper;
import com.womi.businessmodule.mapper.sys.SysRoleInfoMapper;
import com.womi.businessmodule.mapper.sys.SysRoleMapper;
import com.womi.businessmodule.model.sys.SysUser;
import com.womi.businessmodule.model.sys.SysRole;
import com.womi.commonmodule.constants.UserConstants;
import com.womi.webmodule.service.auth.SecurityUser;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final SysUserMapper sysUserMapper;
    private final SysRoleInfoMapper sysRoleInfoMapper;
    private final SysRoleMapper sysRoleMapper;
    private final SysPermissionMapper sysPermissionMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // 1. 查用户
        SysUser user = sysUserMapper.selectByUsername(username);
        if (user == null) {
            throw new UsernameNotFoundException("用户不存在: " + username);
        }

        // 2. 查角色ID列表（通过 sys_role_info）
        List<Long> roleIds = sysRoleInfoMapper.selectRoleIdsByUserId(user.getId());
        List<SimpleGrantedAuthority> authorities = new ArrayList<>();

        if (!CollectionUtils.isEmpty(roleIds)) {
            List<SysRole> roles = sysRoleMapper.selectRolesByIds(roleIds);
            if (!CollectionUtils.isEmpty(roles)) {
                roles.stream()
                        .filter(role -> UserConstants.ENABLE_USER.equals(role.getStatus()))
                        .forEach(role -> authorities.add(new SimpleGrantedAuthority(UserConstants.ROLE_PREFIX + role.getRoleCode())));
            }

            List<String> permCodes = sysPermissionMapper.selectPermCodesByRoleIds(roleIds);
            if (!CollectionUtils.isEmpty(permCodes)) {
                permCodes.forEach(code -> authorities.add(new SimpleGrantedAuthority(code)));
            }
        }

        // 5. 返回自定义的 SecurityUser
        return new SecurityUser(user, authorities);
    }
}