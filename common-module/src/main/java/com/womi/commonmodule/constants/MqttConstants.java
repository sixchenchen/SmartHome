package com.womi.commonmodule.constants;

/**
 * MQTT 领域常量
 */
public final class MqttConstants {

    private MqttConstants() {
    }
    // ---------- 凭据前缀 ----------
    /**
     * MQTT 客户端 ID 前缀
     */
    public static final String MQTT_CLIENT_ID_PREFIX = "device-";
    /**
     * MQTT 用户名前缀
     */
    public static final String MQTT_USERNAME_PREFIX = "dev_";
    // ---------- 注册响应字段：MQTT 配置 ----------
    public static final String FIELD_MQTT_HOST = "host";
    public static final String FIELD_MQTT_PORT = "port";
    public static final String FIELD_MQTT_CLIENT_ID = "clientId";
    public static final String FIELD_MQTT_USERNAME = "username";
    public static final String FIELD_MQTT_PASSWORD = "password";
    public static final String FIELD_MQTT_KEEP_ALIVE = "keepAlive";

    // ---------- 注册响应字段：Will 配置 ----------
    public static final String FIELD_WILL_TOPIC = "topic";
    public static final String FIELD_WILL_QOS = "qos";
    public static final String FIELD_WILL_RETAIN = "retain";
    public static final String FIELD_WILL_PAYLOAD = "payload";

    // ---------- 注册响应字段：设备配置 ----------
    public static final long REGISTER_TIMESTAMP_WINDOW_MS = 5 * 60 * 1000;
    public static final String FIELD_HEARTBEAT_INTERVAL = "heartbeat_interval";
    public static final String FIELD_SENSOR_BATCH_SIZE = "sensor_batch_size";

// ---------- 默认配置值 ----------
    /**
     * 默认传感器批量上报大小
     */
    public static final int DEFAULT_SENSOR_BATCH_SIZE = 32;
    // ---------- Topic 前缀与分隔符 ----------
    /**
     * 设备主题前缀
     */
    public static final String DEVICE_TOPIC_PREFIX = "device";
    /**
     * 广播主题前缀
     */
    public static final String BROADCAST_TOPIC_PREFIX = "$broadcast";
    /**
     * 注册主题前缀
     */
    public static final String PROVISION_TOPIC_PREFIX = "/provision";
    /**
     * 主题分隔符
     */
    public static final String TOPIC_SEPARATOR = "/";

    // ---------- Topic 格式：下行（服务器 → 设备） ----------
    /**
     * 指令下发：device/{mac}/command
     */
    public static final String COMMAND_TOPIC_FORMAT = "device/%s/command";
    /**
     * 指令广播：$broadcast/command
     */
    public static final String COMMAND_BROADCAST_TOPIC = "$broadcast/command";

    // ---------- Topic 格式：上行（设备 → 服务器） ----------
    /**
     * 上线：device/{mac}/online
     */
    public static final String ONLINE_TOPIC_FORMAT = "device/%s/online";
    /**
     * 主动离线：device/{mac}/offline
     */
    public static final String OFFLINE_TOPIC_FORMAT = "device/%s/offline";
    /**
     * LWT 遗嘱：device/{mac}/will
     */
    public static final String WILL_TOPIC_FORMAT = "device/%s/will";
    /**
     * 心跳：device/{mac}/heartbeat
     */
    public static final String HEARTBEAT_TOPIC_FORMAT = "device/%s/heartbeat";
    /**
     * 状态：device/{mac}/state
     */
    public static final String STATE_TOPIC_FORMAT = "device/%s/state";
    /**
     * 回执：device/{mac}/ack
     */
    public static final String ACK_TOPIC_FORMAT = "device/%s/ack";
    /**
     * 事件：device/{mac}/event
     */
    public static final String EVENT_TOPIC_FORMAT = "device/%s/event";
    /**
     * 传感器：device/{mac}/sensor
     */
    public static final String SENSOR_TOPIC_FORMAT = "device/%s/sensor";

