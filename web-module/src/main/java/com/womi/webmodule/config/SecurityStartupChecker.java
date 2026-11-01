package com.womi.webmodule.config;

import io.jsonwebtoken.io.Decoders;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Slf4j
@Component
public class SecurityStartupChecker implements ApplicationRunner {

    private static final String DEFAULT_SECRET = "dGhpc2lzYXZlcnlzZWNyZXRrZXlmb3Jqd3R0b2tlbnVzZTEyMzQ1Ng==";

    private final String jwtSecret;
    private final Environment environment;

    public SecurityStartupChecker(@Value("${my.jwt.secret}") String jwtSecret, Environment environment) {
        this.jwtSecret = jwtSecret;
        this.environment = environment;
    }

    @Override
    public void run(ApplicationArguments args) {
        // ==================== 1. 校验 Secret 的格式与长度 ====================
        if (jwtSecret == null || jwtSecret.isBlank()) {
            throw new IllegalStateException(" 严重安全告警：JWT secret 未配置！拒绝启动！");
        }

        try {
            // 尝试 Base64 解码
            byte[] keyBytes = Decoders.BASE64.decode(jwtSecret);
            // 校验长度（HS256 要求至少 32 字节 / 256 bit）
            if (keyBytes.length < 32) {
                throw new IllegalStateException(" 严重安全告警：JWT secret 解码后长度不足 32 字节（当前 "
                        + keyBytes.length + " 字节），存在被暴力破解的风险！拒绝启动！");
            }
        } catch (IllegalStateException e) {
            throw e; // 抛出我们自定义的长度不足异常
        } catch (Exception e) {
            throw new IllegalStateException(" 严重安全告警：JWT secret 不是合法的 Base64 字符串！请检查配置。", e);
        }

        // ==================== 2. 环境与默认值校验 ====================
        // 获取当前激活的 profile
        String[] activeProfiles = environment.getActiveProfiles();
        boolean isProd = Arrays.asList(activeProfiles).contains("prod");

        // 无条件计算是否在使用默认密钥
        boolean isDefault = DEFAULT_SECRET.equals(jwtSecret);

        // 如果无 active profile，给出提示（通常默认走 dev）
        if (activeProfiles.length == 0) {
            log.info("ℹ未显式指定 spring.profiles.active，当前将以 default (dev) 环境启动。");
        }

        // 生产环境 + 默认密钥 = 直接抛异常，禁止启动
        if (isProd && isDefault) {
            throw new IllegalStateException(" 生产环境(prod)禁止使用默认的 JWT 密钥！请在服务器配置环境变量 JWT_SECRET！");
        }
        // 无论什么环境，只要用了默认密钥就给出警告
        else if (isDefault) {
            log.warn(" 当前正在使用默认的 JWT 密钥，请勿在生产环境中使用！");
        }

        log.info(" JWT 密钥安全性校验通过 - 当前环境: {}, 密钥长度: 充足",
                activeProfiles.length > 0 ? Arrays.toString(activeProfiles) : "default");
    }
}