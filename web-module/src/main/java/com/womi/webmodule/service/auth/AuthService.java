package com.womi.webmodule.service.auth;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.womi.businessmodule.dto.UserRegisterRequest;
import com.womi.businessmodule.mapper.sys.SysLoginLogMapper;
import com.womi.businessmodule.mapper.sys.SysRoleInfoMapper;
import com.womi.businessmodule.mapper.sys.SysRoleMapper;
import com.womi.businessmodule.mapper.sys.SysUserMapper;
import com.womi.businessmodule.model.sys.SysLoginLog;
import com.womi.businessmodule.model.sys.SysRole;
import com.womi.businessmodule.model.sys.SysUser;
import com.womi.businessmodule.vo.LoginResponse;
import com.womi.commonmodule.constants.UserConstants;
import com.womi.commonmodule.enums.EnableStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.utils.JwtTokenUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {


    private final SysUserMapper sysUserMapper;
    private final SysRoleMapper sysRoleMapper;
    private final SysRoleInfoMapper sysRoleInfoMapper;
    private final PasswordEncoder passwordEncoder;
    private final SysLoginLogMapper sysLoginLogMapper;
    private final RefreshTokenService refreshTokenService;
    private final JwtTokenUtil jwtTokenUtil;
    private final LoginAttemptService loginAttemptService;

    /**
     * 注册用户 + 绑定默认角色，单事务
     */
    @Transactional(rollbackFor = Exception.class)
    public SysUser register(UserRegisterRequest req) {

        // 1. 先查一次
        Long exists = sysUserMapper.selectCount(
                new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getUsername, req.getUsername()));
        if (exists != null && exists > 0) {
            throw new BusinessException(ErrorCode.PARAM_ERROR, "用户名已存在: " + req.getUsername());
        }

        // 2. 组装用户
        SysUser user = new SysUser();
        user.setUsername(req.getUsername());
        user.setPasswordHash(passwordEncoder.encode(req.getPassword()));
        user.setNickname(StringUtils.hasText(req.getNickname())
                ? req.getNickname() : req.getUsername());
        user.setEmail(req.getEmail());
        user.setPhone(req.getPhone());
        user.setStatus(EnableStatus.ENABLED.getCode());
        user.setDeleted(UserConstants.NOT_DELETED);

        // 3. 插入，唯一索引
        try {
            sysUserMapper.insert(user);
        } catch (DuplicateKeyException e) {
            throw new BusinessException(ErrorCode.PARAM_ERROR, "用户名已存在: " + req.getUsername());
        }

        // 4. 绑定默认角色
        SysRole defaultRole = sysRoleMapper.selectOne(
                new LambdaQueryWrapper<SysRole>()
                        .eq(SysRole::getRoleCode, UserConstants.DEFAULT_ROLE_CODE)
                        .eq(SysRole::getStatus, EnableStatus.ENABLED.getCode())
                        .eq(SysRole::getDeleted, UserConstants.NOT_DELETED)
                        .last("LIMIT 1"));
        if (defaultRole == null) {
            log.error("默认角色 [{}] 未初始化，无法完成用户 [{}] 注册",UserConstants.DEFAULT_ROLE_CODE, req.getUsername());
            throw new BusinessException(ErrorCode.CONFIG_ERROR, "默认角色 [" + UserConstants.DEFAULT_ROLE_CODE + "] 未初始化，请联系管理员");
        } else {
            // 见下方说明：优先用 BaseMapper.insert，如果没有就用自定义 SQL
            sysRoleInfoMapper.insertUserRole(user.getId(), defaultRole.getId());
        }
        log.info("用户注册成功: id={}, username={}", user.getId(), user.getUsername());
        return user;
    }

    /**
     * 登录成功后：
     * - 更新 last_login_time
     * - 保存 IP / UA 到日志（P1-4 才落库，这里先 log）
     * <p>
     * 注意：使用 LambdaUpdateWrapper 显式设 update_time，避免 MetaObjectHandler 缺失
     */
    public void recordLoginSuccess(String username, HttpServletRequest request) {
        String ip = extractClientIp(request);
        String ua = truncate(request.getHeader("User-Agent"), UserConstants.USER_AGENT_MAX_LENGTH);

        SysUser update = new SysUser();
        update.setLastLoginTime(LocalDateTime.now());

        int rows = sysUserMapper.update(update, new LambdaUpdateWrapper<SysUser>().eq(SysUser::getUsername, username));

        if (rows == 0) {
            log.warn("记录登录成功时更新 last_login_time 失败: username={}", username);
        }
        saveLoginLog(username, ip, ua, UserConstants.LOGIN_STATUS_SUCCESS, UserConstants.MSG_LOGIN_SUCCESS);
        log.info("用户登录成功: username={}, ip={}, ua={}", username, ip, ua);
    }

    /**
     * 从请求里提取真实客户端 IP（兼容 Nginx 反代）
     */
    private static String extractClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (StringUtils.hasText(ip) && !"unknown".equalsIgnoreCase(ip)) {
            int idx = ip.indexOf(',');
            return (idx > 0 ? ip.substring(0, idx) : ip).trim();
        }
        ip = request.getHeader("X-Real-IP");
        if (StringUtils.hasText(ip) && !"unknown".equalsIgnoreCase(ip)) {
            return ip.trim();
        }
        return request.getRemoteAddr();
    }

    private static String truncate(String s, int max) {
        if (s == null) return null;
        return s.length() > max ? s.substring(0, max) : s;
    }

    public LocalDateTime getLastLoginTime(String username) {
        SysUser user = sysUserMapper.selectOne(
                new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getUsername, username)
                        .select(SysUser::getLastLoginTime)
        );
        return user != null ? user.getLastLoginTime() : null;
    }

    /**
     * 提取公共写入逻辑
     */
    private void saveLoginLog(String username, String ip, String ua, int status, String message) {
        SysLoginLog loginLog = new SysLoginLog();
        loginLog.setUsername(username);
        loginLog.setIp(ip);
        loginLog.setUserAgent(ua);
        loginLog.setStatus(status);
        loginLog.setMessage(message);
        loginLog.setLoginTime(LocalDateTime.now());
        sysLoginLogMapper.insert(loginLog);
    }

    /**
     * 记录登录失败
     */
    public void recordLoginFailure(String username, HttpServletRequest request, String reason) {
        String ip = extractClientIp(request);
        String ua = truncate(request.getHeader("User-Agent"), UserConstants.USER_AGENT_MAX_LENGTH);

        saveLoginLog(username, ip, ua, UserConstants.LOGIN_STATUS_FAILURE, reason);

        log.warn("用户登录失败: username={}, ip={}, reason={}", username, ip, reason);
    }

    /**
     * 处理登录成功，生成双 Token 并返回结果
     */
    @Transactional(rollbackFor = Exception.class)
    public LoginResponse processLoginSuccess(UserDetails userDetails, HttpServletRequest request, String deviceType) {
        String username = userDetails.getUsername();

        // 1. 生成 AccessToken
        String accessToken = jwtTokenUtil.generateToken(userDetails); // 注意：需要注入 JwtTokenUtil

        // 2. 生成 RefreshToken (需知道 userId)
        SysUser user = sysUserMapper.selectOne(new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, username));
        String refreshToken = refreshTokenService.createRefreshToken(user.getId(), deviceType);

        // 3. 写登录日志
        recordLoginSuccess(username, request);
        return buildLoginResponse(userDetails, user, accessToken, refreshToken);
    }

    public LoginResponse processRefreshSuccess(UserDetails userDetails, SysUser user, String deviceType) {
        String accessToken = jwtTokenUtil.generateToken(userDetails);
        String refreshToken = refreshTokenService.createRefreshToken(user.getId(), deviceType);

        return buildLoginResponse(userDetails, user, accessToken, refreshToken);
    }

    private LoginResponse buildLoginResponse(UserDetails userDetails, SysUser user, String accessToken, String refreshToken) {
        List<String> roles = new ArrayList<>();
        List<String> permissions = new ArrayList<>();
        for (GrantedAuthority authority : userDetails.getAuthorities()) {
            String auth = authority.getAuthority();
            if (auth.startsWith(UserConstants.ROLE_PREFIX)) {
                roles.add(auth.substring(UserConstants.ROLE_PREFIX.length()));
            } else {
                permissions.add(auth);
            }
        }
        return LoginResponse.builder()
                .token(accessToken)
                .refreshToken(refreshToken)
                .username(user.getUsername())
                .nickname(user.getNickname() != null ? user.getNickname() : user.getUsername())
                .roles(roles)
                .permissions(permissions)
                .lastLoginTime(user.getLastLoginTime())
                .expiresAt(LocalDateTime.now().plusNanos(jwtTokenUtil.getExpirationMs() * UserConstants.NANOS_PER_MILLI))
                .build();
    }
}