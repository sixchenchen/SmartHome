package com.womi.businessmodule.service.device;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.device.DeviceEventRecord;

import java.util.List;

public interface DeviceEventRecordService extends IService<DeviceEventRecord> {

    /**
     * 保存事件
     */
    void recordEvent(DeviceEventRecord event);

    /**
     * 查询设备最近事件
     */
    List<DeviceEventRecord> listRecentByDevice(String deviceId, int limit);
}