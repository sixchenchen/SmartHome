"""
模拟设备完整运行脚本（超级重度数据与全维度测试版 - 包含 OTA 闭环）

测试维度覆盖：
1. 主机自带传感器 (host) 与 RS485 从机传感器 (slave) 混合上报。
2. RS485 多通道从机 (address=6, channel=1/2) 同步测试。
3. 舵机 (servo)、开关 (led/mos) 的多路指令下发与状态上报。
4. 携带丰富硬件信息的心跳 (内存、电压、RSSI)。
5. 周期性超标数据触发告警、硬件故障事件触发。
6. 完整模拟 OTA 固件下载、SHA256 校验、刷写重启、上报进度与最终 ACK。
"""

import json
import ssl
import threading
import time
import sys
import random
import hashlib
import os
import urllib.request
import urllib.error
import paho.mqtt.client as mqtt

# ==================== 配置 ====================
MQTT_HOST = "127.0.0.1"
MQTT_PORT = 8883
CLIENT_ID = "device-B4BFE90CDBA1"
USERNAME = "dev_B4BFE90CDBA1"
PASSWORD = "wTZr4bLvSa9Bgy4j"
KEEP_ALIVE = 60

DEVICE_ID = "B4BFE90CDBA1"
PRODUCT = "SmartHome-v1"

# 👈 注意：这里改成了全局变量，OTA 升级后会动态更新
FIRMWARE = "1.0.29"

# ==================== TLS / mTLS 配置 ====================
# 请根据你本机的实际路径修改
CA_CERT     = r"D:\data\mqtt_auth_key\server_key\iot-ca.crt"
CLIENT_CERT = r"D:\data\mqtt_auth_key\server_key\B4BFE90CDBA1.crt"
CLIENT_KEY  = r"D:\data\mqtt_auth_key\server_key\B4BFE90CDBA1.key"

# ==================== Topic 配置 ====================
PRESENCE_TOPIC = f"device/{DEVICE_ID}/presence"
STATE_TOPIC    = f"device/{DEVICE_ID}/state"
SENSOR_TOPIC   = f"device/{DEVICE_ID}/sensor"
HEARTBEAT_TOPIC= f"device/{DEVICE_ID}/heartbeat"
ACK_TOPIC      = f"device/{DEVICE_ID}/ack"
COMMAND_TOPIC  = f"device/{DEVICE_ID}/command"
EVENT_TOPIC    = f"device/{DEVICE_ID}/event"
OTA_PROGRESS_TOPIC = f"device/{DEVICE_ID}/ota_progress"

PRESENCE_QOS = 1
PRESENCE_RETAIN = True
HEARTBEAT_INTERVAL = 30
SENSOR_INTERVAL = 10  # 传感器上报间隔（秒）

# ==================== 遗嘱（LWT） ====================
WILL_PAYLOAD = {
    "device": DEVICE_ID,
    "type": "offline",
    "timestamp": 0,
    "data": {"product": PRODUCT, "reason": "mqtt_lwt"}
}

# ==================== 全局状态 ====================
client = None
stop_flag = threading.Event()

# 1. 完整的外设状态 (3路LED, 8路MOS, 2路舵机, 1路继电器)
current_state = {
    "led_1": 0, "led_2": 0, "led_3": 0,
    "mos_1": 0, "mos_2": 0, "mos_3": 0, "mos_4": 0, 
    "mos_5": 0, "mos_6": 0, "mos_7": 0, "mos_8": 0,
    "servo_1": 90, "servo_2": 90,
    "relay_1": 0
}

# 2. 从机传感器（包含单通道和多通道设备）
slave_sensors = {
    "temp": 25.5, "humi": 55.0, "pm25": 35.0, "co2": 450.0, "lux": 300.0,
    "temp_ch1": 22.0, "temp_ch2": 24.0
}

