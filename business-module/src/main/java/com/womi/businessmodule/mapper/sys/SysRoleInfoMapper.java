package com.womi.businessmodule.mapper.sys;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.sys.SysRoleInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface SysRoleInfoMapper extends BaseMapper<SysRoleInfo> {
    List<Long> selectRoleIdsByUserId(@Param("userId") Long userId);
}
