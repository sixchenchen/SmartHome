package com.womi.businessmodule.vo.device;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 设备绑定关系
 */
@Data
public class DeviceBindingVO {

    private Long bindingId;

    private Long userId;

    private String username;

    private String nickname;

    private LocalDateTime bindTime;

    private Integer bindStatus;
}
