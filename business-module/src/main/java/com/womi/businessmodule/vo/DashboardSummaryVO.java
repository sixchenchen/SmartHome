package com.womi.businessmodule.vo;

import lombok.Data;

/**
 * 管理端首页概览
 */
@Data
public class DashboardSummaryVO {

    private Long deviceTotal;

    private Long onlineCount;

    private Long offlineCount;

    private Long todayCommandCount;

    private Long todayFailedCount;

    /**
     * 今日指令失败率（百分比，保留两位小数）
     */
    private Double failureRate;

    private Long otaRunningCount;

    private Long unhandledAlertCount;
}
