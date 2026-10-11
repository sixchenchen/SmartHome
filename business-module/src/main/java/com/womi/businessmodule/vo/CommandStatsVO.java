package com.womi.businessmodule.vo;

import lombok.Data;

/**
 * 指令状态统计
 */
@Data
public class CommandStatsVO {

    /** 待下发数量 */
    private Long pending;

    /** 已发送数量 */
    private Long sent;

    /** 成功数量 */
    private Long success;

    /** 失败数量 */
    private Long failed;

    /** 超时数量 */
    private Long timeout;

    /** 取消数量 */
    private Long cancelled;

    /** 总数 */
    private Long total;
}