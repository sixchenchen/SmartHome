package com.womi.webmodule.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.FirmwareStatusUpdateRequest;
import com.womi.businessmodule.vo.FirmwareUploadResponse;
import com.womi.businessmodule.vo.FirmwareVO;
import com.womi.businessmodule.vo.device.OtaTaskDetailVO;
import com.womi.businessmodule.vo.device.OtaTaskVO;
import com.womi.commonmodule.constants.PageConstants;
import com.womi.commonmodule.constants.PermissionConstants;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.mqtt.AdminOtaTaskService;
import com.womi.webmodule.service.mqtt.DeviceFirmwareUploadService;
import com.womi.webmodule.service.mqtt.DeviceOtaService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/admin/ota")
@RequiredArgsConstructor
public class AdminOtaController {

    private final DeviceFirmwareUploadService firmwareUploadService;
    private final DeviceOtaService deviceOtaService;
    private final AdminOtaTaskService adminOtaTaskService;

    // ==================== 1. 固件库管理 ====================
    /**
     * 上传固件
     */
    @PostMapping("/firmware/upload")
    @PreAuthorize("hasAuthority('" + PermissionConstants.FIRMWARE_UPLOAD + "')")
    public ApiResponse<FirmwareUploadResponse> uploadFirmware(
            @RequestParam("file") MultipartFile file,
            @RequestParam("version") String version,
            @RequestParam("product") String product,
            @RequestParam(value = "releaseNotes", required = false) String releaseNotes,
            @RequestParam(value = "operator", required = false) String operator) {

        FirmwareUploadResponse response = firmwareUploadService.upload(file, version, product, releaseNotes, operator);
        return ApiResponse.success(response);
    }

    /**
     * 查询所有启用的固件
     */
    @GetMapping("/firmware/list")
    @PreAuthorize("hasAuthority('" + PermissionConstants.OTA_LIST + "')")
    public ApiResponse<List<FirmwareVO>> listFirmware() {
        return ApiResponse.success(firmwareUploadService.listAll());
    }

    /**
     * 固件分页
     */
    @GetMapping("/firmware")
    @PreAuthorize("hasAuthority('" + PermissionConstants.OTA_LIST + "')")
    public ApiResponse<Page<FirmwareVO>> pageFirmware(
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize,
            @RequestParam(required = false) String product,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String keyword) {
        return ApiResponse.success(firmwareUploadService.pageFirmware(pageNum, pageSize, product, status, keyword));
    }

    /**
     * 固件详情
     */
    @GetMapping("/firmware/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.OTA_LIST + "')")
    public ApiResponse<FirmwareVO> getFirmware(@PathVariable Long id) {
        return ApiResponse.success(firmwareUploadService.getDetail(id));
    }

    /**
     * 启用/禁用固件
     */
    @PutMapping("/firmware/{id}/status")
    @PreAuthorize("hasAuthority('" + PermissionConstants.FIRMWARE_UPLOAD + "')")
    public ApiResponse<Void> updateFirmwareStatus(@PathVariable Long id,
                                                  @RequestBody @Valid FirmwareStatusUpdateRequest request) {
        firmwareUploadService.updateStatus(id, request.getStatus());
        return ApiResponse.success(null);
    }

    /**
     * 删除固件
     */
    @DeleteMapping("/firmware/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.FIRMWARE_DELETE + "')")
    public ApiResponse<Void> deleteFirmware(@PathVariable Long id) {
        firmwareUploadService.delete(id);
        return ApiResponse.success(null);
    }
    // ==================== 2. 批量下发 OTA ====================

    /**
     * 批量下发 OTA 升级任务
     */
    @PostMapping("/batch-dispatch")
    @PreAuthorize("hasAuthority('" + PermissionConstants.OTA_CREATE + "')")
    public ApiResponse<Integer> batchDispatch(
            @RequestParam Long firmwareId,
            @RequestParam(required = false) String targetProduct,
            @RequestParam(required = false) String operator) {

        // 返回的是本次成功下发（生成指令）的设备数量
        int count = deviceOtaService.batchDispatchOta(firmwareId, targetProduct, operator);
        return ApiResponse.success(count);
    }

    // ==================== 3. OTA 任务 ====================

    /**
     * 任务列表
     */
    @GetMapping("/tasks")
    @PreAuthorize("hasAuthority('" + PermissionConstants.OTA_LIST + "')")
    public ApiResponse<Page<OtaTaskVO>> pageTasks(
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize,
            @RequestParam(required = false) Integer status) {
        return ApiResponse.success(adminOtaTaskService.pageTasks(pageNum, pageSize, status));
    }

    /**
     * 任务详情（含每台设备执行情况）
     */
    @GetMapping("/tasks/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.OTA_LIST + "')")
    public ApiResponse<OtaTaskDetailVO> getTaskDetail(@PathVariable Long id) {
        return ApiResponse.success(adminOtaTaskService.getTaskDetail(id));
    }

    /**
     * 取消任务（仅取消未下发的子任务）
     */
    @PostMapping("/tasks/{id}/cancel")
    @PreAuthorize("hasAuthority('" + PermissionConstants.OTA_CANCEL + "')")
    public ApiResponse<Integer> cancelTask(@PathVariable Long id, Principal principal) {
        return ApiResponse.success(adminOtaTaskService.cancelTask(id, principal.getName()));
    }
}