package com.womi.webmodule;


import com.womi.businessmodule.model.*;
import com.womi.businessmodule.service.*;
import com.womi.commonmodule.utils.SaltPasswordUtils;
import com.womi.webmodule.schedule.CommandScheduler;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@Slf4j
@SpringBootTest
class WebModuleApplicationTests {


    @Test
    public void testHash() {
        String salt = "767f13ac5e1c4dbdddb7f4c288bb085b";
        String password = "123456";

        String hash = SaltPasswordUtils.hash(password, salt);
        System.out.println("计算哈希: " + hash);
        System.out.println("数据库值: f43c57babf15d80cd5e961e6dee8b1795dcff8805ca9a4aabc2d048d2499f172");
        System.out.println("是否一致: " + hash.equals("f43c57babf15d80cd5e961e6dee8b1795dcff8805ca9a4aabc2d048d2499f172"));
    }
}
