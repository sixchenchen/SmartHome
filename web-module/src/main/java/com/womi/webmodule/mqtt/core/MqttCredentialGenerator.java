package com.womi.webmodule.mqtt.core;

import com.womi.commonmodule.constants.MqttConstants;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * MQTT 凭据生成器
 *
 * <p>负责生成设备连接正式 Broker 所需的客户端 ID、用户名、密码。
 */
@Component
public class MqttCredentialGenerator {

    /** 密码长度 */
    private static final int PASSWORD_LENGTH = 16;

    /**
     * 生成客户端 ID
     * <p>规则：device-{mac}
     */
    public String generateClientId(String deviceId) {
        return MqttConstants.MQTT_CLIENT_ID_PREFIX + deviceId;
    }

    /**
     * 生成用户名
     * <p>规则：dev_{mac}
     */
    public String generateUsername(String deviceId) {
        return MqttConstants.MQTT_USERNAME_PREFIX + deviceId;
    }

    /**
     * 生成密码
     * <p>简化实现：UUID 去横线取前 16 位
     * <p>生产环境建议用 HMAC + 密钥
     */
    public String generatePassword(String deviceId) {
        return UUID.randomUUID().toString()
                .replace("-", "")
                .substring(0, PASSWORD_LENGTH);
    }
}