package com.womi.webmodule.service.ops.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.mapper.device.DeviceAlertRecordMapper;
import com.womi.businessmodule.mapper.device.DeviceCommandMapper;
import com.womi.businessmodule.mapper.device.DeviceInfoMapper;
import com.womi.businessmodule.model.device.DeviceAlertRecord;
import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.vo.DashboardSummaryVO;
import com.womi.commonmodule.constants.DeviceOtaStateConstants;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.enums.DeviceOnlineStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.service.ops.AdminOpsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AdminOpsServiceImpl implements AdminOpsService {

    private final DeviceInfoMapper deviceInfoMapper;
    private final DeviceCommandMapper deviceCommandMapper;
    private final DeviceAlertRecordMapper deviceAlertRecordMapper;

    @Override
    public DashboardSummaryVO getDashboardSummary() {
        DashboardSummaryVO vo = new DashboardSummaryVO();
        long total = deviceInfoMapper.selectCount(new LambdaQueryWrapper<>());
        long online = deviceInfoMapper.selectCount(new LambdaQueryWrapper<DeviceInfo>()
                .eq(DeviceInfo::getOnline, DeviceOnlineStatus.ONLINE.getCode()));
        long otaRunning = deviceInfoMapper.selectCount(new LambdaQueryWrapper<DeviceInfo>()
                .in(DeviceInfo::getOtaState, DeviceOtaStateConstants.RUNNING_STATES));

        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        long todayCommands = deviceCommandMapper.selectCount(new LambdaQueryWrapper<DeviceCommand>()
                .ge(DeviceCommand::getCreateTime, todayStart));
        long todayFailed = deviceCommandMapper.selectCount(new LambdaQueryWrapper<DeviceCommand>()
                .ge(DeviceCommand::getCreateTime, todayStart)
                .in(DeviceCommand::getStatus,
                        DeviceCommandStatus.FAILED.getCode(), DeviceCommandStatus.TIMEOUT.getCode()));
        long unhandledAlerts = deviceAlertRecordMapper.selectCount(new LambdaQueryWrapper<DeviceAlertRecord>()
                .eq(DeviceAlertRecord::getStatus, 0));

        vo.setDeviceTotal(total);
        vo.setOnlineCount(online);
        vo.setOfflineCount(total - online);
        vo.setTodayCommandCount(todayCommands);
        vo.setTodayFailedCount(todayFailed);
        vo.setFailureRate(todayCommands == 0 ? 0.0
                : BigDecimal.valueOf(todayFailed * 100.0 / todayCommands).setScale(2, RoundingMode.HALF_UP).doubleValue());
        vo.setOtaRunningCount(otaRunning);
        vo.setUnhandledAlertCount(unhandledAlerts);
        return vo;
    }

    @Override
    public Page<DeviceCommand> pageCommands(Integer pageNum, Integer pageSize, String deviceId, Integer status,
                                            LocalDateTime from, LocalDateTime to) {
        LambdaQueryWrapper<DeviceCommand> wrapper = new LambdaQueryWrapper<DeviceCommand>()
                .eq(StringUtils.hasText(deviceId), DeviceCommand::getDeviceId, deviceId)
                .eq(status != null, DeviceCommand::getStatus, status)
                .ge(from != null, DeviceCommand::getCreateTime, from)
                .le(to != null, DeviceCommand::getCreateTime, to)
                .orderByDesc(DeviceCommand::getCreateTime);
        return deviceCommandMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    @Override
    public Page<DeviceAlertRecord> pageAlerts(Integer pageNum, Integer pageSize, String deviceId, Integer status,
                                              Integer level, LocalDateTime from, LocalDateTime to) {
        LambdaQueryWrapper<DeviceAlertRecord> wrapper = new LambdaQueryWrapper<DeviceAlertRecord>()
                .eq(StringUtils.hasText(deviceId), DeviceAlertRecord::getDeviceId, deviceId)
                .eq(status != null, DeviceAlertRecord::getStatus, status)
                .eq(level != null, DeviceAlertRecord::getAlertLevel, level)
                .ge(from != null, DeviceAlertRecord::getTimestamp, from)
                .le(to != null, DeviceAlertRecord::getTimestamp, to)
                .orderByDesc(DeviceAlertRecord::getTimestamp);
        return deviceAlertRecordMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    @Override
    public Page<DeviceCommand> pageAuditLogs(Integer pageNum, Integer pageSize, String deviceId, String operator,
                                             String source, LocalDateTime from, LocalDateTime to) {
        LambdaQueryWrapper<DeviceCommand> wrapper = new LambdaQueryWrapper<DeviceCommand>()
                .eq(StringUtils.hasText(deviceId), DeviceCommand::getDeviceId, deviceId)
                .like(StringUtils.hasText(operator), DeviceCommand::getOperator, operator)
                .eq(StringUtils.hasText(source), DeviceCommand::getSource, source)
                .ge(from != null, DeviceCommand::getCreateTime, from)
                .le(to != null, DeviceCommand::getCreateTime, to)
                .orderByDesc(DeviceCommand::getCreateTime);
        return deviceCommandMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleAlert(Long id, Integer status, String operator) {
        DeviceAlertRecord alert = deviceAlertRecordMapper.selectById(id);
        if (alert == null) {
            throw new BusinessException(ErrorCode.PARAM_INVALID, "告警不存在");
        }
        alert.setStatus(status);
        alert.setHandledBy(operator);
        alert.setHandledTime(LocalDateTime.now());
        deviceAlertRecordMapper.updateById(alert);
    }
}
