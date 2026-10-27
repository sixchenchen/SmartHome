package com.womi.businessmodule.dto;

import lombok.Data;

@Data
public class DeviceRegisterRequest {
    /** 设备 MAC */
    private String deviceId;
    /** 产品型号 */
    private String product;
    /** 固件版本 */
    private String firmware;
    /** 芯片型号 */
    private String chip;
    /** 设备外设 **/
    private String capabilities;
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