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

 Date: 16/10/2026 18:54:10
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for device_alert_record
-- ----------------------------
DROP TABLE IF EXISTS `device_alert_record`;
CREATE TABLE `device_alert_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备ID',
  `sensor_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '传感器标识',
  `alert_level` tinyint NOT NULL DEFAULT 1 COMMENT '级别:1-提示 2-一般 3-严重',
  `alert_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型: threshold/offline/fault',
  `message` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '告警消息',
  `value` double NULL DEFAULT NULL COMMENT '触发值',
  `threshold` double NULL DEFAULT NULL COMMENT '阈值',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '0-未处理 1-已确认 2-已解决',
  `handled_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处理人',
  `handled_time` datetime(3) NULL DEFAULT NULL COMMENT '处理时间',
  `timestamp` datetime(3) NOT NULL COMMENT '触发时间',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_device_time`(`device_id` ASC, `timestamp` DESC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_level`(`alert_level` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备告警记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_alert_record
-- ----------------------------

-- ----------------------------
-- Table structure for device_binding
-- ----------------------------
DROP TABLE IF EXISTS `device_binding`;
CREATE TABLE `device_binding`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备ID(MAC)',
  `active_device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci GENERATED ALWAYS AS (if((`bind_status` = 1),`device_id`,NULL)) VIRTUAL COMMENT '生成列：仅有效绑定时=device_id' NULL,
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `bind_status` tinyint NOT NULL DEFAULT 1 COMMENT '绑定状态：1有效，0解绑',
  `bind_time` datetime NULL DEFAULT NULL COMMENT '绑定时间',
  `unbind_time` datetime NULL DEFAULT NULL COMMENT '解绑时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_device_binding_active`(`active_device_id` ASC) USING BTREE,
  INDEX `idx_device_binding_device`(`device_id` ASC) USING BTREE,
  INDEX `idx_device_binding_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备绑定关系表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_binding
-- ----------------------------

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
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态: 0-PENDING 1-SENT 2-SUCCESS 3-FAILED 4-TIMEOUT 5-CANCELLED 6-ACCEPTED',
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
  CONSTRAINT `device_command_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 112 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备下行控制指令表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_command
-- ----------------------------

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
  CONSTRAINT `device_event_record_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备事件记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_event_record
-- ----------------------------

-- ----------------------------
-- Table structure for device_firmware
-- ----------------------------
DROP TABLE IF EXISTS `device_firmware`;
CREATE TABLE `device_firmware`  (
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
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '固件版本表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_firmware
-- ----------------------------

-- ----------------------------
-- Table structure for device_group
-- ----------------------------
DROP TABLE IF EXISTS `device_group`;
CREATE TABLE `device_group`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分组名',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父分组ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '归属用户ID',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_parent`(`parent_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备分组表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_group
-- ----------------------------

-- ----------------------------
-- Table structure for device_heartbeat_record
-- ----------------------------
DROP TABLE IF EXISTS `device_heartbeat_record`;
CREATE TABLE `device_heartbeat_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备ID(MAC)',
  `uptime` bigint NULL DEFAULT NULL COMMENT '运行时间(秒)',
  `timestamp` datetime(3) NOT NULL COMMENT '心跳时间',
  `payload` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '消息内容',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_device_time`(`device_id` ASC, `timestamp` DESC) USING BTREE,
  INDEX `idx_timestamp`(`timestamp` ASC) USING BTREE,
  CONSTRAINT `device_heartbeat_record_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 959 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '心跳记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_heartbeat_record
-- ----------------------------

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
  `group_id` bigint NULL DEFAULT NULL COMMENT '设备分组ID',
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
  `ota_update_time` datetime(3) NULL DEFAULT NULL COMMENT 'OTA 状态最后更新时间（用于检测僵死状态）',
  `ota_version` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'OTA目标版本',
  `config_version` int NULL DEFAULT NULL COMMENT '当前配置版本',
  `last_payload` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '最后一条消息原始内容',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '设备创建时间',
  `update_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '设备更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_online`(`online` ASC) USING BTREE,
  INDEX `idx_last_heartbeat`(`last_heartbeat_time` ASC) USING BTREE,
  INDEX `idx_ota_state`(`ota_state` ASC) USING BTREE,
  INDEX `idx_group_id`(`group_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_info
-- ----------------------------

-- ----------------------------
-- Table structure for device_mqtt_auth
-- ----------------------------
DROP TABLE IF EXISTS `device_mqtt_auth`;
CREATE TABLE `device_mqtt_auth`  (
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
-- Records of device_mqtt_auth
-- ----------------------------
INSERT INTO `device_mqtt_auth` VALUES (1, 'PROVISION_USER', 'f43c57babf15d80cd5e961e6dee8b1795dcff8805ca9a4aabc2d048d2499f172', '767f13ac5e1c4dbdddb7f4c288bb085b', 1, 1, NULL, '2026-10-15 18:36:10.738', '2026-10-15 18:36:35.665');
INSERT INTO `device_mqtt_auth` VALUES (2, 'RUNTIME_USER', 'fae340eae69a2dfad416154a5d47474ce546d2c2ba9bc57fa8c0b833a6886aff', '667f13ac5e1c4dbdddb7f4c288bb0856', 1, 1, NULL, '2026-10-15 18:36:43.369', '2026-10-15 18:38:00.270');

-- ----------------------------
-- Table structure for device_ota_task
-- ----------------------------
DROP TABLE IF EXISTS `device_ota_task`;
CREATE TABLE `device_ota_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务ID(UUID)',
  `firmware_id` bigint NOT NULL COMMENT '固件ID',
  `target_version` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '目标版本',
  `total_count` int NOT NULL DEFAULT 0 COMMENT '设备总数',
  `success_count` int NOT NULL DEFAULT 0 COMMENT '成功数',
  `failed_count` int NOT NULL DEFAULT 0 COMMENT '失败数',
  `pending_count` int NOT NULL DEFAULT 0 COMMENT '待处理数',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '0-进行中 1-已完成 2-已取消',
  `operator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_firmware`(`firmware_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'OTA 批量升级任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_ota_task
-- ----------------------------

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
  CONSTRAINT `device_sensor_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备传感器元数据表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_sensor
-- ----------------------------

-- ----------------------------
-- Table structure for device_sensor_record
-- ----------------------------
DROP TABLE IF EXISTS `device_sensor_record`;
CREATE TABLE `device_sensor_record`  (
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
  CONSTRAINT `device_sensor_record_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '传感器数据历史表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_sensor_record
-- ----------------------------

-- ----------------------------
-- Table structure for device_sensor_threshold
-- ----------------------------
DROP TABLE IF EXISTS `device_sensor_threshold`;
CREATE TABLE `device_sensor_threshold`  (
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
  CONSTRAINT `device_sensor_threshold_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '传感器阈值配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_sensor_threshold
-- ----------------------------

-- ----------------------------
-- Table structure for device_slave_data
-- ----------------------------
DROP TABLE IF EXISTS `device_slave_data`;
CREATE TABLE `device_slave_data`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主机设备ID(MAC)',
  `address` int NOT NULL COMMENT '从机地址(RS-485)',
  `slave_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '从机外设类型: grating_counter/odor/temperature',
  `channel` int NULL DEFAULT NULL COMMENT '同一从机多路同类型时使用，单通道为 NULL',
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
-- Records of device_slave_data
-- ----------------------------

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
  CONSTRAINT `device_state_record_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device_info` (`device_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备状态时序表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_state_record
-- ----------------------------

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
-- Records of device_whitelist
-- ----------------------------

-- ----------------------------
-- Table structure for sys_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `perm_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限编码，如 order:create',
  `perm_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限名称',
  `perm_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ACTION' COMMENT '权限类型：MENU/BUTTON/API/ACTION',
  `resource` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '资源，如 order',
  `action` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '动作，如 create/update/delete/read',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1启用，0禁用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否，1是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sys_permission_code`(`perm_code` ASC) USING BTREE,
  INDEX `idx_sys_permission_resource`(`resource` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_permission
-- ----------------------------

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色编码，如 ADMIN、OPS、USER',
  `role_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1启用，0禁用',
  `built_in` tinyint NOT NULL DEFAULT 0 COMMENT '是否内置：1是，0否',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否，1是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sys_role_code`(`role_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role
-- ----------------------------

-- ----------------------------
-- Table structure for sys_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sys_role_permission`(`role_id` ASC, `permission_id` ASC) USING BTREE,
  INDEX `idx_sys_role_permission_perm`(`permission_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色-权限关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_permission
-- ----------------------------

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录名',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码哈希，BCrypt/Argon2',
  `nickname` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1启用，0禁用',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否，1是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sys_user_username`(`username` ASC) USING BTREE,
  INDEX `idx_sys_user_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sys_user_role`(`user_id` ASC, `role_id` ASC) USING BTREE,
  INDEX `idx_sys_user_role_role`(`role_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户-角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
