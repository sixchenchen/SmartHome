package com.womi.businessmodule.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;
import java.util.Map;

/**
 * 设备批量控制请求
 */
@Data
public class DeviceBatchControlRequest {

    @NotEmpty(message = "指令列表不能为空")
    @Valid
    private List<ControlItem> items;

    @Data
    public static class ControlItem {

        @NotBlank(message = "动作不能为空")
        private String action;

        @NotBlank(message = "目标不能为空")
        private String target;

        private Integer channel;

        @NotNull(message = "参数不能为空")
        private Map<String, Object> params;
    }
}