# ==================== 基础发送方法 ====================
def send_online():
    online_payload = {
        "device": DEVICE_ID,
        "type": "online",
        "timestamp": int(time.time() * 1000),
        "data": {
            "product": PRODUCT,
            "firmware": FIRMWARE,
            "capabilities": {
                "led": 3, "mos": 8, "servo": 2, "relay": 1
            },
            "state": current_state,
            "slaves": [
                {"address": 1, "slave_type": "temperature", "value": slave_sensors["temp"], "unit": "℃"},
                {"address": 2, "slave_type": "humidity", "value": slave_sensors["humi"], "unit": "%"},
                {"address": 3, "slave_type": "pm25", "value": slave_sensors["pm25"], "unit": "μg/m³"},
                {"address": 4, "slave_type": "co2", "value": slave_sensors["co2"], "unit": "ppm"},
                {"address": 5, "slave_type": "illuminance", "value": slave_sensors["lux"], "unit": "lx"},
                {"address": 6, "channel": 1, "slave_type": "temperature", "value": slave_sensors["temp_ch1"], "unit": "℃"},
                {"address": 6, "channel": 2, "slave_type": "temperature", "value": slave_sensors["temp_ch2"], "unit": "℃"}
            ]
        }
    }
    client.publish(PRESENCE_TOPIC, json.dumps(online_payload), qos=PRESENCE_QOS, retain=PRESENCE_RETAIN)
    print(f"[OUT] 已发送上线 (presence) - 固件: {FIRMWARE}, 从机节点: {len(online_payload['data']['slaves'])}")

def send_state_update(target, channel, state_value):
    state_payload = {
        "device": DEVICE_ID,
        "type": "state",
        "timestamp": int(time.time() * 1000),
        "data": {
            "target": target,
            "channel": channel,
            "state": state_value
        }
    }
    client.publish(STATE_TOPIC, json.dumps(state_payload), qos=1)
    print(f"[OUT] 状态已同步上报 - {target}_{channel}: {state_value}")

def send_ack(command_id, target, success=True):
    ack_payload = {
        "device": DEVICE_ID, "commandId": command_id, "type": "ack",
        "success": success, "timestamp": int(time.time() * 1000),
        "data": {"target": target}
    }
    client.publish(ACK_TOPIC, json.dumps(ack_payload), qos=1)
    print(f"[OUT] 控制指令 ACK 已发送 - commandId: {command_id}")

# ==================== OTA 发送辅助 ====================
def send_ota_progress(command_id, state, progress, version=None):
    payload = {
        "device": DEVICE_ID, "type": "ota_progress", "commandId": command_id,
        "timestamp": int(time.time() * 1000),
        "data": {"otaState": state, "progress": progress}
    }
    if version: payload["data"]["version"] = version
    client.publish(OTA_PROGRESS_TOPIC, json.dumps(payload), qos=0)
    print(f"[OTA] → 进度 {state} {progress}%")

def send_ota_final_ack(command_id, version, success=True, error=None):
    ack = {
        "device": DEVICE_ID, "commandId": command_id, "type": "ack",
        "success": success, "timestamp": int(time.time() * 1000),
        "data": {"otaState": "success" if success else "failed", "toVersion": version}
    }
    if error: ack["message"] = error
    client.publish(ACK_TOPIC, json.dumps(ack), qos=1)
    print(f"[OTA] → 最终 ACK 结果: success={success}, version={version}")

# ==================== 传感器与心跳线程 ====================
def start_sensor_report():
    def sensor_loop():
        tick = 0
        while not stop_flag.is_set():
            tick += 1
            slave_sensors["temp"] = round(random.uniform(24.0, 28.0), 1)
            slave_sensors["humi"] = round(random.uniform(50.0, 70.0), 1)
            slave_sensors["pm25"] = round(random.uniform(20.0, 50.0), 1)
            slave_sensors["co2"] = round(random.uniform(400.0, 600.0), 1)
            slave_sensors["lux"] = round(random.uniform(100.0, 800.0), 1)
            slave_sensors["temp_ch1"] = round(random.uniform(20.0, 23.0), 1)
            slave_sensors["temp_ch2"] = round(random.uniform(23.0, 26.0), 1)

            if tick % 5 == 0:
                slave_sensors["temp"] = 35.5
                slave_sensors["pm25"] = 150.0
                print("⚠️ [SIM] 故意制造超标数据，等待后端告警！")

            sensor_payload = {
                "device": DEVICE_ID,
                "type": "sensor_batch",
                "timestamp": int(time.time() * 1000),
                "data": [
                    {"source": "slave", "address": 1, "sensor_key": "temp", "sensor_type": "temperature", "value": slave_sensors["temp"], "unit": "℃"},
                    {"source": "slave", "address": 2, "sensor_key": "humi", "sensor_type": "humidity", "value": slave_sensors["humi"], "unit": "%"},
                    {"source": "slave", "address": 3, "sensor_key": "pm25", "sensor_type": "pm25", "value": slave_sensors["pm25"], "unit": "μg/m³"},
                    {"source": "slave", "address": 4, "sensor_key": "co2", "sensor_type": "co2", "value": slave_sensors["co2"], "unit": "ppm"},
                    {"source": "slave", "address": 5, "sensor_key": "lux", "sensor_type": "illuminance", "value": slave_sensors["lux"], "unit": "lx"},
                    {"source": "slave", "address": 6, "channel": 1, "sensor_key": "temp_ch1", "sensor_type": "temperature", "value": slave_sensors["temp_ch1"], "unit": "℃"},
                    {"source": "slave", "address": 6, "channel": 2, "sensor_key": "temp_ch2", "sensor_type": "temperature", "value": slave_sensors["temp_ch2"], "unit": "℃"},
                    {"source": "host", "sensor_key": "chip_temp", "sensor_type": "temperature", "value": round(random.uniform(45.0, 55.0), 1), "unit": "℃"},
                    {"source": "host", "sensor_key": "system_voltage", "sensor_type": "voltage", "value": round(random.uniform(3.2, 3.4), 2), "unit": "V"},
                    {"source": "host", "sensor_key": "free_heap", "sensor_type": "memory", "value": random.randint(120000, 180000), "unit": "bytes"}
                ]
            }
            try:
                client.publish(SENSOR_TOPIC, json.dumps(sensor_payload), qos=0)
                print(f"[OUT] 上报 10 条传感器数据 (Host + Slave) - 温度:{slave_sensors['temp']}")
            except Exception as e:
                print(f"[ERR] 传感器上报失败: {e}")
            stop_flag.wait(SENSOR_INTERVAL)

    threading.Thread(target=sensor_loop, daemon=True).start()
    print(f"[OK] 传感器上报线程已启动")

