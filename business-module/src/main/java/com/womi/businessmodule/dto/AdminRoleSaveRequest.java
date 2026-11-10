package com.womi.businessmodule.dto;

import com.womi.commonmodule.constants.RegexConstants;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 管理端新增/编辑角色请求
 */
@Data
public class AdminRoleSaveRequest {

    @NotBlank(message = "角色编码不能为空")
    @Pattern(regexp = RegexConstants.ROLE_CODE, message = "角色编码需 3-32 位，以大写字母开头，仅包含大写字母、数字、下划线")
    private String roleCode;

    @NotBlank(message = "角色名称不能为空")
    @Size(max = 64, message = "角色名称最长 64 位")
    private String roleName;

    @Size(max = 255, message = "描述最长 255 位")
    private String description;

    @Min(value = 0, message = "状态只能为 0 或 1")
    @Max(value = 1, message = "状态只能为 0 或 1")
    private Integer status;
}
