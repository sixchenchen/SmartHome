package com.womi.commonmodule.mqtt;

/**
 * MQTT 领域常量
 */
public final class MqttConstants {
    private MqttConstants() {} // 防止实例化

    /** 设备主题前缀 */
    public static final String DEVICE_TOPIC_PREFIX = "device";

    /** 主题分隔符 */
    public static final String TOPIC_SEPARATOR = "/";

    /** 消息类型 - 心跳 */
    public static final String MSG_TYPE_HEART = "heart";

    /** 消息类型 - MOS 状态 */
    public static final String MSG_TYPE_MOS_STATE = "mos_state";

    /** 消息类型 - 传感器 */
    public static final String MSG_TYPE_SENSOR = "sensor";

    /** 消息类型 - 指令 */
    public static final String MSG_TYPE_COMMAND = "command";

    /** 心跳主题正则 */
    public static final String HEART_TOPIC_PATTERN = "device/[^/]+/heart";

    /** MOS 状态主题正则 */
    public static final String MOS_TOPIC_PATTERN = "device/[^/]+/mos_state";

    /** 传感器主题正则 */
    public static final String SENSOR_TOPIC_PATTERN = "device/[^/]+/sensor";

    /** 指令下发主题格式 */
    public static final String COMMAND_TOPIC_FORMAT = "device/%s/command";

    /** 出站 header key - 主题 */
    public static final String MQTT_HEADER_TOPIC = "mqtt_topic";

    /** 出站 header key - QoS */
    public static final String MQTT_HEADER_QOS = "mqtt_qos";

    /** 出站 header key - 是否保留 */
    public static final String MQTT_HEADER_RETAINED = "mqtt_retained";

    /** 入站 header key - 接收主题 */
    public static final String MQTT_RECEIVED_TOPIC = "mqtt_receivedTopic";

    /** 入站 header key - 接收 QoS */
    public static final String MQTT_RECEIVED_QOS = "mqtt_receivedQos";

    /** payload 字段 key - data */
    public static final String FIELD_DATA = "data";

    /** payload 字段 key - uptime */
    public static final String FIELD_UPTIME = "uptime";

    /** payload 字段 key - mos（前缀，拼接通道号） */
    public static final String FIELD_MOS = "mos";

    /** payload 字段 key - slaves */
    public static final String FIELD_SLAVES = "slaves";

    /** payload 字段 key - addr */
    public static final String FIELD_ADDR = "addr";

    /** payload 字段 key - online */
    public static final String FIELD_ONLINE = "online";

    /** payload 字段 key - count */
    public static final String FIELD_COUNT = "count";

    /** payload 字段 key - command */
    public static final String FIELD_COMMAND = "command";

    /** payload 字段 key - commandId */
    public static final String FIELD_COMMAND_ID = "commandId";

    /** payload 字段 key - timestamp */
    public static final String FIELD_TIMESTAMP = "timestamp";

    /** MOS 通道总数 */
    public static final int MOS_CHANNEL_COUNT = 8;

    /** 默认发送 QoS */
    public static final int DEFAULT_QOS = 1;

    /** 默认是否保留消息 */
    public static final boolean DEFAULT_RETAINED = false;

    /** 入站客户端后缀 */
    public static final String INBOUND_SUFFIX = "-inbound";

    /** 出站客户端后缀 */
    public static final String OUTBOUND_SUFFIX = "-outbound";
}