package com.womi.webmodule.util;

import com.womi.commonmodule.constants.HttpConstants;
import com.womi.commonmodule.constants.RateLimitConstants;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.util.StringUtils;

/**
 * 客户端请求信息解析工具
 */
public final class ClientRequestUtils {

    private ClientRequestUtils() {
    }

    /**
     * 获取客户端真实 IP（兼容反向代理）
     */
    public static String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader(HttpConstants.FORWARDED_FOR);
        if (StringUtils.hasText(ip) && !HttpConstants.UNKNOWN.equalsIgnoreCase(ip)) {
            int index = ip.indexOf(',');
            return index != -1 ? ip.substring(0, index).trim() : ip.trim();
        }
        ip = request.getHeader(HttpConstants.REAL_IP);
        if (StringUtils.hasText(ip) && !HttpConstants.UNKNOWN.equalsIgnoreCase(ip)) {
            return ip.trim();
        }
        return request.getRemoteAddr();
    }

    /**
     * 解析设备指纹；未传 {@code X-Device-Id} 时降级使用 IP，避免设备维度失效
     */
    public static String resolveDeviceId(HttpServletRequest request, String ip) {
        String deviceId = request.getHeader(HttpConstants.DEVICE_ID_HEAD);
        if (!StringUtils.hasText(deviceId)) {
            return ip;
        }
        String trimmed = deviceId.trim();
        return trimmed.length() > RateLimitConstants.MAX_DEVICE_ID_LENGTH
                ? trimmed.substring(0, RateLimitConstants.MAX_DEVICE_ID_LENGTH)
                : trimmed;
    }
}
