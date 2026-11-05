package com.womi.webmodule.config;

import com.github.xiaoymin.knife4j.spring.annotations.EnableKnife4j;
import com.womi.commonmodule.constants.AvatarConstants;
import com.womi.commonmodule.constants.HttpConstants;
import lombok.extern.slf4j.Slf4j;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * 配置类，注册web层相关组件
 */
@Configuration
@Slf4j
@EnableKnife4j
public class WebMvcConfiguration implements WebMvcConfigurer {

    @Value("${app.upload.avatar-dir:" + AvatarConstants.DEFAULT_DIR + "}")
    private String avatarDir;

    /**
     * 设置静态资源映射，主要是访问接口文档（html、js、css）
     * @param registry
     */
    @Override
    public  void addResourceHandlers(ResourceHandlerRegistry registry) {
        log.info("开始设置静态资源映射...");
        registry.addResourceHandler(HttpConstants.DOC_HTML_PATH).addResourceLocations(HttpConstants.DOC_HTML_LOCATION);
        registry.addResourceHandler(HttpConstants.WEBJARS_PATTERN).addResourceLocations(HttpConstants.WEBJARS_LOCATION);
        registry.addResourceHandler(AvatarConstants.RESOURCE_HANDLER)
                .addResourceLocations(AvatarConstants.RESOURCE_LOCATION_PREFIX + avatarDir + AvatarConstants.PATH_SEPARATOR);
    }

    @Bean
    public GroupedOpenApi userApi() {
        return GroupedOpenApi.builder()
                .group("user")
                .packagesToScan("com.womi.webmodule.controller.user")
                .build();
    }

    @Bean
    public GroupedOpenApi deviceApi() {
        return GroupedOpenApi.builder()
                .group("device")
                .packagesToScan("com.womi.webmodule.controller.device")
                .build();
    }

    @Bean
    public GroupedOpenApi adminApi() {
        return GroupedOpenApi.builder()
                .group("admin")
                .packagesToScan("com.womi.webmodule.controller.admin")
                .build();
    }

}
