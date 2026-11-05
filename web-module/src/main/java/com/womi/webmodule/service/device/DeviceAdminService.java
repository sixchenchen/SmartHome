package com.womi.webmodule.service.device;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.AdminDeviceCommandRequest;
import com.womi.businessmodule.dto.DeviceAdminUpdateRequest;
import com.womi.businessmodule.dto.DeviceCreateRequest;
import com.womi.businessmodule.vo.device.AdminDeviceVO;
import com.womi.businessmodule.vo.device.DeviceBindingVO;
import com.womi.businessmodule.vo.device.DeviceOnlineStatsVO;

import java.util.List;

public interface DeviceAdminService {

    Page<AdminDeviceVO> pageDevices(Integer pageNum, Integer pageSize, String keyword);

    void createDevice(DeviceCreateRequest request);

    void deleteDevice(Long id);

    /** 设备详情 */
    AdminDeviceVO getDevice(Long id);

    /** 编辑设备基础信息 */
    void updateDevice(Long id, DeviceAdminUpdateRequest request);

    /** 设备绑定用户列表 */
    Page<DeviceBindingVO> pageBindings(Long id, Integer pageNum, Integer pageSize);

    /** 管理员解绑指定用户 */
    void unbindDevice(Long id, Long userId);

    /** 在线统计 */
    DeviceOnlineStatsVO getOnlineStats();

    /** 管理员下发指令 */
    String sendCommand(Long id, AdminDeviceCommandRequest request);

    /** 导出数据源 */
    List<AdminDeviceVO> listForExport(String keyword);
}
