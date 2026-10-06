package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

@Data
@TableName(value = "device_info", autoResultMap = true)
public class DeviceInfo {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("device_id")
    private String deviceId;

    @TableField("device_name")
    private String deviceName;

    private String product;

    private String firmware;

    private String location;

    private Integer online;

    @TableField("offline_reason")
    private String offlineReason;

    @TableField("last_online_time")
    private LocalDateTime lastOnlineTime;

    @TableField("last_offline_time")
    private LocalDateTime lastOfflineTime;

    @TableField("last_heartbeat_time")
    private LocalDateTime lastHeartbeatTime;

    @TableField("last_update_time")
    private LocalDateTime lastUpdateTime;

    private Long uptime;

    @TableField(value = "capabilities", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> capabilities;

    @TableField(value = "current_state", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> currentState;

    @TableField("ota_state")
    private String otaState;

    @TableField("ota_progress")
    private Integer otaProgress;

    @TableField("ota_version")
    private String otaVersion;

    @TableField("config_version")
    private Integer configVersion;

    @TableField("last_payload")
    private String lastPayload;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}