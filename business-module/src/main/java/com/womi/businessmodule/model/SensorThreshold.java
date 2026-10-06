package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 传感器阈值配置表
 */
@Data
@TableName("sensor_threshold")
public class SensorThreshold {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("device_id")
    private String deviceId;

    /** 传感器唯一标识，对应 device_sensor.sensor_key */
    @TableField("sensor_key")
    private String sensorKey;

    /** 传感器类型 */
    @TableField("sensor_type")
    private String sensorType;

    /** 最小值（低于则告警） */
    @TableField("min_value")
    private Double minValue;

    /** 最大值（高于则告警） */
    @TableField("max_value")
    private Double maxValue;

    /** 预警下限 */
    @TableField("warn_min")
    private Double warnMin;

    /** 预警上限 */
    @TableField("warn_max")
    private Double warnMax;

    /** 告警级别: 1-提示 2-一般 3-严重 */
    @TableField("alarm_level")
    private Integer alarmLevel;

    /** 告警文案模板 */
    @TableField("alarm_message")
    private String alarmMessage;

    /** 持续时间(秒)，超过该时长才告警 */
    private Integer duration;

    /** 是否启用: 0-禁用 1-启用 */
    private Integer enabled;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}