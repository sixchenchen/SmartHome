package com.womi.commonmodule.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.util.unit.DataSize;

@Data
@ConfigurationProperties(prefix = "firmware")
public class FirmwareProperties {

    private String uploadDir = "D:/data/firmware/";
    private String baseUrl = "http://localhost:8000/firmware/";
    private String fileNamePattern = "firmware_%s_%s.bin";
    private DataSize maxSize = DataSize.ofMegabytes(16);
    private DataSize maxRequestSize = DataSize.ofMegabytes(20);
}