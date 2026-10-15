package com.womi.webmodule;


import com.womi.commonmodule.utils.SaltPasswordUtils;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.assertThat;

@Slf4j
@SpringBootTest
class WebModuleApplicationTests {


    @Test
    public void testHash() {
        String salt = "667f13ac5e1c4dbdddb7f4c288bb0856";
        String password = "123456";

        String hash = SaltPasswordUtils.hash(password, salt);
        System.out.println("计算哈希: " + hash);
        System.out.println("数据库值: fae340eae69a2dfad416154a5d47474ce546d2c2ba9bc57fa8c0b833a6886aff");
        System.out.println("是否一致: " + hash.equals("fae340eae69a2dfad416154a5d47474ce546d2c2ba9bc57fa8c0b833a6886aff"));
    }
}
