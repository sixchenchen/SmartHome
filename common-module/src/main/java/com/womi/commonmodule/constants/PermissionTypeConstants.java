package com.womi.commonmodule.constants;

import java.util.Set;

/**
 * 权限类型常量
 */
public final class PermissionTypeConstants {

    private PermissionTypeConstants() {
    }

    /** 菜单 */
    public static final String MENU = "MENU";

    /** 按钮 */
    public static final String BUTTON = "BUTTON";

    /** 接口 */
    public static final String API = "API";

    /** 动作 */
    public static final String ACTION = "ACTION";

    /** 默认权限类型 */
    public static final String DEFAULT_TYPE = ACTION;

    /** 合法权限类型集合 */
    public static final Set<String> VALID_TYPES = Set.of(MENU, BUTTON, API, ACTION);
}
