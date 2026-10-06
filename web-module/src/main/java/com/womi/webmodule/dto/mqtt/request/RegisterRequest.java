package com.womi.webmodule.dto.mqtt.request;

import lombok.Data;

@Data
public class RegisterRequest {
    /** 设备 MAC */
    private String deviceId;
    /** 产品型号 */
    private String product;
    /** 固件版本 */
    private String firmware;
    /** 芯片型号 */
    private String chip;
    /** 硬件版本 */
    private String hardwareVersion;
    /** 随机数 */
    private String nonce;
    /** 时间戳 */
    private Long timestamp;
    /** 公钥 */
    private String pubkey;
    /** 签名 */
    private String signature;
}