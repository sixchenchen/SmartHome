package com.womi.webmodule.service.device.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.DeviceControlRequest;
import com.womi.businessmodule.mapper.device.DeviceBindingMapper;
import com.womi.businessmodule.mapper.device.DeviceInfoMapper;
import com.womi.businessmodule.model.device.DeviceBinding;
import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.service.common.CommandSender;
import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.businessmodule.service.device.DeviceInfoService;
import com.womi.businessmodule.vo.device.DeviceInfoVO;
import com.womi.commonmodule.constants.DeviceCommandConstants;
import com.womi.commonmodule.constants.RedisConstants;
import com.womi.commonmodule.constants.ScheduleConstants;
import com.womi.commonmodule.enums.BindStatus;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.enums.DeviceOnlineStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.utils.MacUtils;
import com.womi.commonmodule.utils.TransactionUtils;
import com.womi.webmodule.service.device.DeviceUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceUserServiceImpl implements DeviceUserService {

    private final DeviceInfoMapper deviceInfoMapper;
    private final DeviceBindingMapper deviceBindingMapper;
    private final StringRedisTemplate redisTemplate;
    private final DeviceCommandService deviceCommandService;
    private final CommandSender commandSender;
    private final DeviceInfoService deviceInfoService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void bindDevice(Long userId, String deviceId, String bindCode) {
        String cleanMac = MacUtils.normalize(deviceId);
        // 1. 校验设备是否存在
        DeviceInfo device = deviceInfoMapper.selectOne(
                new LambdaQueryWrapper<DeviceInfo>().eq(DeviceInfo::getDeviceId, cleanMac));
        if (device == null) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_FOUND, ErrorCode.DEVICE_NOT_FOUND.getMessage());
        }

        // 2. 校验设备是否已被绑定
        if (bindCode == null || !bindCode.trim().equalsIgnoreCase(device.getBindCode())) {
            throw new BusinessException(ErrorCode.DEVICE_BINDING_CODE_ERROR, ErrorCode.DEVICE_BINDING_CODE_ERROR.getMessage());
        }
        // 先查一下给用户友好的提示
        DeviceBinding existingBinding = deviceBindingMapper.selectOne(
                new LambdaQueryWrapper<DeviceBinding>().eq(DeviceBinding::getActiveDeviceId, cleanMac));
        if (existingBinding != null) {
            if (existingBinding.getUserId().equals(userId)) {
                throw new BusinessException(ErrorCode.DEVICE_ALREADY_BOUND_SELF, "您已经绑定了该设备");
            } else {
                throw new BusinessException(ErrorCode.DEVICE_ALREADY_BOUND_OTHER, "该设备已被其他用户绑定");
            }
        }

        // 3. 执行绑定
        DeviceBinding binding = new DeviceBinding();
        binding.setDeviceId(cleanMac);
        binding.setUserId(userId);
        binding.setBindStatus(BindStatus.BOUND.getCode());
        binding.setBindTime(LocalDateTime.now());

        try {
            deviceBindingMapper.insert(binding);
        } catch (DuplicateKeyException e) {
            // 解决并发问题：如果两个用户同时点绑定，数据库唯一索引会拦住其中一个
            throw new BusinessException(ErrorCode.DEVICE_ALREADY_BOUND_OTHER, "该设备已被绑定，请刷新重试");
        }
        redisTemplate.opsForSet().add(RedisConstants.BOUND_DEVICES_KEY, cleanMac);
        log.info("用户绑定设备成功: userId={}, deviceId={}", userId, cleanMac);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void unbindDevice(Long userId, String deviceId) {
        // 1. 清洗 MAC 地址
        String cleanMac = MacUtils.normalize(deviceId);
        // 1. 查找有效的绑定记录
        DeviceBinding binding = deviceBindingMapper.selectOne(
                new LambdaQueryWrapper<DeviceBinding>()
                        .eq(DeviceBinding::getActiveDeviceId, cleanMac)
                        .eq(DeviceBinding::getUserId, userId));

        if (binding == null) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_BOUND, "您尚未绑定该设备，或已被解绑");
        }

        // 2. 更新为解绑状态
        // 更新后，数据库的 active_device_id 会自动变为 NULL，解除唯一锁定
        binding.setBindStatus(BindStatus.UNBOUND.getCode());
        binding.setUnbindTime(LocalDateTime.now());
        deviceBindingMapper.updateById(binding);
        redisTemplate.opsForSet().remove(RedisConstants.BOUND_DEVICES_KEY, cleanMac);
        log.info("用户解绑设备成功: userId={}, deviceId={}", userId, cleanMac);
    }

    @Override
    public Page<DeviceInfoVO> getMyDevices(Long userId, Integer pageNum, Integer pageSize) {
        // 1. 先查出该用户绑定的所有 deviceId
        List<DeviceBinding> bindings = deviceBindingMapper.selectList(
                new LambdaQueryWrapper<DeviceBinding>()
                        .eq(DeviceBinding::getUserId, userId)
                        .eq(DeviceBinding::getBindStatus, BindStatus.BOUND.getCode()));

        // 2. 构造目标分页对象
        Page<DeviceInfoVO> voPage = new Page<>(pageNum, pageSize);

        if (bindings.isEmpty()) {
            return voPage; // 直接返回空分页，无需后续查询
        }

        List<String> deviceIds = bindings.stream()
                .map(DeviceBinding::getDeviceId)
                .collect(Collectors.toList());

        // 3. 查询数据库实体分页
        Page<DeviceInfo> entityPage = deviceInfoMapper.selectPage(
                new Page<>(pageNum, pageSize),
                new LambdaQueryWrapper<DeviceInfo>().in(DeviceInfo::getDeviceId, deviceIds)
        );

        // 4. 将 Entity 分页数据转换为 VO 分页数据
        // 复制分页参数（total, current, size, pages 等元数据）
        voPage.setTotal(entityPage.getTotal());
        voPage.setPages(entityPage.getPages());

        // 转换 records 列表
        List<DeviceInfoVO> voList = entityPage.getRecords().stream().map(entity -> {
            DeviceInfoVO vo = new DeviceInfoVO();
            // 使用 Spring 自带的工具类拷贝同名属性，忽略 VO 中不存在的敏感字段
            BeanUtils.copyProperties(entity, vo);
            return vo;
        }).collect(Collectors.toList());

        voPage.setRecords(voList);

        return voPage;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void sendControlCommand(Long userId, DeviceControlRequest request) {
        String cleanMac = MacUtils.normalize(request.getDeviceId());

        // ==================== 1：校验设备是否存在（防报错） ====================
        List<DeviceInfo> devices = deviceInfoMapper.selectList(
                new LambdaQueryWrapper<DeviceInfo>()
                        .eq(DeviceInfo::getDeviceId, cleanMac)
                        .eq(DeviceInfo::getDeleted, 0) // 强制查未删除的
                        .last("LIMIT 1") // 只取一条
        );

        if (devices.isEmpty()) {
            throw new BusinessException(ErrorCode.DEVICE_NOT_FOUND, "设备不存在或已被删除");
        }
        DeviceInfo device = devices.get(0);

        // ==================== 场景 2：校验绑定关系（防越权） ====================
        DeviceBinding binding = deviceBindingMapper.selectOne(
                new LambdaQueryWrapper<DeviceBinding>()
                        .eq(DeviceBinding::getActiveDeviceId, cleanMac)
                        .eq(DeviceBinding::getUserId, userId));

        if (binding == null) {
            throw new BusinessException(ErrorCode.DEVICE_NO_PERMISSION, "您未绑定该设备，无权操作");
        }

        // ==================== 场景 3：校验在线状态 ====================
        if (!Integer.valueOf(DeviceOnlineStatus.ONLINE.getCode()).equals(device.getOnline())) {
            throw new BusinessException(ErrorCode.DEVICE_OFFLINE, "设备当前离线，请检查电源后重试");
        }

        // ==================== 场景 4：校验真实在线状态（防 LWT 延迟黑洞） ====================
        int timeoutSeconds = ScheduleConstants.HEARTBEAT_TIMEOUT_SECONDS;
        if (!deviceInfoService.isDeviceActuallyOnline(device, timeoutSeconds)) {
            throw new BusinessException(ErrorCode.DEVICE_NETWORK_ERROR, "设备已离线或网络异常，请检查电源后重试");
        }

        // ==================== 组装并下发指令 ====================
        LocalDateTime now = LocalDateTime.now();
        DeviceCommand cmd = new DeviceCommand();
        cmd.setCommandId(UUID.randomUUID().toString().replace("-", ""));
        cmd.setDeviceId(cleanMac);
        cmd.setAction(request.getAction());
        cmd.setTarget(request.getTarget());
        cmd.setChannel(request.getChannel());
        cmd.setParams(request.getParams());
        cmd.setQos(DeviceCommandConstants.DEFAULT_QOS);
        cmd.setRetain(DeviceCommandConstants.DEFAULT_RETAIN);
        cmd.setStatus(DeviceCommandStatus.PENDING.getCode());
        cmd.setRetryCount(DeviceCommandConstants.DEFAULT_RETRY_COUNT);
        cmd.setMaxRetry(DeviceCommandConstants.DEFAULT_MAX_RETRY);
        cmd.setOperator("user_" + userId);
        cmd.setSource(DeviceCommandConstants.SOURCE_WEB);
        cmd.setExpireTime(now.plusSeconds(DeviceCommandConstants.DEFAULT_EXPIRE_SECONDS));
        cmd.setCreateTime(now);
        cmd.setUpdateTime(now);

        deviceCommandService.save(cmd);

        // 立即通过 MQTT 下发
        TransactionUtils.afterCommit(() -> {
            try {
                commandSender.send(cmd);
                deviceCommandService.updateStatus(cmd.getId(), DeviceCommandStatus.SENT.getCode(), null);
                deviceCommandService.incrementRetryCount(cmd.getId());
                log.info("用户控制指令下发成功 - userId: {}, deviceId: {}, commandId: {}", userId, cleanMac, cmd.getCommandId());
            } catch (Exception e) {
                log.error("用户控制指令下发失败，等待定时任务兜底 - commandId: {}", cmd.getCommandId(), e);
            }
        });
    }

}