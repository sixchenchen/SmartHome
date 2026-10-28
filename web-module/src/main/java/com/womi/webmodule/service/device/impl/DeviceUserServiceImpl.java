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
import com.womi.commonmodule.constants.RedisConstants;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.utils.MacUtils;
import com.womi.webmodule.service.device.DeviceUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void bindDevice(Long userId, String deviceId,String bindCode) {
        String cleanMac = MacUtils.normalize(deviceId);
        // 1. 校验设备是否存在
        DeviceInfo device = deviceInfoMapper.selectOne(
                new LambdaQueryWrapper<DeviceInfo>().eq(DeviceInfo::getDeviceId, cleanMac));
        if (device == null) {
            throw new BusinessException(400, "设备不存在，请检查MAC地址是否正确");
        }

        // 2. 校验设备是否已被绑定
        if (bindCode == null || !bindCode.trim().equalsIgnoreCase(device.getBindCode())) {
            throw new BusinessException(403, "设备绑定码错误，请扫描设备机身上的二维码");
        }
        // 先查一下给用户友好的提示
        DeviceBinding existingBinding = deviceBindingMapper.selectOne(
                new LambdaQueryWrapper<DeviceBinding>().eq(DeviceBinding::getActiveDeviceId, cleanMac));
        if (existingBinding != null) {
            if (existingBinding.getUserId().equals(userId)) {
                throw new BusinessException(400, "您已经绑定了该设备");
            } else {
                throw new BusinessException(400, "该设备已被其他用户绑定");
            }
        }

        // 3. 执行绑定
        DeviceBinding binding = new DeviceBinding();
        binding.setDeviceId(cleanMac);
        binding.setUserId(userId);
        binding.setBindStatus(1);
        binding.setBindTime(LocalDateTime.now());

        try {
            deviceBindingMapper.insert(binding);
        } catch (DuplicateKeyException e) {
            // 解决并发问题：如果两个用户同时点绑定，数据库唯一索引会拦住其中一个
            throw new BusinessException(400, "该设备已被绑定，请刷新重试");
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
            throw new BusinessException(400, "您尚未绑定该设备，或已被解绑");
        }

        // 2. 更新为解绑状态
        // 更新后，数据库的 active_device_id 会自动变为 NULL，解除唯一锁定
        binding.setBindStatus(0);
        binding.setUnbindTime(LocalDateTime.now());
        deviceBindingMapper.updateById(binding);
        redisTemplate.opsForSet().remove(RedisConstants.BOUND_DEVICES_KEY, cleanMac);
        log.info("用户解绑设备成功: userId={}, deviceId={}", userId, cleanMac);
    }

    @Override
    public Page<DeviceInfo> getMyDevices(Long userId, Integer pageNum, Integer pageSize) {
        // 1. 先查出该用户绑定的所有 deviceId
        List<DeviceBinding> bindings = deviceBindingMapper.selectList(
                new LambdaQueryWrapper<DeviceBinding>()
                        .eq(DeviceBinding::getUserId, userId)
                        .eq(DeviceBinding::getBindStatus, 1));

        Page<DeviceInfo> page = new Page<>(pageNum, pageSize);

        if (bindings.isEmpty()) {
            return page; // 返回空分页
        }

        List<String> deviceIds = bindings.stream()
                .map(DeviceBinding::getDeviceId)
                .collect(Collectors.toList());

        // 2. 根据 deviceId 集合查询设备详情并分页
        return deviceInfoMapper.selectPage(page,
                new LambdaQueryWrapper<DeviceInfo>().in(DeviceInfo::getDeviceId, deviceIds));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void sendControlCommand(Long userId, DeviceControlRequest request) {
        String cleanMac = MacUtils.normalize(request.getDeviceId());

        // ==================== 场景 1：校验绑定关系（防越权） ====================
        DeviceInfo device = deviceInfoMapper.selectOne(
                new LambdaQueryWrapper<DeviceInfo>().eq(DeviceInfo::getDeviceId, cleanMac));

        if (device == null) {
            throw new BusinessException(400, "设备不存在");
        }

        DeviceBinding binding = deviceBindingMapper.selectOne(
                new LambdaQueryWrapper<DeviceBinding>()
                        .eq(DeviceBinding::getActiveDeviceId, cleanMac)
                        .eq(DeviceBinding::getUserId, userId));

        if (binding == null) {
            throw new BusinessException(403, "您未绑定该设备，无权操作");
        }

        // ==================== 场景 4：校验在线状态 ====================
        if (device.getOnline() != 1) {
            throw new BusinessException(400, "设备当前离线，请检查电源后重试");
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
        cmd.setQos(1); // 控制指令建议 QoS 1
        cmd.setRetain(0);
        cmd.setStatus(DeviceCommandStatus.PENDING.getCode());
        cmd.setRetryCount(0);
        cmd.setMaxRetry(3);
        cmd.setOperator("user_" + userId);
        cmd.setSource("APP");
        cmd.setExpireTime(now.plusSeconds(30)); // 控制指令过期时间设短一点，30秒
        cmd.setCreateTime(now);
        cmd.setUpdateTime(now);

        deviceCommandService.save(cmd);

        // 立即通过 MQTT 下发
        try {
            commandSender.send(cmd);
            deviceCommandService.updateStatus(cmd.getId(), DeviceCommandStatus.SENT.getCode(), null);
            deviceCommandService.incrementRetryCount(cmd.getId());
            log.info("用户控制指令下发成功 - userId: {}, deviceId: {}, commandId: {}", userId, cleanMac, cmd.getCommandId());
        } catch (Exception e) {
            log.error("用户控制指令下发失败 - commandId: {}", cmd.getCommandId(), e);
            throw new BusinessException(500, "指令下发失败，请稍后重试");
        }
    }
}