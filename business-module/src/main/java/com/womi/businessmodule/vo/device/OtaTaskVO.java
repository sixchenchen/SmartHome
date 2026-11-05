package com.womi.businessmodule.vo.device;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 管理端 OTA 任务
 */
@Data
public class OtaTaskVO {

    private Long id;

    private Long firmwareId;

    private String targetVersion;

    private Integer totalCount;

    private Integer successCount;

    private Integer failedCount;

    private Integer pendingCount;

    private Integer status;

    private String operator;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
