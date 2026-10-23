package com.womi.businessmodule.vo;

import lombok.Data;

@Data
public class FirmwareUploadResponse {

    private Long id;
    private String version;
    private String product;
    private String url;
    private String md5;
    private String sha256;
    private Long size;
}