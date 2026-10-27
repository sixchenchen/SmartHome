"""
模拟设备完整生命周期：
1. 用 PROVISION_USER 连 8884
2. 发送注册请求
3. 接收配置响应
4. 断开 8884
5. 用返回的凭据连 8883（设置 LWT 遗嘱）
6. 发送 online
7. 周期性发送 heartbeat
8. Ctrl+C 关闭 → 主动发 offline + 断开 → 或崩溃时触发 LWT
"""

import base64
import json
import ssl
import threading
import time
import uuid
import signal
import sys
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes, serialization
import paho.mqtt.client as mqtt

# ==================== 配置 ====================
MQTT_HOST = "192.168.1.15"
PROVISION_PORT = 8884        # 注册端口
RUNTIME_PORT = 8883          # 业务端口

CA_CERT = r"D:\data\mqtt_auth_key\server_key\iot-ca.crt"           
CLIENT_CERT = r"D:\data\mqtt_auth_key\server_key\B4BFE90CDBA1.crt" 
CLIENT_KEY = r"D:\data\mqtt_auth_key\server_key\B4BFE90CDBA1.key"  

PROVISION_USER = "PROVISION_USER"
PROVISION_PASS = "123456"    # 你的 PROVISION_USER 密码

DEVICE_ID = "B4BFE90CDBA1"
PRODUCT = "SmartHome-v1"
FIRMWARE = "1.0.29"
CHIP = "ESP32"
HARDWARE_VERSION = "V1.0"

HEARTBEAT_INTERVAL = 30      # 心跳间隔（秒）

# ==================== 全局状态 ====================
private_key = None
public_key_pem = None
runtime_client = None
heartbeat_thread = None
stop_flag = threading.Event()
runtime_config = {}          # 保存 8883 的连接信息


# ==================== 1. 生成密钥对 ====================
def generate_keypair():
    global private_key, public_key_pem
    private_key = ec.generate_private_key(ec.SECP256R1())
    public_key = private_key.public_key()
    public_key_pem = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    ).decode('utf-8')
    print("[KEY] 密钥对已生成")


# ==================== 2. 构造注册请求 ====================
def build_register_payload():
    timestamp = int(time.time() * 1000)
    nonce = str(uuid.uuid4())
    sign_data = f"{DEVICE_ID}|{timestamp}|{nonce}"

    signature = private_key.sign(
        sign_data.encode('utf-8'),
        ec.ECDSA(hashes.SHA256())
    )
    signature_b64 = base64.b64encode(signature).decode('utf-8')

    return {
        "device": DEVICE_ID,
        "type": "register",
        "timestamp": timestamp,
        "data": {
            "product": PRODUCT,
            "firmware": FIRMWARE,
            "chip": CHIP,
            "hardware_version": HARDWARE_VERSION,
            "nonce": nonce,
            "pubkey": public_key_pem,
            "signature": signature_b64
        }
    }


