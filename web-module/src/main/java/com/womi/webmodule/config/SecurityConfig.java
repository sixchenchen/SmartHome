package com.womi.webmodule.config;

import com.womi.commonmodule.constants.AvatarConstants;
import com.womi.commonmodule.constants.HttpConstants;
import com.womi.commonmodule.constants.UserConstants;
import com.womi.webmodule.filter.JwtAuthenticationFilter;
import com.womi.webmodule.handler.JsonAccessDeniedHandler;
import com.womi.webmodule.handler.JsonAuthenticationEntryPoint;
import com.womi.webmodule.service.auth.impl.UserDetailsServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity          // 开启 @PreAuthorize 等注解
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final UserDetailsServiceImpl userDetailsService;
    private final JsonAuthenticationEntryPoint authenticationEntryPoint;
    private final JsonAccessDeniedHandler accessDeniedHandler;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, Environment env) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .cors(Customizer.withDefaults())
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))  // 无状态
                .authorizeHttpRequests(auth -> {

                    // 1. 所有环境都放行的白名单
                    auth.requestMatchers(
                                    HttpConstants.AUTH_LOGIN_PATH,
                                    HttpConstants.AUTH_REGISTER_PATH,
                                    HttpConstants.AUTH_REFRESH_PATH,
                                    HttpConstants.AUTH_CAPTCHA_PATH)
                            .permitAll()
                            .requestMatchers(HttpConstants.WEBSOCKET_ENDPOINT_PATTERN).permitAll()
                            .requestMatchers(HttpConstants.ACTUATOR_HEALTH_PATH, AvatarConstants.RESOURCE_HANDLER).permitAll()
                            .requestMatchers(HttpConstants.ADMIN_API_PATTERN)
                            .hasAnyRole(UserConstants.USER_ROLE_ADMIN, UserConstants.USER_ROLE_OPS)
                            .requestMatchers(HttpConstants.ERROR_PATH, HttpConstants.FAVICON_PATH).permitAll();

                    // 2. 判断环境：如果不是 prod，才允许访问 Swagger 文档
                    if (!env.acceptsProfiles(Profiles.of(HttpConstants.PROD_PROFILE))) {
                        auth.requestMatchers(
                                HttpConstants.DOC_HTML_PATH,
                                HttpConstants.WEBJARS_PATTERN,
                                HttpConstants.API_DOCS_PATTERN,
                                HttpConstants.SWAGGER_RESOURCES_PATTERN
                        ).permitAll();
                    }

                    // 3. 其余所有请求必须认证
                    auth.anyRequest().authenticated();
                })
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint(authenticationEntryPoint)   // 401 JSON
                        .accessDeniedHandler(accessDeniedHandler)             // 403 JSON
                )
                .authenticationProvider(authenticationProvider())
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * 密码编码器：BCrypt 强度 12
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(UserConstants.PASSWORD_ENCODER_STRENGTH);
    }

    /**
     * 认证提供者：连接自定义 UserDetailsService 与 PasswordEncoder
     */
    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder());
        return provider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}