package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("device_whitelist")
public class DeviceWhitelist {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("device_id")
    private String deviceId;

    @TableField("batch")
    private String batch;

    @TableField("enabled")
    private Integer enabled;

    @TableField("remark")
    private String remark;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}