package com.womi.webmodule.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;

@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        // 允许所有前端域名（生产环境建议改成具体的域名，如 "http://yourdomain.com"）
        config.addAllowedOriginPattern("*");
        // 允许所有请求头
        config.addAllowedHeader("*");
        // 允许所有请求方法 (GET, POST, DELETE, OPTIONS等)
        config.addAllowedMethod("*");
        // 允许携带 Cookie 等凭证
        config.setAllowCredentials(true);
        // 暴露给前端的响应头（比如 Token 自定义响应头，虽然我们用的是 body 返回）
        config.addExposedHeader("*");
        // 预检请求缓存时间（秒），减少 OPTIONS 请求次数
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}