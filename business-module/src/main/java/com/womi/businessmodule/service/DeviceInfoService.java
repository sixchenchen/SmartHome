package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.DeviceInfo;
import com.womi.commonmodule.enums.OfflineReason;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public interface DeviceInfoService extends IService<DeviceInfo> {

    /**
     * 获取或创建设备
     */
    DeviceInfo getOrCreateDevice(String deviceId);

    /**
     * 根据 deviceId 查询
     */
    DeviceInfo getByDeviceId(String deviceId);

    /**
     * 标记设备上线
     */
    void markOnline(String deviceId, String product, String firmware, Map<String, Object> capabilities);

    /**
     * 标记设备离线
     */
    void markOffline(String deviceId, OfflineReason reason);

    /**
     * 更新心跳
     */
    void updateHeartbeat(String deviceId, Long uptime, String payload);

    /**
     * 查询心跳超时的在线设备
     */
    List<DeviceInfo> listHeartbeatTimeoutDevices(int timeoutSeconds);

    /**
     * 标记过期心跳设备离线
     */
    int markHeartbeatTimeoutOffline(int timeoutSeconds);
    /**
     * 更新 OTA 状态
     *
     * @param deviceId 设备ID
     * @param state    OTA 状态
     * @param progress 进度 0-100（可空）
     * @param version  目标版本（可空）
     */
    void updateOtaState(String deviceId, String state, Integer progress, String version);
}