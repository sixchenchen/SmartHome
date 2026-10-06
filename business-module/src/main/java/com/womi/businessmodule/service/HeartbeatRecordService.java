package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.HeartbeatRecord;

public interface HeartbeatRecordService extends IService<HeartbeatRecord> {

    /**
     * 保存心跳
     */
    void recordHeartbeat(String deviceId, Long uptime, String payload);

    /**
     * 清理历史心跳
     */
    int cleanHistory(int retentionDays);
}