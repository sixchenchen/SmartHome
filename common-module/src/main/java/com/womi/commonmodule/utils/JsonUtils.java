package com.womi.commonmodule.utils;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

/**
 * JSON 工具类
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JsonUtils {

    private final ObjectMapper objectMapper;

    // ==================== 解析 ====================

    /**
     * 解析 JSON 字符串为 JsonNode
     */
    public JsonNode parse(String json) {
        if (json == null || json.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.readTree(json);
        } catch (Exception e) {
            log.error("解析JSON失败: {}", e.getMessage());
            return null;
        }
    }

    // ==================== JsonNode 取值 ====================
    public String getString(JsonNode node, String field) {
        if (node == null) return null;
        JsonNode f = node.get(field);
        return (f == null || f.isNull()) ? null : f.asText();
    }

    public Integer getInt(JsonNode node, String field) {
        if (node == null) return null;
        JsonNode f = node.get(field);
        return (f == null || f.isNull()) ? null : f.asInt();
    }

    public Long getLong(JsonNode node, String field) {
        if (node == null) return null;
        JsonNode f = node.get(field);
        return (f == null || f.isNull()) ? null : f.asLong();
    }

    public Double getDouble(JsonNode node, String field) {
        if (node == null) return null;
        JsonNode f = node.get(field);
        return (f == null || f.isNull()) ? null : f.asDouble();
    }

    public Boolean getBoolean(JsonNode node, String field) {
        if (node == null) return null;
        JsonNode f = node.get(field);
        return (f == null || f.isNull()) ? null : f.asBoolean();
    }

    // ==================== JsonNode ↔ Map / Object ====================
    public Map<String, Object> nodeToMap(JsonNode node) {
        if (node == null || !node.isObject()) {
            return new HashMap<>();
        }
        try {
            return objectMapper.convertValue(node, new TypeReference<Map<String, Object>>() {});
        } catch (Exception e) {
            log.error("JsonNode转Map失败: {}", e.getMessage());
            return new HashMap<>();
        }
    }

    public <T> T nodeToObject(JsonNode node, Class<T> clazz) {
        if (node == null || node.isMissingNode() || node.isNull()) {
            return null;
        }
        try {
            return objectMapper.convertValue(node, clazz);
        } catch (Exception e) {
            log.error("JsonNode转对象失败: {}", e.getMessage());
            return null;
        }
    }

    public JsonNode objectToNode(Object obj) {
        if (obj == null) return null;
        try {
            return objectMapper.valueToTree(obj);
        } catch (Exception e) {
            log.error("对象转JsonNode失败: {}", e.getMessage());
            return null;
        }
    }

    // ==================== String ↔ Object ====================
    public Map<String, Object> jsonToMap(String json) {
        if (json == null || json.isEmpty()) return new HashMap<>();
        try {
            return objectMapper.readValue(json, new TypeReference<Map<String, Object>>() {});
        } catch (Exception e) {
            log.error("JSON转Map失败: {}", e.getMessage());
            return new HashMap<>();
        }
    }

    public Map<String, Integer> jsonToIntMap(String json) {
        if (json == null || json.isEmpty()) return new HashMap<>();
        try {
            return objectMapper.readValue(json, new TypeReference<Map<String, Integer>>() {});
        } catch (Exception e) {
            log.error("JSON转IntMap失败: {}", e.getMessage());
            return new HashMap<>();
        }
    }

    public <T> T jsonToObject(String json, Class<T> clazz) {
        if (json == null || json.isEmpty()) return null;
        try {
            return objectMapper.readValue(json, clazz);
        } catch (Exception e) {
            log.error("JSON转对象失败: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 对象转 JSON 字符串
     *
     */
    public String objectToJson(Object obj) {
        if (obj == null) return null;
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            log.error("对象转JSON失败: {}", e.getMessage());
            return null;
        }
    }
}