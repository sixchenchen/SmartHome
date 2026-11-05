package com.womi.webmodule.service.mqtt.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.sys.SysDeadLetterMapper;
import com.womi.businessmodule.model.sys.SysDeadLetter;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.mqtt.core.MqttMessageRouter;
import com.womi.webmodule.service.mqtt.SysDeadLetterService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Objects;

@Slf4j
@Service
@RequiredArgsConstructor
public class SysDeadLetterServiceImpl
        extends ServiceImpl<SysDeadLetterMapper, SysDeadLetter>
        implements SysDeadLetterService {

    private final ObjectProvider<MqttMessageRouter> messageRouterProvider;

    @Override
    public void saveDeadLetter(String topic, String payload, Exception e, boolean isRetryable) {
        try {
            SysDeadLetter dl = new SysDeadLetter();
            dl.setTopic(topic);
            dl.setPayload(payload);
            dl.setIsRetryable(isRetryable ? 1 : 0);
            String errorMsg = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
            dl.setErrorMsg(errorMsg.length() > 500 ? errorMsg.substring(0, 500) : errorMsg);

            dl.setStatus(0);
            dl.setRetryCount(0); // 初始化重试次数

            save(dl);
            log.warn("MQTT消息处理失败，已存入死信队列 - topic: {}, error: {}", topic, errorMsg);
        } catch (Exception ex) {
            log.error("死信消息入库失败！请人工排查 - topic: {}, payload: {}", topic, payload, ex);
        }
    }

    @Override
    public void replay(Long id) {
        SysDeadLetter dl = getById(id);
        if (dl == null) {
            throw new IllegalArgumentException("死信记录不存在");
        }
        if (Objects.equals(dl.getStatus(), 1)) {
            throw new IllegalArgumentException("该死信已重放成功，无需重复重放");
        }
        // ：拦截不可重试的死信（如报文格式错误）
        if (!Objects.equals(dl.getIsRetryable(), 1)) {
            throw new BusinessException(ErrorCode.PARAM_INVALID, "该消息标记为不可重试（报文格式错误等），重放无意义；请直接废弃或修正 payload");
        }

        boolean success;
        String errorMsg = null;
        try {
            success = messageRouterProvider.getObject().route(dl.getTopic(), dl.getPayload(), 1);
        } catch (Exception e) {
            success = false;
            errorMsg = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
        }

        dl.setUpdateTime(LocalDateTime.now());

        if (success) {
            dl.setStatus(1);
            dl.setErrorMsg(null);
            updateById(dl); // 成功则先落库
            log.info("死信重放成功 - id: {}, topic: {}", id, dl.getTopic());
        } else {
            dl.setRetryCount((dl.getRetryCount() == null ? 0 : dl.getRetryCount()) + 1);
            dl.setErrorMsg(errorMsg != null ? errorMsg : "重放失败，请检查 Handler 日志");
            updateById(dl);

            log.warn("死信重放失败 - id: {}, 已经重试 {} 次", id, dl.getRetryCount());
            throw new RuntimeException("重放失败: " + dl.getErrorMsg()); // 最后再抛出异常
        }
    }

    @Override
    public Page<SysDeadLetter> pageDeadLetters(Integer pageNum, Integer pageSize) {
        Page<SysDeadLetter> page = new Page<>(pageNum, pageSize);
        return page(page, new QueryWrapper<SysDeadLetter>().orderByDesc("create_time"));
    }

    @Override
    public SysDeadLetter getDetail(Long id) {
        SysDeadLetter dl = getById(id);
        if (dl == null) {
            throw new BusinessException(ErrorCode.PARAM_INVALID, "死信记录不存在");
        }
        return dl;
    }

    @Override
    public void ignore(Long id) {
        SysDeadLetter dl = getDetail(id);
        if (Objects.equals(dl.getStatus(), 2)) {
            return;
        }
        dl.setStatus(2);
        dl.setUpdateTime(LocalDateTime.now());
        updateById(dl);
        log.info("死信已标记忽略 - id: {}, topic: {}", id, dl.getTopic());
    }
}