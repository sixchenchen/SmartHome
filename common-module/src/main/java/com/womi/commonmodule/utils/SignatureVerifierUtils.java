package com.womi.commonmodule.utils;

import lombok.extern.slf4j.Slf4j;

import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

/**
 * 数字签名验证工具
 *
 * 支持 ECDSA (SHA256withECDSA) + PEM 公钥
 */
@Slf4j
public final class SignatureVerifierUtils {

    private static final String SIGN_ALGORITHM = "SHA256withECDSA";
    private static final String KEY_ALGORITHM = "EC";

    private SignatureVerifierUtils() {}

    /**
     * ECDSA 验签
     *
     * @param pem       PEM 格式公钥（支持标准 Base64 和 URL-safe）
     * @param signData  待验签的原始数据（UTF-8 编码）
     * @param signature Base64 编码的签名（支持标准 Base64 和 URL-safe）
     * @return true 验证通过
     */
    public static boolean verify(String pem, String signData, String signature) {
        // 1. 参数校验
        if (pem == null || pem.isBlank()
                || signData == null
                || signature == null || signature.isBlank()) {
            log.warn("验签参数不完整");
            return false;
        }

        // 2. 解析公钥
        PublicKey publicKey;
        try {
            publicKey = parsePublicKey(pem);
        } catch (Exception e) {
            log.warn("公钥解析失败: {}", e.toString());
            return false;
        }

        // 3. 验签
        try {
            Signature verifier = Signature.getInstance(SIGN_ALGORITHM);
            verifier.initVerify(publicKey);
            verifier.update(signData.getBytes(StandardCharsets.UTF_8));
            byte[] sigBytes = Base64.getMimeDecoder().decode(signature);
            boolean result = verifier.verify(sigBytes);

            if (!result) {
                log.debug("签名不匹配");   // ← 正常失败，debug 级别
            }
            return result;

        } catch (IllegalArgumentException e) {
            // Base64 解码失败
            log.warn("签名 Base64 格式错误: {}", e.toString());
            return false;
        } catch (Exception e) {
            log.warn("验签异常: {}", e.toString());
            return false;
        }
    }

    /**
     * 从 PEM 字符串解析公钥
     */
    private static PublicKey parsePublicKey(String pem) throws Exception {
        String content = pem
                .replace("-----BEGIN PUBLIC KEY-----", "")
                .replace("-----END PUBLIC KEY-----", "")
                .replaceAll("\\s", "");
        byte[] der = Base64.getMimeDecoder().decode(content);   // ★ MIME 解码器
        X509EncodedKeySpec spec = new X509EncodedKeySpec(der);
        return KeyFactory.getInstance(KEY_ALGORITHM).generatePublic(spec);
    }
}