package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("device_info")
public class DeviceInfo {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String deviceId;
    private String deviceName;
    private String location;
    private Integer status;  // 0-离线, 1-在线, 2-故障
    private Long uptime;  // 运行时间（秒）
    private LocalDateTime lastHeartbeatTime;
    private LocalDateTime lastUpdateTime;
    private String lastPayload;
    private String sensorData;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}