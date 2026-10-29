package com.womi.businessmodule.service.device.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.databind.JsonNode;
import com.womi.businessmodule.mapper.device.DeviceEventRecordMapper;
import com.womi.businessmodule.model.device.DeviceEventRecord;
import com.womi.businessmodule.service.device.DeviceEventRecordService;
import com.womi.commonmodule.constants.DeviceMqttConstants;
import com.womi.commonmodule.utils.JsonUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceEventRecordServiceImpl
        extends ServiceImpl<DeviceEventRecordMapper, DeviceEventRecord>
        implements DeviceEventRecordService {

    private final JsonUtils jsonUtils;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void recordEvent(DeviceEventRecord event) {
        if (event.getTimestamp() == null) {
            event.setTimestamp(java.time.LocalDateTime.now());
        }
        save(event);
    }

    @Override
    public List<DeviceEventRecord> listRecentByDevice(String deviceId, int limit) {
        return list(new LambdaQueryWrapper<DeviceEventRecord>()
                .eq(DeviceEventRecord::getDeviceId, deviceId)
                .orderByDesc(DeviceEventRecord::getTimestamp)
                .last("LIMIT " + limit));
    }
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void processDeviceEvent(String deviceId, JsonNode dataNode) {
        // 1. 提取 data 节点中的事件信息
        String eventType = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_TYPE);
        String eventName = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_EVENT);
        String code = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_CODE);
        String message = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_MESSAGE);
        String context = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_CONTEXT);
        String target = jsonUtils.getString(dataNode, DeviceMqttConstants.FIELD_TARGET);
        Integer channel = jsonUtils.getInt(dataNode, DeviceMqttConstants.FIELD_CHANNEL);
        String triggerSource = jsonUtils.getString(dataNode, DeviceMqttConstants.TRIGGER_SOURCE);

        // 2. 组装实体
        DeviceEventRecord record = new DeviceEventRecord();
        record.setDeviceId(deviceId);
        record.setType(eventType != null ? eventType : DeviceMqttConstants.MSG_TYPE_EVENT);
        record.setEvent(eventName);
        record.setCode(code);
        record.setMessage(message);
        record.setContext(context);
        record.setTarget(target);
        record.setChannel(channel);
        record.setTriggerSource(triggerSource);

        // 将完整的原始 data 报文作为 JSON 存入库中
        record.setPayload(jsonUtils.nodeToMap(dataNode));

        // 3. 处理事件时间 (优先取设备时间)
        Long timestampMs = jsonUtils.getLong(dataNode, DeviceMqttConstants.FIELD_TIMESTAMP);
        LocalDateTime eventTime = LocalDateTime.now();
        if (timestampMs != null && timestampMs > 0) {
            try {
                eventTime = LocalDateTime.ofInstant(Instant.ofEpochMilli(timestampMs), ZoneId.systemDefault());
            } catch (Exception e) {
                log.warn("设备上报的事件时间戳异常 - deviceId: {}, timestamp: {}", deviceId, timestampMs);
            }
        }
        record.setTimestamp(eventTime);
        record.setCreateTime(LocalDateTime.now());

        // 4. 落库
        save(record);

        // 5. 日志记录（业务级别的日志）
        if (DeviceMqttConstants.MSG_TYPE_ERROR.equalsIgnoreCase(eventType)) {
            log.error("设备上报错误 - deviceId: {}, code: {}, message: {}, 发生时间: {}",
                    deviceId, code, message, eventTime);
        } else {
            log.info("设备上报事件 - deviceId: {}, event: {}, 发生时间: {}",
                    deviceId, eventName, eventTime);
        }
    }
}