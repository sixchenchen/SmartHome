package com.womi.webmodule.service.mqtt;


import com.womi.businessmodule.dto.DeviceRegisterRequest;
import com.womi.businessmodule.vo.DeviceRegisterResponse;

public interface DeviceRegisterService {

    /**
     * 处理设备注册
     *
     * @param request 注册请求
     * @return 注册响应（含 MQTT 凭据）
     */
    DeviceRegisterResponse register(DeviceRegisterRequest request);
}