package com.womi.commonmodule.constants;

/**
 * 正则表达式常量
 */
public final class RegexConstants {

    /** MAC 地址：12 位大写十六进制（无冒号） */
    public static final String MAC = "^[0-9A-F]{12}$";

    /** MAC 地址：带冒号格式 */
    public static final String MAC_WITH_COLON = "^([0-9A-F]{2}:){5}[0-9A-F]{2}$";

    /** UUID */
    public static final String UUID = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$";

    // ==================== 账号与权限 ====================
    /** 用户名：4-32 位字母、数字、下划线 */
    public static final String USERNAME = "^[a-zA-Z0-9_]{4,32}$";

    /** 密码：8-64 位，至少同时包含字母和数字 */
    public static final String PASSWORD = "^(?=.*[A-Za-z])(?=.*\\d).{8,64}$";

    /** 手机号（允许空字符串） */
    public static final String PHONE = "^$|^1[3-9]\\d{9}$";

    /** 角色编码：3-32 位，以大写字母开头，仅包含大写字母、数字、下划线 */
    public static final String ROLE_CODE = "^[A-Z][A-Z0-9_]{2,31}$";

    /** 权限编码：resource:action，如 device:list、role:assign-permission */
    public static final String PERM_CODE = "^[a-z][a-z0-9-]*:[a-z][a-z0-9-]*$";
}