package com.womi.webmodule.service;

import com.womi.businessmodule.model.DeviceCommand;

import java.util.Map;

public interface DeviceControlService {

    /**
     * 通用指令下发
     */
    DeviceCommand sendCommand(String deviceId, String action, String target,
                              Integer channel, Map<String, Object> params,
                              String operator, int expireSeconds);

    // ==================== MOS ====================
    /**
     * 控制单个 MOS
     */
    DeviceCommand controlMos(String deviceId, int channel, int state, String operator);

    /**
     * 控制全部 MOS
     */
    DeviceCommand controlMosAll(String deviceId, int state, String operator);

    /**
     * 查询 MOS 状态
     */
    DeviceCommand queryMos(String deviceId, int channel, String operator);

    // ==================== LED ====================
    DeviceCommand controlLed(String deviceId, int channel, int state, Integer brightness, String operator);

    // ==================== 舵机 ====================
    DeviceCommand controlServo(String deviceId, int channel, int angle, String operator);

    // ==================== OTA ====================
    DeviceCommand startOta(String deviceId, String url, String version, String md5, Long size, String operator);

    // ==================== 配置 ====================
    DeviceCommand sendConfig(String deviceId, Map<String, Object> config, Integer configVersion, String operator);
}