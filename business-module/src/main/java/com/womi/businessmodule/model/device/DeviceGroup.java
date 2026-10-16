package com.womi.businessmodule.model.device;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 设备分组表
 */
@Data
@TableName(value = "device_group")
public class DeviceGroup {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 分组名 */
    private String name;

    /** 父分组ID */
    @TableField("parent_id")
    private Long parentId;

    /** 归属用户ID */
    @TableField("user_id")
    private Long userId;

    /** 排序 */
    @TableField("sort_order")
    private Integer sortOrder;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}