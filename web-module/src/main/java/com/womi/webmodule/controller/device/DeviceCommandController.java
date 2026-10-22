package com.womi.webmodule.controller.device;

import com.womi.businessmodule.model.device.DeviceCommand;
import com.womi.businessmodule.service.device.DeviceCommandService;
import com.womi.businessmodule.vo.CommandStatsVO;
import com.womi.commonmodule.constants.DeviceCommandConstants;
import com.womi.commonmodule.response.ApiResponse;
import com.womi.webmodule.dto.http.request.SendCommandRequest;
import com.womi.webmodule.service.device.DeviceControlService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/device/command")
@RequiredArgsConstructor
public class DeviceCommandController {

    private final DeviceCommandService deviceCommandService;
    private final DeviceControlService deviceControlService;

    /**
     * 下发指令
     */
    @PostMapping("/send")
    public ApiResponse<DeviceCommand> send(@RequestBody SendCommandRequest req) {
        String operator = req.getOperator() != null ?
                req.getOperator() : DeviceCommandConstants.WEB_DEFAULT_OPERATOR;

        int expireSeconds = req.getExpireSeconds() != null
                ? req.getExpireSeconds() : DeviceCommandConstants.DEFAULT_EXPIRE_SECONDS;

        DeviceCommand command = deviceControlService.sendCommand(
                req.getDeviceId(),
                req.getAction(),
                req.getTarget(),
                req.getChannel(),
                req.getParams(),
                operator,
                expireSeconds);

        log.info("指令下发请求 - commandId: {}, deviceId: {}, action: {}, target: {}", command.getCommandId(), req.getDeviceId(), req.getAction(), req.getTarget());

        return ApiResponse.success(command);
    }

    /**
     * 查询指令详情
     */
    @GetMapping("/{commandId}")
    public ApiResponse<DeviceCommand> detail(@PathVariable String commandId) {
        return ApiResponse.success(deviceCommandService.getByCommandId(commandId));
    }

    /**
     * 查询设备指令列表
     */
    @GetMapping("/list")
    public ApiResponse<List<DeviceCommand>> list(@RequestParam String deviceId,
                                                 @RequestParam(required = false) Integer status) {
        return ApiResponse.success(deviceCommandService.listByDeviceAndStatus(deviceId, status));
    }

    /**
     * 取消指令
     */
    @PostMapping("/cancel/{id}")
    public ApiResponse<Boolean> cancel(@PathVariable Long id,
                                       @RequestParam(required = false) String operator) {
        boolean ok = deviceCommandService.cancelCommand(id,
                operator != null ? operator : DeviceCommandConstants.WEB_DEFAULT_OPERATOR);
        return ApiResponse.success(ok);
    }

    /**
     * 状态统计
     */
    @GetMapping("/stats/{deviceId}")
    public ApiResponse<CommandStatsVO> stats(@PathVariable String deviceId) {
        return ApiResponse.success(deviceCommandService.statsByDevice(deviceId));
    }
}