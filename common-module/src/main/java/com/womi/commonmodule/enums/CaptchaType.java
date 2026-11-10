package com.womi.commonmodule.enums;

/**
 * 验证码类型
 */
public enum CaptchaType {

    /** 图片验证码 */
    IMAGE("image", "图片验证码"),

    /** 短信验证码（预留） */
    SMS("sms", "短信验证码"),

    /** 邮箱验证码（预留） */
    EMAIL("email", "邮箱验证码");

    private final String code;
    private final String message;

    CaptchaType(String code, String message) {
        this.code = code;
        this.message = message;
    }

    /** 接口传输值 */
    public String getCode() {
        return code;
    }

    /** 描述信息 */
    public String getMessage() {
        return message;
    }

    /** 根据 code 反查枚举 */
    public static CaptchaType fromCode(String code) {
        if (code == null || code.isBlank()) {
            return null;
        }
        for (CaptchaType type : values()) {
            if (type.code.equalsIgnoreCase(code.trim())) {
                return type;
            }
        }
        return null;
    }
}
