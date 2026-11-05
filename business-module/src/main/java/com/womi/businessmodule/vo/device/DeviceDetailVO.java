package com.womi.businessmodule.vo.device;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 用户设备详情
 */
@Data
public class DeviceDetailVO {

    private Long id;

    private String deviceId;

    private String deviceName;

    private String product;

    private String firmware;

    private String location;

    private Boolean online;

    private String offlineReason;

    private LocalDateTime lastOnlineTime;

    private LocalDateTime lastOfflineTime;

    private LocalDateTime lastHeartbeatTime;

    private Long uptime;

    private Map<String, Object> capabilities;

    private Map<String, Object> currentState;

    private Integer configVersion;

    private String otaState;

    private Integer otaProgress;

    private String otaVersion;

    private LocalDateTime otaUpdateTime;

    private LocalDateTime bindTime;

    private LocalDateTime createTime;
}
