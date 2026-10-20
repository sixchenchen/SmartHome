package com.womi.webmodule;


import com.womi.commonmodule.utils.SaltPasswordUtils;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;
import java.io.InputStream;
import java.security.KeyStore;
import java.security.SecureRandom;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;

import static org.assertj.core.api.Assertions.assertThat;

@Slf4j
@SpringBootTest
class WebModuleApplicationTests {

    // 注意：连接时使用 ssl:// 协议头
    String broker = "ssl://127.0.0.1:8883";
    String clientId = "java-server-test-001";
    // 你的证书密码（前面打包 p12 时设置的密码）
    String password = "123456";

    @Test
    public void testHash() {
        String salt = "667f13ac5e1c4dbdddb7f4c288bb0856";
        String password = "123456";

        String hash = SaltPasswordUtils.hash(password, salt);
        System.out.println("计算哈希: " + hash);
        System.out.println("数据库值: fae340eae69a2dfad416154a5d47474ce546d2c2ba9bc57fa8c0b833a6886aff");
        System.out.println("是否一致: " + hash.equals("fae340eae69a2dfad416154a5d47474ce546d2c2ba9bc57fa8c0b833a6886aff"));
    }

    @Test
    public void testMqttTls() {
        try {
            // ==================== 1. 加载客户端身份（KeyManager） ====================
            KeyStore keyStore = KeyStore.getInstance("PKCS12");
            InputStream ksStream = WebModuleApplicationTests.class.getClassLoader().getResourceAsStream("certs/java-client.p12");
            if (ksStream == null) throw new RuntimeException("找不到 java-client.p12");
            keyStore.load(ksStream, password.toCharArray());

            KeyManagerFactory kmf = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
            kmf.init(keyStore, password.toCharArray());

            // ==================== 2. 加载信任的根证书（TrustManager） ====================
            // 单独读取 iot-ca.crt 作为信任锚点
            CertificateFactory cf = CertificateFactory.getInstance("X.509");
            InputStream caStream = WebModuleApplicationTests.class.getClassLoader().getResourceAsStream("certs/iot-ca.crt");
            if (caStream == null) throw new RuntimeException("找不到 iot-ca.crt");
            Certificate caCert = cf.generateCertificate(caStream);

            // 构建包含 CA 根证书的信任库
            KeyStore trustStore = KeyStore.getInstance(KeyStore.getDefaultType());
            trustStore.load(null, null); // 初始化一个空的
            trustStore.setCertificateEntry("iot-ca", caCert);

            TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
            tmf.init(trustStore);

            // ==================== 3. 构建 SSLContext ====================
            SSLContext sslContext = SSLContext.getInstance("TLSv1.2");
            sslContext.init(kmf.getKeyManagers(), tmf.getTrustManagers(), new SecureRandom());

            // ==================== 4. 配置 MQTT 连接 ====================
            MqttClient client = new MqttClient(broker, clientId, new MemoryPersistence());
            MqttConnectOptions options = new MqttConnectOptions();
            options.setCleanSession(true);
            options.setSocketFactory(sslContext.getSocketFactory());

            // 如果还报 Hostname 不匹配，再放开这一行
            // options.setHttpsHostnameVerificationEnabled(false);

            // 回调
            client.setCallback(new MqttCallbackExtended() {
                @Override
                public void connectComplete(boolean reconnect, String serverURI) {
                    System.out.println("✅ mTLS 连接成功！已连接到: " + serverURI);
                    try {
                        client.subscribe("/provision/device/+/register", 1);
                        System.out.println("👀 已订阅注册主题，等待设备发送消息...");
                    } catch (MqttException e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void connectionLost(Throwable cause) {
                    System.err.println("❌ 连接断开！原因: " + (cause != null ? cause.getMessage() : "未知"));
                }

                @Override
                public void messageArrived(String topic, MqttMessage message) {
                    System.out.println("\n📩 收到设备注册消息！");
                    System.out.println("Topic: " + topic);
                    System.out.println("Payload: " + new String(message.getPayload()));
                }

                @Override
                public void deliveryComplete(IMqttDeliveryToken token) {}
            });

            System.out.println("正在尝试通过 mTLS 连接 EMQX...");
            client.connect(options);

        } catch (Exception e) {
            System.err.println("💥 连接失败！");
            e.printStackTrace();
        }
    }
}
