package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

@Data
@TableName(value = "mos_state_record", autoResultMap = true)
public class MosStateRecord {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String deviceId;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Integer> mosStates;
    private LocalDateTime timestamp;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}