/*
 Navicat Premium Dump SQL

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80411 (8.4.11)
 Source Host           : localhost:3306
 Source Schema         : smart_device

 Target Server Type    : MySQL
 Target Server Version : 80411 (8.4.11)
 File Encoding         : 65001

 Date: 13/10/2026 08:50:12
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for device_command
-- ----------------------------
DROP TABLE IF EXISTS `device_command`;
CREATE TABLE `device_command`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `command_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '指令唯一ID(UUID)',
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '目标设备ID(MAC)',
  `action` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '动作: set/get/toggle/start/reset',
  `target` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '目标: mos/led/servo/relay/ota/config',
  `channel` int NULL DEFAULT NULL COMMENT '通道号: 0=全部, NULL=无通道',
  `params` json NULL COMMENT '指令参数',
  `qos` tinyint NULL DEFAULT 1 COMMENT 'MQTT QoS等级',
  `retain` tinyint NULL DEFAULT 0 COMMENT '是否保留消息',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态: 0-PENDING 1-SENT 2-SUCCESS 3-FAILED 4-TIMEOUT 5-CANCELLED',
  `retry_count` int NOT NULL DEFAULT 0 COMMENT '重试次数',
  `max_retry` int NOT NULL DEFAULT 3 COMMENT '最大重试次数',
  `error_msg` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '失败原因',
  `response_payload` json NULL COMMENT '设备返回的响应内容',
  `operator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'system' COMMENT '操作人',
  `source` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'WEB' COMMENT '指令来源',
  `expire_time` datetime(3) NULL DEFAULT NULL COMMENT '过期时间',
  `send_time` datetime(3) NULL DEFAULT NULL COMMENT '实际下发时间',
  `ack_time` datetime(3) NULL DEFAULT NULL COMMENT '设备响应时间',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_command_id`(`command_id` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_target`(`target` ASC) USING BTREE,
  INDEX `idx_device_status`(`device_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_target_status`(`target` ASC, `status` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  CONSTRAINT `device_command_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 74 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备下行控制指令表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for device_event_record
-- ----------------------------
DROP TABLE IF EXISTS `device_event_record`;
CREATE TABLE `device_event_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备ID(MAC)',
  `type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'event-事件, error-错误',
  `event` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '事件名',
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '事件/错误代码',
  `message` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '错误描述',
  `context` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '错误上下文',
  `target` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联外设',
  `channel` int NULL DEFAULT NULL COMMENT '关联通道号',
  `trigger_source` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '触发源',
  `payload` json NULL COMMENT '完整原始 payload',
  `timestamp` datetime(3) NOT NULL COMMENT '事件发生时间',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_device_time`(`device_id` ASC, `timestamp` ASC) USING BTREE,
  INDEX `idx_device_type`(`device_id` ASC, `type` ASC) USING BTREE,
  INDEX `idx_event`(`event` ASC) USING BTREE,
  INDEX `idx_code`(`code` ASC) USING BTREE,
  INDEX `idx_timestamp`(`timestamp` ASC) USING BTREE,
  CONSTRAINT `device_event_record_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备事件记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for device_info
-- ----------------------------
DROP TABLE IF EXISTS `device_info`;
CREATE TABLE `device_info`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备ID(MAC地址)',
  `device_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备名称',
  `product` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '产品型号',
  `firmware` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '固件版本',
  `pubkey` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '设备公钥（首次注册时写入，防冒充）',
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备位置',
  `online` tinyint NOT NULL DEFAULT 0 COMMENT '在线状态: 0-离线, 1-在线',
  `offline_reason` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '离线原因',
  `last_online_time` datetime(3) NULL DEFAULT NULL COMMENT '最近上线时间',
  `last_offline_time` datetime(3) NULL DEFAULT NULL COMMENT '最近离线时间',
  `last_heartbeat_time` datetime(3) NULL DEFAULT NULL COMMENT '最后心跳时间',
  `uptime` bigint NULL DEFAULT NULL COMMENT '运行时间(秒)',
  `capabilities` json NULL COMMENT '能力清单',
  `current_state` json NULL COMMENT '当前状态',
  `ota_state` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'OTA状态',
  `ota_progress` int NULL DEFAULT NULL COMMENT 'OTA进度',
  `ota_version` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'OTA目标版本',
  `config_version` int NULL DEFAULT NULL COMMENT '当前配置版本',
  `last_payload` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '最后一条消息原始内容',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '设备创建时间',
  `update_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '设备更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_online`(`online` ASC) USING BTREE,
  INDEX `idx_last_heartbeat`(`last_heartbeat_time` ASC) USING BTREE,
  INDEX `idx_ota_state`(`ota_state` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for device_sensor
-- ----------------------------
DROP TABLE IF EXISTS `device_sensor`;
CREATE TABLE `device_sensor`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '所属设备ID(MAC)',
  `sensor_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '传感器唯一标识',
  `sensor_id` int NULL DEFAULT NULL COMMENT '主机直连传感器编号',
  `sensor_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '传感器类型',
  `sensor_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '传感器名称',
  `source` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '数据来源: host/slave',
  `slave_address` int NULL DEFAULT NULL COMMENT '从机地址',
  `unit` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `spec` json NULL COMMENT '规格参数',
  `enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用: 0-禁用 1-启用',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_device_sensor_key`(`device_id` ASC, `sensor_key` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_sensor_type`(`sensor_type` ASC) USING BTREE,
  INDEX `idx_device_source`(`device_id` ASC, `source` ASC) USING BTREE,
  INDEX `idx_device_slave`(`device_id` ASC, `slave_address` ASC) USING BTREE,
  CONSTRAINT `device_sensor_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备传感器元数据表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for device_slave_data
-- ----------------------------
DROP TABLE IF EXISTS `device_slave_data`;
CREATE TABLE `device_slave_data`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主机设备ID(MAC)',
  `address` int NOT NULL COMMENT '从机地址(RS-485)',
  `slave_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '从机外设类型: grating_counter/odor/temperature',
  `online_since` datetime(3) NOT NULL COMMENT '本次上线时间（用于计算在线时长）',
  `value` double NULL DEFAULT NULL COMMENT '当前值',
  `unit` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `extra` json NULL COMMENT '扩展字段',
  `timestamp` datetime(3) NOT NULL COMMENT '最后采集时间',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '首次入库时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_device_addr_type`(`device_id` ASC, `address` ASC, `slave_type` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_device_type`(`device_id` ASC, `slave_type` ASC) USING BTREE,
  INDEX `idx_timestamp`(`timestamp` ASC) USING BTREE,
  CONSTRAINT `device_slave_data_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备从机数据表(在线即存在，离线即删除)' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for device_state_record
-- ----------------------------
DROP TABLE IF EXISTS `device_state_record`;
CREATE TABLE `device_state_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备ID(MAC)',
  `target` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '外设类型',
  `channel` int NULL DEFAULT NULL COMMENT '通道号',
  `params` json NOT NULL COMMENT '状态参数',
  `timestamp` datetime(3) NOT NULL COMMENT '状态发生时间',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_device_target_time`(`device_id` ASC, `target` ASC, `timestamp` ASC) USING BTREE,
  INDEX `idx_device_time`(`device_id` ASC, `timestamp` ASC) USING BTREE,
  INDEX `idx_timestamp`(`timestamp` ASC) USING BTREE,
  CONSTRAINT `device_state_record_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备状态时序表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for device_whitelist
-- ----------------------------
DROP TABLE IF EXISTS `device_whitelist`;
CREATE TABLE `device_whitelist`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备ID(MAC)',
  `batch` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '出厂批次号，用于追溯',
  `enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否允许注册: 0-禁用 1-启用',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_batch`(`batch` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备白名单（产线导入，允许注册的设备）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for firmware
-- ----------------------------
DROP TABLE IF EXISTS `firmware`;
CREATE TABLE `firmware`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `version` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '版本号',
  `product` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '产品型号',
  `release_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '发布说明',
  `url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '固件下载地址',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '原始文件名',
  `file_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '服务器保存路径',
  `md5` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'MD5',
  `sha256` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'SHA256',
  `size` bigint NOT NULL COMMENT '文件大小(字节)',
  `uploaded_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'system' COMMENT '上传人',
  `upload_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '上传时间',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_version_product`(`version` ASC, `product` ASC) USING BTREE,
  INDEX `idx_version`(`version` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '固件版本表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for heartbeat_record
-- ----------------------------
DROP TABLE IF EXISTS `heartbeat_record`;
CREATE TABLE `heartbeat_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备ID(MAC)',
  `uptime` bigint NULL DEFAULT NULL COMMENT '运行时间(秒)',
  `timestamp` datetime(3) NOT NULL COMMENT '心跳时间',
  `payload` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '消息内容',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_timestamp`(`timestamp` ASC) USING BTREE,
  CONSTRAINT `heartbeat_record_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '心跳记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for mqtt_auth
-- ----------------------------
DROP TABLE IF EXISTS `mqtt_auth`;
CREATE TABLE `mqtt_auth`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'MQTT用户名',
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'MQTT密码(明文或哈希)',
  `salt` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'MQTT密码盐值',
  `is_superuser` tinyint NOT NULL DEFAULT 0 COMMENT '是否超级用户: 1-是(服务器) 0-否(设备)',
  `enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否允许连接: 0-禁用 1-启用',
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联设备ID(MAC)，服务器账号为NULL',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_device_id`(`device_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '统一MQTT认证账号表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sensor_record
-- ----------------------------
DROP TABLE IF EXISTS `sensor_record`;
CREATE TABLE `sensor_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备ID(MAC)',
  `source` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'host' COMMENT '数据来源: host/slave',
  `slave_address` int NULL DEFAULT NULL COMMENT '从机地址(RS-485)',
  `sensor_id` int NULL DEFAULT NULL COMMENT '主机直连传感器编号',
  `channel` int NULL DEFAULT NULL COMMENT '通道号：从机内部通道 / 主机多路通道',
  `sensor_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '传感器唯一标识',
  `sensor_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '传感器类型',
  `sensor_value` double NULL DEFAULT NULL COMMENT '数值',
  `unit` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `extra` json NULL COMMENT '扩展字段',
  `sensor_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '原始数据JSON',
  `timestamp` datetime(3) NOT NULL,
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_device_time`(`device_id` ASC, `timestamp` ASC) USING BTREE,
  INDEX `idx_device_type_time`(`device_id` ASC, `sensor_type` ASC, `timestamp` ASC) USING BTREE,
  INDEX `idx_device_slave_channel_time`(`device_id` ASC, `slave_address` ASC, `channel` ASC, `timestamp` ASC) USING BTREE,
  INDEX `idx_device_sensor_time`(`device_id` ASC, `sensor_id` ASC, `timestamp` ASC) USING BTREE,
  INDEX `idx_device_key_time`(`device_id` ASC, `sensor_key` ASC, `timestamp` ASC) USING BTREE,
  INDEX `idx_timestamp`(`timestamp` ASC) USING BTREE,
  CONSTRAINT `sensor_record_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '传感器数据历史表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sensor_threshold
-- ----------------------------
DROP TABLE IF EXISTS `sensor_threshold`;
CREATE TABLE `sensor_threshold`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备ID(MAC)',
  `sensor_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '传感器唯一标识，对应 device_sensor.sensor_key',
  `sensor_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '传感器类型',
  `min_value` double NULL DEFAULT NULL COMMENT '最小值(低于则告警)',
  `max_value` double NULL DEFAULT NULL COMMENT '最大值(高于则告警)',
  `warn_min` double NULL DEFAULT NULL COMMENT '预警下限',
  `warn_max` double NULL DEFAULT NULL COMMENT '预警上限',
  `alarm_level` tinyint NOT NULL DEFAULT 1 COMMENT '告警级别: 1-提示 2-一般 3-严重',
  `alarm_message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '告警文案模板',
  `duration` int NULL DEFAULT NULL COMMENT '持续时间(秒)，超过该时长才告警',
  `enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用: 0-禁用 1-启用',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_device_sensor_key`(`device_id` ASC, `sensor_key` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_sensor_type`(`sensor_type` ASC) USING BTREE,
  CONSTRAINT `sensor_threshold_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '传感器阈值配置表' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
