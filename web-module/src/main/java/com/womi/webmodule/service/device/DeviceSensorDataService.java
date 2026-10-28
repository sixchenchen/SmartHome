package com.womi.webmodule.service.device;

import com.fasterxml.jackson.databind.JsonNode;

// 接口
public interface DeviceSensorDataService {
    void processSensorData(String deviceId, JsonNode dataArray);
}