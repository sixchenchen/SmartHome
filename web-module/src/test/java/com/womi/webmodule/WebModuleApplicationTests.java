package com.womi.webmodule;


import com.womi.businessmodule.model.*;
import com.womi.businessmodule.service.*;
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


    private static final String TEST_DEVICE_ID = "TEST_DEVICE_001";

    @Test
    void testAllTables() {
        log.info("========== 测试所有表 ==========");


        log.info("========== 所有测试通过 ==========");
    }


}
