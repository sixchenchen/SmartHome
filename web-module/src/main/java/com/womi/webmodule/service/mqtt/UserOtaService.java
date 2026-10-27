package com.womi.webmodule.service.mqtt;

import com.womi.businessmodule.vo.OtaCheckResponse;

public interface UserOtaService {
    OtaCheckResponse checkUpdate(Long userId, String deviceId);
    void startOta(Long userId, String deviceId);
}