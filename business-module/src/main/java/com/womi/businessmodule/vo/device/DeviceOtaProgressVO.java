package com.womi.businessmodule.vo.device;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 设备 OTA 进度快照（轮询兜底 + 断线重连后一次性拉取）
 */
@Data
public class DeviceOtaProgressVO {

    /** 设备 MAC */
    private String deviceId;

    /** OTA 阶段：accepted/downloading/verifying/flashing/rebooting/success/failed */
    private String otaState;

    /** 阶段中文文案，可直接展示 */
    private String otaStateText;

    /** 进度 0~100 */
    private Integer otaProgress;

    /** 目标版本号 */
    private String otaVersion;

    /** 关联的 OTA 指令 ID */
    private String commandId;

    /** 指令状态（见 DeviceCommandStatus） */
    private Integer commandStatus;

    /** 指令状态文案 */
    private String commandStatusText;

    /** 失败原因（成功时为 null） */
    private String errorMsg;

    /** OTA 状态最后更新时间 */
    private LocalDateTime otaUpdateTime;

    /** 是否处于升级进行中 */
    private Boolean running;

    /** 是否已到达终态（成功/失败） */
    private Boolean finished;

    /** 服务端当前时间，前端可据此判断数据新鲜度 */
    private LocalDateTime serverTime;
}
