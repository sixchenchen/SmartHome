package com.womi.businessmodule.service.sys.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.user.SysUserMapper;
import com.womi.businessmodule.model.user.UserInfo;
import com.womi.businessmodule.service.sys.UserService;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl extends ServiceImpl<SysUserMapper, UserInfo> implements UserService {
}