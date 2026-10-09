package com.womi.webmodule.controller;


import com.womi.webmodule.dto.firmware.response.FirmwareUploadResponse;
import com.womi.webmodule.dto.firmware.response.FirmwareVO;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.FirmwareUploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/firmware")
@RequiredArgsConstructor
public class FirmwareController {

    private final FirmwareUploadService firmwareUploadService;

    /**
     * 上传固件
     * POST /api/firmware/upload
     */
    @PostMapping("/upload")
    public ApiResponse<FirmwareUploadResponse> upload(
            @RequestParam("file") MultipartFile file,
            @RequestParam("version") String version,
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "releaseNotes", required = false) String releaseNotes,
            @RequestParam(value = "operator", defaultValue = "admin") String operator) {

        FirmwareUploadResponse response = firmwareUploadService.upload(file, version, product, releaseNotes, operator);
        return ApiResponse.success(response);
    }

    /**
     * 查询固件列表
     * GET /api/firmware/list
     */
    @GetMapping("/list")
    public ApiResponse<List<FirmwareVO>> list() {
        return ApiResponse.success(firmwareUploadService.listAll());
    }

    /**
     * 删除固件
     * DELETE /api/firmware/{id}
     */
    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        firmwareUploadService.delete(id);
        return ApiResponse.success(null);
    }
}