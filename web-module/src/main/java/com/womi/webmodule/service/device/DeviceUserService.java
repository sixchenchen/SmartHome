package com.womi.webmodule.service.device;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.DeviceBatchControlRequest;
import com.womi.businessmodule.dto.DeviceControlRequest;
import com.womi.businessmodule.dto.UserDeviceUpdateRequest;
import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.vo.CommandStatsVO;
import com.womi.businessmodule.vo.device.DeviceDetailVO;
import com.womi.businessmodule.vo.device.DeviceInfoVO;
import com.womi.businessmodule.vo.device.DeviceOnlineVO;

import java.util.List;

public interface DeviceUserService {
    /** 绑定设备 */
    void bindDevice(Long userId, String deviceId, String bindCode);

    /** 解绑设备 */
    void unbindDevice(Long userId, String deviceId);

    /** 查询我的设备 */
    Page<DeviceInfoVO> getMyDevices(Long userId, Integer pageNum, Integer pageSize);

    /** 控制设备，返回 commandId */
    String sendControlCommand(Long userId, DeviceControlRequest request);

    /** 设备详情（仅可查看已绑定设备） */
    DeviceDetailVO getDeviceDetail(Long userId, String deviceId);

    /** 设备在线状态 */
    DeviceOnlineVO getOnlineStatus(Long userId, String deviceId);

    /** 修改设备名称/位置 */
    void updateDevice(Long userId, String deviceId, UserDeviceUpdateRequest request);

    /** 我的指令分页 */
    Page<DeviceCommand> pageCommands(Long userId, String deviceId, Integer status, Integer pageNum, Integer pageSize);

    /** 指令详情 */
    DeviceCommand getCommand(Long userId, String commandId);

    /** 取消未下发指令 */
    boolean cancelCommand(Long userId, Long id);

    /** 按 commandId 取消未下发指令 */
    boolean cancelCommandByCommandId(Long userId, String commandId);

    /** 设备指令统计 */
    CommandStatsVO getCommandStats(Long userId, String deviceId);

    /** 批量控制（单设备多指令） */
    List<String> batchControl(Long userId, String deviceId, DeviceBatchControlRequest request);

    /** 校验设备归属并返回设备实体 */
    DeviceInfo requireBoundDevice(Long userId, String deviceId);
}
