package com.womi.businessmodule.mapper.sys;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.sys.SysRoleInfo;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface SysRoleInfoMapper extends BaseMapper<SysRoleInfo> {
    List<Long> selectRoleIdsByUserId(@Param("userId") Long userId);

    // 绑定用户-角色
    @Insert("INSERT INTO sys_role_info(user_id, role_id, create_time) VALUES(#{userId}, #{roleId}, NOW())")
    int insertUserRole(@Param("userId") Long userId, @Param("roleId") Long roleId);
}
