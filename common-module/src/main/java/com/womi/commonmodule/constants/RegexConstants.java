package com.womi.commonmodule.constants;

/**
 * 正则表达式常量
 */
public final class RegexConstants {
    private RegexConstants() {}

    /** MAC 地址：12 位大写十六进制（无冒号） */
    public static final String MAC = "^[0-9A-F]{12}$";

    /** MAC 地址：带冒号格式 */
    public static final String MAC_WITH_COLON = "^([0-9A-F]{2}:){5}[0-9A-F]{2}$";

    /** UUID */
    public static final String UUID = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$";

    // 加：手机号、邮箱、身份证...
}