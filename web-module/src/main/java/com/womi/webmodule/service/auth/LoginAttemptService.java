package com.womi.webmodule.service.auth;

/**
 * 账号维度登录失败计数与锁定（第三层风控）
 *
 * 仅密码错误计入账号维度：5 次锁定 15 分钟，10 次锁定 1 小时。
 * 验证码错误属于人机识别失败，不计入账号锁定，统一由限流服务按 IP/设备维度统计
 */
public interface LoginAttemptService {

    /** 检查账号是否处于锁定状态，命中直接抛业务异常 */
    void checkNotLocked(String username);

    /** 记录一次密码错误，达到阈值自动锁定 */
    void recordPasswordFailure(String username);

    /** 记录一次登录成功，清空账号失败计数与锁定 */
    void recordSuccess(String username);

    /** 查询账号剩余锁定秒数（0 表示未锁定） */
    long getLockRemainSeconds(String username);
}
