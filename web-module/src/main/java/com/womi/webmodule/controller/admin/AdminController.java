package com.womi.webmodule.controller.admin;

import com.womi.businessmodule.service.sys.SysUserService;
import com.womi.commonmodule.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
public class AdminController {

    private final SysUserService sysUserService;

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteUser(@PathVariable Long id) {
        sysUserService.logicDeleteUser(id);
        return ApiResponse.success(null);
    }
}