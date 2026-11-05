package com.womi.webmodule.controller.common;

import com.womi.businessmodule.vo.AvatarUploadResponse;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.common.CommonService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/common")
@RequiredArgsConstructor
public class CommonController {

    private final CommonService commonService;

    /**
     * 字典表（角色、状态、OTA 状态、产品等）
     */
    @GetMapping("/dictionaries")
    public ApiResponse<Map<String, Object>> getDictionaries() {
        return ApiResponse.success(commonService.getDictionaries());
    }

    /**
     * 上传头像
     */
    @PostMapping("/upload/avatar")
    public ApiResponse<AvatarUploadResponse> uploadAvatar(@RequestParam("file") MultipartFile file) {
        return ApiResponse.success(commonService.uploadAvatar(file));
    }
}
