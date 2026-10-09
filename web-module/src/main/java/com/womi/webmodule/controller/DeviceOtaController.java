package com.womi.webmodule.controller;

import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.dto.ota.request.OtaStartRequest;
import com.womi.webmodule.dto.ota.response.OtaProgressVO;
import com.womi.webmodule.dto.ota.response.OtaStartResponse;
import com.womi.webmodule.service.DeviceOtaService;
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
    public ApiResponse<OtaStartResponse> start(@RequestBody OtaStartRequest request) {
        OtaStartResponse response = deviceOtaService.startOta(request);
        return ApiResponse.success(response);
    }

    /**
     * 查询 OTA 进度
     * GET /api/ota/{deviceId}/progress
     */
    @GetMapping("/{deviceId}/progress")
    public ApiResponse<OtaProgressVO> progress(@PathVariable String deviceId) {
        OtaProgressVO vo = deviceOtaService.getOtaProgress(deviceId);
        return ApiResponse.success(vo);
    }
}