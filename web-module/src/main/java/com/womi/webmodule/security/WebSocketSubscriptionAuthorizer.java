package com.womi.webmodule.security;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.womi.businessmodule.model.device.DeviceBinding;
import com.womi.businessmodule.service.device.DeviceBindingService;
import com.womi.commonmodule.constants.WebSocketConstants;
import com.womi.commonmodule.enums.BindStatus;
import com.womi.commonmodule.utils.MacUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.MessagingException;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.security.Principal;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * WebSocket 订阅授权组件。
 *
 * <p>授权规则：</p>
 * <ol>
 *     <li>管理员：拥有全部主题（{@code /topic/**}）的订阅权限，不做设备归属校验；</li>
 *     <li>普通用户：仅允许订阅自己已绑定设备的主题，格式为
 *     {@code /topic/device/{deviceId}/{state|sensor|alert|ota}}；</li>
 *     <li>非法地址、未认证身份、未绑定设备一律拒绝。</li>
 * </ol>
 *
 * <p>所有订阅请求在 STOMP {@code SUBSCRIBE} 阶段统一走此组件，避免权限逻辑散落在拦截器中。</p>
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class WebSocketSubscriptionAuthorizer {

    /** 设备主题路径：/topic/device/{deviceId}/{type} */
    private static final Pattern DEVICE_TOPIC_PATTERN = Pattern.compile(WebSocketConstants.DEVICE_TOPIC_REGEX);

    private final DeviceBindingService deviceBindingService;

    /**
     * 校验一次订阅请求是否允许。
     *
     * @param principal   当前 STOMP 连接身份（CONNECT 阶段已写入）
     * @param destination 订阅目标地址
     * @throws MessagingException 无权限或地址非法时抛出，由框架回传 ERROR 帧
     */
    public void authorize(Principal principal, String destination) {
        if (!(principal instanceof StompPrincipal stompPrincipal)) {
            throw new MessagingException(WebSocketConstants.ERR_UNAUTHORIZED);
        }
        if (!StringUtils.hasText(destination)) {
            throw new MessagingException(WebSocketConstants.ERR_DESTINATION_EMPTY);
        }

        // 管理员：全部主题放开
        if (stompPrincipal.isAdmin()) {
            if (!destination.startsWith(WebSocketConstants.TOPIC_PREFIX)) {
                throw new MessagingException(String.format(WebSocketConstants.ERR_DESTINATION_INVALID, destination));
            }
            log.debug("管理员订阅放行 - 用户: {}, 地址: {}", stompPrincipal.getUsername(), destination);
            return;
        }

        // 普通用户：仅允许设备主题，且必须是已绑定设备
        if (!destination.startsWith(WebSocketConstants.DEVICE_TOPIC_PREFIX)) {
            throw new MessagingException(WebSocketConstants.ERR_TOPIC_FORBIDDEN);
        }
        Matcher matcher = DEVICE_TOPIC_PATTERN.matcher(destination);
        if (!matcher.matches() || !WebSocketConstants.DEVICE_TOPIC_TYPES.contains(matcher.group(2))) {
            throw new MessagingException(String.format(WebSocketConstants.ERR_DESTINATION_INVALID, destination));
        }

        String deviceId = MacUtils.normalize(matcher.group(1));
        if (!StringUtils.hasText(deviceId)) {
            throw new MessagingException(WebSocketConstants.ERR_DEVICE_ID_EMPTY);
        }
        if (!isBound(stompPrincipal.getUserId(), deviceId)) {
            log.warn("用户越权订阅被拦截 - userId: {}, username: {}, 设备: {}, 地址: {}",
                    stompPrincipal.getUserId(), stompPrincipal.getUsername(), deviceId, destination);
            throw new MessagingException(WebSocketConstants.ERR_DEVICE_FORBIDDEN);
        }
    }

    /**
     * 是否存在有效的设备绑定关系（active_device_id 唯一索引保证一台设备仅一条有效绑定）。
     */
    private boolean isBound(Long userId, String deviceId) {
        try {
            return deviceBindingService.count(new LambdaQueryWrapper<DeviceBinding>()
                    .eq(DeviceBinding::getActiveDeviceId, deviceId)
                    .eq(DeviceBinding::getUserId, userId)
                    .eq(DeviceBinding::getBindStatus, BindStatus.BOUND.getCode())) > 0;
        } catch (Exception e) {
            log.error("校验设备绑定关系异常 - userId: {}, 设备: {}", userId, deviceId, e);
            return false;
        }
    }
}
