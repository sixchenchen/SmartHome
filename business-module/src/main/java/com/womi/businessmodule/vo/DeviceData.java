package com.womi.businessmodule.vo;

import com.womi.businessmodule.model.HeartbeatRecord;
import com.womi.businessmodule.model.MosStateRecord;
import com.womi.businessmodule.model.SensorRecord;
import com.womi.businessmodule.model.SensorSlaveData;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Data
public class DeviceData {

    // 基础信息
    private String deviceId;
    private String deviceName;
    private String location;
    private Integer status;

    // 状态数据
    private Long uptime;
    private LocalDateTime lastHeartbeatTime;
    private LocalDateTime lastUpdateTime;
    private String lastPayload;
    private String sensorData;

    // MOS状态
    private Map<String, Integer> mosStates;

    // 从机数据
    private List<SensorSlaveData> slaveDataList;

    // 历史数据（业务内部使用）
    private List<HeartbeatRecord> heartbeatHistory;
    private List<MosStateRecord> mosStateHistory;
    private List<SensorRecord> sensorHistory;

    public DeviceData(String deviceId) {
        this.deviceId = deviceId;
        this.mosStates = new HashMap<>();
        this.slaveDataList = new ArrayList<>();
        this.heartbeatHistory = new ArrayList<>();
        this.mosStateHistory = new ArrayList<>();
        this.sensorHistory = new ArrayList<>();
        this.status = 1;  // 默认在线

        // 初始化MOS状态
        for (int i = 0; i <= 7; i++) {
            this.mosStates.put("mos" + i, 0);
        }
        this.lastUpdateTime = LocalDateTime.now();
    }

    /**
     * 更新心跳信息
     */
    public void updateHeartbeat(Long uptime, String payload) {
        this.uptime = uptime;
        this.lastHeartbeatTime = LocalDateTime.now();
        this.lastUpdateTime = LocalDateTime.now();
        this.lastPayload = payload;
        this.status = 1;  // 标记为在线
    }

    /**
     * 更新MOS状态
     */
    public void updateMosStates(Map<String, Integer> newStates) {
        if (newStates != null) {
            this.mosStates.putAll(newStates);
        }
        this.lastUpdateTime = LocalDateTime.now();
    }

    /**
     * 更新传感器数据
     */
    public void updateSensorData(String sensorData, List<SensorSlaveData> slaveList) {
        this.sensorData = sensorData;
        this.slaveDataList = slaveList;
        this.lastUpdateTime = LocalDateTime.now();
    }
}