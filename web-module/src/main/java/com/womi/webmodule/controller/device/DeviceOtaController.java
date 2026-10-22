package com.womi.webmodule.controller.device;

import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.dto.http.request.SendCommandRequest;
import com.womi.webmodule.dto.ota.response.DeviceOtaProgressVO;
import com.womi.webmodule.dto.ota.response.DeviceOtaStartResponse;
import com.womi.webmodule.service.device.DeviceOtaService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/ota")
@RequiredArgsConstructor
public class DeviceOtaController {

    private final DeviceOtaService deviceOtaService;

    /**
     * 触发 OTA
     * POST /api/ota/start
     */
    @PostMapping("/start")
    public ApiResponse<DeviceOtaStartResponse> start(@RequestBody SendCommandRequest req) {
        DeviceOtaStartResponse response = deviceOtaService.startOta(req);
        return ApiResponse.success(response);
    }

    /**
     * 查询 OTA 进度
     * GET /api/ota/{deviceId}/progress
     */
    @GetMapping("/{deviceId}/progress")
    public ApiResponse<DeviceOtaProgressVO> progress(@PathVariable String deviceId) {
        DeviceOtaProgressVO vo = deviceOtaService.getOtaProgress(deviceId);
        return ApiResponse.success(vo);
    }
}