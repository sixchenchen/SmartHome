package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 传感器数据历史表
 */
@Data
@TableName(value = "sensor_record", autoResultMap = true)
public class SensorRecord {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("device_id")
    private String deviceId;

    /** 数据来源: host/slave */
    private String source;

    /** 从机地址（source=slave 时使用） */
    @TableField("slave_address")
    private Integer slaveAddress;

    /** 主机直连传感器编号（source=host 时使用） */
    @TableField("sensor_id")
    private Integer sensorId;

    /** 通道号：从机内部通道 / 主机多路通道 */
    private Integer channel;

    /** 传感器唯一标识，对应 device_sensor.sensor_key */
    @TableField("sensor_key")
    private String sensorKey;

    /** 传感器类型: temperature/odor/grating_counter/humidity... */
    @TableField("sensor_type")
    private String sensorType;

    /** 数值 */
    @TableField("sensor_value")
    private Double sensorValue;

    /** 单位: °C/ppm/count/%... */
    private String unit;

    /** 扩展字段，如 {"raw":100,"sampleRate":10} */
    @TableField(value = "extra", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> extra;

    /** 原始数据 JSON */
    @TableField("sensor_data")
    private String sensorData;

    /** 采集时间 */
    private LocalDateTime timestamp;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}