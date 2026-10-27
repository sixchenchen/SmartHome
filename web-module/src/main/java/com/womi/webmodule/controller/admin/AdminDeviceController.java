package com.womi.webmodule.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.DeviceCreateRequest;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.device.DeviceAdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/devices")
@RequiredArgsConstructor
public class AdminDeviceController {

    private final DeviceAdminService deviceAdminService;

    /**
     * 分页查询设备 (支持根据 MAC 或名称模糊搜索)
     */
    @GetMapping
    @PreAuthorize("hasAuthority('device:list')")
    public ApiResponse<Page<DeviceInfo>> pageDevices(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String keyword) {

        return ApiResponse.success(deviceAdminService.pageDevices(pageNum, pageSize, keyword));
    }

    /**
     * 新增设备
     */
    @PostMapping
    @PreAuthorize("hasAuthority('device:create')")
    public ApiResponse<Void> addDevice(@RequestBody @Valid DeviceCreateRequest request) {
        deviceAdminService.createDevice(request);
        return ApiResponse.success(null);
    }

    /**
     * 删除设备
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('device:delete')")
    public ApiResponse<Void> deleteDevice(@PathVariable Long id) {
        deviceAdminService.deleteDevice(id);
        return ApiResponse.success(null);
    }
}