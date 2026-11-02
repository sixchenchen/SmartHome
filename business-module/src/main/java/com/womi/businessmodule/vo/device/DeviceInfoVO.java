package com.womi.businessmodule.vo.device;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.Map;

@Data
public class DeviceInfoVO {
    private Long id;
    private String deviceId;
    private String deviceName;
    private String product;
    private String firmware;
    private String location;

    // 状态与在线信息
    private Integer online;
    private LocalDateTime lastOnlineTime;
    private LocalDateTime lastOfflineTime;
    private LocalDateTime lastHeartbeatTime;
    private Long uptime;

    @TableField(value = "capabilities", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> capabilities;

    @TableField(value = "current_state", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> currentState;


    // 时间
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

}