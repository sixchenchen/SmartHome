package com.womi.webmodule.filter;

import com.womi.businessmodule.model.sys.SysUser;
import com.womi.commonmodule.constants.UserConstants;
import com.womi.commonmodule.utils.JwtTokenUtil;
import com.womi.webmodule.security.SecurityUser;
import com.womi.webmodule.service.auth.impl.TokenBlacklistServiceImpl;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenUtil jwtTokenUtil;
    private final TokenBlacklistServiceImpl tokenBlacklistServiceImpl;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String header = request.getHeader(UserConstants.AUTHORIZATION_HEAD);
        if (!StringUtils.hasText(header) || !header.startsWith(UserConstants.BEARER)) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = header.substring(UserConstants.TOKEN_BEGIN_INDEX);
        try {
            // 只解析一次！获取完整的 Claims 对象
            Claims claims = jwtTokenUtil.parseClaims(token);
            if (claims == null || claims.getExpiration().before(new java.util.Date())) {
                filterChain.doFilter(request, response);
                return;
            }

            // 1. 从 Claims 中提取 jti，校验黑名单
            String jti = claims.getId();
            if (jti != null && tokenBlacklistServiceImpl.isBlacklisted(jti)) {
                filterChain.doFilter(request, response);
                return;
            }

            // 2. 从 Claims 中提取用户名和 userId
            String username = claims.getSubject();
            Long userId = claims.get("userId", Long.class);

            // 3. 从 Claims 中提取权限列表
            @SuppressWarnings("unchecked")
            List<String> authorityStrs = (List<String>) claims.get("authorities");
            if (authorityStrs == null) authorityStrs = Collections.emptyList();

            // 如果上下文里还没有认证信息，才去构建
            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {

                // 组装轻量级实体
                SysUser lightUser = new SysUser();
                lightUser.setId(userId);
                lightUser.setUsername(username);

                List<SimpleGrantedAuthority> authorities = authorityStrs.stream()
                        .map(SimpleGrantedAuthority::new)
                        .collect(Collectors.toList());

                SecurityUser securityUser = new SecurityUser(lightUser, authorities);

                // 注入 SecurityContext
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(securityUser, null, authorities);
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception e) {
            // 解析失败 / Token 过期 / 签名不匹配，直接放行，交给后续的 ExceptionTranslationFilter 返回 401
            log.debug("JWT 校验失败: {}", e.getMessage());
        }

        filterChain.doFilter(request, response);
    }
}