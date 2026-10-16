package com.womi.businessmodule.model.device;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 设备告警记录表
 */
@Data
@TableName(value = "device_alert_record")
public class DeviceAlertRecord {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 设备ID */
    @TableField("device_id")
    private String deviceId;

    /** 传感器标识 */
    @TableField("sensor_key")
    private String sensorKey;

    /** 级别:1-提示 2-一般 3-严重 */
    @TableField("alert_level")
    private Integer alertLevel;

    /** 类型: threshold/offline/fault */
    @TableField("alert_type")
    private String alertType;

    /** 告警消息 */
    private String message;

    /** 触发值 */
    private Double value;

    /** 阈值 */
    private Double threshold;

    /** 0-未处理 1-已确认 2-已解决 */
    private Integer status;

    /** 处理人 */
    @TableField("handled_by")
    private String handledBy;

    /** 处理时间 */
    @TableField("handled_time")
    private LocalDateTime handledTime;

    /** 触发时间 */
    private LocalDateTime timestamp;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}