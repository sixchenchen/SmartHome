package com.womi.webmodule.controller.user;

import com.womi.businessmodule.dto.LoginRequest;
import com.womi.businessmodule.dto.UserRegisterRequest;
import com.womi.businessmodule.mapper.sys.SysUserMapper;
import com.womi.businessmodule.model.sys.SysRefreshToken;
import com.womi.businessmodule.model.sys.SysUser;
import com.womi.businessmodule.vo.LoginResponse;
import com.womi.businessmodule.vo.UserRegisterResponse;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.commonmodule.utils.JwtTokenUtil;
import com.womi.webmodule.service.auth.*;
import com.womi.webmodule.service.auth.impl.UserDetailsServiceImpl;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class UserAuthController {

    private final AuthenticationManager authenticationManager;
    private final SysUserMapper sysUserMapper;
    private final JwtTokenUtil jwtTokenUtil;
    private final AuthService authService;
    private final LoginAttemptService loginAttemptService;
    private final RefreshTokenService refreshTokenService;
    private final TokenBlacklistService tokenBlacklistService;
    private final UserDetailsServiceImpl userDetailsService;

    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@RequestBody LoginRequest request,
                                            HttpServletRequest httpRequest,
                                            @RequestHeader(value = "X-Device-Type", required = false) String deviceType) {
        String username = request.getUsername();
        //  提取真实客户端 IP
        String ip = getClientIp(httpRequest);

        try {
            // 传入 IP 进行校验
            loginAttemptService.checkNotLocked(ip, username);

            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(username, request.getPassword()));

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            SecurityContextHolder.getContext().setAuthentication(authentication);

            // 登录成功，清理该 IP 的失败计数
            loginAttemptService.recordSuccess(ip, username);

            return ApiResponse.success(authService.processLoginSuccess(userDetails, httpRequest, deviceType));

        } catch (BadCredentialsException e) {
            // 传入 IP 记录失败
            loginAttemptService.recordFailure(ip, username);
            authService.recordLoginFailure(username, httpRequest, "用户名或密码错误");
            throw e;
        } catch (BusinessException e) {
            if (e.getCode() == 4013) { // 锁定 code
                authService.recordLoginFailure(username, httpRequest, "账号已锁定");
            }
            throw e;
        }
    }

    @PostMapping("/register")
    public ApiResponse<UserRegisterResponse> register(@RequestBody @Valid UserRegisterRequest request) {
        var user = authService.register(request);
        return ApiResponse.success(new UserRegisterResponse(user.getId(), user.getUsername(), user.getNickname()));
    }

    // ==================== P1-2: 刷新 Token ====================
    @Data
    public static class RefreshRequest {
        private String refreshToken;
    }

    @PostMapping("/refresh")
    public ApiResponse<LoginResponse> refresh(@RequestBody RefreshRequest request) {
        // 1. 验证 RefreshToken
        SysRefreshToken tokenEntity = refreshTokenService.consumeRefreshToken(request.getRefreshToken());
        if (tokenEntity == null) {
            throw new BusinessException(4010, "RefreshToken 无效或已过期，请重新登录");
        }

        // 2. 旋转刷新：旧的立马作废（防止重放攻击）
        refreshTokenService.revokeToken(request.getRefreshToken());

        // 3. 查出用户
        SysUser user = sysUserMapper.selectById(tokenEntity.getUserId());
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND, "用户不存在");
        }

        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getUsername());

        // 4. 生成全新的双 Token，并复用处理登录成功的逻辑
        return ApiResponse.success(authService.processRefreshSuccess(userDetails, user, tokenEntity.getDeviceType()));
    }

    // ==================== P1-3: 登出 ====================
    @PostMapping("/logout")
    public ApiResponse<Void> logout(@RequestBody(required = false) RefreshRequest request,
                                    @RequestHeader(value = "Authorization", required = false) String bearerToken) {
        // 1. 将 AccessToken 加入黑名单
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            String token = bearerToken.substring(7);
            try {
                String jti = jwtTokenUtil.extractJti(token);
                tokenBlacklistService.blacklistToken(jti, jwtTokenUtil.extractExpiration(token));
            } catch (Exception ignored) {
            } // 就算 token 过期了，登出接口也不应该报错
        }

        // 2. 撤销 RefreshToken
        if (request != null && request.getRefreshToken() != null) {
            refreshTokenService.revokeToken(request.getRefreshToken());
        }

        return ApiResponse.success(null);
    }

    /**
     * 兼容 Nginx 反代的真实 IP 提取
     */
    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
            // 多次反向代理后会有多个IP，第一个为真实IP
            int index = ip.indexOf(',');
            if (index != -1) {
                return ip.substring(0, index).trim();
            }
            return ip.trim();
        }
        ip = request.getHeader("X-Real-IP");
        if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
            return ip.trim();
        }
        return request.getRemoteAddr();
    }

}