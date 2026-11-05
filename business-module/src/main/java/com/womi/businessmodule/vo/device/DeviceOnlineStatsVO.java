package com.womi.businessmodule.vo.device;

import lombok.Data;

/**
 * 设备在线统计
 */
@Data
public class DeviceOnlineStatsVO {

    private Long total;

    private Long online;

    private Long offline;

    /**
     * 标记在线但心跳超时的设备数
     */
    private Long abnormal;
}
