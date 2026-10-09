package com.womi.webmodule.dto.firmware.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class FirmwareVO {

    private Long id;
    private String version;
    private String product;
    private String releaseNotes;
    private String url;
    private String md5;
    private String sha256;
    private Long size;
    private String sizeText;
    private String uploadedBy;
    private LocalDateTime uploadTime;
    private Integer status;
}