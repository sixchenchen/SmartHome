package com.womi.commonmodule.utils;

import com.womi.commonmodule.constants.OtaStateConstants;

import java.time.LocalDateTime;

/**
 * OTA 状态工具类
 */
public final class OtaStateUtils {

    private OtaStateUtils() {
    }

    /**
     * 判断 OTA 状态是否为"进行中"
     */
    public static boolean isRunning(String otaState) {
        return otaState != null && OtaStateConstants.RUNNING_STATES.contains(otaState);
    }

    /**
     * 判断 OTA 状态是否为"终态"（成功/失败）
     */
    public static boolean isFinal(String otaState) {
        return otaState != null && OtaStateConstants.FINAL_STATES.contains(otaState);
    }

    /**
     * 判断 OTA 状态是否"僵死"
     * <p>规则：状态为进行中，但 ota_update_time 超过 {@link OtaStateConstants#STALE_OTA_MINUTES} 分钟未更新
     *
     * @param otaState      OTA 状态
     * @param otaUpdateTime OTA 状态最后更新时间（可为 null，视为僵死）
     * @return true=僵死；false=正常
     */
    public static boolean isStale(String otaState, LocalDateTime otaUpdateTime) {
        // 不在进行中状态，不算僵死
        if (!isRunning(otaState)) {
            return false;
        }
        // 时间戳为空 → 视为僵死（历史脏数据）
        if (otaUpdateTime == null) {
            return true;
        }
        // 超过阈值 → 僵死
        return otaUpdateTime.isBefore(
                LocalDateTime.now().minusMinutes(OtaStateConstants.STALE_OTA_MINUTES));
    }
}