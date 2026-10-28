package com.womi.commonmodule.enums;

/**
 * 设备在线状态
 */
public enum DeviceOnlineStatus {

    OFFLINE(0, "离线"),
    ONLINE(1, "在线"),
    FAULT(2, "故障");

    private final int code;
    private final String message;

    DeviceOnlineStatus(int code, String message) {
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
    public static DeviceOnlineStatus fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        for (DeviceOnlineStatus status : values()) {
            if (status.code == code) {
                return status;
            }
        }
        return null;
    }

    /** 是否在线(可用于下发指令前的校验) */
    public boolean isOnline() {
        return this == ONLINE;
    }

    /** 是否离线 */
    public boolean isOffline() {
        return this == OFFLINE;
    }

    /** 是否故障(在线但异常,业务上通常也不接受控制指令) */
    public boolean isFault() {
        return this == FAULT;
    }

    /** 是否可接受控制指令(仅在线可下发) */
    public boolean canAcceptCommand() {
        return this == ONLINE;
    }
}