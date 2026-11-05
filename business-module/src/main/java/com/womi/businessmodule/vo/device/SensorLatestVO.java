package com.womi.businessmodule.vo.device;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 传感器实时值
 */
@Data
public class SensorLatestVO {

    private String sensorKey;

    private String sensorType;

    private String sensorName;

    private String unit;

    private Double value;

    private LocalDateTime timestamp;
}
