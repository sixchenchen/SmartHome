package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.MqttAuthMapper;
import com.womi.businessmodule.model.MqttAuth;
import com.womi.businessmodule.service.MqttAuthService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Service
public class MqttAuthServiceImpl
        extends ServiceImpl<MqttAuthMapper, MqttAuth>
        implements MqttAuthService {

    @Override
    public MqttAuth getByUsername(String username) {
        return getOne(new LambdaQueryWrapper<MqttAuth>()
                .eq(MqttAuth::getUsername, username)
                .last("LIMIT 1"));
    }

    @Override
    public MqttAuth getByDeviceId(String deviceId) {
        return getOne(new LambdaQueryWrapper<MqttAuth>()
                .eq(MqttAuth::getDeviceId, deviceId)
                .last("LIMIT 1"));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveOrUpdateDeviceAuth(String deviceId, String username, String password, String salt, Integer enabled) {
        MqttAuth auth = getByDeviceId(deviceId);
        LocalDateTime now = LocalDateTime.now();
        if (auth == null) {
            auth = new MqttAuth();
            auth.setDeviceId(deviceId);
            auth.setUsername(username);
            auth.setPassword(password);
            auth.setSalt(salt);
            auth.setIsSuperuser(0);
            auth.setEnabled(enabled);
            auth.setCreateTime(now);
            auth.setUpdateTime(now);
            save(auth);
            log.info("新增设备MQTT认证 - deviceId: {}, username: {}", deviceId, username);
        } else {
            auth.setUsername(username);
            auth.setPassword(password);
            auth.setSalt(salt);
            auth.setEnabled(enabled);
            auth.setUpdateTime(now);
            updateById(auth);
            log.info("更新设备MQTT认证 - deviceId: {}, username: {}", deviceId, username);
        }
    }
}