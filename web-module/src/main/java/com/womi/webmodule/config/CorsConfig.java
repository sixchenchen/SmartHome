package com.womi.webmodule.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;

@Configuration
public class CorsConfig {


    @Value("${cors.allowed-origins}")
    private String[] allowedOrigins;

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        // 1. 严格使用白名单
        config.setAllowedOrigins(Arrays.asList(allowedOrigins));

        // 2. 收敛允许的请求头
        config.setAllowedHeaders(Arrays.asList(
                "Authorization",
                "Content-Type",
                "X-Requested-With",
                "Accept",
                "Origin"
        ));

        // 3. 收敛允许的请求方法
        config.setAllowedMethods(Arrays.asList(
                "GET", "POST", "PUT", "DELETE", "OPTIONS"
        ));

        // 4. 允许携带 Cookie 等凭证
        config.setAllowCredentials(true);

        // 5. 暴露给前端的响应头（根据你的需求，如果没有用到自定义响应头，可以写死或者去掉 *）
        config.setExposedHeaders(Arrays.asList("Authorization", "Content-Disposition"));

        // 6. 预检请求缓存时间（秒）
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}