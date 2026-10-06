package com.womi.webmodule.dto.mqtt.response;


import com.womi.commonmodule.enums.MqttErrorCode;
import lombok.Data;
import java.util.Map;

@Data
public class RegisterResponse {
    /**
     * 是否成功
     */
    private boolean success;
    /**
     * 错误码（失败时）
     */
    private String error;
    /**
     * 错误描述（失败时）
     */
    private String message;

    /**
     * MQTT 配置（成功时）
     */
    private Map<String, Object> mqtt;
    /**
     * LWT 遗嘱配置（成功时）
     */
    private Map<String, Object> will;
    /**
     * 初始配置（成功时）
     */
    private Map<String, Object> config;
    /**
     * 成功响应
     */
    public static RegisterResponse success(Map<String, Object> mqtt,
                                           Map<String, Object> will,
                                           Map<String, Object> config) {
        RegisterResponse response = new RegisterResponse();
        response.setSuccess(true);
        response.setMqtt(mqtt);
        response.setWill(will);
        response.setConfig(config);
        return response;
    }

    public static RegisterResponse error(MqttErrorCode errorCode) {
        RegisterResponse response = new RegisterResponse();
        response.setSuccess(false);
        response.setError(errorCode.getCode());
        response.setMessage(errorCode.getDefaultMessage());
        return response;
    }

    /**
     * 带自定义消息的错误响应
     */
    public static RegisterResponse error(MqttErrorCode errorCode, String customMessage) {
        RegisterResponse response = new RegisterResponse();
        response.setSuccess(false);
        response.setError(errorCode.getCode());
        response.setMessage(customMessage != null ? customMessage : errorCode.getDefaultMessage());
        return response;
    }
}