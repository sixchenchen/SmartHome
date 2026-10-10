package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.MqttAuth;

public interface MqttAuthService extends IService<MqttAuth> {

    /**
     * 根据用户名查询认证信息
     */
    MqttAuth getByUsername(String username);

    /**
     * 根据设备ID查询认证信息
     */
    MqttAuth getByDeviceId(String deviceId);

    /**
     * 保存或更新设备认证信息
     */
    void saveOrUpdateDeviceAuth(String deviceId, String username, String password, String salt, Integer enabled);
}