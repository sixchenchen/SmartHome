package com.womi.businessmodule.service.sys.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.user.UserRoleInfoMapper;
import com.womi.businessmodule.model.user.UserRoleInfo;
import com.womi.businessmodule.service.sys.UserRoleService;
import org.springframework.stereotype.Service;

@Service
public class SysRoleServiceImpl extends ServiceImpl<UserRoleInfoMapper, UserRoleInfo> implements UserRoleService {
}