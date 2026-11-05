package com.womi.businessmodule.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 管理端用户详情
 */
@Data
public class AdminUserDetailVO extends AdminUserVO {

    private Long deviceCount;

    private Long loginCount;

    private List<String> permissions;

    private LocalDateTime updateTime;
}