def start_heartbeat():
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
                    "rssi": random.randint(-75, -55),
                    "free_heap": random.randint(120000, 180000),
                    "voltage": round(random.uniform(3.2, 3.4), 2),
                    "core_temp": round(random.uniform(45.0, 55.0), 1)
                }
            }
            client.publish(HEARTBEAT_TOPIC, json.dumps(hb_payload), qos=0)
            print(f"[OUT] 心跳 #{seq} - 信号: {hb_payload['data']['rssi']}dBm")
            stop_flag.wait(HEARTBEAT_INTERVAL)
    threading.Thread(target=heartbeat_loop, daemon=True).start()

def start_event_report():
    def event_loop():
        stop_flag.wait(45)
        if stop_flag.is_set(): return
        event_payload = {
            "device": DEVICE_ID,
            "type": "event",
            "timestamp": int(time.time() * 1000),
            "data": {
                "type": "error",
                "code": "ERR_SENSOR_001",
                "message": "地址为2的湿度传感器通信超时"
            }
        }
        client.publish(EVENT_TOPIC, json.dumps(event_payload), qos=1)
        print("[OUT] 🚨 已上报硬件故障事件 (Event)")
    threading.Thread(target=event_loop, daemon=True).start()

# ==================== OTA 核心流程 ====================
def download_firmware(url, expected_sha256, command_id, version, expected_size=None):
    os.makedirs(".", exist_ok=True)
    save_path = os.path.join(".", f"firmware_{version}.bin")
    sha256_ctx = hashlib.sha256()
    downloaded = 0
    total = expected_size if expected_size and expected_size > 0 else 0
    last_reported = -1

    try:
        print(f"[OTA] 开始下载固件: {url}")
        req = urllib.request.Request(url, headers={"User-Agent": "ESP32-OTA/1.0"})
        with urllib.request.urlopen(req, timeout=30) as resp:
            content_length = resp.headers.get("Content-Length")
            if content_length: total = int(content_length)
            with open(save_path, "wb") as f:
                while True:
                    chunk = resp.read(4096)
                    if not chunk: break
                    f.write(chunk)
                    sha256_ctx.update(chunk)
                    downloaded += len(chunk)
                    if total > 0:
                        progress = int(downloaded * 90 / total)
                        if progress >= last_reported + 5:
                            last_reported = progress - (progress % 5)
                            send_ota_progress(command_id, "downloading", progress, version)
        actual_sha256 = sha256_ctx.hexdigest()
        if expected_sha256 and actual_sha256.lower() != expected_sha256.lower():
            return False, save_path, actual_sha256, "SHA256 校验失败"
        return True, save_path, actual_sha256, None
    except Exception as e:
        return False, save_path, None, f"下载异常: {e}"

