"""
模拟设备完整运行脚本（跳过注册阶段）

功能：
1. 直接用凭据连 8883（mTLS 双向认证）
2. 发送 online（presence topic，retain=true）
3. 周期性发送 heartbeat
4. 接收普通指令 → 回 ACK
5. 接收 OTA 指令 → 完整 OTA 流程（accepted → 下载 → SHA256 校验 → 进度 → 最终 ACK）
6. 支持 Ctrl+C 优雅退出 / 强杀触发 LWT

presence 统一说明：
- online / offline / will 三者合并到 device/{mac}/presence
- 三者都 retain=true，Broker 上只保留最后一条状态
- payload 用 type 字段区分 online / offline
- data.reason 区分离线原因：shutdown / mqtt_lwt

打印说明：
- OTA 接收确认、最终 ACK：JSON 多行美化打印
- OTA 进度上报：JSON 单行紧凑打印（避免刷屏）
- 其他消息：单行打印
"""

import json
import ssl
import threading
import time
import signal
import sys
import hashlib
import os
import urllib.request
import urllib.error
from pathlib import Path

import paho.mqtt.client as mqtt

# ==================== 配置（从注册响应复制过来）====================
MQTT_HOST = "127.0.0.1"
MQTT_PORT = 8883
CLIENT_ID = "device-B4BFE90CDBA1"
USERNAME = "dev_B4BFE90CDBA1"
# ==================== 配置替换注册的密码====================
PASSWORD = "SgQiT28TTtXv66H2" 
KEEP_ALIVE = 60

DEVICE_ID = "B4BFE90CDBA1"
PRODUCT = "SmartHome-v1"
FIRMWARE = "1.0.29"                     # 会被 OTA 更新

# ==================== TLS / mTLS 配置 ====================
# mTLS 三件套：CA 证书（验证服务器） + 客户端证书 + 客户端私钥
# 按你实际的证书存放位置修改下面三个路径
CA_CERT     = r"D:\data\mqtt_auth_key\server_key\iot-ca.crt"
CLIENT_CERT = r"D:\data\mqtt_auth_key\server_key\B4BFE90CDBA1.crt"
CLIENT_KEY  = r"D:\data\mqtt_auth_key\server_key\B4BFE90CDBA1.key"

# ==================== presence 统一配置 ====================
# online / offline / will 三者共用一个 topic，retain=true
PRESENCE_TOPIC = f"device/{DEVICE_ID}/presence"
PRESENCE_QOS = 1
PRESENCE_RETAIN = True

# 遗嘱（LWT）：设备异常断开时由 Broker 代发
WILL_PAYLOAD = {
    "device": DEVICE_ID,
    "type": "offline",
    "timestamp": 0,
    "data": {
        "product": PRODUCT,
        "reason": "mqtt_lwt"
    }
}

# 心跳间隔（秒）
HEARTBEAT_INTERVAL = 30

# ==================== OTA 下载配置 ====================
DOWNLOAD_DIR = "."          # 固件下载保存目录
PROGRESS_STEP = 5           # 下载进度上报步长（%），每变化 >=5% 才发一次
HTTP_TIMEOUT = 30           # HTTP 超时（秒）
CHUNK_SIZE = 4096           # 每次读取字节数

# ==================== 全局状态 ====================
client = None
stop_flag = threading.Event()
heartbeat_thread = None

# OTA 相关
ota_in_progress = False              # 防止 OTA 期间处理新指令
ota_command_id = None                # 模拟 NVS：保存 OTA 的 commandId


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
                "mos": 8,
                "led": 3,
                "servo": 2
            }
        }
    }
    # ★ 关键：发到 presence topic，retain=True 覆盖旧 will
    client.publish(PRESENCE_TOPIC, json.dumps(online_payload),
                   qos=PRESENCE_QOS, retain=PRESENCE_RETAIN)
    print(f"[OUT] 已发送上线（presence） - firmware: {FIRMWARE}")


# ==================== 心跳线程 ====================
def start_heartbeat():
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

            stop_flag.wait(HEARTBEAT_INTERVAL)

    heartbeat_thread = threading.Thread(target=heartbeat_loop, daemon=True)
    heartbeat_thread.start()
    print(f"[OK] 心跳线程已启动（每 {HEARTBEAT_INTERVAL} 秒）")


