package com.womi.webmodule.service.auth;


public interface LoginAttemptService {


     void checkNotLocked(String ip, String username);

    /**
     * 记录一次失败。达到阈值自动锁定。
     */
     void recordFailure(String ip, String username);

    /**
     * 记录一次成功。清空该 IP 下针对该账号的失败计数。
     */
     void recordSuccess(String ip, String username);

    /**
     * 查询剩余锁定秒数（0 表示未锁定）。
     */
     long getLockRemainSeconds(String username);
}