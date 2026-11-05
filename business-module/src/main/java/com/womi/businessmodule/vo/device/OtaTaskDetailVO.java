package com.womi.businessmodule.vo.device;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.List;

/**
 * OTA 任务详情
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class OtaTaskDetailVO extends OtaTaskVO {

    private List<OtaTaskDeviceVO> devices;
}
