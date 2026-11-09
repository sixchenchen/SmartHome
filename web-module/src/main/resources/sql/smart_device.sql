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

 Date: 05/11/2026 16:09:35
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
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备下行控制指令表' ROW_FORMAT = DYNAMIC;

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
  INDEX `idx_timestamp`(`timestamp` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备事件记录表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '固件版本表' ROW_FORMAT = DYNAMIC;

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
  INDEX `idx_timestamp`(`timestamp` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '心跳记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_heartbeat_record
-- ----------------------------
INSERT INTO `device_heartbeat_record` VALUES (1, 'B4BFE90CDBA1', 1440, '2026-11-05 15:49:56.443', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793864996428, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1440, \"rssi\": -63, \"free_heap\": 120332, \"voltage\": 3.26, \"core_temp\": 47.0}}', '2026-11-05 15:49:56.443');
INSERT INTO `device_heartbeat_record` VALUES (2, 'B4BFE90CDBA1', 1470, '2026-11-05 15:50:26.437', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865026431, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1470, \"rssi\": -74, \"free_heap\": 126148, \"voltage\": 3.34, \"core_temp\": 50.8}}', '2026-11-05 15:50:26.437');
INSERT INTO `device_heartbeat_record` VALUES (3, 'B4BFE90CDBA1', 1500, '2026-11-05 15:50:56.442', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865056433, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1500, \"rssi\": -74, \"free_heap\": 141587, \"voltage\": 3.36, \"core_temp\": 52.6}}', '2026-11-05 15:50:56.442');
INSERT INTO `device_heartbeat_record` VALUES (4, 'B4BFE90CDBA1', 1530, '2026-11-05 15:51:26.454', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865086444, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1530, \"rssi\": -62, \"free_heap\": 122383, \"voltage\": 3.26, \"core_temp\": 48.0}}', '2026-11-05 15:51:26.454');
INSERT INTO `device_heartbeat_record` VALUES (5, 'B4BFE90CDBA1', 1560, '2026-11-05 15:51:56.466', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865116457, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1560, \"rssi\": -57, \"free_heap\": 175255, \"voltage\": 3.24, \"core_temp\": 49.2}}', '2026-11-05 15:51:56.466');
INSERT INTO `device_heartbeat_record` VALUES (6, 'B4BFE90CDBA1', 1590, '2026-11-05 15:52:26.474', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865146467, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1590, \"rssi\": -70, \"free_heap\": 146164, \"voltage\": 3.26, \"core_temp\": 53.5}}', '2026-11-05 15:52:26.474');
INSERT INTO `device_heartbeat_record` VALUES (7, 'B4BFE90CDBA1', 1620, '2026-11-05 15:52:56.484', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865176476, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1620, \"rssi\": -59, \"free_heap\": 173350, \"voltage\": 3.29, \"core_temp\": 46.0}}', '2026-11-05 15:52:56.484');
INSERT INTO `device_heartbeat_record` VALUES (8, 'B4BFE90CDBA1', 1650, '2026-11-05 15:53:26.493', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865206487, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1650, \"rssi\": -58, \"free_heap\": 161644, \"voltage\": 3.25, \"core_temp\": 53.7}}', '2026-11-05 15:53:26.493');
INSERT INTO `device_heartbeat_record` VALUES (9, 'B4BFE90CDBA1', 1680, '2026-11-05 15:53:56.510', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865236501, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1680, \"rssi\": -74, \"free_heap\": 125927, \"voltage\": 3.34, \"core_temp\": 48.5}}', '2026-11-05 15:53:56.510');
INSERT INTO `device_heartbeat_record` VALUES (10, 'B4BFE90CDBA1', 1710, '2026-11-05 15:54:26.517', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865266510, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1710, \"rssi\": -66, \"free_heap\": 143211, \"voltage\": 3.34, \"core_temp\": 54.2}}', '2026-11-05 15:54:26.517');
INSERT INTO `device_heartbeat_record` VALUES (11, 'B4BFE90CDBA1', 1740, '2026-11-05 15:54:56.526', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865296521, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1740, \"rssi\": -63, \"free_heap\": 178611, \"voltage\": 3.24, \"core_temp\": 54.2}}', '2026-11-05 15:54:56.526');
INSERT INTO `device_heartbeat_record` VALUES (12, 'B4BFE90CDBA1', 1770, '2026-11-05 15:55:26.539', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865326535, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1770, \"rssi\": -59, \"free_heap\": 145906, \"voltage\": 3.2, \"core_temp\": 47.6}}', '2026-11-05 15:55:26.539');
INSERT INTO `device_heartbeat_record` VALUES (13, 'B4BFE90CDBA1', 1800, '2026-11-05 15:55:56.557', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865356550, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1800, \"rssi\": -74, \"free_heap\": 145540, \"voltage\": 3.21, \"core_temp\": 52.7}}', '2026-11-05 15:55:56.557');
INSERT INTO `device_heartbeat_record` VALUES (14, 'B4BFE90CDBA1', 1830, '2026-11-05 15:56:26.579', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865386565, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1830, \"rssi\": -74, \"free_heap\": 124270, \"voltage\": 3.22, \"core_temp\": 53.0}}', '2026-11-05 15:56:26.579');
INSERT INTO `device_heartbeat_record` VALUES (15, 'B4BFE90CDBA1', 1860, '2026-11-05 15:56:56.580', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865416573, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1860, \"rssi\": -64, \"free_heap\": 155994, \"voltage\": 3.23, \"core_temp\": 51.5}}', '2026-11-05 15:56:56.580');
INSERT INTO `device_heartbeat_record` VALUES (16, 'B4BFE90CDBA1', 1890, '2026-11-05 15:57:26.588', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865446581, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1890, \"rssi\": -71, \"free_heap\": 140633, \"voltage\": 3.35, \"core_temp\": 45.9}}', '2026-11-05 15:57:26.589');
INSERT INTO `device_heartbeat_record` VALUES (17, 'B4BFE90CDBA1', 1920, '2026-11-05 15:57:56.602', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865476595, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1920, \"rssi\": -56, \"free_heap\": 140986, \"voltage\": 3.29, \"core_temp\": 50.3}}', '2026-11-05 15:57:56.602');
INSERT INTO `device_heartbeat_record` VALUES (18, 'B4BFE90CDBA1', 1950, '2026-11-05 15:58:26.609', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865506600, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1950, \"rssi\": -60, \"free_heap\": 128507, \"voltage\": 3.29, \"core_temp\": 48.4}}', '2026-11-05 15:58:26.612');
INSERT INTO `device_heartbeat_record` VALUES (19, 'B4BFE90CDBA1', 1980, '2026-11-05 15:58:56.616', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865536612, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1980, \"rssi\": -56, \"free_heap\": 143499, \"voltage\": 3.26, \"core_temp\": 49.2}}', '2026-11-05 15:58:56.616');
INSERT INTO `device_heartbeat_record` VALUES (20, 'B4BFE90CDBA1', 2010, '2026-11-05 15:59:26.641', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865566628, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2010, \"rssi\": -71, \"free_heap\": 167269, \"voltage\": 3.25, \"core_temp\": 51.8}}', '2026-11-05 15:59:26.641');
INSERT INTO `device_heartbeat_record` VALUES (21, 'B4BFE90CDBA1', 2040, '2026-11-05 15:59:56.656', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865596646, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2040, \"rssi\": -74, \"free_heap\": 160717, \"voltage\": 3.35, \"core_temp\": 45.8}}', '2026-11-05 15:59:56.656');
INSERT INTO `device_heartbeat_record` VALUES (22, 'B4BFE90CDBA1', 2070, '2026-11-05 16:00:26.658', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865626652, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2070, \"rssi\": -66, \"free_heap\": 146331, \"voltage\": 3.31, \"core_temp\": 47.0}}', '2026-11-05 16:00:26.658');
INSERT INTO `device_heartbeat_record` VALUES (23, 'B4BFE90CDBA1', 2100, '2026-11-05 16:00:56.660', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865656653, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2100, \"rssi\": -75, \"free_heap\": 133347, \"voltage\": 3.38, \"core_temp\": 49.3}}', '2026-11-05 16:00:56.661');
INSERT INTO `device_heartbeat_record` VALUES (24, 'B4BFE90CDBA1', 2130, '2026-11-05 16:01:26.671', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865686662, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2130, \"rssi\": -58, \"free_heap\": 141763, \"voltage\": 3.33, \"core_temp\": 47.3}}', '2026-11-05 16:01:26.671');
INSERT INTO `device_heartbeat_record` VALUES (25, 'B4BFE90CDBA1', 2160, '2026-11-05 16:01:56.675', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865716665, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2160, \"rssi\": -61, \"free_heap\": 170780, \"voltage\": 3.22, \"core_temp\": 53.3}}', '2026-11-05 16:01:56.675');
INSERT INTO `device_heartbeat_record` VALUES (26, 'B4BFE90CDBA1', 2190, '2026-11-05 16:02:26.681', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865746669, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2190, \"rssi\": -65, \"free_heap\": 161415, \"voltage\": 3.37, \"core_temp\": 45.4}}', '2026-11-05 16:02:26.681');
INSERT INTO `device_heartbeat_record` VALUES (27, 'B4BFE90CDBA1', 2220, '2026-11-05 16:02:56.681', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865776671, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2220, \"rssi\": -65, \"free_heap\": 173688, \"voltage\": 3.34, \"core_temp\": 47.7}}', '2026-11-05 16:02:56.682');
INSERT INTO `device_heartbeat_record` VALUES (28, 'B4BFE90CDBA1', 2250, '2026-11-05 16:03:26.690', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865806683, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2250, \"rssi\": -63, \"free_heap\": 150195, \"voltage\": 3.37, \"core_temp\": 53.6}}', '2026-11-05 16:03:26.690');
INSERT INTO `device_heartbeat_record` VALUES (29, 'B4BFE90CDBA1', 2280, '2026-11-05 16:03:56.698', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865836686, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2280, \"rssi\": -72, \"free_heap\": 139385, \"voltage\": 3.37, \"core_temp\": 49.4}}', '2026-11-05 16:03:56.699');
INSERT INTO `device_heartbeat_record` VALUES (30, 'B4BFE90CDBA1', 2310, '2026-11-05 16:04:26.705', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865866691, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2310, \"rssi\": -61, \"free_heap\": 167658, \"voltage\": 3.29, \"core_temp\": 45.5}}', '2026-11-05 16:04:26.706');
INSERT INTO `device_heartbeat_record` VALUES (31, 'B4BFE90CDBA1', 2340, '2026-11-05 16:04:56.711', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865896704, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2340, \"rssi\": -63, \"free_heap\": 140302, \"voltage\": 3.31, \"core_temp\": 54.4}}', '2026-11-05 16:04:56.712');
INSERT INTO `device_heartbeat_record` VALUES (32, 'B4BFE90CDBA1', 2370, '2026-11-05 16:05:26.719', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865926710, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2370, \"rssi\": -75, \"free_heap\": 170993, \"voltage\": 3.3, \"core_temp\": 47.6}}', '2026-11-05 16:05:26.719');
INSERT INTO `device_heartbeat_record` VALUES (33, 'B4BFE90CDBA1', 2400, '2026-11-05 16:05:56.723', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865956715, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2400, \"rssi\": -65, \"free_heap\": 166070, \"voltage\": 3.22, \"core_temp\": 53.0}}', '2026-11-05 16:05:56.723');
INSERT INTO `device_heartbeat_record` VALUES (34, 'B4BFE90CDBA1', 2430, '2026-11-05 16:06:26.735', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793865986726, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2430, \"rssi\": -57, \"free_heap\": 137357, \"voltage\": 3.37, \"core_temp\": 51.6}}', '2026-11-05 16:06:26.735');
INSERT INTO `device_heartbeat_record` VALUES (35, 'B4BFE90CDBA1', 2460, '2026-11-05 16:06:56.737', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793866016728, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2460, \"rssi\": -61, \"free_heap\": 134820, \"voltage\": 3.28, \"core_temp\": 54.4}}', '2026-11-05 16:06:56.738');
INSERT INTO `device_heartbeat_record` VALUES (36, 'B4BFE90CDBA1', 2490, '2026-11-05 16:07:26.742', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793866046736, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2490, \"rssi\": -58, \"free_heap\": 170154, \"voltage\": 3.22, \"core_temp\": 51.2}}', '2026-11-05 16:07:26.742');
INSERT INTO `device_heartbeat_record` VALUES (37, 'B4BFE90CDBA1', 2520, '2026-11-05 16:07:56.756', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793866076745, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2520, \"rssi\": -68, \"free_heap\": 169000, \"voltage\": 3.31, \"core_temp\": 51.7}}', '2026-11-05 16:07:56.756');
INSERT INTO `device_heartbeat_record` VALUES (38, 'B4BFE90CDBA1', 2550, '2026-11-05 16:08:26.756', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793866106749, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2550, \"rssi\": -56, \"free_heap\": 153897, \"voltage\": 3.36, \"core_temp\": 50.5}}', '2026-11-05 16:08:26.756');
INSERT INTO `device_heartbeat_record` VALUES (39, 'B4BFE90CDBA1', 2580, '2026-11-05 16:08:56.771', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793866136763, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2580, \"rssi\": -56, \"free_heap\": 152602, \"voltage\": 3.26, \"core_temp\": 48.7}}', '2026-11-05 16:08:56.772');
INSERT INTO `device_heartbeat_record` VALUES (40, 'B4BFE90CDBA1', 2610, '2026-11-05 16:09:26.780', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793866166772, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2610, \"rssi\": -69, \"free_heap\": 166731, \"voltage\": 3.34, \"core_temp\": 45.6}}', '2026-11-05 16:09:26.781');

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
  `bind_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备绑定码(用于扫码绑定)',
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
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0=未删除，非0=删除时间戳/主键ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_device_id_deleted`(`device_id` ASC, `deleted` ASC) USING BTREE,
  UNIQUE INDEX `uk_bind_code_deleted`(`bind_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_online`(`online` ASC) USING BTREE,
  INDEX `idx_last_heartbeat`(`last_heartbeat_time` ASC) USING BTREE,
  INDEX `idx_ota_state`(`ota_state` ASC) USING BTREE,
  INDEX `idx_group_id`(`group_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备信息表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '统一MQTT认证账号表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_mqtt_auth
-- ----------------------------

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
  INDEX `idx_device_slave`(`device_id` ASC, `slave_address` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备传感器元数据表' ROW_FORMAT = DYNAMIC;

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
  INDEX `idx_timestamp`(`timestamp` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1201 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '传感器数据历史表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_sensor_record
-- ----------------------------
INSERT INTO `device_sensor_record` VALUES (1, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:49:37.316', '2026-11-05 15:49:37.316');
INSERT INTO `device_sensor_record` VALUES (2, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.2, '%', NULL, NULL, '2026-11-05 15:49:37.316', '2026-11-05 15:49:37.316');
INSERT INTO `device_sensor_record` VALUES (3, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:49:37.316', '2026-11-05 15:49:37.316');
INSERT INTO `device_sensor_record` VALUES (4, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 513.2, 'ppm', NULL, NULL, '2026-11-05 15:49:37.316', '2026-11-05 15:49:37.316');
INSERT INTO `device_sensor_record` VALUES (5, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 712.4, 'lx', NULL, NULL, '2026-11-05 15:49:37.316', '2026-11-05 15:49:37.316');
INSERT INTO `device_sensor_record` VALUES (6, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.5, '℃', NULL, NULL, '2026-11-05 15:49:37.316', '2026-11-05 15:49:37.316');
INSERT INTO `device_sensor_record` VALUES (7, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-05 15:49:37.316', '2026-11-05 15:49:37.316');
INSERT INTO `device_sensor_record` VALUES (8, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.3, '℃', NULL, NULL, '2026-11-05 15:49:37.316', '2026-11-05 15:49:37.316');
INSERT INTO `device_sensor_record` VALUES (9, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.29, 'V', NULL, NULL, '2026-11-05 15:49:37.316', '2026-11-05 15:49:37.316');
INSERT INTO `device_sensor_record` VALUES (10, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 173947, 'bytes', NULL, NULL, '2026-11-05 15:49:37.316', '2026-11-05 15:49:37.316');
INSERT INTO `device_sensor_record` VALUES (11, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-05 15:49:47.323', '2026-11-05 15:49:47.323');
INSERT INTO `device_sensor_record` VALUES (12, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.5, '%', NULL, NULL, '2026-11-05 15:49:47.323', '2026-11-05 15:49:47.323');
INSERT INTO `device_sensor_record` VALUES (13, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 28.8, 'μg/m³', NULL, NULL, '2026-11-05 15:49:47.323', '2026-11-05 15:49:47.323');
INSERT INTO `device_sensor_record` VALUES (14, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 421.4, 'ppm', NULL, NULL, '2026-11-05 15:49:47.323', '2026-11-05 15:49:47.323');
INSERT INTO `device_sensor_record` VALUES (15, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 751.2, 'lx', NULL, NULL, '2026-11-05 15:49:47.323', '2026-11-05 15:49:47.323');
INSERT INTO `device_sensor_record` VALUES (16, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-05 15:49:47.323', '2026-11-05 15:49:47.323');
INSERT INTO `device_sensor_record` VALUES (17, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-05 15:49:47.323', '2026-11-05 15:49:47.323');
INSERT INTO `device_sensor_record` VALUES (18, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.8, '℃', NULL, NULL, '2026-11-05 15:49:47.323', '2026-11-05 15:49:47.323');
INSERT INTO `device_sensor_record` VALUES (19, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-05 15:49:47.323', '2026-11-05 15:49:47.323');
INSERT INTO `device_sensor_record` VALUES (20, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 150858, 'bytes', NULL, NULL, '2026-11-05 15:49:47.323', '2026-11-05 15:49:47.323');
INSERT INTO `device_sensor_record` VALUES (21, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.3, '℃', NULL, NULL, '2026-11-05 15:49:57.334', '2026-11-05 15:49:57.334');
INSERT INTO `device_sensor_record` VALUES (22, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60.8, '%', NULL, NULL, '2026-11-05 15:49:57.334', '2026-11-05 15:49:57.334');
INSERT INTO `device_sensor_record` VALUES (23, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 20.6, 'μg/m³', NULL, NULL, '2026-11-05 15:49:57.334', '2026-11-05 15:49:57.334');
INSERT INTO `device_sensor_record` VALUES (24, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 507.7, 'ppm', NULL, NULL, '2026-11-05 15:49:57.334', '2026-11-05 15:49:57.334');
INSERT INTO `device_sensor_record` VALUES (25, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 310.7, 'lx', NULL, NULL, '2026-11-05 15:49:57.334', '2026-11-05 15:49:57.334');
INSERT INTO `device_sensor_record` VALUES (26, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-05 15:49:57.334', '2026-11-05 15:49:57.334');
INSERT INTO `device_sensor_record` VALUES (27, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-05 15:49:57.334', '2026-11-05 15:49:57.334');
INSERT INTO `device_sensor_record` VALUES (28, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.7, '℃', NULL, NULL, '2026-11-05 15:49:57.334', '2026-11-05 15:49:57.334');
INSERT INTO `device_sensor_record` VALUES (29, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-05 15:49:57.334', '2026-11-05 15:49:57.334');
INSERT INTO `device_sensor_record` VALUES (30, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 177274, 'bytes', NULL, NULL, '2026-11-05 15:49:57.334', '2026-11-05 15:49:57.334');
INSERT INTO `device_sensor_record` VALUES (31, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-05 15:50:07.346', '2026-11-05 15:50:07.346');
INSERT INTO `device_sensor_record` VALUES (32, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62.9, '%', NULL, NULL, '2026-11-05 15:50:07.346', '2026-11-05 15:50:07.346');
INSERT INTO `device_sensor_record` VALUES (33, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 45, 'μg/m³', NULL, NULL, '2026-11-05 15:50:07.346', '2026-11-05 15:50:07.346');
INSERT INTO `device_sensor_record` VALUES (34, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 457.8, 'ppm', NULL, NULL, '2026-11-05 15:50:07.346', '2026-11-05 15:50:07.346');
INSERT INTO `device_sensor_record` VALUES (35, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 706, 'lx', NULL, NULL, '2026-11-05 15:50:07.346', '2026-11-05 15:50:07.346');
INSERT INTO `device_sensor_record` VALUES (36, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-05 15:50:07.346', '2026-11-05 15:50:07.346');
INSERT INTO `device_sensor_record` VALUES (37, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.2, '℃', NULL, NULL, '2026-11-05 15:50:07.346', '2026-11-05 15:50:07.346');
INSERT INTO `device_sensor_record` VALUES (38, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.1, '℃', NULL, NULL, '2026-11-05 15:50:07.346', '2026-11-05 15:50:07.346');
INSERT INTO `device_sensor_record` VALUES (39, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-05 15:50:07.346', '2026-11-05 15:50:07.346');
INSERT INTO `device_sensor_record` VALUES (40, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 162791, 'bytes', NULL, NULL, '2026-11-05 15:50:07.346', '2026-11-05 15:50:07.346');
INSERT INTO `device_sensor_record` VALUES (41, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-05 15:50:17.360', '2026-11-05 15:50:17.360');
INSERT INTO `device_sensor_record` VALUES (42, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 51.8, '%', NULL, NULL, '2026-11-05 15:50:17.360', '2026-11-05 15:50:17.360');
INSERT INTO `device_sensor_record` VALUES (43, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 49.8, 'μg/m³', NULL, NULL, '2026-11-05 15:50:17.360', '2026-11-05 15:50:17.360');
INSERT INTO `device_sensor_record` VALUES (44, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 562.2, 'ppm', NULL, NULL, '2026-11-05 15:50:17.360', '2026-11-05 15:50:17.360');
INSERT INTO `device_sensor_record` VALUES (45, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 797.2, 'lx', NULL, NULL, '2026-11-05 15:50:17.360', '2026-11-05 15:50:17.360');
INSERT INTO `device_sensor_record` VALUES (46, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-05 15:50:17.360', '2026-11-05 15:50:17.360');
INSERT INTO `device_sensor_record` VALUES (47, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-05 15:50:17.360', '2026-11-05 15:50:17.360');
INSERT INTO `device_sensor_record` VALUES (48, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.8, '℃', NULL, NULL, '2026-11-05 15:50:17.360', '2026-11-05 15:50:17.360');
INSERT INTO `device_sensor_record` VALUES (49, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.39, 'V', NULL, NULL, '2026-11-05 15:50:17.360', '2026-11-05 15:50:17.360');
INSERT INTO `device_sensor_record` VALUES (50, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 142190, 'bytes', NULL, NULL, '2026-11-05 15:50:17.360', '2026-11-05 15:50:17.360');
INSERT INTO `device_sensor_record` VALUES (51, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:50:27.365', '2026-11-05 15:50:27.365');
INSERT INTO `device_sensor_record` VALUES (52, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64.1, '%', NULL, NULL, '2026-11-05 15:50:27.365', '2026-11-05 15:50:27.365');
INSERT INTO `device_sensor_record` VALUES (53, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:50:27.365', '2026-11-05 15:50:27.365');
INSERT INTO `device_sensor_record` VALUES (54, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 467.3, 'ppm', NULL, NULL, '2026-11-05 15:50:27.365', '2026-11-05 15:50:27.365');
INSERT INTO `device_sensor_record` VALUES (55, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 602.4, 'lx', NULL, NULL, '2026-11-05 15:50:27.365', '2026-11-05 15:50:27.365');
INSERT INTO `device_sensor_record` VALUES (56, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-05 15:50:27.365', '2026-11-05 15:50:27.365');
INSERT INTO `device_sensor_record` VALUES (57, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25, '℃', NULL, NULL, '2026-11-05 15:50:27.365', '2026-11-05 15:50:27.365');
INSERT INTO `device_sensor_record` VALUES (58, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.2, '℃', NULL, NULL, '2026-11-05 15:50:27.365', '2026-11-05 15:50:27.365');
INSERT INTO `device_sensor_record` VALUES (59, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-05 15:50:27.365', '2026-11-05 15:50:27.365');
INSERT INTO `device_sensor_record` VALUES (60, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 158129, 'bytes', NULL, NULL, '2026-11-05 15:50:27.365', '2026-11-05 15:50:27.365');
INSERT INTO `device_sensor_record` VALUES (61, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24, '℃', NULL, NULL, '2026-11-05 15:50:37.369', '2026-11-05 15:50:37.369');
INSERT INTO `device_sensor_record` VALUES (62, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64.4, '%', NULL, NULL, '2026-11-05 15:50:37.369', '2026-11-05 15:50:37.369');
INSERT INTO `device_sensor_record` VALUES (63, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 22.4, 'μg/m³', NULL, NULL, '2026-11-05 15:50:37.369', '2026-11-05 15:50:37.369');
INSERT INTO `device_sensor_record` VALUES (64, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 451.1, 'ppm', NULL, NULL, '2026-11-05 15:50:37.369', '2026-11-05 15:50:37.369');
INSERT INTO `device_sensor_record` VALUES (65, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 633.7, 'lx', NULL, NULL, '2026-11-05 15:50:37.369', '2026-11-05 15:50:37.369');
INSERT INTO `device_sensor_record` VALUES (66, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.1, '℃', NULL, NULL, '2026-11-05 15:50:37.369', '2026-11-05 15:50:37.369');
INSERT INTO `device_sensor_record` VALUES (67, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25, '℃', NULL, NULL, '2026-11-05 15:50:37.369', '2026-11-05 15:50:37.369');
INSERT INTO `device_sensor_record` VALUES (68, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.7, '℃', NULL, NULL, '2026-11-05 15:50:37.369', '2026-11-05 15:50:37.369');
INSERT INTO `device_sensor_record` VALUES (69, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-05 15:50:37.369', '2026-11-05 15:50:37.369');
INSERT INTO `device_sensor_record` VALUES (70, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 160299, 'bytes', NULL, NULL, '2026-11-05 15:50:37.369', '2026-11-05 15:50:37.369');
INSERT INTO `device_sensor_record` VALUES (71, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.7, '℃', NULL, NULL, '2026-11-05 15:50:47.374', '2026-11-05 15:50:47.374');
INSERT INTO `device_sensor_record` VALUES (72, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.8, '%', NULL, NULL, '2026-11-05 15:50:47.374', '2026-11-05 15:50:47.374');
INSERT INTO `device_sensor_record` VALUES (73, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 47.7, 'μg/m³', NULL, NULL, '2026-11-05 15:50:47.374', '2026-11-05 15:50:47.374');
INSERT INTO `device_sensor_record` VALUES (74, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 473.2, 'ppm', NULL, NULL, '2026-11-05 15:50:47.374', '2026-11-05 15:50:47.374');
INSERT INTO `device_sensor_record` VALUES (75, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 481.3, 'lx', NULL, NULL, '2026-11-05 15:50:47.374', '2026-11-05 15:50:47.374');
INSERT INTO `device_sensor_record` VALUES (76, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-05 15:50:47.374', '2026-11-05 15:50:47.374');
INSERT INTO `device_sensor_record` VALUES (77, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.4, '℃', NULL, NULL, '2026-11-05 15:50:47.374', '2026-11-05 15:50:47.374');
INSERT INTO `device_sensor_record` VALUES (78, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46, '℃', NULL, NULL, '2026-11-05 15:50:47.374', '2026-11-05 15:50:47.374');
INSERT INTO `device_sensor_record` VALUES (79, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-05 15:50:47.374', '2026-11-05 15:50:47.374');
INSERT INTO `device_sensor_record` VALUES (80, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 177047, 'bytes', NULL, NULL, '2026-11-05 15:50:47.374', '2026-11-05 15:50:47.374');
INSERT INTO `device_sensor_record` VALUES (81, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.5, '℃', NULL, NULL, '2026-11-05 15:50:57.386', '2026-11-05 15:50:57.386');
INSERT INTO `device_sensor_record` VALUES (82, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 57, '%', NULL, NULL, '2026-11-05 15:50:57.386', '2026-11-05 15:50:57.386');
INSERT INTO `device_sensor_record` VALUES (83, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 22.8, 'μg/m³', NULL, NULL, '2026-11-05 15:50:57.386', '2026-11-05 15:50:57.386');
INSERT INTO `device_sensor_record` VALUES (84, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 537.6, 'ppm', NULL, NULL, '2026-11-05 15:50:57.386', '2026-11-05 15:50:57.386');
INSERT INTO `device_sensor_record` VALUES (85, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 181.5, 'lx', NULL, NULL, '2026-11-05 15:50:57.386', '2026-11-05 15:50:57.386');
INSERT INTO `device_sensor_record` VALUES (86, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.6, '℃', NULL, NULL, '2026-11-05 15:50:57.386', '2026-11-05 15:50:57.386');
INSERT INTO `device_sensor_record` VALUES (87, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.7, '℃', NULL, NULL, '2026-11-05 15:50:57.386', '2026-11-05 15:50:57.386');
INSERT INTO `device_sensor_record` VALUES (88, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.8, '℃', NULL, NULL, '2026-11-05 15:50:57.386', '2026-11-05 15:50:57.386');
INSERT INTO `device_sensor_record` VALUES (89, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-05 15:50:57.386', '2026-11-05 15:50:57.386');
INSERT INTO `device_sensor_record` VALUES (90, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 158250, 'bytes', NULL, NULL, '2026-11-05 15:50:57.386', '2026-11-05 15:50:57.386');
INSERT INTO `device_sensor_record` VALUES (91, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.1, '℃', NULL, NULL, '2026-11-05 15:51:07.391', '2026-11-05 15:51:07.391');
INSERT INTO `device_sensor_record` VALUES (92, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.1, '%', NULL, NULL, '2026-11-05 15:51:07.391', '2026-11-05 15:51:07.391');
INSERT INTO `device_sensor_record` VALUES (93, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 42.3, 'μg/m³', NULL, NULL, '2026-11-05 15:51:07.391', '2026-11-05 15:51:07.391');
INSERT INTO `device_sensor_record` VALUES (94, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 503.2, 'ppm', NULL, NULL, '2026-11-05 15:51:07.391', '2026-11-05 15:51:07.391');
INSERT INTO `device_sensor_record` VALUES (95, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 553.2, 'lx', NULL, NULL, '2026-11-05 15:51:07.391', '2026-11-05 15:51:07.391');
INSERT INTO `device_sensor_record` VALUES (96, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.1, '℃', NULL, NULL, '2026-11-05 15:51:07.391', '2026-11-05 15:51:07.391');
INSERT INTO `device_sensor_record` VALUES (97, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-05 15:51:07.391', '2026-11-05 15:51:07.391');
INSERT INTO `device_sensor_record` VALUES (98, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.1, '℃', NULL, NULL, '2026-11-05 15:51:07.391', '2026-11-05 15:51:07.391');
INSERT INTO `device_sensor_record` VALUES (99, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-05 15:51:07.391', '2026-11-05 15:51:07.391');
INSERT INTO `device_sensor_record` VALUES (100, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 161239, 'bytes', NULL, NULL, '2026-11-05 15:51:07.391', '2026-11-05 15:51:07.391');
INSERT INTO `device_sensor_record` VALUES (101, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:51:17.407', '2026-11-05 15:51:17.407');
INSERT INTO `device_sensor_record` VALUES (102, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.5, '%', NULL, NULL, '2026-11-05 15:51:17.407', '2026-11-05 15:51:17.407');
INSERT INTO `device_sensor_record` VALUES (103, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:51:17.407', '2026-11-05 15:51:17.407');
INSERT INTO `device_sensor_record` VALUES (104, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 570.6, 'ppm', NULL, NULL, '2026-11-05 15:51:17.407', '2026-11-05 15:51:17.407');
INSERT INTO `device_sensor_record` VALUES (105, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 188.3, 'lx', NULL, NULL, '2026-11-05 15:51:17.407', '2026-11-05 15:51:17.407');
INSERT INTO `device_sensor_record` VALUES (106, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.5, '℃', NULL, NULL, '2026-11-05 15:51:17.407', '2026-11-05 15:51:17.407');
INSERT INTO `device_sensor_record` VALUES (107, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-05 15:51:17.407', '2026-11-05 15:51:17.407');
INSERT INTO `device_sensor_record` VALUES (108, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.3, '℃', NULL, NULL, '2026-11-05 15:51:17.407', '2026-11-05 15:51:17.407');
INSERT INTO `device_sensor_record` VALUES (109, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-05 15:51:17.407', '2026-11-05 15:51:17.407');
INSERT INTO `device_sensor_record` VALUES (110, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 150542, 'bytes', NULL, NULL, '2026-11-05 15:51:17.407', '2026-11-05 15:51:17.407');
INSERT INTO `device_sensor_record` VALUES (111, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-05 15:51:27.412', '2026-11-05 15:51:27.412');
INSERT INTO `device_sensor_record` VALUES (112, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68, '%', NULL, NULL, '2026-11-05 15:51:27.412', '2026-11-05 15:51:27.412');
INSERT INTO `device_sensor_record` VALUES (113, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 27.4, 'μg/m³', NULL, NULL, '2026-11-05 15:51:27.412', '2026-11-05 15:51:27.412');
INSERT INTO `device_sensor_record` VALUES (114, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 430.6, 'ppm', NULL, NULL, '2026-11-05 15:51:27.412', '2026-11-05 15:51:27.412');
INSERT INTO `device_sensor_record` VALUES (115, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 464.5, 'lx', NULL, NULL, '2026-11-05 15:51:27.412', '2026-11-05 15:51:27.412');
INSERT INTO `device_sensor_record` VALUES (116, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.1, '℃', NULL, NULL, '2026-11-05 15:51:27.412', '2026-11-05 15:51:27.412');
INSERT INTO `device_sensor_record` VALUES (117, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-05 15:51:27.412', '2026-11-05 15:51:27.412');
INSERT INTO `device_sensor_record` VALUES (118, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.1, '℃', NULL, NULL, '2026-11-05 15:51:27.412', '2026-11-05 15:51:27.412');
INSERT INTO `device_sensor_record` VALUES (119, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.22, 'V', NULL, NULL, '2026-11-05 15:51:27.412', '2026-11-05 15:51:27.412');
INSERT INTO `device_sensor_record` VALUES (120, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 130149, 'bytes', NULL, NULL, '2026-11-05 15:51:27.412', '2026-11-05 15:51:27.412');
INSERT INTO `device_sensor_record` VALUES (121, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.7, '℃', NULL, NULL, '2026-11-05 15:51:37.423', '2026-11-05 15:51:37.423');
INSERT INTO `device_sensor_record` VALUES (122, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.3, '%', NULL, NULL, '2026-11-05 15:51:37.423', '2026-11-05 15:51:37.423');
INSERT INTO `device_sensor_record` VALUES (123, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 48.9, 'μg/m³', NULL, NULL, '2026-11-05 15:51:37.423', '2026-11-05 15:51:37.423');
INSERT INTO `device_sensor_record` VALUES (124, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 576.4, 'ppm', NULL, NULL, '2026-11-05 15:51:37.423', '2026-11-05 15:51:37.423');
INSERT INTO `device_sensor_record` VALUES (125, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 582.9, 'lx', NULL, NULL, '2026-11-05 15:51:37.423', '2026-11-05 15:51:37.423');
INSERT INTO `device_sensor_record` VALUES (126, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.3, '℃', NULL, NULL, '2026-11-05 15:51:37.423', '2026-11-05 15:51:37.423');
INSERT INTO `device_sensor_record` VALUES (127, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.4, '℃', NULL, NULL, '2026-11-05 15:51:37.423', '2026-11-05 15:51:37.423');
INSERT INTO `device_sensor_record` VALUES (128, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.3, '℃', NULL, NULL, '2026-11-05 15:51:37.423', '2026-11-05 15:51:37.423');
INSERT INTO `device_sensor_record` VALUES (129, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-05 15:51:37.423', '2026-11-05 15:51:37.423');
INSERT INTO `device_sensor_record` VALUES (130, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 138677, 'bytes', NULL, NULL, '2026-11-05 15:51:37.423', '2026-11-05 15:51:37.423');
INSERT INTO `device_sensor_record` VALUES (131, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-05 15:51:47.425', '2026-11-05 15:51:47.425');
INSERT INTO `device_sensor_record` VALUES (132, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.8, '%', NULL, NULL, '2026-11-05 15:51:47.425', '2026-11-05 15:51:47.425');
INSERT INTO `device_sensor_record` VALUES (133, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 48.9, 'μg/m³', NULL, NULL, '2026-11-05 15:51:47.425', '2026-11-05 15:51:47.425');
INSERT INTO `device_sensor_record` VALUES (134, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 534.6, 'ppm', NULL, NULL, '2026-11-05 15:51:47.425', '2026-11-05 15:51:47.425');
INSERT INTO `device_sensor_record` VALUES (135, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 373.4, 'lx', NULL, NULL, '2026-11-05 15:51:47.425', '2026-11-05 15:51:47.425');
INSERT INTO `device_sensor_record` VALUES (136, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.7, '℃', NULL, NULL, '2026-11-05 15:51:47.425', '2026-11-05 15:51:47.425');
INSERT INTO `device_sensor_record` VALUES (137, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-05 15:51:47.425', '2026-11-05 15:51:47.425');
INSERT INTO `device_sensor_record` VALUES (138, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.4, '℃', NULL, NULL, '2026-11-05 15:51:47.425', '2026-11-05 15:51:47.425');
INSERT INTO `device_sensor_record` VALUES (139, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-05 15:51:47.425', '2026-11-05 15:51:47.425');
INSERT INTO `device_sensor_record` VALUES (140, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 170487, 'bytes', NULL, NULL, '2026-11-05 15:51:47.425', '2026-11-05 15:51:47.425');
INSERT INTO `device_sensor_record` VALUES (141, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.1, '℃', NULL, NULL, '2026-11-05 15:51:57.436', '2026-11-05 15:51:57.436');
INSERT INTO `device_sensor_record` VALUES (142, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.2, '%', NULL, NULL, '2026-11-05 15:51:57.436', '2026-11-05 15:51:57.436');
INSERT INTO `device_sensor_record` VALUES (143, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 30.2, 'μg/m³', NULL, NULL, '2026-11-05 15:51:57.436', '2026-11-05 15:51:57.436');
INSERT INTO `device_sensor_record` VALUES (144, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 507, 'ppm', NULL, NULL, '2026-11-05 15:51:57.436', '2026-11-05 15:51:57.436');
INSERT INTO `device_sensor_record` VALUES (145, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 441, 'lx', NULL, NULL, '2026-11-05 15:51:57.436', '2026-11-05 15:51:57.436');
INSERT INTO `device_sensor_record` VALUES (146, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-05 15:51:57.436', '2026-11-05 15:51:57.436');
INSERT INTO `device_sensor_record` VALUES (147, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-05 15:51:57.436', '2026-11-05 15:51:57.436');
INSERT INTO `device_sensor_record` VALUES (148, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.7, '℃', NULL, NULL, '2026-11-05 15:51:57.436', '2026-11-05 15:51:57.436');
INSERT INTO `device_sensor_record` VALUES (149, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-05 15:51:57.436', '2026-11-05 15:51:57.436');
INSERT INTO `device_sensor_record` VALUES (150, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 159542, 'bytes', NULL, NULL, '2026-11-05 15:51:57.436', '2026-11-05 15:51:57.436');
INSERT INTO `device_sensor_record` VALUES (151, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:52:07.448', '2026-11-05 15:52:07.448');
INSERT INTO `device_sensor_record` VALUES (152, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.8, '%', NULL, NULL, '2026-11-05 15:52:07.448', '2026-11-05 15:52:07.448');
INSERT INTO `device_sensor_record` VALUES (153, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:52:07.448', '2026-11-05 15:52:07.448');
INSERT INTO `device_sensor_record` VALUES (154, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 445.4, 'ppm', NULL, NULL, '2026-11-05 15:52:07.448', '2026-11-05 15:52:07.448');
INSERT INTO `device_sensor_record` VALUES (155, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 577.8, 'lx', NULL, NULL, '2026-11-05 15:52:07.448', '2026-11-05 15:52:07.448');
INSERT INTO `device_sensor_record` VALUES (156, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-05 15:52:07.448', '2026-11-05 15:52:07.448');
INSERT INTO `device_sensor_record` VALUES (157, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-05 15:52:07.448', '2026-11-05 15:52:07.448');
INSERT INTO `device_sensor_record` VALUES (158, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.9, '℃', NULL, NULL, '2026-11-05 15:52:07.448', '2026-11-05 15:52:07.448');
INSERT INTO `device_sensor_record` VALUES (159, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-05 15:52:07.448', '2026-11-05 15:52:07.448');
INSERT INTO `device_sensor_record` VALUES (160, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 168440, 'bytes', NULL, NULL, '2026-11-05 15:52:07.448', '2026-11-05 15:52:07.448');
INSERT INTO `device_sensor_record` VALUES (161, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.4, '℃', NULL, NULL, '2026-11-05 15:52:17.450', '2026-11-05 15:52:17.450');
INSERT INTO `device_sensor_record` VALUES (162, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 51.8, '%', NULL, NULL, '2026-11-05 15:52:17.450', '2026-11-05 15:52:17.450');
INSERT INTO `device_sensor_record` VALUES (163, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.7, 'μg/m³', NULL, NULL, '2026-11-05 15:52:17.450', '2026-11-05 15:52:17.450');
INSERT INTO `device_sensor_record` VALUES (164, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 404.2, 'ppm', NULL, NULL, '2026-11-05 15:52:17.450', '2026-11-05 15:52:17.450');
INSERT INTO `device_sensor_record` VALUES (165, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 445.8, 'lx', NULL, NULL, '2026-11-05 15:52:17.450', '2026-11-05 15:52:17.450');
INSERT INTO `device_sensor_record` VALUES (166, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-05 15:52:17.450', '2026-11-05 15:52:17.450');
INSERT INTO `device_sensor_record` VALUES (167, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.7, '℃', NULL, NULL, '2026-11-05 15:52:17.450', '2026-11-05 15:52:17.450');
INSERT INTO `device_sensor_record` VALUES (168, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52, '℃', NULL, NULL, '2026-11-05 15:52:17.450', '2026-11-05 15:52:17.450');
INSERT INTO `device_sensor_record` VALUES (169, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-05 15:52:17.450', '2026-11-05 15:52:17.450');
INSERT INTO `device_sensor_record` VALUES (170, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 162076, 'bytes', NULL, NULL, '2026-11-05 15:52:17.450', '2026-11-05 15:52:17.450');
INSERT INTO `device_sensor_record` VALUES (171, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24, '℃', NULL, NULL, '2026-11-05 15:52:27.461', '2026-11-05 15:52:27.461');
INSERT INTO `device_sensor_record` VALUES (172, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.5, '%', NULL, NULL, '2026-11-05 15:52:27.461', '2026-11-05 15:52:27.461');
INSERT INTO `device_sensor_record` VALUES (173, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.6, 'μg/m³', NULL, NULL, '2026-11-05 15:52:27.461', '2026-11-05 15:52:27.461');
INSERT INTO `device_sensor_record` VALUES (174, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 585.2, 'ppm', NULL, NULL, '2026-11-05 15:52:27.461', '2026-11-05 15:52:27.461');
INSERT INTO `device_sensor_record` VALUES (175, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 213.3, 'lx', NULL, NULL, '2026-11-05 15:52:27.461', '2026-11-05 15:52:27.461');
INSERT INTO `device_sensor_record` VALUES (176, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.7, '℃', NULL, NULL, '2026-11-05 15:52:27.461', '2026-11-05 15:52:27.461');
INSERT INTO `device_sensor_record` VALUES (177, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.2, '℃', NULL, NULL, '2026-11-05 15:52:27.461', '2026-11-05 15:52:27.461');
INSERT INTO `device_sensor_record` VALUES (178, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.9, '℃', NULL, NULL, '2026-11-05 15:52:27.461', '2026-11-05 15:52:27.461');
INSERT INTO `device_sensor_record` VALUES (179, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-05 15:52:27.461', '2026-11-05 15:52:27.461');
INSERT INTO `device_sensor_record` VALUES (180, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 140810, 'bytes', NULL, NULL, '2026-11-05 15:52:27.461', '2026-11-05 15:52:27.461');
INSERT INTO `device_sensor_record` VALUES (181, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-05 15:52:37.476', '2026-11-05 15:52:37.476');
INSERT INTO `device_sensor_record` VALUES (182, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.5, '%', NULL, NULL, '2026-11-05 15:52:37.476', '2026-11-05 15:52:37.476');
INSERT INTO `device_sensor_record` VALUES (183, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.9, 'μg/m³', NULL, NULL, '2026-11-05 15:52:37.476', '2026-11-05 15:52:37.476');
INSERT INTO `device_sensor_record` VALUES (184, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 421.9, 'ppm', NULL, NULL, '2026-11-05 15:52:37.476', '2026-11-05 15:52:37.476');
INSERT INTO `device_sensor_record` VALUES (185, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 338.8, 'lx', NULL, NULL, '2026-11-05 15:52:37.476', '2026-11-05 15:52:37.476');
INSERT INTO `device_sensor_record` VALUES (186, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-05 15:52:37.476', '2026-11-05 15:52:37.476');
INSERT INTO `device_sensor_record` VALUES (187, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.7, '℃', NULL, NULL, '2026-11-05 15:52:37.476', '2026-11-05 15:52:37.476');
INSERT INTO `device_sensor_record` VALUES (188, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51, '℃', NULL, NULL, '2026-11-05 15:52:37.476', '2026-11-05 15:52:37.476');
INSERT INTO `device_sensor_record` VALUES (189, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-05 15:52:37.476', '2026-11-05 15:52:37.476');
INSERT INTO `device_sensor_record` VALUES (190, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 139078, 'bytes', NULL, NULL, '2026-11-05 15:52:37.476', '2026-11-05 15:52:37.476');
INSERT INTO `device_sensor_record` VALUES (191, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.7, '℃', NULL, NULL, '2026-11-05 15:52:47.484', '2026-11-05 15:52:47.484');
INSERT INTO `device_sensor_record` VALUES (192, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.9, '%', NULL, NULL, '2026-11-05 15:52:47.484', '2026-11-05 15:52:47.484');
INSERT INTO `device_sensor_record` VALUES (193, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 27.6, 'μg/m³', NULL, NULL, '2026-11-05 15:52:47.484', '2026-11-05 15:52:47.484');
INSERT INTO `device_sensor_record` VALUES (194, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 590.4, 'ppm', NULL, NULL, '2026-11-05 15:52:47.484', '2026-11-05 15:52:47.484');
INSERT INTO `device_sensor_record` VALUES (195, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 441.2, 'lx', NULL, NULL, '2026-11-05 15:52:47.484', '2026-11-05 15:52:47.484');
INSERT INTO `device_sensor_record` VALUES (196, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-05 15:52:47.484', '2026-11-05 15:52:47.484');
INSERT INTO `device_sensor_record` VALUES (197, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.4, '℃', NULL, NULL, '2026-11-05 15:52:47.484', '2026-11-05 15:52:47.484');
INSERT INTO `device_sensor_record` VALUES (198, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.7, '℃', NULL, NULL, '2026-11-05 15:52:47.484', '2026-11-05 15:52:47.484');
INSERT INTO `device_sensor_record` VALUES (199, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-05 15:52:47.484', '2026-11-05 15:52:47.484');
INSERT INTO `device_sensor_record` VALUES (200, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 130134, 'bytes', NULL, NULL, '2026-11-05 15:52:47.484', '2026-11-05 15:52:47.484');
INSERT INTO `device_sensor_record` VALUES (201, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:52:57.489', '2026-11-05 15:52:57.489');
INSERT INTO `device_sensor_record` VALUES (202, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.7, '%', NULL, NULL, '2026-11-05 15:52:57.489', '2026-11-05 15:52:57.489');
INSERT INTO `device_sensor_record` VALUES (203, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:52:57.489', '2026-11-05 15:52:57.489');
INSERT INTO `device_sensor_record` VALUES (204, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 460.6, 'ppm', NULL, NULL, '2026-11-05 15:52:57.489', '2026-11-05 15:52:57.489');
INSERT INTO `device_sensor_record` VALUES (205, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 483.6, 'lx', NULL, NULL, '2026-11-05 15:52:57.489', '2026-11-05 15:52:57.489');
INSERT INTO `device_sensor_record` VALUES (206, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.6, '℃', NULL, NULL, '2026-11-05 15:52:57.489', '2026-11-05 15:52:57.489');
INSERT INTO `device_sensor_record` VALUES (207, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.4, '℃', NULL, NULL, '2026-11-05 15:52:57.489', '2026-11-05 15:52:57.489');
INSERT INTO `device_sensor_record` VALUES (208, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.9, '℃', NULL, NULL, '2026-11-05 15:52:57.489', '2026-11-05 15:52:57.489');
INSERT INTO `device_sensor_record` VALUES (209, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-05 15:52:57.489', '2026-11-05 15:52:57.489');
INSERT INTO `device_sensor_record` VALUES (210, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 124326, 'bytes', NULL, NULL, '2026-11-05 15:52:57.489', '2026-11-05 15:52:57.489');
INSERT INTO `device_sensor_record` VALUES (211, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.9, '℃', NULL, NULL, '2026-11-05 15:53:07.507', '2026-11-05 15:53:07.507');
INSERT INTO `device_sensor_record` VALUES (212, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.9, '%', NULL, NULL, '2026-11-05 15:53:07.507', '2026-11-05 15:53:07.507');
INSERT INTO `device_sensor_record` VALUES (213, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 34.1, 'μg/m³', NULL, NULL, '2026-11-05 15:53:07.507', '2026-11-05 15:53:07.507');
INSERT INTO `device_sensor_record` VALUES (214, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 510.9, 'ppm', NULL, NULL, '2026-11-05 15:53:07.507', '2026-11-05 15:53:07.507');
INSERT INTO `device_sensor_record` VALUES (215, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 251.8, 'lx', NULL, NULL, '2026-11-05 15:53:07.507', '2026-11-05 15:53:07.507');
INSERT INTO `device_sensor_record` VALUES (216, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.3, '℃', NULL, NULL, '2026-11-05 15:53:07.507', '2026-11-05 15:53:07.507');
INSERT INTO `device_sensor_record` VALUES (217, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.8, '℃', NULL, NULL, '2026-11-05 15:53:07.507', '2026-11-05 15:53:07.507');
INSERT INTO `device_sensor_record` VALUES (218, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.3, '℃', NULL, NULL, '2026-11-05 15:53:07.507', '2026-11-05 15:53:07.507');
INSERT INTO `device_sensor_record` VALUES (219, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-05 15:53:07.507', '2026-11-05 15:53:07.507');
INSERT INTO `device_sensor_record` VALUES (220, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 163965, 'bytes', NULL, NULL, '2026-11-05 15:53:07.507', '2026-11-05 15:53:07.507');
INSERT INTO `device_sensor_record` VALUES (221, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.6, '℃', NULL, NULL, '2026-11-05 15:53:17.508', '2026-11-05 15:53:17.508');
INSERT INTO `device_sensor_record` VALUES (222, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.5, '%', NULL, NULL, '2026-11-05 15:53:17.508', '2026-11-05 15:53:17.508');
INSERT INTO `device_sensor_record` VALUES (223, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 44, 'μg/m³', NULL, NULL, '2026-11-05 15:53:17.508', '2026-11-05 15:53:17.508');
INSERT INTO `device_sensor_record` VALUES (224, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 499.1, 'ppm', NULL, NULL, '2026-11-05 15:53:17.508', '2026-11-05 15:53:17.508');
INSERT INTO `device_sensor_record` VALUES (225, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 183.6, 'lx', NULL, NULL, '2026-11-05 15:53:17.508', '2026-11-05 15:53:17.508');
INSERT INTO `device_sensor_record` VALUES (226, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.7, '℃', NULL, NULL, '2026-11-05 15:53:17.508', '2026-11-05 15:53:17.508');
INSERT INTO `device_sensor_record` VALUES (227, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.8, '℃', NULL, NULL, '2026-11-05 15:53:17.508', '2026-11-05 15:53:17.508');
INSERT INTO `device_sensor_record` VALUES (228, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.2, '℃', NULL, NULL, '2026-11-05 15:53:17.508', '2026-11-05 15:53:17.508');
INSERT INTO `device_sensor_record` VALUES (229, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.34, 'V', NULL, NULL, '2026-11-05 15:53:17.508', '2026-11-05 15:53:17.508');
INSERT INTO `device_sensor_record` VALUES (230, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 151002, 'bytes', NULL, NULL, '2026-11-05 15:53:17.508', '2026-11-05 15:53:17.508');
INSERT INTO `device_sensor_record` VALUES (231, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-05 15:53:27.516', '2026-11-05 15:53:27.516');
INSERT INTO `device_sensor_record` VALUES (232, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.9, '%', NULL, NULL, '2026-11-05 15:53:27.516', '2026-11-05 15:53:27.516');
INSERT INTO `device_sensor_record` VALUES (233, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.2, 'μg/m³', NULL, NULL, '2026-11-05 15:53:27.516', '2026-11-05 15:53:27.516');
INSERT INTO `device_sensor_record` VALUES (234, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 467.4, 'ppm', NULL, NULL, '2026-11-05 15:53:27.516', '2026-11-05 15:53:27.516');
INSERT INTO `device_sensor_record` VALUES (235, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 224.8, 'lx', NULL, NULL, '2026-11-05 15:53:27.516', '2026-11-05 15:53:27.516');
INSERT INTO `device_sensor_record` VALUES (236, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.6, '℃', NULL, NULL, '2026-11-05 15:53:27.516', '2026-11-05 15:53:27.516');
INSERT INTO `device_sensor_record` VALUES (237, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-05 15:53:27.516', '2026-11-05 15:53:27.516');
INSERT INTO `device_sensor_record` VALUES (238, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.1, '℃', NULL, NULL, '2026-11-05 15:53:27.516', '2026-11-05 15:53:27.516');
INSERT INTO `device_sensor_record` VALUES (239, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-05 15:53:27.516', '2026-11-05 15:53:27.516');
INSERT INTO `device_sensor_record` VALUES (240, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 152632, 'bytes', NULL, NULL, '2026-11-05 15:53:27.516', '2026-11-05 15:53:27.516');
INSERT INTO `device_sensor_record` VALUES (241, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.4, '℃', NULL, NULL, '2026-11-05 15:53:37.521', '2026-11-05 15:53:37.521');
INSERT INTO `device_sensor_record` VALUES (242, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.3, '%', NULL, NULL, '2026-11-05 15:53:37.521', '2026-11-05 15:53:37.521');
INSERT INTO `device_sensor_record` VALUES (243, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.6, 'μg/m³', NULL, NULL, '2026-11-05 15:53:37.521', '2026-11-05 15:53:37.521');
INSERT INTO `device_sensor_record` VALUES (244, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 435.7, 'ppm', NULL, NULL, '2026-11-05 15:53:37.521', '2026-11-05 15:53:37.521');
INSERT INTO `device_sensor_record` VALUES (245, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 500.8, 'lx', NULL, NULL, '2026-11-05 15:53:37.521', '2026-11-05 15:53:37.521');
INSERT INTO `device_sensor_record` VALUES (246, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.3, '℃', NULL, NULL, '2026-11-05 15:53:37.521', '2026-11-05 15:53:37.521');
INSERT INTO `device_sensor_record` VALUES (247, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-05 15:53:37.521', '2026-11-05 15:53:37.521');
INSERT INTO `device_sensor_record` VALUES (248, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.3, '℃', NULL, NULL, '2026-11-05 15:53:37.521', '2026-11-05 15:53:37.521');
INSERT INTO `device_sensor_record` VALUES (249, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-05 15:53:37.521', '2026-11-05 15:53:37.521');
INSERT INTO `device_sensor_record` VALUES (250, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 162730, 'bytes', NULL, NULL, '2026-11-05 15:53:37.521', '2026-11-05 15:53:37.521');
INSERT INTO `device_sensor_record` VALUES (251, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:53:47.524', '2026-11-05 15:53:47.524');
INSERT INTO `device_sensor_record` VALUES (252, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.1, '%', NULL, NULL, '2026-11-05 15:53:47.524', '2026-11-05 15:53:47.524');
INSERT INTO `device_sensor_record` VALUES (253, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:53:47.524', '2026-11-05 15:53:47.524');
INSERT INTO `device_sensor_record` VALUES (254, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 567.5, 'ppm', NULL, NULL, '2026-11-05 15:53:47.524', '2026-11-05 15:53:47.524');
INSERT INTO `device_sensor_record` VALUES (255, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 497.9, 'lx', NULL, NULL, '2026-11-05 15:53:47.524', '2026-11-05 15:53:47.524');
INSERT INTO `device_sensor_record` VALUES (256, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-05 15:53:47.524', '2026-11-05 15:53:47.524');
INSERT INTO `device_sensor_record` VALUES (257, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.9, '℃', NULL, NULL, '2026-11-05 15:53:47.524', '2026-11-05 15:53:47.524');
INSERT INTO `device_sensor_record` VALUES (258, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.2, '℃', NULL, NULL, '2026-11-05 15:53:47.524', '2026-11-05 15:53:47.524');
INSERT INTO `device_sensor_record` VALUES (259, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-05 15:53:47.524', '2026-11-05 15:53:47.524');
INSERT INTO `device_sensor_record` VALUES (260, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 154454, 'bytes', NULL, NULL, '2026-11-05 15:53:47.524', '2026-11-05 15:53:47.524');
INSERT INTO `device_sensor_record` VALUES (261, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.2, '℃', NULL, NULL, '2026-11-05 15:53:57.534', '2026-11-05 15:53:57.534');
INSERT INTO `device_sensor_record` VALUES (262, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.5, '%', NULL, NULL, '2026-11-05 15:53:57.534', '2026-11-05 15:53:57.534');
INSERT INTO `device_sensor_record` VALUES (263, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 22.5, 'μg/m³', NULL, NULL, '2026-11-05 15:53:57.534', '2026-11-05 15:53:57.534');
INSERT INTO `device_sensor_record` VALUES (264, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 513.8, 'ppm', NULL, NULL, '2026-11-05 15:53:57.534', '2026-11-05 15:53:57.534');
INSERT INTO `device_sensor_record` VALUES (265, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 120.9, 'lx', NULL, NULL, '2026-11-05 15:53:57.534', '2026-11-05 15:53:57.534');
INSERT INTO `device_sensor_record` VALUES (266, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-05 15:53:57.534', '2026-11-05 15:53:57.534');
INSERT INTO `device_sensor_record` VALUES (267, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-05 15:53:57.534', '2026-11-05 15:53:57.534');
INSERT INTO `device_sensor_record` VALUES (268, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53, '℃', NULL, NULL, '2026-11-05 15:53:57.534', '2026-11-05 15:53:57.534');
INSERT INTO `device_sensor_record` VALUES (269, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-05 15:53:57.534', '2026-11-05 15:53:57.534');
INSERT INTO `device_sensor_record` VALUES (270, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 140450, 'bytes', NULL, NULL, '2026-11-05 15:53:57.534', '2026-11-05 15:53:57.534');
INSERT INTO `device_sensor_record` VALUES (271, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.4, '℃', NULL, NULL, '2026-11-05 15:54:07.545', '2026-11-05 15:54:07.545');
INSERT INTO `device_sensor_record` VALUES (272, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.3, '%', NULL, NULL, '2026-11-05 15:54:07.545', '2026-11-05 15:54:07.545');
INSERT INTO `device_sensor_record` VALUES (273, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 41.7, 'μg/m³', NULL, NULL, '2026-11-05 15:54:07.545', '2026-11-05 15:54:07.545');
INSERT INTO `device_sensor_record` VALUES (274, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 488.2, 'ppm', NULL, NULL, '2026-11-05 15:54:07.545', '2026-11-05 15:54:07.545');
INSERT INTO `device_sensor_record` VALUES (275, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 573.1, 'lx', NULL, NULL, '2026-11-05 15:54:07.545', '2026-11-05 15:54:07.545');
INSERT INTO `device_sensor_record` VALUES (276, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-05 15:54:07.545', '2026-11-05 15:54:07.545');
INSERT INTO `device_sensor_record` VALUES (277, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.8, '℃', NULL, NULL, '2026-11-05 15:54:07.545', '2026-11-05 15:54:07.545');
INSERT INTO `device_sensor_record` VALUES (278, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.2, '℃', NULL, NULL, '2026-11-05 15:54:07.545', '2026-11-05 15:54:07.545');
INSERT INTO `device_sensor_record` VALUES (279, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-05 15:54:07.545', '2026-11-05 15:54:07.545');
INSERT INTO `device_sensor_record` VALUES (280, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 170569, 'bytes', NULL, NULL, '2026-11-05 15:54:07.545', '2026-11-05 15:54:07.545');
INSERT INTO `device_sensor_record` VALUES (281, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-05 15:54:17.550', '2026-11-05 15:54:17.550');
INSERT INTO `device_sensor_record` VALUES (282, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62.8, '%', NULL, NULL, '2026-11-05 15:54:17.550', '2026-11-05 15:54:17.550');
INSERT INTO `device_sensor_record` VALUES (283, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 48.9, 'μg/m³', NULL, NULL, '2026-11-05 15:54:17.550', '2026-11-05 15:54:17.550');
INSERT INTO `device_sensor_record` VALUES (284, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 409.3, 'ppm', NULL, NULL, '2026-11-05 15:54:17.550', '2026-11-05 15:54:17.550');
INSERT INTO `device_sensor_record` VALUES (285, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 487.9, 'lx', NULL, NULL, '2026-11-05 15:54:17.550', '2026-11-05 15:54:17.550');
INSERT INTO `device_sensor_record` VALUES (286, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-05 15:54:17.550', '2026-11-05 15:54:17.550');
INSERT INTO `device_sensor_record` VALUES (287, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-05 15:54:17.550', '2026-11-05 15:54:17.550');
INSERT INTO `device_sensor_record` VALUES (288, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.1, '℃', NULL, NULL, '2026-11-05 15:54:17.550', '2026-11-05 15:54:17.550');
INSERT INTO `device_sensor_record` VALUES (289, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-05 15:54:17.550', '2026-11-05 15:54:17.550');
INSERT INTO `device_sensor_record` VALUES (290, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 136200, 'bytes', NULL, NULL, '2026-11-05 15:54:17.550', '2026-11-05 15:54:17.550');
INSERT INTO `device_sensor_record` VALUES (291, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-05 15:54:27.569', '2026-11-05 15:54:27.569');
INSERT INTO `device_sensor_record` VALUES (292, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.9, '%', NULL, NULL, '2026-11-05 15:54:27.569', '2026-11-05 15:54:27.569');
INSERT INTO `device_sensor_record` VALUES (293, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 41.6, 'μg/m³', NULL, NULL, '2026-11-05 15:54:27.569', '2026-11-05 15:54:27.569');
INSERT INTO `device_sensor_record` VALUES (294, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 484.5, 'ppm', NULL, NULL, '2026-11-05 15:54:27.569', '2026-11-05 15:54:27.569');
INSERT INTO `device_sensor_record` VALUES (295, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 262, 'lx', NULL, NULL, '2026-11-05 15:54:27.569', '2026-11-05 15:54:27.569');
INSERT INTO `device_sensor_record` VALUES (296, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.9, '℃', NULL, NULL, '2026-11-05 15:54:27.569', '2026-11-05 15:54:27.569');
INSERT INTO `device_sensor_record` VALUES (297, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-05 15:54:27.569', '2026-11-05 15:54:27.569');
INSERT INTO `device_sensor_record` VALUES (298, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.3, '℃', NULL, NULL, '2026-11-05 15:54:27.569', '2026-11-05 15:54:27.569');
INSERT INTO `device_sensor_record` VALUES (299, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-05 15:54:27.569', '2026-11-05 15:54:27.569');
INSERT INTO `device_sensor_record` VALUES (300, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 177067, 'bytes', NULL, NULL, '2026-11-05 15:54:27.569', '2026-11-05 15:54:27.569');
INSERT INTO `device_sensor_record` VALUES (301, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:54:37.582', '2026-11-05 15:54:37.582');
INSERT INTO `device_sensor_record` VALUES (302, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.5, '%', NULL, NULL, '2026-11-05 15:54:37.582', '2026-11-05 15:54:37.582');
INSERT INTO `device_sensor_record` VALUES (303, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:54:37.582', '2026-11-05 15:54:37.582');
INSERT INTO `device_sensor_record` VALUES (304, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 464.3, 'ppm', NULL, NULL, '2026-11-05 15:54:37.582', '2026-11-05 15:54:37.582');
INSERT INTO `device_sensor_record` VALUES (305, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 799.3, 'lx', NULL, NULL, '2026-11-05 15:54:37.582', '2026-11-05 15:54:37.582');
INSERT INTO `device_sensor_record` VALUES (306, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.4, '℃', NULL, NULL, '2026-11-05 15:54:37.582', '2026-11-05 15:54:37.582');
INSERT INTO `device_sensor_record` VALUES (307, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.6, '℃', NULL, NULL, '2026-11-05 15:54:37.582', '2026-11-05 15:54:37.582');
INSERT INTO `device_sensor_record` VALUES (308, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.9, '℃', NULL, NULL, '2026-11-05 15:54:37.582', '2026-11-05 15:54:37.582');
INSERT INTO `device_sensor_record` VALUES (309, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-05 15:54:37.582', '2026-11-05 15:54:37.582');
INSERT INTO `device_sensor_record` VALUES (310, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 154583, 'bytes', NULL, NULL, '2026-11-05 15:54:37.582', '2026-11-05 15:54:37.582');
INSERT INTO `device_sensor_record` VALUES (311, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-05 15:54:47.592', '2026-11-05 15:54:47.592');
INSERT INTO `device_sensor_record` VALUES (312, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62.6, '%', NULL, NULL, '2026-11-05 15:54:47.592', '2026-11-05 15:54:47.592');
INSERT INTO `device_sensor_record` VALUES (313, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 37.3, 'μg/m³', NULL, NULL, '2026-11-05 15:54:47.592', '2026-11-05 15:54:47.592');
INSERT INTO `device_sensor_record` VALUES (314, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 487.5, 'ppm', NULL, NULL, '2026-11-05 15:54:47.592', '2026-11-05 15:54:47.592');
INSERT INTO `device_sensor_record` VALUES (315, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 250.4, 'lx', NULL, NULL, '2026-11-05 15:54:47.592', '2026-11-05 15:54:47.592');
INSERT INTO `device_sensor_record` VALUES (316, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.4, '℃', NULL, NULL, '2026-11-05 15:54:47.592', '2026-11-05 15:54:47.592');
INSERT INTO `device_sensor_record` VALUES (317, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.7, '℃', NULL, NULL, '2026-11-05 15:54:47.592', '2026-11-05 15:54:47.592');
INSERT INTO `device_sensor_record` VALUES (318, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.4, '℃', NULL, NULL, '2026-11-05 15:54:47.592', '2026-11-05 15:54:47.592');
INSERT INTO `device_sensor_record` VALUES (319, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-05 15:54:47.592', '2026-11-05 15:54:47.592');
INSERT INTO `device_sensor_record` VALUES (320, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 159692, 'bytes', NULL, NULL, '2026-11-05 15:54:47.592', '2026-11-05 15:54:47.592');
INSERT INTO `device_sensor_record` VALUES (321, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-05 15:54:57.597', '2026-11-05 15:54:57.597');
INSERT INTO `device_sensor_record` VALUES (322, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.2, '%', NULL, NULL, '2026-11-05 15:54:57.597', '2026-11-05 15:54:57.597');
INSERT INTO `device_sensor_record` VALUES (323, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 33.2, 'μg/m³', NULL, NULL, '2026-11-05 15:54:57.597', '2026-11-05 15:54:57.597');
INSERT INTO `device_sensor_record` VALUES (324, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 537.6, 'ppm', NULL, NULL, '2026-11-05 15:54:57.597', '2026-11-05 15:54:57.597');
INSERT INTO `device_sensor_record` VALUES (325, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 314.6, 'lx', NULL, NULL, '2026-11-05 15:54:57.597', '2026-11-05 15:54:57.597');
INSERT INTO `device_sensor_record` VALUES (326, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.5, '℃', NULL, NULL, '2026-11-05 15:54:57.597', '2026-11-05 15:54:57.597');
INSERT INTO `device_sensor_record` VALUES (327, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25, '℃', NULL, NULL, '2026-11-05 15:54:57.597', '2026-11-05 15:54:57.597');
INSERT INTO `device_sensor_record` VALUES (328, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.1, '℃', NULL, NULL, '2026-11-05 15:54:57.597', '2026-11-05 15:54:57.597');
INSERT INTO `device_sensor_record` VALUES (329, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-05 15:54:57.597', '2026-11-05 15:54:57.597');
INSERT INTO `device_sensor_record` VALUES (330, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 175773, 'bytes', NULL, NULL, '2026-11-05 15:54:57.597', '2026-11-05 15:54:57.597');
INSERT INTO `device_sensor_record` VALUES (331, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.9, '℃', NULL, NULL, '2026-11-05 15:55:07.604', '2026-11-05 15:55:07.604');
INSERT INTO `device_sensor_record` VALUES (332, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.1, '%', NULL, NULL, '2026-11-05 15:55:07.604', '2026-11-05 15:55:07.604');
INSERT INTO `device_sensor_record` VALUES (333, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 30.7, 'μg/m³', NULL, NULL, '2026-11-05 15:55:07.604', '2026-11-05 15:55:07.604');
INSERT INTO `device_sensor_record` VALUES (334, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 549.3, 'ppm', NULL, NULL, '2026-11-05 15:55:07.604', '2026-11-05 15:55:07.604');
INSERT INTO `device_sensor_record` VALUES (335, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 177.7, 'lx', NULL, NULL, '2026-11-05 15:55:07.604', '2026-11-05 15:55:07.604');
INSERT INTO `device_sensor_record` VALUES (336, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-05 15:55:07.604', '2026-11-05 15:55:07.604');
INSERT INTO `device_sensor_record` VALUES (337, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-05 15:55:07.604', '2026-11-05 15:55:07.604');
INSERT INTO `device_sensor_record` VALUES (338, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.1, '℃', NULL, NULL, '2026-11-05 15:55:07.604', '2026-11-05 15:55:07.604');
INSERT INTO `device_sensor_record` VALUES (339, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.29, 'V', NULL, NULL, '2026-11-05 15:55:07.604', '2026-11-05 15:55:07.604');
INSERT INTO `device_sensor_record` VALUES (340, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 159456, 'bytes', NULL, NULL, '2026-11-05 15:55:07.604', '2026-11-05 15:55:07.604');
INSERT INTO `device_sensor_record` VALUES (341, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.9, '℃', NULL, NULL, '2026-11-05 15:55:17.605', '2026-11-05 15:55:17.605');
INSERT INTO `device_sensor_record` VALUES (342, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 50.9, '%', NULL, NULL, '2026-11-05 15:55:17.605', '2026-11-05 15:55:17.605');
INSERT INTO `device_sensor_record` VALUES (343, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.9, 'μg/m³', NULL, NULL, '2026-11-05 15:55:17.605', '2026-11-05 15:55:17.605');
INSERT INTO `device_sensor_record` VALUES (344, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 509.1, 'ppm', NULL, NULL, '2026-11-05 15:55:17.605', '2026-11-05 15:55:17.605');
INSERT INTO `device_sensor_record` VALUES (345, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 242.3, 'lx', NULL, NULL, '2026-11-05 15:55:17.605', '2026-11-05 15:55:17.605');
INSERT INTO `device_sensor_record` VALUES (346, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.4, '℃', NULL, NULL, '2026-11-05 15:55:17.605', '2026-11-05 15:55:17.605');
INSERT INTO `device_sensor_record` VALUES (347, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-05 15:55:17.605', '2026-11-05 15:55:17.605');
INSERT INTO `device_sensor_record` VALUES (348, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.6, '℃', NULL, NULL, '2026-11-05 15:55:17.605', '2026-11-05 15:55:17.605');
INSERT INTO `device_sensor_record` VALUES (349, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-05 15:55:17.605', '2026-11-05 15:55:17.605');
INSERT INTO `device_sensor_record` VALUES (350, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 167382, 'bytes', NULL, NULL, '2026-11-05 15:55:17.605', '2026-11-05 15:55:17.605');
INSERT INTO `device_sensor_record` VALUES (351, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:55:27.611', '2026-11-05 15:55:27.611');
INSERT INTO `device_sensor_record` VALUES (352, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62.1, '%', NULL, NULL, '2026-11-05 15:55:27.611', '2026-11-05 15:55:27.611');
INSERT INTO `device_sensor_record` VALUES (353, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:55:27.611', '2026-11-05 15:55:27.611');
INSERT INTO `device_sensor_record` VALUES (354, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 470.7, 'ppm', NULL, NULL, '2026-11-05 15:55:27.611', '2026-11-05 15:55:27.611');
INSERT INTO `device_sensor_record` VALUES (355, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 103.2, 'lx', NULL, NULL, '2026-11-05 15:55:27.611', '2026-11-05 15:55:27.611');
INSERT INTO `device_sensor_record` VALUES (356, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-05 15:55:27.611', '2026-11-05 15:55:27.611');
INSERT INTO `device_sensor_record` VALUES (357, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23, '℃', NULL, NULL, '2026-11-05 15:55:27.611', '2026-11-05 15:55:27.611');
INSERT INTO `device_sensor_record` VALUES (358, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.4, '℃', NULL, NULL, '2026-11-05 15:55:27.611', '2026-11-05 15:55:27.611');
INSERT INTO `device_sensor_record` VALUES (359, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-05 15:55:27.611', '2026-11-05 15:55:27.611');
INSERT INTO `device_sensor_record` VALUES (360, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 151643, 'bytes', NULL, NULL, '2026-11-05 15:55:27.611', '2026-11-05 15:55:27.611');
INSERT INTO `device_sensor_record` VALUES (361, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.1, '℃', NULL, NULL, '2026-11-05 15:55:37.621', '2026-11-05 15:55:37.621');
INSERT INTO `device_sensor_record` VALUES (362, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 57, '%', NULL, NULL, '2026-11-05 15:55:37.621', '2026-11-05 15:55:37.621');
INSERT INTO `device_sensor_record` VALUES (363, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 31.7, 'μg/m³', NULL, NULL, '2026-11-05 15:55:37.621', '2026-11-05 15:55:37.621');
INSERT INTO `device_sensor_record` VALUES (364, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 413.8, 'ppm', NULL, NULL, '2026-11-05 15:55:37.621', '2026-11-05 15:55:37.621');
INSERT INTO `device_sensor_record` VALUES (365, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 579.8, 'lx', NULL, NULL, '2026-11-05 15:55:37.621', '2026-11-05 15:55:37.621');
INSERT INTO `device_sensor_record` VALUES (366, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-05 15:55:37.621', '2026-11-05 15:55:37.621');
INSERT INTO `device_sensor_record` VALUES (367, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.2, '℃', NULL, NULL, '2026-11-05 15:55:37.621', '2026-11-05 15:55:37.621');
INSERT INTO `device_sensor_record` VALUES (368, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.6, '℃', NULL, NULL, '2026-11-05 15:55:37.621', '2026-11-05 15:55:37.621');
INSERT INTO `device_sensor_record` VALUES (369, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.29, 'V', NULL, NULL, '2026-11-05 15:55:37.621', '2026-11-05 15:55:37.621');
INSERT INTO `device_sensor_record` VALUES (370, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 176721, 'bytes', NULL, NULL, '2026-11-05 15:55:37.621', '2026-11-05 15:55:37.621');
INSERT INTO `device_sensor_record` VALUES (371, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-05 15:55:47.629', '2026-11-05 15:55:47.629');
INSERT INTO `device_sensor_record` VALUES (372, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.2, '%', NULL, NULL, '2026-11-05 15:55:47.629', '2026-11-05 15:55:47.629');
INSERT INTO `device_sensor_record` VALUES (373, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 37.5, 'μg/m³', NULL, NULL, '2026-11-05 15:55:47.629', '2026-11-05 15:55:47.629');
INSERT INTO `device_sensor_record` VALUES (374, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 550.4, 'ppm', NULL, NULL, '2026-11-05 15:55:47.629', '2026-11-05 15:55:47.629');
INSERT INTO `device_sensor_record` VALUES (375, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 229.9, 'lx', NULL, NULL, '2026-11-05 15:55:47.629', '2026-11-05 15:55:47.629');
INSERT INTO `device_sensor_record` VALUES (376, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-05 15:55:47.629', '2026-11-05 15:55:47.629');
INSERT INTO `device_sensor_record` VALUES (377, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.3, '℃', NULL, NULL, '2026-11-05 15:55:47.629', '2026-11-05 15:55:47.629');
INSERT INTO `device_sensor_record` VALUES (378, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.8, '℃', NULL, NULL, '2026-11-05 15:55:47.629', '2026-11-05 15:55:47.629');
INSERT INTO `device_sensor_record` VALUES (379, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-05 15:55:47.629', '2026-11-05 15:55:47.629');
INSERT INTO `device_sensor_record` VALUES (380, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 171968, 'bytes', NULL, NULL, '2026-11-05 15:55:47.629', '2026-11-05 15:55:47.629');
INSERT INTO `device_sensor_record` VALUES (381, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.2, '℃', NULL, NULL, '2026-11-05 15:55:57.640', '2026-11-05 15:55:57.640');
INSERT INTO `device_sensor_record` VALUES (382, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.8, '%', NULL, NULL, '2026-11-05 15:55:57.640', '2026-11-05 15:55:57.640');
INSERT INTO `device_sensor_record` VALUES (383, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 40.4, 'μg/m³', NULL, NULL, '2026-11-05 15:55:57.640', '2026-11-05 15:55:57.640');
INSERT INTO `device_sensor_record` VALUES (384, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 467.2, 'ppm', NULL, NULL, '2026-11-05 15:55:57.640', '2026-11-05 15:55:57.640');
INSERT INTO `device_sensor_record` VALUES (385, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 785.2, 'lx', NULL, NULL, '2026-11-05 15:55:57.640', '2026-11-05 15:55:57.640');
INSERT INTO `device_sensor_record` VALUES (386, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-05 15:55:57.640', '2026-11-05 15:55:57.640');
INSERT INTO `device_sensor_record` VALUES (387, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.7, '℃', NULL, NULL, '2026-11-05 15:55:57.640', '2026-11-05 15:55:57.640');
INSERT INTO `device_sensor_record` VALUES (388, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.2, '℃', NULL, NULL, '2026-11-05 15:55:57.640', '2026-11-05 15:55:57.640');
INSERT INTO `device_sensor_record` VALUES (389, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-05 15:55:57.640', '2026-11-05 15:55:57.640');
INSERT INTO `device_sensor_record` VALUES (390, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 127632, 'bytes', NULL, NULL, '2026-11-05 15:55:57.640', '2026-11-05 15:55:57.640');
INSERT INTO `device_sensor_record` VALUES (391, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-05 15:56:07.655', '2026-11-05 15:56:07.655');
INSERT INTO `device_sensor_record` VALUES (392, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.9, '%', NULL, NULL, '2026-11-05 15:56:07.655', '2026-11-05 15:56:07.655');
INSERT INTO `device_sensor_record` VALUES (393, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 39.6, 'μg/m³', NULL, NULL, '2026-11-05 15:56:07.655', '2026-11-05 15:56:07.655');
INSERT INTO `device_sensor_record` VALUES (394, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 582.3, 'ppm', NULL, NULL, '2026-11-05 15:56:07.655', '2026-11-05 15:56:07.655');
INSERT INTO `device_sensor_record` VALUES (395, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 528.1, 'lx', NULL, NULL, '2026-11-05 15:56:07.655', '2026-11-05 15:56:07.655');
INSERT INTO `device_sensor_record` VALUES (396, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.3, '℃', NULL, NULL, '2026-11-05 15:56:07.655', '2026-11-05 15:56:07.655');
INSERT INTO `device_sensor_record` VALUES (397, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-05 15:56:07.655', '2026-11-05 15:56:07.655');
INSERT INTO `device_sensor_record` VALUES (398, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 55, '℃', NULL, NULL, '2026-11-05 15:56:07.655', '2026-11-05 15:56:07.655');
INSERT INTO `device_sensor_record` VALUES (399, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-05 15:56:07.655', '2026-11-05 15:56:07.655');
INSERT INTO `device_sensor_record` VALUES (400, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 139218, 'bytes', NULL, NULL, '2026-11-05 15:56:07.655', '2026-11-05 15:56:07.655');
INSERT INTO `device_sensor_record` VALUES (401, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:56:17.666', '2026-11-05 15:56:17.666');
INSERT INTO `device_sensor_record` VALUES (402, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60.9, '%', NULL, NULL, '2026-11-05 15:56:17.666', '2026-11-05 15:56:17.666');
INSERT INTO `device_sensor_record` VALUES (403, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:56:17.666', '2026-11-05 15:56:17.666');
INSERT INTO `device_sensor_record` VALUES (404, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 548.5, 'ppm', NULL, NULL, '2026-11-05 15:56:17.666', '2026-11-05 15:56:17.666');
INSERT INTO `device_sensor_record` VALUES (405, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 147.6, 'lx', NULL, NULL, '2026-11-05 15:56:17.666', '2026-11-05 15:56:17.666');
INSERT INTO `device_sensor_record` VALUES (406, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-05 15:56:17.666', '2026-11-05 15:56:17.666');
INSERT INTO `device_sensor_record` VALUES (407, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.9, '℃', NULL, NULL, '2026-11-05 15:56:17.666', '2026-11-05 15:56:17.666');
INSERT INTO `device_sensor_record` VALUES (408, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47, '℃', NULL, NULL, '2026-11-05 15:56:17.666', '2026-11-05 15:56:17.666');
INSERT INTO `device_sensor_record` VALUES (409, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-05 15:56:17.666', '2026-11-05 15:56:17.666');
INSERT INTO `device_sensor_record` VALUES (410, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 169779, 'bytes', NULL, NULL, '2026-11-05 15:56:17.666', '2026-11-05 15:56:17.666');
INSERT INTO `device_sensor_record` VALUES (411, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.9, '℃', NULL, NULL, '2026-11-05 15:56:27.672', '2026-11-05 15:56:27.672');
INSERT INTO `device_sensor_record` VALUES (412, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54, '%', NULL, NULL, '2026-11-05 15:56:27.672', '2026-11-05 15:56:27.672');
INSERT INTO `device_sensor_record` VALUES (413, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 34.5, 'μg/m³', NULL, NULL, '2026-11-05 15:56:27.672', '2026-11-05 15:56:27.672');
INSERT INTO `device_sensor_record` VALUES (414, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 491.3, 'ppm', NULL, NULL, '2026-11-05 15:56:27.672', '2026-11-05 15:56:27.672');
INSERT INTO `device_sensor_record` VALUES (415, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 577.2, 'lx', NULL, NULL, '2026-11-05 15:56:27.672', '2026-11-05 15:56:27.672');
INSERT INTO `device_sensor_record` VALUES (416, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.3, '℃', NULL, NULL, '2026-11-05 15:56:27.672', '2026-11-05 15:56:27.672');
INSERT INTO `device_sensor_record` VALUES (417, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-05 15:56:27.672', '2026-11-05 15:56:27.672');
INSERT INTO `device_sensor_record` VALUES (418, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.6, '℃', NULL, NULL, '2026-11-05 15:56:27.672', '2026-11-05 15:56:27.672');
INSERT INTO `device_sensor_record` VALUES (419, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.34, 'V', NULL, NULL, '2026-11-05 15:56:27.672', '2026-11-05 15:56:27.672');
INSERT INTO `device_sensor_record` VALUES (420, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 165912, 'bytes', NULL, NULL, '2026-11-05 15:56:27.672', '2026-11-05 15:56:27.672');
INSERT INTO `device_sensor_record` VALUES (421, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.7, '℃', NULL, NULL, '2026-11-05 15:56:37.677', '2026-11-05 15:56:37.677');
INSERT INTO `device_sensor_record` VALUES (422, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63, '%', NULL, NULL, '2026-11-05 15:56:37.677', '2026-11-05 15:56:37.677');
INSERT INTO `device_sensor_record` VALUES (423, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 33.3, 'μg/m³', NULL, NULL, '2026-11-05 15:56:37.677', '2026-11-05 15:56:37.677');
INSERT INTO `device_sensor_record` VALUES (424, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 521.9, 'ppm', NULL, NULL, '2026-11-05 15:56:37.677', '2026-11-05 15:56:37.677');
INSERT INTO `device_sensor_record` VALUES (425, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 554, 'lx', NULL, NULL, '2026-11-05 15:56:37.677', '2026-11-05 15:56:37.677');
INSERT INTO `device_sensor_record` VALUES (426, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-05 15:56:37.677', '2026-11-05 15:56:37.677');
INSERT INTO `device_sensor_record` VALUES (427, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.4, '℃', NULL, NULL, '2026-11-05 15:56:37.677', '2026-11-05 15:56:37.677');
INSERT INTO `device_sensor_record` VALUES (428, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.3, '℃', NULL, NULL, '2026-11-05 15:56:37.677', '2026-11-05 15:56:37.677');
INSERT INTO `device_sensor_record` VALUES (429, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-05 15:56:37.677', '2026-11-05 15:56:37.677');
INSERT INTO `device_sensor_record` VALUES (430, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 132809, 'bytes', NULL, NULL, '2026-11-05 15:56:37.677', '2026-11-05 15:56:37.677');
INSERT INTO `device_sensor_record` VALUES (431, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.1, '℃', NULL, NULL, '2026-11-05 15:56:47.687', '2026-11-05 15:56:47.687');
INSERT INTO `device_sensor_record` VALUES (432, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 69.1, '%', NULL, NULL, '2026-11-05 15:56:47.687', '2026-11-05 15:56:47.687');
INSERT INTO `device_sensor_record` VALUES (433, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 41.5, 'μg/m³', NULL, NULL, '2026-11-05 15:56:47.687', '2026-11-05 15:56:47.687');
INSERT INTO `device_sensor_record` VALUES (434, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 546.7, 'ppm', NULL, NULL, '2026-11-05 15:56:47.687', '2026-11-05 15:56:47.687');
INSERT INTO `device_sensor_record` VALUES (435, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 798.3, 'lx', NULL, NULL, '2026-11-05 15:56:47.687', '2026-11-05 15:56:47.687');
INSERT INTO `device_sensor_record` VALUES (436, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.6, '℃', NULL, NULL, '2026-11-05 15:56:47.687', '2026-11-05 15:56:47.687');
INSERT INTO `device_sensor_record` VALUES (437, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.4, '℃', NULL, NULL, '2026-11-05 15:56:47.687', '2026-11-05 15:56:47.687');
INSERT INTO `device_sensor_record` VALUES (438, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.3, '℃', NULL, NULL, '2026-11-05 15:56:47.687', '2026-11-05 15:56:47.687');
INSERT INTO `device_sensor_record` VALUES (439, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-05 15:56:47.687', '2026-11-05 15:56:47.687');
INSERT INTO `device_sensor_record` VALUES (440, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 159521, 'bytes', NULL, NULL, '2026-11-05 15:56:47.687', '2026-11-05 15:56:47.687');
INSERT INTO `device_sensor_record` VALUES (441, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-05 15:56:57.692', '2026-11-05 15:56:57.692');
INSERT INTO `device_sensor_record` VALUES (442, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 50.7, '%', NULL, NULL, '2026-11-05 15:56:57.692', '2026-11-05 15:56:57.692');
INSERT INTO `device_sensor_record` VALUES (443, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 41.7, 'μg/m³', NULL, NULL, '2026-11-05 15:56:57.692', '2026-11-05 15:56:57.692');
INSERT INTO `device_sensor_record` VALUES (444, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 516.5, 'ppm', NULL, NULL, '2026-11-05 15:56:57.692', '2026-11-05 15:56:57.692');
INSERT INTO `device_sensor_record` VALUES (445, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 797.2, 'lx', NULL, NULL, '2026-11-05 15:56:57.692', '2026-11-05 15:56:57.692');
INSERT INTO `device_sensor_record` VALUES (446, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-05 15:56:57.692', '2026-11-05 15:56:57.692');
INSERT INTO `device_sensor_record` VALUES (447, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-05 15:56:57.692', '2026-11-05 15:56:57.692');
INSERT INTO `device_sensor_record` VALUES (448, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.5, '℃', NULL, NULL, '2026-11-05 15:56:57.692', '2026-11-05 15:56:57.692');
INSERT INTO `device_sensor_record` VALUES (449, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-05 15:56:57.692', '2026-11-05 15:56:57.692');
INSERT INTO `device_sensor_record` VALUES (450, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 126326, 'bytes', NULL, NULL, '2026-11-05 15:56:57.692', '2026-11-05 15:56:57.692');
INSERT INTO `device_sensor_record` VALUES (451, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:57:07.701', '2026-11-05 15:57:07.701');
INSERT INTO `device_sensor_record` VALUES (452, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.6, '%', NULL, NULL, '2026-11-05 15:57:07.701', '2026-11-05 15:57:07.701');
INSERT INTO `device_sensor_record` VALUES (453, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:57:07.701', '2026-11-05 15:57:07.701');
INSERT INTO `device_sensor_record` VALUES (454, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 405.9, 'ppm', NULL, NULL, '2026-11-05 15:57:07.701', '2026-11-05 15:57:07.701');
INSERT INTO `device_sensor_record` VALUES (455, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 761.8, 'lx', NULL, NULL, '2026-11-05 15:57:07.701', '2026-11-05 15:57:07.701');
INSERT INTO `device_sensor_record` VALUES (456, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-05 15:57:07.701', '2026-11-05 15:57:07.701');
INSERT INTO `device_sensor_record` VALUES (457, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-05 15:57:07.701', '2026-11-05 15:57:07.701');
INSERT INTO `device_sensor_record` VALUES (458, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.6, '℃', NULL, NULL, '2026-11-05 15:57:07.701', '2026-11-05 15:57:07.701');
INSERT INTO `device_sensor_record` VALUES (459, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-05 15:57:07.701', '2026-11-05 15:57:07.701');
INSERT INTO `device_sensor_record` VALUES (460, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 172050, 'bytes', NULL, NULL, '2026-11-05 15:57:07.701', '2026-11-05 15:57:07.701');
INSERT INTO `device_sensor_record` VALUES (461, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-05 15:57:17.710', '2026-11-05 15:57:17.710');
INSERT INTO `device_sensor_record` VALUES (462, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62.6, '%', NULL, NULL, '2026-11-05 15:57:17.710', '2026-11-05 15:57:17.710');
INSERT INTO `device_sensor_record` VALUES (463, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.8, 'μg/m³', NULL, NULL, '2026-11-05 15:57:17.710', '2026-11-05 15:57:17.710');
INSERT INTO `device_sensor_record` VALUES (464, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 561, 'ppm', NULL, NULL, '2026-11-05 15:57:17.710', '2026-11-05 15:57:17.710');
INSERT INTO `device_sensor_record` VALUES (465, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 452.5, 'lx', NULL, NULL, '2026-11-05 15:57:17.710', '2026-11-05 15:57:17.710');
INSERT INTO `device_sensor_record` VALUES (466, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-05 15:57:17.710', '2026-11-05 15:57:17.710');
INSERT INTO `device_sensor_record` VALUES (467, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-05 15:57:17.710', '2026-11-05 15:57:17.710');
INSERT INTO `device_sensor_record` VALUES (468, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54, '℃', NULL, NULL, '2026-11-05 15:57:17.710', '2026-11-05 15:57:17.710');
INSERT INTO `device_sensor_record` VALUES (469, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-05 15:57:17.710', '2026-11-05 15:57:17.710');
INSERT INTO `device_sensor_record` VALUES (470, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 135422, 'bytes', NULL, NULL, '2026-11-05 15:57:17.710', '2026-11-05 15:57:17.710');
INSERT INTO `device_sensor_record` VALUES (471, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-05 15:57:27.720', '2026-11-05 15:57:27.720');
INSERT INTO `device_sensor_record` VALUES (472, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.9, '%', NULL, NULL, '2026-11-05 15:57:27.720', '2026-11-05 15:57:27.720');
INSERT INTO `device_sensor_record` VALUES (473, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 28.1, 'μg/m³', NULL, NULL, '2026-11-05 15:57:27.720', '2026-11-05 15:57:27.720');
INSERT INTO `device_sensor_record` VALUES (474, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 408.3, 'ppm', NULL, NULL, '2026-11-05 15:57:27.720', '2026-11-05 15:57:27.720');
INSERT INTO `device_sensor_record` VALUES (475, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 649.4, 'lx', NULL, NULL, '2026-11-05 15:57:27.720', '2026-11-05 15:57:27.720');
INSERT INTO `device_sensor_record` VALUES (476, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.9, '℃', NULL, NULL, '2026-11-05 15:57:27.720', '2026-11-05 15:57:27.720');
INSERT INTO `device_sensor_record` VALUES (477, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.7, '℃', NULL, NULL, '2026-11-05 15:57:27.720', '2026-11-05 15:57:27.720');
INSERT INTO `device_sensor_record` VALUES (478, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.7, '℃', NULL, NULL, '2026-11-05 15:57:27.720', '2026-11-05 15:57:27.720');
INSERT INTO `device_sensor_record` VALUES (479, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-05 15:57:27.720', '2026-11-05 15:57:27.720');
INSERT INTO `device_sensor_record` VALUES (480, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 169660, 'bytes', NULL, NULL, '2026-11-05 15:57:27.720', '2026-11-05 15:57:27.720');
INSERT INTO `device_sensor_record` VALUES (481, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.4, '℃', NULL, NULL, '2026-11-05 15:57:37.726', '2026-11-05 15:57:37.726');
INSERT INTO `device_sensor_record` VALUES (482, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60.1, '%', NULL, NULL, '2026-11-05 15:57:37.726', '2026-11-05 15:57:37.726');
INSERT INTO `device_sensor_record` VALUES (483, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 28.9, 'μg/m³', NULL, NULL, '2026-11-05 15:57:37.726', '2026-11-05 15:57:37.726');
INSERT INTO `device_sensor_record` VALUES (484, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 503.6, 'ppm', NULL, NULL, '2026-11-05 15:57:37.726', '2026-11-05 15:57:37.726');
INSERT INTO `device_sensor_record` VALUES (485, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 281, 'lx', NULL, NULL, '2026-11-05 15:57:37.726', '2026-11-05 15:57:37.726');
INSERT INTO `device_sensor_record` VALUES (486, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.6, '℃', NULL, NULL, '2026-11-05 15:57:37.726', '2026-11-05 15:57:37.726');
INSERT INTO `device_sensor_record` VALUES (487, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.8, '℃', NULL, NULL, '2026-11-05 15:57:37.726', '2026-11-05 15:57:37.726');
INSERT INTO `device_sensor_record` VALUES (488, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46, '℃', NULL, NULL, '2026-11-05 15:57:37.726', '2026-11-05 15:57:37.726');
INSERT INTO `device_sensor_record` VALUES (489, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-05 15:57:37.726', '2026-11-05 15:57:37.726');
INSERT INTO `device_sensor_record` VALUES (490, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 175310, 'bytes', NULL, NULL, '2026-11-05 15:57:37.726', '2026-11-05 15:57:37.726');
INSERT INTO `device_sensor_record` VALUES (491, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.7, '℃', NULL, NULL, '2026-11-05 15:57:47.734', '2026-11-05 15:57:47.734');
INSERT INTO `device_sensor_record` VALUES (492, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.5, '%', NULL, NULL, '2026-11-05 15:57:47.734', '2026-11-05 15:57:47.734');
INSERT INTO `device_sensor_record` VALUES (493, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 38.9, 'μg/m³', NULL, NULL, '2026-11-05 15:57:47.734', '2026-11-05 15:57:47.734');
INSERT INTO `device_sensor_record` VALUES (494, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 550.6, 'ppm', NULL, NULL, '2026-11-05 15:57:47.734', '2026-11-05 15:57:47.734');
INSERT INTO `device_sensor_record` VALUES (495, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 383.9, 'lx', NULL, NULL, '2026-11-05 15:57:47.734', '2026-11-05 15:57:47.734');
INSERT INTO `device_sensor_record` VALUES (496, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.6, '℃', NULL, NULL, '2026-11-05 15:57:47.734', '2026-11-05 15:57:47.734');
INSERT INTO `device_sensor_record` VALUES (497, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-05 15:57:47.734', '2026-11-05 15:57:47.734');
INSERT INTO `device_sensor_record` VALUES (498, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.1, '℃', NULL, NULL, '2026-11-05 15:57:47.734', '2026-11-05 15:57:47.734');
INSERT INTO `device_sensor_record` VALUES (499, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-05 15:57:47.734', '2026-11-05 15:57:47.734');
INSERT INTO `device_sensor_record` VALUES (500, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 129131, 'bytes', NULL, NULL, '2026-11-05 15:57:47.734', '2026-11-05 15:57:47.734');
INSERT INTO `device_sensor_record` VALUES (501, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:57:57.749', '2026-11-05 15:57:57.749');
INSERT INTO `device_sensor_record` VALUES (502, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.6, '%', NULL, NULL, '2026-11-05 15:57:57.749', '2026-11-05 15:57:57.749');
INSERT INTO `device_sensor_record` VALUES (503, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:57:57.749', '2026-11-05 15:57:57.749');
INSERT INTO `device_sensor_record` VALUES (504, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 423.4, 'ppm', NULL, NULL, '2026-11-05 15:57:57.749', '2026-11-05 15:57:57.749');
INSERT INTO `device_sensor_record` VALUES (505, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 516.1, 'lx', NULL, NULL, '2026-11-05 15:57:57.749', '2026-11-05 15:57:57.749');
INSERT INTO `device_sensor_record` VALUES (506, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.3, '℃', NULL, NULL, '2026-11-05 15:57:57.749', '2026-11-05 15:57:57.749');
INSERT INTO `device_sensor_record` VALUES (507, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-05 15:57:57.749', '2026-11-05 15:57:57.749');
INSERT INTO `device_sensor_record` VALUES (508, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.7, '℃', NULL, NULL, '2026-11-05 15:57:57.749', '2026-11-05 15:57:57.749');
INSERT INTO `device_sensor_record` VALUES (509, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-05 15:57:57.749', '2026-11-05 15:57:57.749');
INSERT INTO `device_sensor_record` VALUES (510, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 125902, 'bytes', NULL, NULL, '2026-11-05 15:57:57.749', '2026-11-05 15:57:57.749');
INSERT INTO `device_sensor_record` VALUES (511, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.3, '℃', NULL, NULL, '2026-11-05 15:58:07.761', '2026-11-05 15:58:07.761');
INSERT INTO `device_sensor_record` VALUES (512, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55, '%', NULL, NULL, '2026-11-05 15:58:07.761', '2026-11-05 15:58:07.761');
INSERT INTO `device_sensor_record` VALUES (513, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.2, 'μg/m³', NULL, NULL, '2026-11-05 15:58:07.761', '2026-11-05 15:58:07.761');
INSERT INTO `device_sensor_record` VALUES (514, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 504.9, 'ppm', NULL, NULL, '2026-11-05 15:58:07.761', '2026-11-05 15:58:07.761');
INSERT INTO `device_sensor_record` VALUES (515, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 632.4, 'lx', NULL, NULL, '2026-11-05 15:58:07.761', '2026-11-05 15:58:07.761');
INSERT INTO `device_sensor_record` VALUES (516, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.3, '℃', NULL, NULL, '2026-11-05 15:58:07.761', '2026-11-05 15:58:07.761');
INSERT INTO `device_sensor_record` VALUES (517, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-05 15:58:07.761', '2026-11-05 15:58:07.761');
INSERT INTO `device_sensor_record` VALUES (518, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.8, '℃', NULL, NULL, '2026-11-05 15:58:07.761', '2026-11-05 15:58:07.761');
INSERT INTO `device_sensor_record` VALUES (519, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-05 15:58:07.761', '2026-11-05 15:58:07.761');
INSERT INTO `device_sensor_record` VALUES (520, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 152059, 'bytes', NULL, NULL, '2026-11-05 15:58:07.761', '2026-11-05 15:58:07.761');
INSERT INTO `device_sensor_record` VALUES (521, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.4, '℃', NULL, NULL, '2026-11-05 15:58:17.777', '2026-11-05 15:58:17.777');
INSERT INTO `device_sensor_record` VALUES (522, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 51.3, '%', NULL, NULL, '2026-11-05 15:58:17.777', '2026-11-05 15:58:17.777');
INSERT INTO `device_sensor_record` VALUES (523, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 22.2, 'μg/m³', NULL, NULL, '2026-11-05 15:58:17.777', '2026-11-05 15:58:17.777');
INSERT INTO `device_sensor_record` VALUES (524, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 434.5, 'ppm', NULL, NULL, '2026-11-05 15:58:17.777', '2026-11-05 15:58:17.777');
INSERT INTO `device_sensor_record` VALUES (525, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 379.3, 'lx', NULL, NULL, '2026-11-05 15:58:17.777', '2026-11-05 15:58:17.777');
INSERT INTO `device_sensor_record` VALUES (526, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-05 15:58:17.777', '2026-11-05 15:58:17.777');
INSERT INTO `device_sensor_record` VALUES (527, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-05 15:58:17.777', '2026-11-05 15:58:17.777');
INSERT INTO `device_sensor_record` VALUES (528, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.9, '℃', NULL, NULL, '2026-11-05 15:58:17.777', '2026-11-05 15:58:17.777');
INSERT INTO `device_sensor_record` VALUES (529, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-05 15:58:17.777', '2026-11-05 15:58:17.777');
INSERT INTO `device_sensor_record` VALUES (530, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 169704, 'bytes', NULL, NULL, '2026-11-05 15:58:17.777', '2026-11-05 15:58:17.777');
INSERT INTO `device_sensor_record` VALUES (531, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.9, '℃', NULL, NULL, '2026-11-05 15:58:27.784', '2026-11-05 15:58:27.784');
INSERT INTO `device_sensor_record` VALUES (532, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.7, '%', NULL, NULL, '2026-11-05 15:58:27.784', '2026-11-05 15:58:27.784');
INSERT INTO `device_sensor_record` VALUES (533, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 24.9, 'μg/m³', NULL, NULL, '2026-11-05 15:58:27.784', '2026-11-05 15:58:27.784');
INSERT INTO `device_sensor_record` VALUES (534, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 462.7, 'ppm', NULL, NULL, '2026-11-05 15:58:27.784', '2026-11-05 15:58:27.784');
INSERT INTO `device_sensor_record` VALUES (535, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 784.5, 'lx', NULL, NULL, '2026-11-05 15:58:27.784', '2026-11-05 15:58:27.784');
INSERT INTO `device_sensor_record` VALUES (536, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.3, '℃', NULL, NULL, '2026-11-05 15:58:27.784', '2026-11-05 15:58:27.784');
INSERT INTO `device_sensor_record` VALUES (537, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-05 15:58:27.784', '2026-11-05 15:58:27.784');
INSERT INTO `device_sensor_record` VALUES (538, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.3, '℃', NULL, NULL, '2026-11-05 15:58:27.784', '2026-11-05 15:58:27.784');
INSERT INTO `device_sensor_record` VALUES (539, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-05 15:58:27.784', '2026-11-05 15:58:27.784');
INSERT INTO `device_sensor_record` VALUES (540, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 127807, 'bytes', NULL, NULL, '2026-11-05 15:58:27.784', '2026-11-05 15:58:27.784');
INSERT INTO `device_sensor_record` VALUES (541, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.7, '℃', NULL, NULL, '2026-11-05 15:58:37.791', '2026-11-05 15:58:37.791');
INSERT INTO `device_sensor_record` VALUES (542, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64.7, '%', NULL, NULL, '2026-11-05 15:58:37.791', '2026-11-05 15:58:37.791');
INSERT INTO `device_sensor_record` VALUES (543, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 28.2, 'μg/m³', NULL, NULL, '2026-11-05 15:58:37.791', '2026-11-05 15:58:37.791');
INSERT INTO `device_sensor_record` VALUES (544, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 530.6, 'ppm', NULL, NULL, '2026-11-05 15:58:37.791', '2026-11-05 15:58:37.791');
INSERT INTO `device_sensor_record` VALUES (545, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 459.8, 'lx', NULL, NULL, '2026-11-05 15:58:37.791', '2026-11-05 15:58:37.791');
INSERT INTO `device_sensor_record` VALUES (546, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.7, '℃', NULL, NULL, '2026-11-05 15:58:37.791', '2026-11-05 15:58:37.791');
INSERT INTO `device_sensor_record` VALUES (547, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.8, '℃', NULL, NULL, '2026-11-05 15:58:37.791', '2026-11-05 15:58:37.791');
INSERT INTO `device_sensor_record` VALUES (548, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53, '℃', NULL, NULL, '2026-11-05 15:58:37.791', '2026-11-05 15:58:37.791');
INSERT INTO `device_sensor_record` VALUES (549, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-05 15:58:37.791', '2026-11-05 15:58:37.791');
INSERT INTO `device_sensor_record` VALUES (550, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 175715, 'bytes', NULL, NULL, '2026-11-05 15:58:37.791', '2026-11-05 15:58:37.791');
INSERT INTO `device_sensor_record` VALUES (551, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:58:47.796', '2026-11-05 15:58:47.796');
INSERT INTO `device_sensor_record` VALUES (552, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.2, '%', NULL, NULL, '2026-11-05 15:58:47.796', '2026-11-05 15:58:47.796');
INSERT INTO `device_sensor_record` VALUES (553, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:58:47.796', '2026-11-05 15:58:47.796');
INSERT INTO `device_sensor_record` VALUES (554, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 440.2, 'ppm', NULL, NULL, '2026-11-05 15:58:47.796', '2026-11-05 15:58:47.796');
INSERT INTO `device_sensor_record` VALUES (555, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 651.9, 'lx', NULL, NULL, '2026-11-05 15:58:47.796', '2026-11-05 15:58:47.796');
INSERT INTO `device_sensor_record` VALUES (556, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-05 15:58:47.796', '2026-11-05 15:58:47.796');
INSERT INTO `device_sensor_record` VALUES (557, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.8, '℃', NULL, NULL, '2026-11-05 15:58:47.796', '2026-11-05 15:58:47.796');
INSERT INTO `device_sensor_record` VALUES (558, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.7, '℃', NULL, NULL, '2026-11-05 15:58:47.796', '2026-11-05 15:58:47.796');
INSERT INTO `device_sensor_record` VALUES (559, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-05 15:58:47.796', '2026-11-05 15:58:47.796');
INSERT INTO `device_sensor_record` VALUES (560, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 171872, 'bytes', NULL, NULL, '2026-11-05 15:58:47.796', '2026-11-05 15:58:47.796');
INSERT INTO `device_sensor_record` VALUES (561, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.4, '℃', NULL, NULL, '2026-11-05 15:58:57.796', '2026-11-05 15:58:57.796');
INSERT INTO `device_sensor_record` VALUES (562, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.9, '%', NULL, NULL, '2026-11-05 15:58:57.796', '2026-11-05 15:58:57.796');
INSERT INTO `device_sensor_record` VALUES (563, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 21.7, 'μg/m³', NULL, NULL, '2026-11-05 15:58:57.796', '2026-11-05 15:58:57.796');
INSERT INTO `device_sensor_record` VALUES (564, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 497.4, 'ppm', NULL, NULL, '2026-11-05 15:58:57.796', '2026-11-05 15:58:57.796');
INSERT INTO `device_sensor_record` VALUES (565, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 312.4, 'lx', NULL, NULL, '2026-11-05 15:58:57.796', '2026-11-05 15:58:57.796');
INSERT INTO `device_sensor_record` VALUES (566, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.9, '℃', NULL, NULL, '2026-11-05 15:58:57.796', '2026-11-05 15:58:57.796');
INSERT INTO `device_sensor_record` VALUES (567, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.2, '℃', NULL, NULL, '2026-11-05 15:58:57.796', '2026-11-05 15:58:57.796');
INSERT INTO `device_sensor_record` VALUES (568, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52, '℃', NULL, NULL, '2026-11-05 15:58:57.796', '2026-11-05 15:58:57.796');
INSERT INTO `device_sensor_record` VALUES (569, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.34, 'V', NULL, NULL, '2026-11-05 15:58:57.796', '2026-11-05 15:58:57.796');
INSERT INTO `device_sensor_record` VALUES (570, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 142080, 'bytes', NULL, NULL, '2026-11-05 15:58:57.796', '2026-11-05 15:58:57.796');
INSERT INTO `device_sensor_record` VALUES (571, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.2, '℃', NULL, NULL, '2026-11-05 15:59:07.810', '2026-11-05 15:59:07.810');
INSERT INTO `device_sensor_record` VALUES (572, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.8, '%', NULL, NULL, '2026-11-05 15:59:07.810', '2026-11-05 15:59:07.810');
INSERT INTO `device_sensor_record` VALUES (573, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 21.2, 'μg/m³', NULL, NULL, '2026-11-05 15:59:07.810', '2026-11-05 15:59:07.810');
INSERT INTO `device_sensor_record` VALUES (574, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 438.9, 'ppm', NULL, NULL, '2026-11-05 15:59:07.810', '2026-11-05 15:59:07.810');
INSERT INTO `device_sensor_record` VALUES (575, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 260.2, 'lx', NULL, NULL, '2026-11-05 15:59:07.810', '2026-11-05 15:59:07.810');
INSERT INTO `device_sensor_record` VALUES (576, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 23, '℃', NULL, NULL, '2026-11-05 15:59:07.810', '2026-11-05 15:59:07.810');
INSERT INTO `device_sensor_record` VALUES (577, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-05 15:59:07.810', '2026-11-05 15:59:07.810');
INSERT INTO `device_sensor_record` VALUES (578, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.5, '℃', NULL, NULL, '2026-11-05 15:59:07.810', '2026-11-05 15:59:07.810');
INSERT INTO `device_sensor_record` VALUES (579, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-05 15:59:07.810', '2026-11-05 15:59:07.810');
INSERT INTO `device_sensor_record` VALUES (580, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 137007, 'bytes', NULL, NULL, '2026-11-05 15:59:07.810', '2026-11-05 15:59:07.810');
INSERT INTO `device_sensor_record` VALUES (581, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-05 15:59:17.813', '2026-11-05 15:59:17.813');
INSERT INTO `device_sensor_record` VALUES (582, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 51.4, '%', NULL, NULL, '2026-11-05 15:59:17.813', '2026-11-05 15:59:17.813');
INSERT INTO `device_sensor_record` VALUES (583, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 34.9, 'μg/m³', NULL, NULL, '2026-11-05 15:59:17.813', '2026-11-05 15:59:17.813');
INSERT INTO `device_sensor_record` VALUES (584, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 510.3, 'ppm', NULL, NULL, '2026-11-05 15:59:17.813', '2026-11-05 15:59:17.813');
INSERT INTO `device_sensor_record` VALUES (585, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 219.9, 'lx', NULL, NULL, '2026-11-05 15:59:17.813', '2026-11-05 15:59:17.813');
INSERT INTO `device_sensor_record` VALUES (586, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-05 15:59:17.813', '2026-11-05 15:59:17.813');
INSERT INTO `device_sensor_record` VALUES (587, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23, '℃', NULL, NULL, '2026-11-05 15:59:17.813', '2026-11-05 15:59:17.813');
INSERT INTO `device_sensor_record` VALUES (588, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.7, '℃', NULL, NULL, '2026-11-05 15:59:17.813', '2026-11-05 15:59:17.813');
INSERT INTO `device_sensor_record` VALUES (589, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.39, 'V', NULL, NULL, '2026-11-05 15:59:17.813', '2026-11-05 15:59:17.813');
INSERT INTO `device_sensor_record` VALUES (590, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 120436, 'bytes', NULL, NULL, '2026-11-05 15:59:17.813', '2026-11-05 15:59:17.813');
INSERT INTO `device_sensor_record` VALUES (591, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.5, '℃', NULL, NULL, '2026-11-05 15:59:27.827', '2026-11-05 15:59:27.827');
INSERT INTO `device_sensor_record` VALUES (592, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.4, '%', NULL, NULL, '2026-11-05 15:59:27.827', '2026-11-05 15:59:27.827');
INSERT INTO `device_sensor_record` VALUES (593, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.8, 'μg/m³', NULL, NULL, '2026-11-05 15:59:27.827', '2026-11-05 15:59:27.827');
INSERT INTO `device_sensor_record` VALUES (594, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 408.1, 'ppm', NULL, NULL, '2026-11-05 15:59:27.827', '2026-11-05 15:59:27.827');
INSERT INTO `device_sensor_record` VALUES (595, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 729.4, 'lx', NULL, NULL, '2026-11-05 15:59:27.827', '2026-11-05 15:59:27.827');
INSERT INTO `device_sensor_record` VALUES (596, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-05 15:59:27.827', '2026-11-05 15:59:27.827');
INSERT INTO `device_sensor_record` VALUES (597, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.4, '℃', NULL, NULL, '2026-11-05 15:59:27.827', '2026-11-05 15:59:27.827');
INSERT INTO `device_sensor_record` VALUES (598, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.7, '℃', NULL, NULL, '2026-11-05 15:59:27.827', '2026-11-05 15:59:27.827');
INSERT INTO `device_sensor_record` VALUES (599, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.34, 'V', NULL, NULL, '2026-11-05 15:59:27.827', '2026-11-05 15:59:27.827');
INSERT INTO `device_sensor_record` VALUES (600, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 150677, 'bytes', NULL, NULL, '2026-11-05 15:59:27.827', '2026-11-05 15:59:27.827');
INSERT INTO `device_sensor_record` VALUES (601, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 15:59:37.838', '2026-11-05 15:59:37.838');
INSERT INTO `device_sensor_record` VALUES (602, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.9, '%', NULL, NULL, '2026-11-05 15:59:37.838', '2026-11-05 15:59:37.838');
INSERT INTO `device_sensor_record` VALUES (603, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 15:59:37.838', '2026-11-05 15:59:37.838');
INSERT INTO `device_sensor_record` VALUES (604, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 432.4, 'ppm', NULL, NULL, '2026-11-05 15:59:37.838', '2026-11-05 15:59:37.838');
INSERT INTO `device_sensor_record` VALUES (605, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 321.6, 'lx', NULL, NULL, '2026-11-05 15:59:37.838', '2026-11-05 15:59:37.838');
INSERT INTO `device_sensor_record` VALUES (606, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-05 15:59:37.838', '2026-11-05 15:59:37.838');
INSERT INTO `device_sensor_record` VALUES (607, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-05 15:59:37.838', '2026-11-05 15:59:37.838');
INSERT INTO `device_sensor_record` VALUES (608, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.5, '℃', NULL, NULL, '2026-11-05 15:59:37.838', '2026-11-05 15:59:37.838');
INSERT INTO `device_sensor_record` VALUES (609, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-05 15:59:37.838', '2026-11-05 15:59:37.838');
INSERT INTO `device_sensor_record` VALUES (610, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 177401, 'bytes', NULL, NULL, '2026-11-05 15:59:37.838', '2026-11-05 15:59:37.838');
INSERT INTO `device_sensor_record` VALUES (611, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27, '℃', NULL, NULL, '2026-11-05 15:59:47.852', '2026-11-05 15:59:47.852');
INSERT INTO `device_sensor_record` VALUES (612, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.1, '%', NULL, NULL, '2026-11-05 15:59:47.852', '2026-11-05 15:59:47.852');
INSERT INTO `device_sensor_record` VALUES (613, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 30.5, 'μg/m³', NULL, NULL, '2026-11-05 15:59:47.852', '2026-11-05 15:59:47.852');
INSERT INTO `device_sensor_record` VALUES (614, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 427.4, 'ppm', NULL, NULL, '2026-11-05 15:59:47.852', '2026-11-05 15:59:47.852');
INSERT INTO `device_sensor_record` VALUES (615, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 493.7, 'lx', NULL, NULL, '2026-11-05 15:59:47.852', '2026-11-05 15:59:47.852');
INSERT INTO `device_sensor_record` VALUES (616, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.1, '℃', NULL, NULL, '2026-11-05 15:59:47.852', '2026-11-05 15:59:47.852');
INSERT INTO `device_sensor_record` VALUES (617, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-05 15:59:47.852', '2026-11-05 15:59:47.852');
INSERT INTO `device_sensor_record` VALUES (618, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53, '℃', NULL, NULL, '2026-11-05 15:59:47.852', '2026-11-05 15:59:47.852');
INSERT INTO `device_sensor_record` VALUES (619, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-05 15:59:47.852', '2026-11-05 15:59:47.852');
INSERT INTO `device_sensor_record` VALUES (620, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 142051, 'bytes', NULL, NULL, '2026-11-05 15:59:47.852', '2026-11-05 15:59:47.852');
INSERT INTO `device_sensor_record` VALUES (621, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.3, '℃', NULL, NULL, '2026-11-05 15:59:57.859', '2026-11-05 15:59:57.859');
INSERT INTO `device_sensor_record` VALUES (622, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64.9, '%', NULL, NULL, '2026-11-05 15:59:57.859', '2026-11-05 15:59:57.859');
INSERT INTO `device_sensor_record` VALUES (623, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 28.8, 'μg/m³', NULL, NULL, '2026-11-05 15:59:57.859', '2026-11-05 15:59:57.859');
INSERT INTO `device_sensor_record` VALUES (624, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 472.3, 'ppm', NULL, NULL, '2026-11-05 15:59:57.859', '2026-11-05 15:59:57.859');
INSERT INTO `device_sensor_record` VALUES (625, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 710.1, 'lx', NULL, NULL, '2026-11-05 15:59:57.859', '2026-11-05 15:59:57.859');
INSERT INTO `device_sensor_record` VALUES (626, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-05 15:59:57.859', '2026-11-05 15:59:57.859');
INSERT INTO `device_sensor_record` VALUES (627, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-05 15:59:57.859', '2026-11-05 15:59:57.859');
INSERT INTO `device_sensor_record` VALUES (628, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.3, '℃', NULL, NULL, '2026-11-05 15:59:57.859', '2026-11-05 15:59:57.859');
INSERT INTO `device_sensor_record` VALUES (629, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-05 15:59:57.859', '2026-11-05 15:59:57.859');
INSERT INTO `device_sensor_record` VALUES (630, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 146746, 'bytes', NULL, NULL, '2026-11-05 15:59:57.859', '2026-11-05 15:59:57.859');
INSERT INTO `device_sensor_record` VALUES (631, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.9, '℃', NULL, NULL, '2026-11-05 16:00:07.871', '2026-11-05 16:00:07.871');
INSERT INTO `device_sensor_record` VALUES (632, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.6, '%', NULL, NULL, '2026-11-05 16:00:07.871', '2026-11-05 16:00:07.871');
INSERT INTO `device_sensor_record` VALUES (633, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 46.2, 'μg/m³', NULL, NULL, '2026-11-05 16:00:07.871', '2026-11-05 16:00:07.871');
INSERT INTO `device_sensor_record` VALUES (634, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 447, 'ppm', NULL, NULL, '2026-11-05 16:00:07.871', '2026-11-05 16:00:07.871');
INSERT INTO `device_sensor_record` VALUES (635, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 586.7, 'lx', NULL, NULL, '2026-11-05 16:00:07.871', '2026-11-05 16:00:07.871');
INSERT INTO `device_sensor_record` VALUES (636, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-05 16:00:07.871', '2026-11-05 16:00:07.871');
INSERT INTO `device_sensor_record` VALUES (637, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.5, '℃', NULL, NULL, '2026-11-05 16:00:07.871', '2026-11-05 16:00:07.871');
INSERT INTO `device_sensor_record` VALUES (638, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.7, '℃', NULL, NULL, '2026-11-05 16:00:07.871', '2026-11-05 16:00:07.871');
INSERT INTO `device_sensor_record` VALUES (639, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-05 16:00:07.871', '2026-11-05 16:00:07.871');
INSERT INTO `device_sensor_record` VALUES (640, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 176228, 'bytes', NULL, NULL, '2026-11-05 16:00:07.871', '2026-11-05 16:00:07.871');
INSERT INTO `device_sensor_record` VALUES (641, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.9, '℃', NULL, NULL, '2026-11-05 16:00:17.886', '2026-11-05 16:00:17.886');
INSERT INTO `device_sensor_record` VALUES (642, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60, '%', NULL, NULL, '2026-11-05 16:00:17.886', '2026-11-05 16:00:17.886');
INSERT INTO `device_sensor_record` VALUES (643, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.8, 'μg/m³', NULL, NULL, '2026-11-05 16:00:17.886', '2026-11-05 16:00:17.886');
INSERT INTO `device_sensor_record` VALUES (644, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 415.7, 'ppm', NULL, NULL, '2026-11-05 16:00:17.886', '2026-11-05 16:00:17.886');
INSERT INTO `device_sensor_record` VALUES (645, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 283.8, 'lx', NULL, NULL, '2026-11-05 16:00:17.886', '2026-11-05 16:00:17.886');
INSERT INTO `device_sensor_record` VALUES (646, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.1, '℃', NULL, NULL, '2026-11-05 16:00:17.886', '2026-11-05 16:00:17.886');
INSERT INTO `device_sensor_record` VALUES (647, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.4, '℃', NULL, NULL, '2026-11-05 16:00:17.886', '2026-11-05 16:00:17.886');
INSERT INTO `device_sensor_record` VALUES (648, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51, '℃', NULL, NULL, '2026-11-05 16:00:17.886', '2026-11-05 16:00:17.886');
INSERT INTO `device_sensor_record` VALUES (649, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.34, 'V', NULL, NULL, '2026-11-05 16:00:17.886', '2026-11-05 16:00:17.886');
INSERT INTO `device_sensor_record` VALUES (650, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 135217, 'bytes', NULL, NULL, '2026-11-05 16:00:17.886', '2026-11-05 16:00:17.886');
INSERT INTO `device_sensor_record` VALUES (651, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 16:00:27.901', '2026-11-05 16:00:27.901');
INSERT INTO `device_sensor_record` VALUES (652, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.1, '%', NULL, NULL, '2026-11-05 16:00:27.901', '2026-11-05 16:00:27.901');
INSERT INTO `device_sensor_record` VALUES (653, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 16:00:27.901', '2026-11-05 16:00:27.901');
INSERT INTO `device_sensor_record` VALUES (654, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 526.6, 'ppm', NULL, NULL, '2026-11-05 16:00:27.901', '2026-11-05 16:00:27.901');
INSERT INTO `device_sensor_record` VALUES (655, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 545.6, 'lx', NULL, NULL, '2026-11-05 16:00:27.901', '2026-11-05 16:00:27.901');
INSERT INTO `device_sensor_record` VALUES (656, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-05 16:00:27.901', '2026-11-05 16:00:27.901');
INSERT INTO `device_sensor_record` VALUES (657, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 26, '℃', NULL, NULL, '2026-11-05 16:00:27.901', '2026-11-05 16:00:27.901');
INSERT INTO `device_sensor_record` VALUES (658, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.3, '℃', NULL, NULL, '2026-11-05 16:00:27.901', '2026-11-05 16:00:27.901');
INSERT INTO `device_sensor_record` VALUES (659, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.34, 'V', NULL, NULL, '2026-11-05 16:00:27.901', '2026-11-05 16:00:27.901');
INSERT INTO `device_sensor_record` VALUES (660, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 174159, 'bytes', NULL, NULL, '2026-11-05 16:00:27.901', '2026-11-05 16:00:27.901');
INSERT INTO `device_sensor_record` VALUES (661, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-05 16:00:37.906', '2026-11-05 16:00:37.906');
INSERT INTO `device_sensor_record` VALUES (662, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63, '%', NULL, NULL, '2026-11-05 16:00:37.906', '2026-11-05 16:00:37.906');
INSERT INTO `device_sensor_record` VALUES (663, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 39.6, 'μg/m³', NULL, NULL, '2026-11-05 16:00:37.906', '2026-11-05 16:00:37.906');
INSERT INTO `device_sensor_record` VALUES (664, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 538.4, 'ppm', NULL, NULL, '2026-11-05 16:00:37.906', '2026-11-05 16:00:37.906');
INSERT INTO `device_sensor_record` VALUES (665, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 312, 'lx', NULL, NULL, '2026-11-05 16:00:37.906', '2026-11-05 16:00:37.906');
INSERT INTO `device_sensor_record` VALUES (666, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.3, '℃', NULL, NULL, '2026-11-05 16:00:37.906', '2026-11-05 16:00:37.906');
INSERT INTO `device_sensor_record` VALUES (667, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-05 16:00:37.906', '2026-11-05 16:00:37.906');
INSERT INTO `device_sensor_record` VALUES (668, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.3, '℃', NULL, NULL, '2026-11-05 16:00:37.906', '2026-11-05 16:00:37.906');
INSERT INTO `device_sensor_record` VALUES (669, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-05 16:00:37.906', '2026-11-05 16:00:37.906');
INSERT INTO `device_sensor_record` VALUES (670, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 164746, 'bytes', NULL, NULL, '2026-11-05 16:00:37.906', '2026-11-05 16:00:37.906');
INSERT INTO `device_sensor_record` VALUES (671, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.2, '℃', NULL, NULL, '2026-11-05 16:00:47.912', '2026-11-05 16:00:47.912');
INSERT INTO `device_sensor_record` VALUES (672, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.7, '%', NULL, NULL, '2026-11-05 16:00:47.912', '2026-11-05 16:00:47.912');
INSERT INTO `device_sensor_record` VALUES (673, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 33.6, 'μg/m³', NULL, NULL, '2026-11-05 16:00:47.912', '2026-11-05 16:00:47.912');
INSERT INTO `device_sensor_record` VALUES (674, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 502.6, 'ppm', NULL, NULL, '2026-11-05 16:00:47.912', '2026-11-05 16:00:47.912');
INSERT INTO `device_sensor_record` VALUES (675, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 264.2, 'lx', NULL, NULL, '2026-11-05 16:00:47.912', '2026-11-05 16:00:47.912');
INSERT INTO `device_sensor_record` VALUES (676, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20, '℃', NULL, NULL, '2026-11-05 16:00:47.912', '2026-11-05 16:00:47.912');
INSERT INTO `device_sensor_record` VALUES (677, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.7, '℃', NULL, NULL, '2026-11-05 16:00:47.912', '2026-11-05 16:00:47.912');
INSERT INTO `device_sensor_record` VALUES (678, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.6, '℃', NULL, NULL, '2026-11-05 16:00:47.912', '2026-11-05 16:00:47.912');
INSERT INTO `device_sensor_record` VALUES (679, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-05 16:00:47.912', '2026-11-05 16:00:47.912');
INSERT INTO `device_sensor_record` VALUES (680, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 153358, 'bytes', NULL, NULL, '2026-11-05 16:00:47.912', '2026-11-05 16:00:47.912');
INSERT INTO `device_sensor_record` VALUES (681, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.4, '℃', NULL, NULL, '2026-11-05 16:00:57.924', '2026-11-05 16:00:57.924');
INSERT INTO `device_sensor_record` VALUES (682, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.4, '%', NULL, NULL, '2026-11-05 16:00:57.924', '2026-11-05 16:00:57.924');
INSERT INTO `device_sensor_record` VALUES (683, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 41.9, 'μg/m³', NULL, NULL, '2026-11-05 16:00:57.924', '2026-11-05 16:00:57.924');
INSERT INTO `device_sensor_record` VALUES (684, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 471.1, 'ppm', NULL, NULL, '2026-11-05 16:00:57.924', '2026-11-05 16:00:57.924');
INSERT INTO `device_sensor_record` VALUES (685, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 331.2, 'lx', NULL, NULL, '2026-11-05 16:00:57.924', '2026-11-05 16:00:57.924');
INSERT INTO `device_sensor_record` VALUES (686, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 23, '℃', NULL, NULL, '2026-11-05 16:00:57.924', '2026-11-05 16:00:57.924');
INSERT INTO `device_sensor_record` VALUES (687, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-05 16:00:57.924', '2026-11-05 16:00:57.924');
INSERT INTO `device_sensor_record` VALUES (688, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.8, '℃', NULL, NULL, '2026-11-05 16:00:57.924', '2026-11-05 16:00:57.924');
INSERT INTO `device_sensor_record` VALUES (689, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-05 16:00:57.924', '2026-11-05 16:00:57.924');
INSERT INTO `device_sensor_record` VALUES (690, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 130081, 'bytes', NULL, NULL, '2026-11-05 16:00:57.924', '2026-11-05 16:00:57.924');
INSERT INTO `device_sensor_record` VALUES (691, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-05 16:01:07.932', '2026-11-05 16:01:07.932');
INSERT INTO `device_sensor_record` VALUES (692, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.4, '%', NULL, NULL, '2026-11-05 16:01:07.932', '2026-11-05 16:01:07.932');
INSERT INTO `device_sensor_record` VALUES (693, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 47.6, 'μg/m³', NULL, NULL, '2026-11-05 16:01:07.932', '2026-11-05 16:01:07.932');
INSERT INTO `device_sensor_record` VALUES (694, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 526.8, 'ppm', NULL, NULL, '2026-11-05 16:01:07.932', '2026-11-05 16:01:07.932');
INSERT INTO `device_sensor_record` VALUES (695, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 139.7, 'lx', NULL, NULL, '2026-11-05 16:01:07.932', '2026-11-05 16:01:07.932');
INSERT INTO `device_sensor_record` VALUES (696, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.8, '℃', NULL, NULL, '2026-11-05 16:01:07.932', '2026-11-05 16:01:07.932');
INSERT INTO `device_sensor_record` VALUES (697, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-05 16:01:07.932', '2026-11-05 16:01:07.932');
INSERT INTO `device_sensor_record` VALUES (698, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.4, '℃', NULL, NULL, '2026-11-05 16:01:07.932', '2026-11-05 16:01:07.932');
INSERT INTO `device_sensor_record` VALUES (699, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-05 16:01:07.932', '2026-11-05 16:01:07.932');
INSERT INTO `device_sensor_record` VALUES (700, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 139433, 'bytes', NULL, NULL, '2026-11-05 16:01:07.932', '2026-11-05 16:01:07.932');
INSERT INTO `device_sensor_record` VALUES (701, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 16:01:17.943', '2026-11-05 16:01:17.943');
INSERT INTO `device_sensor_record` VALUES (702, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.5, '%', NULL, NULL, '2026-11-05 16:01:17.943', '2026-11-05 16:01:17.943');
INSERT INTO `device_sensor_record` VALUES (703, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 16:01:17.943', '2026-11-05 16:01:17.943');
INSERT INTO `device_sensor_record` VALUES (704, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 561.2, 'ppm', NULL, NULL, '2026-11-05 16:01:17.943', '2026-11-05 16:01:17.943');
INSERT INTO `device_sensor_record` VALUES (705, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 400.6, 'lx', NULL, NULL, '2026-11-05 16:01:17.943', '2026-11-05 16:01:17.943');
INSERT INTO `device_sensor_record` VALUES (706, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-05 16:01:17.943', '2026-11-05 16:01:17.943');
INSERT INTO `device_sensor_record` VALUES (707, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.4, '℃', NULL, NULL, '2026-11-05 16:01:17.943', '2026-11-05 16:01:17.943');
INSERT INTO `device_sensor_record` VALUES (708, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.4, '℃', NULL, NULL, '2026-11-05 16:01:17.943', '2026-11-05 16:01:17.943');
INSERT INTO `device_sensor_record` VALUES (709, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-05 16:01:17.943', '2026-11-05 16:01:17.943');
INSERT INTO `device_sensor_record` VALUES (710, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 168187, 'bytes', NULL, NULL, '2026-11-05 16:01:17.943', '2026-11-05 16:01:17.943');
INSERT INTO `device_sensor_record` VALUES (711, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-05 16:01:27.958', '2026-11-05 16:01:27.958');
INSERT INTO `device_sensor_record` VALUES (712, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.9, '%', NULL, NULL, '2026-11-05 16:01:27.958', '2026-11-05 16:01:27.958');
INSERT INTO `device_sensor_record` VALUES (713, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.8, 'μg/m³', NULL, NULL, '2026-11-05 16:01:27.958', '2026-11-05 16:01:27.958');
INSERT INTO `device_sensor_record` VALUES (714, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 530.3, 'ppm', NULL, NULL, '2026-11-05 16:01:27.958', '2026-11-05 16:01:27.958');
INSERT INTO `device_sensor_record` VALUES (715, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 598.1, 'lx', NULL, NULL, '2026-11-05 16:01:27.958', '2026-11-05 16:01:27.958');
INSERT INTO `device_sensor_record` VALUES (716, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-05 16:01:27.958', '2026-11-05 16:01:27.958');
INSERT INTO `device_sensor_record` VALUES (717, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-05 16:01:27.958', '2026-11-05 16:01:27.958');
INSERT INTO `device_sensor_record` VALUES (718, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.6, '℃', NULL, NULL, '2026-11-05 16:01:27.958', '2026-11-05 16:01:27.958');
INSERT INTO `device_sensor_record` VALUES (719, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-05 16:01:27.958', '2026-11-05 16:01:27.958');
INSERT INTO `device_sensor_record` VALUES (720, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 161604, 'bytes', NULL, NULL, '2026-11-05 16:01:27.958', '2026-11-05 16:01:27.958');
INSERT INTO `device_sensor_record` VALUES (721, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-05 16:01:37.964', '2026-11-05 16:01:37.964');
INSERT INTO `device_sensor_record` VALUES (722, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.9, '%', NULL, NULL, '2026-11-05 16:01:37.964', '2026-11-05 16:01:37.964');
INSERT INTO `device_sensor_record` VALUES (723, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 34.8, 'μg/m³', NULL, NULL, '2026-11-05 16:01:37.964', '2026-11-05 16:01:37.964');
INSERT INTO `device_sensor_record` VALUES (724, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 418.6, 'ppm', NULL, NULL, '2026-11-05 16:01:37.964', '2026-11-05 16:01:37.964');
INSERT INTO `device_sensor_record` VALUES (725, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 264.7, 'lx', NULL, NULL, '2026-11-05 16:01:37.964', '2026-11-05 16:01:37.964');
INSERT INTO `device_sensor_record` VALUES (726, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.8, '℃', NULL, NULL, '2026-11-05 16:01:37.964', '2026-11-05 16:01:37.964');
INSERT INTO `device_sensor_record` VALUES (727, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.5, '℃', NULL, NULL, '2026-11-05 16:01:37.964', '2026-11-05 16:01:37.964');
INSERT INTO `device_sensor_record` VALUES (728, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47, '℃', NULL, NULL, '2026-11-05 16:01:37.964', '2026-11-05 16:01:37.964');
INSERT INTO `device_sensor_record` VALUES (729, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-05 16:01:37.964', '2026-11-05 16:01:37.964');
INSERT INTO `device_sensor_record` VALUES (730, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 152096, 'bytes', NULL, NULL, '2026-11-05 16:01:37.964', '2026-11-05 16:01:37.964');
INSERT INTO `device_sensor_record` VALUES (731, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-05 16:01:47.966', '2026-11-05 16:01:47.966');
INSERT INTO `device_sensor_record` VALUES (732, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.6, '%', NULL, NULL, '2026-11-05 16:01:47.966', '2026-11-05 16:01:47.966');
INSERT INTO `device_sensor_record` VALUES (733, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 46.5, 'μg/m³', NULL, NULL, '2026-11-05 16:01:47.966', '2026-11-05 16:01:47.966');
INSERT INTO `device_sensor_record` VALUES (734, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 485.4, 'ppm', NULL, NULL, '2026-11-05 16:01:47.966', '2026-11-05 16:01:47.966');
INSERT INTO `device_sensor_record` VALUES (735, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 478.5, 'lx', NULL, NULL, '2026-11-05 16:01:47.966', '2026-11-05 16:01:47.966');
INSERT INTO `device_sensor_record` VALUES (736, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-05 16:01:47.966', '2026-11-05 16:01:47.966');
INSERT INTO `device_sensor_record` VALUES (737, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-05 16:01:47.966', '2026-11-05 16:01:47.966');
INSERT INTO `device_sensor_record` VALUES (738, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.3, '℃', NULL, NULL, '2026-11-05 16:01:47.966', '2026-11-05 16:01:47.966');
INSERT INTO `device_sensor_record` VALUES (739, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-05 16:01:47.966', '2026-11-05 16:01:47.966');
INSERT INTO `device_sensor_record` VALUES (740, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 169622, 'bytes', NULL, NULL, '2026-11-05 16:01:47.966', '2026-11-05 16:01:47.966');
INSERT INTO `device_sensor_record` VALUES (741, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26, '℃', NULL, NULL, '2026-11-05 16:01:57.969', '2026-11-05 16:01:57.969');
INSERT INTO `device_sensor_record` VALUES (742, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 50.8, '%', NULL, NULL, '2026-11-05 16:01:57.969', '2026-11-05 16:01:57.969');
INSERT INTO `device_sensor_record` VALUES (743, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 27.8, 'μg/m³', NULL, NULL, '2026-11-05 16:01:57.969', '2026-11-05 16:01:57.969');
INSERT INTO `device_sensor_record` VALUES (744, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 471.4, 'ppm', NULL, NULL, '2026-11-05 16:01:57.969', '2026-11-05 16:01:57.969');
INSERT INTO `device_sensor_record` VALUES (745, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 224.1, 'lx', NULL, NULL, '2026-11-05 16:01:57.969', '2026-11-05 16:01:57.969');
INSERT INTO `device_sensor_record` VALUES (746, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.3, '℃', NULL, NULL, '2026-11-05 16:01:57.969', '2026-11-05 16:01:57.969');
INSERT INTO `device_sensor_record` VALUES (747, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.4, '℃', NULL, NULL, '2026-11-05 16:01:57.969', '2026-11-05 16:01:57.969');
INSERT INTO `device_sensor_record` VALUES (748, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.9, '℃', NULL, NULL, '2026-11-05 16:01:57.969', '2026-11-05 16:01:57.969');
INSERT INTO `device_sensor_record` VALUES (749, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-05 16:01:57.969', '2026-11-05 16:01:57.969');
INSERT INTO `device_sensor_record` VALUES (750, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 176352, 'bytes', NULL, NULL, '2026-11-05 16:01:57.969', '2026-11-05 16:01:57.969');
INSERT INTO `device_sensor_record` VALUES (751, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 16:02:07.974', '2026-11-05 16:02:07.974');
INSERT INTO `device_sensor_record` VALUES (752, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.6, '%', NULL, NULL, '2026-11-05 16:02:07.974', '2026-11-05 16:02:07.974');
INSERT INTO `device_sensor_record` VALUES (753, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 16:02:07.974', '2026-11-05 16:02:07.974');
INSERT INTO `device_sensor_record` VALUES (754, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 532.1, 'ppm', NULL, NULL, '2026-11-05 16:02:07.974', '2026-11-05 16:02:07.974');
INSERT INTO `device_sensor_record` VALUES (755, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 483.5, 'lx', NULL, NULL, '2026-11-05 16:02:07.974', '2026-11-05 16:02:07.974');
INSERT INTO `device_sensor_record` VALUES (756, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.2, '℃', NULL, NULL, '2026-11-05 16:02:07.974', '2026-11-05 16:02:07.974');
INSERT INTO `device_sensor_record` VALUES (757, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.2, '℃', NULL, NULL, '2026-11-05 16:02:07.974', '2026-11-05 16:02:07.974');
INSERT INTO `device_sensor_record` VALUES (758, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47, '℃', NULL, NULL, '2026-11-05 16:02:07.974', '2026-11-05 16:02:07.974');
INSERT INTO `device_sensor_record` VALUES (759, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-05 16:02:07.974', '2026-11-05 16:02:07.974');
INSERT INTO `device_sensor_record` VALUES (760, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 170603, 'bytes', NULL, NULL, '2026-11-05 16:02:07.974', '2026-11-05 16:02:07.974');
INSERT INTO `device_sensor_record` VALUES (761, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26, '℃', NULL, NULL, '2026-11-05 16:02:17.993', '2026-11-05 16:02:17.993');
INSERT INTO `device_sensor_record` VALUES (762, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 50.7, '%', NULL, NULL, '2026-11-05 16:02:17.993', '2026-11-05 16:02:17.993');
INSERT INTO `device_sensor_record` VALUES (763, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 31.1, 'μg/m³', NULL, NULL, '2026-11-05 16:02:17.993', '2026-11-05 16:02:17.993');
INSERT INTO `device_sensor_record` VALUES (764, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 548.4, 'ppm', NULL, NULL, '2026-11-05 16:02:17.993', '2026-11-05 16:02:17.993');
INSERT INTO `device_sensor_record` VALUES (765, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 765.4, 'lx', NULL, NULL, '2026-11-05 16:02:17.993', '2026-11-05 16:02:17.993');
INSERT INTO `device_sensor_record` VALUES (766, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.7, '℃', NULL, NULL, '2026-11-05 16:02:17.993', '2026-11-05 16:02:17.993');
INSERT INTO `device_sensor_record` VALUES (767, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 26, '℃', NULL, NULL, '2026-11-05 16:02:17.993', '2026-11-05 16:02:17.993');
INSERT INTO `device_sensor_record` VALUES (768, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.4, '℃', NULL, NULL, '2026-11-05 16:02:17.993', '2026-11-05 16:02:17.993');
INSERT INTO `device_sensor_record` VALUES (769, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-05 16:02:17.993', '2026-11-05 16:02:17.993');
INSERT INTO `device_sensor_record` VALUES (770, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 164921, 'bytes', NULL, NULL, '2026-11-05 16:02:17.993', '2026-11-05 16:02:17.993');
INSERT INTO `device_sensor_record` VALUES (771, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.2, '℃', NULL, NULL, '2026-11-05 16:02:27.998', '2026-11-05 16:02:27.998');
INSERT INTO `device_sensor_record` VALUES (772, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.4, '%', NULL, NULL, '2026-11-05 16:02:27.998', '2026-11-05 16:02:27.998');
INSERT INTO `device_sensor_record` VALUES (773, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 27.7, 'μg/m³', NULL, NULL, '2026-11-05 16:02:27.998', '2026-11-05 16:02:27.998');
INSERT INTO `device_sensor_record` VALUES (774, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 478.2, 'ppm', NULL, NULL, '2026-11-05 16:02:27.998', '2026-11-05 16:02:27.998');
INSERT INTO `device_sensor_record` VALUES (775, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 215.9, 'lx', NULL, NULL, '2026-11-05 16:02:27.998', '2026-11-05 16:02:27.998');
INSERT INTO `device_sensor_record` VALUES (776, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-05 16:02:27.998', '2026-11-05 16:02:27.998');
INSERT INTO `device_sensor_record` VALUES (777, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-05 16:02:27.998', '2026-11-05 16:02:27.998');
INSERT INTO `device_sensor_record` VALUES (778, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.4, '℃', NULL, NULL, '2026-11-05 16:02:27.998', '2026-11-05 16:02:27.998');
INSERT INTO `device_sensor_record` VALUES (779, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-05 16:02:27.998', '2026-11-05 16:02:27.998');
INSERT INTO `device_sensor_record` VALUES (780, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 146622, 'bytes', NULL, NULL, '2026-11-05 16:02:27.998', '2026-11-05 16:02:27.998');
INSERT INTO `device_sensor_record` VALUES (781, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.4, '℃', NULL, NULL, '2026-11-05 16:02:38.008', '2026-11-05 16:02:38.008');
INSERT INTO `device_sensor_record` VALUES (782, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64.1, '%', NULL, NULL, '2026-11-05 16:02:38.008', '2026-11-05 16:02:38.008');
INSERT INTO `device_sensor_record` VALUES (783, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35.4, 'μg/m³', NULL, NULL, '2026-11-05 16:02:38.008', '2026-11-05 16:02:38.008');
INSERT INTO `device_sensor_record` VALUES (784, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 537.3, 'ppm', NULL, NULL, '2026-11-05 16:02:38.008', '2026-11-05 16:02:38.008');
INSERT INTO `device_sensor_record` VALUES (785, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 353.1, 'lx', NULL, NULL, '2026-11-05 16:02:38.008', '2026-11-05 16:02:38.008');
INSERT INTO `device_sensor_record` VALUES (786, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-05 16:02:38.008', '2026-11-05 16:02:38.008');
INSERT INTO `device_sensor_record` VALUES (787, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23, '℃', NULL, NULL, '2026-11-05 16:02:38.008', '2026-11-05 16:02:38.008');
INSERT INTO `device_sensor_record` VALUES (788, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.2, '℃', NULL, NULL, '2026-11-05 16:02:38.008', '2026-11-05 16:02:38.008');
INSERT INTO `device_sensor_record` VALUES (789, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-05 16:02:38.008', '2026-11-05 16:02:38.008');
INSERT INTO `device_sensor_record` VALUES (790, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 159026, 'bytes', NULL, NULL, '2026-11-05 16:02:38.008', '2026-11-05 16:02:38.008');
INSERT INTO `device_sensor_record` VALUES (791, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.8, '℃', NULL, NULL, '2026-11-05 16:02:48.025', '2026-11-05 16:02:48.025');
INSERT INTO `device_sensor_record` VALUES (792, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.2, '%', NULL, NULL, '2026-11-05 16:02:48.025', '2026-11-05 16:02:48.025');
INSERT INTO `device_sensor_record` VALUES (793, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 39.7, 'μg/m³', NULL, NULL, '2026-11-05 16:02:48.025', '2026-11-05 16:02:48.025');
INSERT INTO `device_sensor_record` VALUES (794, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 469, 'ppm', NULL, NULL, '2026-11-05 16:02:48.025', '2026-11-05 16:02:48.025');
INSERT INTO `device_sensor_record` VALUES (795, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 167.1, 'lx', NULL, NULL, '2026-11-05 16:02:48.025', '2026-11-05 16:02:48.025');
INSERT INTO `device_sensor_record` VALUES (796, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.5, '℃', NULL, NULL, '2026-11-05 16:02:48.025', '2026-11-05 16:02:48.025');
INSERT INTO `device_sensor_record` VALUES (797, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-05 16:02:48.025', '2026-11-05 16:02:48.025');
INSERT INTO `device_sensor_record` VALUES (798, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.9, '℃', NULL, NULL, '2026-11-05 16:02:48.025', '2026-11-05 16:02:48.025');
INSERT INTO `device_sensor_record` VALUES (799, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-05 16:02:48.025', '2026-11-05 16:02:48.025');
INSERT INTO `device_sensor_record` VALUES (800, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 134511, 'bytes', NULL, NULL, '2026-11-05 16:02:48.025', '2026-11-05 16:02:48.025');
INSERT INTO `device_sensor_record` VALUES (801, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 16:02:58.027', '2026-11-05 16:02:58.027');
INSERT INTO `device_sensor_record` VALUES (802, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.8, '%', NULL, NULL, '2026-11-05 16:02:58.027', '2026-11-05 16:02:58.027');
INSERT INTO `device_sensor_record` VALUES (803, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 16:02:58.027', '2026-11-05 16:02:58.027');
INSERT INTO `device_sensor_record` VALUES (804, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 561.4, 'ppm', NULL, NULL, '2026-11-05 16:02:58.027', '2026-11-05 16:02:58.027');
INSERT INTO `device_sensor_record` VALUES (805, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 734.6, 'lx', NULL, NULL, '2026-11-05 16:02:58.027', '2026-11-05 16:02:58.027');
INSERT INTO `device_sensor_record` VALUES (806, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.5, '℃', NULL, NULL, '2026-11-05 16:02:58.027', '2026-11-05 16:02:58.027');
INSERT INTO `device_sensor_record` VALUES (807, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-05 16:02:58.027', '2026-11-05 16:02:58.027');
INSERT INTO `device_sensor_record` VALUES (808, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.2, '℃', NULL, NULL, '2026-11-05 16:02:58.027', '2026-11-05 16:02:58.027');
INSERT INTO `device_sensor_record` VALUES (809, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-05 16:02:58.027', '2026-11-05 16:02:58.027');
INSERT INTO `device_sensor_record` VALUES (810, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 126159, 'bytes', NULL, NULL, '2026-11-05 16:02:58.027', '2026-11-05 16:02:58.027');
INSERT INTO `device_sensor_record` VALUES (811, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-05 16:03:08.027', '2026-11-05 16:03:08.027');
INSERT INTO `device_sensor_record` VALUES (812, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.9, '%', NULL, NULL, '2026-11-05 16:03:08.027', '2026-11-05 16:03:08.027');
INSERT INTO `device_sensor_record` VALUES (813, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 43, 'μg/m³', NULL, NULL, '2026-11-05 16:03:08.027', '2026-11-05 16:03:08.027');
INSERT INTO `device_sensor_record` VALUES (814, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 452, 'ppm', NULL, NULL, '2026-11-05 16:03:08.027', '2026-11-05 16:03:08.027');
INSERT INTO `device_sensor_record` VALUES (815, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 329.4, 'lx', NULL, NULL, '2026-11-05 16:03:08.027', '2026-11-05 16:03:08.027');
INSERT INTO `device_sensor_record` VALUES (816, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.5, '℃', NULL, NULL, '2026-11-05 16:03:08.027', '2026-11-05 16:03:08.027');
INSERT INTO `device_sensor_record` VALUES (817, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-05 16:03:08.027', '2026-11-05 16:03:08.027');
INSERT INTO `device_sensor_record` VALUES (818, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50, '℃', NULL, NULL, '2026-11-05 16:03:08.027', '2026-11-05 16:03:08.027');
INSERT INTO `device_sensor_record` VALUES (819, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-05 16:03:08.027', '2026-11-05 16:03:08.027');
INSERT INTO `device_sensor_record` VALUES (820, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 157034, 'bytes', NULL, NULL, '2026-11-05 16:03:08.027', '2026-11-05 16:03:08.027');
INSERT INTO `device_sensor_record` VALUES (821, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.9, '℃', NULL, NULL, '2026-11-05 16:03:18.033', '2026-11-05 16:03:18.033');
INSERT INTO `device_sensor_record` VALUES (822, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.4, '%', NULL, NULL, '2026-11-05 16:03:18.033', '2026-11-05 16:03:18.033');
INSERT INTO `device_sensor_record` VALUES (823, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 29.9, 'μg/m³', NULL, NULL, '2026-11-05 16:03:18.033', '2026-11-05 16:03:18.033');
INSERT INTO `device_sensor_record` VALUES (824, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 522.5, 'ppm', NULL, NULL, '2026-11-05 16:03:18.033', '2026-11-05 16:03:18.033');
INSERT INTO `device_sensor_record` VALUES (825, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 351.2, 'lx', NULL, NULL, '2026-11-05 16:03:18.033', '2026-11-05 16:03:18.033');
INSERT INTO `device_sensor_record` VALUES (826, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-05 16:03:18.033', '2026-11-05 16:03:18.033');
INSERT INTO `device_sensor_record` VALUES (827, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-05 16:03:18.033', '2026-11-05 16:03:18.033');
INSERT INTO `device_sensor_record` VALUES (828, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.9, '℃', NULL, NULL, '2026-11-05 16:03:18.033', '2026-11-05 16:03:18.033');
INSERT INTO `device_sensor_record` VALUES (829, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-05 16:03:18.033', '2026-11-05 16:03:18.033');
INSERT INTO `device_sensor_record` VALUES (830, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 175399, 'bytes', NULL, NULL, '2026-11-05 16:03:18.033', '2026-11-05 16:03:18.033');
INSERT INTO `device_sensor_record` VALUES (831, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.4, '℃', NULL, NULL, '2026-11-05 16:03:28.036', '2026-11-05 16:03:28.036');
INSERT INTO `device_sensor_record` VALUES (832, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.4, '%', NULL, NULL, '2026-11-05 16:03:28.036', '2026-11-05 16:03:28.036');
INSERT INTO `device_sensor_record` VALUES (833, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 24.7, 'μg/m³', NULL, NULL, '2026-11-05 16:03:28.036', '2026-11-05 16:03:28.036');
INSERT INTO `device_sensor_record` VALUES (834, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 536.7, 'ppm', NULL, NULL, '2026-11-05 16:03:28.036', '2026-11-05 16:03:28.036');
INSERT INTO `device_sensor_record` VALUES (835, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 495.2, 'lx', NULL, NULL, '2026-11-05 16:03:28.036', '2026-11-05 16:03:28.036');
INSERT INTO `device_sensor_record` VALUES (836, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-05 16:03:28.036', '2026-11-05 16:03:28.036');
INSERT INTO `device_sensor_record` VALUES (837, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.8, '℃', NULL, NULL, '2026-11-05 16:03:28.036', '2026-11-05 16:03:28.036');
INSERT INTO `device_sensor_record` VALUES (838, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.1, '℃', NULL, NULL, '2026-11-05 16:03:28.036', '2026-11-05 16:03:28.036');
INSERT INTO `device_sensor_record` VALUES (839, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-05 16:03:28.036', '2026-11-05 16:03:28.036');
INSERT INTO `device_sensor_record` VALUES (840, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 158440, 'bytes', NULL, NULL, '2026-11-05 16:03:28.036', '2026-11-05 16:03:28.036');
INSERT INTO `device_sensor_record` VALUES (841, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.6, '℃', NULL, NULL, '2026-11-05 16:03:38.039', '2026-11-05 16:03:38.039');
INSERT INTO `device_sensor_record` VALUES (842, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.1, '%', NULL, NULL, '2026-11-05 16:03:38.039', '2026-11-05 16:03:38.039');
INSERT INTO `device_sensor_record` VALUES (843, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 37.3, 'μg/m³', NULL, NULL, '2026-11-05 16:03:38.039', '2026-11-05 16:03:38.039');
INSERT INTO `device_sensor_record` VALUES (844, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 491.5, 'ppm', NULL, NULL, '2026-11-05 16:03:38.039', '2026-11-05 16:03:38.039');
INSERT INTO `device_sensor_record` VALUES (845, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 495, 'lx', NULL, NULL, '2026-11-05 16:03:38.039', '2026-11-05 16:03:38.039');
INSERT INTO `device_sensor_record` VALUES (846, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-05 16:03:38.039', '2026-11-05 16:03:38.039');
INSERT INTO `device_sensor_record` VALUES (847, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 26, '℃', NULL, NULL, '2026-11-05 16:03:38.039', '2026-11-05 16:03:38.039');
INSERT INTO `device_sensor_record` VALUES (848, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.5, '℃', NULL, NULL, '2026-11-05 16:03:38.039', '2026-11-05 16:03:38.039');
INSERT INTO `device_sensor_record` VALUES (849, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-05 16:03:38.039', '2026-11-05 16:03:38.039');
INSERT INTO `device_sensor_record` VALUES (850, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 153322, 'bytes', NULL, NULL, '2026-11-05 16:03:38.039', '2026-11-05 16:03:38.039');
INSERT INTO `device_sensor_record` VALUES (851, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 16:03:48.054', '2026-11-05 16:03:48.054');
INSERT INTO `device_sensor_record` VALUES (852, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.7, '%', NULL, NULL, '2026-11-05 16:03:48.054', '2026-11-05 16:03:48.054');
INSERT INTO `device_sensor_record` VALUES (853, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 16:03:48.054', '2026-11-05 16:03:48.054');
INSERT INTO `device_sensor_record` VALUES (854, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 406, 'ppm', NULL, NULL, '2026-11-05 16:03:48.054', '2026-11-05 16:03:48.054');
INSERT INTO `device_sensor_record` VALUES (855, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 628.2, 'lx', NULL, NULL, '2026-11-05 16:03:48.054', '2026-11-05 16:03:48.054');
INSERT INTO `device_sensor_record` VALUES (856, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-05 16:03:48.054', '2026-11-05 16:03:48.054');
INSERT INTO `device_sensor_record` VALUES (857, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.7, '℃', NULL, NULL, '2026-11-05 16:03:48.054', '2026-11-05 16:03:48.054');
INSERT INTO `device_sensor_record` VALUES (858, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.6, '℃', NULL, NULL, '2026-11-05 16:03:48.054', '2026-11-05 16:03:48.054');
INSERT INTO `device_sensor_record` VALUES (859, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.34, 'V', NULL, NULL, '2026-11-05 16:03:48.054', '2026-11-05 16:03:48.054');
INSERT INTO `device_sensor_record` VALUES (860, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 176902, 'bytes', NULL, NULL, '2026-11-05 16:03:48.054', '2026-11-05 16:03:48.054');
INSERT INTO `device_sensor_record` VALUES (861, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-05 16:03:58.072', '2026-11-05 16:03:58.072');
INSERT INTO `device_sensor_record` VALUES (862, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60.1, '%', NULL, NULL, '2026-11-05 16:03:58.072', '2026-11-05 16:03:58.072');
INSERT INTO `device_sensor_record` VALUES (863, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 49.6, 'μg/m³', NULL, NULL, '2026-11-05 16:03:58.072', '2026-11-05 16:03:58.072');
INSERT INTO `device_sensor_record` VALUES (864, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 524.6, 'ppm', NULL, NULL, '2026-11-05 16:03:58.072', '2026-11-05 16:03:58.072');
INSERT INTO `device_sensor_record` VALUES (865, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 642.5, 'lx', NULL, NULL, '2026-11-05 16:03:58.072', '2026-11-05 16:03:58.072');
INSERT INTO `device_sensor_record` VALUES (866, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-05 16:03:58.072', '2026-11-05 16:03:58.072');
INSERT INTO `device_sensor_record` VALUES (867, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-05 16:03:58.072', '2026-11-05 16:03:58.072');
INSERT INTO `device_sensor_record` VALUES (868, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53, '℃', NULL, NULL, '2026-11-05 16:03:58.072', '2026-11-05 16:03:58.072');
INSERT INTO `device_sensor_record` VALUES (869, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.39, 'V', NULL, NULL, '2026-11-05 16:03:58.072', '2026-11-05 16:03:58.072');
INSERT INTO `device_sensor_record` VALUES (870, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 160329, 'bytes', NULL, NULL, '2026-11-05 16:03:58.072', '2026-11-05 16:03:58.072');
INSERT INTO `device_sensor_record` VALUES (871, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25, '℃', NULL, NULL, '2026-11-05 16:04:08.082', '2026-11-05 16:04:08.082');
INSERT INTO `device_sensor_record` VALUES (872, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.1, '%', NULL, NULL, '2026-11-05 16:04:08.082', '2026-11-05 16:04:08.082');
INSERT INTO `device_sensor_record` VALUES (873, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 46.8, 'μg/m³', NULL, NULL, '2026-11-05 16:04:08.082', '2026-11-05 16:04:08.082');
INSERT INTO `device_sensor_record` VALUES (874, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 447.1, 'ppm', NULL, NULL, '2026-11-05 16:04:08.082', '2026-11-05 16:04:08.082');
INSERT INTO `device_sensor_record` VALUES (875, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 406.3, 'lx', NULL, NULL, '2026-11-05 16:04:08.082', '2026-11-05 16:04:08.082');
INSERT INTO `device_sensor_record` VALUES (876, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.4, '℃', NULL, NULL, '2026-11-05 16:04:08.082', '2026-11-05 16:04:08.082');
INSERT INTO `device_sensor_record` VALUES (877, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.3, '℃', NULL, NULL, '2026-11-05 16:04:08.082', '2026-11-05 16:04:08.082');
INSERT INTO `device_sensor_record` VALUES (878, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.9, '℃', NULL, NULL, '2026-11-05 16:04:08.082', '2026-11-05 16:04:08.082');
INSERT INTO `device_sensor_record` VALUES (879, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-05 16:04:08.082', '2026-11-05 16:04:08.082');
INSERT INTO `device_sensor_record` VALUES (880, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 169814, 'bytes', NULL, NULL, '2026-11-05 16:04:08.082', '2026-11-05 16:04:08.082');
INSERT INTO `device_sensor_record` VALUES (881, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.2, '℃', NULL, NULL, '2026-11-05 16:04:18.085', '2026-11-05 16:04:18.085');
INSERT INTO `device_sensor_record` VALUES (882, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.6, '%', NULL, NULL, '2026-11-05 16:04:18.085', '2026-11-05 16:04:18.085');
INSERT INTO `device_sensor_record` VALUES (883, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 43.4, 'μg/m³', NULL, NULL, '2026-11-05 16:04:18.085', '2026-11-05 16:04:18.085');
INSERT INTO `device_sensor_record` VALUES (884, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 586.5, 'ppm', NULL, NULL, '2026-11-05 16:04:18.085', '2026-11-05 16:04:18.085');
INSERT INTO `device_sensor_record` VALUES (885, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 547.4, 'lx', NULL, NULL, '2026-11-05 16:04:18.085', '2026-11-05 16:04:18.085');
INSERT INTO `device_sensor_record` VALUES (886, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-05 16:04:18.085', '2026-11-05 16:04:18.085');
INSERT INTO `device_sensor_record` VALUES (887, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-05 16:04:18.085', '2026-11-05 16:04:18.085');
INSERT INTO `device_sensor_record` VALUES (888, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.7, '℃', NULL, NULL, '2026-11-05 16:04:18.085', '2026-11-05 16:04:18.085');
INSERT INTO `device_sensor_record` VALUES (889, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-05 16:04:18.085', '2026-11-05 16:04:18.085');
INSERT INTO `device_sensor_record` VALUES (890, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 162636, 'bytes', NULL, NULL, '2026-11-05 16:04:18.085', '2026-11-05 16:04:18.085');
INSERT INTO `device_sensor_record` VALUES (891, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.3, '℃', NULL, NULL, '2026-11-05 16:04:28.101', '2026-11-05 16:04:28.101');
INSERT INTO `device_sensor_record` VALUES (892, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 69, '%', NULL, NULL, '2026-11-05 16:04:28.101', '2026-11-05 16:04:28.101');
INSERT INTO `device_sensor_record` VALUES (893, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 27.9, 'μg/m³', NULL, NULL, '2026-11-05 16:04:28.101', '2026-11-05 16:04:28.101');
INSERT INTO `device_sensor_record` VALUES (894, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 432.1, 'ppm', NULL, NULL, '2026-11-05 16:04:28.101', '2026-11-05 16:04:28.101');
INSERT INTO `device_sensor_record` VALUES (895, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 377.8, 'lx', NULL, NULL, '2026-11-05 16:04:28.101', '2026-11-05 16:04:28.101');
INSERT INTO `device_sensor_record` VALUES (896, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 23, '℃', NULL, NULL, '2026-11-05 16:04:28.101', '2026-11-05 16:04:28.101');
INSERT INTO `device_sensor_record` VALUES (897, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-05 16:04:28.101', '2026-11-05 16:04:28.101');
INSERT INTO `device_sensor_record` VALUES (898, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.8, '℃', NULL, NULL, '2026-11-05 16:04:28.101', '2026-11-05 16:04:28.101');
INSERT INTO `device_sensor_record` VALUES (899, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-05 16:04:28.101', '2026-11-05 16:04:28.101');
INSERT INTO `device_sensor_record` VALUES (900, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 138473, 'bytes', NULL, NULL, '2026-11-05 16:04:28.101', '2026-11-05 16:04:28.101');
INSERT INTO `device_sensor_record` VALUES (901, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 16:04:38.101', '2026-11-05 16:04:38.101');
INSERT INTO `device_sensor_record` VALUES (902, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.1, '%', NULL, NULL, '2026-11-05 16:04:38.101', '2026-11-05 16:04:38.101');
INSERT INTO `device_sensor_record` VALUES (903, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 16:04:38.101', '2026-11-05 16:04:38.101');
INSERT INTO `device_sensor_record` VALUES (904, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 416.7, 'ppm', NULL, NULL, '2026-11-05 16:04:38.101', '2026-11-05 16:04:38.101');
INSERT INTO `device_sensor_record` VALUES (905, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 289.2, 'lx', NULL, NULL, '2026-11-05 16:04:38.101', '2026-11-05 16:04:38.101');
INSERT INTO `device_sensor_record` VALUES (906, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.6, '℃', NULL, NULL, '2026-11-05 16:04:38.101', '2026-11-05 16:04:38.101');
INSERT INTO `device_sensor_record` VALUES (907, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-05 16:04:38.101', '2026-11-05 16:04:38.101');
INSERT INTO `device_sensor_record` VALUES (908, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.7, '℃', NULL, NULL, '2026-11-05 16:04:38.101', '2026-11-05 16:04:38.101');
INSERT INTO `device_sensor_record` VALUES (909, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-05 16:04:38.101', '2026-11-05 16:04:38.101');
INSERT INTO `device_sensor_record` VALUES (910, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 137439, 'bytes', NULL, NULL, '2026-11-05 16:04:38.101', '2026-11-05 16:04:38.101');
INSERT INTO `device_sensor_record` VALUES (911, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-05 16:04:48.116', '2026-11-05 16:04:48.116');
INSERT INTO `device_sensor_record` VALUES (912, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.6, '%', NULL, NULL, '2026-11-05 16:04:48.116', '2026-11-05 16:04:48.116');
INSERT INTO `device_sensor_record` VALUES (913, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 46.7, 'μg/m³', NULL, NULL, '2026-11-05 16:04:48.116', '2026-11-05 16:04:48.116');
INSERT INTO `device_sensor_record` VALUES (914, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 584.1, 'ppm', NULL, NULL, '2026-11-05 16:04:48.116', '2026-11-05 16:04:48.116');
INSERT INTO `device_sensor_record` VALUES (915, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 422.2, 'lx', NULL, NULL, '2026-11-05 16:04:48.116', '2026-11-05 16:04:48.116');
INSERT INTO `device_sensor_record` VALUES (916, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.5, '℃', NULL, NULL, '2026-11-05 16:04:48.116', '2026-11-05 16:04:48.116');
INSERT INTO `device_sensor_record` VALUES (917, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-05 16:04:48.116', '2026-11-05 16:04:48.116');
INSERT INTO `device_sensor_record` VALUES (918, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.6, '℃', NULL, NULL, '2026-11-05 16:04:48.116', '2026-11-05 16:04:48.116');
INSERT INTO `device_sensor_record` VALUES (919, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-05 16:04:48.116', '2026-11-05 16:04:48.116');
INSERT INTO `device_sensor_record` VALUES (920, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 146569, 'bytes', NULL, NULL, '2026-11-05 16:04:48.116', '2026-11-05 16:04:48.116');
INSERT INTO `device_sensor_record` VALUES (921, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-05 16:04:58.119', '2026-11-05 16:04:58.119');
INSERT INTO `device_sensor_record` VALUES (922, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.6, '%', NULL, NULL, '2026-11-05 16:04:58.119', '2026-11-05 16:04:58.119');
INSERT INTO `device_sensor_record` VALUES (923, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 41.5, 'μg/m³', NULL, NULL, '2026-11-05 16:04:58.119', '2026-11-05 16:04:58.119');
INSERT INTO `device_sensor_record` VALUES (924, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 576.4, 'ppm', NULL, NULL, '2026-11-05 16:04:58.119', '2026-11-05 16:04:58.119');
INSERT INTO `device_sensor_record` VALUES (925, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 400.4, 'lx', NULL, NULL, '2026-11-05 16:04:58.119', '2026-11-05 16:04:58.119');
INSERT INTO `device_sensor_record` VALUES (926, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-05 16:04:58.119', '2026-11-05 16:04:58.119');
INSERT INTO `device_sensor_record` VALUES (927, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-05 16:04:58.119', '2026-11-05 16:04:58.119');
INSERT INTO `device_sensor_record` VALUES (928, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.8, '℃', NULL, NULL, '2026-11-05 16:04:58.119', '2026-11-05 16:04:58.119');
INSERT INTO `device_sensor_record` VALUES (929, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-05 16:04:58.119', '2026-11-05 16:04:58.119');
INSERT INTO `device_sensor_record` VALUES (930, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 146193, 'bytes', NULL, NULL, '2026-11-05 16:04:58.119', '2026-11-05 16:04:58.119');
INSERT INTO `device_sensor_record` VALUES (931, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.7, '℃', NULL, NULL, '2026-11-05 16:05:08.130', '2026-11-05 16:05:08.130');
INSERT INTO `device_sensor_record` VALUES (932, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60.6, '%', NULL, NULL, '2026-11-05 16:05:08.130', '2026-11-05 16:05:08.130');
INSERT INTO `device_sensor_record` VALUES (933, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 36.7, 'μg/m³', NULL, NULL, '2026-11-05 16:05:08.130', '2026-11-05 16:05:08.130');
INSERT INTO `device_sensor_record` VALUES (934, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 499.1, 'ppm', NULL, NULL, '2026-11-05 16:05:08.130', '2026-11-05 16:05:08.130');
INSERT INTO `device_sensor_record` VALUES (935, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 144, 'lx', NULL, NULL, '2026-11-05 16:05:08.130', '2026-11-05 16:05:08.130');
INSERT INTO `device_sensor_record` VALUES (936, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-05 16:05:08.130', '2026-11-05 16:05:08.130');
INSERT INTO `device_sensor_record` VALUES (937, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-05 16:05:08.130', '2026-11-05 16:05:08.130');
INSERT INTO `device_sensor_record` VALUES (938, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.6, '℃', NULL, NULL, '2026-11-05 16:05:08.130', '2026-11-05 16:05:08.130');
INSERT INTO `device_sensor_record` VALUES (939, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-05 16:05:08.130', '2026-11-05 16:05:08.130');
INSERT INTO `device_sensor_record` VALUES (940, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 150530, 'bytes', NULL, NULL, '2026-11-05 16:05:08.130', '2026-11-05 16:05:08.130');
INSERT INTO `device_sensor_record` VALUES (941, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.6, '℃', NULL, NULL, '2026-11-05 16:05:18.137', '2026-11-05 16:05:18.137');
INSERT INTO `device_sensor_record` VALUES (942, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.2, '%', NULL, NULL, '2026-11-05 16:05:18.137', '2026-11-05 16:05:18.137');
INSERT INTO `device_sensor_record` VALUES (943, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 49.5, 'μg/m³', NULL, NULL, '2026-11-05 16:05:18.137', '2026-11-05 16:05:18.137');
INSERT INTO `device_sensor_record` VALUES (944, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 589.5, 'ppm', NULL, NULL, '2026-11-05 16:05:18.137', '2026-11-05 16:05:18.137');
INSERT INTO `device_sensor_record` VALUES (945, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 455.8, 'lx', NULL, NULL, '2026-11-05 16:05:18.137', '2026-11-05 16:05:18.137');
INSERT INTO `device_sensor_record` VALUES (946, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.3, '℃', NULL, NULL, '2026-11-05 16:05:18.137', '2026-11-05 16:05:18.137');
INSERT INTO `device_sensor_record` VALUES (947, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.5, '℃', NULL, NULL, '2026-11-05 16:05:18.137', '2026-11-05 16:05:18.137');
INSERT INTO `device_sensor_record` VALUES (948, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.7, '℃', NULL, NULL, '2026-11-05 16:05:18.137', '2026-11-05 16:05:18.137');
INSERT INTO `device_sensor_record` VALUES (949, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-05 16:05:18.137', '2026-11-05 16:05:18.137');
INSERT INTO `device_sensor_record` VALUES (950, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 122903, 'bytes', NULL, NULL, '2026-11-05 16:05:18.137', '2026-11-05 16:05:18.137');
INSERT INTO `device_sensor_record` VALUES (951, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 16:05:28.143', '2026-11-05 16:05:28.143');
INSERT INTO `device_sensor_record` VALUES (952, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.7, '%', NULL, NULL, '2026-11-05 16:05:28.143', '2026-11-05 16:05:28.143');
INSERT INTO `device_sensor_record` VALUES (953, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 16:05:28.143', '2026-11-05 16:05:28.143');
INSERT INTO `device_sensor_record` VALUES (954, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 529, 'ppm', NULL, NULL, '2026-11-05 16:05:28.143', '2026-11-05 16:05:28.143');
INSERT INTO `device_sensor_record` VALUES (955, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 775.1, 'lx', NULL, NULL, '2026-11-05 16:05:28.143', '2026-11-05 16:05:28.143');
INSERT INTO `device_sensor_record` VALUES (956, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.5, '℃', NULL, NULL, '2026-11-05 16:05:28.143', '2026-11-05 16:05:28.143');
INSERT INTO `device_sensor_record` VALUES (957, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-05 16:05:28.143', '2026-11-05 16:05:28.143');
INSERT INTO `device_sensor_record` VALUES (958, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.7, '℃', NULL, NULL, '2026-11-05 16:05:28.143', '2026-11-05 16:05:28.143');
INSERT INTO `device_sensor_record` VALUES (959, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-05 16:05:28.143', '2026-11-05 16:05:28.143');
INSERT INTO `device_sensor_record` VALUES (960, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 160033, 'bytes', NULL, NULL, '2026-11-05 16:05:28.143', '2026-11-05 16:05:28.143');
INSERT INTO `device_sensor_record` VALUES (961, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-05 16:05:38.154', '2026-11-05 16:05:38.154');
INSERT INTO `device_sensor_record` VALUES (962, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.2, '%', NULL, NULL, '2026-11-05 16:05:38.154', '2026-11-05 16:05:38.154');
INSERT INTO `device_sensor_record` VALUES (963, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 31.9, 'μg/m³', NULL, NULL, '2026-11-05 16:05:38.154', '2026-11-05 16:05:38.154');
INSERT INTO `device_sensor_record` VALUES (964, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 474.1, 'ppm', NULL, NULL, '2026-11-05 16:05:38.154', '2026-11-05 16:05:38.154');
INSERT INTO `device_sensor_record` VALUES (965, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 528.9, 'lx', NULL, NULL, '2026-11-05 16:05:38.154', '2026-11-05 16:05:38.154');
INSERT INTO `device_sensor_record` VALUES (966, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.4, '℃', NULL, NULL, '2026-11-05 16:05:38.154', '2026-11-05 16:05:38.154');
INSERT INTO `device_sensor_record` VALUES (967, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-05 16:05:38.154', '2026-11-05 16:05:38.154');
INSERT INTO `device_sensor_record` VALUES (968, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.5, '℃', NULL, NULL, '2026-11-05 16:05:38.154', '2026-11-05 16:05:38.154');
INSERT INTO `device_sensor_record` VALUES (969, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-05 16:05:38.154', '2026-11-05 16:05:38.154');
INSERT INTO `device_sensor_record` VALUES (970, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 148437, 'bytes', NULL, NULL, '2026-11-05 16:05:38.154', '2026-11-05 16:05:38.154');
INSERT INTO `device_sensor_record` VALUES (971, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27, '℃', NULL, NULL, '2026-11-05 16:05:48.163', '2026-11-05 16:05:48.163');
INSERT INTO `device_sensor_record` VALUES (972, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.4, '%', NULL, NULL, '2026-11-05 16:05:48.163', '2026-11-05 16:05:48.163');
INSERT INTO `device_sensor_record` VALUES (973, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 33.6, 'μg/m³', NULL, NULL, '2026-11-05 16:05:48.163', '2026-11-05 16:05:48.163');
INSERT INTO `device_sensor_record` VALUES (974, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 496, 'ppm', NULL, NULL, '2026-11-05 16:05:48.163', '2026-11-05 16:05:48.163');
INSERT INTO `device_sensor_record` VALUES (975, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 735.9, 'lx', NULL, NULL, '2026-11-05 16:05:48.163', '2026-11-05 16:05:48.163');
INSERT INTO `device_sensor_record` VALUES (976, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.6, '℃', NULL, NULL, '2026-11-05 16:05:48.163', '2026-11-05 16:05:48.163');
INSERT INTO `device_sensor_record` VALUES (977, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23, '℃', NULL, NULL, '2026-11-05 16:05:48.163', '2026-11-05 16:05:48.163');
INSERT INTO `device_sensor_record` VALUES (978, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45, '℃', NULL, NULL, '2026-11-05 16:05:48.163', '2026-11-05 16:05:48.163');
INSERT INTO `device_sensor_record` VALUES (979, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-05 16:05:48.163', '2026-11-05 16:05:48.163');
INSERT INTO `device_sensor_record` VALUES (980, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 177957, 'bytes', NULL, NULL, '2026-11-05 16:05:48.163', '2026-11-05 16:05:48.163');
INSERT INTO `device_sensor_record` VALUES (981, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25, '℃', NULL, NULL, '2026-11-05 16:05:58.167', '2026-11-05 16:05:58.167');
INSERT INTO `device_sensor_record` VALUES (982, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.5, '%', NULL, NULL, '2026-11-05 16:05:58.167', '2026-11-05 16:05:58.167');
INSERT INTO `device_sensor_record` VALUES (983, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.4, 'μg/m³', NULL, NULL, '2026-11-05 16:05:58.167', '2026-11-05 16:05:58.167');
INSERT INTO `device_sensor_record` VALUES (984, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 533.1, 'ppm', NULL, NULL, '2026-11-05 16:05:58.167', '2026-11-05 16:05:58.167');
INSERT INTO `device_sensor_record` VALUES (985, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 211.1, 'lx', NULL, NULL, '2026-11-05 16:05:58.167', '2026-11-05 16:05:58.167');
INSERT INTO `device_sensor_record` VALUES (986, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.3, '℃', NULL, NULL, '2026-11-05 16:05:58.167', '2026-11-05 16:05:58.167');
INSERT INTO `device_sensor_record` VALUES (987, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25, '℃', NULL, NULL, '2026-11-05 16:05:58.167', '2026-11-05 16:05:58.167');
INSERT INTO `device_sensor_record` VALUES (988, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.3, '℃', NULL, NULL, '2026-11-05 16:05:58.167', '2026-11-05 16:05:58.167');
INSERT INTO `device_sensor_record` VALUES (989, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-05 16:05:58.167', '2026-11-05 16:05:58.167');
INSERT INTO `device_sensor_record` VALUES (990, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 178081, 'bytes', NULL, NULL, '2026-11-05 16:05:58.167', '2026-11-05 16:05:58.167');
INSERT INTO `device_sensor_record` VALUES (991, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.3, '℃', NULL, NULL, '2026-11-05 16:06:08.178', '2026-11-05 16:06:08.178');
INSERT INTO `device_sensor_record` VALUES (992, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64.2, '%', NULL, NULL, '2026-11-05 16:06:08.178', '2026-11-05 16:06:08.178');
INSERT INTO `device_sensor_record` VALUES (993, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 44.5, 'μg/m³', NULL, NULL, '2026-11-05 16:06:08.178', '2026-11-05 16:06:08.178');
INSERT INTO `device_sensor_record` VALUES (994, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 574.1, 'ppm', NULL, NULL, '2026-11-05 16:06:08.178', '2026-11-05 16:06:08.178');
INSERT INTO `device_sensor_record` VALUES (995, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 756.3, 'lx', NULL, NULL, '2026-11-05 16:06:08.178', '2026-11-05 16:06:08.178');
INSERT INTO `device_sensor_record` VALUES (996, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-05 16:06:08.178', '2026-11-05 16:06:08.178');
INSERT INTO `device_sensor_record` VALUES (997, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.3, '℃', NULL, NULL, '2026-11-05 16:06:08.178', '2026-11-05 16:06:08.178');
INSERT INTO `device_sensor_record` VALUES (998, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.3, '℃', NULL, NULL, '2026-11-05 16:06:08.178', '2026-11-05 16:06:08.178');
INSERT INTO `device_sensor_record` VALUES (999, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.39, 'V', NULL, NULL, '2026-11-05 16:06:08.178', '2026-11-05 16:06:08.178');
INSERT INTO `device_sensor_record` VALUES (1000, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 153754, 'bytes', NULL, NULL, '2026-11-05 16:06:08.178', '2026-11-05 16:06:08.178');
INSERT INTO `device_sensor_record` VALUES (1001, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 16:06:18.193', '2026-11-05 16:06:18.193');
INSERT INTO `device_sensor_record` VALUES (1002, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.4, '%', NULL, NULL, '2026-11-05 16:06:18.193', '2026-11-05 16:06:18.193');
INSERT INTO `device_sensor_record` VALUES (1003, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 16:06:18.193', '2026-11-05 16:06:18.193');
INSERT INTO `device_sensor_record` VALUES (1004, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 462.1, 'ppm', NULL, NULL, '2026-11-05 16:06:18.193', '2026-11-05 16:06:18.193');
INSERT INTO `device_sensor_record` VALUES (1005, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 461.4, 'lx', NULL, NULL, '2026-11-05 16:06:18.193', '2026-11-05 16:06:18.193');
INSERT INTO `device_sensor_record` VALUES (1006, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.2, '℃', NULL, NULL, '2026-11-05 16:06:18.193', '2026-11-05 16:06:18.193');
INSERT INTO `device_sensor_record` VALUES (1007, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.9, '℃', NULL, NULL, '2026-11-05 16:06:18.193', '2026-11-05 16:06:18.193');
INSERT INTO `device_sensor_record` VALUES (1008, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.6, '℃', NULL, NULL, '2026-11-05 16:06:18.193', '2026-11-05 16:06:18.193');
INSERT INTO `device_sensor_record` VALUES (1009, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-05 16:06:18.193', '2026-11-05 16:06:18.193');
INSERT INTO `device_sensor_record` VALUES (1010, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 173057, 'bytes', NULL, NULL, '2026-11-05 16:06:18.193', '2026-11-05 16:06:18.193');
INSERT INTO `device_sensor_record` VALUES (1011, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-05 16:06:28.194', '2026-11-05 16:06:28.194');
INSERT INTO `device_sensor_record` VALUES (1012, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 69.2, '%', NULL, NULL, '2026-11-05 16:06:28.194', '2026-11-05 16:06:28.194');
INSERT INTO `device_sensor_record` VALUES (1013, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 43.7, 'μg/m³', NULL, NULL, '2026-11-05 16:06:28.194', '2026-11-05 16:06:28.194');
INSERT INTO `device_sensor_record` VALUES (1014, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 535.4, 'ppm', NULL, NULL, '2026-11-05 16:06:28.194', '2026-11-05 16:06:28.194');
INSERT INTO `device_sensor_record` VALUES (1015, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 792, 'lx', NULL, NULL, '2026-11-05 16:06:28.194', '2026-11-05 16:06:28.194');
INSERT INTO `device_sensor_record` VALUES (1016, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.3, '℃', NULL, NULL, '2026-11-05 16:06:28.194', '2026-11-05 16:06:28.194');
INSERT INTO `device_sensor_record` VALUES (1017, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-05 16:06:28.194', '2026-11-05 16:06:28.194');
INSERT INTO `device_sensor_record` VALUES (1018, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.6, '℃', NULL, NULL, '2026-11-05 16:06:28.194', '2026-11-05 16:06:28.194');
INSERT INTO `device_sensor_record` VALUES (1019, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-05 16:06:28.194', '2026-11-05 16:06:28.194');
INSERT INTO `device_sensor_record` VALUES (1020, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 137012, 'bytes', NULL, NULL, '2026-11-05 16:06:28.194', '2026-11-05 16:06:28.194');
INSERT INTO `device_sensor_record` VALUES (1021, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.8, '℃', NULL, NULL, '2026-11-05 16:06:38.206', '2026-11-05 16:06:38.206');
INSERT INTO `device_sensor_record` VALUES (1022, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 57.6, '%', NULL, NULL, '2026-11-05 16:06:38.206', '2026-11-05 16:06:38.206');
INSERT INTO `device_sensor_record` VALUES (1023, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 30.5, 'μg/m³', NULL, NULL, '2026-11-05 16:06:38.206', '2026-11-05 16:06:38.206');
INSERT INTO `device_sensor_record` VALUES (1024, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 460.9, 'ppm', NULL, NULL, '2026-11-05 16:06:38.206', '2026-11-05 16:06:38.206');
INSERT INTO `device_sensor_record` VALUES (1025, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 467.6, 'lx', NULL, NULL, '2026-11-05 16:06:38.206', '2026-11-05 16:06:38.206');
INSERT INTO `device_sensor_record` VALUES (1026, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-05 16:06:38.206', '2026-11-05 16:06:38.206');
INSERT INTO `device_sensor_record` VALUES (1027, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25, '℃', NULL, NULL, '2026-11-05 16:06:38.206', '2026-11-05 16:06:38.206');
INSERT INTO `device_sensor_record` VALUES (1028, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.9, '℃', NULL, NULL, '2026-11-05 16:06:38.206', '2026-11-05 16:06:38.206');
INSERT INTO `device_sensor_record` VALUES (1029, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-05 16:06:38.206', '2026-11-05 16:06:38.206');
INSERT INTO `device_sensor_record` VALUES (1030, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 121209, 'bytes', NULL, NULL, '2026-11-05 16:06:38.206', '2026-11-05 16:06:38.206');
INSERT INTO `device_sensor_record` VALUES (1031, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24, '℃', NULL, NULL, '2026-11-05 16:06:48.209', '2026-11-05 16:06:48.209');
INSERT INTO `device_sensor_record` VALUES (1032, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.4, '%', NULL, NULL, '2026-11-05 16:06:48.209', '2026-11-05 16:06:48.209');
INSERT INTO `device_sensor_record` VALUES (1033, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 40.5, 'μg/m³', NULL, NULL, '2026-11-05 16:06:48.209', '2026-11-05 16:06:48.209');
INSERT INTO `device_sensor_record` VALUES (1034, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 423, 'ppm', NULL, NULL, '2026-11-05 16:06:48.209', '2026-11-05 16:06:48.209');
INSERT INTO `device_sensor_record` VALUES (1035, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 587.4, 'lx', NULL, NULL, '2026-11-05 16:06:48.209', '2026-11-05 16:06:48.209');
INSERT INTO `device_sensor_record` VALUES (1036, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-05 16:06:48.209', '2026-11-05 16:06:48.209');
INSERT INTO `device_sensor_record` VALUES (1037, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 26, '℃', NULL, NULL, '2026-11-05 16:06:48.209', '2026-11-05 16:06:48.209');
INSERT INTO `device_sensor_record` VALUES (1038, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.6, '℃', NULL, NULL, '2026-11-05 16:06:48.209', '2026-11-05 16:06:48.209');
INSERT INTO `device_sensor_record` VALUES (1039, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-05 16:06:48.209', '2026-11-05 16:06:48.209');
INSERT INTO `device_sensor_record` VALUES (1040, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 128627, 'bytes', NULL, NULL, '2026-11-05 16:06:48.209', '2026-11-05 16:06:48.209');
INSERT INTO `device_sensor_record` VALUES (1041, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.1, '℃', NULL, NULL, '2026-11-05 16:06:58.216', '2026-11-05 16:06:58.216');
INSERT INTO `device_sensor_record` VALUES (1042, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 57.3, '%', NULL, NULL, '2026-11-05 16:06:58.216', '2026-11-05 16:06:58.216');
INSERT INTO `device_sensor_record` VALUES (1043, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 38.1, 'μg/m³', NULL, NULL, '2026-11-05 16:06:58.216', '2026-11-05 16:06:58.216');
INSERT INTO `device_sensor_record` VALUES (1044, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 546.4, 'ppm', NULL, NULL, '2026-11-05 16:06:58.216', '2026-11-05 16:06:58.216');
INSERT INTO `device_sensor_record` VALUES (1045, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 218.9, 'lx', NULL, NULL, '2026-11-05 16:06:58.216', '2026-11-05 16:06:58.216');
INSERT INTO `device_sensor_record` VALUES (1046, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-05 16:06:58.216', '2026-11-05 16:06:58.216');
INSERT INTO `device_sensor_record` VALUES (1047, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.7, '℃', NULL, NULL, '2026-11-05 16:06:58.216', '2026-11-05 16:06:58.216');
INSERT INTO `device_sensor_record` VALUES (1048, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54, '℃', NULL, NULL, '2026-11-05 16:06:58.216', '2026-11-05 16:06:58.216');
INSERT INTO `device_sensor_record` VALUES (1049, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-05 16:06:58.216', '2026-11-05 16:06:58.216');
INSERT INTO `device_sensor_record` VALUES (1050, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 131980, 'bytes', NULL, NULL, '2026-11-05 16:06:58.216', '2026-11-05 16:06:58.216');
INSERT INTO `device_sensor_record` VALUES (1051, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 16:07:08.225', '2026-11-05 16:07:08.225');
INSERT INTO `device_sensor_record` VALUES (1052, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.9, '%', NULL, NULL, '2026-11-05 16:07:08.225', '2026-11-05 16:07:08.225');
INSERT INTO `device_sensor_record` VALUES (1053, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 16:07:08.225', '2026-11-05 16:07:08.225');
INSERT INTO `device_sensor_record` VALUES (1054, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 526.1, 'ppm', NULL, NULL, '2026-11-05 16:07:08.225', '2026-11-05 16:07:08.225');
INSERT INTO `device_sensor_record` VALUES (1055, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 179.1, 'lx', NULL, NULL, '2026-11-05 16:07:08.225', '2026-11-05 16:07:08.225');
INSERT INTO `device_sensor_record` VALUES (1056, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.6, '℃', NULL, NULL, '2026-11-05 16:07:08.225', '2026-11-05 16:07:08.225');
INSERT INTO `device_sensor_record` VALUES (1057, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.4, '℃', NULL, NULL, '2026-11-05 16:07:08.225', '2026-11-05 16:07:08.225');
INSERT INTO `device_sensor_record` VALUES (1058, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.6, '℃', NULL, NULL, '2026-11-05 16:07:08.225', '2026-11-05 16:07:08.225');
INSERT INTO `device_sensor_record` VALUES (1059, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-05 16:07:08.225', '2026-11-05 16:07:08.225');
INSERT INTO `device_sensor_record` VALUES (1060, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 150791, 'bytes', NULL, NULL, '2026-11-05 16:07:08.225', '2026-11-05 16:07:08.225');
INSERT INTO `device_sensor_record` VALUES (1061, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-05 16:07:18.229', '2026-11-05 16:07:18.229');
INSERT INTO `device_sensor_record` VALUES (1062, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.7, '%', NULL, NULL, '2026-11-05 16:07:18.229', '2026-11-05 16:07:18.229');
INSERT INTO `device_sensor_record` VALUES (1063, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 46.9, 'μg/m³', NULL, NULL, '2026-11-05 16:07:18.229', '2026-11-05 16:07:18.229');
INSERT INTO `device_sensor_record` VALUES (1064, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 577.5, 'ppm', NULL, NULL, '2026-11-05 16:07:18.229', '2026-11-05 16:07:18.229');
INSERT INTO `device_sensor_record` VALUES (1065, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 391.4, 'lx', NULL, NULL, '2026-11-05 16:07:18.229', '2026-11-05 16:07:18.229');
INSERT INTO `device_sensor_record` VALUES (1066, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-05 16:07:18.229', '2026-11-05 16:07:18.229');
INSERT INTO `device_sensor_record` VALUES (1067, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-05 16:07:18.229', '2026-11-05 16:07:18.229');
INSERT INTO `device_sensor_record` VALUES (1068, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.2, '℃', NULL, NULL, '2026-11-05 16:07:18.229', '2026-11-05 16:07:18.229');
INSERT INTO `device_sensor_record` VALUES (1069, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-05 16:07:18.229', '2026-11-05 16:07:18.229');
INSERT INTO `device_sensor_record` VALUES (1070, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 161548, 'bytes', NULL, NULL, '2026-11-05 16:07:18.229', '2026-11-05 16:07:18.229');
INSERT INTO `device_sensor_record` VALUES (1071, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.7, '℃', NULL, NULL, '2026-11-05 16:07:28.237', '2026-11-05 16:07:28.237');
INSERT INTO `device_sensor_record` VALUES (1072, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60.9, '%', NULL, NULL, '2026-11-05 16:07:28.237', '2026-11-05 16:07:28.237');
INSERT INTO `device_sensor_record` VALUES (1073, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 20.4, 'μg/m³', NULL, NULL, '2026-11-05 16:07:28.237', '2026-11-05 16:07:28.237');
INSERT INTO `device_sensor_record` VALUES (1074, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 430.7, 'ppm', NULL, NULL, '2026-11-05 16:07:28.237', '2026-11-05 16:07:28.237');
INSERT INTO `device_sensor_record` VALUES (1075, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 243.1, 'lx', NULL, NULL, '2026-11-05 16:07:28.237', '2026-11-05 16:07:28.237');
INSERT INTO `device_sensor_record` VALUES (1076, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-05 16:07:28.237', '2026-11-05 16:07:28.237');
INSERT INTO `device_sensor_record` VALUES (1077, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-05 16:07:28.237', '2026-11-05 16:07:28.237');
INSERT INTO `device_sensor_record` VALUES (1078, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.8, '℃', NULL, NULL, '2026-11-05 16:07:28.237', '2026-11-05 16:07:28.237');
INSERT INTO `device_sensor_record` VALUES (1079, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-05 16:07:28.237', '2026-11-05 16:07:28.237');
INSERT INTO `device_sensor_record` VALUES (1080, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 157437, 'bytes', NULL, NULL, '2026-11-05 16:07:28.237', '2026-11-05 16:07:28.237');
INSERT INTO `device_sensor_record` VALUES (1081, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.8, '℃', NULL, NULL, '2026-11-05 16:07:38.239', '2026-11-05 16:07:38.239');
INSERT INTO `device_sensor_record` VALUES (1082, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60, '%', NULL, NULL, '2026-11-05 16:07:38.239', '2026-11-05 16:07:38.239');
INSERT INTO `device_sensor_record` VALUES (1083, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 42.3, 'μg/m³', NULL, NULL, '2026-11-05 16:07:38.239', '2026-11-05 16:07:38.239');
INSERT INTO `device_sensor_record` VALUES (1084, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 550, 'ppm', NULL, NULL, '2026-11-05 16:07:38.239', '2026-11-05 16:07:38.239');
INSERT INTO `device_sensor_record` VALUES (1085, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 745, 'lx', NULL, NULL, '2026-11-05 16:07:38.239', '2026-11-05 16:07:38.239');
INSERT INTO `device_sensor_record` VALUES (1086, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-05 16:07:38.239', '2026-11-05 16:07:38.239');
INSERT INTO `device_sensor_record` VALUES (1087, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.8, '℃', NULL, NULL, '2026-11-05 16:07:38.239', '2026-11-05 16:07:38.239');
INSERT INTO `device_sensor_record` VALUES (1088, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.9, '℃', NULL, NULL, '2026-11-05 16:07:38.239', '2026-11-05 16:07:38.239');
INSERT INTO `device_sensor_record` VALUES (1089, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-05 16:07:38.239', '2026-11-05 16:07:38.239');
INSERT INTO `device_sensor_record` VALUES (1090, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 151536, 'bytes', NULL, NULL, '2026-11-05 16:07:38.239', '2026-11-05 16:07:38.239');
INSERT INTO `device_sensor_record` VALUES (1091, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-05 16:07:48.248', '2026-11-05 16:07:48.248');
INSERT INTO `device_sensor_record` VALUES (1092, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 57.1, '%', NULL, NULL, '2026-11-05 16:07:48.248', '2026-11-05 16:07:48.248');
INSERT INTO `device_sensor_record` VALUES (1093, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 49.5, 'μg/m³', NULL, NULL, '2026-11-05 16:07:48.248', '2026-11-05 16:07:48.248');
INSERT INTO `device_sensor_record` VALUES (1094, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 546.1, 'ppm', NULL, NULL, '2026-11-05 16:07:48.248', '2026-11-05 16:07:48.248');
INSERT INTO `device_sensor_record` VALUES (1095, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 516.5, 'lx', NULL, NULL, '2026-11-05 16:07:48.248', '2026-11-05 16:07:48.248');
INSERT INTO `device_sensor_record` VALUES (1096, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.6, '℃', NULL, NULL, '2026-11-05 16:07:48.248', '2026-11-05 16:07:48.248');
INSERT INTO `device_sensor_record` VALUES (1097, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-05 16:07:48.248', '2026-11-05 16:07:48.248');
INSERT INTO `device_sensor_record` VALUES (1098, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.9, '℃', NULL, NULL, '2026-11-05 16:07:48.248', '2026-11-05 16:07:48.248');
INSERT INTO `device_sensor_record` VALUES (1099, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-05 16:07:48.248', '2026-11-05 16:07:48.248');
INSERT INTO `device_sensor_record` VALUES (1100, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 169119, 'bytes', NULL, NULL, '2026-11-05 16:07:48.248', '2026-11-05 16:07:48.248');
INSERT INTO `device_sensor_record` VALUES (1101, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 16:07:58.256', '2026-11-05 16:07:58.256');
INSERT INTO `device_sensor_record` VALUES (1102, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.1, '%', NULL, NULL, '2026-11-05 16:07:58.256', '2026-11-05 16:07:58.256');
INSERT INTO `device_sensor_record` VALUES (1103, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 16:07:58.256', '2026-11-05 16:07:58.256');
INSERT INTO `device_sensor_record` VALUES (1104, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 571.2, 'ppm', NULL, NULL, '2026-11-05 16:07:58.256', '2026-11-05 16:07:58.256');
INSERT INTO `device_sensor_record` VALUES (1105, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 403.2, 'lx', NULL, NULL, '2026-11-05 16:07:58.256', '2026-11-05 16:07:58.256');
INSERT INTO `device_sensor_record` VALUES (1106, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 23, '℃', NULL, NULL, '2026-11-05 16:07:58.256', '2026-11-05 16:07:58.256');
INSERT INTO `device_sensor_record` VALUES (1107, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.4, '℃', NULL, NULL, '2026-11-05 16:07:58.256', '2026-11-05 16:07:58.256');
INSERT INTO `device_sensor_record` VALUES (1108, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54, '℃', NULL, NULL, '2026-11-05 16:07:58.256', '2026-11-05 16:07:58.256');
INSERT INTO `device_sensor_record` VALUES (1109, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-05 16:07:58.256', '2026-11-05 16:07:58.256');
INSERT INTO `device_sensor_record` VALUES (1110, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 159618, 'bytes', NULL, NULL, '2026-11-05 16:07:58.256', '2026-11-05 16:07:58.256');
INSERT INTO `device_sensor_record` VALUES (1111, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-05 16:08:08.263', '2026-11-05 16:08:08.263');
INSERT INTO `device_sensor_record` VALUES (1112, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 69.1, '%', NULL, NULL, '2026-11-05 16:08:08.263', '2026-11-05 16:08:08.263');
INSERT INTO `device_sensor_record` VALUES (1113, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 49.9, 'μg/m³', NULL, NULL, '2026-11-05 16:08:08.263', '2026-11-05 16:08:08.263');
INSERT INTO `device_sensor_record` VALUES (1114, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 538, 'ppm', NULL, NULL, '2026-11-05 16:08:08.263', '2026-11-05 16:08:08.263');
INSERT INTO `device_sensor_record` VALUES (1115, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 629, 'lx', NULL, NULL, '2026-11-05 16:08:08.263', '2026-11-05 16:08:08.263');
INSERT INTO `device_sensor_record` VALUES (1116, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-05 16:08:08.263', '2026-11-05 16:08:08.263');
INSERT INTO `device_sensor_record` VALUES (1117, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.4, '℃', NULL, NULL, '2026-11-05 16:08:08.263', '2026-11-05 16:08:08.263');
INSERT INTO `device_sensor_record` VALUES (1118, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.7, '℃', NULL, NULL, '2026-11-05 16:08:08.263', '2026-11-05 16:08:08.263');
INSERT INTO `device_sensor_record` VALUES (1119, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-05 16:08:08.263', '2026-11-05 16:08:08.263');
INSERT INTO `device_sensor_record` VALUES (1120, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 146344, 'bytes', NULL, NULL, '2026-11-05 16:08:08.263', '2026-11-05 16:08:08.263');
INSERT INTO `device_sensor_record` VALUES (1121, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-05 16:08:18.270', '2026-11-05 16:08:18.270');
INSERT INTO `device_sensor_record` VALUES (1122, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.6, '%', NULL, NULL, '2026-11-05 16:08:18.270', '2026-11-05 16:08:18.270');
INSERT INTO `device_sensor_record` VALUES (1123, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 44.3, 'μg/m³', NULL, NULL, '2026-11-05 16:08:18.270', '2026-11-05 16:08:18.270');
INSERT INTO `device_sensor_record` VALUES (1124, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 478.2, 'ppm', NULL, NULL, '2026-11-05 16:08:18.270', '2026-11-05 16:08:18.270');
INSERT INTO `device_sensor_record` VALUES (1125, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 159.7, 'lx', NULL, NULL, '2026-11-05 16:08:18.270', '2026-11-05 16:08:18.270');
INSERT INTO `device_sensor_record` VALUES (1126, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.5, '℃', NULL, NULL, '2026-11-05 16:08:18.270', '2026-11-05 16:08:18.270');
INSERT INTO `device_sensor_record` VALUES (1127, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-05 16:08:18.270', '2026-11-05 16:08:18.270');
INSERT INTO `device_sensor_record` VALUES (1128, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.4, '℃', NULL, NULL, '2026-11-05 16:08:18.270', '2026-11-05 16:08:18.270');
INSERT INTO `device_sensor_record` VALUES (1129, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.22, 'V', NULL, NULL, '2026-11-05 16:08:18.270', '2026-11-05 16:08:18.270');
INSERT INTO `device_sensor_record` VALUES (1130, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 151932, 'bytes', NULL, NULL, '2026-11-05 16:08:18.270', '2026-11-05 16:08:18.270');
INSERT INTO `device_sensor_record` VALUES (1131, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-05 16:08:28.271', '2026-11-05 16:08:28.271');
INSERT INTO `device_sensor_record` VALUES (1132, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.2, '%', NULL, NULL, '2026-11-05 16:08:28.271', '2026-11-05 16:08:28.271');
INSERT INTO `device_sensor_record` VALUES (1133, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35.1, 'μg/m³', NULL, NULL, '2026-11-05 16:08:28.271', '2026-11-05 16:08:28.271');
INSERT INTO `device_sensor_record` VALUES (1134, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 525.2, 'ppm', NULL, NULL, '2026-11-05 16:08:28.271', '2026-11-05 16:08:28.271');
INSERT INTO `device_sensor_record` VALUES (1135, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 609.2, 'lx', NULL, NULL, '2026-11-05 16:08:28.271', '2026-11-05 16:08:28.271');
INSERT INTO `device_sensor_record` VALUES (1136, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.7, '℃', NULL, NULL, '2026-11-05 16:08:28.271', '2026-11-05 16:08:28.271');
INSERT INTO `device_sensor_record` VALUES (1137, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-05 16:08:28.271', '2026-11-05 16:08:28.271');
INSERT INTO `device_sensor_record` VALUES (1138, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.1, '℃', NULL, NULL, '2026-11-05 16:08:28.271', '2026-11-05 16:08:28.271');
INSERT INTO `device_sensor_record` VALUES (1139, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.39, 'V', NULL, NULL, '2026-11-05 16:08:28.271', '2026-11-05 16:08:28.271');
INSERT INTO `device_sensor_record` VALUES (1140, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 157473, 'bytes', NULL, NULL, '2026-11-05 16:08:28.271', '2026-11-05 16:08:28.271');
INSERT INTO `device_sensor_record` VALUES (1141, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-05 16:08:38.275', '2026-11-05 16:08:38.275');
INSERT INTO `device_sensor_record` VALUES (1142, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.5, '%', NULL, NULL, '2026-11-05 16:08:38.275', '2026-11-05 16:08:38.275');
INSERT INTO `device_sensor_record` VALUES (1143, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35.3, 'μg/m³', NULL, NULL, '2026-11-05 16:08:38.275', '2026-11-05 16:08:38.275');
INSERT INTO `device_sensor_record` VALUES (1144, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 546.2, 'ppm', NULL, NULL, '2026-11-05 16:08:38.275', '2026-11-05 16:08:38.275');
INSERT INTO `device_sensor_record` VALUES (1145, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 398.6, 'lx', NULL, NULL, '2026-11-05 16:08:38.275', '2026-11-05 16:08:38.275');
INSERT INTO `device_sensor_record` VALUES (1146, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.9, '℃', NULL, NULL, '2026-11-05 16:08:38.275', '2026-11-05 16:08:38.275');
INSERT INTO `device_sensor_record` VALUES (1147, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-05 16:08:38.275', '2026-11-05 16:08:38.275');
INSERT INTO `device_sensor_record` VALUES (1148, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.9, '℃', NULL, NULL, '2026-11-05 16:08:38.275', '2026-11-05 16:08:38.275');
INSERT INTO `device_sensor_record` VALUES (1149, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-05 16:08:38.275', '2026-11-05 16:08:38.275');
INSERT INTO `device_sensor_record` VALUES (1150, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 175865, 'bytes', NULL, NULL, '2026-11-05 16:08:38.275', '2026-11-05 16:08:38.275');
INSERT INTO `device_sensor_record` VALUES (1151, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-05 16:08:48.284', '2026-11-05 16:08:48.284');
INSERT INTO `device_sensor_record` VALUES (1152, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64.2, '%', NULL, NULL, '2026-11-05 16:08:48.284', '2026-11-05 16:08:48.284');
INSERT INTO `device_sensor_record` VALUES (1153, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-05 16:08:48.284', '2026-11-05 16:08:48.284');
INSERT INTO `device_sensor_record` VALUES (1154, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 476.6, 'ppm', NULL, NULL, '2026-11-05 16:08:48.284', '2026-11-05 16:08:48.284');
INSERT INTO `device_sensor_record` VALUES (1155, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 354.1, 'lx', NULL, NULL, '2026-11-05 16:08:48.284', '2026-11-05 16:08:48.284');
INSERT INTO `device_sensor_record` VALUES (1156, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.3, '℃', NULL, NULL, '2026-11-05 16:08:48.284', '2026-11-05 16:08:48.284');
INSERT INTO `device_sensor_record` VALUES (1157, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-05 16:08:48.284', '2026-11-05 16:08:48.284');
INSERT INTO `device_sensor_record` VALUES (1158, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.8, '℃', NULL, NULL, '2026-11-05 16:08:48.284', '2026-11-05 16:08:48.284');
INSERT INTO `device_sensor_record` VALUES (1159, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-05 16:08:48.284', '2026-11-05 16:08:48.284');
INSERT INTO `device_sensor_record` VALUES (1160, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 152273, 'bytes', NULL, NULL, '2026-11-05 16:08:48.284', '2026-11-05 16:08:48.284');
INSERT INTO `device_sensor_record` VALUES (1161, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.5, '℃', NULL, NULL, '2026-11-05 16:08:58.291', '2026-11-05 16:08:58.291');
INSERT INTO `device_sensor_record` VALUES (1162, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.3, '%', NULL, NULL, '2026-11-05 16:08:58.291', '2026-11-05 16:08:58.291');
INSERT INTO `device_sensor_record` VALUES (1163, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 44.1, 'μg/m³', NULL, NULL, '2026-11-05 16:08:58.291', '2026-11-05 16:08:58.291');
INSERT INTO `device_sensor_record` VALUES (1164, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 429.7, 'ppm', NULL, NULL, '2026-11-05 16:08:58.291', '2026-11-05 16:08:58.291');
INSERT INTO `device_sensor_record` VALUES (1165, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 453.8, 'lx', NULL, NULL, '2026-11-05 16:08:58.291', '2026-11-05 16:08:58.291');
INSERT INTO `device_sensor_record` VALUES (1166, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.1, '℃', NULL, NULL, '2026-11-05 16:08:58.291', '2026-11-05 16:08:58.291');
INSERT INTO `device_sensor_record` VALUES (1167, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-05 16:08:58.291', '2026-11-05 16:08:58.291');
INSERT INTO `device_sensor_record` VALUES (1168, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.8, '℃', NULL, NULL, '2026-11-05 16:08:58.291', '2026-11-05 16:08:58.291');
INSERT INTO `device_sensor_record` VALUES (1169, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-05 16:08:58.291', '2026-11-05 16:08:58.291');
INSERT INTO `device_sensor_record` VALUES (1170, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 137639, 'bytes', NULL, NULL, '2026-11-05 16:08:58.291', '2026-11-05 16:08:58.291');
INSERT INTO `device_sensor_record` VALUES (1171, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.2, '℃', NULL, NULL, '2026-11-05 16:09:08.291', '2026-11-05 16:09:08.291');
INSERT INTO `device_sensor_record` VALUES (1172, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.9, '%', NULL, NULL, '2026-11-05 16:09:08.291', '2026-11-05 16:09:08.291');
INSERT INTO `device_sensor_record` VALUES (1173, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 45.1, 'μg/m³', NULL, NULL, '2026-11-05 16:09:08.291', '2026-11-05 16:09:08.291');
INSERT INTO `device_sensor_record` VALUES (1174, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 412.2, 'ppm', NULL, NULL, '2026-11-05 16:09:08.291', '2026-11-05 16:09:08.291');
INSERT INTO `device_sensor_record` VALUES (1175, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 785.5, 'lx', NULL, NULL, '2026-11-05 16:09:08.291', '2026-11-05 16:09:08.291');
INSERT INTO `device_sensor_record` VALUES (1176, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.8, '℃', NULL, NULL, '2026-11-05 16:09:08.291', '2026-11-05 16:09:08.291');
INSERT INTO `device_sensor_record` VALUES (1177, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-05 16:09:08.291', '2026-11-05 16:09:08.291');
INSERT INTO `device_sensor_record` VALUES (1178, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.5, '℃', NULL, NULL, '2026-11-05 16:09:08.291', '2026-11-05 16:09:08.291');
INSERT INTO `device_sensor_record` VALUES (1179, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.29, 'V', NULL, NULL, '2026-11-05 16:09:08.291', '2026-11-05 16:09:08.291');
INSERT INTO `device_sensor_record` VALUES (1180, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 175932, 'bytes', NULL, NULL, '2026-11-05 16:09:08.291', '2026-11-05 16:09:08.291');
INSERT INTO `device_sensor_record` VALUES (1181, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-05 16:09:18.296', '2026-11-05 16:09:18.296');
INSERT INTO `device_sensor_record` VALUES (1182, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 57, '%', NULL, NULL, '2026-11-05 16:09:18.296', '2026-11-05 16:09:18.296');
INSERT INTO `device_sensor_record` VALUES (1183, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26, 'μg/m³', NULL, NULL, '2026-11-05 16:09:18.296', '2026-11-05 16:09:18.296');
INSERT INTO `device_sensor_record` VALUES (1184, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 519, 'ppm', NULL, NULL, '2026-11-05 16:09:18.296', '2026-11-05 16:09:18.296');
INSERT INTO `device_sensor_record` VALUES (1185, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 126.5, 'lx', NULL, NULL, '2026-11-05 16:09:18.296', '2026-11-05 16:09:18.296');
INSERT INTO `device_sensor_record` VALUES (1186, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.3, '℃', NULL, NULL, '2026-11-05 16:09:18.296', '2026-11-05 16:09:18.296');
INSERT INTO `device_sensor_record` VALUES (1187, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-05 16:09:18.296', '2026-11-05 16:09:18.296');
INSERT INTO `device_sensor_record` VALUES (1188, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.8, '℃', NULL, NULL, '2026-11-05 16:09:18.296', '2026-11-05 16:09:18.296');
INSERT INTO `device_sensor_record` VALUES (1189, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-05 16:09:18.296', '2026-11-05 16:09:18.296');
INSERT INTO `device_sensor_record` VALUES (1190, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 141036, 'bytes', NULL, NULL, '2026-11-05 16:09:18.296', '2026-11-05 16:09:18.296');
INSERT INTO `device_sensor_record` VALUES (1191, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-05 16:09:28.302', '2026-11-05 16:09:28.302');
INSERT INTO `device_sensor_record` VALUES (1192, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.5, '%', NULL, NULL, '2026-11-05 16:09:28.302', '2026-11-05 16:09:28.302');
INSERT INTO `device_sensor_record` VALUES (1193, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 36.7, 'μg/m³', NULL, NULL, '2026-11-05 16:09:28.302', '2026-11-05 16:09:28.302');
INSERT INTO `device_sensor_record` VALUES (1194, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 532.1, 'ppm', NULL, NULL, '2026-11-05 16:09:28.302', '2026-11-05 16:09:28.302');
INSERT INTO `device_sensor_record` VALUES (1195, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 666.5, 'lx', NULL, NULL, '2026-11-05 16:09:28.302', '2026-11-05 16:09:28.302');
INSERT INTO `device_sensor_record` VALUES (1196, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.2, '℃', NULL, NULL, '2026-11-05 16:09:28.302', '2026-11-05 16:09:28.302');
INSERT INTO `device_sensor_record` VALUES (1197, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-05 16:09:28.302', '2026-11-05 16:09:28.302');
INSERT INTO `device_sensor_record` VALUES (1198, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.1, '℃', NULL, NULL, '2026-11-05 16:09:28.302', '2026-11-05 16:09:28.302');
INSERT INTO `device_sensor_record` VALUES (1199, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-05 16:09:28.302', '2026-11-05 16:09:28.302');
INSERT INTO `device_sensor_record` VALUES (1200, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 163849, 'bytes', NULL, NULL, '2026-11-05 16:09:28.302', '2026-11-05 16:09:28.302');

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
  INDEX `idx_sensor_type`(`sensor_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '传感器阈值配置表' ROW_FORMAT = DYNAMIC;

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
  UNIQUE INDEX `uk_device_addr_type_channel`(`device_id` ASC, `address` ASC, `slave_type` ASC, `channel` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_device_type`(`device_id` ASC, `slave_type` ASC) USING BTREE,
  INDEX `idx_timestamp`(`timestamp` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备从机数据表(在线即存在，离线即删除)' ROW_FORMAT = DYNAMIC;

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
  INDEX `idx_timestamp`(`timestamp` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备状态时序表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备白名单（产线导入，允许注册的设备）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_whitelist
-- ----------------------------

-- ----------------------------
-- Table structure for sys_dead_letter
-- ----------------------------
DROP TABLE IF EXISTS `sys_dead_letter`;
CREATE TABLE `sys_dead_letter`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `topic` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '死信主题',
  `payload` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '原始报文',
  `error_msg` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '错误堆栈简略信息',
  `is_retryable` int NULL DEFAULT NULL COMMENT '0-不能重试 1-表示可以重试',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '0-未处理 1-已重放成功 2-已忽略',
  `retry_count` int NOT NULL DEFAULT 0 COMMENT '重放次数',
  `create_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'MQTT死信队列' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dead_letter
-- ----------------------------

-- ----------------------------
-- Table structure for sys_login_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_login_log`;
CREATE TABLE `sys_login_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '尝试登录的用户名',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户端IP',
  `user_agent` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '浏览器/客户端 UA',
  `status` tinyint NOT NULL COMMENT '状态：1-成功，0-失败',
  `message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '提示消息/失败原因',
  `login_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '登录时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_login_time`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_login_log
-- ----------------------------
INSERT INTO `sys_login_log` VALUES (1, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36', 1, '登录成功', '2026-11-05 15:56:40.476');
INSERT INTO `sys_login_log` VALUES (2, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36', 1, '登录成功', '2026-11-05 16:07:57.963');

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
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_permission
-- ----------------------------
INSERT INTO `sys_permission` VALUES (1, 'device:list', '查询设备列表', 'API', 'device', 'read', '获取设备分页列表', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (2, 'device:read', '查看设备详情', 'API', 'device', 'read', '获取单台设备详细信息', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (3, 'device:create', '添加设备', 'API', 'device', 'create', '录入新设备', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (4, 'device:update', '修改设备', 'API', 'device', 'update', '修改设备名称、位置等信息', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (5, 'device:delete', '删除设备', 'API', 'device', 'delete', '移除设备', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (6, 'device:bind', '绑定设备', 'API', 'device', 'update', '用户绑定设备', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (7, 'device:unbind', '解绑设备', 'API', 'device', 'update', '用户解绑设备', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (8, 'command:send', '下发指令', 'API', 'command', 'create', '向设备下发控制指令(mos/led/servo等)', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (9, 'firmware:list', '查询固件', 'API', 'firmware', 'read', '查看固件版本列表', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (10, 'firmware:upload', '上传固件', 'API', 'firmware', 'create', '上传新的固件包', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (11, 'ota:create', '发起OTA', 'API', 'ota', 'create', '批量下发OTA升级任务', 1, '2026-10-26 16:03:52', '2026-10-27 15:15:12', 0);
INSERT INTO `sys_permission` VALUES (12, 'ota:cancel', '取消OTA', 'API', 'ota', 'update', '取消正在进行的升级任务', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (13, 'alert:list', '查询告警', 'API', 'alert', 'read', '查看告警记录', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (14, 'alert:handle', '处理告警', 'API', 'alert', 'update', '确认或解决告警', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (15, 'user:list', '查询用户', 'API', 'user', 'read', '查看用户列表', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (16, 'user:create', '创建用户', 'API', 'user', 'create', '管理员添加用户', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (17, 'user:update', '修改用户', 'API', 'user', 'update', '修改用户状态或角色', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (18, 'system:config', '系统配置', 'API', 'system', 'update', '修改系统级参数', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (19, 'firmware:delete', '删除固件', 'API', 'firmware', 'delete', '删除废弃的固件包', 1, '2026-10-27 15:09:44', '2026-10-27 15:09:44', 0);
INSERT INTO `sys_permission` VALUES (20, 'ota:list', '查询固件', 'API', 'firmware', 'select', '查询所有的固件包', 1, '2026-10-27 15:12:10', '2026-10-27 15:12:10', 0);

-- ----------------------------
-- Table structure for sys_refresh_token
-- ----------------------------
DROP TABLE IF EXISTS `sys_refresh_token`;
CREATE TABLE `sys_refresh_token`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `token_hash` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'RefreshToken的SHA256哈希',
  `device_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'web' COMMENT '设备类型',
  `expires_at` datetime(3) NOT NULL COMMENT '过期时间',
  `revoked` tinyint NOT NULL DEFAULT 0 COMMENT '0-有效 1-已撤销',
  `create_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_token_hash`(`token_hash` ASC) USING BTREE,
  INDEX `idx_user_revoked`(`user_id` ASC, `revoked` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户Refresh Token表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_refresh_token
-- ----------------------------
INSERT INTO `sys_refresh_token` VALUES (1, 1, 'fa148a69a0ac08d5280fb55714a1f12f48329aeb21831948541a04b36a5cd876', 'web', '2026-11-12 15:56:40.475', 1, '2026-11-05 15:56:40.475', '2026-11-05 16:07:54.007');
INSERT INTO `sys_refresh_token` VALUES (2, 1, '1a1079ac6d1bbbc7d4aba2b787a296ff057e1a6da980967a7e4def579d720064', 'web', '2026-11-12 16:07:57.960', 0, '2026-11-05 16:07:57.960', '2026-11-05 16:07:57.960');

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
INSERT INTO `sys_role` VALUES (1, 'ADMIN', '超级管理员', '系统最高权限，管理所有设备、用户及系统配置', 1, 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_role` VALUES (2, 'OPS', '运维人员', '负责设备管理、固件升级、告警处理，不可修改系统核心配置', 1, 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_role` VALUES (3, 'USER', '普通用户', '终端用户，只能查看和控制自己绑定的设备', 1, 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);

-- ----------------------------
-- Table structure for sys_role_info
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_info`;
CREATE TABLE `sys_role_info`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sys_user_role`(`user_id` ASC, `role_id` ASC) USING BTREE,
  INDEX `idx_sys_user_role_role`(`role_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户-角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_info
-- ----------------------------
INSERT INTO `sys_role_info` VALUES (1, 1, 1, '2026-11-05 15:56:34');

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
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色-权限关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_permission
-- ----------------------------
INSERT INTO `sys_role_permission` VALUES (1, 1, 1, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (2, 1, 2, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (3, 1, 3, '2026-11-05 16:02:06');
INSERT INTO `sys_role_permission` VALUES (4, 1, 4, '2026-11-05 16:02:35');
INSERT INTO `sys_role_permission` VALUES (5, 1, 5, '2026-11-05 16:02:41');
INSERT INTO `sys_role_permission` VALUES (6, 1, 6, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (7, 1, 7, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (8, 1, 8, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (9, 1, 9, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (10, 1, 10, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (11, 1, 11, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (12, 1, 12, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (13, 1, 13, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (14, 1, 14, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (15, 1, 15, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (16, 1, 16, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (17, 1, 17, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (18, 1, 18, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (19, 1, 19, '2026-10-27 15:09:44');
INSERT INTO `sys_role_permission` VALUES (20, 1, 20, '2026-10-27 15:12:10');
INSERT INTO `sys_role_permission` VALUES (21, 2, 1, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (22, 2, 2, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (23, 2, 3, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (24, 2, 4, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (25, 2, 5, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (26, 2, 6, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (27, 2, 7, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (28, 2, 8, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (29, 2, 9, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (30, 2, 10, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (31, 2, 11, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (32, 2, 12, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (33, 2, 13, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (34, 2, 14, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (35, 3, 1, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (36, 3, 2, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (37, 3, 6, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (38, 3, 7, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (39, 3, 8, '2026-10-26 16:03:52');

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
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1启用，0禁用',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否，1是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sys_user_username`(`username` ASC) USING BTREE,
  INDEX `idx_sys_user_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '$2a$12$rv4E/xFYLPv1rbjdaJ53X.xRMgk7owbS2cn745lB3yMBI1HyLvrYG', '管理员', '123@qq.com', '17788888888', NULL, 1, '2026-11-05 16:07:58', '2026-11-05 15:56:35', '2026-11-05 16:07:58', 0);

SET FOREIGN_KEY_CHECKS = 1;
