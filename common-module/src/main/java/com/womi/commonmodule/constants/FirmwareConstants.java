package com.womi.commonmodule.constants;

/**
 * 固件相关常量
 */
public final class FirmwareConstants {

    private FirmwareConstants() {}

    /** 默认文件名格式：firmware_{version}_{timestamp}.bin */
    public static final String DEFAULT_FILE_NAME_PATTERN = "firmware_%s_%s.bin";

    /** 默认固件基础 URL 前缀 */
    public static final String DEFAULT_BASE_URL = "http://192.168.1.15:8000/firmware/";

    /** 默认上传目录 */
    public static final String DEFAULT_UPLOAD_DIR = "/data/firmware/";

    /** 文件名时间戳格式 */
    public static final String FILE_TIMESTAMP_PATTERN = "yyyyMMddHHmmss";
}