package com.womi.businessmodule.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class DeviceCreateRequest {
    @NotBlank(message = "设备MAC地址不能为空")
    private String deviceId;

    private String deviceName;
    private String product;
    private String location;
}