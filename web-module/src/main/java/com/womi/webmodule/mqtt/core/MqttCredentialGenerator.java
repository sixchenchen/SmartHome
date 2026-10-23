    package com.womi.webmodule.mqtt.core;

    import com.womi.commonmodule.constants.DeviceMqttConstants;
    import com.womi.commonmodule.utils.SaltPasswordUtils;
    import com.womi.businessmodule.model.mqtt.MqttCredential;
    import org.springframework.stereotype.Component;

    import java.util.UUID;

    /**
     * MQTT 凭据生成器
     * 负责生成设备连接正式 Broker 所需的客户端 ID、用户名、密码。
     */
    @Component
    public class MqttCredentialGenerator {

        /**
         * 密码长度
         */
        private static final int PASSWORD_LENGTH = 16;

        /**
         * 生成完整的 MQTT 凭据
         */
        public MqttCredential generate(String deviceId) {
            String clientId = DeviceMqttConstants.MQTT_CLIENT_ID_PREFIX + deviceId;
            String username = deviceId;

            String plainPassword = SaltPasswordUtils.generatePassword(SaltPasswordUtils.DEFAULT_PASSWORD_LENGTH);
            String salt = SaltPasswordUtils.generateSalt();
            String passwordHash = SaltPasswordUtils.hash(plainPassword, salt);

            return new MqttCredential(clientId, username, plainPassword, salt, passwordHash);
        }

        /**
         * 生成用户名：dev_{mac}
         */
        public String generateUsername(String deviceId) {
            return DeviceMqttConstants.MQTT_USERNAME_PREFIX + deviceId;
        }

        /**
         * 生成密码：UUID 去横线取前 16 位
         */
        public String generatePassword(String deviceId) {
            return UUID.randomUUID().toString()
                    .replace("-", "")
                    .substring(0, PASSWORD_LENGTH);
        }
    }