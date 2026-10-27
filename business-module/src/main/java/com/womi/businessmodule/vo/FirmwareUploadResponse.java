package com.womi.businessmodule.vo;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FirmwareUploadResponse {

    private Long id;
    private String version;
    private String product;
    private String url;
    private String md5;
    private String sha256;
    private Long size;
}