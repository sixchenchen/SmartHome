package com.womi.webmodule.service.user;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.AdminUserCreateRequest;
import com.womi.businessmodule.dto.AdminUserUpdateRequest;
import com.womi.businessmodule.vo.AdminUserDetailVO;
import com.womi.businessmodule.vo.AdminUserVO;
import com.womi.businessmodule.vo.device.DeviceInfoVO;

import java.util.List;

/**
 * 管理端用户管理服务
 */
public interface AdminUserService {

    Page<AdminUserVO> pageUsers(Integer pageNum, Integer pageSize, String keyword, Integer status, String roleCode);

    /** 新增用户并分配角色，返回新用户ID */
    Long createUser(AdminUserCreateRequest request);

    AdminUserDetailVO getUserDetail(Long userId);

    void updateUser(Long userId, AdminUserUpdateRequest request);

    void updateStatus(Long userId, Integer status);

    void updateRoles(Long userId, List<String> roleCodes);

    Page<DeviceInfoVO> pageUserDevices(Long userId, Integer pageNum, Integer pageSize);

    void forceUnbind(Long userId, String deviceId);
}
