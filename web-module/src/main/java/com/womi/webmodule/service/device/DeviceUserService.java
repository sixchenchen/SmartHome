package com.womi.webmodule.service.device;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.DeviceControlRequest;
import com.womi.businessmodule.model.device.DeviceInfo;

public interface DeviceUserService {
    /** 绑定设备 */
    void bindDevice(Long userId, String deviceId);

    /** 解绑设备 */
    void unbindDevice(Long userId, String deviceId);

    /** 查询我的设备 */
    Page<DeviceInfo> getMyDevices(Long userId, Integer pageNum, Integer pageSize);

    void sendControlCommand(Long userId, DeviceControlRequest request);
}