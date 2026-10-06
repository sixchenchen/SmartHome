package com.womi.webmodule.service.impl;

import com.womi.businessmodule.model.DeviceInfo;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.commonmodule.constants.MqttConstants;
import com.womi.commonmodule.constants.RegexConstants;
import com.womi.commonmodule.enums.MqttErrorCode;
import com.womi.commonmodule.enums.OfflineReason;
import com.womi.commonmodule.utils.SignatureVerifier;
import com.womi.commonmodule.utils.TimestampValidator;
import com.womi.webmodule.dto.mqtt.request.RegisterRequest;
import com.womi.webmodule.dto.mqtt.response.RegisterResponse;
import com.womi.webmodule.mqtt.core.MqttCredentialGenerator;
import com.womi.webmodule.mqtt.core.MqttProperties;
import com.womi.webmodule.service.DeviceRegisterService;
import com.womi.webmodule.service.NonceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceRegisterServiceImpl implements DeviceRegisterService {

    private final DeviceInfoService deviceInfoService;
    private final MqttProperties mqttProperties;
    private final MqttCredentialGenerator credentialGenerator;
    private final NonceService nonceService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public RegisterResponse register(RegisterRequest request) {
        // ==================== 1. 基础校验 ====================
        String deviceId = request.getDeviceId();
        if (deviceId == null || deviceId.isBlank()) {
            return RegisterResponse.error(MqttErrorCode.INVALID_DEVICE_ID);
        }
        if (!deviceId.matches(RegexConstants.MAC)) {
            return RegisterResponse.error(MqttErrorCode.INVALID_DEVICE_ID, "MAC 格式错误");
        }
        if (request.getProduct() == null || request.getProduct().isBlank()) {
            return RegisterResponse.error(MqttErrorCode.PARAM_MISSING, "product 为空");
        }

        // ==================== 2. 安全校验 ====================
        // 2.1 时间戳校验
        if (!TimestampValidator.isWithinWindow(
                request.getTimestamp(),
                MqttConstants.REGISTER_TIMESTAMP_WINDOW_MS)) {
            return RegisterResponse.error(MqttErrorCode.INVALID_TIMESTAMP);
        }
        // 2.2 nonce 防重放
        if (!nonceService.tryAcquire(request.getNonce())) {
            return RegisterResponse.error(MqttErrorCode.REPLAY_ATTACK);
        }
        // 2.3 签名校验
        if (!verifySignature(request)) {
            log.warn("签名验证失败 - deviceId: {}", deviceId);
            return RegisterResponse.error(MqttErrorCode.INVALID_SIGNATURE);
        }

        // ==================== 3. 业务处理 ====================
        try {
            String clientId = credentialGenerator.generateClientId(deviceId);
            String username = credentialGenerator.generateUsername(deviceId);
            String password = credentialGenerator.generatePassword(deviceId);

            saveDeviceInfo(request);

            RegisterResponse response = RegisterResponse.success(
                    buildMqttConfig(clientId, username, password),
                    buildWillConfig(deviceId, request.getProduct()),
                    buildDeviceConfig()
            );

            log.info("设备注册成功 - deviceId: {}, clientId: {}", deviceId, clientId);
            return response;

        } catch (Exception e) {
            log.error("设备注册异常 - deviceId: {}", deviceId, e);
            return RegisterResponse.error(MqttErrorCode.SERVER_ERROR);
        }
    }

    // ==================== 私有方法 ====================

    /**
     * 校验签名
     * <p>待签数据：{device}|{timestamp}|{nonce}（注册业务专属格式）
     */
    private boolean verifySignature(RegisterRequest request) {
        if (request.getPubkey() == null || request.getSignature() == null) {
            return false;
        }
        String signData = request.getDeviceId()
                + "|" + request.getTimestamp()
                + "|" + request.getNonce();
        return SignatureVerifier.verify(
                request.getPubkey(),
                signData,
                request.getSignature()
        );
    }

    private void saveDeviceInfo(RegisterRequest request) {
        DeviceInfo device = deviceInfoService.getOrCreateDevice(request.getDeviceId());
        device.setProduct(request.getProduct());
        device.setFirmware(request.getFirmware());
        device.setOnline(0);
        device.setOfflineReason(null);
        device.setLastUpdateTime(LocalDateTime.now());
        deviceInfoService.updateById(device);
    }

    private Map<String, Object> buildMqttConfig(String clientId, String username, String password) {
        Map<String, Object> mqtt = new LinkedHashMap<>();
        mqtt.put(MqttConstants.FIELD_MQTT_HOST, mqttProperties.getHost());
        mqtt.put(MqttConstants.FIELD_MQTT_PORT, mqttProperties.getPort());
        mqtt.put(MqttConstants.FIELD_MQTT_CLIENT_ID, clientId);
        mqtt.put(MqttConstants.FIELD_MQTT_USERNAME, username);
        mqtt.put(MqttConstants.FIELD_MQTT_PASSWORD, password);
        mqtt.put(MqttConstants.FIELD_MQTT_KEEP_ALIVE, mqttProperties.getKeepAliveInterval());
        return mqtt;
    }

    private Map<String, Object> buildWillConfig(String deviceId, String product) {
        Map<String, Object> willPayload = new LinkedHashMap<>();
        willPayload.put(MqttConstants.FIELD_DEVICE, deviceId);
        willPayload.put(MqttConstants.FIELD_PRODUCT, product);
        willPayload.put(MqttConstants.FIELD_TYPE, MqttConstants.MSG_TYPE_OFFLINE);
        willPayload.put(MqttConstants.FIELD_TIMESTAMP, 0);

        Map<String, Object> willData = new LinkedHashMap<>();
        willData.put(MqttConstants.FIELD_REASON, OfflineReason.MQTT_LWT.getCode());
        willPayload.put(MqttConstants.FIELD_DATA, willData);

        Map<String, Object> will = new LinkedHashMap<>();
        will.put(MqttConstants.FIELD_WILL_TOPIC, String.format(MqttConstants.WILL_TOPIC_FORMAT, deviceId));
        will.put(MqttConstants.FIELD_WILL_QOS, MqttConstants.DEFAULT_QOS);
        will.put(MqttConstants.FIELD_WILL_RETAIN, MqttConstants.PRESENCE_RETAINED);
        will.put(MqttConstants.FIELD_WILL_PAYLOAD, willPayload);
        return will;
    }

    private Map<String, Object> buildDeviceConfig() {
        Map<String, Object> config = new LinkedHashMap<>();
        config.put(MqttConstants.FIELD_HEARTBEAT_INTERVAL, MqttConstants.DEFAULT_HEARTBEAT_INTERVAL);
        config.put(MqttConstants.FIELD_SENSOR_BATCH_SIZE, MqttConstants.DEFAULT_SENSOR_BATCH_SIZE);
        return config;
    }
}