def ota_flow(command_id, target_version, url, sha256, size=None):
    global FIRMWARE
    try:
        print(f"\n[OTA] ========== 开始 OTA 升级 ==========")
        
        # 1. 发送接收确认
        send_ota_progress(command_id, "accepted", 0, target_version)
        time.sleep(0.5)
        
        # 2. 下载并校验
        ok, save_path, actual_sha256, error = download_firmware(url, sha256, command_id, target_version, size)
        if not ok:
            print(f"[OTA] ❌ 下载或校验失败: {error}")
            send_ota_final_ack(command_id, target_version, success=False, error=error)
            return

        # 3. 模拟刷写
        print(f"[OTA] ========== 校验 + 刷写 ==========")
        time.sleep(1)
        send_ota_progress(command_id, "verifying", 92, target_version)
        time.sleep(1)
        send_ota_progress(command_id, "flashing", 98, target_version)
        time.sleep(1)
        send_ota_progress(command_id, "rebooting", 99, target_version)

        # 4. 模拟重启
        print(f"[OTA] ========== 模拟重启 ==========")
        time.sleep(3)

        # 5. 更新本地版本并重新上线
        FIRMWARE = target_version
        print(f"[OTA] ✅ 升级成功，当前版本: {FIRMWARE}")
        send_online()

        # 6. 发送最终成功 ACK 和 100% 进度
        send_ota_progress(command_id, "success", 100, target_version)
        send_ota_final_ack(command_id, target_version, success=True)
        print(f"[OTA] ========== OTA 流程结束 ==========\n")

    except Exception as e:
        print(f"[OTA] ❌ OTA 过程异常: {e}")
        send_ota_final_ack(command_id, target_version, success=False, error=str(e))

# ==================== MQTT 消息回调 ====================
def on_message(c, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode('utf-8'))
        command_id = payload.get("commandId")
        target = payload.get("target")
        action = payload.get("action")
        channel = payload.get("channel")
        params = payload.get("params", {})

        # 👈 捕获 OTA 指令并启动独立的线程进行升级
        if target == "ota":
            print(f"\n[IN] 收到 OTA 指令，准备开始升级...")
            threading.Thread(
                target=ota_flow, 
                args=(command_id, params.get("version"), params.get("url"), params.get("sha256"), params.get("size")), 
                daemon=True
            ).start()
            return

        if command_id and target:
            print(f"\n[IN] 收到控制指令 - target: {target}, action: {action}, channel: {channel}, params: {params}")
            time.sleep(0.3)
            
            ch = channel if channel is not None else 1
            key = f"{target}_{ch}"
            new_state = None

            if action in ["set", "on", "off", "toggle"] and target in ["led", "mos", "relay"]:
                new_state = 1
                if action == "set":
                    new_state = params.get("state", 1)
                elif action == "off":
                    new_state = 0
                elif action == "toggle":
                    new_state = 0 if current_state.get(key, 0) == 1 else 1

            elif target == "servo" and action == "set":
                new_state = params.get("angle", 90)

            if new_state is not None:
                if key in current_state:
                    current_state[key] = new_state
                send_state_update(target, ch, new_state)
                
            send_ack(command_id, target, success=True)

    except Exception as e:
        print(f"[ERR] 处理指令失败: {e}")

# ==================== 主流程 ====================
def main():
    global client
    sys.stdout.reconfigure(encoding='utf-8')
    
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION1, client_id=CLIENT_ID)
    client.will_set(PRESENCE_TOPIC, json.dumps(WILL_PAYLOAD), qos=1, retain=True)
    client.tls_set(ca_certs=CA_CERT, certfile=CLIENT_CERT, keyfile=CLIENT_KEY, cert_reqs=ssl.CERT_REQUIRED)
    client.tls_insecure_set(True)
    client.username_pw_set(USERNAME, PASSWORD)

    def on_connect(c, userdata, flags, rc):
        if rc == 0:
            print(f"[OK] 已连接 {MQTT_HOST}:{MQTT_PORT}")
            c.subscribe(COMMAND_TOPIC, qos=1)
            send_online()
            start_heartbeat()
            start_sensor_report()
            start_event_report()
        else:
            print(f"[ERR] 连接失败: {rc}")

    client.on_connect = on_connect
    client.on_message = on_message

    client.connect(MQTT_HOST, MQTT_PORT, keepalive=KEEP_ALIVE)
    client.loop_start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        stop_flag.set()
        offline_payload = {
            "device": DEVICE_ID, "type": "offline", "timestamp": int(time.time() * 1000),
            "data": {"reason": "shutdown"}
        }
        client.publish(PRESENCE_TOPIC, json.dumps(offline_payload), qos=1, retain=True)
        time.sleep(0.5)
        client.disconnect()
        print("已退出")

if __name__ == '__main__':
    main()