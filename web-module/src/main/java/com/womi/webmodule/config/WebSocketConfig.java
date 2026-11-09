package com.womi.webmodule.config;

import com.womi.commonmodule.constants.WebSocketConstants;
import com.womi.webmodule.interceptor.WebSocketAuthInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {


    @Value("${cors.allowed-origins}")
    private String[] allowedOrigins;
    private final WebSocketAuthInterceptor webSocketAuthInterceptor;

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // 后端发给前端订阅：路径用 /topic/xxx 或 /queue/xxx
        config.enableSimpleBroker(
                WebSocketConstants.BROKER_TOPIC_DESTINATION,
                WebSocketConstants.BROKER_QUEUE_DESTINATION
        );
        // 前端发给后端处理：路径用 /app/xxx
        config.setApplicationDestinationPrefixes(WebSocketConstants.APP_DESTINATION_PREFIX);
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // 前端域名
        registry.addEndpoint(WebSocketConstants.ENDPOINT_PATH)
                .setAllowedOriginPatterns(allowedOrigins)
                .withSockJS();
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        // 注册拦截器
        registration.interceptors(webSocketAuthInterceptor);
    }
}