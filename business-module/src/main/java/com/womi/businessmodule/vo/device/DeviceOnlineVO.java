package com.womi.businessmodule.vo.device;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 设备在线状态
 */
@Data
public class DeviceOnlineVO {

    private String deviceId;

    private Boolean online;

    private LocalDateTime lastHeartbeatTime;

    private String offlineReason;
}
