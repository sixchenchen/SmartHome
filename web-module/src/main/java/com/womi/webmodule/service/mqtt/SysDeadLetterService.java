package com.womi.webmodule.service.mqtt;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.sys.SysDeadLetter;

public interface SysDeadLetterService extends IService<SysDeadLetter> {
    void saveDeadLetter(String topic, String payload, Exception e, boolean isRetryable);
    Page<SysDeadLetter> pageDeadLetters(Integer pageNum, Integer pageSize);

    void replay(Long id);
}