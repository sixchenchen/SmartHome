package com.womi.webmodule.service;


import com.womi.webmodule.dto.http.request.SendCommandRequest;
import com.womi.webmodule.dto.ota.response.DeviceOtaProgressVO;
import com.womi.webmodule.dto.ota.response.DeviceOtaStartResponse;

public interface DeviceOtaService {

    /**
     * 触发 OTA
     */
    DeviceOtaStartResponse startOta(SendCommandRequest request);

    /**
     * 查询 OTA 进度
     */
    DeviceOtaProgressVO getOtaProgress(String deviceId);

}