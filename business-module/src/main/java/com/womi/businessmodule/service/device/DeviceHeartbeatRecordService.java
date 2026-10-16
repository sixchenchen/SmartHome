package com.womi.businessmodule.service.device;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.device.DeviceHeartbeatRecord;

public interface DeviceHeartbeatRecordService extends IService<DeviceHeartbeatRecord> {

    /**
     * 保存心跳
     */
    void recordHeartbeat(String deviceId, Long uptime, String payload);

    /**
     * 清理历史心跳
     */
    int cleanHistory(int retentionDays);
}