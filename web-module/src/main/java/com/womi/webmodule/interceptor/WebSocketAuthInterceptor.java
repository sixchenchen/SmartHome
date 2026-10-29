package com.womi.webmodule.interceptor;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.womi.businessmodule.model.device.DeviceBinding;
import com.womi.businessmodule.service.device.DeviceBindingService;
import com.womi.commonmodule.utils.JwtTokenUtil;
import com.womi.webmodule.security.StompPrincipal;
import com.womi.webmodule.security.SecurityUser;
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

import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    private final JwtTokenUtil jwtTokenUtil;
    private final UserDetailsServiceImpl userDetailsService;
    private final DeviceBindingService deviceBindingService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null) {
            // ==================== 1. 握手连接鉴权 (CONNECT) ====================
            if (StompCommand.CONNECT.equals(accessor.getCommand())) {
                String authHeader = accessor.getFirstNativeHeader("Authorization");
                log.info("尝试建立 WebSocket 连接, 携带的 Header: {}", authHeader);

                if (authHeader != null && authHeader.startsWith("Bearer ")) {
                    String token = authHeader.substring(7).trim();
                    try {
                        String username = jwtTokenUtil.extractUsername(token);
                        UserDetails userDetails = userDetailsService.loadUserByUsername(username);

                        if (jwtTokenUtil.validateToken(token, userDetails)) {
                            SecurityUser securityUser = (SecurityUser) userDetails;
                            boolean isAdmin = userDetails.getAuthorities().stream()
                                    .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

                            StompPrincipal principal = new StompPrincipal(
                                    securityUser.sysUser().getId(), username, isAdmin);

                            // 保存到 sessionAttributes 中，供后续 SUBSCRIBE 取用
                            Map<String, Object> sessionAttributes = accessor.getSessionAttributes();
                            if (sessionAttributes != null) {
                                sessionAttributes.put("userId", securityUser.sysUser().getId());
                                sessionAttributes.put("isAdmin", isAdmin);
                            }

                            accessor.setUser(principal);
                            log.info("WebSocket 认证成功 - 用户: {}", username);
                        }
                    } catch (Exception e) {
                        log.error("WebSocket JWT 解析失败", e);
                        throw new MessagingException("认证失败，Token无效或已过期");
                    }
                } else {
                    throw new MessagingException("缺少 Authorization Token");
                }
            }

            // ==================== 2. 订阅鉴权 (SUBSCRIBE) ====================
            if (StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
                String destination = accessor.getDestination();

                // 从 sessionAttributes 中获取身份信息，避免强转异常
                Map<String, Object> sessionAttributes = accessor.getSessionAttributes();
                if (sessionAttributes == null || !sessionAttributes.containsKey("userId")) {
                    throw new MessagingException("未认证，禁止订阅");
                }

                Long userId = (Long) sessionAttributes.get("userId");
                Boolean isAdmin = (Boolean) sessionAttributes.get("isAdmin");

                if (destination != null && destination.startsWith("/topic/device/")) {
                    String[] parts = destination.split("/");
                    if (parts.length >= 4) {
                        String deviceMac = parts[3];

                        if (isAdmin == null || !isAdmin) {
                            boolean hasAccess = checkUserDeviceAccess(userId, deviceMac);
                            if (!hasAccess) {
                                log.warn("用户越权订阅被拦截 - 用户ID: {}, 设备: {}", userId, deviceMac);
                                throw new MessagingException("无权订阅该设备的数据");
                            }
                        }
                    }
                }
            }
        }
        return message;
    }

    private boolean checkUserDeviceAccess(Long userId, String deviceMac) {
        try {
            long count = deviceBindingService.count(new LambdaQueryWrapper<DeviceBinding>()
                    .eq(DeviceBinding::getUserId, userId)
                    .eq(DeviceBinding::getDeviceId, deviceMac)
                    .eq(DeviceBinding::getBindStatus, 1));
            return count > 0;
        } catch (Exception e) {
            log.error("校验设备绑定关系异常 - userId: {}, mac: {}", userId, deviceMac, e);
            return false;
        }
    }
}