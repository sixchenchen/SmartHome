package com.womi.commonmodule.constants;

/**
 * 验证码常量
 */
public final class CaptchaConstants {

    private CaptchaConstants() {
    }

    // ==================== 默认参数 ====================
    /** 验证码有效期（秒） */
    public static final long DEFAULT_TTL_SECONDS = 300L;

    /** 验证码字符长度 */
    public static final int DEFAULT_LENGTH = 4;

    /** 图片宽度 */
    public static final int DEFAULT_WIDTH = 120;

    /** 图片高度 */
    public static final int DEFAULT_HEIGHT = 40;

    /** 干扰线数量 */
    public static final int DEFAULT_NOISE_LINES = 8;

    /** 单个验证码允许的最大校验失败次数 */
    public static final int MAX_VERIFY_ATTEMPTS = 5;

    // ==================== 字符与图片 ====================
    /** 验证码字符集（去除 I/O/0/1 等易混淆字符） */
    public static final String CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz23456789";

    /** 图片格式 */
    public static final String IMAGE_FORMAT = "png";

    /** Base64 图片前缀 */
    public static final String IMAGE_BASE64_PREFIX = "data:image/png;base64,";

    /** 字体名称 */
    public static final String FONT_NAME = "SansSerif";

    /** 最小字号 */
    public static final int FONT_SIZE_MIN = 24;

    /** 字号相对图片高度的偏移量 */
    public static final int FONT_SIZE_HEIGHT_OFFSET = 8;

    /** 图片背景色（RGB） */
    public static final int BACKGROUND_RGB = 0xF5F7FA;

    /** 字符颜色下限 */
    public static final int COLOR_DARK_MIN = 20;

    /** 字符颜色上限 */
    public static final int COLOR_DARK_MAX = 110;

    /** 干扰线颜色下限 */
    public static final int COLOR_LIGHT_MIN = 120;

    /** 干扰线颜色上限 */
    public static final int COLOR_LIGHT_MAX = 200;

    /** 字符最大旋转角度 */
    public static final double MAX_ROTATION_DEGREE = 25.0;

    /** 字符横向抖动范围 */
    public static final int CHAR_X_JITTER = 6;

    /** 字符纵向抖动范围 */
    public static final int CHAR_Y_JITTER = 8;
}
