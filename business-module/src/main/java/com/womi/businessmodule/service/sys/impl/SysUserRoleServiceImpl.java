package com.womi.businessmodule.service.sys.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.user.SysUserRoleMapper;
import com.womi.businessmodule.model.user.UserRole;
import com.womi.businessmodule.service.sys.UserRoleInfoService;
import org.springframework.stereotype.Service;

@Service
public class SysUserRoleServiceImpl extends ServiceImpl<SysUserRoleMapper, UserRole> implements UserRoleInfoService {
}