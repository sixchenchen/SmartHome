package com.womi.webmodule;


import com.womi.businessmodule.model.*;
import com.womi.businessmodule.service.*;
import com.womi.businessmodule.vo.DeviceData;
import com.womi.webmodule.schedule.CommandScheduler;
import com.womi.webmodule.service.DeviceCommandSender;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@Slf4j
@SpringBootTest
class WebModuleApplicationTests {
    @Autowired
    private DeviceInfoService deviceInfoService;
    @Autowired
    private HeartbeatRecordService heartbeatRecordService;
    @Autowired
    private MosStateRecordService mosStateRecordService;
    @Autowired
    private SensorRecordService sensorRecordService;
    @Autowired
    private SensorSlaveDataService sensorSlaveDataService;
    @Autowired
    private DeviceDataService deviceDataService;
    @Autowired
    private DeviceCommandService deviceCommandService;
    @Autowired
    private DeviceCommandSender deviceCommandSender;
    @Autowired
    private CommandScheduler commandScheduler;

    private static final String TEST_DEVICE_ID = "TEST_DEVICE_001";

    @Test
    void testAllTables() {
        log.info("========== 测试所有表 ==========");

        // 1. 测试 DeviceInfo
        testDeviceInfo();

        // 2. 测试 HeartbeatRecord
        testHeartbeatRecord();

        // 3. 测试 MosStateRecord
        testMosStateRecord();

        // 4. 测试 SensorRecord
        testSensorRecord();

        // 5. 测试 SensorSlaveData
        testSensorSlaveData();

        // 6. 测试聚合服务
        testDeviceDataService();

        // 7. 测试下行指令
        testDeviceCommand();

        log.info("========== 所有测试通过 ==========");
    }

    private void testDeviceInfo() {
        log.info("--- 测试 DeviceInfo ---");

        DeviceInfo deviceInfo = new DeviceInfo();
        deviceInfo.setDeviceId(TEST_DEVICE_ID);
        deviceInfo.setDeviceName("测试设备");
        deviceInfo.setLocation("A区");
        deviceInfo.setStatus(1);
        deviceInfo.setUptime(3600L);
        deviceInfo.setLastHeartbeatTime(LocalDateTime.now());
        deviceInfo.setLastUpdateTime(LocalDateTime.now());

        // 插入
        boolean saved = deviceInfoService.save(deviceInfo);
        assertThat(saved).isTrue();
        log.info("✅ 插入成功");

        // 查询
        DeviceInfo found = deviceInfoService.getByDeviceId(TEST_DEVICE_ID);
        assertThat(found).isNotNull();
        log.info("✅ 查询成功: {}", found.getDeviceName());

        // 更新
        found.setDeviceName("更新后的设备名");
        deviceInfoService.updateById(found);
        log.info("✅ 更新成功");
    }

    private void testHeartbeatRecord() {
        log.info("--- 测试 HeartbeatRecord ---");

        // 插入心跳记录
        for (int i = 0; i < 5; i++) {
            HeartbeatRecord record = new HeartbeatRecord();
            record.setDeviceId(TEST_DEVICE_ID);
            record.setUptime(3600L + i * 60);
            record.setPayload("{\"seq\": " + i + "}");
            record.setTimestamp(LocalDateTime.now().minusMinutes(i));
            heartbeatRecordService.save(record);
        }
        log.info("✅ 插入5条心跳记录");

        // 查询最近3条
        List<HeartbeatRecord> recent = heartbeatRecordService.getRecentByDeviceId(TEST_DEVICE_ID, 3);
        assertThat(recent).hasSize(3);
        log.info("✅ 查询最近3条记录成功");

        // 统计
        Long count = heartbeatRecordService.countByDeviceId(TEST_DEVICE_ID);
        log.info("✅ 总记录数: {}", count);
    }

