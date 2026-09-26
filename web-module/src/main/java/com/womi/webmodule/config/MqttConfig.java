package com.womi.webmodule.config;

import com.womi.webmodule.mqtt.core.MqttMessageRouter;
import com.womi.webmodule.mqtt.core.MqttProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.core.MessageProducer;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.core.MqttPahoClientFactory;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.integration.mqtt.outbound.MqttPahoMessageHandler;
import org.springframework.integration.mqtt.support.DefaultPahoMessageConverter;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;

@Slf4j
@Configuration
@RequiredArgsConstructor
@EnableConfigurationProperties(MqttProperties.class)
public class MqttConfig {

    private final MqttProperties mqttProperties;
    private final MqttMessageRouter messageRouter;

    /**
     * MQTT 客户端工厂
     */
    @Bean
    public MqttPahoClientFactory mqttClientFactory() {
        DefaultMqttPahoClientFactory factory = new DefaultMqttPahoClientFactory();
        MqttConnectOptions options = new MqttConnectOptions();

        // 连接配置
        String serverURI = String.format("tcp://%s:%d",
                mqttProperties.getHost(), mqttProperties.getPort());
        options.setServerURIs(new String[]{serverURI});

        // 认证配置
        if (mqttProperties.getUsername() != null) {
            options.setUserName(mqttProperties.getUsername());
        }
        if (mqttProperties.getPassword() != null) {
            options.setPassword(mqttProperties.getPassword().toCharArray());
        }

        // 连接参数
        options.setKeepAliveInterval(mqttProperties.getKeepAliveInterval());
        options.setConnectionTimeout(mqttProperties.getConnectionTimeout());
        options.setAutomaticReconnect(mqttProperties.isAutomaticReconnect());
        options.setCleanSession(mqttProperties.isCleanSession());
        options.setMaxInflight(mqttProperties.getMaxInflight());

        log.info("MQTT 客户端初始化完成, Broker: {}", serverURI);
        factory.setConnectionOptions(options);
        return factory;
    }

    /**
     * 入站消息通道
     */
    @Bean
    public MessageChannel mqttInputChannel() {
        return new DirectChannel();
    }

    /**
     * MQTT 入站适配器（订阅消息）
     */
    @Bean
    public MessageProducer mqttInbound() {
        String[] topics = mqttProperties.getTopics().toArray(new String[0]);
        int[] qos = mqttProperties.getQos().stream().mapToInt(Integer::intValue).toArray();

        MqttPahoMessageDrivenChannelAdapter adapter =
                new MqttPahoMessageDrivenChannelAdapter(
                        mqttProperties.getClientId() + "-inbound",
                        mqttClientFactory(),
                        topics
                );

        adapter.setConverter(new DefaultPahoMessageConverter());
        adapter.setQos(qos);
        adapter.setOutputChannel(mqttInputChannel());

        log.info("MQTT 订阅主题: {}", mqttProperties.getTopics());
        return adapter;
    }

    /**
     * 消息处理器（路由到具体处理器）
     */
    @Bean
    @ServiceActivator(inputChannel = "mqttInputChannel")
    public MessageHandler mqttInputChannelHandler() {
        return message -> {
            String payload = message.getPayload().toString();
            String topic = (String) message.getHeaders().get("mqtt_receivedTopic");
            Integer qos = (Integer) message.getHeaders().get("mqtt_receivedQos");

            log.debug("收到 MQTT 消息 - Topic: {}, QoS: {}", topic, qos);
            messageRouter.route(topic, payload, qos);
        };
    }

    /**
     * MQTT 出站通道（发送消息）
     */
    @Bean
    public MessageChannel mqttOutputChannel() {
        return new DirectChannel();
    }

    /**
     * MQTT 出站处理器（发送消息）
     */
    @Bean
    @ServiceActivator(inputChannel = "mqttOutputChannel")
    public MessageHandler mqttOutbound() {
        MqttPahoMessageHandler handler =
                new MqttPahoMessageHandler(
                        mqttProperties.getClientId() + "-outbound",
                        mqttClientFactory()
                );
        handler.setAsync(true);
        handler.setDefaultQos(mqttProperties.getDefaultQos());
        handler.setDefaultRetained(false);
        return handler;
    }
}