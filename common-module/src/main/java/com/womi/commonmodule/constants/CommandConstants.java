package com.womi.commonmodule.constants;

import com.womi.commonmodule.enums.CommandStatus;

import java.util.List;

/**
 * 指令领域常量
 */
public final class CommandConstants {
    private CommandConstants() {}

    /** 已结束状态集合（清理历史时使用） */
    public static final List<Integer> FINISHED_STATUSES = List.of(
            CommandStatus.SUCCESS.getCode(),
            CommandStatus.FAILED.getCode(),
            CommandStatus.TIMEOUT.getCode(),
            CommandStatus.CANCELLED.getCode()
    );
    /** 默认过期秒数 */
    public static final int DEFAULT_EXPIRE_SECONDS = 300;

    /** 默认最大重试次数 */
    public static final int DEFAULT_MAX_RETRY = 3;

    /** 默认 QoS */
    public static final int DEFAULT_QOS = 1;

    /** 默认 retain */
    public static final int DEFAULT_RETAIN = 0;

    /** 系统默认操作人 */
    public static final String DEFAULT_OPERATOR = "system";

    /** Web 接口默认操作人 */
    public static final String WEB_DEFAULT_OPERATOR = "web-user";

    /** 默认指令来源 */
    public static final String DEFAULT_SOURCE = "WEB";

    /** ACK 失败时的默认原因 */
    public static final String DEFAULT_FAIL_MSG = "设备执行失败";
}