package com.womi.businessmodule.service.sys.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.sys.SysRolePermissionMapper;
import com.womi.businessmodule.model.sys.SysRolePermission;
import com.womi.businessmodule.service.sys.SysRolePermissionService;
import org.springframework.stereotype.Service;

@Service
public class SysRolePermissionServiceImpl extends ServiceImpl<SysRolePermissionMapper, SysRolePermission> implements SysRolePermissionService {
}