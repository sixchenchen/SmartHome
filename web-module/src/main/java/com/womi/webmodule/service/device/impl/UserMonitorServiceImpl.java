package com.womi.webmodule.service.device.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.mapper.device.DeviceAlertRecordMapper;
import com.womi.businessmodule.mapper.device.DeviceBindingMapper;
import com.womi.businessmodule.mapper.device.DeviceEventRecordMapper;
import com.womi.businessmodule.mapper.device.DeviceSensorMapper;
import com.womi.businessmodule.mapper.device.DeviceSensorRecordMapper;
import com.womi.businessmodule.mapper.device.DeviceStateRecordMapper;
import com.womi.businessmodule.model.device.DeviceAlertRecord;
import com.womi.businessmodule.model.device.DeviceBinding;
import com.womi.businessmodule.model.device.DeviceEventRecord;
import com.womi.businessmodule.model.device.DeviceSensor;
import com.womi.businessmodule.model.device.DeviceSensorRecord;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.model.device.DeviceStateRecord;
import com.womi.businessmodule.vo.device.SensorLatestVO;
import com.womi.commonmodule.enums.BindStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.service.device.DeviceUserService;
import com.womi.webmodule.service.device.UserMonitorService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserMonitorServiceImpl implements UserMonitorService {

    private final DeviceUserService deviceUserService;
    private final DeviceBindingMapper deviceBindingMapper;
    private final DeviceSensorMapper deviceSensorMapper;
    private final DeviceSensorRecordMapper deviceSensorRecordMapper;
    private final DeviceEventRecordMapper deviceEventRecordMapper;
    private final DeviceStateRecordMapper deviceStateRecordMapper;
    private final DeviceAlertRecordMapper deviceAlertRecordMapper;

    @Override
    public Page<DeviceSensorRecord> pageSensorRecords(Long userId, String deviceId, String sensorKey, String sensorType,
                                                      LocalDateTime from, LocalDateTime to,
                                                      Integer pageNum, Integer pageSize) {
        DeviceInfo device = deviceUserService.requireBoundDevice(userId, deviceId);
        LambdaQueryWrapper<DeviceSensorRecord> wrapper = new LambdaQueryWrapper<DeviceSensorRecord>()
                .eq(DeviceSensorRecord::getDeviceId, device.getDeviceId())
                .eq(sensorKey != null && !sensorKey.isBlank(), DeviceSensorRecord::getSensorKey, sensorKey)
                .eq(sensorType != null && !sensorType.isBlank(), DeviceSensorRecord::getSensorType, sensorType)
                .ge(from != null, DeviceSensorRecord::getTimestamp, from)
                .le(to != null, DeviceSensorRecord::getTimestamp, to)
                .orderByDesc(DeviceSensorRecord::getTimestamp);
        return deviceSensorRecordMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    @Override
    public List<SensorLatestVO> listLatestSensors(Long userId, String deviceId) {
        DeviceInfo device = deviceUserService.requireBoundDevice(userId, deviceId);

        QueryWrapper<DeviceSensorRecord> latestWrapper = new QueryWrapper<DeviceSensorRecord>()
                .select("sensor_key", "MAX(id) AS max_id")
                .eq("device_id", device.getDeviceId())
                .groupBy("sensor_key");
        List<Map<String, Object>> rows = deviceSensorRecordMapper.selectMaps(latestWrapper);
        if (rows.isEmpty()) {
            return Collections.emptyList();
        }
        List<Long> ids = rows.stream()
                .map(row -> ((Number) row.get("max_id")).longValue())
                .collect(Collectors.toList());
        List<DeviceSensorRecord> records = deviceSensorRecordMapper.selectBatchIds(ids);

        Map<String, DeviceSensor> sensorMeta = deviceSensorMapper.selectList(
                        new LambdaQueryWrapper<DeviceSensor>().eq(DeviceSensor::getDeviceId, device.getDeviceId()))
                .stream().collect(Collectors.toMap(DeviceSensor::getSensorKey, Function.identity(), (a, b) -> a));

        List<SensorLatestVO> result = new ArrayList<>();
        for (DeviceSensorRecord record : records) {
            SensorLatestVO vo = new SensorLatestVO();
            vo.setSensorKey(record.getSensorKey());
            vo.setSensorType(record.getSensorType());
            vo.setValue(record.getSensorValue());
            vo.setUnit(record.getUnit());
            vo.setTimestamp(record.getTimestamp());
            DeviceSensor meta = sensorMeta.get(record.getSensorKey());
            if (meta != null) {
                vo.setSensorName(meta.getSensorName());
                vo.setSensorType(meta.getSensorType());
                if (vo.getUnit() == null) {
                    vo.setUnit(meta.getUnit());
                }
            }
            result.add(vo);
        }
        return result;
    }

    @Override
    public Page<DeviceEventRecord> pageEvents(Long userId, String deviceId, String type,
                                              LocalDateTime from, LocalDateTime to,
                                              Integer pageNum, Integer pageSize) {
        DeviceInfo device = deviceUserService.requireBoundDevice(userId, deviceId);
        LambdaQueryWrapper<DeviceEventRecord> wrapper = new LambdaQueryWrapper<DeviceEventRecord>()
                .eq(DeviceEventRecord::getDeviceId, device.getDeviceId())
                .eq(type != null && !type.isBlank(), DeviceEventRecord::getType, type)
                .ge(from != null, DeviceEventRecord::getTimestamp, from)
                .le(to != null, DeviceEventRecord::getTimestamp, to)
                .orderByDesc(DeviceEventRecord::getTimestamp);
        return deviceEventRecordMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    @Override
    public Page<DeviceStateRecord> pageStates(Long userId, String deviceId,
                                              LocalDateTime from, LocalDateTime to,
                                              Integer pageNum, Integer pageSize) {
        DeviceInfo device = deviceUserService.requireBoundDevice(userId, deviceId);
        LambdaQueryWrapper<DeviceStateRecord> wrapper = new LambdaQueryWrapper<DeviceStateRecord>()
                .eq(DeviceStateRecord::getDeviceId, device.getDeviceId())
                .ge(from != null, DeviceStateRecord::getTimestamp, from)
                .le(to != null, DeviceStateRecord::getTimestamp, to)
                .orderByDesc(DeviceStateRecord::getTimestamp);
        return deviceStateRecordMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    @Override
    public Page<DeviceAlertRecord> pageAlerts(Long userId, String deviceId, Integer status, Integer level,
                                              LocalDateTime from, LocalDateTime to,
                                              Integer pageNum, Integer pageSize) {
        List<String> deviceIds = resolveBoundDeviceIds(userId, deviceId);
        Page<DeviceAlertRecord> page = new Page<>(pageNum, pageSize);
        if (deviceIds.isEmpty()) {
            return page;
        }
        LambdaQueryWrapper<DeviceAlertRecord> wrapper = new LambdaQueryWrapper<DeviceAlertRecord>()
                .in(DeviceAlertRecord::getDeviceId, deviceIds)
                .eq(status != null, DeviceAlertRecord::getStatus, status)
                .eq(level != null, DeviceAlertRecord::getAlertLevel, level)
                .ge(from != null, DeviceAlertRecord::getTimestamp, from)
                .le(to != null, DeviceAlertRecord::getTimestamp, to)
                .orderByDesc(DeviceAlertRecord::getTimestamp);
        return deviceAlertRecordMapper.selectPage(page, wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void ackAlert(Long userId, Long alertId, String operator) {
        DeviceAlertRecord alert = deviceAlertRecordMapper.selectById(alertId);
        if (alert == null) {
            throw new BusinessException(ErrorCode.PARAM_INVALID, "告警不存在");
        }
        deviceUserService.requireBoundDevice(userId, alert.getDeviceId());
        if (alert.getStatus() != null && alert.getStatus() == 2) {
            return;
        }
        alert.setStatus(1);
        alert.setHandledBy(operator);
        alert.setHandledTime(LocalDateTime.now());
        deviceAlertRecordMapper.updateById(alert);
    }

    private List<String> resolveBoundDeviceIds(Long userId, String deviceId) {
        if (deviceId != null && !deviceId.isBlank()) {
            return Collections.singletonList(deviceUserService.requireBoundDevice(userId, deviceId).getDeviceId());
        }
        return deviceBindingMapper.selectList(new LambdaQueryWrapper<DeviceBinding>()
                        .eq(DeviceBinding::getUserId, userId)
                        .eq(DeviceBinding::getBindStatus, BindStatus.BOUND.getCode()))
                .stream().map(DeviceBinding::getDeviceId).collect(Collectors.toList());
    }
}
