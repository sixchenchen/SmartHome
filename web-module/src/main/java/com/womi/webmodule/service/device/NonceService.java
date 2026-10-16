package com.womi.webmodule.service.device;

/**
 * Nonce 防重放服务:用于注册接口的防重放校验，nonce 一旦被使用，短时间内不可重复。
 */
public interface NonceService {

    /**
     * 检查 nonce 是否已被使用（不消耗）
     *
     * @param nonce 随机数
     * @return true=已被使用；false=未被使用
     */
    boolean exists(String nonce);

    /**
     * 尝试占用 nonce（消耗）
     *
     * @param nonce 随机数
     * @return true=首次使用（获取成功）；false=已被使用（获取失败）
     */
    boolean tryAcquire(String nonce);
}