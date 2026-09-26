package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.DeviceInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface DeviceInfoMapper extends BaseMapper<DeviceInfo> {

    /**
     * 根据设备ID查询
     */
    DeviceInfo selectByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 查询所有在线设备
     */
    List<DeviceInfo> selectOnlineDevices();

    /**
     * 根据设备名称模糊查询
     */
    List<DeviceInfo> selectByDeviceName(@Param("deviceName") String deviceName);

    /**
     * 根据状态查询设备列表
     */
    List<DeviceInfo> selectByStatus(@Param("status") Integer status);

    /**
     * 查询最近更新的设备
     */
    List<DeviceInfo> selectRecentDevices(@Param("limit") int limit);

    /**
     * 查询离线设备（心跳超时）
     */
    List<DeviceInfo> selectOfflineDevices(@Param("timeoutSeconds") int timeoutSeconds);

    /**
     * 统计设备数量
     */
    int countDevicesByStatus(@Param("status") Integer status);

    /**
     * 更新设备在线状态
     */
    int updateStatus(@Param("deviceId") String deviceId,
                     @Param("status") Integer status,
                     @Param("heartbeatTime") LocalDateTime heartbeatTime,
                     @Param("updateTime") LocalDateTime updateTime);

    /**
     * 更新设备信息
     */
    int updateDeviceInfo(DeviceInfo deviceInfo);

    /**
     * 批量更新设备状态
     */
    int batchUpdateStatus(@Param("deviceIds") List<String> deviceIds, @Param("status") Integer status);

    /**
     * 插入或更新设备
     */
    int insertOrUpdateDevice(DeviceInfo deviceInfo);
    /**
     * 删除设备
     */
    int deleteByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 批量删除设备
     */
    int batchDeleteDevices(@Param("deviceIds") List<String> deviceIds);
}