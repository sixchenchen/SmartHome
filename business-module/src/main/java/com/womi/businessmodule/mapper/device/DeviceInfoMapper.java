package com.womi.businessmodule.mapper.device;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.device.DeviceInfo;
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

    /**
     * 定向更新 OTA 状态（只改 ota_* 字段，避免整行覆盖导致并发字段丢失）
     */
    int updateOtaStateByDeviceId(@Param("deviceId") String deviceId,
                                 @Param("state") String state,
                                 @Param("progress") Integer progress,
                                 @Param("version") String version);

    /**
     * 定向同步固件版本（仅当与目标版本不一致时才更新，幂等）
     */
    int updateFirmwareByDeviceId(@Param("deviceId") String deviceId,
                                 @Param("firmware") String firmware);

    /**
     * 定向清理 OTA 状态（只清 ota_state/ota_progress）
     */
    int clearOtaStateByDeviceId(@Param("deviceId") String deviceId);
}