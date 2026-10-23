package com.womi.businessmodule.dto;

import lombok.Data;

import java.util.Map;

/**
 * 下发指令请求
 */
@Data
public class SendCommandRequest {

    /** 目标设备ID（MAC） */
    private String deviceId;

    /** 动作: set/get/toggle/start/reset */
    private String action;

    /** 目标: mos/led/servo/relay/ota/config */
    private String target;

    /** 通道号，可选 */
    private Integer channel;

    /** 指令参数，可选 */
    private Map<String, Object> params;

    /** 操作人，可选 */
    private String operator;

    /** 过期时间（秒），可选，<=0 时用默认值 */
    private Integer expireSeconds;
}