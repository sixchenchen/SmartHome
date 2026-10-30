package com.womi.commonmodule.constants;

public final class HttpConstants {

    public static final int SUCCESS_CODE = 200;
    public static final String SUCCESS_MESSAGE = "success";

    public static final int BAD_REQUEST_CODE = 400;
    public static final String BAD_REQUEST_MESSAGE = "Bad Request";

    public static final int UNAUTHORIZED_CODE = 401;
    public static final String UNAUTHORIZED_MESSAGE = "Unauthorized";

    public static final int INTERNAL_ERROR_CODE = 500;
    public static final String INTERNAL_ERROR_MESSAGE = "Internal Server Error";

    public static final String DEVICE_TYPE_HEAD = "X-Device-Type";
    public static final String FORWARDED_FOR = "X-Forwarded-For";
    public static final String REAL_IP = "X-Real-IP";
    public static final String UNKNOWN = "unknown";
}
