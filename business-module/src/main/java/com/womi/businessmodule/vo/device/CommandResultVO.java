package com.womi.businessmodule.vo.device;

import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 指令执行结果（WebSocket 推送体 / 指令详情）
 */
@Data
@Builder
public class CommandResultVO {

    /** 指令ID */
    private String commandId;

    /** 设备 MAC */
    private String deviceId;

    /** 动作：set/get/toggle/start/reset */
    private String action;

    /** 目标：mos/led/servo/relay/ota/config */
    private String target;

    /** 通道号：0=全部 */
    private Integer channel;

    /** 状态码：0-待下发 1-已下发 2-成功 3-失败 4-超时 5-取消 6-已接收 */
    private Integer status;

    /** 状态文案 */
    private String statusText;

    /**
     * 是否成功：
     * true=成功，false=失败/超时/取消，null=执行中（如 OTA 已接收）
     */
    private Boolean success;

    /** 失败原因 */
    private String errorMsg;

    /** 设备响应内容（ACK 的 data 字段） */
    private Map<String, Object> responsePayload;

    /** 设备响应时间 */
    private LocalDateTime ackTime;

    public static CommandResultVO of(DeviceCommand command) {
        DeviceCommandStatus status = DeviceCommandStatus.fromCode(command.getStatus());
        Boolean success = null;
        if (status != null) {
            if (status == DeviceCommandStatus.SUCCESS) {
                success = Boolean.TRUE;
            } else if (status.isFinished()) {
                success = Boolean.FALSE;
            }
        }
        return CommandResultVO.builder()
                .commandId(command.getCommandId())
                .deviceId(command.getDeviceId())
                .action(command.getAction())
                .target(command.getTarget())
                .channel(command.getChannel())
                .status(command.getStatus())
                .statusText(status == null ? null : status.getMessage())
                .success(success)
                .errorMsg(command.getErrorMsg())
                .responsePayload(command.getResponsePayload())
                .ackTime(command.getAckTime())
                .build();
    }
}
