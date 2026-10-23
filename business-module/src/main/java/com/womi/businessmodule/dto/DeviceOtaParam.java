package com.womi.businessmodule.dto;

import com.womi.commonmodule.constants.DeviceMqttConstants;
import lombok.Builder;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * OTA 参数
 */

@Builder
public record DeviceOtaParam(
        String url,
        String version,
        String sha256,
        Long size
) {
    public Map<String, Object> toMap() {
        Map<String, Object> map = new LinkedHashMap<>(4);
        map.put(DeviceMqttConstants.FIELD_OTA_URL, url);
        map.put(DeviceMqttConstants.FIELD_OTA_VERSION, version);
        map.put(DeviceMqttConstants.FIELD_OTA_SHA256, sha256);
        map.put(DeviceMqttConstants.FIELD_OTA_SIZE, size);
        return map;
    }
}