package com.womi.businessmodule.mapper.sys;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.sys.SysRole;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SysRoleMapper extends BaseMapper<SysRole> {
    SysRole selectByRoleCode(@Param("roleCode") String roleCode);
    List<SysRole> selectRolesByIds(@Param("roleIds") List<Long> roleIds);
}