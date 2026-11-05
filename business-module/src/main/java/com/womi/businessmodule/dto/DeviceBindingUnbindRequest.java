package com.womi.businessmodule.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 管理端解绑设备请求
 */
@Data
public class DeviceBindingUnbindRequest {

    @NotNull(message = "用户ID不能为空")
    private Long userId;
}
