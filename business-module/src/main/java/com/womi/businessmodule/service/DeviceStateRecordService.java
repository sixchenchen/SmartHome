package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.DeviceStateRecord;

import java.time.LocalDateTime;
import java.util.List;

public interface DeviceStateRecordService extends IService<DeviceStateRecord> {

    /**
     * 保存状态变更
     */
    void recordState(String deviceId, String target, Integer channel,
                     java.util.Map<String, Object> params, LocalDateTime timestamp);

    /**
     * 查询设备的某外设历史
     */
    List<DeviceStateRecord> listByDeviceAndTarget(String deviceId, String target,
                                                  LocalDateTime start, LocalDateTime end);

    /**
     * 清理历史
     */
    int cleanHistory(int retentionDays);
}