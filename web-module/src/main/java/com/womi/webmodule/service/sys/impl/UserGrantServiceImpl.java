package com.womi.webmodule.service.sys.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.womi.businessmodule.mapper.sys.SysPermissionMapper;
import com.womi.businessmodule.mapper.sys.SysRoleInfoMapper;
import com.womi.businessmodule.mapper.sys.SysRoleMapper;
import com.womi.businessmodule.model.sys.SysRole;
import com.womi.businessmodule.model.sys.SysRoleInfo;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.service.sys.UserGrantService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserGrantServiceImpl implements UserGrantService {

    private final SysRoleMapper sysRoleMapper;
    private final SysRoleInfoMapper sysRoleInfoMapper;
    private final SysPermissionMapper sysPermissionMapper;

    @Override
    public List<String> getRoleCodes(Long userId) {
        List<Long> roleIds = sysRoleInfoMapper.selectRoleIdsByUserId(userId);
        if (roleIds == null || roleIds.isEmpty()) {
            return Collections.emptyList();
        }
        return sysRoleMapper.selectRolesByIds(roleIds).stream()
                .map(SysRole::getRoleCode)
                .collect(Collectors.toList());
    }

    @Override
    public List<String> getPermissionCodes(Long userId) {
        List<Long> roleIds = sysRoleInfoMapper.selectRoleIdsByUserId(userId);
        if (roleIds == null || roleIds.isEmpty()) {
            return Collections.emptyList();
        }
        List<String> codes = sysPermissionMapper.selectPermCodesByRoleIds(roleIds);
        return codes == null ? Collections.emptyList() : codes;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void replaceRoles(Long userId, List<String> roleCodes) {
        List<SysRole> roles = new ArrayList<>();
        for (String roleCode : roleCodes) {
            SysRole role = sysRoleMapper.selectByRoleCode(roleCode);
            if (role == null || (role.getStatus() != null && role.getStatus() != 1)) {
                throw new BusinessException(ErrorCode.PARAM_INVALID, "角色不存在或已禁用: " + roleCode);
            }
            roles.add(role);
        }
        sysRoleInfoMapper.delete(Wrappers.<SysRoleInfo>lambdaQuery().eq(SysRoleInfo::getUserId, userId));
        for (SysRole role : roles) {
            sysRoleInfoMapper.insertUserRole(userId, role.getId());
        }
    }
}
