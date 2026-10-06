package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 设备从机数据表
 */
@Data
@TableName(value = "device_slave_data", autoResultMap = true)
public class DeviceSlaveData {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("device_id")
    private String deviceId;

    /** 从机地址(RS-485) */
    private Integer address;

    /** 从机外设类型 */
    @TableField("slave_type")
    private String slaveType;

    /** 通道号：同一从机多路同类型时使用，单通道为 NULL */
    private Integer channel;

    /** 本次上线时间 */
    @TableField("online_since")
    private LocalDateTime onlineSince;

    /** 当前值 */
    private Double value;

    /** 单位 */
    private String unit;

    /** 扩展字段 */
    @TableField(value = "extra", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> extra;

    /** 最后采集时间 */
    private LocalDateTime timestamp;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}