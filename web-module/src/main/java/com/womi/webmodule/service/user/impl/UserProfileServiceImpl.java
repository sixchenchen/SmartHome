package com.womi.webmodule.service.user.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.PasswordChangeRequest;
import com.womi.businessmodule.dto.UserProfileUpdateRequest;
import com.womi.businessmodule.mapper.sys.SysLoginLogMapper;
import com.womi.businessmodule.mapper.sys.SysRefreshTokenMapper;
import com.womi.businessmodule.mapper.sys.SysUserMapper;
import com.womi.businessmodule.model.sys.SysLoginLog;
import com.womi.businessmodule.model.sys.SysRefreshToken;
import com.womi.businessmodule.model.sys.SysUser;
import com.womi.businessmodule.vo.LoginLogVO;
import com.womi.businessmodule.vo.UserProfileVO;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.service.sys.UserGrantService;
import com.womi.webmodule.service.user.UserProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserProfileServiceImpl implements UserProfileService {

    private final SysUserMapper sysUserMapper;
    private final SysLoginLogMapper sysLoginLogMapper;
    private final SysRefreshTokenMapper sysRefreshTokenMapper;
    private final PasswordEncoder passwordEncoder;
    private final UserGrantService userGrantService;

    @Override
    public UserProfileVO getProfile(Long userId) {
        SysUser user = requireUser(userId);
        UserProfileVO vo = new UserProfileVO();
        BeanUtils.copyProperties(user, vo);
        vo.setUserId(user.getId());
        vo.setRoles(userGrantService.getRoleCodes(userId));
        vo.setPermissions(userGrantService.getPermissionCodes(userId));
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public UserProfileVO updateProfile(Long userId, UserProfileUpdateRequest request) {
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
        return getProfile(userId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void changePassword(Long userId, PasswordChangeRequest request) {
        SysUser user = requireUser(userId);
        if (!passwordEncoder.matches(request.getOldPassword(), user.getPasswordHash())) {
            throw new BusinessException(ErrorCode.PARAM_INVALID, "原密码错误");
        }
        SysUser update = new SysUser();
        update.setId(userId);
        update.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        sysUserMapper.updateById(update);

        // 强制下线：撤销该用户所有刷新令牌
        LambdaUpdateWrapper<SysRefreshToken> wrapper = Wrappers.<SysRefreshToken>lambdaUpdate()
                .eq(SysRefreshToken::getUserId, userId)
                .set(SysRefreshToken::getRevoked, 1);
        sysRefreshTokenMapper.update(null, wrapper);
    }

    @Override
    public Page<LoginLogVO> pageLoginLogs(Long userId, Integer pageNum, Integer pageSize) {
        SysUser user = requireUser(userId);
        LambdaQueryWrapper<SysLoginLog> wrapper = Wrappers.<SysLoginLog>lambdaQuery()
                .eq(SysLoginLog::getUsername, user.getUsername())
                .orderByDesc(SysLoginLog::getLoginTime);
        Page<SysLoginLog> page = sysLoginLogMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);

        Page<LoginLogVO> result = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        List<LoginLogVO> records = new ArrayList<>();
        for (SysLoginLog log : page.getRecords()) {
            LoginLogVO vo = new LoginLogVO();
            BeanUtils.copyProperties(log, vo);
            records.add(vo);
        }
        result.setRecords(records);
        return result;
    }

    private SysUser requireUser(Long userId) {
        SysUser user = sysUserMapper.selectById(userId);
        if (user == null || (user.getDeleted() != null && user.getDeleted() != 0)) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        return user;
    }
}
