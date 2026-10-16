package com.womi.businessmodule.model.device;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * OTA 批量升级任务表
 */
@Data
@TableName(value = "device_ota_task")
public class DeviceOtaTask {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 任务ID(UUID) */
    @TableField("task_id")
    private String taskId;

    /** 固件ID */
    @TableField("firmware_id")
    private Long firmwareId;

    /** 目标版本 */
    @TableField("target_version")
    private String targetVersion;

    /** 设备总数 */
    @TableField("total_count")
    private Integer totalCount;

    /** 成功数 */
    @TableField("success_count")
    private Integer successCount;

    /** 失败数 */
    @TableField("failed_count")
    private Integer failedCount;

    /** 待处理数 */
    @TableField("pending_count")
    private Integer pendingCount;

    /** 0-进行中 1-已完成 2-已取消 */
    private Integer status;

    /** 操作人 */
    private String operator;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}