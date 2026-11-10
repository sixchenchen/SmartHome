package com.womi.commonmodule.exception;

import com.womi.commonmodule.enums.ErrorCode;

/**
 * 限流异常
 *
 * <p>由全局异常处理器转换为 HTTP 429，响应体沿用统一 {@code ApiResponse} 结构。
 * 消息保持模糊，避免向前端暴露具体限流维度。</p>
 */
public class RateLimitException extends BusinessException {

    public RateLimitException(ErrorCode errorCode) {
        super(errorCode);
    }

    public RateLimitException(ErrorCode errorCode, String message) {
        super(errorCode, message);
    }
}
