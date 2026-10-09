package com.womi.webmodule.handler;

import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.response.ApiResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import jakarta.servlet.http.HttpServletRequest;

/**
 * 全局异常处理器
 * 统一捕获 Controller 抛出的异常，包装成 ApiResponse 返回
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    // ==================== 业务异常 ====================

    /**
     * 业务异常
     */
    @ExceptionHandler(BusinessException.class)
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<Void> handleBusinessException(BusinessException e, HttpServletRequest request) {
        log.warn("业务异常 - uri: {}, code: {}, message: {}", request.getRequestURI(), e.getCode(), e.getMessage());
        return ApiResponse.error(e.getCode(), e.getMessage());
    }

    // ==================== 参数校验异常 ====================
    /**
     * IllegalArgumentException（参数非法）
     */
    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<Void> handleIllegalArgument(IllegalArgumentException e, HttpServletRequest request) {
        log.warn("参数错误 - uri: {}, message: {}", request.getRequestURI(), e.getMessage());
        return ApiResponse.error(ErrorCode.PARAM_ERROR.getCode(), e.getMessage() != null ? e.getMessage() : ErrorCode.PARAM_ERROR.getMessage());
    }

    /**
     * IllegalStateException（状态非法）
     */
    @ExceptionHandler(IllegalStateException.class)
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<Void> handleIllegalState(IllegalStateException e, HttpServletRequest request) {
        log.warn("状态错误 - uri: {}, message: {}", request.getRequestURI(), e.getMessage());
        return ApiResponse.error(ErrorCode.BUSINESS_ERROR.getCode(), e.getMessage() != null ? e.getMessage() : ErrorCode.BUSINESS_ERROR.getMessage());
    }

    /**
     * @Valid 校验失败（RequestBody）
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<Void> handleMethodArgumentNotValid(MethodArgumentNotValidException e) {
        FieldError fieldError = e.getBindingResult().getFieldError();
        String message = fieldError != null
                ? fieldError.getField() + ": " + fieldError.getDefaultMessage()
                : ErrorCode.PARAM_INVALID.getMessage();
        log.warn("@Valid 校验失败: {}", message);
        return ApiResponse.error(ErrorCode.PARAM_INVALID.getCode(), message);
    }

    /**
     * @Valid 校验失败（表单）
     */
    @ExceptionHandler(BindException.class)
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<Void> handleBindException(BindException e) {
        FieldError fieldError = e.getBindingResult().getFieldError();
        String message = fieldError != null
                ? fieldError.getField() + ": " + fieldError.getDefaultMessage()
                : ErrorCode.PARAM_INVALID.getMessage();
        log.warn("BindException 校验失败: {}", message);
        return ApiResponse.error(ErrorCode.PARAM_INVALID.getCode(), message);
    }

    /**
     * 缺少请求参数
     */
    @ExceptionHandler(MissingServletRequestParameterException.class)
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<Void> handleMissingParam(MissingServletRequestParameterException e) {
        String message = "缺少参数: " + e.getParameterName();
        log.warn(message);
        return ApiResponse.error(ErrorCode.PARAM_MISSING.getCode(), message);
    }

    // ==================== 文件异常 ====================
    /**
     * 文件超过大小限制
     */
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<Void> handleMaxUploadSize(MaxUploadSizeExceededException e) {
        log.warn("文件超过大小限制: {}", e.getMessage());
        return ApiResponse.error(ErrorCode.FILE_TOO_LARGE.getCode(), ErrorCode.FILE_TOO_LARGE.getMessage());
    }

    // ==================== 兜底 ====================
    /**
     * 兜底：其他未捕获的异常
     */
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<Void> handleException(Exception e, HttpServletRequest request) {
        log.error("系统异常 - uri: {}", request.getRequestURI(), e);
        return ApiResponse.error(ErrorCode.SYSTEM_ERROR.getCode(), ErrorCode.SYSTEM_ERROR.getMessage());
    }
}