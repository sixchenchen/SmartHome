package com.womi.commonmodule.utils;


import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Component
public class JsonUtils {

    // 直接创建 ObjectMapper，不依赖注入
    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * JSON 字符串转 Map<String, Integer>
     */
    public Map<String, Integer> jsonToMap(String json) {
        if (json == null || json.isEmpty()) {
            return new HashMap<>();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<>() {
            });
        } catch (Exception e) {
            log.error("JSON转Map失败: {}", e.getMessage());
            return new HashMap<>();
        }
    }

    /**
     * Map 转 JSON 字符串
     */
    public String mapToJson(Map<String, Integer> map) {
        if (map == null || map.isEmpty()) {
            return "{}";
        }
        try {
            return objectMapper.writeValueAsString(map);
        } catch (Exception e) {
            log.error("Map转JSON失败: {}", e.getMessage());
            return "{}";
        }
    }

    /**
     * JSON 字符串转指定类型的对象
     */
    public <T> T jsonToObject(String json, Class<T> clazz) {
        if (json == null || json.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.readValue(json, clazz);
        } catch (Exception e) {
            log.error("JSON转对象失败: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 对象转 JSON 字符串
     */
    public String objectToJson(Object obj) {
        if (obj == null) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            log.error("对象转JSON失败: {}", e.getMessage());
            return null;
        }
    }
}