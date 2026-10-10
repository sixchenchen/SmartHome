package com.womi.commonmodule.utils;

import com.womi.commonmodule.constants.ErrorInfoConstants;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;

/**
 * 密码工具（加盐哈希）
 * <p>
 * 存储格式：
 * salt：16 字节 → 32 位十六进制字符串
 * hash：SHA-256(salt + password) → 64 位十六进制字符串
 */
@Slf4j
public final class SaltPasswordUtils {

    private SaltPasswordUtils() {
    }

    /**
     * 盐长度（字节）
     */
    private static final int SALT_LENGTH = 16;

    /**
     * 哈希算法
     */
    private static final String HASH_ALGORITHM = "SHA-256";

    /**
     * 随机源（线程安全）
     */
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    /**
     * 密码字符集（去掉了容易混淆的 0/O、1/l/I）
     */
    private static final String PASSWORD_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";

    /**
     * 默认密码长度
     */
    public static final int DEFAULT_PASSWORD_LENGTH = 16;

    // ==================== 盐 ====================

    /**
     * 生成随机盐
     *
     * @return 32 位十六进制字符串
     */
    public static String generateSalt() {
        byte[] salt = new byte[SALT_LENGTH];
        SECURE_RANDOM.nextBytes(salt);
        return bytesToHex(salt);
    }

    // ==================== 哈希 ====================

    /**
     * 对密码加盐哈希
     *
     * @param password 明文密码
     * @param salt     盐值
     * @return 64 位十六进制哈希字符串
     */
    public static String hash(String password, String salt) {
        if (password == null || salt == null) {
            throw new BusinessException(ErrorCode.PASSWORD_EMPTY, ErrorInfoConstants.PASSWORD_EMPTY);
        }
        try {
            MessageDigest digest = MessageDigest.getInstance(HASH_ALGORITHM);
            // prefix:盐在前密码在后
            digest.update(salt.getBytes(StandardCharsets.UTF_8));
            digest.update(password.getBytes(StandardCharsets.UTF_8));
            byte[] hash = digest.digest();
            return bytesToHex(hash);
        } catch (Exception e) {
            log.error("密码哈希失败", e);
            throw new RuntimeException("密码哈希失败", e);
        }
    }

    /**
     * 验证密码
     *
     * @param password     明文密码
     * @param salt         盐值
     * @param expectedHash 期望的哈希值
     * @return true 匹配
     */
    public static boolean verify(String password, String salt, String expectedHash) {
        if (password == null || salt == null || expectedHash == null) {
            return false;
        }
        String actualHash = hash(password, salt);
        return constantTimeEquals(actualHash, expectedHash);
    }

    // ==================== 生成密码 ====================

    /**
     * 生成随机密码
     *
     * @return 16 位随机字符串
     */
    public static String generatePassword() {
        return generatePassword(DEFAULT_PASSWORD_LENGTH);
    }

    /**
     * 生成指定长度的随机密码
     */
    public static String generatePassword(int length) {
        if (length <= 0) {
            throw new BusinessException(ErrorCode.PASSWORD_TOO_SHORT,ErrorInfoConstants.PASSWORD_TOO_SHOW);
        }
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            int index = SECURE_RANDOM.nextInt(PASSWORD_CHARS.length());
            sb.append(PASSWORD_CHARS.charAt(index));
        }
        return sb.toString();
    }

    // ==================== 私有方法 ====================

    /**
     * 常量时间比较，防时序攻击
     */
    private static boolean constantTimeEquals(String a, String b) {
        if (a == null || b == null) {
            return false;
        }
        if (a.length() != b.length()) {
            return false;
        }
        int result = 0;
        for (int i = 0; i < a.length(); i++) {
            result |= a.charAt(i) ^ b.charAt(i);
        }
        return result == 0;
    }

    /**
     * 字节数组 → 十六进制字符串
     */
    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}