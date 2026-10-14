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
     * 查询心跳超时的在线设备
     */
    List<DeviceInfo> selectHeartbeatTimeoutDevices(@Param("threshold") LocalDateTime threshold);

    /**
     * 仅当"当前在线且心跳时间未变"时才标记离线，用于防止"心跳超时扫描"与"设备心跳"并发导致误判
     */
    int markOfflineIfTimeout(@Param("deviceId") String deviceId,
                             @Param("reason") String reason, @Param("lastHeartbeatTime") LocalDateTime lastHeartbeatTime);

    /**
     * 心跳更新（设备不存在则影响 0 行，不创建）
     */
    int updateHeartbeatByDeviceId(@Param("deviceId") String deviceId,
                                  @Param("uptime") Long uptime,
                                  @Param("payload") String payload);

    int markOfflineByDeviceId(@Param("deviceId") String deviceId,
                              @Param("reason") String reason);
}