package com.womi.commonmodule.enums;

/**
 * 设备绑定状态
 */
public enum BindStatus {

    UNBOUND(0, "已解绑"),
    BOUND(1, "已绑定");

    private final int code;
    private final String message;

    BindStatus(int code, String message) {
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
    public static BindStatus fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        for (BindStatus status : values()) {
            if (status.code == code) {
                return status;
            }
        }
        return null;
    }

    /** 是否已绑定 */
    public boolean isBound() {
        return this == BOUND;
    }

    /** 是否已解绑 */
    public boolean isUnbound() {
        return this == UNBOUND;
    }
}