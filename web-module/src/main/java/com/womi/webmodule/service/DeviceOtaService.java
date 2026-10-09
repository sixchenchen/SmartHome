package com.womi.webmodule.service;


import com.womi.webmodule.dto.ota.request.OtaStartRequest;
import com.womi.webmodule.dto.ota.response.OtaProgressVO;
import com.womi.webmodule.dto.ota.response.OtaStartResponse;

public interface DeviceOtaService {

    /**
     * 触发 OTA
     */
    OtaStartResponse startOta(OtaStartRequest request);

    /**
     * 查询 OTA 进度
     */
    OtaProgressVO getOtaProgress(String deviceId);
}