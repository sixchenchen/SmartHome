package com.womi.webmodule.mqtt.core;

import com.womi.commonmodule.constants.MqttConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
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

import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManagerFactory;
import java.io.InputStream;
import java.security.KeyStore;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;

/**
 * MQTT 配置：运行时（1883）+ 注册（1884）双通道
 */
@Slf4j
@Configuration
@RequiredArgsConstructor
@EnableConfigurationProperties(MqttProperties.class)
public class MqttConfig {

    private final MqttProperties mqttProperties;

    // ==================== 通用：连接工厂 ====================
    private MqttPahoClientFactory createClientFactory(MqttProperties.Broker broker, String label) {
        DefaultMqttPahoClientFactory factory = new DefaultMqttPahoClientFactory();
        MqttConnectOptions options = new MqttConnectOptions();

        String serverURI = String.format("ssl://%s:%d", broker.getHost(), broker.getPort());
        options.setServerURIs(new String[]{serverURI});

        if (broker.getUsername() != null) {
            options.setUserName(broker.getUsername());
        }
        if (broker.getPassword() != null) {
            options.setPassword(broker.getPassword().toCharArray());
        }

        options.setKeepAliveInterval(broker.getKeepAliveInterval());
        options.setConnectionTimeout(broker.getConnectionTimeout());
        options.setAutomaticReconnect(broker.isAutomaticReconnect());
        options.setCleanSession(broker.isCleanSession());
        options.setMaxInflight(broker.getMaxInflight());
        try {
            options.setSocketFactory(buildSslSocketFactory(broker.getCaCert()));
        } catch (Exception e) {
            throw new IllegalStateException("[" + label + "] 初始化 TLS SocketFactory 失败", e);
        }
        log.info("[{}] MQTT 客户端工厂初始化完成, Broker: {}", label, serverURI);
        factory.setConnectionOptions(options);
        return factory;
    }

    // ==================== 运行时 Broker（1883） ====================
    @Bean("runtimeClientFactory")
    public MqttPahoClientFactory runtimeClientFactory() {
        return createClientFactory(mqttProperties.getRuntime(), "RUNTIME");
    }

    @Bean("runtimeInputChannel")
    public MessageChannel runtimeInputChannel() {
        return new DirectChannel();
    }

    @Bean("runtimeInbound")
    public MessageProducer runtimeInbound() {
        MqttProperties.Broker broker = mqttProperties.getRuntime();
        String[] topics = broker.getTopics().toArray(new String[0]);
        int[] qos = broker.getQos().stream().mapToInt(Integer::intValue).toArray();

        MqttPahoMessageDrivenChannelAdapter adapter =
                new MqttPahoMessageDrivenChannelAdapter(
                        broker.getClientId() + MqttConstants.RUNTIME_INBOUND_SUFFIX,
                        runtimeClientFactory(),
                        topics
                );

        adapter.setConverter(new DefaultPahoMessageConverter());
        adapter.setQos(qos);
        adapter.setOutputChannel(runtimeInputChannel());

        log.info("[RUNTIME] 订阅主题: {}", broker.getTopics());
        return adapter;
    }

    @Bean("runtimeOutputChannel")
    public MessageChannel runtimeOutputChannel() {
        return new DirectChannel();
    }

    @Bean("runtimeOutbound")
    @ServiceActivator(inputChannel = "runtimeOutputChannel")
    public MessageHandler runtimeOutbound() {
        MqttProperties.Broker broker = mqttProperties.getRuntime();

        MqttPahoMessageHandler handler =
                new MqttPahoMessageHandler(
                        broker.getClientId() + MqttConstants.RUNTIME_OUTBOUND_SUFFIX,
                        runtimeClientFactory()
                );
        handler.setAsync(true);
        handler.setDefaultQos(broker.getDefaultQos());
        handler.setDefaultRetained(false);
        return handler;
    }

    // ==================== 注册 Broker（1884） ====================
    @Bean("provisionClientFactory")
    public MqttPahoClientFactory provisionClientFactory() {
        return createClientFactory(mqttProperties.getProvision(), "PROVISION");
    }

    @Bean("provisionInputChannel")
    public MessageChannel provisionInputChannel() {
        return new DirectChannel();
    }

    @Bean("provisionInbound")
    public MessageProducer provisionInbound() {
        MqttProperties.Broker broker = mqttProperties.getProvision();
        String[] topics = broker.getTopics().toArray(new String[0]);
        int[] qos = broker.getQos().stream().mapToInt(Integer::intValue).toArray();

        MqttPahoMessageDrivenChannelAdapter adapter =
                new MqttPahoMessageDrivenChannelAdapter(
                        broker.getClientId() + MqttConstants.PROVISION_INBOUND_SUFFIX,
                        provisionClientFactory(),
                        topics
                );

        adapter.setConverter(new DefaultPahoMessageConverter());
        adapter.setQos(qos);
        adapter.setOutputChannel(provisionInputChannel());

        log.info("[PROVISION] 订阅主题: {}", broker.getTopics());
        return adapter;
    }

    @Bean("provisionOutputChannel")
    public MessageChannel provisionOutputChannel() {
        return new DirectChannel();
    }

    @Bean("provisionOutbound")
    @ServiceActivator(inputChannel = "provisionOutputChannel")
    public MessageHandler provisionOutbound() {
        MqttProperties.Broker broker = mqttProperties.getProvision();

        MqttPahoMessageHandler handler =
                new MqttPahoMessageHandler(
                        broker.getClientId() + MqttConstants.PROVISION_OUTBOUND_SUFFIX,
                        provisionClientFactory()
                );
        handler.setAsync(true);
        handler.setDefaultQos(broker.getDefaultQos());
        handler.setDefaultRetained(false);
        return handler;
    }

    /**
     * 从 classpath 加载 CA 证书，构建 SSLSocketFactory
     */
    private SSLSocketFactory buildSslSocketFactory(String caCertPath) throws Exception {
        CertificateFactory cf = CertificateFactory.getInstance("X.509");
        try (InputStream is = new ClassPathResource(caCertPath).getInputStream()) {
            Certificate ca = cf.generateCertificate(is);
            KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
            ks.load(null, null);
            ks.setCertificateEntry("ca", ca);

            TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
            tmf.init(ks);

            SSLContext ctx = SSLContext.getInstance("TLS");
            ctx.init(null, tmf.getTrustManagers(), null);
            return ctx.getSocketFactory();
        }
    }
}