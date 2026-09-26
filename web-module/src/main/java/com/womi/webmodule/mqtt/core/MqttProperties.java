package com.womi.webmodule.mqtt.core;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.ArrayList;
import java.util.List;

@Data
@ConfigurationProperties(prefix = "mqtt")
public class MqttProperties {

    /** Broker 主机地址 */
    private String host = "192.168.124.6";

    /** Broker 端口 */
    private int port = 1883;

    /** 客户端ID */
    private String clientId = "spring-boot-server";

    /** 用户名 */
    private String username = "MQTT1";

    /** 密码 */
    private String password = "123456";

    /** 订阅主题列表 */
    private List<String> topics = new ArrayList<>();

    /** 订阅QoS列表 */
    private List<Integer> qos = new ArrayList<>();

    /** 默认QoS */
    private int defaultQos = 1;

    /** 保持连接间隔（秒） */
    private int keepAliveInterval = 60;

    /** 连接超时（秒） */
    private int connectionTimeout = 30;

    /** 自动重连 */
    private boolean automaticReconnect = true;

    /** 清理会话 */
    private boolean cleanSession = true;

    /** 最大并发消息数 */
    private int maxInflight = 10;
}