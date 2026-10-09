package com.womi.webmodule.dto.ota.request;

import lombok.Data;

import java.util.List;

@Data
public class OtaStartRequest {

    /** 目标设备 ID（单设备） */
    private String deviceId;

    /** 目标设备 ID 列表（批量） */
    private List<String> deviceIds;

    /** 固件 ID（从 firmware 表查） */
    private Long firmwareId;

    /** 操作人 */
    private String operator;

    /** 过期秒数（默认 600） */
    private Integer expireSeconds;
}