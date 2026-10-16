package com.womi.businessmodule.service.device;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.commonmodule.enums.DeviceOfflineReason;

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
    void markOffline(String deviceId, DeviceOfflineReason reason);

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

    /**
     * 同步设备固件版本为目标版本（幂等）
     * <p>OTA 的"双保险"收口方法：ACK 与 ota_progress 两条路径都调用它，
     * 只有当前 firmware 与目标版本不一致时才更新，避免重复写与整行覆盖。</p>
     *
     * @param deviceId      设备ID
     * @param targetVersion 目标版本（为空/空白则不处理）
     * @return 是否真正发生了版本更新
     */
    boolean syncFirmwareIfTarget(String deviceId, String targetVersion);

    /**
     * 设备上线后的 OTA 结果校验兜底
     * <p>设备上报 success 后重启，若实际运行版本与目标版本不一致，说明升级回滚，判定为失败。</p>
     *
     * @param deviceId         设备ID
     * @param reportedFirmware 上线报文里上报的实际运行版本
     */
    void reconcileOtaOnOnline(String deviceId, String reportedFirmware);

    /**
     * 清理设备 OTA 状态（定向更新，只清 ota_state/ota_progress）
     */
    void clearOtaState(String deviceId);
}