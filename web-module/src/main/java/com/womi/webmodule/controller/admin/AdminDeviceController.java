package com.womi.webmodule.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.AdminDeviceCommandRequest;
import com.womi.businessmodule.dto.DeviceAdminUpdateRequest;
import com.womi.businessmodule.dto.DeviceBindingUnbindRequest;
import com.womi.businessmodule.dto.DeviceCreateRequest;
import com.womi.businessmodule.vo.device.AdminDeviceVO;
import com.womi.businessmodule.vo.device.DeviceBindingVO;
import com.womi.businessmodule.vo.device.DeviceOnlineStatsVO;
import com.womi.commonmodule.constants.CsvConstants;
import com.womi.commonmodule.constants.PageConstants;
import com.womi.commonmodule.constants.PermissionConstants;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.service.device.DeviceAdminService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.List;

@RestController
@RequestMapping("/api/admin/devices")
@RequiredArgsConstructor
public class AdminDeviceController {

    private final DeviceAdminService deviceAdminService;

    /**
     * 分页查询设备 (支持根据 MAC / 名称 / 产品模糊搜索)
     */
    @GetMapping
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_LIST + "')")
    public ApiResponse<Page<AdminDeviceVO>> pageDevices(
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize,
            @RequestParam(required = false) String keyword) {
        return ApiResponse.success(deviceAdminService.pageDevices(pageNum, pageSize, keyword));
    }

    /**
     * 在线统计
     */
    @GetMapping({"/online-stats", "/stats/online"})
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_LIST + "')")
    public ApiResponse<DeviceOnlineStatsVO> getOnlineStats() {
        return ApiResponse.success(deviceAdminService.getOnlineStats());
    }

    /**
     * 导出设备 CSV
     */
    @GetMapping("/export")
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_LIST + "')")
    public void exportDevices(@RequestParam(required = false) String keyword,
                              HttpServletResponse response) throws IOException {
        List<AdminDeviceVO> devices = deviceAdminService.listForExport(keyword);
        response.setContentType(CsvConstants.CONTENT_TYPE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setHeader(CsvConstants.HEADER_CONTENT_DISPOSITION,
                String.format(CsvConstants.DISPOSITION_FORMAT, CsvConstants.DEVICE_FILE_NAME));
        try (PrintWriter writer = response.getWriter()) {
            // UTF-8 BOM，避免 Excel 打开中文乱码
            writer.write(CsvConstants.UTF8_BOM);
            writer.println(CsvConstants.DEVICE_HEADER);
            for (AdminDeviceVO device : devices) {
                writer.println(String.join(CsvConstants.DELIMITER,
                        csv(device.getId()), csv(device.getDeviceId()), csv(device.getDeviceName()),
                        csv(device.getProduct()), csv(device.getFirmware()), csv(device.getLocation()),
                        csv(device.getBindCode()), csv(device.getOnline()), csv(device.getLastOnlineTime()),
                        csv(device.getLastHeartbeatTime()), csv(device.getCreateTime())));
            }
        }
    }

    /**
     * 设备详情
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_READ + "')")
    public ApiResponse<AdminDeviceVO> getDevice(@PathVariable Long id) {
        return ApiResponse.success(deviceAdminService.getDevice(id));
    }

    /**
     * 编辑设备基础信息
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_UPDATE + "')")
    public ApiResponse<Void> updateDevice(@PathVariable Long id,
                                          @RequestBody @Valid DeviceAdminUpdateRequest request) {
        deviceAdminService.updateDevice(id, request);
        return ApiResponse.success(null);
    }

    /**
     * 设备当前绑定用户
     */
    @GetMapping("/{id}/bindings")
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_READ + "')")
    public ApiResponse<Page<DeviceBindingVO>> pageBindings(
            @PathVariable Long id,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_NUM) Integer pageNum,
            @RequestParam(defaultValue = PageConstants.DEFAULT_PAGE_SIZE) Integer pageSize) {
        return ApiResponse.success(deviceAdminService.pageBindings(id, pageNum, pageSize));
    }

    /**
     * 管理员解绑指定用户
     */
    @PostMapping("/{id}/unbind")
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_UNBIND + "')")
    public ApiResponse<Void> unbindDevice(@PathVariable Long id,
                                          @RequestBody @Valid DeviceBindingUnbindRequest request) {
        deviceAdminService.unbindDevice(id, request.getUserId());
        return ApiResponse.success(null);
    }

    /**
     * 管理员下发指令
     */
    @PostMapping("/{id}/command")
    @PreAuthorize("hasAuthority('" + PermissionConstants.COMMAND_SEND + "')")
    public ApiResponse<String> sendCommand(@PathVariable Long id,
                                           @RequestBody @Valid AdminDeviceCommandRequest request) {
        return ApiResponse.success(deviceAdminService.sendCommand(id, request));
    }

    /**
     * 新增设备
     */
    @PostMapping
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_CREATE + "')")
    public ApiResponse<Void> addDevice(@RequestBody @Valid DeviceCreateRequest request) {
        deviceAdminService.createDevice(request);
        return ApiResponse.success(null);
    }

    /**
     * 删除设备
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('" + PermissionConstants.DEVICE_DELETE + "')")
    public ApiResponse<Void> deleteDevice(@PathVariable Long id) {
        deviceAdminService.deleteDevice(id);
        return ApiResponse.success(null);
    }

    private String csv(Object value) {
        if (value == null) {
            return "";
        }
        String text = String.valueOf(value);
        if (text.contains(CsvConstants.DELIMITER)
                || text.contains(CsvConstants.QUOTE)
                || text.contains(CsvConstants.NEW_LINE)) {
            return CsvConstants.QUOTE + text.replace(CsvConstants.QUOTE, CsvConstants.ESCAPED_QUOTE)
                    + CsvConstants.QUOTE;
        }
        return text;
    }
}
