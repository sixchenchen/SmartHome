package com.womi.businessmodule.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 管理端编辑设备请求
 */
@Data
public class DeviceAdminUpdateRequest {

    @Size(max = 64, message = "设备名称最长 64 位")
    private String deviceName;

    @Size(max = 64, message = "产品标识最长 64 位")
    private String product;

    @Size(max = 128, message = "位置最长 128 位")
    private String location;
}
