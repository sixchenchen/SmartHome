package com.womi.businessmodule.service.sys;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.sys.SysUser;

public interface SysUserService extends IService<SysUser> {
    /**
     * 逻辑删除用户，并将用户名重命名，释放原用户名供重新注册
     */
    boolean logicDeleteUser(Long userId);
}
