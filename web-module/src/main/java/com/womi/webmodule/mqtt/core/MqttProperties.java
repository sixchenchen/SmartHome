package com.womi.webmodule.mqtt.core;

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
        private String host = "192.168.124.6";
        private String caCert = "certs/cert.pem";
        private int port;
        private String clientId;
        private String username;
        private String password;
        private List<String> topics = new ArrayList<>();
        private List<Integer> qos = new ArrayList<>();
        private int defaultQos = 1;
        private int keepAliveInterval = 60;
        private int connectionTimeout = 30;
        private boolean automaticReconnect = true;
        private boolean cleanSession = true;
        private int maxInflight = 10;
    }
}