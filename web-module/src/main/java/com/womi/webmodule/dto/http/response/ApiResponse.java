package com.womi.webmodule.dto.http.response;


import com.womi.webmodule.dto.http.HttpStatusConstants;
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
        return new ApiResponse<>(
                HttpStatusConstants.SUCCESS_CODE,
                HttpStatusConstants.SUCCESS_MESSAGE,
                data,
                getCurrentTimestamp()
        );
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(
                HttpStatusConstants.SUCCESS_CODE,
                message,
                data,
                getCurrentTimestamp()
        );
    }

    public static <T> ApiResponse<T> error(int code, String message) {
        return new ApiResponse<>(code, message, null, getCurrentTimestamp());
    }

    private static String getCurrentTimestamp() {
        return LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
    }
}