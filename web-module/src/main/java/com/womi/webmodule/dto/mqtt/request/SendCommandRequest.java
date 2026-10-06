package com.womi.webmodule.dto.mqtt.request;

import lombok.Data;

import java.util.Map;

@Data
public class SendCommandRequest {
        private String deviceId;
        private String commandType;
        private Map<String, Object> payload;
        private String operator;
        private Integer expireSeconds;
}
