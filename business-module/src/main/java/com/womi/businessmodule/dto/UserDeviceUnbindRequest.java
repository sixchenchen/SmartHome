package com.womi.businessmodule.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 管理端强制解绑设备请求
 */
@Data
public class UserDeviceUnbindRequest {

    @NotBlank(message = "设备ID不能为空")
    private String deviceId;
}
