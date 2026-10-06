package com.womi.businessmodule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.womi.businessmodule.model.HeartbeatRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;

@Mapper
public interface HeartbeatRecordMapper extends BaseMapper<HeartbeatRecord> {

    /**
     * 删除指定时间之前的心跳记录
     */
    int deleteBefore(@Param("time") LocalDateTime time);
}