package com.womi.businessmodule.vo;

import lombok.Data;

/**
 * 头像上传结果
 */
@Data
public class AvatarUploadResponse {

    private String url;

    private Long size;

    private String contentType;
}
