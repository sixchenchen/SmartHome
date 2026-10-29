package com.womi.webmodule.service.auth;

import com.womi.businessmodule.dto.UserRegisterRequest;
import com.womi.businessmodule.model.sys.SysUser;
import com.womi.businessmodule.vo.LoginResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.userdetails.UserDetails;

public interface AuthService {

    SysUser register(UserRegisterRequest req);

    void recordLoginSuccess(String username, HttpServletRequest request);

    void recordLoginFailure(String username, HttpServletRequest request, String reason);

    LoginResponse processLoginSuccess(UserDetails userDetails, HttpServletRequest request, String deviceType);

    LoginResponse processRefreshSuccess(UserDetails userDetails, SysUser user, String deviceType);
}