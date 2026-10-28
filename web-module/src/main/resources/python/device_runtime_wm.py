"""
模拟设备完整运行脚本（超级重度数据与全维度测试版）

测试维度覆盖：
1. 主机自带传感器 (host) 与 RS485 从机传感器 (slave) 混合上报。
2. RS485 多通道从机 (address=6, channel=1/2) 同步测试。
3. 舵机 (servo)、开关 (led/mos) 的多路指令下发与状态上报。
4. 携带丰富硬件信息的心跳 (内存、电压、RSSI)。
5. 周期性超标数据触发告警、硬件故障事件触发。
"""

import json
import ssl
import threading
import time
import sys
import random
import paho.mqtt.client as mqtt

# ==================== 配置 ====================
MQTT_HOST = "127.0.0.1"
MQTT_PORT = 8883
CLIENT_ID = "device-B4BFE90CDBA1"
USERNAME = "dev_B4BFE90CDBA1"
PASSWORD = "dSXAXrFBZweS9Fpa" 
KEEP_ALIVE = 60

DEVICE_ID = "B4BFE90CDBA1"
PRODUCT = "SmartHome-v1"
FIRMWARE = "1.0.29"

# ==================== TLS / mTLS 配置 ====================
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
    "temp_ch1": 22.0, "temp_ch2": 24.0 # 地址6的两个通道
}

# ==================== 发送上线消息（presence）====================
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
                # 单通道从机
                {"address": 1, "slave_type": "temperature", "value": slave_sensors["temp"], "unit": "℃"},
                {"address": 2, "slave_type": "humidity", "value": slave_sensors["humi"], "unit": "%"},
                {"address": 3, "slave_type": "pm25", "value": slave_sensors["pm25"], "unit": "μg/m³"},
                {"address": 4, "slave_type": "co2", "value": slave_sensors["co2"], "unit": "ppm"},
                {"address": 5, "slave_type": "illuminance", "value": slave_sensors["lux"], "unit": "lx"},
                # 👈 多通道从机测试 (地址6，通道1和2)
                {"address": 6, "channel": 1, "slave_type": "temperature", "value": slave_sensors["temp_ch1"], "unit": "℃"},
                {"address": 6, "channel": 2, "slave_type": "temperature", "value": slave_sensors["temp_ch2"], "unit": "℃"}
            ]
        }
    }
    client.publish(PRESENCE_TOPIC, json.dumps(online_payload), qos=PRESENCE_QOS, retain=PRESENCE_RETAIN)
    print(f"[OUT] 已发送上线 (presence) - 携带 {len(online_payload['data']['slaves'])} 个从机节点")

# ==================== 发送状态上报（state） ====================
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

# ==================== 传感器定时上报（混合 Host 与 Slave） ====================
def start_sensor_report():
    def sensor_loop():
        tick = 0
        while not stop_flag.is_set():
            tick += 1
            
            # 模拟常规波动
            slave_sensors["temp"] = round(random.uniform(24.0, 28.0), 1)
            slave_sensors["humi"] = round(random.uniform(50.0, 70.0), 1)
            slave_sensors["pm25"] = round(random.uniform(20.0, 50.0), 1)
            slave_sensors["co2"] = round(random.uniform(400.0, 600.0), 1)
            slave_sensors["lux"] = round(random.uniform(100.0, 800.0), 1)
            slave_sensors["temp_ch1"] = round(random.uniform(20.0, 23.0), 1)
            slave_sensors["temp_ch2"] = round(random.uniform(23.0, 26.0), 1)

            # 每 5 次上报，故意制造一次数据超标
            if tick % 5 == 0:
                slave_sensors["temp"] = 35.5  # 超标
                slave_sensors["pm25"] = 150.0 # 超标
                print("⚠️ [SIM] 故意制造超标数据，等待后端告警！")

            sensor_payload = {
                "device": DEVICE_ID,
                "type": "sensor_batch",
                "timestamp": int(time.time() * 1000),
                "data": [
                    # ============ 从机 (slave) 数据 ============
                    {"source": "slave", "address": 1, "sensor_key": "temp", "sensor_type": "temperature", "value": slave_sensors["temp"], "unit": "℃"},
                    {"source": "slave", "address": 2, "sensor_key": "humi", "sensor_type": "humidity", "value": slave_sensors["humi"], "unit": "%"},
                    {"source": "slave", "address": 3, "sensor_key": "pm25", "sensor_type": "pm25", "value": slave_sensors["pm25"], "unit": "μg/m³"},
                    {"source": "slave", "address": 4, "sensor_key": "co2", "sensor_type": "co2", "value": slave_sensors["co2"], "unit": "ppm"},
                    {"source": "slave", "address": 5, "sensor_key": "lux", "sensor_type": "illuminance", "value": slave_sensors["lux"], "unit": "lx"},
                    # 多通道从机
                    {"source": "slave", "address": 6, "channel": 1, "sensor_key": "temp_ch1", "sensor_type": "temperature", "value": slave_sensors["temp_ch1"], "unit": "℃"},
                    {"source": "slave", "address": 6, "channel": 2, "sensor_key": "temp_ch2", "sensor_type": "temperature", "value": slave_sensors["temp_ch2"], "unit": "℃"},
                    
                    # ============ 主机 (host) 自带传感器数据 ============
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

# ==================== 心跳线程（带丰富硬件指标） ====================
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
                    # 👈 增加丰富的硬件参数测试 last_payload 字段
                    "free_heap": random.randint(120000, 180000),
                    "voltage": round(random.uniform(3.2, 3.4), 2),
                    "core_temp": round(random.uniform(45.0, 55.0), 1)
                }
            }
            client.publish(HEARTBEAT_TOPIC, json.dumps(hb_payload), qos=0)
            print(f"[OUT] 心跳 #{seq} - 信号: {hb_payload['data']['rssi']}dBm")
            stop_flag.wait(HEARTBEAT_INTERVAL)
    threading.Thread(target=heartbeat_loop, daemon=True).start()

# ==================== 设备事件上报 ====================
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

# ==================== 指令处理 ====================
def send_ack(command_id, target, success=True):
    ack_payload = {
        "device": DEVICE_ID, "commandId": command_id, "type": "ack",
        "success": success, "timestamp": int(time.time() * 1000),
        "data": {"target": target}
    }
    client.publish(ACK_TOPIC, json.dumps(ack_payload), qos=1)

def on_message(c, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode('utf-8'))
        command_id = payload.get("commandId")
        target = payload.get("target")
        action = payload.get("action")
        channel = payload.get("channel")
        params = payload.get("params", {})

        if target == "ota":
            print(f"[IN] 收到 OTA 指令")
            return

        if command_id and target:
            print(f"\n[IN] 收到控制指令 - target: {target}, action: {action}, channel: {channel}, params: {params}")
            time.sleep(0.3)
            
            ch = channel if channel is not None else 1
            key = f"{target}_{ch}"
            new_state = None

            # 1. 处理普通开关指令 (LED/MOS/Relay)
            if action in ["set", "on", "off", "toggle"] and target in ["led", "mos", "relay"]:
                new_state = 1
                if action == "set":
                    new_state = params.get("state", 1)
                elif action == "off":
                    new_state = 0
                elif action == "toggle":
                    new_state = 0 if current_state.get(key, 0) == 1 else 1

            # 2. 👈 处理舵机指令 (Servo)
            elif target == "servo" and action == "set":
                # 舵机接收 angle 参数，范围 0-180
                new_state = params.get("angle", 90)

            # 更新状态并上报
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