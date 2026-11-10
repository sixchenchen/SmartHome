package com.womi.commonmodule.constants;

/**
 * 角色常量
 */
public final class RoleConstants {

    private RoleConstants() {
    }

    // ==================== 内置角色编码 ====================
    /** 超级管理员 */
    public static final String ADMIN = "ADMIN";

    /** 运维人员 */
    public static final String OPS = "OPS";

    /** 普通用户 */
    public static final String USER = "USER";

    // ==================== 内置标识 ====================
    /** 内置角色：禁止删除、禁止修改角色编码、禁止禁用 */
    public static final Integer BUILT_IN = 1;

    /** 非内置角色 */
    public static final Integer NOT_BUILT_IN = 0;
}
