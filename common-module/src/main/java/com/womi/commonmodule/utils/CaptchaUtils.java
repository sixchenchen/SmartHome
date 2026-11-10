package com.womi.commonmodule.utils;

import com.womi.commonmodule.constants.CaptchaConstants;

import java.security.SecureRandom;
import java.util.UUID;

/**
 * 验证码通用工具
 */
public final class CaptchaUtils {

    private static final SecureRandom RANDOM = new SecureRandom();

    private CaptchaUtils() {
    }

    /** 生成验证码唯一标识 */
    public static String randomId() {
        return UUID.randomUUID().toString().replace("-", "");
    }

    /** 生成指定长度的随机验证码 */
    public static String randomCode(int length) {
        int size = length > 0 ? length : CaptchaConstants.DEFAULT_LENGTH;
        StringBuilder builder = new StringBuilder(size);
        for (int i = 0; i < size; i++) {
            builder.append(CaptchaConstants.CODE_CHARS.charAt(nextInt(CaptchaConstants.CODE_CHARS.length())));
        }
        return builder.toString();
    }

    /** 忽略大小写校验验证码 */
    public static boolean matches(String expected, String input) {
        return expected != null && input != null && expected.equalsIgnoreCase(input.trim());
    }

    /** 安全随机数 */
    public static int nextInt(int bound) {
        return RANDOM.nextInt(bound);
    }

    /** 安全随机数 */
    public static double nextDouble() {
        return RANDOM.nextDouble();
    }
}
