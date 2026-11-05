package com.womi.webmodule.service.mqtt;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.womi.businessmodule.vo.device.OtaTaskDetailVO;
import com.womi.businessmodule.vo.device.OtaTaskVO;

/**
 * 管理端 OTA 任务服务
 */
public interface AdminOtaTaskService {

    Page<OtaTaskVO> pageTasks(Integer pageNum, Integer pageSize, Integer status);

    OtaTaskDetailVO getTaskDetail(Long id);

    int cancelTask(Long id, String operator);
}
