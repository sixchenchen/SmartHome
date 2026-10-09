package com.womi.commonmodule.exception;

import com.womi.commonmodule.enums.ErrorCode;
import lombok.Getter;

/**
 * 业务异常
 *
 * 业务代码主动抛出，会被 GlobalExceptionHandler 捕获。
 */
@Getter
public class BusinessException extends RuntimeException {

    private final int code;

    public BusinessException(String message) {
        super(message);
        this.code = ErrorCode.BUSINESS_ERROR.getCode();
    }

    public BusinessException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.code = errorCode.getCode();
    }

    public BusinessException(ErrorCode errorCode, String message) {
        super(message);
        this.code = errorCode.getCode();
    }

    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }
}