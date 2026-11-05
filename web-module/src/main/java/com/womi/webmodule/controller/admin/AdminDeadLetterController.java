package com.womi.webmodule.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.model.sys.SysDeadLetter;
import com.womi.webmodule.service.mqtt.SysDeadLetterService;
import com.womi.commonmodule.constants.PageConstants;
import com.womi.commonmodule.constants.UserConstants;
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
    @PreAuthorize("hasRole('" + UserConstants.USER_ROLE_ADMIN + "')")
    public ApiResponse<Page<SysDeadLetter>> page(
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize) {
        return ApiResponse.success(deadLetterService.pageDeadLetters(pageNum, pageSize));
    }

    /**
     * 死信详情
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('" + UserConstants.USER_ROLE_ADMIN + "')")
    public ApiResponse<SysDeadLetter> detail(@PathVariable Long id) {
        return ApiResponse.success(deadLetterService.getDetail(id));
    }

    /**
     * 标记忽略（不再重放）
     */
    @PostMapping("/{id}/ignore")
    @PreAuthorize("hasRole('" + UserConstants.USER_ROLE_ADMIN + "')")
    public ApiResponse<Void> ignore(@PathVariable Long id) {
        deadLetterService.ignore(id);
        return ApiResponse.success(null);
    }

    /**
     * 手动重放死信
     */
    @PostMapping("/{id}/replay")
    @PreAuthorize("hasRole('" + UserConstants.USER_ROLE_ADMIN + "')")
    public ApiResponse<Void> replay(@PathVariable Long id) {
        deadLetterService.replay(id);
        return ApiResponse.success(null);
    }
}