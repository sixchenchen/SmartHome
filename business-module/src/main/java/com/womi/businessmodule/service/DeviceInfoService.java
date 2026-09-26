package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.DeviceInfo;

import java.time.LocalDateTime;
import java.util.List;

public interface DeviceInfoService extends IService<DeviceInfo> {

    /**
     * 根据设备ID查询设备信息
     */
    DeviceInfo getByDeviceId(String deviceId);

    /**
     * 查询所有在线设备
     */
    List<DeviceInfo> getOnlineDevices();

    /**
     * 根据设备名称模糊查询
     */
    List<DeviceInfo> getByDeviceName(String deviceName);

    /**
     * 根据状态查询设备列表
     */
    List<DeviceInfo> getByStatus(Integer status);

    /**
     * 查询最近更新的设备
     */
    List<DeviceInfo> getRecentDevices(int limit);

    /**
     * 查询离线设备（心跳超时）
     */
    List<DeviceInfo> getOfflineDevices(int timeoutSeconds);

    /**
     * 统计设备数量
     */
    int countByStatus(Integer status);

    /**
     * 更新设备在线状态
     */
    int updateStatus(String deviceId, Integer status, LocalDateTime heartbeatTime, LocalDateTime updateTime);

    /**
     * 更新设备信息
     */
    int updateDeviceInfo(DeviceInfo deviceInfo);

    /**
     * 批量更新设备状态
     */
    int batchUpdateStatus(List<String> deviceIds, Integer status);

    /**
     * 插入或更新设备
     */
    int insertOrUpdateDevice(DeviceInfo deviceInfo);

    /**
     * 删除设备
     */
    int deleteByDeviceId(String deviceId);

    /**
     * 批量删除设备
     */
    int batchDeleteDevices(List<String> deviceIds);

    /**
     * 检查设备是否存在
     */
    boolean existsByDeviceId(String deviceId);

    /**
     * 获取设备总数
     */
    long getTotalCount();
}