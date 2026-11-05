package com.womi.webmodule.service.mqtt.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.mapper.device.DeviceInfoMapper;
import com.womi.businessmodule.mapper.device.DeviceOtaTaskMapper;
import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.model.device.DeviceOtaTask;
import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.businessmodule.vo.device.OtaTaskDetailVO;
import com.womi.businessmodule.vo.device.OtaTaskDeviceVO;
import com.womi.businessmodule.vo.device.OtaTaskVO;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.service.mqtt.AdminOtaTaskService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
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
public class AdminOtaTaskServiceImpl implements AdminOtaTaskService {

    private static final String PARAM_TASK_ID = "taskId";

    private final DeviceOtaTaskMapper deviceOtaTaskMapper;
    private final DeviceCommandService deviceCommandService;
    private final DeviceInfoMapper deviceInfoMapper;

    @Override
    public Page<OtaTaskVO> pageTasks(Integer pageNum, Integer pageSize, Integer status) {
        Page<DeviceOtaTask> page = deviceOtaTaskMapper.selectPage(new Page<>(pageNum, pageSize),
                new LambdaQueryWrapper<DeviceOtaTask>()
                        .eq(status != null, DeviceOtaTask::getStatus, status)
                        .orderByDesc(DeviceOtaTask::getCreateTime));
        Page<OtaTaskVO> result = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        result.setRecords(page.getRecords().stream().map(this::toVO).collect(Collectors.toList()));
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public OtaTaskDetailVO getTaskDetail(Long id) {
        DeviceOtaTask task = requireTask(id);
        List<DeviceCommand> commands = loadTaskCommands(task);

        int success = 0;
        int failed = 0;
        int pending = 0;
        for (DeviceCommand command : commands) {
            DeviceCommandStatus status = DeviceCommandStatus.fromCode(command.getStatus());
            if (status == DeviceCommandStatus.SUCCESS) {
                success++;
            } else if (status == DeviceCommandStatus.FAILED || status == DeviceCommandStatus.TIMEOUT) {
                failed++;
            } else {
                pending++;
            }
        }

        OtaTaskDetailVO vo = new OtaTaskDetailVO();
        BeanUtils.copyProperties(task, vo);
        vo.setSuccessCount(success);
        vo.setFailedCount(failed);
        vo.setPendingCount(pending);
        if (task.getStatus() == null || task.getStatus() != 2) {
            vo.setStatus(pending == 0 ? 1 : 0);
        }

        // 回写统计，保证列表数据与详情一致
        DeviceOtaTask update = new DeviceOtaTask();
        update.setId(task.getId());
        update.setSuccessCount(success);
        update.setFailedCount(failed);
        update.setPendingCount(pending);
        update.setStatus(vo.getStatus());
        update.setUpdateTime(LocalDateTime.now());
        deviceOtaTaskMapper.updateById(update);

        Map<String, DeviceInfo> deviceMap = loadDeviceMap(commands);
        List<OtaTaskDeviceVO> devices = new ArrayList<>();
        for (DeviceCommand command : commands) {
            OtaTaskDeviceVO item = new OtaTaskDeviceVO();
            item.setDeviceId(command.getDeviceId());
            item.setCommandStatus(command.getStatus());
            DeviceCommandStatus status = DeviceCommandStatus.fromCode(command.getStatus());
            item.setCommandStatusText(status == null ? null : status.getMessage());
            item.setErrorMsg(command.getErrorMsg());
            item.setUpdateTime(command.getUpdateTime());
            DeviceInfo device = deviceMap.get(command.getDeviceId());
            if (device != null) {
                item.setDeviceName(device.getDeviceName());
                item.setFirmware(device.getFirmware());
                item.setOtaState(device.getOtaState());
                item.setOtaProgress(device.getOtaProgress());
            }
            devices.add(item);
        }
        vo.setDevices(devices);
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int cancelTask(Long id, String operator) {
        DeviceOtaTask task = requireTask(id);
        if (task.getStatus() != null && task.getStatus() == 2) {
            throw new BusinessException(ErrorCode.PARAM_INVALID, "任务已取消");
        }
        List<DeviceCommand> commands = loadTaskCommands(task);
        int cancelled = 0;
        for (DeviceCommand command : commands) {
            if (command.getStatus() != null && command.getStatus() == DeviceCommandStatus.PENDING.getCode()) {
                deviceCommandService.updateStatus(command.getId(), DeviceCommandStatus.CANCELLED.getCode(),
                        "任务已被 " + operator + " 取消");
                cancelled++;
            }
        }
        if (cancelled == 0) {
            throw new BusinessException(ErrorCode.PARAM_INVALID, "没有可取消的待下发子任务");
        }

        DeviceOtaTask update = new DeviceOtaTask();
        update.setId(task.getId());
        update.setStatus(2);
        update.setPendingCount(Math.max(0, (task.getPendingCount() == null ? 0 : task.getPendingCount()) - cancelled));
        update.setUpdateTime(LocalDateTime.now());
        deviceOtaTaskMapper.updateById(update);
        return cancelled;
    }

    private DeviceOtaTask requireTask(Long id) {
        DeviceOtaTask task = deviceOtaTaskMapper.selectById(id);
        if (task == null) {
            throw new BusinessException(ErrorCode.PARAM_INVALID, "OTA 任务不存在");
        }
        return task;
    }

    private List<DeviceCommand> loadTaskCommands(DeviceOtaTask task) {
        if (task.getCreateTime() == null) {
            return Collections.emptyList();
        }
        List<DeviceCommand> commands = deviceCommandService.list(new LambdaQueryWrapper<DeviceCommand>()
                .eq(DeviceCommand::getTarget, DeviceMqttConstants.TARGET_OTA)
                .ge(DeviceCommand::getCreateTime, task.getCreateTime().minusSeconds(5))
                .orderByAsc(DeviceCommand::getCreateTime));
        return commands.stream()
                .filter(command -> command.getParams() != null
                        && task.getTaskId().equals(String.valueOf(command.getParams().get(PARAM_TASK_ID))))
                .collect(Collectors.toList());
    }

    private Map<String, DeviceInfo> loadDeviceMap(List<DeviceCommand> commands) {
        List<String> deviceIds = commands.stream().map(DeviceCommand::getDeviceId).distinct().collect(Collectors.toList());
        if (deviceIds.isEmpty()) {
            return Collections.emptyMap();
        }
        return deviceInfoMapper.selectList(new LambdaQueryWrapper<DeviceInfo>()
                        .in(DeviceInfo::getDeviceId, deviceIds))
                .stream().collect(Collectors.toMap(DeviceInfo::getDeviceId, Function.identity(), (a, b) -> a));
    }

    private OtaTaskVO toVO(DeviceOtaTask task) {
        OtaTaskVO vo = new OtaTaskVO();
        BeanUtils.copyProperties(task, vo);
        return vo;
    }
}
