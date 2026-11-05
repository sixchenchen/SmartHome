package com.womi.businessmodule.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 登录记录
 */
@Data
public class LoginLogVO {

    private Long id;

    private String username;

    private String ip;

    private String userAgent;

    private Integer status;

    private String message;

    private LocalDateTime loginTime;
}
