package com.womi.commonmodule.constants;

public final class UserConstants {
    /**
     * 用户权限限定名
     */
    public static final String USER_ROLE = "role";
    /**
     * 启用
     **/
    public static final Integer ENABLE_USER = 1;
    /**
     * 禁用
     **/
    public static final Integer DISENABLE_USER = 1;
    /**
     * 用户未删除
     **/
    public static final Integer NOT_DELETED = 0;
    /**
     * 用户未删除
     **/
    public static final Integer DELETED = 0;
    /**
     * 默认角色编码：可在 yml 里配成 app.register.default-role
     */
    public static final String DEFAULT_ROLE_CODE = "USER";
    /**
     * 逻辑删除用户
     */
    public static final Object LOGIC_DELETE_USER = 1;
}
