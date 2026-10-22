package com.womi.webmodule.controller.admin;

import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.commonmodule.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {
    /**
     * 查询指令详情
     */
    @GetMapping("/test")
    public ApiResponse<String> detail() {
        return ApiResponse.success("Admin_OK");
    }

}
