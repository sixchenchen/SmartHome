package com.womi.webmodule.service.mqtt;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.vo.OtaCheckResponse;
import com.womi.businessmodule.vo.device.DeviceOtaProgressVO;
import com.womi.businessmodule.vo.device.OtaRecordVO;

public interface UserOtaService {
    OtaCheckResponse checkUpdate(Long userId, String deviceId);
    void startOta(Long userId, String deviceId);

    /**
     * 查询设备 OTA 进度
     */
    DeviceOtaProgressVO getProgress(Long userId, String deviceId);

    /**
     * 我的 OTA 升级记录
     */
    Page<OtaRecordVO> pageRecords(Long userId, String deviceId, Integer pageNum, Integer pageSize);

    /**
     * 失败重试（仅允许存在失败/超时/取消记录时重试）
     */
    void retry(Long userId, String deviceId);
}
