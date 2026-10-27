package com.womi.webmodule.service.mqtt;


import com.womi.businessmodule.dto.SendCommandRequest;
import com.womi.businessmodule.vo.DeviceOtaProgressVO;
import com.womi.businessmodule.vo.DeviceOtaStartResponse;

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