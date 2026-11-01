package com.womi.webmodule.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.model.sys.SysDeadLetter;
import com.womi.webmodule.service.mqtt.SysDeadLetterService;
import com.womi.commonmodule.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/dead-letters")
@RequiredArgsConstructor
public class AdminDeadLetterController {

    private final SysDeadLetterService deadLetterService;

    /**
     * 分页查询死信列表
     */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Page<SysDeadLetter>> page(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        return ApiResponse.success(deadLetterService.pageDeadLetters(pageNum, pageSize));
    }

    /**
     * 手动重放死信
     */
    @PostMapping("/{id}/replay")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Void> replay(@PathVariable Long id) {
        deadLetterService.replay(id);
        return ApiResponse.success(null);
    }
}