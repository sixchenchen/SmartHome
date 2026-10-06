package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

@Data
@TableName(value = "device_sensor", autoResultMap = true)
public class DeviceSensor {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("device_id")
    private String deviceId;

    @TableField("sensor_key")
    private String sensorKey;

    @TableField("sensor_id")
    private Integer sensorId;

    @TableField("sensor_type")
    private String sensorType;

    @TableField("sensor_name")
    private String sensorName;

    private String source;

    @TableField("slave_address")
    private Integer slaveAddress;

    private String unit;

    @TableField(value = "spec", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> spec;

    private Integer enabled;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}