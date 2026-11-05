package com.womi.webmodule.service.device;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.model.device.DeviceAlertRecord;
import com.womi.businessmodule.model.device.DeviceEventRecord;
import com.womi.businessmodule.model.device.DeviceSensorRecord;
import com.womi.businessmodule.model.device.DeviceStateRecord;
import com.womi.businessmodule.vo.device.SensorLatestVO;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户侧设备数据监控服务（传感器/事件/状态/告警）
 */
public interface UserMonitorService {

    Page<DeviceSensorRecord> pageSensorRecords(Long userId, String deviceId, String sensorKey, String sensorType,
                                               LocalDateTime from, LocalDateTime to,
                                               Integer pageNum, Integer pageSize);

    List<SensorLatestVO> listLatestSensors(Long userId, String deviceId);

    Page<DeviceEventRecord> pageEvents(Long userId, String deviceId, String type,
                                       LocalDateTime from, LocalDateTime to,
                                       Integer pageNum, Integer pageSize);

    Page<DeviceStateRecord> pageStates(Long userId, String deviceId,
                                       LocalDateTime from, LocalDateTime to,
                                       Integer pageNum, Integer pageSize);

    Page<DeviceAlertRecord> pageAlerts(Long userId, String deviceId, Integer status, Integer level,
                                       LocalDateTime from, LocalDateTime to,
                                       Integer pageNum, Integer pageSize);

    void ackAlert(Long userId, Long alertId, String operator);
}
