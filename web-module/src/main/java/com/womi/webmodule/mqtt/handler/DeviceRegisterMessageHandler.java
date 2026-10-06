package com.womi.webmodule.mqtt.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.womi.commonmodule.constants.MqttConstants;
import com.womi.commonmodule.enums.MqttErrorCode;
import com.womi.commonmodule.utils.JsonUtils;
import com.womi.webmodule.dto.mqtt.request.RegisterRequest;
import com.womi.webmodule.dto.mqtt.response.RegisterResponse;
import com.womi.webmodule.mqtt.core.MqttMessageHandler;
import com.womi.webmodule.mqtt.core.MqttPublisher;
import com.womi.webmodule.service.DeviceRegisterService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 设备注册处理器
 *
 *payload:
 * {
 *   "device": "B4BFE90CDBA0",
 *   "product": "SmartHome-v1",
 *   "type": "register",
 *   "timestamp": 1710000000700,
 *   "data": {
 *     "firmware": "1.0.29",
 *     "chip": "ESP32",
 *     "hardware_version": "V1.0",
 *     "nonce": "550e8400-...",
 *     "pubkey": "-----BEGIN PUBLIC KEY-----...",
 *     "signature": "MEUCIQDxYz..."
 *   }
 * }
 * </pre>
 */
@Slf4j
@Component
@Order(1)
@RequiredArgsConstructor
public class DeviceRegisterMessageHandler implements MqttMessageHandler {

    private final JsonUtils jsonUtils;
    private final MqttPublisher mqttPublisher;
    private final DeviceRegisterService deviceRegisterService;

    @Override
    public boolean supports(String topic) {
        return topic != null && topic.matches(MqttConstants.PROVISION_REGISTER_TOPIC_PATTERN);
    }

    @Override
    public void handle(String topic, String payload, Integer qos) {
        try {
            // 1. 提取 deviceId
            String deviceId = extractProvisionDeviceId(topic);
            if (deviceId == null) {
                log.warn("无法提取设备ID - Topic: {}", topic);
                return;
            }

            // 2. 解析 payload
            JsonNode json = jsonUtils.parse(payload);
            if (json == null) {
                log.warn("payload 解析失败 - Topic: {}", topic);
                sendResponse(deviceId, RegisterResponse.error(MqttErrorCode.INVALID_PAYLOAD));
                return;
            }

            // 3. 提取字段 → 组装 RegisterRequest
            RegisterRequest request = buildRequest(deviceId, json);

            // 4. 调业务层（含验签、防重放、分配凭据）
            RegisterResponse response = deviceRegisterService.register(request);

            // 5. 发送响应
            sendResponse(deviceId, response);

            log.info("设备注册处理完成 - deviceId: {}, success: {}",
                    deviceId, response.isSuccess());

        } catch (Exception e) {
            log.error("处理注册请求失败 - topic: {}, error: {}", topic, e.getMessage(), e);
        }
    }

    // ==================== 私有方法 ====================

    /**
     * 从 JSON 构建 RegisterRequest
     */
    private RegisterRequest buildRequest(String deviceId, JsonNode json) {
        RegisterRequest request = new RegisterRequest();
        request.setDeviceId(deviceId);
        request.setProduct(jsonUtils.getString(json, MqttConstants.FIELD_PRODUCT));
        request.setTimestamp(jsonUtils.getLong(json, MqttConstants.FIELD_TIMESTAMP));

        JsonNode dataNode = json.path(MqttConstants.FIELD_DATA);
        request.setFirmware(jsonUtils.getString(dataNode, MqttConstants.FIELD_FIRMWARE));
        request.setChip(jsonUtils.getString(dataNode, MqttConstants.FIELD_CHIP));
        request.setHardwareVersion(jsonUtils.getString(dataNode, MqttConstants.FIELD_HARDWARE_VERSION));
        request.setNonce(jsonUtils.getString(dataNode, MqttConstants.FIELD_NONCE));
        request.setPubkey(jsonUtils.getString(dataNode, MqttConstants.FIELD_PUBKEY));
        request.setSignature(jsonUtils.getString(dataNode, MqttConstants.FIELD_SIGNATURE));

        return request;
    }

    /**
     * 发送注册响应到 /provision/device/{mac}/config
     */
    private void sendResponse(String deviceId, RegisterResponse response) {
        String responseTopic = String.format(
                MqttConstants.PROVISION_CONFIG_TOPIC_FORMAT, deviceId);

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put(MqttConstants.FIELD_DEVICE, deviceId);
        payload.put(MqttConstants.FIELD_SUCCESS, response.isSuccess());

        if (response.isSuccess()) {
            payload.put(MqttConstants.FIELD_MQTT, response.getMqtt());
            payload.put(MqttConstants.FIELD_WILL, response.getWill());
            payload.put(MqttConstants.FIELD_CONFIG, response.getConfig());
        } else {
            payload.put(MqttConstants.FIELD_ERROR, response.getError());
            payload.put(MqttConstants.FIELD_MESSAGE, response.getMessage());
        }
        payload.put(MqttConstants.FIELD_TIMESTAMP, System.currentTimeMillis());

        mqttPublisher.publish(responseTopic, payload, MqttConstants.DEFAULT_QOS, false);

        log.info("注册响应已发送 - deviceId: {}, topic: {}", deviceId, responseTopic);
    }
}