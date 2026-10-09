package com.womi.commonmodule.constants;

public final class HttpStatusConstants {
    private HttpStatusConstants() {} // 防止实例化

    public static final int SUCCESS_CODE = 200;
    public static final String SUCCESS_MESSAGE = "success";

    public static final int BAD_REQUEST_CODE = 400;
    public static final String BAD_REQUEST_MESSAGE = "Bad Request";

    public static final int UNAUTHORIZED_CODE = 401;
    public static final String UNAUTHORIZED_MESSAGE = "Unauthorized";

    public static final int INTERNAL_ERROR_CODE = 500;
    public static final String INTERNAL_ERROR_MESSAGE = "Internal Server Error";
}