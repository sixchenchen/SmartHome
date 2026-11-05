package com.womi.commonmodule.constants;

/**
 * 头像上传常量
 */
public final class AvatarConstants {

    private AvatarConstants() {
    }

    // ==================== 存储与访问 ====================

    /** 头像大小上限：2MB */
    public static final long MAX_SIZE = 2L * 1024 * 1024;

    /** 默认存储目录（可通过 app.upload.avatar-dir 覆盖） */
    public static final String DEFAULT_DIR = "uploads/avatar";

    /** 默认访问前缀（可通过 app.upload.avatar-base-url 覆盖） */
    public static final String DEFAULT_BASE_URL = "/files/avatar/";

    /** 静态资源映射路径 */
    public static final String RESOURCE_HANDLER = "/files/avatar/**";

    /** 本地文件资源定位前缀 */
    public static final String RESOURCE_LOCATION_PREFIX = "file:";

    /** 资源定位路径分隔符 */
    public static final String PATH_SEPARATOR = "/";

    // ==================== 支持的文件类型 ====================

    public static final String CONTENT_TYPE_JPEG = "image/jpeg";
    public static final String CONTENT_TYPE_PNG = "image/png";
    public static final String CONTENT_TYPE_WEBP = "image/webp";

    public static final String EXTENSION_JPG = "jpg";
    public static final String EXTENSION_PNG = "png";
    public static final String EXTENSION_WEBP = "webp";

    // ==================== 文件命名 ====================

    /** 扩展名分隔符 */
    public static final String EXTENSION_SEPARATOR = ".";

    /** UUID 中的连接符（生成文件名时去除） */
    public static final String UUID_SEPARATOR = "-";

    // ==================== 提示消息 ====================

    public static final String MSG_SIZE_EXCEEDED =
            "头像大小不能超过 " + (MAX_SIZE / (1024 * 1024)) + "MB";
    public static final String MSG_FORMAT_UNSUPPORTED = "仅支持 jpg/png/webp 图片";
}
