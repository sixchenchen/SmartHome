package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

@Data
@TableName(value = "device_command", autoResultMap = true)
public class DeviceCommand {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 指令唯一ID（UUID） */
    private String commandId;

    /** 目标设备ID */
    private String deviceId;

    /** 指令类型: MOS_CONTROL/REBOOT/CONFIG/QUERY/OTA */
    private String commandType;

    /** 指令参数（Map类型，自动转JSON） */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> payload;

    /** QoS等级 */
    private Integer qos;

    /** 是否保留消息 */
    private Integer retain;

    /** 状态：0-待下发 1-已下发 2-设备已接收 3-执行成功 4-执行失败 5-已超时 6-已取消 */
    private Integer status;

    /** 重试次数 */
    private Integer retryCount;

    /** 最大重试次数 */
    private Integer maxRetry;

    /** 失败原因 */
    private String errorMsg;

    /** 设备响应内容 */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> responsePayload;

    /** 操作人 */
    private String operator;

    /** 指令来源 */
    private String source;

    /** 过期时间 */
    private LocalDateTime expireTime;

    /** 下发时间 */
    private LocalDateTime sendTime;

    /** 设备响应时间 */
    private LocalDateTime ackTime;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}