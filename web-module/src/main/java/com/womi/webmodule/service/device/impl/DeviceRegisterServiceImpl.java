package com.womi.webmodule.service.device.impl;

import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.businessmodule.service.device.DeviceMqttAuthService;
import com.womi.businessmodule.service.device.DeviceWhitelistService;
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.constants.RegexConstants;
import com.womi.commonmodule.enums.MqttErrorCode;
import com.womi.commonmodule.enums.DeviceOfflineReason;
import com.womi.commonmodule.utils.SignatureVerifierUtils;
import com.womi.commonmodule.utils.TimestampValidatorUtils;
import com.womi.webmodule.dto.mqtt.MqttCredential;
import com.womi.webmodule.dto.mqtt.request.RegisterRequest;
import com.womi.webmodule.dto.mqtt.response.RegisterResponse;
import com.womi.webmodule.mqtt.core.MqttCredentialGenerator;
import com.womi.webmodule.mqtt.core.MqttProperties;
import com.womi.webmodule.service.device.DeviceRegisterService;
import com.womi.webmodule.service.device.NonceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceRegisterServiceImpl implements DeviceRegisterService {

    private final DeviceInfoService deviceInfoService;
    private final MqttProperties mqttProperties;
    private final DeviceMqttAuthService mqttAuthService;
    private final MqttCredentialGenerator credentialGenerator;
    private final NonceService nonceService;
    private final DeviceWhitelistService deviceWhitelistService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public RegisterResponse register(RegisterRequest request) {
        // ==================== 1. 基础校验 ====================
        String deviceId = request.getDeviceId();
        if (deviceId == null || deviceId.isBlank()) {
            return RegisterResponse.error(MqttErrorCode.INVALID_DEVICE_ID);
        }
        if (!deviceId.matches(RegexConstants.MAC)) {
            return RegisterResponse.error(MqttErrorCode.INVALID_DEVICE_ID,
                    MqttErrorCode.INVALID_DEVICE_ID.getMessage());
        }
        if (request.getProduct() == null || request.getProduct().isBlank()) {
            return RegisterResponse.error(MqttErrorCode.PARAM_MISSING,
                    MqttErrorCode.PARAM_MISSING.getMessage());
        }
        // 1.1 校验签名材料（长度/格式）
        if (!isValidSignatureMaterial(request)) {
            log.warn("签名材料格式不合法 - deviceId: {}", deviceId);
            return RegisterResponse.error(MqttErrorCode.PARAM_INVALID, "签名材料格式不合法");
        }

        // ==================== 2. 白名单校验 ====================
        if (!deviceWhitelistService.isAllowed(deviceId)) {
            log.warn("设备不在白名单，拒绝注册 - deviceId: {}", deviceId);
            return RegisterResponse.error(MqttErrorCode.DEVICE_NOT_AUTHORIZED);
        }

        // ==================== 3. 已注册设备校验 ====================
        DeviceInfo existing = deviceInfoService.getByDeviceId(deviceId);
        boolean isReregister = false;

        if (existing != null && existing.getPubkey() != null && !existing.getPubkey().isBlank()) {
            // 已注册 → 必须 pubkey 一致才能重注册
            if (!existing.getPubkey().equals(request.getPubkey())) {
                log.warn("pubkey 不一致，疑似冒充 - deviceId: {}", deviceId);
                return RegisterResponse.error(MqttErrorCode.DEVICE_ALREADY_REGISTERED);
            }
            isReregister = true;
            log.info("设备重注册（pubkey 一致）- deviceId: {}", deviceId);
        }

        // ==================== 4. 安全校验（先验签，后处理 nonce） ====================
        // 4.1 时间戳校验
        if (request.getTimestamp() == null
                || !TimestampValidatorUtils.isWithinWindow(request.getTimestamp(),
                DeviceMqttConstants.REGISTER_TIMESTAMP_WINDOW_MS)) {
            return RegisterResponse.error(MqttErrorCode.INVALID_TIMESTAMP);
        }
        // 4.2 签名校验
        String verifyPubkey = (existing != null && existing.getPubkey() != null && !existing.getPubkey().isBlank())
                ? existing.getPubkey()
                : request.getPubkey();
        if (!verifySignature(verifyPubkey, request)) {
            log.warn("签名验证失败 - deviceId: {}", deviceId);
            return RegisterResponse.error(MqttErrorCode.INVALID_SIGNATURE);
        }
        // 4.3 nonce 防重放：先检查（不消耗），事务提交后才真正消耗
        String nonce = request.getNonce();
        if (nonceService.exists(nonce)) {
            return RegisterResponse.error(MqttErrorCode.REPLAY_ATTACK);
        }

        // ==================== 5. 业务处理 ====================
        // 5.1 生成 MQTT 凭据
        MqttCredential credential = credentialGenerator.generate(deviceId);

        // 5.2 保存设备信息 + 凭据（首次注册 or 重注册）
        try {
            if (isReregister) {
                saveReregister(existing, request, credential);
            } else {
                saveFirstTimeDevice(request, credential);
            }
        } catch (DuplicateKeyException e) {
            log.warn("并发注册冲突 - deviceId: {}", deviceId);
            return RegisterResponse.error(MqttErrorCode.DEVICE_ALREADY_REGISTERED);
        }

        // 5.3 事务提交后消耗 nonce
        registerNonceConsumption(nonce);

        // ==================== 6. 组装响应 ====================
        RegisterResponse response = RegisterResponse.success(
                buildMqttConfig(credential),
                buildWillConfig(deviceId, request.getProduct()),
                buildDeviceConfig()
        );

        log.info("设备注册成功 - deviceId: {}, isReregister: {}, clientId: {}, username: {}",
                deviceId, isReregister, credential.getClientId(), credential.getUsername());
        return response;
    }

    // ==================== 私有方法 ====================

    /**
     * 校验签名材料（pubkey / nonce / signature）的长度与格式
     */
    private boolean isValidSignatureMaterial(RegisterRequest request) {
        String pubkey = request.getPubkey();
        String nonce = request.getNonce();
        String signature = request.getSignature();

        if (pubkey == null || pubkey.isBlank() || pubkey.length() > DeviceConstants.MAX_PUBKEY_LENGTH) {
            return false;
        }
        if (!pubkey.contains("BEGIN PUBLIC KEY")) {
            return false;
        }
        if (nonce == null || nonce.isBlank() || nonce.length() > DeviceConstants.MAX_NONCE_LENGTH) {
            return false;
        }
        if (signature == null || signature.isBlank() || signature.length() > DeviceConstants.MAX_SIGNATURE_LENGTH) {
            return false;
        }
        return true;
    }

    /**
     * 校验签名
     *
     * @param pubkey 用于验签的公钥（重注册用数据库的，首次用请求的）
     */
    private boolean verifySignature(String pubkey, RegisterRequest request) {
        String signData = request.getDeviceId() + "|" + request.getTimestamp() + "|" + request.getNonce();
        return SignatureVerifierUtils.verify(pubkey, signData, request.getSignature());
    }

    /**
     * 事务提交后消耗 nonce：确保业务失败回滚时 nonce 不被消耗，允许设备重试。
     */
    private void registerNonceConsumption(String nonce) {
        if (!TransactionSynchronizationManager.isSynchronizationActive()) {
            nonceService.tryAcquire(nonce);
            return;
        }
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                try {
                    boolean acquired = nonceService.tryAcquire(nonce);
                    if (!acquired) {
                        log.warn("nonce 提交后消耗失败（可能并发） - nonce: {}", nonce);
                    }
                } catch (Exception e) {
                    log.error("消耗 nonce 失败 - nonce: {}", nonce, e);
                }
            }
        });
    }

    /**
     * 首次注册：保存设备信息 + MQTT 凭据
     */
    private void saveFirstTimeDevice(RegisterRequest request, MqttCredential credential) {
        // 1. 保存 device_info
        LocalDateTime now = LocalDateTime.now();
        DeviceInfo device = new DeviceInfo();
        device.setDeviceId(request.getDeviceId());
        device.setProduct(request.getProduct());
        device.setFirmware(request.getFirmware());
        device.setPubkey(request.getPubkey());
        device.setOnline(DeviceConstants.DEVICE_STATUS_OFFLINE);
        device.setOfflineReason(null);
        device.setCreateTime(now);
        device.setUpdateTime(now);
        deviceInfoService.save(device);

        // 2. 保存 MQTT 凭据
        mqttAuthService.saveOrUpdateDeviceAuth(
                request.getDeviceId(),
                credential.getUsername(),
                credential.getPasswordHash(),
                credential.getSalt(),
                DeviceConstants.MQTT_STATUS_ENABLE
        );
    }

    /**
     * 重注册：只更新设备信息（product/firmware），重新分配 MQTT 凭据
     * <p>pubkey 保持不变（出厂预置），不覆盖
     */
    private void saveReregister(DeviceInfo existing, RegisterRequest request, MqttCredential credential) {
        // 1. 更新 device_info（不动 pubkey）
        existing.setProduct(request.getProduct());
        existing.setFirmware(request.getFirmware());
        existing.setUpdateTime(LocalDateTime.now());
        deviceInfoService.updateById(existing);

        // 2. 覆盖 MQTT 凭据（旧凭据作废）
        mqttAuthService.saveOrUpdateDeviceAuth(
                request.getDeviceId(),
                credential.getUsername(),
                credential.getPasswordHash(),
                credential.getSalt(),
                DeviceConstants.MQTT_STATUS_ENABLE
        );
    }

    private Map<String, Object> buildMqttConfig(MqttCredential credential) {
        MqttProperties.Broker runtime = mqttProperties.getRuntime();

        Map<String, Object> mqtt = new LinkedHashMap<>();
        mqtt.put(DeviceMqttConstants.FIELD_MQTT_HOST, runtime.getHost());
        mqtt.put(DeviceMqttConstants.FIELD_MQTT_PORT, runtime.getPort());
        mqtt.put(DeviceMqttConstants.FIELD_MQTT_CLIENT_ID, credential.getClientId());
        mqtt.put(DeviceMqttConstants.FIELD_MQTT_USERNAME, credential.getUsername());
        mqtt.put(DeviceMqttConstants.FIELD_MQTT_PASSWORD, credential.getPlainPassword());
        mqtt.put(DeviceMqttConstants.FIELD_MQTT_KEEP_ALIVE, runtime.getKeepAliveInterval());
        return mqtt;
    }

    private Map<String, Object> buildWillConfig(String deviceId, String product) {
        Map<String, Object> willPayload = new LinkedHashMap<>();
        willPayload.put(DeviceMqttConstants.FIELD_DEVICE, deviceId);
        willPayload.put(DeviceMqttConstants.FIELD_PRODUCT, product);
        willPayload.put(DeviceMqttConstants.FIELD_TYPE, DeviceMqttConstants.MSG_TYPE_OFFLINE);
        willPayload.put(DeviceMqttConstants.FIELD_TIMESTAMP, DeviceMqttConstants.WILL_TIMESTAMP_DEFAULT);

        Map<String, Object> willData = new LinkedHashMap<>();
        willData.put(DeviceMqttConstants.FIELD_REASON, DeviceOfflineReason.MQTT_LWT.getCode());
        willPayload.put(DeviceMqttConstants.FIELD_DATA, willData);

        Map<String, Object> will = new LinkedHashMap<>();
        will.put(DeviceMqttConstants.FIELD_WILL_TOPIC, String.format(DeviceMqttConstants.PRESENCE_TOPIC_FORMAT, deviceId));
        will.put(DeviceMqttConstants.FIELD_WILL_QOS, DeviceMqttConstants.DEFAULT_QOS);
        will.put(DeviceMqttConstants.FIELD_WILL_RETAIN, DeviceMqttConstants.PRESENCE_RETAINED);
        will.put(DeviceMqttConstants.FIELD_WILL_PAYLOAD, willPayload);
        return will;
    }

    private Map<String, Object> buildDeviceConfig() {
        Map<String, Object> config = new LinkedHashMap<>();
        config.put(DeviceMqttConstants.FIELD_HEARTBEAT_INTERVAL, DeviceMqttConstants.DEFAULT_HEARTBEAT_INTERVAL);
        config.put(DeviceMqttConstants.FIELD_SENSOR_BATCH_SIZE, DeviceMqttConstants.DEFAULT_SENSOR_BATCH_SIZE);
        return config;
    }
}