# ==================== 普通指令 ACK ====================
def send_ack(command_id, target):
    ack_payload = {
        "device": DEVICE_ID,
        "commandId": command_id,
        "type": "ack",
        "success": True,
        "timestamp": int(time.time() * 1000),
        "data": {
            "target": target
        }
    }
    topic = f"device/{DEVICE_ID}/ack"
    client.publish(topic, json.dumps(ack_payload), qos=1)
    print(f"[OUT] 已回 ACK - commandId: {command_id}, target: {target}")
    print(f"       Topic: {topic}")
    print(f"       Payload: {json.dumps(ack_payload, ensure_ascii=False)}")


# ==================== OTA：接收确认 ====================
def send_ota_accept_ack(command_id):
    ack = {
        "device": DEVICE_ID,
        "commandId": command_id,
        "type": "ack",
        "success": True,
        "timestamp": int(time.time() * 1000),
        "data": {
            "otaState": "accepted"
        }
    }
    topic = f"device/{DEVICE_ID}/ack"
    payload_str = json.dumps(ack, ensure_ascii=False)
    client.publish(topic, payload_str, qos=1)
    print(f"[OTA] → ACK accepted（SENT → ACCEPTED）")
    print(f"       Topic: {topic}")
    print(f"       Payload: {json.dumps(ack, ensure_ascii=False, indent=7)}")


# ==================== OTA：进度上报 ====================
def send_ota_progress(command_id, state, progress, version=None):
    payload = {
        "device": DEVICE_ID,
        "type": "ota_progress",
        "commandId": command_id,
        "timestamp": int(time.time() * 1000),
        "data": {
            "otaState": state,
            "progress": progress
        }
    }
    if version:
        payload["data"]["version"] = version
    topic = f"device/{DEVICE_ID}/ota_progress"
    payload_str = json.dumps(payload, ensure_ascii=False)
    client.publish(topic, payload_str, qos=0)
    print(f"[OTA] → 进度 {state} {progress}%")
    print(f"       Topic: {topic}")
    print(f"       Payload: {payload_str}")


# ==================== OTA：最终 ACK ====================
def send_ota_final_ack(command_id, version, success=True, error=None):
    ack = {
        "device": DEVICE_ID,
        "commandId": command_id,
        "type": "ack",
        "success": success,
        "timestamp": int(time.time() * 1000),
        "data": {
            "otaState": "success" if success else "failed",
            "toVersion": version
        }
    }
    if error:
        ack["message"] = error

    topic = f"device/{DEVICE_ID}/ack"
    payload_str = json.dumps(ack, ensure_ascii=False)
    client.publish(topic, payload_str, qos=1)
    print(f"[OTA] → ACK 最终结果 success={success} version={version}")
    print(f"       Topic: {topic}")
    print(f"       Payload: {json.dumps(ack, ensure_ascii=False, indent=7)}")


