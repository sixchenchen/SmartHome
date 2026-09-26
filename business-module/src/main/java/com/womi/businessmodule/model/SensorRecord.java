package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("sensor_record")
public class SensorRecord {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String deviceId;
    private String sensorData;  // JSON 字符串
    private LocalDateTime timestamp;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}