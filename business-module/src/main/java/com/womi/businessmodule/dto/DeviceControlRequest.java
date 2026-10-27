package com.womi.businessmodule.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.util.Map;

@Data
public class DeviceControlRequest {
    @NotBlank(message = "设备ID不能为空")
    private String deviceId;

    @NotBlank(message = "动作不能为空")
    private String action; // 如: set, toggle, on, off

    @NotBlank(message = "目标不能为空")
    private String target; // 如: led, mos, relay

    private Integer channel; // 通道号，没有可为空

    @NotNull(message = "参数不能为空")
    private Map<String, Object> params; // 比如 {"state": 1} 或 {"brightness": 80}
}