# ==================== 3. 注册阶段（8884）====================
def do_register():
    """连接 8884，发注册请求，收配置"""
    print(f"\n========== 阶段 1：注册（8884）==========")
    print(f"[INFO] 用 {PROVISION_USER} 连接 {MQTT_HOST}:{PROVISION_PORT}")

    register_result = {"success": False, "config": None}
    register_done = threading.Event()

    client = mqtt.Client(client_id=f"mock-register-{DEVICE_ID}")

    def on_connect(c, userdata, flags, rc):
        if rc == 0:
            print("[OK] 已连接 8884")
            c.subscribe(f"/provision/device/{DEVICE_ID}/config", qos=1)
            print(f"[OK] 已订阅 /provision/device/{DEVICE_ID}/config")
            # 发注册请求
            payload = build_register_payload()
            print(f"[OUT] 发送注册请求")
            print(f"      {json.dumps(payload, ensure_ascii=False)}")
            c.publish(f"/provision/device/{DEVICE_ID}/register",
                      json.dumps(payload), qos=1)
        else:
            print(f"[ERR] 连接 8884 失败，返回码: {rc}")
            register_done.set()

    def on_message(c, userdata, msg):
        try:
            payload = json.loads(msg.payload.decode('utf-8'))
            print(f"\n[IN] 收到配置")
            print(f"     Topic: {msg.topic}")
            print(f"     Payload: {json.dumps(payload, ensure_ascii=False, indent=2)}")

            if payload.get("success"):
                register_result["success"] = True
                register_result["config"] = payload
                print("[OK] 注册成功")
            else:
                print(f"[ERR] 注册失败: {payload.get('message')}")
        except Exception as e:
            print(f"[ERR] 解析配置失败: {e}")
        finally:
            register_done.set()

    def on_disconnect(c, userdata, rc):
        print(f"[WARN] 8884 连接断开，返回码: {rc}")

    client.username_pw_set(PROVISION_USER, PROVISION_PASS)
    client.tls_set(ca_certs=CA_CERT, certfile=CLIENT_CERT, keyfile=CLIENT_KEY,cert_reqs=ssl.CERT_REQUIRED)
    client.tls_insecure_set(True)
    client.on_connect = on_connect
    client.on_message = on_message
    client.on_disconnect = on_disconnect

    client.connect(MQTT_HOST, PROVISION_PORT, keepalive=60)
    client.loop_start()

    # 等待注册完成（最多 15 秒）
    if not register_done.wait(timeout=15):
        print("[ERR] 注册超时")
        client.loop_stop()
        client.disconnect()
        return None

    client.loop_stop()
    client.disconnect()
    print("[INFO] 已断开 8884")

    return register_result["config"] if register_result["success"] else None


# ==================== 4. 业务阶段（8883）====================
def start_runtime(config):
    """用注册返回的凭据连 8883，设置 LWT，发 online，启动心跳"""
    global runtime_client

    mqtt_cfg = config["mqtt"]
    host = mqtt_cfg["host"]
    port = mqtt_cfg["port"]
    username = mqtt_cfg["username"]
    password = mqtt_cfg["password"]
    client_id = mqtt_cfg["clientId"]
    keep_alive = mqtt_cfg.get("keepAlive", 60)

    will_cfg = config.get("will", {})

    print(f"\n========== 阶段 2：业务（{port}）==========")
    print(f"[INFO] 连接 {host}:{port}")
    print(f"       ClientId: {client_id}")
    print(f"       Username: {username}")

    client = mqtt.Client(client_id=client_id)

    # ★ 设置 LWT（遗嘱消息）
    if will_cfg:
        will_topic = will_cfg.get("topic")
        will_payload = json.dumps(will_cfg.get("payload", {}))
        will_qos = will_cfg.get("qos", 1)
        will_retain = will_cfg.get("retain", False)
        client.will_set(will_topic, will_payload, qos=will_qos, retain=will_retain)
        print(f"[LWT] 遗嘱已设置: {will_topic}")

    def on_connect(c, userdata, flags, rc):
        if rc == 0:
            print(f"[OK] 已连接 {port}")
            # 发 online
            send_online(c)
            # 启动心跳线程
            start_heartbeat(c)
        else:
            print(f"[ERR] 连接 {port} 失败，返回码: {rc}")

    def on_disconnect(c, userdata, rc):
        print(f"[WARN] 8883 连接断开，返回码: {rc}")

    def on_message(c, userdata, msg):
        # 业务阶段接收指令
        print(f"\n[IN] 收到消息 - Topic: {msg.topic}")
        try:
            payload = json.loads(msg.payload.decode('utf-8'))
            print(f"     Payload: {json.dumps(payload, ensure_ascii=False)}")
            # 这里可以加 ACK 回复
        except Exception:
            print(f"     Payload(raw): {msg.payload.decode('utf-8', errors='ignore')}")

    client.username_pw_set(username, password)
    client.tls_set(ca_certs=CA_CERT, certfile=CLIENT_CERT, keyfile=CLIENT_KEY,cert_reqs=ssl.CERT_REQUIRED)
    client.tls_insecure_set(True)
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.on_message = on_message

    client.connect(host, port, keepalive=keep_alive)
    client.loop_start()

    runtime_client = client
    return client


