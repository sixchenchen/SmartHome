package com.womi.businessmodule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.womi.businessmodule.model.MosStateRecord;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public interface MosStateRecordService extends IService<MosStateRecord> {

    /**
     * 保存MOS状态记录
     */
    boolean saveMosStateRecord(String deviceId, Map<String, Integer> mosStates);

    /**
     * 查询设备最近的MOS状态记录
     */
    List<MosStateRecord> getRecentByDeviceId(String deviceId, int limit);

    /**
     * 查询设备最新的MOS状态
     */
    MosStateRecord getLatestByDeviceId(String deviceId);

    /**
     * 查询设备指定时间段的MOS状态记录
     */
    List<MosStateRecord> getByTimeRange(String deviceId, LocalDateTime startTime, LocalDateTime endTime);

    /**
     * 查询设备最新的MOS状态（包含解析后的JSON）
     */
    MosStateRecord getLatestWithParsedJson(String deviceId);

    /**
     * 查询设备特定MOS通道的历史数据
     */
    List<Map<String, Object>> getMosChannelHistory(String deviceId, int mosIndex, int limit);

    /**
     * 统计设备各MOS状态出现次数
     */
    List<Map<String, Object>> countMosStatesDistribution(String deviceId, int mosIndex, int days);

    /**
     * 查询设备最新的MOS状态记录（仅查询特定通道）
     */
    Integer getLatestMosChannel(String deviceId, int mosIndex);

    /**
     * 批量保存MOS状态记录
     */
    boolean batchSave(List<MosStateRecord> records);

    /**
     * 清理过期MOS状态记录
     */
    int cleanExpiredRecords(int days);
}