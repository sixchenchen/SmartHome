package com.womi.webmodule.service.user.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.AdminUserCreateRequest;
import com.womi.businessmodule.dto.AdminUserUpdateRequest;
import com.womi.businessmodule.mapper.device.DeviceBindingMapper;
import com.womi.businessmodule.mapper.device.DeviceInfoMapper;
import com.womi.businessmodule.mapper.sys.SysLoginLogMapper;
import com.womi.businessmodule.mapper.sys.SysRoleInfoMapper;
import com.womi.businessmodule.mapper.sys.SysRoleMapper;
import com.womi.businessmodule.mapper.sys.SysUserMapper;
import com.womi.businessmodule.model.device.DeviceBinding;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.model.sys.SysLoginLog;
import com.womi.businessmodule.model.sys.SysRole;
import com.womi.businessmodule.model.sys.SysRoleInfo;
import com.womi.businessmodule.model.sys.SysUser;
import com.womi.businessmodule.vo.AdminUserDetailVO;
import com.womi.businessmodule.vo.AdminUserVO;
import com.womi.businessmodule.vo.device.DeviceInfoVO;
import com.womi.commonmodule.constants.RedisConstants;
import com.womi.commonmodule.constants.UserConstants;
import com.womi.commonmodule.enums.BindStatus;
import com.womi.commonmodule.enums.EnableStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.utils.MacUtils;
import com.womi.webmodule.service.sys.UserGrantService;
import com.womi.webmodule.service.user.AdminUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminUserServiceImpl implements AdminUserService {

    private final SysUserMapper sysUserMapper;
    private final SysLoginLogMapper sysLoginLogMapper;
    private final SysRoleMapper sysRoleMapper;
    private final SysRoleInfoMapper sysRoleInfoMapper;
    private final DeviceBindingMapper deviceBindingMapper;
    private final DeviceInfoMapper deviceInfoMapper;
    private final UserGrantService userGrantService;
    private final StringRedisTemplate redisTemplate;
    private final PasswordEncoder passwordEncoder;

    @Override
    public Page<AdminUserVO> pageUsers(Integer pageNum, Integer pageSize, String keyword, Integer status, String roleCode) {
        Page<SysUser> page = new Page<>(pageNum, pageSize);

        List<Long> userIdsByRole = null;
        if (roleCode != null && !roleCode.isBlank()) {
            SysRole role = sysRoleMapper.selectByRoleCode(roleCode);
            if (role == null) {
                return new Page<>(pageNum, pageSize);
            }
            userIdsByRole = sysRoleInfoMapper.selectList(
                            new LambdaQueryWrapper<SysRoleInfo>().eq(SysRoleInfo::getRoleId, role.getId()))
                    .stream().map(SysRoleInfo::getUserId).collect(Collectors.toList());
            if (userIdsByRole.isEmpty()) {
                return new Page<>(pageNum, pageSize);
            }
        }

        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getDeleted, 0)
                .eq(status != null, SysUser::getStatus, status)
                .in(userIdsByRole != null, SysUser::getId, userIdsByRole == null ? Collections.emptyList() : userIdsByRole)
                .and(keyword != null && !keyword.isBlank(), w -> w
                        .like(SysUser::getUsername, keyword)
                        .or().like(SysUser::getNickname, keyword)
                        .or().like(SysUser::getPhone, keyword))
                .orderByDesc(SysUser::getCreateTime);

        Page<SysUser> entityPage = sysUserMapper.selectPage(page, wrapper);
        List<Long> ids = entityPage.getRecords().stream().map(SysUser::getId).collect(Collectors.toList());
        Map<Long, List<String>> roleMap = loadRoleCodes(ids);

        Page<AdminUserVO> result = new Page<>(entityPage.getCurrent(), entityPage.getSize(), entityPage.getTotal());
        List<AdminUserVO> records = new ArrayList<>();
        for (SysUser user : entityPage.getRecords()) {
            AdminUserVO vo = new AdminUserVO();
            BeanUtils.copyProperties(user, vo);
            vo.setRoles(roleMap.getOrDefault(user.getId(), Collections.emptyList()));
            records.add(vo);
        }
        result.setRecords(records);
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long createUser(AdminUserCreateRequest request) {
        String username = request.getUsername().trim();
        if (sysUserMapper.selectByUsername(username) != null) {
            throw new BusinessException(ErrorCode.USERNAME_EXIST);
        }

        SysUser user = new SysUser();
        user.setUsername(username);
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setNickname(StringUtils.hasText(request.getNickname()) ? request.getNickname().trim() : username);
        user.setEmail(StringUtils.hasText(request.getEmail()) ? request.getEmail().trim() : null);
        user.setPhone(StringUtils.hasText(request.getPhone()) ? request.getPhone().trim() : null);
        user.setStatus(request.getStatus() == null ? EnableStatus.ENABLED.getCode() : request.getStatus());
        user.setDeleted(UserConstants.NOT_DELETED);
        try {
            sysUserMapper.insert(user);
        } catch (DuplicateKeyException e) {
            throw new BusinessException(ErrorCode.USERNAME_EXIST);
        }

        List<String> roleCodes = request.getRoleCodes();
        if (roleCodes == null || roleCodes.isEmpty()) {
            roleCodes = Collections.singletonList(UserConstants.DEFAULT_ROLE_CODE);
        }
        userGrantService.replaceRoles(user.getId(), roleCodes);
        return user.getId();
    }

    @Override
    public AdminUserDetailVO getUserDetail(Long userId) {
        SysUser user = requireUser(userId);
        AdminUserDetailVO vo = new AdminUserDetailVO();
        BeanUtils.copyProperties(user, vo);
        vo.setRoles(userGrantService.getRoleCodes(userId));
        vo.setPermissions(userGrantService.getPermissionCodes(userId));
        vo.setDeviceCount(deviceBindingMapper.selectCount(new LambdaQueryWrapper<DeviceBinding>()
                .eq(DeviceBinding::getUserId, userId)
                .eq(DeviceBinding::getBindStatus, BindStatus.BOUND.getCode())));
        vo.setLoginCount(sysLoginLogMapper.selectCount(new LambdaQueryWrapper<SysLoginLog>()
                .eq(SysLoginLog::getUsername, user.getUsername())));
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateUser(Long userId, AdminUserUpdateRequest request) {
        if (request.getNickname() == null && request.getEmail() == null && request.getPhone() == null) {
            throw new BusinessException(ErrorCode.PARAM_MISSING, "至少提交一个需要修改的字段");
        }
        SysUser user = requireUser(userId);
        if (request.getNickname() != null) {
            user.setNickname(request.getNickname().trim());
        }
        if (request.getEmail() != null) {
            user.setEmail(request.getEmail().trim());
        }
        if (request.getPhone() != null) {
            user.setPhone(request.getPhone().trim());
        }
        sysUserMapper.updateById(user);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateStatus(Long userId, Integer status) {
        if (EnableStatus.fromCode(status) == null) {
            throw new BusinessException(ErrorCode.USER_STATUS_INVALID);
        }
        requireUser(userId);
        SysUser update = new SysUser();
        update.setId(userId);
        update.setStatus(status);
        sysUserMapper.updateById(update);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateRoles(Long userId, List<String> roleCodes) {
        requireUser(userId);
        userGrantService.replaceRoles(userId, roleCodes);
    }

    @Override
    public Page<DeviceInfoVO> pageUserDevices(Long userId, Integer pageNum, Integer pageSize) {
        requireUser(userId);
        List<DeviceBinding> bindings = deviceBindingMapper.selectList(new LambdaQueryWrapper<DeviceBinding>()
                .eq(DeviceBinding::getUserId, userId)
                .eq(DeviceBinding::getBindStatus, BindStatus.BOUND.getCode()));
        Page<DeviceInfoVO> result = new Page<>(pageNum, pageSize);
        if (bindings.isEmpty()) {
            return result;
        }
        List<String> deviceIds = bindings.stream().map(DeviceBinding::getDeviceId).collect(Collectors.toList());
        Page<DeviceInfo> page = deviceInfoMapper.selectPage(new Page<>(pageNum, pageSize),
                new LambdaQueryWrapper<DeviceInfo>()
                        .in(DeviceInfo::getDeviceId, deviceIds)
                        .eq(DeviceInfo::getDeleted, 0));
        List<DeviceInfoVO> records = new ArrayList<>();
        for (DeviceInfo device : page.getRecords()) {
            DeviceInfoVO vo = new DeviceInfoVO();
            BeanUtils.copyProperties(device, vo);
            records.add(vo);
        }
        result.setTotal(page.getTotal());
        result.setRecords(records);
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void forceUnbind(Long userId, String deviceId) {
        String cleanMac = MacUtils.normalize(deviceId);
        DeviceBinding binding = deviceBindingMapper.selectOne(new LambdaQueryWrapper<DeviceBinding>()
                .eq(DeviceBinding::getActiveDeviceId, cleanMac)
                .eq(DeviceBinding::getUserId, userId));
        if (binding == null) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_BOUND);
        }
        binding.setBindStatus(BindStatus.UNBOUND.getCode());
        binding.setUnbindTime(LocalDateTime.now());
        deviceBindingMapper.updateById(binding);
        redisTemplate.opsForSet().remove(RedisConstants.BOUND_DEVICES_KEY, cleanMac);
    }

    private Map<Long, List<String>> loadRoleCodes(List<Long> userIds) {
        if (userIds.isEmpty()) {
            return Collections.emptyMap();
        }
        List<SysRoleInfo> roleInfos = sysRoleInfoMapper.selectList(
                new LambdaQueryWrapper<SysRoleInfo>().in(SysRoleInfo::getUserId, userIds));
        if (roleInfos.isEmpty()) {
            return Collections.emptyMap();
        }
        List<Long> roleIds = roleInfos.stream().map(SysRoleInfo::getRoleId).distinct().collect(Collectors.toList());
        Map<Long, String> codeMap = sysRoleMapper.selectRolesByIds(roleIds).stream()
                .collect(Collectors.toMap(SysRole::getId, SysRole::getRoleCode, (a, b) -> a));
        return roleInfos.stream()
                .filter(info -> codeMap.containsKey(info.getRoleId()))
                .collect(Collectors.groupingBy(SysRoleInfo::getUserId,
                        Collectors.mapping(info -> codeMap.get(info.getRoleId()), Collectors.toList())));
    }

    private SysUser requireUser(Long userId) {
        SysUser user = sysUserMapper.selectById(userId);
        if (user == null || (user.getDeleted() != null && user.getDeleted() != 0)) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        return user;
    }
}
