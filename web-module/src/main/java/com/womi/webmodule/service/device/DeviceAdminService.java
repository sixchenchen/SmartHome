package com.womi.webmodule.service.device;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.DeviceCreateRequest;
import com.womi.businessmodule.model.device.DeviceInfo;

public interface DeviceAdminService {

    Page<DeviceInfo> pageDevices(Integer pageNum, Integer pageSize, String keyword);

    void createDevice(DeviceCreateRequest request);

    void deleteDevice(Long id);
}