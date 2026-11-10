package com.womi.businessmodule.dto;

import com.womi.commonmodule.constants.RegexConstants;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

/**
 * 管理端新增用户请求
 */
@Data
public class AdminUserCreateRequest {

    @NotBlank(message = "用户名不能为空")
    @Pattern(regexp = RegexConstants.USERNAME, message = "用户名需 4-32 位，只能包含字母、数字、下划线")
    private String username;

    @NotBlank(message = "密码不能为空")
    @Pattern(regexp = RegexConstants.PASSWORD, message = "密码需 8-64 位，且同时包含字母和数字")
    private String password;

    @Size(max = 64, message = "昵称最长 64 位")
    private String nickname;

    @Email(message = "邮箱格式不正确")
    @Size(max = 128, message = "邮箱最长 128 位")
    private String email;

    @Pattern(regexp = RegexConstants.PHONE, message = "手机号格式不正确")
    private String phone;

    /** 角色编码列表，为空时分配默认角色 USER */
    private List<String> roleCodes;

    @Min(value = 0, message = "状态只能为 0 或 1")
    @Max(value = 1, message = "状态只能为 0 或 1")
    private Integer status;
}