    // ---------- Topic 格式：注册（Broker 1884） ----------
    /**
     * 注册请求：/provision/device/{mac}/register
     */
    public static final String PROVISION_REGISTER_TOPIC_FORMAT = "/provision/device/%s/register";
    /**
     * 注册响应：/provision/device/{mac}/config
     */
    public static final String PROVISION_CONFIG_TOPIC_FORMAT = "/provision/device/%s/config";

    // ---------- Topic 正则（用于 Handler 匹配） ----------
    public static final String ONLINE_TOPIC_PATTERN = "device/[^/]+/online";
    public static final String OFFLINE_TOPIC_PATTERN = "device/[^/]+/offline";
    public static final String WILL_TOPIC_PATTERN = "device/[^/]+/will";
    public static final String HEARTBEAT_TOPIC_PATTERN = "device/[^/]+/heartbeat";
    public static final String STATE_TOPIC_PATTERN = "device/[^/]+/state";
    public static final String ACK_TOPIC_PATTERN = "device/[^/]+/ack";
    public static final String EVENT_TOPIC_PATTERN = "device/[^/]+/event";
    public static final String SENSOR_TOPIC_PATTERN = "device/[^/]+/sensor";
    public static final String PROVISION_REGISTER_TOPIC_PATTERN = "/provision/device/[^/]+/register";

    // ---------- payload 字段 key：通用 ----------
    public static final String FIELD_DEVICE = "device";
    public static final String FIELD_PRODUCT = "product";
    public static final String FIELD_FIRMWARE = "firmware";
    public static final String FIELD_CAPABILITIES = "capabilities";
    public static final String FIELD_TYPE = "type";
    public static final String FIELD_TIMESTAMP = "timestamp";
    public static final String FIELD_DATA = "data";

    // ---------- payload 字段 key：指令相关 ----------
    public static final String FIELD_COMMAND_ID = "commandId";
    public static final String FIELD_ACTION = "action";
    public static final String FIELD_TARGET = "target";
    public static final String FIELD_CHANNEL = "channel";
    public static final String FIELD_PARAMS = "params";
    public static final String FIELD_STATE = "state";
    public static final String FIELD_SUCCESS = "success";
    public static final String FIELD_ERROR = "error";
    public static final String FIELD_MESSAGE = "message";
    public static final String FIELD_CONTEXT = "context";
    public static final String FIELD_RESULT = "result";

    // ---------- payload 字段 key：状态相关 ----------
    public static final String FIELD_FULL = "full";
    public static final String FIELD_TARGETS = "targets";
    public static final String FIELD_CHANNELS = "channels";

    // ---------- payload 字段 key：事件相关 ----------
    public static final String FIELD_EVENT = "event";
    public static final String FIELD_TRIGGER = "trigger";

    // ---------- payload 字段 key：心跳 / 离线 ----------
    public static final String FIELD_UPTIME = "uptime";
    public static final String FIELD_RSSI = "rssi";
    public static final String FIELD_REASON = "reason";

    // ---------- payload 字段 key：传感器 ----------
    public static final String FIELD_SENSOR_ID = "sensor_id";
    public static final String FIELD_SENSOR_TYPE = "sensor_type";
    public static final String FIELD_VALUE = "value";
    public static final String FIELD_UNIT = "unit";
    public static final String FIELD_COUNT = "count";

    // ---------- payload 字段 key：OTA ----------
    public static final String FIELD_OTA_URL = "url";
    public static final String FIELD_OTA_VERSION = "version";
    public static final String FIELD_OTA_MD5 = "md5";
    public static final String FIELD_OTA_SIZE = "size";
    public static final String FIELD_OTA_PROGRESS = "progress";
    public static final String FIELD_OTA_FORCE = "force";

    // ---------- payload 字段 key：配置 ----------
    public static final String FIELD_CONFIG = "config";
    public static final String FIELD_CONFIG_VERSION = "configVersion";
    public static final String FIELD_PERSIST = "persist";

    // ---------- payload 字段 key：注册 ----------
    public static final String FIELD_CHIP = "chip";
    public static final String FIELD_HARDWARE_VERSION = "hardware_version";
    public static final String FIELD_NONCE = "nonce";
    public static final String FIELD_MQTT = "mqtt";
    public static final String FIELD_WILL = "will";
    public static final String FIELD_PUBKEY = "pubkey";
    public static final String FIELD_SIGNATURE = "signature";

