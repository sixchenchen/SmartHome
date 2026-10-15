package com.womi.webmodule.dto.ota.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * OTA 启动响应（兼容单/多设备）
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class DeviceOtaStartResponse {

    /** 请求总数 */
    private int total;

    /** 成功数 */
    private int success;

    /** 失败数 */
    private int failed;

    /** 每个设备的处理结果 */
    private List<Item> results = new ArrayList<>();

    public DeviceOtaStartResponse(int total) {
        this.total = total;
    }

    public void addResult(String deviceId, boolean success,
                          String commandId, String version, String error) {
        Item item = new Item();
        item.setDeviceId(deviceId);
        item.setSuccess(success);
        item.setCommandId(commandId);
        item.setVersion(version);
        this.results.add(item);

        if (success) {
            this.success++;
        } else {
            this.failed++;
        }
    }

    /**
     * 单设备处理结果
     */
    @Data
    public static class Item {
        /** 设备 ID */
        private String deviceId;

        /** 是否成功 */
        private boolean success;

        /** 指令 ID（成功时非空） */
        private String commandId;

        /** 目标版本（成功时非空） */
        private String version;

        /** 错误信息（失败时非空） */
        private String error;
    }
}