# ==================== 5. 发送上线消息 ====================
def send_online(client):
    online_payload = {
        "device": DEVICE_ID,
        "type": "online",
        "timestamp": int(time.time() * 1000),
        "data": {
            "product": PRODUCT,
            "firmware": FIRMWARE,
            "capabilities": {
                "mos": 8,
                "led": 3,
                "servo": 2
            }
        }
    }
    topic = f"device/{DEVICE_ID}/online"
    client.publish(topic, json.dumps(online_payload), qos=1)
    print(f"[OUT] 已发送上线 - Topic: {topic}")


# ==================== 6. 心跳线程 ====================
def start_heartbeat(client):
    global heartbeat_thread

    def heartbeat_loop():
        seq = 0
        while not stop_flag.is_set():
            seq += 1
            hb_payload = {
                "device": DEVICE_ID,
                "type": "heartbeat",
                "timestamp": int(time.time() * 1000),
                "data": {
                    "product": PRODUCT,
                    "uptime": seq * HEARTBEAT_INTERVAL,
                    "rssi": -65
                }
            }
            topic = f"device/{DEVICE_ID}/heartbeat"
            try:
                client.publish(topic, json.dumps(hb_payload), qos=0)
                print(f"[OUT] 心跳 #{seq} - uptime: {seq * HEARTBEAT_INTERVAL}s")
            except Exception as e:
                print(f"[ERR] 心跳发送失败: {e}")

            # 等待下一次心跳（可被 stop_flag 提前唤醒）
            stop_flag.wait(HEARTBEAT_INTERVAL)

    heartbeat_thread = threading.Thread(target=heartbeat_loop, daemon=True)
    heartbeat_thread.start()
    print(f"[OK] 心跳线程已启动（每 {HEARTBEAT_INTERVAL} 秒）")


# ==================== 7. 优雅退出 ====================
def graceful_shutdown(signum=None, frame=None):
    """Ctrl+C 时优雅退出：发 offline，断开连接"""
    global runtime_client

    print("\n\n========== 收到退出信号 ==========")
    stop_flag.set()

    if runtime_client:
        # 发主动离线消息
        offline_payload = {
            "device": DEVICE_ID,
            "type": "offline",
            "timestamp": int(time.time() * 1000),
            "data": {
                "product": PRODUCT,
                "reason": "shutdown"
            }
        }
        topic = f"device/{DEVICE_ID}/offline"
        try:
            runtime_client.publish(topic, json.dumps(offline_payload), qos=1)
            print(f"[OUT] 已发送离线 - Topic: {topic}")
            time.sleep(0.5)  # 等消息发出去
        except Exception as e:
            print(f"[ERR] 发送离线失败: {e}")

        # 断开连接
        try:
            runtime_client.disconnect()
            print("[INFO] 已断开 8883")
        except Exception:
            pass

    time.sleep(0.5)
    print("[INFO] 程序退出")
    sys.exit(0)


# ==================== 8. 主流程 ====================
def main():
    # 注册退出信号处理
    signal.signal(signal.SIGINT, graceful_shutdown)
    signal.signal(signal.SIGTERM, graceful_shutdown)

    print("=" * 60)
    print(f"模拟设备: {DEVICE_ID}")
    print("=" * 60)

    # ① 生成密钥对
    generate_keypair()

    # ② 注册
    config = do_register()
    if not config:
        print("[FATAL] 注册失败，退出")
        sys.exit(1)

    # ③ 连 8883 + 上线 + 心跳
    start_runtime(config)

    # ④ 保持运行
    print("\n[INFO] 设备运行中，按 Ctrl+C 退出...\n")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        graceful_shutdown()


if __name__ == '__main__':
    main()