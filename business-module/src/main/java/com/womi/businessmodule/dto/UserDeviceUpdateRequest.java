package com.womi.businessmodule.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 用户修改设备名称/位置请求
 */
@Data
public class UserDeviceUpdateRequest {

    @Size(max = 64, message = "设备名称最长 64 位")
    private String deviceName;

    @Size(max = 128, message = "位置最长 128 位")
    private String location;
}
