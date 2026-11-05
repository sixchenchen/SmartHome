package com.womi.businessmodule.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 管理端处理告警请求
 */
@Data
public class AlertHandleRequest {

    @NotNull(message = "处理状态不能为空")
    @Min(value = 1, message = "状态值非法")
    @Max(value = 2, message = "状态值非法")
    private Integer status;
}
