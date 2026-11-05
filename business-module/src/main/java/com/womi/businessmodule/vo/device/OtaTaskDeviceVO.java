package com.womi.businessmodule.vo.device;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * OTA 任务下的单设备执行情况
 */
@Data
public class OtaTaskDeviceVO {

    private String deviceId;

    private String deviceName;

    private String firmware;

    private String otaState;

    private Integer otaProgress;

    private Integer commandStatus;

    private String commandStatusText;

    private String errorMsg;

    private LocalDateTime updateTime;
}
