package com.womi.webmodule.service.impl;

import com.womi.businessmodule.model.DeviceInfo;
import com.womi.businessmodule.service.DeviceInfoService;
import com.womi.businessmodule.service.MqttAuthService;
import com.womi.commonmodule.constants.MqttConstants;
import com.womi.commonmodule.constants.RegexConstants;
import com.womi.commonmodule.enums.MqttErrorCode;
import com.womi.commonmodule.enums.OfflineReason;

import com.womi.commonmodule.utils.SignatureVerifierUtils;
import com.womi.commonmodule.utils.TimestampValidatorUtils;
import com.womi.webmodule.dto.mqtt.MqttCredential;
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

import static com.womi.commonmodule.constants.DeviceConstants.DEVICE_STATUS_ONLINE;
import static com.womi.commonmodule.constants.DeviceConstants.MQTT_STATUS_ENABLE;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceRegisterServiceImpl implements DeviceRegisterService {

    private final DeviceInfoService deviceInfoService;
    private final MqttProperties mqttProperties;
    private final MqttAuthService mqttAuthService;
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
        if (!TimestampValidatorUtils.isWithinWindow(request.getTimestamp(), MqttConstants.REGISTER_TIMESTAMP_WINDOW_MS)) {
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
            // ---------- 3.1 生成 MQTT 凭据 ----------
            MqttCredential credential = credentialGenerator.generate(deviceId);

            // ---------- 3.2 保存设备信息----------
            saveDeviceAndAuth(request, credential);

            // ---------- 3.3 响应----------
            RegisterResponse response = RegisterResponse.success(
                    buildMqttConfig(credential),
                    buildWillConfig(deviceId, request.getProduct()),
                    buildDeviceConfig()
            );
            log.info("设备注册成功 - deviceId: {}, clientId: {}, username: {}", deviceId, credential.getClientId(), credential.getUsername());
            return response;

        } catch (Exception e) {
            log.error("设备注册异常 - deviceId: {}", deviceId, e);
            return RegisterResponse.error(MqttErrorCode.SERVER_ERROR);
        }
    }

    /**
     * 校验签名
     * 待签数据：{device}|{timestamp}|{nonce}（注册业务专属格式）
     */
    private boolean verifySignature(RegisterRequest request) {
        if (request.getPubkey() == null || request.getSignature() == null) {
            return false;
        }
        String signData = request.getDeviceId() + "|" + request.getTimestamp() + "|" + request.getNonce();
        return SignatureVerifierUtils.verify(request.getPubkey(), signData, request.getSignature());
    }

    private void saveDeviceAndAuth(RegisterRequest request, MqttCredential credential) {
        // ----- 1. 更新 device_info 基本信息 -----
        DeviceInfo device = deviceInfoService.getOrCreateDevice(request.getDeviceId());
        device.setProduct(request.getProduct());
        device.setFirmware(request.getFirmware());
        device.setOnline(DEVICE_STATUS_ONLINE);
        device.setOfflineReason(null);

        // 首次注册时保存 pubkey
        if (device.getPubkey() == null && request.getPubkey() != null) {
            device.setPubkey(request.getPubkey());
        }
        device.setUpdateTime(LocalDateTime.now());
        deviceInfoService.updateById(device);

        // ----- 2. 保存 MQTT 认证信息到 mqtt_auth -----
        mqttAuthService.saveOrUpdateDeviceAuth(
                request.getDeviceId(),
                credential.getUsername(),
                credential.getPasswordHash(),
                credential.getSalt(),
                MQTT_STATUS_ENABLE
        );
    }

    private Map<String, Object> buildMqttConfig(MqttCredential credential) {
        MqttProperties.Broker runtime = mqttProperties.getRuntime();

        Map<String, Object> mqtt = new LinkedHashMap<>();
        mqtt.put(MqttConstants.FIELD_MQTT_HOST, runtime.getHost());
        mqtt.put(MqttConstants.FIELD_MQTT_PORT, runtime.getPort());
        mqtt.put(MqttConstants.FIELD_MQTT_CLIENT_ID, credential.getClientId());
        mqtt.put(MqttConstants.FIELD_MQTT_USERNAME, credential.getUsername());
        mqtt.put(MqttConstants.FIELD_MQTT_PASSWORD, credential.getPlainPassword());
        mqtt.put(MqttConstants.FIELD_MQTT_KEEP_ALIVE, runtime.getKeepAliveInterval());
        return mqtt;
    }

    private Map<String, Object> buildWillConfig(String deviceId, String product) {
        Map<String, Object> willPayload = new LinkedHashMap<>();
        willPayload.put(MqttConstants.FIELD_DEVICE, deviceId);
        willPayload.put(MqttConstants.FIELD_PRODUCT, product);
        willPayload.put(MqttConstants.FIELD_TYPE, MqttConstants.MSG_TYPE_OFFLINE);
        willPayload.put(MqttConstants.FIELD_TIMESTAMP, MqttConstants.WILL_TIMESTAMP_DEFAULT);

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