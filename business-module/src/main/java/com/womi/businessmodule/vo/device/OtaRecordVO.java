package com.womi.businessmodule.vo.device;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * OTA 升级记录
 */
@Data
public class OtaRecordVO {

    private Long id;

    private String commandId;

    private String deviceId;

    private String version;

    private Integer status;

    private String statusText;

    private String otaState;

    private Integer progress;

    private String errorMsg;

    private LocalDateTime createTime;

    private LocalDateTime sendTime;

    private LocalDateTime ackTime;
}
