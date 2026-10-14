package com.womi.commonmodule.constants;

import java.util.Set;

/**
 * OTA 状态常量
 */
public final class OtaStateConstants {

    private OtaStateConstants() {
    }

    // ==================== 设备 OTA 阶段状态 ====================

    public static final String ACCEPTED    = "accepted";
    public static final String DOWNLOADING = "downloading";
    public static final String VERIFYING   = "verifying";
    public static final String FLASHING    = "flashing";
    public static final String REBOOTING   = "rebooting";
    public static final String SUCCESS     = "success";
    public static final String FAILED      = "failed";

    /** 进行中的状态集合（这些状态的设备不能再次发起 OTA） */
    public static final Set<String> RUNNING_STATES = Set.of(
            ACCEPTED, DOWNLOADING, VERIFYING, FLASHING, REBOOTING
    );

    /** 终态集合 */
    public static final Set<String> FINAL_STATES = Set.of(
            SUCCESS, FAILED
    );

    /** 僵死判定阈值：ota_update_time 超过该分钟数未更新，视为僵死 */
    public static final int STALE_OTA_MINUTES = 5;
}