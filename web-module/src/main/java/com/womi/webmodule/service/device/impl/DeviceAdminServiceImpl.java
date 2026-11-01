package com.womi.webmodule.service.device.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.DeviceCreateRequest;
import com.womi.businessmodule.mapper.device.DeviceBindingMapper;
import com.womi.businessmodule.mapper.device.DeviceInfoMapper;
import com.womi.businessmodule.mapper.device.DeviceMqttAuthMapper;
import com.womi.businessmodule.mapper.device.DeviceWhitelistMapper;
import com.womi.businessmodule.model.device.DeviceBinding;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.model.device.DeviceMqttAuth;
import com.womi.businessmodule.model.device.DeviceWhitelist;
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.commonmodule.constants.RedisConstants;
import com.womi.commonmodule.constants.RegexConstants;
import com.womi.commonmodule.enums.DeviceOnlineStatus;
import com.womi.commonmodule.enums.EnableStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.utils.MacUtils;
import com.womi.webmodule.service.device.DeviceAdminService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceAdminServiceImpl implements DeviceAdminService {

    private final DeviceInfoMapper deviceInfoMapper;
    private final DeviceWhitelistMapper deviceWhitelistMapper;
    private final DeviceMqttAuthMapper deviceMqttAuthMapper;
    private final DeviceBindingMapper deviceBindingMapper;
    private final StringRedisTemplate redisTemplate;

    @Override
    public Page<DeviceInfo> pageDevices(Integer pageNum, Integer pageSize, String keyword) {
        Page<DeviceInfo> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<DeviceInfo> wrapper = new LambdaQueryWrapper<>();

        if (StringUtils.hasText(keyword)) {
            wrapper.like(DeviceInfo::getDeviceId, keyword)
                    .or()
                    .like(DeviceInfo::getDeviceName, keyword);
        }
        wrapper.orderByDesc(DeviceInfo::getCreateTime);

        return deviceInfoMapper.selectPage(page, wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createDevice(DeviceCreateRequest request) {
        String cleanMac = MacUtils.normalize(request.getDeviceId());
        if (cleanMac == null || !cleanMac.matches(RegexConstants.MAC)) {
            throw new BusinessException(ErrorCode.MAC_FORMAT_ERROR, "MAC地址格式不正确");
        }

        // 1. 校验 MAC 地址是否已存在
        Long count = deviceInfoMapper.selectCount(
                new LambdaQueryWrapper<DeviceInfo>().eq(DeviceInfo::getDeviceId, cleanMac)
        );
        if (count > 0) {
            throw new BusinessException(ErrorCode.DEVICE_ALREADY_EXIST, ErrorCode.DEVICE_ALREADY_EXIST.getMessage());
        }

        // 2. 组装设备基本信息
        DeviceInfo device = new DeviceInfo();
        device.setDeviceId(cleanMac);
        device.setDeviceName(StringUtils.hasText(request.getDeviceName()) ? request.getDeviceName() : cleanMac);
        device.setProduct(request.getProduct());
        device.setLocation(request.getLocation());
        device.setOnline(DeviceOnlineStatus.OFFLINE.getCode());

        // 3. 生成 BindCode 并插入（带重试机制）
        int maxRetries = 3;
        boolean insertSuccess = false;

        for (int i = 0; i < maxRetries; i++) {
            // 每次循环生成新的 6 位大写随机码
            String bindCode = UUID.randomUUID().toString().substring(0, 6).toUpperCase();
            device.setBindCode(bindCode);

            try {
                deviceInfoMapper.insert(device);
                insertSuccess = true;
                break; // 插入成功，跳出循环
            } catch (DuplicateKeyException e) {
                // 判断是否是 bind_code 冲突
                if (e.getMessage() != null && e.getMessage().contains("uk_bind_code")) {
                    log.warn("生成 bind_code 发生碰撞，准备重试 - deviceId: {}, 碰撞的 bindCode: {}", cleanMac, bindCode);
                } else {
                    // 如果是其他唯一键冲突（如 device_id），说明并发插入发生了，直接抛出
                    throw new BusinessException(ErrorCode.DEVICE_ALREADY_EXIST, "设备已存在，请勿重复添加");
                }
            }
        }

        if (!insertSuccess) {
            log.error("设备创建失败：生成唯一 bind_code 重试次数耗尽 - deviceId: {}", cleanMac);
            throw new BusinessException(ErrorCode.SYSTEM_ERROR, "系统繁忙，设备绑定码生成失败，请重试");
        }

        // 4. 安全插入/更新 device_whitelist
        DeviceWhitelist existingWhitelist = deviceWhitelistMapper.selectOne(
                new LambdaQueryWrapper<DeviceWhitelist>().eq(DeviceWhitelist::getDeviceId, cleanMac)
        );

        if (existingWhitelist != null) {
            existingWhitelist.setEnabled(EnableStatus.ENABLED.getCode());
            existingWhitelist.setRemark(DeviceConstants.WHITELIST_REMARK_ADMIN_OVERRIDE);
            deviceWhitelistMapper.updateById(existingWhitelist);
        } else {
            DeviceWhitelist whitelist = new DeviceWhitelist();
            whitelist.setDeviceId(cleanMac);
            whitelist.setEnabled(EnableStatus.ENABLED.getCode());
            whitelist.setRemark(DeviceConstants.WHITELIST_REMARK_ADMIN_CREATE);
            deviceWhitelistMapper.insert(whitelist);
        }

        log.info("管理员创建设备成功: deviceId={}, bindCode={}", cleanMac, device.getBindCode());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteDevice(Long id) {
        DeviceInfo device = deviceInfoMapper.selectById(id);
        if (device == null) {
            return; // 设备不存在直接返回
        }
        String mac = device.getDeviceId();

        // 1. 删除 device_info
        deviceInfoMapper.deleteById(id);

        // 2. 删除 device_whitelist (防止设备死灰复燃)
        deviceWhitelistMapper.delete(
                new LambdaQueryWrapper<DeviceWhitelist>().eq(DeviceWhitelist::getDeviceId, mac)
        );

        // 3. 删除 device_mqtt_auth (废弃该设备的 MQTT 账号，防止继续连接)
        deviceMqttAuthMapper.delete(
                new LambdaQueryWrapper<DeviceMqttAuth>().eq(DeviceMqttAuth::getDeviceId, mac)
        );

        // 4. 删除 device_binding (强制解除用户与该设备的绑定关系)
        deviceBindingMapper.delete(
                new LambdaQueryWrapper<DeviceBinding>().eq(DeviceBinding::getDeviceId, mac)
        );
        // 5. 清理 Redis 缓存
        try {
            redisTemplate.opsForSet().remove(RedisConstants.BOUND_DEVICES_KEY, mac);
            log.info("已清理设备 Redis 绑定缓存 - deviceId={}", mac);
        } catch (Exception e) {
            // 注意：Redis 清理失败不应该影响数据库事务的回滚
            log.error("清理设备 Redis 绑定缓存失败 - deviceId={}", mac, e);
        }
        log.info("管理员删除设备及关联数据成功: deviceId={}", mac);
    }
}