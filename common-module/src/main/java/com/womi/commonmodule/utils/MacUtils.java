package com.womi.commonmodule.utils;

import org.springframework.util.StringUtils;

public class MacUtils {

    /**
     * 标准化 MAC 地址：去除空格、冒号、横杠，并转为大写
     * @param mac 原始输入（如 "aa:bb:cc:dd:ee:ff" 或 "AA-BB-CC-DD-EE-FF"）
     * @return 标准化 MAC（如 "AABBCCDDEEFF"）
     */
    public static String normalize(String mac) {
        if (!StringUtils.hasText(mac)) {
            return null;
        }
        // 去除冒号、横杠、空格，并转大写
        return mac.replaceAll("[:\\-\\s]", "").toUpperCase();
    }
}