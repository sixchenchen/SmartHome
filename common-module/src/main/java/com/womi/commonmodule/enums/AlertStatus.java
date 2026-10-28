package com.womi.commonmodule.enums;

/**
 * 告警处理状态
 */
public enum AlertStatus {

    PENDING(0, "未处理"),
    ACKNOWLEDGED(1, "已确认"),
    RESOLVED(2, "已解决");

    private final int code;
    private final String message;

    AlertStatus(int code, String message) {
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
    public static AlertStatus fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        for (AlertStatus status : values()) {
            if (status.code == code) {
                return status;
            }
        }
        return null;
    }

    /** 是否为终态(已解决) */
    public boolean isFinished() {
        return this == RESOLVED;
    }

    /** 是否待处理(未处理/已确认) */
    public boolean isPending() {
        return this == PENDING || this == ACKNOWLEDGED;
    }

    /** 是否已确认(可继续流转到已解决) */
    public boolean isAcknowledged() {
        return this == ACKNOWLEDGED;
    }
}