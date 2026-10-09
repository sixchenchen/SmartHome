package com.womi.businessmodule.service;

import com.womi.businessmodule.model.DeviceCommand;

/**
 * 指令发送器（依赖倒置接口）
 *
 * business 层定义，web 层实现。
 * business 层通过这个接口下发指令，不感知 MQTT 具体实现。
 */
public interface CommandSender {
    /**
     * 发送指令
     *
     * @param command 已入库的指令
     */
    void send(DeviceCommand command);
}