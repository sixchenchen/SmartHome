package com.womi.commonmodule.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.ArrayList;
import java.util.List;

@Data
@ConfigurationProperties(prefix = "mqtt")
public class MqttProperties {

    /** 运行时 Broker（8883） */
    private Broker runtime = new Broker();

    /** 注册 Broker（8884） */
    private Broker provision = new Broker();


    @Data
    public static class Broker {

        // ==================== 环境相关：不给默认值 ====================
        /** 必填：yml 里必须配置 */
        private String host;
        /** 必填：yml 里必须配置 */
        private Integer port;
        /** 必填：yml 里必须配置 */
        private String username;
        /** 可不用配置 */
        private String password;
        /** 必填：CA 证书路径 */
        private String caCert;
        /** 必填：Java 客户端证书 .p12 路径（用于向 EMQX 证明自己） */
        private String clientCert;
        /** 必填：.p12 证书的密码 */
        private String clientCertPassword;
        private String clientId;
        private List<String> topics = new ArrayList<>();
        private List<Integer> qos = new ArrayList<>();
        // ==================== 通用参数：代码默认值 ====================
        /** 默认 QoS = 1 */
        private int defaultQos = 1;
        /** 默认 KeepAlive = 60 秒 */
        private int keepAliveInterval = 60;
        /** 默认连接超时 = 30 秒 */
        private int connectionTimeout = 30;
        /** 默认自动重连 = true */
        private boolean automaticReconnect = true;
        /** 默认 CleanSession = true */
        private boolean cleanSession = true;
        /** 默认 MaxInflight = 10 */
        private int maxInflight = 10;
    }
}