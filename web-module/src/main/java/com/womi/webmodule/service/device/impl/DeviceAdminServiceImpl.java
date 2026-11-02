package com.womi.webmodule.service.device.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.dto.DeviceCreateRequest;
import com.womi.businessmodule.mapper.device.*;
import com.womi.businessmodule.model.device.*;
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

import java.time.LocalDateTime;
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
    private final DeviceSensorMapper deviceSensorMapper;
    private final DeviceSensorThresholdMapper deviceSensorThresholdMapper;
    private final DeviceSlaveDataMapper deviceSlaveDataMapper;
    private final DeviceCommandMapper deviceCommandMapper;
    private final DeviceSensorRecordMapper deviceSensorRecordMapper;
    private final DeviceEventRecordMapper deviceEventRecordMapper;
    private final DeviceHeartbeatRecordMapper deviceHeartbeatRecordMapper;
    private final DeviceStateRecordMapper deviceStateRecordMapper;
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
        DeviceInfo device = deviceInfoMapper.selectById(id); // MP 自动加 deleted=0
        if (device == null) {
            return;
        }
        String mac = device.getDeviceId();

        // ============================================================
        // 第 1 组：释放唯一索引占用（必须，否则同 MAC 重新注册必冲突）
        // ============================================================

        // 1.1 解绑（软解绑，保留绑定历史；同时释放 active_device_id 生成列唯一索引）
        deviceBindingMapper.update(null, new LambdaUpdateWrapper<DeviceBinding>()
                .eq(DeviceBinding::getDeviceId, mac)
                .eq(DeviceBinding::getBindStatus, 1)
                .set(DeviceBinding::getBindStatus, 0)
                .set(DeviceBinding::getUnbindTime, LocalDateTime.now()));

        // 1.2 物理删除 MQTT 账号（uk_device_id 唯一索引会卡重注册）
        deviceMqttAuthMapper.delete(new LambdaQueryWrapper<DeviceMqttAuth>()
                .eq(DeviceMqttAuth::getDeviceId, mac));

        // 1.3 物理删除白名单（防止死灰复燃，同时释放 uk_device_id）
        //     注意：删掉后同一 MAC 将无法再注册，若需支持换机重注册，改为 enabled=0
        deviceWhitelistMapper.delete(new LambdaQueryWrapper<DeviceWhitelist>()
                .eq(DeviceWhitelist::getDeviceId, mac));

        // 1.4 物理删除传感器元数据和阈值配置（释放 uk_device_sensor_key）
        //     若需要保留配置，需给这两张表加 deleted 字段并改复合唯一索引
        deviceSensorMapper.delete(new LambdaQueryWrapper<DeviceSensor>()
                .eq(DeviceSensor::getDeviceId, mac));
        deviceSensorThresholdMapper.delete(new LambdaQueryWrapper<DeviceSensorThreshold>()
                .eq(DeviceSensorThreshold::getDeviceId, mac));

        // ============================================================
        // 第 2 组：清理运行时/时序数据（防止孤儿数据）
        //   按业务需要可选择性保留：如果要保留审计历史，注释掉对应行即可
        // ============================================================

        // 2.1 从机在线数据（表注释说"离线即删除"，设备删了必须清）
        deviceSlaveDataMapper.delete(new LambdaQueryWrapper<DeviceSlaveData>()
                .eq(DeviceSlaveData::getDeviceId, mac));

        // 2.2 指令记录（临时性数据，清掉；如需审计可注释）
        deviceCommandMapper.delete(new LambdaQueryWrapper<DeviceCommand>()
                .eq(DeviceCommand::getDeviceId, mac));

        // 2.3 传感器历史数据（量大，设备删了业务上无查询意义，清掉）
        deviceSensorRecordMapper.delete(new LambdaQueryWrapper<DeviceSensorRecord>()
                .eq(DeviceSensorRecord::getDeviceId, mac));

        // 2.4 事件 / 心跳 / 状态时序（同上，按需保留）
        deviceEventRecordMapper.delete(new LambdaQueryWrapper<DeviceEventRecord>()
                .eq(DeviceEventRecord::getDeviceId, mac));
        deviceHeartbeatRecordMapper.delete(new LambdaQueryWrapper<DeviceHeartbeatRecord>()
                .eq(DeviceHeartbeatRecord::getDeviceId, mac));
        deviceStateRecordMapper.delete(new LambdaQueryWrapper<DeviceStateRecord>()
                .eq(DeviceStateRecord::getDeviceId, mac));

        // ============================================================
        // 第 3 组：软删除设备主记录（最后执行）
        // ============================================================
        deviceInfoMapper.deleteById(id);   // MP 自动 UPDATE deleted=id

        // ============================================================
        // 第 4 组：Redis 缓存清理（放最后，异常不影响事务）
        // ============================================================
        try {
            redisTemplate.opsForSet().remove(RedisConstants.BOUND_DEVICES_KEY, mac);
            log.info("已清理设备 Redis 绑定缓存 - deviceId={}", mac);
        } catch (Exception e) {
            log.error("清理设备 Redis 绑定缓存失败 - deviceId={}", mac, e);
        }

        log.info("管理员删除设备及关联数据成功: deviceId={}, id={}", mac, id);
    }
}