package com.womi.webmodule.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class SecurityStartupChecker implements ApplicationRunner {

    @Value("${my.jwt.secret}")
    private String jwtSecret;

    private final Environment environment;

    public SecurityStartupChecker(Environment environment) {
        this.environment = environment;
    }

    @Override
    public void run(ApplicationArguments args) {
        String defaultSecret = "dGhpc2lzYXZlcnlzZWNyZXRrZXlmb3Jqd3R0b2tlbnVzZTEyMzQ1Ng==";
        boolean isProd = false;
        for (String profile : environment.getActiveProfiles()) {
            if ("prod".equalsIgnoreCase(profile)) {
                isProd = true;
                break;
            } else if (defaultSecret.equals(jwtSecret)) {
                log.warn("当前正在使用默认的 JWT 密钥，请勿在生产环境中使用！");
            }

        }

        if (isProd && defaultSecret.equals(jwtSecret)) {
            log.error("严重安全告警：生产环境使用了默认 JWT 密钥，系统即将关闭！");
            System.exit(1); // 强行终止进程
        }
    }
}