# ==================== OTA：下载 + SHA256 校验 ====================
def download_firmware(url, expected_sha256, command_id, version, expected_size=None):
    """
    下载固件并校验 SHA256

    :return: (success, save_path, actual_sha256, error_msg)
    """
    os.makedirs(DOWNLOAD_DIR, exist_ok=True)
    save_path = os.path.join(DOWNLOAD_DIR, f"firmware_{version}.bin")

    sha256_ctx = hashlib.sha256()
    downloaded = 0
    total = expected_size if expected_size and expected_size > 0 else 0
    last_reported = -1

    try:
        print(f"[OTA] 开始下载: {url}")
        req = urllib.request.Request(url, headers={"User-Agent": "ESP32-OTA/1.0"})

        with urllib.request.urlopen(req, timeout=HTTP_TIMEOUT) as resp:
            # Content-Length 优先，其次用指令里的 size
            content_length = resp.headers.get("Content-Length")
            if content_length:
                try:
                    total = int(content_length)
                except ValueError:
                    pass
            if total > 0:
                print(f"[OTA] 文件大小: {total} bytes")
            else:
                print("[OTA] 文件大小未知（按块估算进度）")

            with open(save_path, "wb") as f:
                while True:
                    chunk = resp.read(CHUNK_SIZE)
                    if not chunk:
                        break
                    f.write(chunk)
                    sha256_ctx.update(chunk)
                    downloaded += len(chunk)

                    if total > 0:
                        progress = int(downloaded * 90 / total)   # 下载阶段映射到 0~90
                        if progress >= last_reported + PROGRESS_STEP:
                            last_reported = progress - (progress % PROGRESS_STEP)
                            send_ota_progress(command_id, "downloading", progress, version=version)
                    else:
                        # 未知大小：每 1MB 报一次，最大 90
                        mb = downloaded // (1024 * 1024)
                        if mb > last_reported:
                            last_reported = mb
                            send_ota_progress(command_id, "downloading",
                                              min(90, mb * PROGRESS_STEP), version=version)

        actual_sha256 = sha256_ctx.hexdigest()
        print(f"[OTA] 下载完成: {downloaded} bytes")
        print(f"[OTA] 期望 sha256: {expected_sha256}")
        print(f"[OTA] 实际 sha256: {actual_sha256}")

        # 校验
        if expected_sha256 and actual_sha256.lower() != expected_sha256.lower():
            error = f"SHA256 校验失败: 期望 {expected_sha256}, 实际 {actual_sha256}"
            print(f"[OTA] ❌ {error}")
            return False, save_path, actual_sha256, error

        print(f"[OTA] ✅ SHA256 校验通过")
        return True, save_path, actual_sha256, None

    except urllib.error.HTTPError as e:
        error = f"HTTP 错误 {e.code}: {e.reason}"
        print(f"[OTA] ❌ {error}")
        return False, save_path, None, error
    except urllib.error.URLError as e:
        error = f"网络错误: {e.reason}"
        print(f"[OTA] ❌ {error}")
        return False, save_path, None, error
    except Exception as e:
        error = f"下载异常: {e}"
        print(f"[OTA] ❌ {error}")
        return False, save_path, None, error


# ==================== OTA：完整流程（独立线程）====================
def ota_flow(command_id, target_version, url, sha256, size=None):
    """OTA 完整流程：真实下载 + SHA256 校验 + 模拟刷写"""
    global ota_in_progress, ota_command_id, FIRMWARE

    try:
        # ========== 阶段 1：立即回 accepted ==========
        print(f"\n[OTA] ========== 阶段 1：回接收确认 ==========")
        send_ota_accept_ack(command_id)
        time.sleep(0.5)

        # ========== 阶段 2：真实下载 + SHA256 校验 ==========
        print(f"\n[OTA] ========== 阶段 2：下载固件 + 校验 ==========")
        ok, save_path, actual_sha256, error = download_firmware(
            url=url,
            expected_sha256=sha256,
            command_id=command_id,
            version=target_version,
            expected_size=size
        )

        if not ok:
            # ★ 校验失败 / 下载失败：直接发失败 ACK，不再往下走
            print(f"[OTA] 下载或校验失败，终止 OTA：{error}")
            send_ota_final_ack(command_id, target_version, success=False, error=error)
            return

        # ========== 阶段 3：校验 → 刷写 → 重启（模拟）==========
        print(f"\n[OTA] ========== 阶段 3：校验 + 刷写 ==========")
        time.sleep(1)
        send_ota_progress(command_id, "verifying", 92, version=target_version)
        time.sleep(1)
        send_ota_progress(command_id, "flashing", 98, version=target_version)
        time.sleep(1)
        send_ota_progress(command_id, "rebooting", 99, version=target_version)

        # ========== 阶段 4：模拟重启（3 秒）==========
        print(f"\n[OTA] ========== 阶段 4：模拟重启（3 秒）==========")
        time.sleep(3)

        # ========== 阶段 5：重启完成 ==========
        FIRMWARE = target_version
        print(f"[OTA] 重启完成，当前版本：{FIRMWARE}")

        # ★ 关键：重启后必须重发 online（presence topic，retain=true 覆盖旧 will）
        send_online()

        # 上报最终进度
        send_ota_progress(command_id, "success", 100, version=target_version)

        # ★ 关键：发最终 ACK（ACCEPTED → SUCCESS）
        send_ota_final_ack(command_id, target_version, success=True)

        print(f"\n[OTA] ✅ OTA 完成 - version: {target_version}, 文件: {save_path}\n")

    except Exception as e:
        print(f"[OTA] ❌ OTA 失败: {e}")
        send_ota_final_ack(command_id, target_version, success=False, error=str(e))
    finally:
        ota_in_progress = False
        ota_command_id = None


