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
import com.womi.commonmodule.constants.RegexConstants;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.utils.MacUtils;
import com.womi.webmodule.service.device.DeviceAdminService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceAdminServiceImpl implements DeviceAdminService {

    private final DeviceInfoMapper deviceInfoMapper;
    private final DeviceWhitelistMapper deviceWhitelistMapper;
    private final DeviceMqttAuthMapper deviceMqttAuthMapper;
    private final DeviceBindingMapper deviceBindingMapper;

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
            throw new BusinessException(400, "MAC地址格式不正确");
        }
        // 1. 校验 MAC 地址是否已存在
        Long count = deviceInfoMapper.selectCount(
                new LambdaQueryWrapper<DeviceInfo>().eq(DeviceInfo::getDeviceId, cleanMac)
        );
        if (count > 0) {
            throw new BusinessException(400, "设备MAC地址已存在");
        }

        // 2. 插入 device_info
        DeviceInfo device = new DeviceInfo();
        device.setDeviceId(cleanMac);
        device.setDeviceName(StringUtils.hasText(request.getDeviceName()) ? request.getDeviceName() : cleanMac);
        device.setProduct(request.getProduct());
        device.setLocation(request.getLocation());
        device.setOnline(0); // 默认离线
        deviceInfoMapper.insert(device);

        // 3. ：安全插入/更新 device_whitelist
        DeviceWhitelist existingWhitelist = deviceWhitelistMapper.selectOne(
                new LambdaQueryWrapper<DeviceWhitelist>().eq(DeviceWhitelist::getDeviceId, cleanMac)
        );

        if (existingWhitelist != null) {
            // 如果白名单已存在（比如之前是禁用的），直接恢复启用状态
            existingWhitelist.setEnabled(1);
            existingWhitelist.setRemark("管理员后台录入覆盖更新");
            deviceWhitelistMapper.updateById(existingWhitelist);
        } else {
            // 如果不存在，则新建
            DeviceWhitelist whitelist = new DeviceWhitelist();
            whitelist.setDeviceId(cleanMac);
            whitelist.setEnabled(1);
            whitelist.setRemark("管理员后台录入自动生成");
            deviceWhitelistMapper.insert(whitelist);
        }

        log.info("管理员创建设备成功: deviceId={}", cleanMac);
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

        log.info("管理员删除设备及关联数据成功: deviceId={}", mac);
    }
}