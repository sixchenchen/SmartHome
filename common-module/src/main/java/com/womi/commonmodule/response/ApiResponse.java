package com.womi.commonmodule.response;


import com.womi.commonmodule.constants.HttpConstants;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {
    private int code;
    private String message;
    private T data;
    private String timestamp;

    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(HttpConstants.SUCCESS_CODE, HttpConstants.SUCCESS_MESSAGE, data, getCurrentTimestamp());
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(HttpConstants.SUCCESS_CODE, message, data, getCurrentTimestamp()
        );
    }

    public static <T> ApiResponse<T> error(int code, String message) {
        return new ApiResponse<>(code, message, null, getCurrentTimestamp());
    }

    private static String getCurrentTimestamp() {
        return LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
    }
}