package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 设备下行指令实体
 */
@Data
@TableName(value = "device_command", autoResultMap = true)
public class DeviceCommand {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 指令唯一ID（UUID），用于 ACK 匹配 */
    @TableField("command_id")
    private String commandId;

    /** 目标设备ID(MAC) */
    @TableField("device_id")
    private String deviceId;

    /** 动作：set/get/toggle/start/reset */
    private String action;

    /** 目标：mos/led/servo/relay/ota/config */
    private String target;

    /** 通道号：0=全部，NULL=无通道 */
    private Integer channel;

    /** 指令参数（Map 类型，自动转 JSON） */
    @TableField(value = "params", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> params;

    /** QoS 等级 */
    private Integer qos;

    /** 是否保留消息 */
    private Integer retain;

    /**
     * 状态：
     * 0-PENDING 待下发
     * 1-SENT 已下发
     * 2-SUCCESS 成功
     * 3-FAILED 失败
     * 4-TIMEOUT 超时
     * 5-CANCELLED 取消
     */
    private Integer status;

    /** 重试次数 */
    @TableField("retry_count")
    private Integer retryCount;

    /** 最大重试次数 */
    @TableField("max_retry")
    private Integer maxRetry;

    /** 失败原因 */
    @TableField("error_msg")
    private String errorMsg;

    /** 设备响应内容 */
    @TableField(value = "response_payload", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> responsePayload;

    /** 操作人 */
    private String operator;

    /** 指令来源：WEB/API/SCHEDULE/SYSTEM */
    private String source;

    /** 过期时间 */
    @TableField("expire_time")
    private LocalDateTime expireTime;

    /** 下发时间 */
    @TableField("send_time")
    private LocalDateTime sendTime;

    /** 设备响应时间 */
    @TableField("ack_time")
    private LocalDateTime ackTime;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}