package com.womi.businessmodule.service.sys.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.sys.SysInfoMapper;
import com.womi.businessmodule.model.sys.SysInfo;
import com.womi.businessmodule.service.sys.SysInfoService;
import org.springframework.stereotype.Service;

@Service
public class SysInfoServiceImpl extends ServiceImpl<SysInfoMapper, SysInfo> implements SysInfoService {
}