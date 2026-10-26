package com.womi.businessmodule.service.sys.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.sys.SysUserMapper;
import com.womi.businessmodule.model.sys.SysUser;
import com.womi.businessmodule.service.sys.SysUserService;
import com.womi.commonmodule.constants.UserConstants;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class SysUserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements SysUserService {
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean logicDeleteUser(Long userId) {
        SysUser user = getById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }

        // 生成改名后的用户名
        String deletedUsername = user.getUsername() + "#DEL#" + userId;

        // 使用 UpdateWrapper 直接更新（绕开逻辑删除导致找不到数据的坑）
        boolean updated = lambdaUpdate()
                .set(SysUser::getUsername, deletedUsername)
                .set(SysUser::getDeleted, UserConstants.LOGIC_DELETE_USER)  // 逻辑删除
                .eq(SysUser::getId, userId)
                .update();

        log.info("用户逻辑删除: id={}, 原用户名={} -> 新用户名={}", userId, user.getUsername(), deletedUsername);
        return updated;
    }
}