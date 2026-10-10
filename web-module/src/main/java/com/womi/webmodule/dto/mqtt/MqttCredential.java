package com.womi.webmodule.dto.mqtt;


import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * MQTT 凭据
 */
@Data
@AllArgsConstructor
public class MqttCredential {

    /** 客户端 ID（返回设备） */
    private String clientId;

    /** 用户名（返回设备 + 存库） */
    private String username;

    /** 明文密码（返回设备） */
    private String plainPassword;

    /** 盐值（存库） */
    private String salt;

    /** 密码哈希（存库） */
    private String passwordHash;
}