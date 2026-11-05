package com.womi.webmodule.interceptor;

import com.womi.commonmodule.constants.UserConstants;
import com.womi.commonmodule.constants.WebSocketConstants;
import com.womi.commonmodule.utils.JwtTokenUtil;
import com.womi.webmodule.security.SecurityUser;
import com.womi.webmodule.security.StompPrincipal;
import com.womi.webmodule.security.WebSocketSubscriptionAuthorizer;
import com.womi.webmodule.service.auth.impl.UserDetailsServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessagingException;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Principal;
import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    private final JwtTokenUtil jwtTokenUtil;
    private final UserDetailsServiceImpl userDetailsService;
    private final WebSocketSubscriptionAuthorizer subscriptionAuthorizer;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
        if (accessor == null) {
            return message;
        }

        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            authenticate(accessor);
        } else if (StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
            authorizeSubscribe(accessor);
        }
        return message;
    }

    /**
     * CONNECT 阶段：校验 JWT 并写入 STOMP 会话身份。
     */
    private void authenticate(StompHeaderAccessor accessor) {
        String authHeader = accessor.getFirstNativeHeader(UserConstants.AUTHORIZATION_HEAD);
        log.info("尝试建立 WebSocket 连接, 携带的 Header: {}", authHeader);

        if (authHeader == null || !authHeader.startsWith(UserConstants.BEARER)) {
            throw new MessagingException(WebSocketConstants.ERR_AUTH_MISSING);
        }

        String token = authHeader.substring(UserConstants.TOKEN_BEGIN_INDEX).trim();
        try {
            String username = jwtTokenUtil.extractUsername(token);
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);
            if (!jwtTokenUtil.validateToken(token, userDetails)) {
                throw new MessagingException(WebSocketConstants.ERR_AUTH_FAILED);
            }

            SecurityUser securityUser = (SecurityUser) userDetails;
            boolean isAdmin = userDetails.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals(UserConstants.ADMIN_AUTHORITY));

            StompPrincipal principal = new StompPrincipal(securityUser.sysUser().getId(), username, isAdmin);

            // 会话属性作为后续 SUBSCRIBE 的兜底身份来源（正常情况优先取 accessor.getUser()）
            Map<String, Object> sessionAttributes = accessor.getSessionAttributes();
            if (sessionAttributes != null) {
                sessionAttributes.put(UserConstants.USER_ID, securityUser.sysUser().getId());
                sessionAttributes.put(WebSocketConstants.SESSION_USERNAME, username);
                sessionAttributes.put(WebSocketConstants.SESSION_IS_ADMIN, isAdmin);
            }

            accessor.setUser(principal);
            log.info("WebSocket 认证成功 - 用户: {}, 管理员: {}", username, isAdmin);
        } catch (MessagingException e) {
            throw e;
        } catch (Exception e) {
            log.error("WebSocket JWT 解析失败", e);
            throw new MessagingException(WebSocketConstants.ERR_AUTH_FAILED);
        }
    }

    /**
     * SUBSCRIBE 阶段：统一委托授权组件，管理员放开全部主题，普通用户仅限已绑定设备。
     */
    private void authorizeSubscribe(StompHeaderAccessor accessor) {
        Principal principal = accessor.getUser();
        if (principal == null) {
            principal = restorePrincipal(accessor);
        }
        if (principal == null) {
            throw new MessagingException(WebSocketConstants.ERR_UNAUTHORIZED);
        }
        subscriptionAuthorizer.authorize(principal, accessor.getDestination());
    }

    /**
     * 从会话属性恢复身份，兼容部分 STOMP 客户端在 SUBSCRIBE 帧未透传用户信息的情况。
     */
    private StompPrincipal restorePrincipal(StompHeaderAccessor accessor) {
        Map<String, Object> sessionAttributes = accessor.getSessionAttributes();
        if (sessionAttributes == null) {
            return null;
        }
        Object userId = sessionAttributes.get(UserConstants.USER_ID);
        Object username = sessionAttributes.get(WebSocketConstants.SESSION_USERNAME);
        if (!(userId instanceof Number userIdValue) || username == null) {
            return null;
        }
        boolean isAdmin = Boolean.TRUE.equals(sessionAttributes.get(WebSocketConstants.SESSION_IS_ADMIN));
        return new StompPrincipal(userIdValue.longValue(), String.valueOf(username), isAdmin);
    }
}
