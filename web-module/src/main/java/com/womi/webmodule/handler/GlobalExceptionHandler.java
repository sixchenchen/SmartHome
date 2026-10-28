package com.womi.webmodule.handler;

import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.response.ApiResponse;
import io.swagger.v3.oas.annotations.Hidden;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.authorization.AuthorizationDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import java.nio.file.AccessDeniedException;

/**
 * 全局异常处理器
 * 统一捕获 Controller 抛出的异常，包装成 ApiResponse 返回
 */
@Slf4j
@RestControllerAdvice
@Hidden
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

    // 用户异常

    /**
     * 认证失败（账号密码错误、用户不存在、账号被锁等）
     */
    @ExceptionHandler(AuthenticationException.class)
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<Void> handleAuthenticationException(AuthenticationException e,
                                                           HttpServletRequest request) {
        log.warn("认证失败 - uri: {}, type: {}, message: {}",
                request.getRequestURI(), e.getClass().getSimpleName(), e.getMessage());

        // 账号禁用：不泄露"用户是否存在"，因为用户名不存在时抛的是 BadCredentialsException
        if (e instanceof DisabledException) {
            return ApiResponse.error(ErrorCode.ACCOUNT_DISABLED.getCode(),
                    ErrorCode.ACCOUNT_DISABLED.getMessage());
        }
        // 账号锁定：目前 SecurityUser.isAccountNonLocked() 恒为 true，这里预留
        if (e instanceof LockedException) {
            return ApiResponse.error(ErrorCode.ACCOUNT_LOCKED.getCode(),
                    ErrorCode.ACCOUNT_LOCKED.getMessage());
        }
        // 默认：统一文案，避免被枚举用户名
        return ApiResponse.error(ErrorCode.AUTH_FAILED.getCode(),
                ErrorCode.AUTH_FAILED.getMessage());
    }

    // ==================== 参数校验异常 ====================

    /**
     * IllegalArgumentException（参数非法）
     */
    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<Void> handleIllegalArgument(IllegalArgumentException e, HttpServletRequest request) {
        log.error("非业务 IllegalArgumentException（请改用 BusinessException） - uri: {}, message: {}",
                request.getRequestURI(), e.getMessage(), e);
        return ApiResponse.error(ErrorCode.PARAM_ERROR.getCode(), ErrorCode.PARAM_ERROR.getMessage());
    }

    @ExceptionHandler(IllegalStateException.class)
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<Void> handleIllegalState(IllegalStateException e, HttpServletRequest request) {
        // log 从 warn 升到 error —— 如果出现说明有人违反规约
        log.error("非业务 IllegalStateException（请改用 BusinessException） - uri: {}, message: {}",
                request.getRequestURI(), e.getMessage(), e);
        // 返回 SYSTEM_ERROR 而不是 BUSINESS_ERROR —— 因为这不是"业务规则不允许"
        return ApiResponse.error(ErrorCode.SYSTEM_ERROR.getCode(), ErrorCode.SYSTEM_ERROR.getMessage());
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

    /**
     * 处理静态资源找不到的异常（如 favicon.ico 等）
     * 避免被兜底的 Exception 捕获，减少无用的 ERROR 日志
     */
    @ExceptionHandler(NoResourceFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND) // 返回 404 状态码
    public ApiResponse<Void> handleNoResourceFound(NoResourceFoundException e, HttpServletRequest request) {
        // 使用 debug 或 warn 级别，不要用 error
        log.debug("静态资源未找到 - uri: {}", request.getRequestURI());
        return ApiResponse.error(404, "资源不存在");
    }

    /**
     * 拦截 @PreAuthorize 权限不足异常
     */
    @ExceptionHandler({AccessDeniedException.class, AuthorizationDeniedException.class})
    @ResponseStatus(HttpStatus.FORBIDDEN) // 返回 403 状态码
    public ApiResponse<Void> handleAccessDeniedException(Exception e, HttpServletRequest request) {
        log.warn("权限不足 - uri: {}, message: {}", request.getRequestURI(), e.getMessage());
        return ApiResponse.error(ErrorCode.FAIL.getCode(), "权限不足，无法访问该资源"); // 你的 ErrorCode.FAIL 是 401 还是自定义的 403，请根据实际调整
    }
    // ==================== 兜底 ====================

    /**
     * 兜底：其他未捕获的异常
     */
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ApiResponse<Void> handleException(Exception e, HttpServletRequest request) {
        log.error("系统异常 - uri: {}", request.getRequestURI(), e);
        return ApiResponse.error(ErrorCode.SYSTEM_ERROR.getCode(), ErrorCode.SYSTEM_ERROR.getMessage());
    }
}