package com.womi.webmodule.dto.ota.request;

import com.womi.commonmodule.constants.MqttConstants;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * OTA 参数
 */
public record OtaParam(
        String url,
        String version,
        String sha256,
        Long size
) {
    public Map<String, Object> toMap() {
        Map<String, Object> map = new LinkedHashMap<>(4);
        map.put(MqttConstants.FIELD_OTA_URL, url);
        map.put(MqttConstants.FIELD_OTA_VERSION, version);
        map.put(MqttConstants.FIELD_OTA_SHA256, sha256);
        map.put(MqttConstants.FIELD_OTA_SIZE, size);
        return map;
    }
}