package com.womi.businessmodule.dto;

import com.womi.commonmodule.constants.AvatarConstants;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 修改当前用户资料请求
 */
@Data
public class UserProfileUpdateRequest {

    @Size(max = 64, message = "昵称最长 64 位")
    private String nickname;

    @Email(message = "邮箱格式不正确")
    @Size(max = 128, message = "邮箱最长 128 位")
    private String email;

    @Pattern(regexp = "^$|^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    /** 头像 URL：只允许本服务上传接口返回的地址，传空串表示清除头像 */
    @Size(max = 255, message = "头像地址最长 255 位")
    @Pattern(regexp = "^$|" + AvatarConstants.URL_REGEX, message = "头像地址不合法")
    private String avatar;
}
