package com.womi.commonmodule.enums;

/**
 * 通用启用/禁用状态
 */
public enum EnableStatus {

    DISABLED(0, "禁用"),
    ENABLED(1, "启用");

    private final int code;
    private final String message;

    EnableStatus(int code, String message) {
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
    public static EnableStatus fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        for (EnableStatus status : values()) {
            if (status.code == code) {
                return status;
            }
        }
        return null;
    }

    /** 是否启用 */
    public boolean isEnabled() {
        return this == ENABLED;
    }

    /** 是否禁用 */
    public boolean isDisabled() {
        return this == DISABLED;
    }

    /** 取反后的 code(启用→0,禁用→1),用于快速切换 */
    public int toggleCode() {
        return this == ENABLED ? DISABLED.code : ENABLED.code;
    }
}