package com.womi.webmodule.service.sys.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.AdminPermissionSaveRequest;
import com.womi.businessmodule.mapper.sys.SysPermissionMapper;
import com.womi.businessmodule.mapper.sys.SysRolePermissionMapper;
import com.womi.businessmodule.model.sys.SysPermission;
import com.womi.businessmodule.model.sys.SysRolePermission;
import com.womi.businessmodule.vo.AdminPermissionVO;
import com.womi.commonmodule.constants.PermissionTypeConstants;
import com.womi.commonmodule.constants.UserConstants;
import com.womi.commonmodule.enums.EnableStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.service.sys.AdminPermissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminPermissionServiceImpl implements AdminPermissionService {

    private final SysPermissionMapper sysPermissionMapper;
    private final SysRolePermissionMapper sysRolePermissionMapper;

    @Override
    public Page<AdminPermissionVO> pagePermissions(Integer pageNum, Integer pageSize, String keyword,
                                                   String permType, String resource, Integer status) {
        String normalizedType = StringUtils.hasText(permType) ? normalizeType(permType) : null;
        String normalizedResource = StringUtils.hasText(resource) ? resource.trim() : null;
        LambdaQueryWrapper<SysPermission> wrapper = new LambdaQueryWrapper<SysPermission>()
                .eq(SysPermission::getDeleted, UserConstants.NOT_DELETED)
                .eq(status != null, SysPermission::getStatus, status)
                .eq(normalizedType != null, SysPermission::getPermType, normalizedType)
                .eq(normalizedResource != null, SysPermission::getResource, normalizedResource)
                .and(StringUtils.hasText(keyword), w -> w
                        .like(SysPermission::getPermCode, keyword)
                        .or().like(SysPermission::getPermName, keyword))
                .orderByAsc(SysPermission::getResource)
                .orderByAsc(SysPermission::getId);

        Page<SysPermission> entityPage = sysPermissionMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        Page<AdminPermissionVO> result = new Page<>(entityPage.getCurrent(), entityPage.getSize(), entityPage.getTotal());
        result.setRecords(toPermissionVOList(entityPage.getRecords()));
        return result;
    }

    @Override
    public List<AdminPermissionVO> listAllPermissions() {
        List<SysPermission> permissions = sysPermissionMapper.selectList(new LambdaQueryWrapper<SysPermission>()
                .eq(SysPermission::getDeleted, UserConstants.NOT_DELETED)
                .orderByAsc(SysPermission::getResource)
                .orderByAsc(SysPermission::getId));
        return toPermissionVOList(permissions);
    }

    @Override
    public AdminPermissionVO getPermission(Long permissionId) {
        return toPermissionVOList(Collections.singletonList(requirePermission(permissionId))).get(0);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long createPermission(AdminPermissionSaveRequest request) {
        String permCode = request.getPermCode().trim().toLowerCase(Locale.ROOT);
        if (sysPermissionMapper.selectByPermCode(permCode) != null) {
            throw new BusinessException(ErrorCode.PERMISSION_CODE_EXIST);
        }

        String permType = normalizeType(request.getPermType());
        String[] segments = splitPermCode(permCode);

        SysPermission permission = new SysPermission();
        permission.setPermCode(permCode);
        permission.setPermName(request.getPermName().trim());
        permission.setPermType(permType);
        permission.setResource(StringUtils.hasText(request.getResource()) ? request.getResource().trim() : segments[0]);
        permission.setAction(StringUtils.hasText(request.getAction()) ? request.getAction().trim() : segments[1]);
        permission.setDescription(request.getDescription());
        permission.setStatus(request.getStatus() == null ? EnableStatus.ENABLED.getCode() : request.getStatus());
        permission.setDeleted(UserConstants.NOT_DELETED);
        try {
            sysPermissionMapper.insert(permission);
        } catch (DuplicateKeyException e) {
            throw new BusinessException(ErrorCode.PERMISSION_CODE_EXIST);
        }
        return permission.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updatePermission(Long permissionId, AdminPermissionSaveRequest request) {
        SysPermission permission = requirePermission(permissionId);
        String permCode = request.getPermCode().trim().toLowerCase(Locale.ROOT);
        if (!permission.getPermCode().equals(permCode)) {
            throw new BusinessException(ErrorCode.PERMISSION_CODE_IMMUTABLE);
        }

        String permType = normalizeType(request.getPermType());
        String[] segments = splitPermCode(permCode);

        permission.setPermName(request.getPermName().trim());
        permission.setPermType(permType);
        permission.setResource(StringUtils.hasText(request.getResource()) ? request.getResource().trim() : segments[0]);
        permission.setAction(StringUtils.hasText(request.getAction()) ? request.getAction().trim() : segments[1]);
        permission.setDescription(request.getDescription());
        if (request.getStatus() != null) {
            permission.setStatus(request.getStatus());
        }
        sysPermissionMapper.updateById(permission);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateStatus(Long permissionId, Integer status) {
        if (EnableStatus.fromCode(status) == null) {
            throw new BusinessException(ErrorCode.PARAM_INVALID, "权限状态值非法");
        }
        requirePermission(permissionId);
        SysPermission update = new SysPermission();
        update.setId(permissionId);
        update.setStatus(status);
        sysPermissionMapper.updateById(update);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deletePermission(Long permissionId) {
        SysPermission permission = requirePermission(permissionId);
        Long roleCount = sysRolePermissionMapper.selectCount(
                new LambdaQueryWrapper<SysRolePermission>().eq(SysRolePermission::getPermissionId, permissionId));
        if (roleCount != null && roleCount > 0) {
            throw new BusinessException(ErrorCode.PERMISSION_IN_USE);
        }

        // 逻辑删除并改写权限编码，避免唯一索引与后续同编码权限冲突
        sysPermissionMapper.update(null, Wrappers.<SysPermission>lambdaUpdate()
                .set(SysPermission::getPermCode, permission.getPermCode() + UserConstants.DELETE_USER_NAME + permissionId)
                .set(SysPermission::getStatus, EnableStatus.DISABLED.getCode())
                .set(SysPermission::getDeleted, UserConstants.LOGIC_DELETE_USER)
                .eq(SysPermission::getId, permissionId));
    }

    private List<AdminPermissionVO> toPermissionVOList(List<SysPermission> permissions) {
        if (permissions == null || permissions.isEmpty()) {
            return Collections.emptyList();
        }
        List<Long> permissionIds = permissions.stream().map(SysPermission::getId).collect(Collectors.toList());
        Map<Long, Long> roleCountMap = sysRolePermissionMapper.selectList(
                        new LambdaQueryWrapper<SysRolePermission>().in(SysRolePermission::getPermissionId, permissionIds))
                .stream().collect(Collectors.groupingBy(SysRolePermission::getPermissionId, Collectors.counting()));

        List<AdminPermissionVO> result = new ArrayList<>(permissions.size());
        for (SysPermission permission : permissions) {
            AdminPermissionVO vo = new AdminPermissionVO();
            BeanUtils.copyProperties(permission, vo);
            vo.setRoleCount(roleCountMap.getOrDefault(permission.getId(), 0L));
            result.add(vo);
        }
        return result;
    }

    private SysPermission requirePermission(Long permissionId) {
        SysPermission permission = sysPermissionMapper.selectById(permissionId);
        if (permission == null || permission.getDeleted() == null || permission.getDeleted() != 0) {
            throw new BusinessException(ErrorCode.PERMISSION_NOT_FOUND);
        }
        return permission;
    }

    private String normalizeType(String permType) {
        String type = permType.trim().toUpperCase(Locale.ROOT);
        if (!PermissionTypeConstants.VALID_TYPES.contains(type)) {
            throw new BusinessException(ErrorCode.PERMISSION_TYPE_INVALID);
        }
        return type;
    }

    /** 权限编码格式已由正则保证包含冒号 */
    private String[] splitPermCode(String permCode) {
        return permCode.split(":", 2);
    }
}