    private void testMosStateRecord() {
        log.info("--- 测试 MosStateRecord ---");

        // 插入MOS状态
        Map<String, Integer> mosStates = new HashMap<>();
        for (int i = 0; i <= 7; i++) {
            mosStates.put("mos" + i, i % 2);
        }

        boolean saved = mosStateRecordService.saveMosStateRecord(TEST_DEVICE_ID, mosStates);
        assertThat(saved).isTrue();
        log.info("✅ MOS状态插入成功");

        // 查询最新
        MosStateRecord latest = mosStateRecordService.getLatestByDeviceId(TEST_DEVICE_ID);
        assertThat(latest).isNotNull();
        log.info("✅ 查询最新MOS状态成功");
    }

    private void testSensorRecord() {
        log.info("--- 测试 SensorRecord ---");

        String sensorData = "{\"temperature\": 25.5, \"humidity\": 60.2}";
        boolean saved = sensorRecordService.saveSensorRecord(TEST_DEVICE_ID, sensorData);
        assertThat(saved).isTrue();
        log.info("✅ 传感器数据插入成功");

        // 查询最新
        SensorRecord latest = sensorRecordService.getLatestByDeviceId(TEST_DEVICE_ID);
        assertThat(latest).isNotNull();
        log.info("✅ 查询最新传感器数据成功");
    }

    private void testSensorSlaveData() {
        log.info("--- 测试 SensorSlaveData ---");

        // 批量插入从机数据
        List<SensorSlaveData> slaveList = new ArrayList<>();
        for (int i = 1; i <= 8; i++) {
            SensorSlaveData slave = new SensorSlaveData();
            slave.setDeviceId(TEST_DEVICE_ID);
            slave.setAddress(i);
            slave.setOnline(i % 2 == 0 ? 1 : 0);
            slave.setCount(i * 10);
            slave.setTimestamp(LocalDateTime.now());
            slaveList.add(slave);
        }

        int inserted = sensorSlaveDataService.batchSave(slaveList);
        assertThat(inserted).isGreaterThan(0);
        log.info("✅ 批量插入{}条从机数据", inserted);

        // 查询在线从机
        List<SensorSlaveData> online = sensorSlaveDataService.getOnlineSlaves(TEST_DEVICE_ID);
        log.info("✅ 在线从机数量: {}", online.size());
    }

    private void testDeviceDataService() {
        log.info("--- 测试 DeviceData 聚合服务 ---");

        // 获取设备数据
        DeviceData deviceData = deviceDataService.getDeviceData(TEST_DEVICE_ID);
        assertThat(deviceData).isNotNull();
        log.info("✅ 获取设备数据成功");
        log.info("   - DeviceId: {}", deviceData.getDeviceId());
        log.info("   - DeviceName: {}", deviceData.getDeviceName());
        log.info("   - MOS状态: {}", deviceData.getMosStates());
        log.info("   - 从机数量: {}", deviceData.getSlaveDataList().size());
        log.info("   - 心跳历史: {}", deviceData.getHeartbeatHistory().size());
        log.info("   - MOS历史: {}", deviceData.getMosStateHistory().size());
    }