    // ---------- 消息类型（payload.type） ----------
    public static final String MSG_TYPE_ONLINE = "online";
    public static final String MSG_TYPE_OFFLINE = "offline";
    public static final String MSG_TYPE_HEARTBEAT = "heartbeat";
    public static final String MSG_TYPE_STATE = "state";
    public static final String MSG_TYPE_ACK = "ack";
    public static final String MSG_TYPE_EVENT = "event";
    public static final String MSG_TYPE_ERROR = "error";
    public static final String MSG_TYPE_REGISTER = "register";
    public static final String MSG_TYPE_SENSOR_BATCH = "sensor_batch";

    // ---------- 下行指令 action ----------
    public static final String ACTION_SET = "set";
    public static final String ACTION_GET = "get";
    public static final String ACTION_TOGGLE = "toggle";
    public static final String ACTION_START = "start";
    public static final String ACTION_RESET = "reset";
    public static final String ACTION_CANCEL = "cancel";

    // ---------- 下行指令 target ----------
    public static final String TARGET_MOS = "mos";
    public static final String TARGET_LED = "led";
    public static final String TARGET_SERVO = "servo";
    public static final String TARGET_RELAY = "relay";
    public static final String TARGET_OTA = "ota";
    public static final String TARGET_CONFIG = "config";

    // ---------- 状态值 / 通道 ----------
    /**
     * 状态 - 关
     */
    public static final int STATE_OFF = 0;
    /**
     * 状态 - 开
     */
    public static final int STATE_ON = 1;
    /**
     * 通道 - 全部
     */
    public static final int CHANNEL_ALL = 0;

    // ---------- OTA 状态 ----------
    public static final String OTA_STATE_ACCEPTED = "accepted";
    public static final String OTA_STATE_DOWNLOADING = "downloading";
    public static final String OTA_STATE_VERIFYING = "verifying";
    public static final String OTA_STATE_FLASHING = "flashing";
    public static final String OTA_STATE_SUCCESS = "success";
    public static final String OTA_STATE_FAIL = "fail";
    public static final String OTA_STATE_CANCELED = "canceled";

    // ---------- MQTT Header Key ----------
    public static final String MQTT_HEADER_TOPIC = "mqtt_topic";
    public static final String MQTT_HEADER_QOS = "mqtt_qos";
    public static final String MQTT_HEADER_RETAINED = "mqtt_retained";
    public static final String MQTT_RECEIVED_TOPIC = "mqtt_receivedTopic";
    public static final String MQTT_RECEIVED_QOS = "mqtt_receivedQos";

    // ---------- QoS / Retained 策略 ----------
    /**
     * 默认 QoS
     */
    public static final int DEFAULT_QOS = 1;
    /**
     * 默认 Retained
     */
    public static final boolean DEFAULT_RETAINED = false;
    /**
     * 心跳 QoS（高频，可丢）
     */
    public static final int HEARTBEAT_QOS = 0;
    /**
     * 传感器 QoS（高频，可丢）
     */
    public static final int SENSOR_QOS = 0;
    /**
     * 状态 QoS（需送达）
     */
    public static final int STATE_QOS = 1;
    /**
     * 状态 Retained（重启恢复）
     */
    public static final boolean STATE_RETAINED = true;
    /**
     * 在线/离线 Retained（重启恢复）
     */
    public static final boolean PRESENCE_RETAINED = true;

    // ---------- MQTT 客户端参数 ----------
    /**
     * 入站客户端后缀
     */
    public static final String INBOUND_SUFFIX = "-inbound";
    /**
     * 出站客户端后缀
     */
    public static final String OUTBOUND_SUFFIX = "-outbound";

    // ---------- 硬件参数 ----------
    /**
     * MOS 通道总数
     */
    public static final int MOS_CHANNEL_COUNT = 8;
    /**
     * 默认心跳间隔（秒）
     */
    public static final int DEFAULT_HEARTBEAT_INTERVAL = 30;
}