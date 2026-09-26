package com.womi.commonmodule.command;

import java.util.List;

/**
 * 指令领域常量
 */
public final class CommandConstants {
    private CommandConstants() {} // 防止实例化

    /** 指令状态 - 待下发 */
    public static final int STATUS_PENDING = 0;

    /** 指令状态 - 已下发 */
    public static final int STATUS_SENT = 1;

    /** 指令状态 - 设备已接收 */
    public static final int STATUS_RECEIVED = 2;

    /** 指令状态 - 执行成功 */
    public static final int STATUS_SUCCESS = 3;

    /** 指令状态 - 执行失败 */
    public static final int STATUS_FAILED = 4;

    /** 指令状态 - 已超时 */
    public static final int STATUS_TIMEOUT = 5;

    /** 指令状态 - 已取消 */
    public static final int STATUS_CANCELED = 6;

    /** 已结束状态集合（清理历史时保留结束态范围判定用） */
    public static final List<Integer> FINISHED_STATUSES = List.of(
            STATUS_SUCCESS, STATUS_FAILED, STATUS_TIMEOUT, STATUS_CANCELED
    );

    /** 默认过期秒数 */
    public static final int DEFAULT_EXPIRE_SECONDS = 300;

    /** 默认最大重试次数 */
    public static final int DEFAULT_MAX_RETRY = 3;

    /** 默认 QoS 等级 */
    public static final int DEFAULT_QOS = 1;

    /** 默认是否保留消息 */
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