# ==================== OTA：接收指令入口 ====================
def handle_ota_command(payload):
    """处理 OTA 指令（异步，不阻塞 MQTT 线程）"""
    global ota_in_progress, ota_command_id

    if ota_in_progress:
        print("[OTA] 已有 OTA 进行中，拒绝新指令")
        return

    command_id = payload.get("commandId")
    params = payload.get("params", {})

    url = params.get("url")
    version = params.get("version")
    sha256 = params.get("sha256")
    size = params.get("size")

    print(f"\n========== 收到 OTA 指令 ==========")
    print(f"  commandId: {command_id}")
    print(f"  url:       {url}")
    print(f"  version:   {version}")
    print(f"  sha256:    {sha256}")
    print(f"  size:      {size}")

    # 参数校验：url / version / sha256 必填
    if not url or not version:
        print("[OTA] 参数不完整（url/version 缺失），拒绝")
        send_ota_final_ack(command_id, version or "unknown",
                           success=False, error="参数不完整：url/version 缺失")
        return

    if not sha256:
        print("[OTA] 缺少 sha256，拒绝（无完整性校验的 OTA 不安全）")
        send_ota_final_ack(command_id, version,
                           success=False, error="参数不完整：缺少 sha256")
        return

    # 保存 commandId（真实设备要存 NVS）
    ota_command_id = command_id
    ota_in_progress = True

    # 异步执行 OTA（把 url/sha256/size 传进去）
    threading.Thread(
        target=ota_flow,
        args=(command_id, version, url, sha256, size),
        daemon=True
    ).start()


# ==================== MQTT 回调（Callback API v1）====================
def on_connect(c, userdata, flags, rc):
    if rc == 0:
        print(f"[OK] 已连接 {MQTT_HOST}:{MQTT_PORT}")
        print(f"     ClientId: {CLIENT_ID}")
        print(f"     Username: {USERNAME}")

        # 订阅指令主题
        c.subscribe(f"device/{DEVICE_ID}/command", qos=1)
        print(f"[OK] 已订阅 device/{DEVICE_ID}/command")

        # 发上线（presence topic，retain=true）
        send_online()

        # 启动心跳
        start_heartbeat()
    else:
        print(f"[ERR] 连接失败，返回码: {rc}")
        stop_flag.set()


def on_disconnect(c, userdata, rc):
    if rc != 0:
        print(f"[WARN] 意外断开，返回码: {rc}")


def on_message(c, userdata, msg):
    print(f"\n[IN] 收到消息 - Topic: {msg.topic}")
    try:
        payload = json.loads(msg.payload.decode('utf-8'))
        print(f"     Payload: {json.dumps(payload, ensure_ascii=False)}")

        command_id = payload.get("commandId")
        if not command_id:
            print("[WARN] 消息缺少 commandId，忽略")
            return

        target = payload.get("target")

        # ★ 关键：OTA 指令走独立流程
        if target == "ota":
            handle_ota_command(payload)
        else:
            # 普通指令：直接回成功 ACK
            send_ack(command_id, target)

    except Exception as e:
        print(f"[ERR] 处理消息失败: {e}")
        print(f"     Payload(raw): {msg.payload.decode('utf-8', errors='ignore')}")


# ==================== 优雅退出 ====================
def graceful_shutdown(signum=None, frame=None):
    print("\n\n========== 收到退出信号 ==========")
    stop_flag.set()

    if client:
        # 发主动离线消息（presence topic，retain=true）
        offline_payload = {
            "device": DEVICE_ID,
            "type": "offline",
            "timestamp": int(time.time() * 1000),
            "data": {
                "product": PRODUCT,
                "reason": "shutdown"
            }
        }
        try:
            client.publish(PRESENCE_TOPIC, json.dumps(offline_payload),
                           qos=PRESENCE_QOS, retain=PRESENCE_RETAIN)
            print(f"[OUT] 已发送离线（presence） - reason: shutdown")
            time.sleep(0.5)   # 等 publish 出网，再 disconnect
        except Exception as e:
            print(f"[ERR] 发送离线失败: {e}")

        try:
            client.disconnect()
            print("[INFO] 已断开 8883")
        except Exception:
            pass

    time.sleep(0.5)
    print("[INFO] 程序退出")
    sys.exit(0)


