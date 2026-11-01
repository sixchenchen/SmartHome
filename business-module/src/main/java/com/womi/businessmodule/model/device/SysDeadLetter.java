package com.womi.businessmodule.model.sys;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("sys_dead_letter")
public class SysDeadLetter {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String topic;
    private String payload;

    @TableField("error_msg")
    private String errorMsg;

    @TableField("is_retryable")
    private Integer isRetryable;

    /** 0-未处理 1-已重放成功 2-已忽略 */
    private Integer status;

    @TableField("retry_count")
    private Integer retryCount;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}