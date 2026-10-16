package com.womi.businessmodule.model.device;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 设备绑定关系表
 */
@Data
@TableName(value = "device_binding")
public class DeviceBinding {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 设备ID(MAC) */
    @TableField("device_id")
    private String deviceId;

    /** 生成列：仅有效绑定时=device_id */
    @TableField("active_device_id")
    private String activeDeviceId;

    /** 用户ID */
    @TableField("user_id")
    private Long userId;

    /** 绑定状态：1有效，0解绑 */
    @TableField("bind_status")
    private Integer bindStatus;

    /** 绑定时间 */
    @TableField("bind_time")
    private LocalDateTime bindTime;

    /** 解绑时间 */
    @TableField("unbind_time")
    private LocalDateTime unbindTime;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}