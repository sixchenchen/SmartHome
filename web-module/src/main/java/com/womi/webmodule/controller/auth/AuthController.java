package com.womi.webmodule.controller.auth;

import com.womi.businessmodule.dto.LoginRequest;
import com.womi.businessmodule.dto.RefreshRequest;
import com.womi.businessmodule.dto.UserRegisterRequest;
import com.womi.businessmodule.mapper.sys.SysUserMapper;
import com.womi.businessmodule.model.sys.SysRefreshToken;
import com.womi.businessmodule.model.sys.SysUser;
import com.womi.businessmodule.vo.LoginResponse;
import com.womi.businessmodule.vo.UserRegisterResponse;
import com.womi.commonmodule.constants.HttpConstants;
import com.womi.commonmodule.constants.UserConstants;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.commonmodule.utils.JwtTokenUtil;
import com.womi.webmodule.service.auth.AuthService;
import com.womi.webmodule.service.auth.LoginAttemptService;
import com.womi.webmodule.service.auth.RefreshTokenService;
import com.womi.webmodule.service.auth.TokenBlacklistService;
import com.womi.webmodule.service.captcha.CaptchaService;
import com.womi.webmodule.service.security.RateLimitService;
import com.womi.webmodule.util.ClientRequestUtils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final SysUserMapper sysUserMapper;
    private final JwtTokenUtil jwtTokenUtil;

    private final AuthService authService;
    private final LoginAttemptService loginAttemptService;
    private final RefreshTokenService refreshTokenService;
    private final TokenBlacklistService tokenBlacklistService;
    private final UserDetailsService userDetailsService;
    private final CaptchaService captchaService;
    private final RateLimitService rateLimitService;

    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@RequestBody @Valid LoginRequest request,
                                            HttpServletRequest httpRequest,
                                            @RequestHeader(value = HttpConstants.DEVICE_TYPE_HEAD, required = false) String deviceType) {
        log.info("用户{}请求登录",request.getUsername());
        String username = request.getUsername();
        String ip = ClientRequestUtils.getClientIp(httpRequest);
        String deviceId = ClientRequestUtils.resolveDeviceId(httpRequest, ip);

        // 第二层：登录请求整体限流（先于验证码校验，超限直接拒绝）
        rateLimitService.checkLoginAccess(ip, deviceId, username);

        // 第三层：验证码错误计入 IP/设备失败计数，不计入账号锁定
        try {
            captchaService.verify(request.getCaptchaId(), request.getCaptchaCode());
        } catch (BusinessException e) {
            if (e.getCode() == ErrorCode.CAPTCHA_INVALID.getCode()
                    || e.getCode() == ErrorCode.CAPTCHA_EXPIRED.getCode()) {
                rateLimitService.recordCaptchaFailure(ip, deviceId);
            }
            throw e;
        }

        try {
            loginAttemptService.checkNotLocked(username);

            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(username, request.getPassword()));

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            SecurityContextHolder.getContext().setAuthentication(authentication);

            loginAttemptService.recordSuccess(username);

            return ApiResponse.success(authService.processLoginSuccess(userDetails, httpRequest, deviceType));

        } catch (BadCredentialsException e) {
            // 密码错误计入账号维度；账号不存在计入 IP/设备维度（防用户枚举）
            if (sysUserMapper.selectByUsername(username) == null) {
                rateLimitService.recordAnonymousFailure(ip, deviceId);
            } else {
                loginAttemptService.recordPasswordFailure(username);
            }
            authService.recordLoginFailure(username, httpRequest, ErrorCode.AUTH_FAILED.getMessage());
            throw e;
        } catch (BusinessException e) {
            if (e.getCode() == ErrorCode.ACCOUNT_LOCKED.getCode()) {
                authService.recordLoginFailure(username, httpRequest, ErrorCode.ACCOUNT_LOCKED.getMessage());
            }
            throw e;
        }
    }

    @PostMapping("/register")
    public ApiResponse<UserRegisterResponse> register(@RequestBody @Valid UserRegisterRequest request) {
        log.info("用户{}请求注册",request.getUsername());
        var user = authService.register(request);
        return ApiResponse.success(new UserRegisterResponse(user.getId(), user.getUsername(), user.getNickname()));
    }

    @PostMapping("/refresh")
    public ApiResponse<LoginResponse> refresh(@RequestBody RefreshRequest request) {
        // 1. 验证并原子核销 RefreshToken
        SysRefreshToken tokenEntity = refreshTokenService.consumeRefreshToken(request.getRefreshToken());
        if (tokenEntity == null) {
            throw new BusinessException(ErrorCode.REFRESH_TOKEN_INVALID, ErrorCode.REFRESH_TOKEN_INVALID.getMessage());
        }

        // 2. 查出用户
        SysUser user = sysUserMapper.selectById(tokenEntity.getUserId());
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND, ErrorCode.USER_NOT_FOUND.getMessage());
        }

        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getUsername());

        // 3. 生成全新的双 Token
        return ApiResponse.success(authService.processRefreshSuccess(userDetails, user, tokenEntity.getDeviceType()));
    }

    @PostMapping("/logout")
    public ApiResponse<Void> logout(@RequestBody(required = false) RefreshRequest request,
                                    @RequestHeader(value = UserConstants.AUTHORIZATION_HEAD, required = false) String bearerToken) {
        log.info("用户退出");
        // 1. 将 AccessToken 加入黑名单
        if (bearerToken != null && bearerToken.startsWith(UserConstants.BEARER)) {
            String token = bearerToken.substring(UserConstants.TOKEN_BEGIN_INDEX);
            try {
                String jti = jwtTokenUtil.extractJti(token);
                tokenBlacklistService.blacklistToken(jti, jwtTokenUtil.extractExpiration(token));
            } catch (Exception ignored) {
            }
        }

        // 2. 撤销 RefreshToken
        if (request != null && request.getRefreshToken() != null) {
            refreshTokenService.revokeToken(request.getRefreshToken());
        }

        return ApiResponse.success(null);
    }
}