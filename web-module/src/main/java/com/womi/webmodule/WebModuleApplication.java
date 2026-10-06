package com.womi.webmodule;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication(scanBasePackages = {
        "com.womi.webmodule",
        "com.womi.businessmodule",
        "com.womi.commonmodule"
})
@EnableScheduling // 启动定时任务
@MapperScan("com.womi.businessmodule.mapper") // 开启mapper层扫描
public class WebModuleApplication {
    public static void main(String[] args) {
        SpringApplication.run(WebModuleApplication.class, args);
    }
}
