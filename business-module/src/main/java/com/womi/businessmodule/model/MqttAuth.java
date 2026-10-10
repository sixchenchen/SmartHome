package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 统一 MQTT 认证账号表
 */
@Data
@TableName("mqtt_auth")
public class MqttAuth {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("username")
    private String username;

    @TableField("password")
    private String password;

    @TableField("salt")
    private String salt;

    @TableField("is_superuser")
    private Integer isSuperuser;

    @TableField("enabled")
    private Integer enabled;

    @TableField("device_id")
    private String deviceId;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}