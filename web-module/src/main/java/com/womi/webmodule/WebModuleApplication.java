package com.womi.webmodule;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication(scanBasePackages = {
        "com.womi.webmodule",
        "com.womi.businessmodule",
        "com.womi.commonmodule"
})
@MapperScan("com.womi.businessmodule.mapper")
public class WebModuleApplication {
    public static void main(String[] args) {
        SpringApplication.run(WebModuleApplication.class, args);
    }
}
