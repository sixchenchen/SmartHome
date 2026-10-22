package com.womi.businessmodule.service.sys.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.user.SysPermissionMapper;
import com.womi.businessmodule.model.user.SysPermission;
import com.womi.businessmodule.service.sys.UserPermissionService;
import org.springframework.stereotype.Service;

@Service
public class SysPermissionServiceImpl extends ServiceImpl<SysPermissionMapper, SysPermission> implements UserPermissionService {
}