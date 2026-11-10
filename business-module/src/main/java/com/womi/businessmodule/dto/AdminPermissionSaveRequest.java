package com.womi.businessmodule.dto;

import com.womi.commonmodule.constants.RegexConstants;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 管理端新增/编辑权限请求
 */
@Data
public class AdminPermissionSaveRequest {

    @NotBlank(message = "权限编码不能为空")
    @Pattern(regexp = RegexConstants.PERM_CODE, message = "权限编码格式应为 resource:action，如 device:list")
    private String permCode;

    @NotBlank(message = "权限名称不能为空")
    @Size(max = 128, message = "权限名称最长 128 位")
    private String permName;

    @NotBlank(message = "权限类型不能为空")
    @Size(max = 16, message = "权限类型最长 16 位")
    private String permType;

    @Size(max = 128, message = "资源最长 128 位")
    private String resource;

    @Size(max = 64, message = "动作最长 64 位")
    private String action;

    @Size(max = 255, message = "描述最长 255 位")
    private String description;

    @Min(value = 0, message = "状态只能为 0 或 1")
    @Max(value = 1, message = "状态只能为 0 或 1")
    private Integer status;
}
