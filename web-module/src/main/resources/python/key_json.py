import base64
import json
import time
import uuid
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes, serialization

# ===== 1. 生成密钥对（实际项目里由设备出厂时生成）=====
private_key = ec.generate_private_key(ec.SECP256R1())
public_key = private_key.public_key()

# ===== 2. 导出公钥 PEM =====
pubkey_pem = public_key.public_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PublicFormat.SubjectPublicKeyInfo
).decode('utf-8')

# ===== 3. 构建设备信息 =====
device = "B4BFE90CDBA1"
timestamp = int(time.time() * 1000)
nonce = str(uuid.uuid4())

# ===== 4. 待签数据（和 Java 端一致）=====
sign_data = f"{device}|{timestamp}|{nonce}"

# ===== 5. 签名 =====
signature = private_key.sign(
    sign_data.encode('utf-8'),
    ec.ECDSA(hashes.SHA256())
)
signature_b64 = base64.b64encode(signature).decode('utf-8')

# ===== 6. 组装 JSON =====
payload = {
    "device": device,
    "product": "SmartHome-v1",
    "type": "register",
    "timestamp": timestamp,
    "data": {
        "firmware": "1.0.29",
        "chip": "ESP32",
        "hardware_version": "V1.0",
        "nonce": nonce,
        "pubkey": pubkey_pem,
        "signature": signature_b64
    }
}

print(json.dumps(payload, indent=2, ensure_ascii=False))