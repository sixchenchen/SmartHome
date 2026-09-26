package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("sensor_slave_data")
public class SensorSlaveData {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String deviceId;
    private Integer address;
    private Integer online;
    private Integer count;
    private LocalDateTime timestamp;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}