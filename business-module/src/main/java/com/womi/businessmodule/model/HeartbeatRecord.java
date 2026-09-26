package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("heartbeat_record")
public class HeartbeatRecord {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String deviceId;
    private Long uptime;
    private LocalDateTime timestamp;
    private String payload;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}