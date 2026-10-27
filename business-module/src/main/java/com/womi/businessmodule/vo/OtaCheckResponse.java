package com.womi.businessmodule.vo;

import lombok.Data;

@Data
public class OtaCheckResponse {
    /** 是否有新版本 */
    private boolean hasNewVersion;
    /** 新固件ID（用于发起升级时传参） */
    private Long firmwareId;
    /** 最新版本号 */
    private String latestVersion;
    /** 更新说明 */
    private String releaseNotes;
    /** 固件大小(字节) */
    private Long size;
}