package com.womi.commonmodule.utils;

import lombok.extern.slf4j.Slf4j;

import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

/**
 * 数字签名验证工具
 */
@Slf4j
public final class SignatureVerifier {

    private SignatureVerifier() {}

    /**
     * ECDSA (SHA256withECDSA) 验签
     *
     * @param pem       PEM 格式公钥
     * @param signData  待验签的原始数据
     * @param signature Base64 编码的签名
     * @return true 验证通过
     */
    public static boolean verify(String pem, String signData, String signature) {
        try {
            PublicKey publicKey = parsePublicKey(pem);
            Signature verifier = Signature.getInstance("SHA256withECDSA");
            verifier.initVerify(publicKey);
            verifier.update(signData.getBytes());
            byte[] sigBytes = Base64.getDecoder().decode(signature);
            return verifier.verify(sigBytes);
        } catch (Exception e) {
            log.warn("验签失败: {}", e.getMessage());
            return false;
        }
    }

    private static PublicKey parsePublicKey(String pem) throws Exception {
        String content = pem
                .replace("-----BEGIN PUBLIC KEY-----", "")
                .replace("-----END PUBLIC KEY-----", "")
                .replaceAll("\\s", "");
        byte[] der = Base64.getDecoder().decode(content);
        X509EncodedKeySpec spec = new X509EncodedKeySpec(der);
        return KeyFactory.getInstance("EC").generatePublic(spec);
    }
}