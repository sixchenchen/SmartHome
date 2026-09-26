package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.DeviceCommand;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
public interface DeviceCommandMapper extends BaseMapper<DeviceCommand> {

    /**
     * 根据 commandId 查询指令（用于 ACK 消息匹配）
     */
    DeviceCommand selectByCommandId(@Param("commandId") String commandId);

    /**
     * 查询设备最新的指令（不分状态）
     */
    DeviceCommand selectLatestByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 按设备 + 状态查询指令列表
     */
    List<DeviceCommand> selectByDeviceAndStatus(@Param("deviceId") String deviceId,
                                                @Param("status") Integer status);

    /**
     * 查询某设备指定时间范围内的指令历史
     */
    List<DeviceCommand> selectByTimeRange(@Param("deviceId") String deviceId,
                                          @Param("startTime") LocalDateTime startTime,
                                          @Param("endTime") LocalDateTime endTime);

    /**
     * 查询所有待下发指令
     */
    List<DeviceCommand> selectPendingCommands(@Param("limit") int limit);

    /**
     * 查询需要重试的指令（已下发但未 ACK，且未达最大重试次数）
     */
    List<DeviceCommand> selectRetryableCommands(@Param("timeoutSeconds") int timeoutSeconds,
                                                @Param("limit") int limit);

    /**
     * 查询已超时的指令（超过 expire_time 且仍未完成）
     */
    List<DeviceCommand> selectExpiredCommands(@Param("now") LocalDateTime now);

    /**
     * 更新指令状态为已下发
     */
    int markAsSent(@Param("id") Long id,
                   @Param("sendTime") LocalDateTime sendTime);

    /**
     * 更新指令状态为设备已接收
     */
    int markAsReceived(@Param("commandId") String commandId,
                       @Param("ackTime") LocalDateTime ackTime,
                       @Param("responsePayload") String responsePayload);

    /**
     * 更新指令状态为执行成功
     */
    int markAsSuccess(@Param("commandId") String commandId,
                      @Param("ackTime") LocalDateTime ackTime,
                      @Param("responsePayload") String responsePayload);

    /**
     * 更新指令状态为执行失败
     */
    int markAsFailed(@Param("commandId") String commandId,
                     @Param("ackTime") LocalDateTime ackTime,
                     @Param("errorMsg") String errorMsg);

    /**
     * 增加重试次数并更新重试时间
     */
    int incrementRetryCount(@Param("id") Long id,
                            @Param("sendTime") LocalDateTime sendTime);

    /**
     * 批量更新状态
     */
    int batchUpdateStatus(@Param("ids") List<Long> ids,
                          @Param("status") Integer status);

    /**
     * 取消指令
     */
    int cancelCommand(@Param("id") Long id,
                      @Param("operator") String operator);

    /**
     * 统计各状态指令数量
     */
    List<Map<String, Object>> countByStatus(@Param("deviceId") String deviceId);

    /**
     * 按指令类型统计
     */
    List<Map<String, Object>> countByType(@Param("startTime") LocalDateTime startTime,
                                          @Param("endTime") LocalDateTime endTime);

    /**
     * 清理过期历史指令
     */
    int deleteFinishedBefore(@Param("beforeTime") LocalDateTime beforeTime,
                             @Param("statusList") List<Integer> statusList);
}