package com.womi.businessmodule.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.Map;

/**
 * 管理端向设备下发指令请求
 */
@Data
public class AdminDeviceCommandRequest {

    @NotBlank(message = "动作不能为空")
    private String action;

    @NotBlank(message = "目标不能为空")
    private String target;

    private Integer channel;

    @NotNull(message = "参数不能为空")
    private Map<String, Object> params;
}
