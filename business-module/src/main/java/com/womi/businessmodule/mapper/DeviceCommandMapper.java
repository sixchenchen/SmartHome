package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.DeviceCommand;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface DeviceCommandMapper extends BaseMapper<DeviceCommand> {

    /**
     * 根据 commandId 查询指令
     */
    DeviceCommand selectByCommandId(@Param("commandId") String commandId);

    /**
     * 查询待下发指令
     */
    List<DeviceCommand> selectPendingCommands(@Param("limit") int limit);

    /**
     * 查询需要重试的指令（已发送，超过重试间隔，未超时）
     */
    List<DeviceCommand> selectRetryableCommands(@Param("timeoutSeconds") int timeoutSeconds,
                                                @Param("limit") int limit);

    /**
     * 查询已过期但未完成的指令
     */
    List<DeviceCommand> selectExpiredCommands(@Param("now") LocalDateTime now);

    /**
     * 标记为已发送
     */
    int markAsSent(@Param("id") Long id, @Param("sendTime") LocalDateTime sendTime);

    /**
     * 增加重试次数
     */
    int incrementRetryCount(@Param("id") Long id, @Param("sendTime") LocalDateTime sendTime);

    /**
     * 标记成功
     */
    int markAsSuccess(@Param("commandId") String commandId,
                      @Param("ackTime") LocalDateTime ackTime,
                      @Param("responsePayload") String responsePayload);

    /**
     * 标记失败
     */
    int markAsFailed(@Param("commandId") String commandId,
                     @Param("ackTime") LocalDateTime ackTime,
                     @Param("errorMsg") String errorMsg);

    /**
     * 标记超时
     */
    int markAsTimeout(@Param("ids") List<Long> ids);

    /**
     * 批量更新状态
     */
    int batchUpdateStatus(@Param("ids") List<Long> ids, @Param("status") int status);
}