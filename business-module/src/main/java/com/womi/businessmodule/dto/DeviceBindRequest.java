package com.womi.businessmodule.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DeviceBindRequest {

    @NotBlank(message = "设备ID不能为空")
    private String deviceId;

    /**
     * 解绑时可忽略
     */
    private String bindCode;
}
