package com.womi.businessmodule.model;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 固件版本
 */
@Data
@TableName("firmware")
public class Firmware {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 版本号 */
    private String version;

    /** 产品型号 */
    private String product;

    /** 发布说明 */
    @TableField("release_notes")
    private String releaseNotes;

    /** 固件下载地址 */
    private String url;

    /** 原始文件名 */
    @TableField("file_name")
    private String fileName;

    /** 服务器保存路径 */
    @TableField("file_path")
    private String filePath;

    /** MD5 */
    private String md5;

    /** SHA256 */
    private String sha256;

    /** 文件大小（字节） */
    private Long size;

    /** 上传人 */
    @TableField("uploaded_by")
    private String uploadedBy;

    /** 上传时间 */
    @TableField("upload_time")
    private LocalDateTime uploadTime;

    /** 状态：0-禁用 1-启用 */
    private Integer status;

    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}