# ==================== TLS 证书检查 ====================
def check_tls_files():
    """启动前检查 mTLS 三件套是否齐全，缺哪个报哪个，避免 load_verify_locations 的模糊错误"""
    checks = {
        "CA_CERT (验证服务器)": CA_CERT,
        "CLIENT_CERT (客户端证书)": CLIENT_CERT,
        "CLIENT_KEY (客户端私钥)": CLIENT_KEY,
    }
    missing = []
    for name, p in checks.items():
        path = Path(p)
        if not path.exists():
            missing.append(f"  - {name}: {path}")
    if missing:
        print("[FATAL] 以下 TLS 文件不存在：")
        for m in missing:
            print(m)
        print("\n请检查 EMQX certs 目录 / 你生成的客户端证书路径是否正确。")
        sys.exit(1)


# ==================== 主流程 ====================
def main():
    global client

    # 注册信号
    signal.signal(signal.SIGINT, graceful_shutdown)
    signal.signal(signal.SIGTERM, graceful_shutdown)

    print("=" * 60)
    print(f"模拟设备: {DEVICE_ID}")
    print(f"连接: {MQTT_HOST}:{MQTT_PORT}  (mTLS)")
    print(f"固件版本: {FIRMWARE}")
    print(f"presence topic: {PRESENCE_TOPIC} (retain={PRESENCE_RETAIN})")
    print("=" * 60)

    # 先检查证书文件
    check_tls_files()

    # 创建客户端（显式声明 v1 回调 API，消除 DeprecationWarning）
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION1, client_id=CLIENT_ID)

    # 设置遗嘱（发到 presence topic，retain=true）
    will_payload_str = json.dumps(WILL_PAYLOAD)
    client.will_set(PRESENCE_TOPIC, will_payload_str,
                    qos=PRESENCE_QOS, retain=PRESENCE_RETAIN)
    print(f"[LWT] 遗嘱已设置: {PRESENCE_TOPIC}")

    # ==================== mTLS 配置 ====================
    # ca_certs : 验证服务器证书
    # certfile : 提供给 broker 验证的客户端证书
    # keyfile  : 客户端证书对应的私钥
    try:
        client.tls_set(
            ca_certs=CA_CERT,
            certfile=CLIENT_CERT,
            keyfile=CLIENT_KEY,
            cert_reqs=ssl.CERT_REQUIRED,
            tls_version=ssl.PROTOCOL_TLS_CLIENT,
        )
        # 连的是 IP，服务器证书 SAN 通常不含 IP，跳过主机名校验
        # 注意：这只跳过 hostname 校验，证书链校验仍然生效
        client.tls_insecure_set(True)
        print(f"[TLS] mTLS 已启用")
        print(f"      CA:   {CA_CERT}")
        print(f"      Cert: {CLIENT_CERT}")
        print(f"      Key:  {CLIENT_KEY}")
    except Exception as e:
        print(f"[FATAL] TLS 配置失败: {e}")
        sys.exit(1)

    # 凭据（如果 EMQX 只配了证书认证，这两项会被忽略；叠加用户名认证时保留）
    client.username_pw_set(USERNAME, PASSWORD)

    # 回调
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.on_message = on_message

    # 连接
    print(f"\n[INFO] 连接 {MQTT_HOST}:{MQTT_PORT} ...")
    try:
        client.connect(MQTT_HOST, MQTT_PORT, keepalive=KEEP_ALIVE)
    except Exception as e:
        print(f"[FATAL] 连接失败: {e}")
        sys.exit(1)

    client.loop_start()

    # 保持运行
    print("\n[INFO] 设备运行中，按 Ctrl+C 退出...\n")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        graceful_shutdown()


if __name__ == '__main__':
    main()