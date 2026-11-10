package com.womi.webmodule.service.sys.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.AdminRoleSaveRequest;
import com.womi.businessmodule.mapper.sys.SysPermissionMapper;
import com.womi.businessmodule.mapper.sys.SysRoleInfoMapper;
import com.womi.businessmodule.mapper.sys.SysRoleMapper;
import com.womi.businessmodule.mapper.sys.SysRolePermissionMapper;
import com.womi.businessmodule.model.sys.SysPermission;
import com.womi.businessmodule.model.sys.SysRole;
import com.womi.businessmodule.model.sys.SysRoleInfo;
import com.womi.businessmodule.model.sys.SysRolePermission;
import com.womi.businessmodule.vo.AdminRoleDetailVO;
import com.womi.businessmodule.vo.AdminRoleVO;
import com.womi.commonmodule.constants.RoleConstants;
import com.womi.commonmodule.constants.UserConstants;
import com.womi.commonmodule.enums.EnableStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.service.sys.AdminRoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminRoleServiceImpl implements AdminRoleService {

    private final SysRoleMapper sysRoleMapper;
    private final SysRoleInfoMapper sysRoleInfoMapper;
    private final SysRolePermissionMapper sysRolePermissionMapper;
    private final SysPermissionMapper sysPermissionMapper;

    @Override
    public Page<AdminRoleVO> pageRoles(Integer pageNum, Integer pageSize, String keyword, Integer status) {
        LambdaQueryWrapper<SysRole> wrapper = new LambdaQueryWrapper<SysRole>()
                .eq(status != null, SysRole::getStatus, status)
                .and(StringUtils.hasText(keyword), w -> w
                        .like(SysRole::getRoleCode, keyword)
                        .or().like(SysRole::getRoleName, keyword))
                .orderByDesc(SysRole::getBuiltIn)
                .orderByAsc(SysRole::getId);

        Page<SysRole> entityPage = sysRoleMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        Page<AdminRoleVO> result = new Page<>(entityPage.getCurrent(), entityPage.getSize(), entityPage.getTotal());
        result.setRecords(toRoleVOList(entityPage.getRecords()));
        return result;
    }

    @Override
    public List<AdminRoleVO> listAllRoles() {
        List<SysRole> roles = sysRoleMapper.selectList(new LambdaQueryWrapper<SysRole>()
                .orderByDesc(SysRole::getBuiltIn)
                .orderByAsc(SysRole::getId));
        return toRoleVOList(roles);
    }

    @Override
    public AdminRoleDetailVO getRoleDetail(Long roleId) {
        SysRole role = requireRole(roleId);
        return buildDetail(role);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long createRole(AdminRoleSaveRequest request) {
        String roleCode = request.getRoleCode().trim();
        if (sysRoleMapper.selectByRoleCode(roleCode) != null) {
            throw new BusinessException(ErrorCode.ROLE_CODE_EXIST);
        }

        SysRole role = new SysRole();
        role.setRoleCode(roleCode);
        role.setRoleName(request.getRoleName().trim());
        role.setDescription(request.getDescription());
        role.setStatus(request.getStatus() == null ? EnableStatus.ENABLED.getCode() : request.getStatus());
        role.setBuiltIn(RoleConstants.NOT_BUILT_IN);
        role.setDeleted(UserConstants.NOT_DELETED);
        try {
            sysRoleMapper.insert(role);
        } catch (DuplicateKeyException e) {
            throw new BusinessException(ErrorCode.ROLE_CODE_EXIST);
        }
        return role.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateRole(Long roleId, AdminRoleSaveRequest request) {
        SysRole role = requireRole(roleId);
        String roleCode = request.getRoleCode().trim();
        boolean builtIn = RoleConstants.BUILT_IN.equals(role.getBuiltIn());

        if (builtIn && !role.getRoleCode().equals(roleCode)) {
            throw new BusinessException(ErrorCode.ROLE_BUILT_IN_PROTECTED, "内置角色编码不允许修改");
        }
        if (builtIn && request.getStatus() != null && request.getStatus() == EnableStatus.DISABLED.getCode()) {
            throw new BusinessException(ErrorCode.ROLE_BUILT_IN_PROTECTED, "内置角色不允许禁用");
        }
        SysRole sameCode = sysRoleMapper.selectByRoleCode(roleCode);
        if (sameCode != null && !sameCode.getId().equals(roleId)) {
            throw new BusinessException(ErrorCode.ROLE_CODE_EXIST);
        }

        role.setRoleCode(roleCode);
        role.setRoleName(request.getRoleName().trim());
        role.setDescription(request.getDescription());
        if (request.getStatus() != null) {
            role.setStatus(request.getStatus());
        }
        try {
            sysRoleMapper.updateById(role);
        } catch (DuplicateKeyException e) {
            throw new BusinessException(ErrorCode.ROLE_CODE_EXIST);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateStatus(Long roleId, Integer status) {
        if (EnableStatus.fromCode(status) == null) {
            throw new BusinessException(ErrorCode.PARAM_INVALID, "角色状态值非法");
        }
        SysRole role = requireRole(roleId);
        if (RoleConstants.BUILT_IN.equals(role.getBuiltIn()) && status == EnableStatus.DISABLED.getCode()) {
            throw new BusinessException(ErrorCode.ROLE_BUILT_IN_PROTECTED, "内置角色不允许禁用");
        }
        SysRole update = new SysRole();
        update.setId(roleId);
        update.setStatus(status);
        sysRoleMapper.updateById(update);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteRole(Long roleId) {
        SysRole role = requireRole(roleId);
        if (RoleConstants.BUILT_IN.equals(role.getBuiltIn())) {
            throw new BusinessException(ErrorCode.ROLE_BUILT_IN_PROTECTED, "内置角色不允许删除");
        }
        Long userCount = sysRoleInfoMapper.selectCount(
                new LambdaQueryWrapper<SysRoleInfo>().eq(SysRoleInfo::getRoleId, roleId));
        if (userCount != null && userCount > 0) {
            throw new BusinessException(ErrorCode.ROLE_IN_USE);
        }

        sysRolePermissionMapper.delete(
                new LambdaQueryWrapper<SysRolePermission>().eq(SysRolePermission::getRoleId, roleId));
        // 逻辑删除并改写角色编码，避免唯一索引与后续同名角色冲突
        sysRoleMapper.update(null, Wrappers.<SysRole>lambdaUpdate()
                .set(SysRole::getRoleCode, role.getRoleCode() + UserConstants.DELETE_USER_NAME + roleId)
                .set(SysRole::getDeleted, UserConstants.LOGIC_DELETE_USER)
                .eq(SysRole::getId, roleId));
    }

    @Override
    public AdminRoleDetailVO getRolePermissions(Long roleId) {
        return buildDetail(requireRole(roleId));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateRolePermissions(Long roleId, List<Long> permissionIds) {
        requireRole(roleId);
        List<Long> targetIds = permissionIds == null ? Collections.emptyList()
                : permissionIds.stream().filter(Objects::nonNull).distinct().collect(Collectors.toList());

        if (!targetIds.isEmpty()) {
            Long existing = sysPermissionMapper.selectCount(new LambdaQueryWrapper<SysPermission>()
                    .in(SysPermission::getId, targetIds)
                    .eq(SysPermission::getDeleted, UserConstants.NOT_DELETED));
            if (existing == null || existing != targetIds.size()) {
                throw new BusinessException(ErrorCode.PERMISSION_NOT_FOUND, "存在无效的权限ID");
            }
        }

        sysRolePermissionMapper.delete(
                new LambdaQueryWrapper<SysRolePermission>().eq(SysRolePermission::getRoleId, roleId));
        for (Long permissionId : targetIds) {
            SysRolePermission relation = new SysRolePermission();
            relation.setRoleId(roleId);
            relation.setPermissionId(permissionId);
            sysRolePermissionMapper.insert(relation);
        }
    }

    private AdminRoleDetailVO buildDetail(SysRole role) {
        AdminRoleDetailVO detail = new AdminRoleDetailVO();
        BeanUtils.copyProperties(toRoleVOList(Collections.singletonList(role)).get(0), detail);

        List<Long> permissionIds = sysRolePermissionMapper.selectPermissionIdsByRoleId(role.getId());
        detail.setPermissionIds(permissionIds == null ? Collections.emptyList() : permissionIds);
        if (permissionIds == null || permissionIds.isEmpty()) {
            detail.setPermCodes(Collections.emptyList());
            return detail;
        }
        List<SysPermission> permissions = sysPermissionMapper.selectList(new LambdaQueryWrapper<SysPermission>()
                .in(SysPermission::getId, permissionIds)
                .eq(SysPermission::getDeleted, UserConstants.NOT_DELETED)
                .orderByAsc(SysPermission::getId));
        detail.setPermCodes(permissions.stream().map(SysPermission::getPermCode).collect(Collectors.toList()));
        return detail;
    }

    private List<AdminRoleVO> toRoleVOList(List<SysRole> roles) {
        if (roles == null || roles.isEmpty()) {
            return Collections.emptyList();
        }
        List<Long> roleIds = roles.stream().map(SysRole::getId).collect(Collectors.toList());
        Map<Long, Long> userCountMap = sysRoleInfoMapper.selectList(
                        new LambdaQueryWrapper<SysRoleInfo>().in(SysRoleInfo::getRoleId, roleIds))
                .stream().collect(Collectors.groupingBy(SysRoleInfo::getRoleId, Collectors.counting()));
        Map<Long, Long> permissionCountMap = sysRolePermissionMapper.selectList(
                        new LambdaQueryWrapper<SysRolePermission>().in(SysRolePermission::getRoleId, roleIds))
                .stream().collect(Collectors.groupingBy(SysRolePermission::getRoleId, Collectors.counting()));

        List<AdminRoleVO> result = new ArrayList<>(roles.size());
        for (SysRole role : roles) {
            AdminRoleVO vo = new AdminRoleVO();
            BeanUtils.copyProperties(role, vo);
            vo.setUserCount(userCountMap.getOrDefault(role.getId(), 0L));
            vo.setPermissionCount(permissionCountMap.getOrDefault(role.getId(), 0L));
            result.add(vo);
        }
        return result;
    }

    private SysRole requireRole(Long roleId) {
        SysRole role = sysRoleMapper.selectById(roleId);
        if (role == null) {
            throw new BusinessException(ErrorCode.ROLE_NOT_FOUND);
        }
        return role;
    }
}