    private void testDeviceCommand() {
        log.info("--- 测试 DeviceCommand ---");

        Map<String, Object> payload = new HashMap<>();
        payload.put("mosIndex", 4);
        payload.put("action", 1);

        // 1. 下发指令（通过 DeviceCommandSender，它会入库 + 发 MQTT）
        String commandId = deviceCommandSender.sendCommand(TEST_DEVICE_ID, "MOS_CONTROL", payload, "test-runner", "TEST", 300);
        assertThat(commandId).isNotBlank();
        log.info("✅ 指令下发成功 - commandId: {}", commandId);

        // 2. 按 commandId 查询
        DeviceCommand found = deviceCommandService.getByCommandId(commandId);
        assertThat(found).isNotNull();
        assertThat(found.getDeviceId()).isEqualTo(TEST_DEVICE_ID);
        assertThat(found.getCommandType()).isEqualTo("MOS_CONTROL");
        assertThat(found.getStatus()).isIn(0, 1); // 待下发或已下发（MQTT 不通时可能停在 0）
        log.info("✅ 指令查询成功 - status: {}", found.getStatus());

        // 3. 模拟设备 ACK 成功回调
        Map<String, Object> ackResult = new HashMap<>();
        ackResult.put("mosIndex", 4);
        ackResult.put("newState", 1);
        deviceCommandService.handleAck(commandId, true, ackResult, null);

        DeviceCommand afterAck = deviceCommandService.getByCommandId(commandId);
        assertThat(afterAck.getStatus()).isEqualTo(3); // 执行成功
        assertThat(afterAck.getAckTime()).isNotNull();
        assertThat(afterAck.getResponsePayload()).containsEntry("newState", 1);
        log.info("✅ ACK 处理成功 - status: {}, ackTime: {}", afterAck.getStatus(), afterAck.getAckTime());

        // 4. 下发一条指令并模拟失败 ACK
        Map<String, Object> failPayload = new HashMap<>();
        failPayload.put("mosIndex", 5);
        failPayload.put("action", 0);

        // 🌟 改成 deviceCommandSender
        String failCmdId = deviceCommandSender.sendCommand(TEST_DEVICE_ID, "MOS_CONTROL", failPayload, "test-runner", "TEST", 300);
        deviceCommandService.handleAck(failCmdId, false, null, "GPIO write timeout");

        DeviceCommand failed = deviceCommandService.getByCommandId(failCmdId);
        assertThat(failed.getStatus()).isEqualTo(4); // 执行失败
        assertThat(failed.getErrorMsg()).isEqualTo("GPIO write timeout");
        log.info("✅ 失败 ACK 处理正确 - errorMsg: {}", failed.getErrorMsg());

        // 5. 查询设备所有指令
        List<DeviceCommand> all = deviceCommandService.listByDeviceAndStatus(TEST_DEVICE_ID, null);
        assertThat(all).isNotEmpty();
        log.info("✅ 设备指令总数: {}", all.size());

        // 6. 查询设备成功指令
        List<DeviceCommand> successList = deviceCommandService.listByDeviceAndStatus(TEST_DEVICE_ID, 3);
        assertThat(successList).isNotEmpty();
        log.info("✅ 设备成功指令数: {}", successList.size());

        // 7. 状态统计
        Map<Integer, Long> stats = deviceCommandService.countByStatus(TEST_DEVICE_ID);
        assertThat(stats).isNotEmpty();
        log.info("✅ 指令状态统计: {}", stats);

        // 8. 取消指令（新建一条后立即取消）
        // 🌟 改成 deviceCommandSender
        String cancelCmdId = deviceCommandSender.sendCommand(TEST_DEVICE_ID, "REBOOT", new HashMap<>(), "test-runner", "TEST", 300);
        DeviceCommand toCancel = deviceCommandService.getByCommandId(cancelCmdId);
        boolean cancelled = deviceCommandService.cancelCommand(toCancel.getId(), "test-runner");
        assertThat(cancelled).isTrue();

        DeviceCommand afterCancel = deviceCommandService.getByCommandId(cancelCmdId);
        assertThat(afterCancel.getStatus()).isEqualTo(6); // 已取消
        log.info("✅ 指令取消成功 - status: {}", afterCancel.getStatus());

        // 9. 手动触发调度器扫描（验证调度逻辑不抛异常）
        // 🌟 dispatchPendingCommands 已挪到 web 层，改为调用 CommandScheduler
        commandScheduler.dispatchPending();
        commandScheduler.retryTimeout();
        commandScheduler.markExpired();
        log.info("✅ 调度器扫描完成");

        // 10. 过期标记（这个还是 business 层的方法，保留）
        int expired = deviceCommandService.markExpiredCommands();
        log.info("✅ 过期标记完成 - 标记数: {}", expired);
    }
}
