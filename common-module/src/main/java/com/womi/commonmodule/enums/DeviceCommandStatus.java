package com.womi.commonmodule.enums;

/**
 * 指令状态
 *
 * 0-PENDING   待下发
 * 1-SENT      已下发
 * 2-SUCCESS   成功
 * 3-FAILED    失败
 * 4-TIMEOUT   超时
 * 5-CANCELLED 取消
 * 6-ACCEPTED  已接收 (设备已受理，正在执行)
 */
public enum DeviceCommandStatus {

    PENDING(0, "待下发"),
    SENT(1, "已下发"),
    SUCCESS(2, "成功"),
    FAILED(3, "失败"),
    TIMEOUT(4, "超时"),
    CANCELLED(5, "取消"),
    ACCEPTED(6, "已接收");

    private final int code;
    private final String message;

    DeviceCommandStatus(int code, String message) {
        this.code = code;
        this.message = message;
    }

    /** 数据库存储值 */
    public int getCode() {
        return code;
    }

    /** 描述信息 */
    public String getMessage() {
        return message;
    }

    /** 根据 code 反查枚举 */
    public static DeviceCommandStatus fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        for (DeviceCommandStatus status : values()) {
            if (status.code == code) {
                return status;
            }
        }
        return null;
    }

    /** 是否为终态（成功/失败/超时/取消） */
    public boolean isFinished() {
        return this == SUCCESS || this == FAILED || this == TIMEOUT || this == CANCELLED;
    }

    /**
     * 是否为待响应状态（严格指：待下发 / 已下发，等待设备 ACK）。
     */
    public boolean isPending() {
        return this == PENDING || this == SENT;
    }

    /**
     * 是否为活跃状态（未进入终态的所有状态，包含待下发、已下发、已接收）。
     */
    public boolean isActive() {
        return !isFinished();
    }
}