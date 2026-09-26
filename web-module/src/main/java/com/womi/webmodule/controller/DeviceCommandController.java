package com.womi.webmodule.controller;

import com.womi.businessmodule.model.DeviceCommand;
import com.womi.businessmodule.service.DeviceCommandService;
import com.womi.commonmodule.command.CommandConstants;
import com.womi.webmodule.dto.request.SendCommandRequest;
import com.womi.webmodule.service.DeviceCommandSender;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/device/command")
@RequiredArgsConstructor
public class DeviceCommandController {

    private final DeviceCommandSender deviceCommandSender;
    private final DeviceCommandService deviceCommandService;

    /** 下发指令 */
    @PostMapping("/send")
    public String send(@RequestBody SendCommandRequest req) {
        return deviceCommandSender.sendCommand(
                req.getDeviceId(),
                req.getCommandType(),
                req.getPayload(),
                req.getOperator() != null ? req.getOperator() : CommandConstants.WEB_DEFAULT_OPERATOR,
                CommandConstants.DEFAULT_SOURCE,
                req.getExpireSeconds() != null ? req.getExpireSeconds() : CommandConstants.DEFAULT_EXPIRE_SECONDS
        );
    }

    /** 查询指令详情 */
    @GetMapping("/{commandId}")
    public DeviceCommand detail(@PathVariable String commandId) {
        return deviceCommandService.getByCommandId(commandId);
    }

    /** 查询设备指令列表 */
    @GetMapping("/list")
    public List<DeviceCommand> list(@RequestParam String deviceId,
                                    @RequestParam(required = false) Integer status) {
        return deviceCommandService.listByDeviceAndStatus(deviceId, status);
    }

    /** 取消指令 */
    @PostMapping("/cancel/{id}")
    public boolean cancel(@PathVariable Long id,
                          @RequestParam(required = false) String operator) {
        return deviceCommandService.cancelCommand(id,
                operator != null ? operator : CommandConstants.WEB_DEFAULT_OPERATOR);
    }

    /** 状态统计 */
    @GetMapping("/stats/{deviceId}")
    public Map<Integer, Long> stats(@PathVariable String deviceId) {
        return deviceCommandService.countByStatus(deviceId);
    }


}