package com.womi.businessmodule.dto;

import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;

/**
 * 分配用户角色请求
 */
@Data
public class UserRolesUpdateRequest {

    @NotEmpty(message = "角色不能为空")
    private List<String> roleCodes;
}
