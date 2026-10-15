"""
模拟设备：自动响应服务器下发的控制指令
- 订阅 device/{MAC}/command
- 收到指令 → 立即回 ACK 到 device/{MAC}/ack
"""

import json
import time
import ssl
import paho.mqtt.client as mqtt

# ==================== 配置 ====================
MQTT_HOST = "localhost"
MQTT_PORT = 8883
DEVICE_MAC = "B4BFE90CDBA1"
USERNAME = "dev_B4BFE90CDBA1"
PASSWORD = "4gRF6UUaZtGazQMn"          # 从注册响应里拿

CA_CERT = r"d:\software\emqx-5.3.0-windows-amd64\etc\certs\cert.pem"                   # 你的 EMQX CA 证书

COMMAND_TOPIC = f"device/{DEVICE_MAC}/command"
ACK_TOPIC     = f"device/{DEVICE_MAC}/ack"


# ==================== 回调 ====================
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print(f"[OK] 已连接 EMQX")
        client.subscribe(COMMAND_TOPIC, qos=1)
        print(f"[OK] 已订阅 {COMMAND_TOPIC}")
    else:
        print(f"[ERR] 连接失败，返回码: {rc}")


def on_message(client, userdata, msg):
    """收到服务器下发的指令 → 立即回 ACK"""
    try:
        topic = msg.topic
        payload = json.loads(msg.payload.decode('utf-8'))
        print(f"\n[IN] 收到指令")
        print(f"     Topic: {topic}")
        print(f"     Payload: {json.dumps(payload, ensure_ascii=False)}")

        command_id = payload.get("commandId")
        target = payload.get("target")
        action = payload.get("action")

        if not command_id:
            print("[WARN] 指令缺少 commandId，忽略")
            return

        # ==================== 模拟执行指令 ====================
        # 这里可以加实际的硬件操作代码
        # 比如 GPIO 控制、继电器开关等
        time.sleep(0.1)   # 模拟执行耗时 100ms

        # ==================== 构造 ACK ====================
        ack_payload = {
            "device": DEVICE_MAC,
            "commandId": command_id,
            "type": "ack",
            "success": True,
            "timestamp": int(time.time() * 1000),
            "data": {
                "target": target,
                "action": action,
                "result": payload.get("params", {})
            }
        }

        # ==================== 发送 ACK ====================
        client.publish(ACK_TOPIC, json.dumps(ack_payload), qos=1)
        print(f"[OUT] 已回 ACK")
        print(f"     Topic: {ACK_TOPIC}")
        print(f"     Payload: {json.dumps(ack_payload, ensure_ascii=False)}")

    except Exception as e:
        print(f"[ERR] 处理指令失败: {e}")


def on_disconnect(client, userdata, rc):
    print(f"[WARN] 连接断开，返回码: {rc}")


# ==================== 主流程 ====================
def main():
    client = mqtt.Client(client_id=f"mock-{DEVICE_MAC}")
    client.username_pw_set(USERNAME, PASSWORD)

    # TLS 配置
    client.tls_set(
        ca_certs=CA_CERT,
        cert_reqs=ssl.CERT_REQUIRED,
        tls_version=ssl.PROTOCOL_TLS_CLIENT
    )
    # 如果你的证书 SAN 是 IP，需要跳过主机名校验
    client.tls_insecure_set(True)

    client.on_connect = on_connect
    client.on_message = on_message
    client.on_disconnect = on_disconnect

    print(f"[INFO] 连接 {MQTT_HOST}:{MQTT_PORT} ...")
    client.connect(MQTT_HOST, MQTT_PORT, keepalive=60)

    # 阻塞循环
    client.loop_forever()


if __name__ == '__main__':
    main()