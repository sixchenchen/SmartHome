package com.womi.webmodule.service.mqtt.impl;

import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.businessmodule.service.device.DeviceMqttAuthService;
import com.womi.businessmodule.service.device.DeviceWhitelistService;
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.constants.RegexConstants;
import com.womi.commonmodule.enums.MqttErrorCode;
import com.womi.commonmodule.enums.DeviceOfflineReason;
import com.womi.commonmodule.utils.MacUtils;
import com.womi.commonmodule.utils.SignatureVerifierUtils;
import com.womi.commonmodule.utils.TimestampValidatorUtils;
import com.womi.businessmodule.model.mqtt.MqttCredential;
import com.womi.businessmodule.dto.DeviceRegisterRequest;
import com.womi.businessmodule.vo.DeviceRegisterResponse;
import com.womi.webmodule.mqtt.core.MqttCredentialGenerator;
import com.womi.commonmodule.properties.MqttProperties;
import com.womi.webmodule.service.mqtt.DeviceRegisterService;
import com.womi.webmodule.service.mqtt.NonceService;
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
    public DeviceRegisterResponse register(DeviceRegisterRequest request) {
        // ==================== 1. 基础校验 & 全局清洗 ====================
        // 清洗并直接覆盖，从此 request.getDeviceId() 永远是无冒号大写格式
        String cleanMac = MacUtils.normalize(request.getDeviceId());
        if (cleanMac == null || cleanMac.isBlank() || !cleanMac.matches(RegexConstants.MAC)) {
            return DeviceRegisterResponse.error(MqttErrorCode.INVALID_DEVICE_ID,
                    MqttErrorCode.INVALID_DEVICE_ID.getMessage());
        }
        request.setDeviceId(cleanMac); // 👈 核心魔法：覆盖原对象

        String deviceId = request.getDeviceId(); // 后续全用这个，其实与 cleanMac 等价

        if (request.getProduct() == null || request.getProduct().isBlank()) {
            return DeviceRegisterResponse.error(MqttErrorCode.PARAM_MISSING,
                    MqttErrorCode.PARAM_MISSING.getMessage());
        }
        // 1.1 校验签名材料（长度/格式）
        if (!isValidSignatureMaterial(request)) {
            log.warn("签名材料格式不合法 - deviceId: {}", deviceId);
            return DeviceRegisterResponse.error(MqttErrorCode.PARAM_INVALID, "签名材料格式不合法");
        }

        // ==================== 2. 白名单校验 ====================
        if (!deviceWhitelistService.isAllowed(deviceId)) {
            log.warn("设备不在白名单，拒绝注册 - deviceId: {}", deviceId);
            return DeviceRegisterResponse.error(MqttErrorCode.DEVICE_NOT_AUTHORIZED);
        }

        // ==================== 3. 已注册设备校验 ====================
        DeviceInfo existing = deviceInfoService.getByDeviceId(deviceId);
        boolean isReregister = false;
        boolean isPreRegistered = false;

        if (existing != null) {
            if (existing.getPubkey() != null && !existing.getPubkey().isBlank()) {
                if (!existing.getPubkey().equals(request.getPubkey())) {
                    log.warn("pubkey 不一致，疑似冒充 - deviceId: {}", deviceId);
                    return DeviceRegisterResponse.error(MqttErrorCode.DEVICE_ALREADY_REGISTERED);
                }
                isReregister = true;
                log.info("设备重注册（pubkey 一致）- deviceId: {}", deviceId);
            } else {
                isPreRegistered = true;
                log.info("预登记设备首次激活 - deviceId: {}", deviceId);
            }
        }

        // ==================== 4. 安全校验（先验签，后处理 nonce） ====================
        if (request.getTimestamp() == null || !TimestampValidatorUtils.isWithinWindow(request.getTimestamp(),
                DeviceMqttConstants.REGISTER_TIMESTAMP_WINDOW_MS)) {
            log.warn("时间戳校验失败 - deviceId: {}, 设备时间: {}, 服务器时间: {}", deviceId, request.getTimestamp(), System.currentTimeMillis());
            return DeviceRegisterResponse.error(MqttErrorCode.INVALID_TIMESTAMP);
        }

        String verifyPubkey = (existing != null && existing.getPubkey() != null && !existing.getPubkey().isBlank())
                ? existing.getPubkey()
                : request.getPubkey();
        if (!verifySignature(verifyPubkey, request)) {
            log.warn("签名验证失败 - deviceId: {}", deviceId);
            return DeviceRegisterResponse.error(MqttErrorCode.INVALID_SIGNATURE);
        }

        String nonce = request.getNonce();
        if (nonceService.exists(nonce)) {
            return DeviceRegisterResponse.error(MqttErrorCode.REPLAY_ATTACK);
        }

        // ==================== 5. 业务处理 ====================
        MqttCredential credential = credentialGenerator.generate(deviceId);

        try {
            if (isReregister) {
                saveReregister(existing, request, credential);
            } else if (isPreRegistered) {
                activatePreRegistered(existing, request, credential);
            } else {
                saveFirstTimeDevice(request, credential);
            }
        } catch (DuplicateKeyException e) {
            log.warn("并发注册冲突 - deviceId: {}", deviceId);
            return DeviceRegisterResponse.error(MqttErrorCode.DEVICE_ALREADY_REGISTERED);
        }

        registerNonceConsumption(nonce);

        // ==================== 6. 组装响应 ====================
        DeviceRegisterResponse response = DeviceRegisterResponse.success(
                buildMqttConfig(credential),
                buildWillConfig(deviceId, request.getProduct()),
                buildDeviceConfig()
        );

        log.info("设备注册成功 - deviceId: {}, isReregister: {}, clientId: {}, username: {}",
                deviceId, isReregister, credential.getClientId(), credential.getUsername());
        return response;
    }

    // ==================== 私有方法 ====================

    private boolean isValidSignatureMaterial(DeviceRegisterRequest request) {
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

    private boolean verifySignature(String pubkey, DeviceRegisterRequest request) {
        // 👈 此时 request.getDeviceId() 已经是清洗过的无冒号格式
        String signData = request.getDeviceId() + "|" + request.getTimestamp() + "|" + request.getNonce();
        return SignatureVerifierUtils.verify(pubkey, signData, request.getSignature());
    }

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

    private void saveFirstTimeDevice(DeviceRegisterRequest request, MqttCredential credential) {
        // 👈 不需要再 normalize 了，直接用
        String deviceId = request.getDeviceId();
        LocalDateTime now = LocalDateTime.now();
        DeviceInfo device = new DeviceInfo();
        device.setDeviceId(deviceId);
        device.setProduct(request.getProduct());
        device.setFirmware(request.getFirmware());
        device.setPubkey(request.getPubkey());
        device.setOnline(DeviceConstants.DEVICE_STATUS_OFFLINE);
        device.setOfflineReason(null);
        device.setCreateTime(now);
        device.setUpdateTime(now);
        deviceInfoService.save(device);

        mqttAuthService.saveOrUpdateDeviceAuth(
                deviceId, // 👈 直接用
                credential.getUsername(),
                credential.getPasswordHash(),
                credential.getSalt(),
                DeviceConstants.MQTT_STATUS_ENABLE
        );
    }

    private void saveReregister(DeviceInfo existing, DeviceRegisterRequest request, MqttCredential credential) {
        // 👈 不需要再 normalize 了，直接用
        existing.setProduct(request.getProduct());
        existing.setFirmware(request.getFirmware());
        existing.setUpdateTime(LocalDateTime.now());
        deviceInfoService.updateById(existing);

        mqttAuthService.saveOrUpdateDeviceAuth(
                request.getDeviceId(), // 👈 直接用
                credential.getUsername(),
                credential.getPasswordHash(),
                credential.getSalt(),
                DeviceConstants.MQTT_STATUS_ENABLE
        );
    }

    private void activatePreRegistered(DeviceInfo existing, DeviceRegisterRequest request, MqttCredential credential) {
        existing.setPubkey(request.getPubkey());
        existing.setFirmware(request.getFirmware());
        existing.setUpdateTime(LocalDateTime.now());
        deviceInfoService.updateById(existing);

        // 👈 彻底修复：这里原来用的是未清洗的 request.getDeviceId()，现在安全了
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