package com.womi.webmodule.service.user;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.PasswordChangeRequest;
import com.womi.businessmodule.dto.UserProfileUpdateRequest;
import com.womi.businessmodule.vo.LoginLogVO;
import com.womi.businessmodule.vo.UserProfileVO;

/**
 * 用户中心服务
 */
public interface UserProfileService {

    UserProfileVO getProfile(Long userId);

    UserProfileVO updateProfile(Long userId, UserProfileUpdateRequest request);

    void changePassword(Long userId, PasswordChangeRequest request);

    Page<LoginLogVO> pageLoginLogs(Long userId, Integer pageNum, Integer pageSize);
}
