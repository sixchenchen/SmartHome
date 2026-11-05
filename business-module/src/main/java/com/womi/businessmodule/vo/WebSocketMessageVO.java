package com.womi.businessmodule.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * WebSocket 统一消息信封
 * <p>所有实时推送均使用该结构，前端按 type 分发处理。</p>
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class WebSocketMessageVO<T> {

    /**
     * 消息类型：state / sensor / alert / ota_progress
     */
    private String type;

    private String deviceId;

    private LocalDateTime timestamp;

    private T data;

    public static <T> WebSocketMessageVO<T> of(String type, String deviceId, T data) {
        return new WebSocketMessageVO<>(type, deviceId, LocalDateTime.now(), data);
    }
}
