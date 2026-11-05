package com.womi.commonmodule.utils;

import com.womi.commonmodule.constants.DeviceOtaStateConstants;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * OTA 状态工具类
 */
public final class DeviceOtaStateUtils {

    private DeviceOtaStateUtils() {
    }

    /**
     * 判断 OTA 状态是否为"进行中"
     */
    public static boolean isRunning(String otaState) {
        return otaState != null && DeviceOtaStateConstants.RUNNING_STATES.contains(otaState);
    }

    /**
     * 判断 OTA 状态是否为"终态"（成功/失败）
     */
    public static boolean isFinal(String otaState) {
        return otaState != null && DeviceOtaStateConstants.FINAL_STATES.contains(otaState);
    }

    /**
     * 状态英文码 → 中文文案（未知状态原样返回，便于前端直接展示）
     */
    public static String textOf(String otaState) {
        if (otaState == null) {
            return null;
        }
        for (Map.Entry<String, String> entry : DeviceOtaStateConstants.STATE_LABELS) {
            if (entry.getKey().equals(otaState)) {
                return entry.getValue();
            }
        }
        return otaState;
    }

    /**
     * 判断 OTA 状态是否为"僵死"：状态为进行中，但 ota_update_time 超过 {@link DeviceOtaStateConstants#STALE_OTA_MINUTES} 分钟未更新
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
        return otaUpdateTime.isBefore(LocalDateTime.now().minusMinutes(DeviceOtaStateConstants.STALE_OTA_MINUTES));
    }
}