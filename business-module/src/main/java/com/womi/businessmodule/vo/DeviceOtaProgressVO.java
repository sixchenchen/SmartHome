package com.womi.businessmodule.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class DeviceOtaProgressVO {

    private String deviceId;
    private String otaState;
    private Integer otaProgress;
    private String otaVersion;
    private LocalDateTime updateTime;
}