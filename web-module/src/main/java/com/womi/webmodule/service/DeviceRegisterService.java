package com.womi.webmodule.service;


import com.womi.webmodule.dto.mqtt.request.RegisterRequest;
import com.womi.webmodule.dto.mqtt.response.RegisterResponse;

public interface DeviceRegisterService {

    /**
     * 处理设备注册
     *
     * @param request 注册请求
     * @return 注册响应（含 MQTT 凭据）
     */
    RegisterResponse register(RegisterRequest request);
}