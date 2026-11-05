package com.womi.businessmodule.vo.device;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 管理端设备列表/详情
 */
@Data
public class AdminDeviceVO {

    private Long id;

    private String deviceId;

    private String deviceName;

    private String product;

    private String firmware;

    private String location;

    private String bindCode;

    private Integer groupId;

    private Boolean online;

    private String offlineReason;

    private LocalDateTime lastOnlineTime;

    private LocalDateTime lastOfflineTime;

    private LocalDateTime lastHeartbeatTime;

    private Long uptime;

    private Map<String, Object> capabilities;

    private Map<String, Object> currentState;

    private String otaState;

    private Integer otaProgress;

    private String otaVersion;

    private LocalDateTime otaUpdateTime;

    private Integer configVersion;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
