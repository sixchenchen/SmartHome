package com.womi.webmodule.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.model.device.DeviceFirmware;
import com.womi.businessmodule.vo.FirmwareUploadResponse;
import com.womi.businessmodule.vo.FirmwareVO;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.mqtt.DeviceFirmwareUploadService;
import com.womi.webmodule.service.mqtt.DeviceOtaService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/admin/ota")
@RequiredArgsConstructor
public class AdminOtaController {

    // 👈 直接注入第一段代码的 Service
    private final DeviceFirmwareUploadService firmwareUploadService;
    private final DeviceOtaService deviceOtaService;

    // ==================== 1. 固件库管理 ====================

    /**
     * 上传固件
     */
    @PostMapping("/firmware/upload")
    @PreAuthorize("hasAuthority('firmware:upload')")
    public ApiResponse<FirmwareUploadResponse> uploadFirmware(
            @RequestParam("file") MultipartFile file,
            @RequestParam("version") String version,
            @RequestParam("product") String product,
            @RequestParam(value = "releaseNotes", required = false) String releaseNotes,
            @RequestParam(value = "operator", required = false) String operator) {

        // 调用你第一段代码的 upload 方法，完美返回
        FirmwareUploadResponse response = firmwareUploadService.upload(file, version, product, releaseNotes, operator);
        return ApiResponse.success(response);
    }

    /**
     * 查询所有启用的固件
     */
    @GetMapping("/firmware/list")
    @PreAuthorize("hasAuthority('ota:list')")
    public ApiResponse<List<FirmwareVO>> listFirmware() {
        return ApiResponse.success(firmwareUploadService.listAll());
    }

    /**
     * 删除固件
     */
    @DeleteMapping("/firmware/{id}")
    @PreAuthorize("hasAuthority('firmware:delete')")
    public ApiResponse<Void> deleteFirmware(@PathVariable Long id) {
        firmwareUploadService.delete(id);
        return ApiResponse.success(null);
    }
    // ==================== 2. 批量下发 OTA ====================

    /**
     * 批量下发 OTA 升级任务
     */
    @PostMapping("/batch-dispatch")
    @PreAuthorize("hasAuthority('ota:create')")
    public ApiResponse<Integer> batchDispatch(
            @RequestParam Long firmwareId,
            @RequestParam(required = false) String targetProduct,
            @RequestParam(required = false) String operator) {

        // 返回的是本次成功下发（生成指令）的设备数量
        int count = deviceOtaService.batchDispatchOta(firmwareId, targetProduct, operator);
        return ApiResponse.success(count);
    }
}