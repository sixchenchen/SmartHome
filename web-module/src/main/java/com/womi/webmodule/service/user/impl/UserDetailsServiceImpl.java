package com.womi.webmodule.service.user.impl;

import com.womi.businessmodule.mapper.sys.SysInfoMapper;
import com.womi.businessmodule.mapper.sys.SysPermissionMapper;
import com.womi.businessmodule.mapper.sys.SysRoleInfoMapper;
import com.womi.businessmodule.mapper.sys.SysRoleMapper;
import com.womi.businessmodule.model.sys.SysInfo;
import com.womi.businessmodule.model.sys.SysRole;
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

    private final SysInfoMapper sysInfoMapper;
    private final SysRoleInfoMapper sysRoleInfoMapper;
    private final SysRoleMapper sysRoleMapper;
    private final SysPermissionMapper sysPermissionMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // 1. 查用户
        SysInfo user = sysInfoMapper.selectByUsername(username);
        if (user == null) {
            throw new UsernameNotFoundException("用户不存在: " + username);
        }

        // 2. 查角色ID列表（通过 sys_role_info）
        List<Long> roleIds = sysRoleInfoMapper.selectRoleIdsByUserId(user.getId());
        List<SimpleGrantedAuthority> authorities = new ArrayList<>();

        if (!CollectionUtils.isEmpty(roleIds)) {
            // 3. 批量查角色实体（避免在循环里查库）
            List<SysRole> roles = sysRoleMapper.selectRolesByIds(roleIds);
            if (!CollectionUtils.isEmpty(roles)) {
                // 组装角色权限（注意加上 ROLE_ 前缀）
                roles.stream()
                        .filter(role -> role.getStatus() != null && role.getStatus() == 1)
                        .forEach(role -> authorities.add(new SimpleGrantedAuthority("ROLE_" + role.getRoleCode())));
            }

            // 4. 批量查权限编码（通过角色-权限关联表联表查询）
            List<String> permCodes = sysPermissionMapper.selectPermCodesByRoleIds(roleIds);
            if (!CollectionUtils.isEmpty(permCodes)) {
                permCodes.forEach(code -> authorities.add(new SimpleGrantedAuthority(code)));
            }
        }

        // 5. 返回自定义的 SecurityUser
        return new SecurityUser(user, authorities);
    }
}