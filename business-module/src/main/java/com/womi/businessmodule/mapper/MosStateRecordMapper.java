package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.MosStateRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
public interface MosStateRecordMapper extends BaseMapper<MosStateRecord> {

    /**
     * 查询设备最近的MOS状态记录
     */
    List<MosStateRecord> selectRecentByDeviceId(@Param("deviceId") String deviceId,
                                                @Param("limit") int limit);

    /**
     * 查询设备最新的MOS状态
     */
    MosStateRecord selectLatestByDeviceId(@Param("deviceId") String deviceId);

    /**
     * 查询设备指定时间段的MOS状态记录
     */
    List<MosStateRecord> selectByTimeRange(@Param("deviceId") String deviceId,
                                           @Param("startTime") LocalDateTime startTime,
                                           @Param("endTime") LocalDateTime endTime);

    /**
     * 查询设备最新的MOS状态（包含解析后的JSON）
     */
    MosStateRecord selectLatestWithParsedJson(@Param("deviceId") String deviceId);

    /**
     * 查询设备特定MOS通道的历史数据
     */
    List<Map<String, Object>> selectMosChannelHistory(@Param("deviceId") String deviceId,
                                                      @Param("mosIndex") int mosIndex,
                                                      @Param("limit") int limit);

    /**
     * 统计设备各MOS状态出现次数
     */
    List<Map<String, Object>> countMosStatesDistribution(@Param("deviceId") String deviceId,
                                                         @Param("mosIndex") int mosIndex,
                                                         @Param("days") int days);

    /**
     * 查询设备最新的MOS状态记录（仅查询特定通道）
     */
    Integer selectLatestMosChannel(@Param("deviceId") String deviceId,
                                   @Param("mosIndex") int mosIndex);
}