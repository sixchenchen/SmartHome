package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

@Data
@TableName(value = "device_state_record", autoResultMap = true)
public class DeviceStateRecord {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("device_id")
    private String deviceId;

    private String target;

    private Integer channel;

    @TableField(value = "params", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> params;

    private LocalDateTime timestamp;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}