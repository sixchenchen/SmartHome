package com.womi.webmodule.service.mqtt.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.sys.SysDeadLetterMapper;
import com.womi.businessmodule.model.sys.SysDeadLetter;
import com.womi.commonmodule.constants.DeviceCommandConstants;
import com.womi.commonmodule.constants.DeviceConstants;
import com.womi.webmodule.mqtt.core.MqttMessageRouter;
import com.womi.webmodule.service.mqtt.SysDeadLetterService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class SysDeadLetterServiceImpl
        extends ServiceImpl<SysDeadLetterMapper, SysDeadLetter>
        implements SysDeadLetterService {


    private final ObjectProvider<MqttMessageRouter> messageRouterProvider;

    @Override
    public void saveDeadLetter(String topic, String payload, Exception e) {
        try {
            SysDeadLetter dl = new SysDeadLetter();
            dl.setTopic(topic);
            dl.setPayload(payload);

            String errorMsg = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
            dl.setErrorMsg(errorMsg.length() > 500 ? errorMsg.substring(0, 500) : errorMsg);

            dl.setStatus(0);
            dl.setRetryCount(DeviceCommandConstants.DEFAULT_RETRY_COUNT);

            save(dl);
            log.warn("MQTT消息处理失败，已存入死信队列 - topic: {}, error: {}", topic, errorMsg);
        } catch (Exception ex) {
            log.error("死信消息入库失败！请人工排查 - topic: {}, payload: {}", topic, payload, ex);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void replay(Long id) {
        SysDeadLetter dl = getById(id);
        if (dl == null) {
            throw new IllegalArgumentException("死信记录不存在");
        }
        if (dl.getStatus() == 1) {
            throw new IllegalArgumentException("该死信已重放成功，无需重复重放");
        }

        boolean success = messageRouterProvider.getObject().route(dl.getTopic(), dl.getPayload(), 1);

        if (success) {
            dl.setStatus(1);
            dl.setErrorMsg(null);
            log.info("死信重放成功 - id: {}, topic: {}", id, dl.getTopic());
        } else {
            dl.setRetryCount(dl.getRetryCount() + 1);
            dl.setErrorMsg("重放失败，请检查 Handler 日志");
            log.warn("死信重放失败 - id: {}, 已经重试 {} 次", id, dl.getRetryCount());
            throw new RuntimeException("重放失败，请检查 Handler 日志");
        }

        dl.setUpdateTime(LocalDateTime.now());
        updateById(dl);
    }
    @Override
    public Page<SysDeadLetter> pageDeadLetters(Integer pageNum, Integer pageSize) {
        Page<SysDeadLetter> page = new Page<>(pageNum, pageSize);
        return page(page, new QueryWrapper<SysDeadLetter>().orderByDesc("create_time"));
    }
}