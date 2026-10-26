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

 Date: 26/10/2026 18:06:01
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
) ENGINE = InnoDB AUTO_INCREMENT = 1647 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '心跳记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_heartbeat_record
-- ----------------------------
INSERT INTO `device_heartbeat_record` VALUES (959, 'B4BFE90CDBA1', 30, '2026-10-21 11:54:30.558', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792554870312, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 30, \"rssi\": -65}}', '2026-10-21 11:54:30.561');
INSERT INTO `device_heartbeat_record` VALUES (960, 'B4BFE90CDBA1', 60, '2026-10-21 11:55:00.332', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792554900322, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 60, \"rssi\": -65}}', '2026-10-21 11:55:00.333');
INSERT INTO `device_heartbeat_record` VALUES (961, 'B4BFE90CDBA1', 90, '2026-10-21 11:55:30.342', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792554930331, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 90, \"rssi\": -65}}', '2026-10-21 11:55:30.343');
INSERT INTO `device_heartbeat_record` VALUES (962, 'B4BFE90CDBA1', 120, '2026-10-21 11:56:00.380', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792554960336, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 120, \"rssi\": -65}}', '2026-10-21 11:56:00.381');
INSERT INTO `device_heartbeat_record` VALUES (963, 'B4BFE90CDBA1', 150, '2026-10-21 11:56:30.357', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792554990344, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 150, \"rssi\": -65}}', '2026-10-21 11:56:30.358');
INSERT INTO `device_heartbeat_record` VALUES (964, 'B4BFE90CDBA1', 180, '2026-10-21 11:57:00.388', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555020349, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 180, \"rssi\": -65}}', '2026-10-21 11:57:00.389');
INSERT INTO `device_heartbeat_record` VALUES (965, 'B4BFE90CDBA1', 210, '2026-10-21 11:57:30.373', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555050361, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 210, \"rssi\": -65}}', '2026-10-21 11:57:30.374');
INSERT INTO `device_heartbeat_record` VALUES (966, 'B4BFE90CDBA1', 240, '2026-10-21 11:58:00.385', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555080376, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 240, \"rssi\": -65}}', '2026-10-21 11:58:00.385');
INSERT INTO `device_heartbeat_record` VALUES (967, 'B4BFE90CDBA1', 270, '2026-10-21 11:58:30.400', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555110390, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 270, \"rssi\": -65}}', '2026-10-21 11:58:30.402');
INSERT INTO `device_heartbeat_record` VALUES (968, 'B4BFE90CDBA1', 300, '2026-10-21 11:59:00.407', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555140392, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 300, \"rssi\": -65}}', '2026-10-21 11:59:00.408');
INSERT INTO `device_heartbeat_record` VALUES (969, 'B4BFE90CDBA1', 330, '2026-10-21 11:59:30.398', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555170393, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 330, \"rssi\": -65}}', '2026-10-21 11:59:30.398');
INSERT INTO `device_heartbeat_record` VALUES (970, 'B4BFE90CDBA1', 360, '2026-10-21 12:00:00.421', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555200406, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 360, \"rssi\": -65}}', '2026-10-21 12:00:00.422');
INSERT INTO `device_heartbeat_record` VALUES (971, 'B4BFE90CDBA1', 390, '2026-10-21 12:00:30.424', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555230409, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 390, \"rssi\": -65}}', '2026-10-21 12:00:30.424');
INSERT INTO `device_heartbeat_record` VALUES (972, 'B4BFE90CDBA1', 420, '2026-10-21 12:01:00.435', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555260421, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 420, \"rssi\": -65}}', '2026-10-21 12:01:00.436');
INSERT INTO `device_heartbeat_record` VALUES (973, 'B4BFE90CDBA1', 450, '2026-10-21 12:01:30.454', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555290436, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 450, \"rssi\": -65}}', '2026-10-21 12:01:30.454');
INSERT INTO `device_heartbeat_record` VALUES (974, 'B4BFE90CDBA1', 480, '2026-10-21 12:02:00.459', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555320447, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 480, \"rssi\": -65}}', '2026-10-21 12:02:00.459');
INSERT INTO `device_heartbeat_record` VALUES (975, 'B4BFE90CDBA1', 510, '2026-10-21 12:02:30.472', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555350459, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 510, \"rssi\": -65}}', '2026-10-21 12:02:30.472');
INSERT INTO `device_heartbeat_record` VALUES (976, 'B4BFE90CDBA1', 540, '2026-10-21 12:03:00.482', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555380471, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 540, \"rssi\": -65}}', '2026-10-21 12:03:00.482');
INSERT INTO `device_heartbeat_record` VALUES (977, 'B4BFE90CDBA1', 570, '2026-10-21 12:03:30.500', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555410481, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 570, \"rssi\": -65}}', '2026-10-21 12:03:30.501');
INSERT INTO `device_heartbeat_record` VALUES (978, 'B4BFE90CDBA1', 600, '2026-10-21 12:04:00.502', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555440488, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 600, \"rssi\": -65}}', '2026-10-21 12:04:00.502');
INSERT INTO `device_heartbeat_record` VALUES (979, 'B4BFE90CDBA1', 630, '2026-10-21 12:04:30.509', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555470496, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 630, \"rssi\": -65}}', '2026-10-21 12:04:30.510');
INSERT INTO `device_heartbeat_record` VALUES (980, 'B4BFE90CDBA1', 660, '2026-10-21 12:05:00.514', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555500498, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 660, \"rssi\": -65}}', '2026-10-21 12:05:00.514');
INSERT INTO `device_heartbeat_record` VALUES (981, 'B4BFE90CDBA1', 690, '2026-10-21 12:05:30.521', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555530509, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 690, \"rssi\": -65}}', '2026-10-21 12:05:30.522');
INSERT INTO `device_heartbeat_record` VALUES (982, 'B4BFE90CDBA1', 720, '2026-10-21 12:06:00.528', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555560518, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 720, \"rssi\": -65}}', '2026-10-21 12:06:00.529');
INSERT INTO `device_heartbeat_record` VALUES (983, 'B4BFE90CDBA1', 750, '2026-10-21 12:06:30.540', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555590532, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 750, \"rssi\": -65}}', '2026-10-21 12:06:30.540');
INSERT INTO `device_heartbeat_record` VALUES (984, 'B4BFE90CDBA1', 780, '2026-10-21 12:07:00.547', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555620536, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 780, \"rssi\": -65}}', '2026-10-21 12:07:00.548');
INSERT INTO `device_heartbeat_record` VALUES (985, 'B4BFE90CDBA1', 810, '2026-10-21 12:07:30.562', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555650547, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 810, \"rssi\": -65}}', '2026-10-21 12:07:30.563');
INSERT INTO `device_heartbeat_record` VALUES (986, 'B4BFE90CDBA1', 840, '2026-10-21 12:08:00.568', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555680558, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 840, \"rssi\": -65}}', '2026-10-21 12:08:00.568');
INSERT INTO `device_heartbeat_record` VALUES (987, 'B4BFE90CDBA1', 870, '2026-10-21 12:08:30.581', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555710571, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 870, \"rssi\": -65}}', '2026-10-21 12:08:30.581');
INSERT INTO `device_heartbeat_record` VALUES (988, 'B4BFE90CDBA1', 900, '2026-10-21 12:09:00.596', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555740586, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 900, \"rssi\": -65}}', '2026-10-21 12:09:00.596');
INSERT INTO `device_heartbeat_record` VALUES (989, 'B4BFE90CDBA1', 930, '2026-10-21 12:09:30.611', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555770600, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 930, \"rssi\": -65}}', '2026-10-21 12:09:30.611');
INSERT INTO `device_heartbeat_record` VALUES (990, 'B4BFE90CDBA1', 960, '2026-10-21 12:10:00.616', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555800604, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 960, \"rssi\": -65}}', '2026-10-21 12:10:00.617');
INSERT INTO `device_heartbeat_record` VALUES (991, 'B4BFE90CDBA1', 990, '2026-10-21 12:10:30.633', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555830620, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 990, \"rssi\": -65}}', '2026-10-21 12:10:30.633');
INSERT INTO `device_heartbeat_record` VALUES (992, 'B4BFE90CDBA1', 1020, '2026-10-21 12:11:00.648', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555860635, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1020, \"rssi\": -65}}', '2026-10-21 12:11:00.648');
INSERT INTO `device_heartbeat_record` VALUES (993, 'B4BFE90CDBA1', 1050, '2026-10-21 12:11:30.661', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555890651, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1050, \"rssi\": -65}}', '2026-10-21 12:11:30.662');
INSERT INTO `device_heartbeat_record` VALUES (994, 'B4BFE90CDBA1', 1080, '2026-10-21 12:12:00.666', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555920657, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1080, \"rssi\": -65}}', '2026-10-21 12:12:00.666');
INSERT INTO `device_heartbeat_record` VALUES (995, 'B4BFE90CDBA1', 1110, '2026-10-21 12:12:30.677', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555950664, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1110, \"rssi\": -65}}', '2026-10-21 12:12:30.677');
INSERT INTO `device_heartbeat_record` VALUES (996, 'B4BFE90CDBA1', 1140, '2026-10-21 12:13:00.690', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792555980673, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1140, \"rssi\": -65}}', '2026-10-21 12:13:00.692');
INSERT INTO `device_heartbeat_record` VALUES (997, 'B4BFE90CDBA1', 1170, '2026-10-21 12:13:30.693', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556010679, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1170, \"rssi\": -65}}', '2026-10-21 12:13:30.694');
INSERT INTO `device_heartbeat_record` VALUES (998, 'B4BFE90CDBA1', 1200, '2026-10-21 12:14:00.689', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556040680, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1200, \"rssi\": -65}}', '2026-10-21 12:14:00.689');
INSERT INTO `device_heartbeat_record` VALUES (999, 'B4BFE90CDBA1', 1230, '2026-10-21 12:14:30.694', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556070687, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1230, \"rssi\": -65}}', '2026-10-21 12:14:30.694');
INSERT INTO `device_heartbeat_record` VALUES (1000, 'B4BFE90CDBA1', 1260, '2026-10-21 12:15:00.703', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556100695, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1260, \"rssi\": -65}}', '2026-10-21 12:15:00.703');
INSERT INTO `device_heartbeat_record` VALUES (1001, 'B4BFE90CDBA1', 1290, '2026-10-21 12:15:30.706', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556130697, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1290, \"rssi\": -65}}', '2026-10-21 12:15:30.709');
INSERT INTO `device_heartbeat_record` VALUES (1002, 'B4BFE90CDBA1', 1320, '2026-10-21 12:16:00.705', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556160698, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1320, \"rssi\": -65}}', '2026-10-21 12:16:00.705');
INSERT INTO `device_heartbeat_record` VALUES (1003, 'B4BFE90CDBA1', 1350, '2026-10-21 12:16:30.706', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556190701, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1350, \"rssi\": -65}}', '2026-10-21 12:16:30.706');
INSERT INTO `device_heartbeat_record` VALUES (1004, 'B4BFE90CDBA1', 1380, '2026-10-21 12:17:00.720', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556220710, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1380, \"rssi\": -65}}', '2026-10-21 12:17:00.721');
INSERT INTO `device_heartbeat_record` VALUES (1005, 'B4BFE90CDBA1', 1410, '2026-10-21 12:17:30.721', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556250713, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1410, \"rssi\": -65}}', '2026-10-21 12:17:30.721');
INSERT INTO `device_heartbeat_record` VALUES (1006, 'B4BFE90CDBA1', 1440, '2026-10-21 12:18:00.734', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556280726, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1440, \"rssi\": -65}}', '2026-10-21 12:18:00.734');
INSERT INTO `device_heartbeat_record` VALUES (1007, 'B4BFE90CDBA1', 1470, '2026-10-21 12:18:30.733', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556310728, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1470, \"rssi\": -65}}', '2026-10-21 12:18:30.733');
INSERT INTO `device_heartbeat_record` VALUES (1008, 'B4BFE90CDBA1', 1500, '2026-10-21 12:19:00.748', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556340736, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1500, \"rssi\": -65}}', '2026-10-21 12:19:00.748');
INSERT INTO `device_heartbeat_record` VALUES (1009, 'B4BFE90CDBA1', 1530, '2026-10-21 12:19:30.749', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556370739, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1530, \"rssi\": -65}}', '2026-10-21 12:19:30.749');
INSERT INTO `device_heartbeat_record` VALUES (1010, 'B4BFE90CDBA1', 1560, '2026-10-21 12:20:00.754', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556400742, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1560, \"rssi\": -65}}', '2026-10-21 12:20:00.755');
INSERT INTO `device_heartbeat_record` VALUES (1011, 'B4BFE90CDBA1', 1590, '2026-10-21 12:20:30.765', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556430755, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1590, \"rssi\": -65}}', '2026-10-21 12:20:30.765');
INSERT INTO `device_heartbeat_record` VALUES (1012, 'B4BFE90CDBA1', 1620, '2026-10-21 12:21:00.778', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556460767, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1620, \"rssi\": -65}}', '2026-10-21 12:21:00.778');
INSERT INTO `device_heartbeat_record` VALUES (1013, 'B4BFE90CDBA1', 1650, '2026-10-21 12:21:30.781', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556490773, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1650, \"rssi\": -65}}', '2026-10-21 12:21:30.782');
INSERT INTO `device_heartbeat_record` VALUES (1014, 'B4BFE90CDBA1', 1680, '2026-10-21 12:22:00.797', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556520781, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1680, \"rssi\": -65}}', '2026-10-21 12:22:00.798');
INSERT INTO `device_heartbeat_record` VALUES (1015, 'B4BFE90CDBA1', 1710, '2026-10-21 12:22:30.802', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556550791, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1710, \"rssi\": -65}}', '2026-10-21 12:22:30.803');
INSERT INTO `device_heartbeat_record` VALUES (1016, 'B4BFE90CDBA1', 1740, '2026-10-21 12:23:00.818', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556580803, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1740, \"rssi\": -65}}', '2026-10-21 12:23:00.818');
INSERT INTO `device_heartbeat_record` VALUES (1017, 'B4BFE90CDBA1', 1770, '2026-10-21 12:23:30.831', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556610819, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1770, \"rssi\": -65}}', '2026-10-21 12:23:30.832');
INSERT INTO `device_heartbeat_record` VALUES (1018, 'B4BFE90CDBA1', 1800, '2026-10-21 12:24:00.837', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556640821, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1800, \"rssi\": -65}}', '2026-10-21 12:24:00.838');
INSERT INTO `device_heartbeat_record` VALUES (1019, 'B4BFE90CDBA1', 1830, '2026-10-21 12:24:30.841', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556670830, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1830, \"rssi\": -65}}', '2026-10-21 12:24:30.841');
INSERT INTO `device_heartbeat_record` VALUES (1020, 'B4BFE90CDBA1', 1860, '2026-10-21 12:25:00.848', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556700838, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1860, \"rssi\": -65}}', '2026-10-21 12:25:00.848');
INSERT INTO `device_heartbeat_record` VALUES (1021, 'B4BFE90CDBA1', 1890, '2026-10-21 12:25:30.856', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556730845, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1890, \"rssi\": -65}}', '2026-10-21 12:25:30.856');
INSERT INTO `device_heartbeat_record` VALUES (1022, 'B4BFE90CDBA1', 1920, '2026-10-21 12:26:00.865', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556760852, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1920, \"rssi\": -65}}', '2026-10-21 12:26:00.867');
INSERT INTO `device_heartbeat_record` VALUES (1023, 'B4BFE90CDBA1', 1950, '2026-10-21 12:26:30.875', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556790863, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1950, \"rssi\": -65}}', '2026-10-21 12:26:30.876');
INSERT INTO `device_heartbeat_record` VALUES (1024, 'B4BFE90CDBA1', 1980, '2026-10-21 12:27:00.880', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556820872, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1980, \"rssi\": -65}}', '2026-10-21 12:27:00.880');
INSERT INTO `device_heartbeat_record` VALUES (1025, 'B4BFE90CDBA1', 2010, '2026-10-21 12:27:30.885', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556850874, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2010, \"rssi\": -65}}', '2026-10-21 12:27:30.885');
INSERT INTO `device_heartbeat_record` VALUES (1026, 'B4BFE90CDBA1', 2040, '2026-10-21 12:28:00.901', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556880882, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2040, \"rssi\": -65}}', '2026-10-21 12:28:00.901');
INSERT INTO `device_heartbeat_record` VALUES (1027, 'B4BFE90CDBA1', 2070, '2026-10-21 12:28:30.907', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556910893, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2070, \"rssi\": -65}}', '2026-10-21 12:28:30.907');
INSERT INTO `device_heartbeat_record` VALUES (1028, 'B4BFE90CDBA1', 2100, '2026-10-21 12:29:00.920', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556940906, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2100, \"rssi\": -65}}', '2026-10-21 12:29:00.921');
INSERT INTO `device_heartbeat_record` VALUES (1029, 'B4BFE90CDBA1', 2130, '2026-10-21 12:29:30.923', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792556970911, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2130, \"rssi\": -65}}', '2026-10-21 12:29:30.923');
INSERT INTO `device_heartbeat_record` VALUES (1030, 'B4BFE90CDBA1', 2160, '2026-10-21 12:30:00.942', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557000927, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2160, \"rssi\": -65}}', '2026-10-21 12:30:00.943');
INSERT INTO `device_heartbeat_record` VALUES (1031, 'B4BFE90CDBA1', 2190, '2026-10-21 12:30:30.959', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557030942, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2190, \"rssi\": -65}}', '2026-10-21 12:30:30.960');
INSERT INTO `device_heartbeat_record` VALUES (1032, 'B4BFE90CDBA1', 2220, '2026-10-21 12:31:00.972', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557060958, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2220, \"rssi\": -65}}', '2026-10-21 12:31:00.972');
INSERT INTO `device_heartbeat_record` VALUES (1033, 'B4BFE90CDBA1', 2250, '2026-10-21 12:31:30.967', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557090959, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2250, \"rssi\": -65}}', '2026-10-21 12:31:30.967');
INSERT INTO `device_heartbeat_record` VALUES (1034, 'B4BFE90CDBA1', 2280, '2026-10-21 12:32:00.968', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557120962, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2280, \"rssi\": -65}}', '2026-10-21 12:32:00.968');
INSERT INTO `device_heartbeat_record` VALUES (1035, 'B4BFE90CDBA1', 2310, '2026-10-21 12:32:31.014', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557150973, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2310, \"rssi\": -65}}', '2026-10-21 12:32:31.014');
INSERT INTO `device_heartbeat_record` VALUES (1036, 'B4BFE90CDBA1', 2340, '2026-10-21 12:33:00.998', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557180986, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2340, \"rssi\": -65}}', '2026-10-21 12:33:00.999');
INSERT INTO `device_heartbeat_record` VALUES (1037, 'B4BFE90CDBA1', 2370, '2026-10-21 12:33:31.002', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557210988, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2370, \"rssi\": -65}}', '2026-10-21 12:33:31.002');
INSERT INTO `device_heartbeat_record` VALUES (1038, 'B4BFE90CDBA1', 2400, '2026-10-21 12:34:01.007', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557240992, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2400, \"rssi\": -65}}', '2026-10-21 12:34:01.007');
INSERT INTO `device_heartbeat_record` VALUES (1039, 'B4BFE90CDBA1', 2430, '2026-10-21 12:34:31.019', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557271006, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2430, \"rssi\": -65}}', '2026-10-21 12:34:31.019');
INSERT INTO `device_heartbeat_record` VALUES (1040, 'B4BFE90CDBA1', 2460, '2026-10-21 12:35:01.026', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557301014, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2460, \"rssi\": -65}}', '2026-10-21 12:35:01.026');
INSERT INTO `device_heartbeat_record` VALUES (1041, 'B4BFE90CDBA1', 2490, '2026-10-21 12:35:31.034', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557331023, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2490, \"rssi\": -65}}', '2026-10-21 12:35:31.035');
INSERT INTO `device_heartbeat_record` VALUES (1042, 'B4BFE90CDBA1', 2520, '2026-10-21 12:36:01.057', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557361034, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2520, \"rssi\": -65}}', '2026-10-21 12:36:01.057');
INSERT INTO `device_heartbeat_record` VALUES (1043, 'B4BFE90CDBA1', 2550, '2026-10-21 12:36:31.069', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557391056, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2550, \"rssi\": -65}}', '2026-10-21 12:36:31.069');
INSERT INTO `device_heartbeat_record` VALUES (1044, 'B4BFE90CDBA1', 2580, '2026-10-21 12:37:01.080', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557421064, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2580, \"rssi\": -65}}', '2026-10-21 12:37:01.081');
INSERT INTO `device_heartbeat_record` VALUES (1045, 'B4BFE90CDBA1', 2610, '2026-10-21 12:37:31.093', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557451080, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2610, \"rssi\": -65}}', '2026-10-21 12:37:31.093');
INSERT INTO `device_heartbeat_record` VALUES (1046, 'B4BFE90CDBA1', 2640, '2026-10-21 12:38:01.112', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557481093, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2640, \"rssi\": -65}}', '2026-10-21 12:38:01.112');
INSERT INTO `device_heartbeat_record` VALUES (1047, 'B4BFE90CDBA1', 2670, '2026-10-21 12:38:31.112', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557511105, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2670, \"rssi\": -65}}', '2026-10-21 12:38:31.112');
INSERT INTO `device_heartbeat_record` VALUES (1048, 'B4BFE90CDBA1', 2700, '2026-10-21 12:39:01.124', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557541117, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2700, \"rssi\": -65}}', '2026-10-21 12:39:01.124');
INSERT INTO `device_heartbeat_record` VALUES (1049, 'B4BFE90CDBA1', 2730, '2026-10-21 12:39:31.134', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557571120, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2730, \"rssi\": -65}}', '2026-10-21 12:39:31.135');
INSERT INTO `device_heartbeat_record` VALUES (1050, 'B4BFE90CDBA1', 2760, '2026-10-21 12:40:01.144', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557601130, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2760, \"rssi\": -65}}', '2026-10-21 12:40:01.145');
INSERT INTO `device_heartbeat_record` VALUES (1051, 'B4BFE90CDBA1', 2790, '2026-10-21 12:40:31.156', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557631143, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2790, \"rssi\": -65}}', '2026-10-21 12:40:31.156');
INSERT INTO `device_heartbeat_record` VALUES (1052, 'B4BFE90CDBA1', 2820, '2026-10-21 12:41:01.159', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557661144, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2820, \"rssi\": -65}}', '2026-10-21 12:41:01.160');
INSERT INTO `device_heartbeat_record` VALUES (1053, 'B4BFE90CDBA1', 2850, '2026-10-21 12:41:31.166', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557691156, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2850, \"rssi\": -65}}', '2026-10-21 12:41:31.166');
INSERT INTO `device_heartbeat_record` VALUES (1054, 'B4BFE90CDBA1', 2880, '2026-10-21 12:42:01.184', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557721170, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2880, \"rssi\": -65}}', '2026-10-21 12:42:01.184');
INSERT INTO `device_heartbeat_record` VALUES (1055, 'B4BFE90CDBA1', 2910, '2026-10-21 12:42:31.195', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557751180, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2910, \"rssi\": -65}}', '2026-10-21 12:42:31.195');
INSERT INTO `device_heartbeat_record` VALUES (1056, 'B4BFE90CDBA1', 2940, '2026-10-21 12:43:01.205', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557781193, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2940, \"rssi\": -65}}', '2026-10-21 12:43:01.205');
INSERT INTO `device_heartbeat_record` VALUES (1057, 'B4BFE90CDBA1', 2970, '2026-10-21 12:43:31.217', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557811203, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2970, \"rssi\": -65}}', '2026-10-21 12:43:31.217');
INSERT INTO `device_heartbeat_record` VALUES (1058, 'B4BFE90CDBA1', 3000, '2026-10-21 12:44:01.216', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557841210, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3000, \"rssi\": -65}}', '2026-10-21 12:44:01.217');
INSERT INTO `device_heartbeat_record` VALUES (1059, 'B4BFE90CDBA1', 3030, '2026-10-21 12:44:31.223', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557871211, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3030, \"rssi\": -65}}', '2026-10-21 12:44:31.223');
INSERT INTO `device_heartbeat_record` VALUES (1060, 'B4BFE90CDBA1', 3060, '2026-10-21 12:45:01.232', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557901223, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3060, \"rssi\": -65}}', '2026-10-21 12:45:01.232');
INSERT INTO `device_heartbeat_record` VALUES (1061, 'B4BFE90CDBA1', 3090, '2026-10-21 12:45:31.246', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557931235, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3090, \"rssi\": -65}}', '2026-10-21 12:45:31.246');
INSERT INTO `device_heartbeat_record` VALUES (1062, 'B4BFE90CDBA1', 3120, '2026-10-21 12:46:01.265', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557961250, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3120, \"rssi\": -65}}', '2026-10-21 12:46:01.266');
INSERT INTO `device_heartbeat_record` VALUES (1063, 'B4BFE90CDBA1', 3150, '2026-10-21 12:46:31.266', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792557991253, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3150, \"rssi\": -65}}', '2026-10-21 12:46:31.266');
INSERT INTO `device_heartbeat_record` VALUES (1064, 'B4BFE90CDBA1', 3180, '2026-10-21 12:47:01.298', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558021267, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3180, \"rssi\": -65}}', '2026-10-21 12:47:01.298');
INSERT INTO `device_heartbeat_record` VALUES (1065, 'B4BFE90CDBA1', 3210, '2026-10-21 12:47:31.287', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558051271, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3210, \"rssi\": -65}}', '2026-10-21 12:47:31.289');
INSERT INTO `device_heartbeat_record` VALUES (1066, 'B4BFE90CDBA1', 3240, '2026-10-21 12:48:01.291', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558081284, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3240, \"rssi\": -65}}', '2026-10-21 12:48:01.291');
INSERT INTO `device_heartbeat_record` VALUES (1067, 'B4BFE90CDBA1', 3270, '2026-10-21 12:48:31.308', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558111294, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3270, \"rssi\": -65}}', '2026-10-21 12:48:31.309');
INSERT INTO `device_heartbeat_record` VALUES (1068, 'B4BFE90CDBA1', 3300, '2026-10-21 12:49:01.309', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558141300, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3300, \"rssi\": -65}}', '2026-10-21 12:49:01.309');
INSERT INTO `device_heartbeat_record` VALUES (1069, 'B4BFE90CDBA1', 3330, '2026-10-21 12:49:31.322', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558171308, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3330, \"rssi\": -65}}', '2026-10-21 12:49:31.323');
INSERT INTO `device_heartbeat_record` VALUES (1070, 'B4BFE90CDBA1', 3360, '2026-10-21 12:50:01.332', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558201319, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3360, \"rssi\": -65}}', '2026-10-21 12:50:01.333');
INSERT INTO `device_heartbeat_record` VALUES (1071, 'B4BFE90CDBA1', 3390, '2026-10-21 12:50:31.344', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558231330, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3390, \"rssi\": -65}}', '2026-10-21 12:50:31.344');
INSERT INTO `device_heartbeat_record` VALUES (1072, 'B4BFE90CDBA1', 3420, '2026-10-21 12:51:01.355', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558261343, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3420, \"rssi\": -65}}', '2026-10-21 12:51:01.355');
INSERT INTO `device_heartbeat_record` VALUES (1073, 'B4BFE90CDBA1', 3450, '2026-10-21 12:51:31.362', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558291352, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3450, \"rssi\": -65}}', '2026-10-21 12:51:31.362');
INSERT INTO `device_heartbeat_record` VALUES (1074, 'B4BFE90CDBA1', 3480, '2026-10-21 12:52:01.376', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558321362, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3480, \"rssi\": -65}}', '2026-10-21 12:52:01.377');
INSERT INTO `device_heartbeat_record` VALUES (1075, 'B4BFE90CDBA1', 3510, '2026-10-21 12:52:31.387', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558351374, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3510, \"rssi\": -65}}', '2026-10-21 12:52:31.387');
INSERT INTO `device_heartbeat_record` VALUES (1076, 'B4BFE90CDBA1', 3540, '2026-10-21 12:53:01.400', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558381386, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3540, \"rssi\": -65}}', '2026-10-21 12:53:01.400');
INSERT INTO `device_heartbeat_record` VALUES (1077, 'B4BFE90CDBA1', 3570, '2026-10-21 12:53:31.406', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558411393, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3570, \"rssi\": -65}}', '2026-10-21 12:53:31.406');
INSERT INTO `device_heartbeat_record` VALUES (1078, 'B4BFE90CDBA1', 3600, '2026-10-21 12:54:01.408', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558441396, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3600, \"rssi\": -65}}', '2026-10-21 12:54:01.410');
INSERT INTO `device_heartbeat_record` VALUES (1079, 'B4BFE90CDBA1', 3630, '2026-10-21 12:54:31.414', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558471402, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3630, \"rssi\": -65}}', '2026-10-21 12:54:31.415');
INSERT INTO `device_heartbeat_record` VALUES (1080, 'B4BFE90CDBA1', 3660, '2026-10-21 12:55:01.424', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558501411, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3660, \"rssi\": -65}}', '2026-10-21 12:55:01.425');
INSERT INTO `device_heartbeat_record` VALUES (1081, 'B4BFE90CDBA1', 3690, '2026-10-21 12:55:31.432', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558531419, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3690, \"rssi\": -65}}', '2026-10-21 12:55:31.432');
INSERT INTO `device_heartbeat_record` VALUES (1082, 'B4BFE90CDBA1', 3720, '2026-10-21 12:56:01.448', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558561435, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3720, \"rssi\": -65}}', '2026-10-21 12:56:01.448');
INSERT INTO `device_heartbeat_record` VALUES (1083, 'B4BFE90CDBA1', 3750, '2026-10-21 12:56:31.461', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558591446, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3750, \"rssi\": -65}}', '2026-10-21 12:56:31.462');
INSERT INTO `device_heartbeat_record` VALUES (1084, 'B4BFE90CDBA1', 3780, '2026-10-21 12:57:01.466', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558621452, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3780, \"rssi\": -65}}', '2026-10-21 12:57:01.466');
INSERT INTO `device_heartbeat_record` VALUES (1085, 'B4BFE90CDBA1', 3810, '2026-10-21 12:57:31.480', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558651459, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3810, \"rssi\": -65}}', '2026-10-21 12:57:31.481');
INSERT INTO `device_heartbeat_record` VALUES (1086, 'B4BFE90CDBA1', 3840, '2026-10-21 12:58:01.479', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558681462, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3840, \"rssi\": -65}}', '2026-10-21 12:58:01.481');
INSERT INTO `device_heartbeat_record` VALUES (1087, 'B4BFE90CDBA1', 3870, '2026-10-21 12:58:31.481', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558711471, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3870, \"rssi\": -65}}', '2026-10-21 12:58:31.482');
INSERT INTO `device_heartbeat_record` VALUES (1088, 'B4BFE90CDBA1', 3900, '2026-10-21 12:59:01.486', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558741478, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3900, \"rssi\": -65}}', '2026-10-21 12:59:01.487');
INSERT INTO `device_heartbeat_record` VALUES (1089, 'B4BFE90CDBA1', 3930, '2026-10-21 12:59:31.507', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558771494, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3930, \"rssi\": -65}}', '2026-10-21 12:59:31.507');
INSERT INTO `device_heartbeat_record` VALUES (1090, 'B4BFE90CDBA1', 3960, '2026-10-21 13:00:01.518', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558801506, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3960, \"rssi\": -65}}', '2026-10-21 13:00:01.518');
INSERT INTO `device_heartbeat_record` VALUES (1091, 'B4BFE90CDBA1', 3990, '2026-10-21 13:00:31.524', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558831514, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3990, \"rssi\": -65}}', '2026-10-21 13:00:31.525');
INSERT INTO `device_heartbeat_record` VALUES (1092, 'B4BFE90CDBA1', 4020, '2026-10-21 13:01:01.535', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558861524, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4020, \"rssi\": -65}}', '2026-10-21 13:01:01.536');
INSERT INTO `device_heartbeat_record` VALUES (1093, 'B4BFE90CDBA1', 4050, '2026-10-21 13:01:31.551', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558891540, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4050, \"rssi\": -65}}', '2026-10-21 13:01:31.551');
INSERT INTO `device_heartbeat_record` VALUES (1094, 'B4BFE90CDBA1', 4080, '2026-10-21 13:02:01.558', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558921545, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4080, \"rssi\": -65}}', '2026-10-21 13:02:01.558');
INSERT INTO `device_heartbeat_record` VALUES (1095, 'B4BFE90CDBA1', 4110, '2026-10-21 13:02:31.562', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558951547, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4110, \"rssi\": -65}}', '2026-10-21 13:02:31.562');
INSERT INTO `device_heartbeat_record` VALUES (1096, 'B4BFE90CDBA1', 4140, '2026-10-21 13:03:01.570', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792558981557, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4140, \"rssi\": -65}}', '2026-10-21 13:03:01.571');
INSERT INTO `device_heartbeat_record` VALUES (1097, 'B4BFE90CDBA1', 4170, '2026-10-21 13:03:31.574', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559011561, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4170, \"rssi\": -65}}', '2026-10-21 13:03:31.575');
INSERT INTO `device_heartbeat_record` VALUES (1098, 'B4BFE90CDBA1', 4200, '2026-10-21 13:04:01.573', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559041563, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4200, \"rssi\": -65}}', '2026-10-21 13:04:01.573');
INSERT INTO `device_heartbeat_record` VALUES (1099, 'B4BFE90CDBA1', 4230, '2026-10-21 13:04:31.585', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559071574, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4230, \"rssi\": -65}}', '2026-10-21 13:04:31.585');
INSERT INTO `device_heartbeat_record` VALUES (1100, 'B4BFE90CDBA1', 4260, '2026-10-21 13:05:01.590', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559101580, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4260, \"rssi\": -65}}', '2026-10-21 13:05:01.590');
INSERT INTO `device_heartbeat_record` VALUES (1101, 'B4BFE90CDBA1', 4290, '2026-10-21 13:05:31.606', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559131596, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4290, \"rssi\": -65}}', '2026-10-21 13:05:31.606');
INSERT INTO `device_heartbeat_record` VALUES (1102, 'B4BFE90CDBA1', 4320, '2026-10-21 13:06:01.619', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559161607, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4320, \"rssi\": -65}}', '2026-10-21 13:06:01.620');
INSERT INTO `device_heartbeat_record` VALUES (1103, 'B4BFE90CDBA1', 4350, '2026-10-21 13:06:31.623', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559191612, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4350, \"rssi\": -65}}', '2026-10-21 13:06:31.623');
INSERT INTO `device_heartbeat_record` VALUES (1104, 'B4BFE90CDBA1', 4380, '2026-10-21 13:07:01.639', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559221626, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4380, \"rssi\": -65}}', '2026-10-21 13:07:01.639');
INSERT INTO `device_heartbeat_record` VALUES (1105, 'B4BFE90CDBA1', 4410, '2026-10-21 13:07:31.640', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559251636, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4410, \"rssi\": -65}}', '2026-10-21 13:07:31.640');
INSERT INTO `device_heartbeat_record` VALUES (1106, 'B4BFE90CDBA1', 4440, '2026-10-21 13:08:01.687', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559281648, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4440, \"rssi\": -65}}', '2026-10-21 13:08:01.688');
INSERT INTO `device_heartbeat_record` VALUES (1107, 'B4BFE90CDBA1', 4470, '2026-10-21 13:08:31.677', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559311663, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4470, \"rssi\": -65}}', '2026-10-21 13:08:31.677');
INSERT INTO `device_heartbeat_record` VALUES (1108, 'B4BFE90CDBA1', 4500, '2026-10-21 13:09:01.687', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559341676, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4500, \"rssi\": -65}}', '2026-10-21 13:09:01.687');
INSERT INTO `device_heartbeat_record` VALUES (1109, 'B4BFE90CDBA1', 4530, '2026-10-21 13:09:31.695', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559371685, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4530, \"rssi\": -65}}', '2026-10-21 13:09:31.695');
INSERT INTO `device_heartbeat_record` VALUES (1110, 'B4BFE90CDBA1', 4560, '2026-10-21 13:10:01.706', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559401694, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4560, \"rssi\": -65}}', '2026-10-21 13:10:01.706');
INSERT INTO `device_heartbeat_record` VALUES (1111, 'B4BFE90CDBA1', 4590, '2026-10-21 13:10:31.717', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559431706, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4590, \"rssi\": -65}}', '2026-10-21 13:10:31.717');
INSERT INTO `device_heartbeat_record` VALUES (1112, 'B4BFE90CDBA1', 4620, '2026-10-21 13:11:01.726', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559461714, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4620, \"rssi\": -65}}', '2026-10-21 13:11:01.726');
INSERT INTO `device_heartbeat_record` VALUES (1113, 'B4BFE90CDBA1', 4650, '2026-10-21 13:11:31.739', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559491729, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4650, \"rssi\": -65}}', '2026-10-21 13:11:31.739');
INSERT INTO `device_heartbeat_record` VALUES (1114, 'B4BFE90CDBA1', 4680, '2026-10-21 13:12:01.742', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559521731, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4680, \"rssi\": -65}}', '2026-10-21 13:12:01.742');
INSERT INTO `device_heartbeat_record` VALUES (1115, 'B4BFE90CDBA1', 4710, '2026-10-21 13:12:31.758', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559551746, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4710, \"rssi\": -65}}', '2026-10-21 13:12:31.759');
INSERT INTO `device_heartbeat_record` VALUES (1116, 'B4BFE90CDBA1', 4740, '2026-10-21 13:13:01.765', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559581760, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4740, \"rssi\": -65}}', '2026-10-21 13:13:01.765');
INSERT INTO `device_heartbeat_record` VALUES (1117, 'B4BFE90CDBA1', 4770, '2026-10-21 13:13:31.775', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559611764, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4770, \"rssi\": -65}}', '2026-10-21 13:13:31.775');
INSERT INTO `device_heartbeat_record` VALUES (1118, 'B4BFE90CDBA1', 4800, '2026-10-21 13:14:01.788', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559641775, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4800, \"rssi\": -65}}', '2026-10-21 13:14:01.788');
INSERT INTO `device_heartbeat_record` VALUES (1119, 'B4BFE90CDBA1', 4830, '2026-10-21 13:14:31.798', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559671786, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4830, \"rssi\": -65}}', '2026-10-21 13:14:31.799');
INSERT INTO `device_heartbeat_record` VALUES (1120, 'B4BFE90CDBA1', 4860, '2026-10-21 13:15:01.799', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559701789, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4860, \"rssi\": -65}}', '2026-10-21 13:15:01.799');
INSERT INTO `device_heartbeat_record` VALUES (1121, 'B4BFE90CDBA1', 4890, '2026-10-21 13:15:31.812', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559731801, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4890, \"rssi\": -65}}', '2026-10-21 13:15:31.812');
INSERT INTO `device_heartbeat_record` VALUES (1122, 'B4BFE90CDBA1', 4920, '2026-10-21 13:16:01.820', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559761805, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4920, \"rssi\": -65}}', '2026-10-21 13:16:01.821');
INSERT INTO `device_heartbeat_record` VALUES (1123, 'B4BFE90CDBA1', 4950, '2026-10-21 13:16:31.821', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559791809, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4950, \"rssi\": -65}}', '2026-10-21 13:16:31.821');
INSERT INTO `device_heartbeat_record` VALUES (1124, 'B4BFE90CDBA1', 4980, '2026-10-21 13:17:01.827', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559821813, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4980, \"rssi\": -65}}', '2026-10-21 13:17:01.827');
INSERT INTO `device_heartbeat_record` VALUES (1125, 'B4BFE90CDBA1', 5010, '2026-10-21 13:17:31.833', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559851823, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5010, \"rssi\": -65}}', '2026-10-21 13:17:31.833');
INSERT INTO `device_heartbeat_record` VALUES (1126, 'B4BFE90CDBA1', 5040, '2026-10-21 13:18:01.851', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559881839, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5040, \"rssi\": -65}}', '2026-10-21 13:18:01.851');
INSERT INTO `device_heartbeat_record` VALUES (1127, 'B4BFE90CDBA1', 5070, '2026-10-21 13:18:31.859', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559911847, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5070, \"rssi\": -65}}', '2026-10-21 13:18:31.860');
INSERT INTO `device_heartbeat_record` VALUES (1128, 'B4BFE90CDBA1', 5100, '2026-10-21 13:19:01.871', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559941862, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5100, \"rssi\": -65}}', '2026-10-21 13:19:01.871');
INSERT INTO `device_heartbeat_record` VALUES (1129, 'B4BFE90CDBA1', 5130, '2026-10-21 13:19:31.882', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792559971869, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5130, \"rssi\": -65}}', '2026-10-21 13:19:31.883');
INSERT INTO `device_heartbeat_record` VALUES (1130, 'B4BFE90CDBA1', 5160, '2026-10-21 13:20:01.887', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560001875, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5160, \"rssi\": -65}}', '2026-10-21 13:20:01.887');
INSERT INTO `device_heartbeat_record` VALUES (1131, 'B4BFE90CDBA1', 5190, '2026-10-21 13:20:31.893', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560031881, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5190, \"rssi\": -65}}', '2026-10-21 13:20:31.894');
INSERT INTO `device_heartbeat_record` VALUES (1132, 'B4BFE90CDBA1', 5220, '2026-10-21 13:21:01.908', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560061895, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5220, \"rssi\": -65}}', '2026-10-21 13:21:01.910');
INSERT INTO `device_heartbeat_record` VALUES (1133, 'B4BFE90CDBA1', 5250, '2026-10-21 13:21:31.907', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560091899, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5250, \"rssi\": -65}}', '2026-10-21 13:21:31.907');
INSERT INTO `device_heartbeat_record` VALUES (1134, 'B4BFE90CDBA1', 5280, '2026-10-21 13:22:01.920', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560121909, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5280, \"rssi\": -65}}', '2026-10-21 13:22:01.920');
INSERT INTO `device_heartbeat_record` VALUES (1135, 'B4BFE90CDBA1', 5310, '2026-10-21 13:22:31.923', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560151913, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5310, \"rssi\": -65}}', '2026-10-21 13:22:31.924');
INSERT INTO `device_heartbeat_record` VALUES (1136, 'B4BFE90CDBA1', 5340, '2026-10-21 13:23:01.943', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560181927, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5340, \"rssi\": -65}}', '2026-10-21 13:23:01.944');
INSERT INTO `device_heartbeat_record` VALUES (1137, 'B4BFE90CDBA1', 5370, '2026-10-21 13:23:31.946', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560211932, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5370, \"rssi\": -65}}', '2026-10-21 13:23:31.946');
INSERT INTO `device_heartbeat_record` VALUES (1138, 'B4BFE90CDBA1', 5400, '2026-10-21 13:24:01.951', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560241946, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5400, \"rssi\": -65}}', '2026-10-21 13:24:01.951');
INSERT INTO `device_heartbeat_record` VALUES (1139, 'B4BFE90CDBA1', 5430, '2026-10-21 13:24:31.963', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560271954, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5430, \"rssi\": -65}}', '2026-10-21 13:24:31.964');
INSERT INTO `device_heartbeat_record` VALUES (1140, 'B4BFE90CDBA1', 5460, '2026-10-21 13:25:01.972', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560301955, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5460, \"rssi\": -65}}', '2026-10-21 13:25:01.972');
INSERT INTO `device_heartbeat_record` VALUES (1141, 'B4BFE90CDBA1', 5490, '2026-10-21 13:25:31.983', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560331971, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5490, \"rssi\": -65}}', '2026-10-21 13:25:31.984');
INSERT INTO `device_heartbeat_record` VALUES (1142, 'B4BFE90CDBA1', 5520, '2026-10-21 13:26:01.993', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560361982, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5520, \"rssi\": -65}}', '2026-10-21 13:26:01.993');
INSERT INTO `device_heartbeat_record` VALUES (1143, 'B4BFE90CDBA1', 5550, '2026-10-21 13:26:32.010', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560391995, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5550, \"rssi\": -65}}', '2026-10-21 13:26:32.010');
INSERT INTO `device_heartbeat_record` VALUES (1144, 'B4BFE90CDBA1', 5580, '2026-10-21 13:27:02.022', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560422010, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5580, \"rssi\": -65}}', '2026-10-21 13:27:02.022');
INSERT INTO `device_heartbeat_record` VALUES (1145, 'B4BFE90CDBA1', 5610, '2026-10-21 13:27:32.033', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560452025, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5610, \"rssi\": -65}}', '2026-10-21 13:27:32.033');
INSERT INTO `device_heartbeat_record` VALUES (1146, 'B4BFE90CDBA1', 5640, '2026-10-21 13:28:02.041', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560482029, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5640, \"rssi\": -65}}', '2026-10-21 13:28:02.041');
INSERT INTO `device_heartbeat_record` VALUES (1147, 'B4BFE90CDBA1', 5670, '2026-10-21 13:28:32.042', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560512032, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5670, \"rssi\": -65}}', '2026-10-21 13:28:32.042');
INSERT INTO `device_heartbeat_record` VALUES (1148, 'B4BFE90CDBA1', 5700, '2026-10-21 13:29:02.048', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560542034, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5700, \"rssi\": -65}}', '2026-10-21 13:29:02.048');
INSERT INTO `device_heartbeat_record` VALUES (1149, 'B4BFE90CDBA1', 5730, '2026-10-21 13:29:32.051', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560572036, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5730, \"rssi\": -65}}', '2026-10-21 13:29:32.051');
INSERT INTO `device_heartbeat_record` VALUES (1150, 'B4BFE90CDBA1', 5760, '2026-10-21 13:30:02.058', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560602043, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5760, \"rssi\": -65}}', '2026-10-21 13:30:02.059');
INSERT INTO `device_heartbeat_record` VALUES (1151, 'B4BFE90CDBA1', 5790, '2026-10-21 13:30:32.061', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560632051, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5790, \"rssi\": -65}}', '2026-10-21 13:30:32.062');
INSERT INTO `device_heartbeat_record` VALUES (1152, 'B4BFE90CDBA1', 5820, '2026-10-21 13:31:02.078', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560662063, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5820, \"rssi\": -65}}', '2026-10-21 13:31:02.078');
INSERT INTO `device_heartbeat_record` VALUES (1153, 'B4BFE90CDBA1', 5850, '2026-10-21 13:31:32.085', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560692076, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5850, \"rssi\": -65}}', '2026-10-21 13:31:32.085');
INSERT INTO `device_heartbeat_record` VALUES (1154, 'B4BFE90CDBA1', 5880, '2026-10-21 13:32:02.102', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560722091, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5880, \"rssi\": -65}}', '2026-10-21 13:32:02.102');
INSERT INTO `device_heartbeat_record` VALUES (1155, 'B4BFE90CDBA1', 5910, '2026-10-21 13:32:32.113', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560752096, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5910, \"rssi\": -65}}', '2026-10-21 13:32:32.114');
INSERT INTO `device_heartbeat_record` VALUES (1156, 'B4BFE90CDBA1', 5940, '2026-10-21 13:33:02.113', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560782099, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5940, \"rssi\": -65}}', '2026-10-21 13:33:02.113');
INSERT INTO `device_heartbeat_record` VALUES (1157, 'B4BFE90CDBA1', 5970, '2026-10-21 13:33:32.130', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560812116, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5970, \"rssi\": -65}}', '2026-10-21 13:33:32.131');
INSERT INTO `device_heartbeat_record` VALUES (1158, 'B4BFE90CDBA1', 6000, '2026-10-21 13:34:02.127', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560842120, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6000, \"rssi\": -65}}', '2026-10-21 13:34:02.128');
INSERT INTO `device_heartbeat_record` VALUES (1159, 'B4BFE90CDBA1', 6030, '2026-10-21 13:34:32.148', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560872135, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6030, \"rssi\": -65}}', '2026-10-21 13:34:32.148');
INSERT INTO `device_heartbeat_record` VALUES (1160, 'B4BFE90CDBA1', 6060, '2026-10-21 13:35:02.152', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560902137, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6060, \"rssi\": -65}}', '2026-10-21 13:35:02.152');
INSERT INTO `device_heartbeat_record` VALUES (1161, 'B4BFE90CDBA1', 6090, '2026-10-21 13:35:32.160', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560932142, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6090, \"rssi\": -65}}', '2026-10-21 13:35:32.160');
INSERT INTO `device_heartbeat_record` VALUES (1162, 'B4BFE90CDBA1', 6120, '2026-10-21 13:36:02.168', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560962155, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6120, \"rssi\": -65}}', '2026-10-21 13:36:02.168');
INSERT INTO `device_heartbeat_record` VALUES (1163, 'B4BFE90CDBA1', 6150, '2026-10-21 13:36:32.165', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792560992158, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6150, \"rssi\": -65}}', '2026-10-21 13:36:32.165');
INSERT INTO `device_heartbeat_record` VALUES (1164, 'B4BFE90CDBA1', 6180, '2026-10-21 13:37:02.170', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561022161, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6180, \"rssi\": -65}}', '2026-10-21 13:37:02.170');
INSERT INTO `device_heartbeat_record` VALUES (1165, 'B4BFE90CDBA1', 6210, '2026-10-21 13:37:32.183', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561052170, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6210, \"rssi\": -65}}', '2026-10-21 13:37:32.183');
INSERT INTO `device_heartbeat_record` VALUES (1166, 'B4BFE90CDBA1', 6240, '2026-10-21 13:38:02.178', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561082172, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6240, \"rssi\": -65}}', '2026-10-21 13:38:02.178');
INSERT INTO `device_heartbeat_record` VALUES (1167, 'B4BFE90CDBA1', 6270, '2026-10-21 13:38:32.196', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561112182, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6270, \"rssi\": -65}}', '2026-10-21 13:38:32.196');
INSERT INTO `device_heartbeat_record` VALUES (1168, 'B4BFE90CDBA1', 6300, '2026-10-21 13:39:02.198', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561142191, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6300, \"rssi\": -65}}', '2026-10-21 13:39:02.198');
INSERT INTO `device_heartbeat_record` VALUES (1169, 'B4BFE90CDBA1', 6330, '2026-10-21 13:39:32.219', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561172202, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6330, \"rssi\": -65}}', '2026-10-21 13:39:32.220');
INSERT INTO `device_heartbeat_record` VALUES (1170, 'B4BFE90CDBA1', 6360, '2026-10-21 13:40:02.231', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561202217, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6360, \"rssi\": -65}}', '2026-10-21 13:40:02.232');
INSERT INTO `device_heartbeat_record` VALUES (1171, 'B4BFE90CDBA1', 6390, '2026-10-21 13:40:32.245', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561232229, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6390, \"rssi\": -65}}', '2026-10-21 13:40:32.246');
INSERT INTO `device_heartbeat_record` VALUES (1172, 'B4BFE90CDBA1', 6420, '2026-10-21 13:41:02.257', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561262243, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6420, \"rssi\": -65}}', '2026-10-21 13:41:02.257');
INSERT INTO `device_heartbeat_record` VALUES (1173, 'B4BFE90CDBA1', 6450, '2026-10-21 13:41:32.258', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561292246, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6450, \"rssi\": -65}}', '2026-10-21 13:41:32.258');
INSERT INTO `device_heartbeat_record` VALUES (1174, 'B4BFE90CDBA1', 6480, '2026-10-21 13:42:02.270', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561322262, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6480, \"rssi\": -65}}', '2026-10-21 13:42:02.270');
INSERT INTO `device_heartbeat_record` VALUES (1175, 'B4BFE90CDBA1', 6510, '2026-10-21 13:42:32.279', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561352270, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6510, \"rssi\": -65}}', '2026-10-21 13:42:32.279');
INSERT INTO `device_heartbeat_record` VALUES (1176, 'B4BFE90CDBA1', 6540, '2026-10-21 13:43:02.292', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561382279, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6540, \"rssi\": -65}}', '2026-10-21 13:43:02.292');
INSERT INTO `device_heartbeat_record` VALUES (1177, 'B4BFE90CDBA1', 6570, '2026-10-21 13:43:32.302', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561412294, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6570, \"rssi\": -65}}', '2026-10-21 13:43:32.303');
INSERT INTO `device_heartbeat_record` VALUES (1178, 'B4BFE90CDBA1', 6600, '2026-10-21 13:44:02.306', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561442295, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6600, \"rssi\": -65}}', '2026-10-21 13:44:02.307');
INSERT INTO `device_heartbeat_record` VALUES (1179, 'B4BFE90CDBA1', 6630, '2026-10-21 13:44:32.311', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561472298, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6630, \"rssi\": -65}}', '2026-10-21 13:44:32.311');
INSERT INTO `device_heartbeat_record` VALUES (1180, 'B4BFE90CDBA1', 6660, '2026-10-21 13:45:02.311', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561502305, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6660, \"rssi\": -65}}', '2026-10-21 13:45:02.312');
INSERT INTO `device_heartbeat_record` VALUES (1181, 'B4BFE90CDBA1', 6690, '2026-10-21 13:45:32.326', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561532318, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6690, \"rssi\": -65}}', '2026-10-21 13:45:32.326');
INSERT INTO `device_heartbeat_record` VALUES (1182, 'B4BFE90CDBA1', 6720, '2026-10-21 13:46:02.331', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561562323, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6720, \"rssi\": -65}}', '2026-10-21 13:46:02.331');
INSERT INTO `device_heartbeat_record` VALUES (1183, 'B4BFE90CDBA1', 6750, '2026-10-21 13:46:32.351', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561592335, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6750, \"rssi\": -65}}', '2026-10-21 13:46:32.351');
INSERT INTO `device_heartbeat_record` VALUES (1184, 'B4BFE90CDBA1', 6780, '2026-10-21 13:47:02.356', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561622342, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6780, \"rssi\": -65}}', '2026-10-21 13:47:02.357');
INSERT INTO `device_heartbeat_record` VALUES (1185, 'B4BFE90CDBA1', 6810, '2026-10-21 13:47:32.364', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561652345, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6810, \"rssi\": -65}}', '2026-10-21 13:47:32.364');
INSERT INTO `device_heartbeat_record` VALUES (1186, 'B4BFE90CDBA1', 6840, '2026-10-21 13:48:02.366', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561682359, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6840, \"rssi\": -65}}', '2026-10-21 13:48:02.366');
INSERT INTO `device_heartbeat_record` VALUES (1187, 'B4BFE90CDBA1', 6870, '2026-10-21 13:48:32.388', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561712370, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6870, \"rssi\": -65}}', '2026-10-21 13:48:32.389');
INSERT INTO `device_heartbeat_record` VALUES (1188, 'B4BFE90CDBA1', 6900, '2026-10-21 13:49:02.387', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561742380, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6900, \"rssi\": -65}}', '2026-10-21 13:49:02.387');
INSERT INTO `device_heartbeat_record` VALUES (1189, 'B4BFE90CDBA1', 6930, '2026-10-21 13:49:32.397', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561772383, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6930, \"rssi\": -65}}', '2026-10-21 13:49:32.397');
INSERT INTO `device_heartbeat_record` VALUES (1190, 'B4BFE90CDBA1', 6960, '2026-10-21 13:50:02.402', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561802393, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6960, \"rssi\": -65}}', '2026-10-21 13:50:02.402');
INSERT INTO `device_heartbeat_record` VALUES (1191, 'B4BFE90CDBA1', 6990, '2026-10-21 13:50:32.404', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561832396, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6990, \"rssi\": -65}}', '2026-10-21 13:50:32.404');
INSERT INTO `device_heartbeat_record` VALUES (1192, 'B4BFE90CDBA1', 7020, '2026-10-21 13:51:02.415', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561862406, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7020, \"rssi\": -65}}', '2026-10-21 13:51:02.415');
INSERT INTO `device_heartbeat_record` VALUES (1193, 'B4BFE90CDBA1', 7050, '2026-10-21 13:51:32.428', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561892421, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7050, \"rssi\": -65}}', '2026-10-21 13:51:32.428');
INSERT INTO `device_heartbeat_record` VALUES (1194, 'B4BFE90CDBA1', 7080, '2026-10-21 13:52:02.431', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561922423, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7080, \"rssi\": -65}}', '2026-10-21 13:52:02.432');
INSERT INTO `device_heartbeat_record` VALUES (1195, 'B4BFE90CDBA1', 7110, '2026-10-21 13:52:32.441', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561952430, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7110, \"rssi\": -65}}', '2026-10-21 13:52:32.442');
INSERT INTO `device_heartbeat_record` VALUES (1196, 'B4BFE90CDBA1', 7140, '2026-10-21 13:53:02.443', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792561982434, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7140, \"rssi\": -65}}', '2026-10-21 13:53:02.443');
INSERT INTO `device_heartbeat_record` VALUES (1197, 'B4BFE90CDBA1', 7170, '2026-10-21 13:53:32.460', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562012441, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7170, \"rssi\": -65}}', '2026-10-21 13:53:32.461');
INSERT INTO `device_heartbeat_record` VALUES (1198, 'B4BFE90CDBA1', 7200, '2026-10-21 13:54:02.456', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562042443, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7200, \"rssi\": -65}}', '2026-10-21 13:54:02.457');
INSERT INTO `device_heartbeat_record` VALUES (1199, 'B4BFE90CDBA1', 7230, '2026-10-21 13:54:32.454', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562072447, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7230, \"rssi\": -65}}', '2026-10-21 13:54:32.454');
INSERT INTO `device_heartbeat_record` VALUES (1200, 'B4BFE90CDBA1', 7260, '2026-10-21 13:55:02.466', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562102458, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7260, \"rssi\": -65}}', '2026-10-21 13:55:02.466');
INSERT INTO `device_heartbeat_record` VALUES (1201, 'B4BFE90CDBA1', 7290, '2026-10-21 13:55:32.485', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562132470, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7290, \"rssi\": -65}}', '2026-10-21 13:55:32.485');
INSERT INTO `device_heartbeat_record` VALUES (1202, 'B4BFE90CDBA1', 7320, '2026-10-21 13:56:02.480', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562162473, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7320, \"rssi\": -65}}', '2026-10-21 13:56:02.480');
INSERT INTO `device_heartbeat_record` VALUES (1203, 'B4BFE90CDBA1', 7350, '2026-10-21 13:56:32.494', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562192486, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7350, \"rssi\": -65}}', '2026-10-21 13:56:32.494');
INSERT INTO `device_heartbeat_record` VALUES (1204, 'B4BFE90CDBA1', 7380, '2026-10-21 13:57:02.510', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562222491, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7380, \"rssi\": -65}}', '2026-10-21 13:57:02.511');
INSERT INTO `device_heartbeat_record` VALUES (1205, 'B4BFE90CDBA1', 7410, '2026-10-21 13:57:32.503', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562252496, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7410, \"rssi\": -65}}', '2026-10-21 13:57:32.503');
INSERT INTO `device_heartbeat_record` VALUES (1206, 'B4BFE90CDBA1', 7440, '2026-10-21 13:58:02.518', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562282510, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7440, \"rssi\": -65}}', '2026-10-21 13:58:02.518');
INSERT INTO `device_heartbeat_record` VALUES (1207, 'B4BFE90CDBA1', 7470, '2026-10-21 13:58:32.530', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562312511, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7470, \"rssi\": -65}}', '2026-10-21 13:58:32.530');
INSERT INTO `device_heartbeat_record` VALUES (1208, 'B4BFE90CDBA1', 7500, '2026-10-21 13:59:02.529', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562342521, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7500, \"rssi\": -65}}', '2026-10-21 13:59:02.529');
INSERT INTO `device_heartbeat_record` VALUES (1209, 'B4BFE90CDBA1', 7530, '2026-10-21 13:59:32.531', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562372525, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7530, \"rssi\": -65}}', '2026-10-21 13:59:32.532');
INSERT INTO `device_heartbeat_record` VALUES (1210, 'B4BFE90CDBA1', 7560, '2026-10-21 14:00:02.546', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562402530, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7560, \"rssi\": -65}}', '2026-10-21 14:00:02.547');
INSERT INTO `device_heartbeat_record` VALUES (1211, 'B4BFE90CDBA1', 7590, '2026-10-21 14:00:32.545', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562432533, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7590, \"rssi\": -65}}', '2026-10-21 14:00:32.545');
INSERT INTO `device_heartbeat_record` VALUES (1212, 'B4BFE90CDBA1', 7620, '2026-10-21 14:01:02.548', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562462539, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7620, \"rssi\": -65}}', '2026-10-21 14:01:02.548');
INSERT INTO `device_heartbeat_record` VALUES (1213, 'B4BFE90CDBA1', 7650, '2026-10-21 14:01:32.548', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562492542, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7650, \"rssi\": -65}}', '2026-10-21 14:01:32.548');
INSERT INTO `device_heartbeat_record` VALUES (1214, 'B4BFE90CDBA1', 7680, '2026-10-21 14:02:02.551', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562522544, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7680, \"rssi\": -65}}', '2026-10-21 14:02:02.552');
INSERT INTO `device_heartbeat_record` VALUES (1215, 'B4BFE90CDBA1', 7710, '2026-10-21 14:02:32.567', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562552551, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7710, \"rssi\": -65}}', '2026-10-21 14:02:32.568');
INSERT INTO `device_heartbeat_record` VALUES (1216, 'B4BFE90CDBA1', 7740, '2026-10-21 14:03:02.574', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562582567, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7740, \"rssi\": -65}}', '2026-10-21 14:03:02.574');
INSERT INTO `device_heartbeat_record` VALUES (1217, 'B4BFE90CDBA1', 7770, '2026-10-21 14:03:32.588', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562612576, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7770, \"rssi\": -65}}', '2026-10-21 14:03:32.588');
INSERT INTO `device_heartbeat_record` VALUES (1218, 'B4BFE90CDBA1', 7800, '2026-10-21 14:04:02.585', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562642578, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7800, \"rssi\": -65}}', '2026-10-21 14:04:02.585');
INSERT INTO `device_heartbeat_record` VALUES (1219, 'B4BFE90CDBA1', 7830, '2026-10-21 14:04:32.589', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562672579, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7830, \"rssi\": -65}}', '2026-10-21 14:04:32.589');
INSERT INTO `device_heartbeat_record` VALUES (1220, 'B4BFE90CDBA1', 7860, '2026-10-21 14:05:02.597', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562702587, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7860, \"rssi\": -65}}', '2026-10-21 14:05:02.597');
INSERT INTO `device_heartbeat_record` VALUES (1221, 'B4BFE90CDBA1', 7890, '2026-10-21 14:05:32.604', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562732595, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7890, \"rssi\": -65}}', '2026-10-21 14:05:32.604');
INSERT INTO `device_heartbeat_record` VALUES (1222, 'B4BFE90CDBA1', 7920, '2026-10-21 14:06:02.605', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562762597, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7920, \"rssi\": -65}}', '2026-10-21 14:06:02.605');
INSERT INTO `device_heartbeat_record` VALUES (1223, 'B4BFE90CDBA1', 7950, '2026-10-21 14:06:32.611', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562792602, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7950, \"rssi\": -65}}', '2026-10-21 14:06:32.611');
INSERT INTO `device_heartbeat_record` VALUES (1224, 'B4BFE90CDBA1', 7980, '2026-10-21 14:07:02.621', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562822610, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7980, \"rssi\": -65}}', '2026-10-21 14:07:02.621');
INSERT INTO `device_heartbeat_record` VALUES (1225, 'B4BFE90CDBA1', 8010, '2026-10-21 14:07:32.631', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562852625, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8010, \"rssi\": -65}}', '2026-10-21 14:07:32.631');
INSERT INTO `device_heartbeat_record` VALUES (1226, 'B4BFE90CDBA1', 8040, '2026-10-21 14:08:02.646', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562882640, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8040, \"rssi\": -65}}', '2026-10-21 14:08:02.646');
INSERT INTO `device_heartbeat_record` VALUES (1227, 'B4BFE90CDBA1', 8070, '2026-10-21 14:08:32.649', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562912643, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8070, \"rssi\": -65}}', '2026-10-21 14:08:32.649');
INSERT INTO `device_heartbeat_record` VALUES (1228, 'B4BFE90CDBA1', 8100, '2026-10-21 14:09:02.667', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562942656, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8100, \"rssi\": -65}}', '2026-10-21 14:09:02.667');
INSERT INTO `device_heartbeat_record` VALUES (1229, 'B4BFE90CDBA1', 8130, '2026-10-21 14:09:32.678', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792562972672, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8130, \"rssi\": -65}}', '2026-10-21 14:09:32.679');
INSERT INTO `device_heartbeat_record` VALUES (1230, 'B4BFE90CDBA1', 8160, '2026-10-21 14:10:02.692', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563002681, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8160, \"rssi\": -65}}', '2026-10-21 14:10:02.693');
INSERT INTO `device_heartbeat_record` VALUES (1231, 'B4BFE90CDBA1', 8190, '2026-10-21 14:10:32.700', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563032693, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8190, \"rssi\": -65}}', '2026-10-21 14:10:32.700');
INSERT INTO `device_heartbeat_record` VALUES (1232, 'B4BFE90CDBA1', 8220, '2026-10-21 14:11:02.708', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563062702, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8220, \"rssi\": -65}}', '2026-10-21 14:11:02.708');
INSERT INTO `device_heartbeat_record` VALUES (1233, 'B4BFE90CDBA1', 8250, '2026-10-21 14:11:32.733', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563092717, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8250, \"rssi\": -65}}', '2026-10-21 14:11:32.733');
INSERT INTO `device_heartbeat_record` VALUES (1234, 'B4BFE90CDBA1', 8280, '2026-10-21 14:12:02.740', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563122733, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8280, \"rssi\": -65}}', '2026-10-21 14:12:02.740');
INSERT INTO `device_heartbeat_record` VALUES (1235, 'B4BFE90CDBA1', 8310, '2026-10-21 14:12:32.755', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563152748, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8310, \"rssi\": -65}}', '2026-10-21 14:12:32.755');
INSERT INTO `device_heartbeat_record` VALUES (1236, 'B4BFE90CDBA1', 8340, '2026-10-21 14:13:02.762', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563182754, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8340, \"rssi\": -65}}', '2026-10-21 14:13:02.762');
INSERT INTO `device_heartbeat_record` VALUES (1237, 'B4BFE90CDBA1', 8370, '2026-10-21 14:13:32.762', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563212755, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8370, \"rssi\": -65}}', '2026-10-21 14:13:32.762');
INSERT INTO `device_heartbeat_record` VALUES (1238, 'B4BFE90CDBA1', 8400, '2026-10-21 14:14:02.766', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563242758, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8400, \"rssi\": -65}}', '2026-10-21 14:14:02.767');
INSERT INTO `device_heartbeat_record` VALUES (1239, 'B4BFE90CDBA1', 8430, '2026-10-21 14:14:32.768', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563272759, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8430, \"rssi\": -65}}', '2026-10-21 14:14:32.768');
INSERT INTO `device_heartbeat_record` VALUES (1240, 'B4BFE90CDBA1', 8460, '2026-10-21 14:15:02.783', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563302771, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8460, \"rssi\": -65}}', '2026-10-21 14:15:02.783');
INSERT INTO `device_heartbeat_record` VALUES (1241, 'B4BFE90CDBA1', 8490, '2026-10-21 14:15:32.790', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563332784, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8490, \"rssi\": -65}}', '2026-10-21 14:15:32.790');
INSERT INTO `device_heartbeat_record` VALUES (1242, 'B4BFE90CDBA1', 8520, '2026-10-21 14:16:02.790', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563362785, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8520, \"rssi\": -65}}', '2026-10-21 14:16:02.790');
INSERT INTO `device_heartbeat_record` VALUES (1243, 'B4BFE90CDBA1', 8550, '2026-10-21 14:16:32.812', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563392800, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8550, \"rssi\": -65}}', '2026-10-21 14:16:32.812');
INSERT INTO `device_heartbeat_record` VALUES (1244, 'B4BFE90CDBA1', 8580, '2026-10-21 14:17:02.827', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563422813, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8580, \"rssi\": -65}}', '2026-10-21 14:17:02.827');
INSERT INTO `device_heartbeat_record` VALUES (1245, 'B4BFE90CDBA1', 8610, '2026-10-21 14:17:32.825', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563452816, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8610, \"rssi\": -65}}', '2026-10-21 14:17:32.825');
INSERT INTO `device_heartbeat_record` VALUES (1246, 'B4BFE90CDBA1', 8640, '2026-10-21 14:18:02.838', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563482827, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8640, \"rssi\": -65}}', '2026-10-21 14:18:02.839');
INSERT INTO `device_heartbeat_record` VALUES (1247, 'B4BFE90CDBA1', 8670, '2026-10-21 14:18:32.838', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563512831, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8670, \"rssi\": -65}}', '2026-10-21 14:18:32.838');
INSERT INTO `device_heartbeat_record` VALUES (1248, 'B4BFE90CDBA1', 8700, '2026-10-21 14:19:02.845', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563542837, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8700, \"rssi\": -65}}', '2026-10-21 14:19:02.846');
INSERT INTO `device_heartbeat_record` VALUES (1249, 'B4BFE90CDBA1', 8730, '2026-10-21 14:19:32.850', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563572844, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8730, \"rssi\": -65}}', '2026-10-21 14:19:32.850');
INSERT INTO `device_heartbeat_record` VALUES (1250, 'B4BFE90CDBA1', 8760, '2026-10-21 14:20:02.868', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563602851, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8760, \"rssi\": -65}}', '2026-10-21 14:20:02.868');
INSERT INTO `device_heartbeat_record` VALUES (1251, 'B4BFE90CDBA1', 8790, '2026-10-21 14:20:32.874', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563632863, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8790, \"rssi\": -65}}', '2026-10-21 14:20:32.875');
INSERT INTO `device_heartbeat_record` VALUES (1252, 'B4BFE90CDBA1', 8820, '2026-10-21 14:21:02.875', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563662867, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8820, \"rssi\": -65}}', '2026-10-21 14:21:02.875');
INSERT INTO `device_heartbeat_record` VALUES (1253, 'B4BFE90CDBA1', 8850, '2026-10-21 14:21:32.885', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563692873, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8850, \"rssi\": -65}}', '2026-10-21 14:21:32.885');
INSERT INTO `device_heartbeat_record` VALUES (1254, 'B4BFE90CDBA1', 8880, '2026-10-21 14:22:02.901', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563722888, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8880, \"rssi\": -65}}', '2026-10-21 14:22:02.903');
INSERT INTO `device_heartbeat_record` VALUES (1255, 'B4BFE90CDBA1', 8910, '2026-10-21 14:22:32.903', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563752893, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8910, \"rssi\": -65}}', '2026-10-21 14:22:32.903');
INSERT INTO `device_heartbeat_record` VALUES (1256, 'B4BFE90CDBA1', 8940, '2026-10-21 14:23:02.905', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563782895, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8940, \"rssi\": -65}}', '2026-10-21 14:23:02.905');
INSERT INTO `device_heartbeat_record` VALUES (1257, 'B4BFE90CDBA1', 8970, '2026-10-21 14:23:32.919', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563812907, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8970, \"rssi\": -65}}', '2026-10-21 14:23:32.919');
INSERT INTO `device_heartbeat_record` VALUES (1258, 'B4BFE90CDBA1', 9000, '2026-10-21 14:24:02.937', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563842921, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9000, \"rssi\": -65}}', '2026-10-21 14:24:02.937');
INSERT INTO `device_heartbeat_record` VALUES (1259, 'B4BFE90CDBA1', 9030, '2026-10-21 14:24:32.944', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563872935, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9030, \"rssi\": -65}}', '2026-10-21 14:24:32.944');
INSERT INTO `device_heartbeat_record` VALUES (1260, 'B4BFE90CDBA1', 9060, '2026-10-21 14:25:02.971', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563902957, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9060, \"rssi\": -65}}', '2026-10-21 14:25:02.971');
INSERT INTO `device_heartbeat_record` VALUES (1261, 'B4BFE90CDBA1', 9090, '2026-10-21 14:25:32.977', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563932970, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9090, \"rssi\": -65}}', '2026-10-21 14:25:32.978');
INSERT INTO `device_heartbeat_record` VALUES (1262, 'B4BFE90CDBA1', 9120, '2026-10-21 14:26:02.997', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563962982, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9120, \"rssi\": -65}}', '2026-10-21 14:26:02.998');
INSERT INTO `device_heartbeat_record` VALUES (1263, 'B4BFE90CDBA1', 9150, '2026-10-21 14:26:32.997', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792563992988, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9150, \"rssi\": -65}}', '2026-10-21 14:26:32.997');
INSERT INTO `device_heartbeat_record` VALUES (1264, 'B4BFE90CDBA1', 9180, '2026-10-21 14:27:03.010', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564022996, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9180, \"rssi\": -65}}', '2026-10-21 14:27:03.010');
INSERT INTO `device_heartbeat_record` VALUES (1265, 'B4BFE90CDBA1', 9210, '2026-10-21 14:27:33.011', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564052997, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9210, \"rssi\": -65}}', '2026-10-21 14:27:33.012');
INSERT INTO `device_heartbeat_record` VALUES (1266, 'B4BFE90CDBA1', 9240, '2026-10-21 14:28:03.019', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564083010, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9240, \"rssi\": -65}}', '2026-10-21 14:28:03.020');
INSERT INTO `device_heartbeat_record` VALUES (1267, 'B4BFE90CDBA1', 9270, '2026-10-21 14:28:33.026', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564113018, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9270, \"rssi\": -65}}', '2026-10-21 14:28:33.026');
INSERT INTO `device_heartbeat_record` VALUES (1268, 'B4BFE90CDBA1', 9300, '2026-10-21 14:29:03.033', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564143024, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9300, \"rssi\": -65}}', '2026-10-21 14:29:03.033');
INSERT INTO `device_heartbeat_record` VALUES (1269, 'B4BFE90CDBA1', 9330, '2026-10-21 14:29:33.042', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564173035, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9330, \"rssi\": -65}}', '2026-10-21 14:29:33.043');
INSERT INTO `device_heartbeat_record` VALUES (1270, 'B4BFE90CDBA1', 9360, '2026-10-21 14:30:03.056', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564203044, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9360, \"rssi\": -65}}', '2026-10-21 14:30:03.057');
INSERT INTO `device_heartbeat_record` VALUES (1271, 'B4BFE90CDBA1', 9390, '2026-10-21 14:30:33.059', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564233052, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9390, \"rssi\": -65}}', '2026-10-21 14:30:33.060');
INSERT INTO `device_heartbeat_record` VALUES (1272, 'B4BFE90CDBA1', 9420, '2026-10-21 14:31:03.069', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564263055, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9420, \"rssi\": -65}}', '2026-10-21 14:31:03.070');
INSERT INTO `device_heartbeat_record` VALUES (1273, 'B4BFE90CDBA1', 9450, '2026-10-21 14:31:33.077', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564293063, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9450, \"rssi\": -65}}', '2026-10-21 14:31:33.077');
INSERT INTO `device_heartbeat_record` VALUES (1274, 'B4BFE90CDBA1', 9480, '2026-10-21 14:32:03.079', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564323074, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9480, \"rssi\": -65}}', '2026-10-21 14:32:03.080');
INSERT INTO `device_heartbeat_record` VALUES (1275, 'B4BFE90CDBA1', 9510, '2026-10-21 14:32:33.080', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564353075, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9510, \"rssi\": -65}}', '2026-10-21 14:32:33.080');
INSERT INTO `device_heartbeat_record` VALUES (1276, 'B4BFE90CDBA1', 9540, '2026-10-21 14:33:03.086', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564383076, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9540, \"rssi\": -65}}', '2026-10-21 14:33:03.088');
INSERT INTO `device_heartbeat_record` VALUES (1277, 'B4BFE90CDBA1', 9570, '2026-10-21 14:33:33.093', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564413082, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9570, \"rssi\": -65}}', '2026-10-21 14:33:33.093');
INSERT INTO `device_heartbeat_record` VALUES (1278, 'B4BFE90CDBA1', 9600, '2026-10-21 14:34:03.099', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564443084, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9600, \"rssi\": -65}}', '2026-10-21 14:34:03.099');
INSERT INTO `device_heartbeat_record` VALUES (1279, 'B4BFE90CDBA1', 9630, '2026-10-21 14:34:33.097', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564473087, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9630, \"rssi\": -65}}', '2026-10-21 14:34:33.097');
INSERT INTO `device_heartbeat_record` VALUES (1280, 'B4BFE90CDBA1', 9660, '2026-10-21 14:35:03.109', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564503097, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9660, \"rssi\": -65}}', '2026-10-21 14:35:03.109');
INSERT INTO `device_heartbeat_record` VALUES (1281, 'B4BFE90CDBA1', 9690, '2026-10-21 14:35:33.142', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564533109, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9690, \"rssi\": -65}}', '2026-10-21 14:35:33.142');
INSERT INTO `device_heartbeat_record` VALUES (1282, 'B4BFE90CDBA1', 9720, '2026-10-21 14:36:03.128', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564563118, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9720, \"rssi\": -65}}', '2026-10-21 14:36:03.128');
INSERT INTO `device_heartbeat_record` VALUES (1283, 'B4BFE90CDBA1', 9750, '2026-10-21 14:36:33.143', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564593133, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9750, \"rssi\": -65}}', '2026-10-21 14:36:33.144');
INSERT INTO `device_heartbeat_record` VALUES (1284, 'B4BFE90CDBA1', 9780, '2026-10-21 14:37:03.151', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564623135, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9780, \"rssi\": -65}}', '2026-10-21 14:37:03.152');
INSERT INTO `device_heartbeat_record` VALUES (1285, 'B4BFE90CDBA1', 9810, '2026-10-21 14:37:33.155', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564653147, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9810, \"rssi\": -65}}', '2026-10-21 14:37:33.155');
INSERT INTO `device_heartbeat_record` VALUES (1286, 'B4BFE90CDBA1', 9840, '2026-10-21 14:38:03.164', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564683158, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9840, \"rssi\": -65}}', '2026-10-21 14:38:03.164');
INSERT INTO `device_heartbeat_record` VALUES (1287, 'B4BFE90CDBA1', 9870, '2026-10-21 14:38:33.179', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564713169, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9870, \"rssi\": -65}}', '2026-10-21 14:38:33.179');
INSERT INTO `device_heartbeat_record` VALUES (1288, 'B4BFE90CDBA1', 9900, '2026-10-21 14:39:03.183', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564743175, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9900, \"rssi\": -65}}', '2026-10-21 14:39:03.183');
INSERT INTO `device_heartbeat_record` VALUES (1289, 'B4BFE90CDBA1', 9930, '2026-10-21 14:39:33.199', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564773188, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9930, \"rssi\": -65}}', '2026-10-21 14:39:33.200');
INSERT INTO `device_heartbeat_record` VALUES (1290, 'B4BFE90CDBA1', 9960, '2026-10-21 14:40:03.210', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564803192, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9960, \"rssi\": -65}}', '2026-10-21 14:40:03.210');
INSERT INTO `device_heartbeat_record` VALUES (1291, 'B4BFE90CDBA1', 9990, '2026-10-21 14:40:33.204', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564833194, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9990, \"rssi\": -65}}', '2026-10-21 14:40:33.205');
INSERT INTO `device_heartbeat_record` VALUES (1292, 'B4BFE90CDBA1', 10020, '2026-10-21 14:41:03.214', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564863196, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10020, \"rssi\": -65}}', '2026-10-21 14:41:03.214');
INSERT INTO `device_heartbeat_record` VALUES (1293, 'B4BFE90CDBA1', 10050, '2026-10-21 14:41:33.219', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564893208, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10050, \"rssi\": -65}}', '2026-10-21 14:41:33.219');
INSERT INTO `device_heartbeat_record` VALUES (1294, 'B4BFE90CDBA1', 10080, '2026-10-21 14:42:03.220', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564923215, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10080, \"rssi\": -65}}', '2026-10-21 14:42:03.220');
INSERT INTO `device_heartbeat_record` VALUES (1295, 'B4BFE90CDBA1', 10110, '2026-10-21 14:42:33.239', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564953232, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10110, \"rssi\": -65}}', '2026-10-21 14:42:33.240');
INSERT INTO `device_heartbeat_record` VALUES (1296, 'B4BFE90CDBA1', 10140, '2026-10-21 14:43:03.250', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792564983241, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10140, \"rssi\": -65}}', '2026-10-21 14:43:03.250');
INSERT INTO `device_heartbeat_record` VALUES (1297, 'B4BFE90CDBA1', 10170, '2026-10-21 14:43:33.262', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565013251, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10170, \"rssi\": -65}}', '2026-10-21 14:43:33.262');
INSERT INTO `device_heartbeat_record` VALUES (1298, 'B4BFE90CDBA1', 10200, '2026-10-21 14:44:03.259', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565043252, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10200, \"rssi\": -65}}', '2026-10-21 14:44:03.260');
INSERT INTO `device_heartbeat_record` VALUES (1299, 'B4BFE90CDBA1', 10230, '2026-10-21 14:44:33.280', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565073266, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10230, \"rssi\": -65}}', '2026-10-21 14:44:33.280');
INSERT INTO `device_heartbeat_record` VALUES (1300, 'B4BFE90CDBA1', 10260, '2026-10-21 14:45:03.277', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565103267, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10260, \"rssi\": -65}}', '2026-10-21 14:45:03.277');
INSERT INTO `device_heartbeat_record` VALUES (1301, 'B4BFE90CDBA1', 10290, '2026-10-21 14:45:33.280', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565133271, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10290, \"rssi\": -65}}', '2026-10-21 14:45:33.280');
INSERT INTO `device_heartbeat_record` VALUES (1302, 'B4BFE90CDBA1', 10320, '2026-10-21 14:46:03.295', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565163277, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10320, \"rssi\": -65}}', '2026-10-21 14:46:03.297');
INSERT INTO `device_heartbeat_record` VALUES (1303, 'B4BFE90CDBA1', 10350, '2026-10-21 14:46:33.295', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565193286, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10350, \"rssi\": -65}}', '2026-10-21 14:46:33.295');
INSERT INTO `device_heartbeat_record` VALUES (1304, 'B4BFE90CDBA1', 10380, '2026-10-21 14:47:03.296', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565223288, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10380, \"rssi\": -65}}', '2026-10-21 14:47:03.296');
INSERT INTO `device_heartbeat_record` VALUES (1305, 'B4BFE90CDBA1', 10410, '2026-10-21 14:47:33.315', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565253298, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10410, \"rssi\": -65}}', '2026-10-21 14:47:33.316');
INSERT INTO `device_heartbeat_record` VALUES (1306, 'B4BFE90CDBA1', 10440, '2026-10-21 14:48:03.327', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565283304, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10440, \"rssi\": -65}}', '2026-10-21 14:48:03.328');
INSERT INTO `device_heartbeat_record` VALUES (1307, 'B4BFE90CDBA1', 10470, '2026-10-21 14:48:33.322', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565313306, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10470, \"rssi\": -65}}', '2026-10-21 14:48:33.323');
INSERT INTO `device_heartbeat_record` VALUES (1308, 'B4BFE90CDBA1', 10500, '2026-10-21 14:49:03.316', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565343310, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10500, \"rssi\": -65}}', '2026-10-21 14:49:03.316');
INSERT INTO `device_heartbeat_record` VALUES (1309, 'B4BFE90CDBA1', 10530, '2026-10-21 14:49:33.324', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565373317, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10530, \"rssi\": -65}}', '2026-10-21 14:49:33.324');
INSERT INTO `device_heartbeat_record` VALUES (1310, 'B4BFE90CDBA1', 10560, '2026-10-21 14:50:03.336', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565403328, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10560, \"rssi\": -65}}', '2026-10-21 14:50:03.336');
INSERT INTO `device_heartbeat_record` VALUES (1311, 'B4BFE90CDBA1', 10590, '2026-10-21 14:50:33.352', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565433343, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10590, \"rssi\": -65}}', '2026-10-21 14:50:33.352');
INSERT INTO `device_heartbeat_record` VALUES (1312, 'B4BFE90CDBA1', 10620, '2026-10-21 14:51:03.355', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565463347, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10620, \"rssi\": -65}}', '2026-10-21 14:51:03.356');
INSERT INTO `device_heartbeat_record` VALUES (1313, 'B4BFE90CDBA1', 10650, '2026-10-21 14:51:33.371', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565493359, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10650, \"rssi\": -65}}', '2026-10-21 14:51:33.371');
INSERT INTO `device_heartbeat_record` VALUES (1314, 'B4BFE90CDBA1', 10680, '2026-10-21 14:52:03.371', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565523364, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10680, \"rssi\": -65}}', '2026-10-21 14:52:03.371');
INSERT INTO `device_heartbeat_record` VALUES (1315, 'B4BFE90CDBA1', 10710, '2026-10-21 14:52:33.389', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565553375, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10710, \"rssi\": -65}}', '2026-10-21 14:52:33.389');
INSERT INTO `device_heartbeat_record` VALUES (1316, 'B4BFE90CDBA1', 10740, '2026-10-21 14:53:03.387', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565583377, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10740, \"rssi\": -65}}', '2026-10-21 14:53:03.387');
INSERT INTO `device_heartbeat_record` VALUES (1317, 'B4BFE90CDBA1', 10770, '2026-10-21 14:53:33.401', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565613390, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10770, \"rssi\": -65}}', '2026-10-21 14:53:33.401');
INSERT INTO `device_heartbeat_record` VALUES (1318, 'B4BFE90CDBA1', 10800, '2026-10-21 14:54:03.401', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565643394, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10800, \"rssi\": -65}}', '2026-10-21 14:54:03.401');
INSERT INTO `device_heartbeat_record` VALUES (1319, 'B4BFE90CDBA1', 10830, '2026-10-21 14:54:33.400', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565673394, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10830, \"rssi\": -65}}', '2026-10-21 14:54:33.400');
INSERT INTO `device_heartbeat_record` VALUES (1320, 'B4BFE90CDBA1', 10860, '2026-10-21 14:55:03.407', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565703395, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10860, \"rssi\": -65}}', '2026-10-21 14:55:03.408');
INSERT INTO `device_heartbeat_record` VALUES (1321, 'B4BFE90CDBA1', 10890, '2026-10-21 14:55:33.404', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565733397, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10890, \"rssi\": -65}}', '2026-10-21 14:55:33.404');
INSERT INTO `device_heartbeat_record` VALUES (1322, 'B4BFE90CDBA1', 10920, '2026-10-21 14:56:03.414', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565763407, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10920, \"rssi\": -65}}', '2026-10-21 14:56:03.414');
INSERT INTO `device_heartbeat_record` VALUES (1323, 'B4BFE90CDBA1', 10950, '2026-10-21 14:56:33.429', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565793422, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10950, \"rssi\": -65}}', '2026-10-21 14:56:33.429');
INSERT INTO `device_heartbeat_record` VALUES (1324, 'B4BFE90CDBA1', 10980, '2026-10-21 14:57:03.439', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565823430, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10980, \"rssi\": -65}}', '2026-10-21 14:57:03.439');
INSERT INTO `device_heartbeat_record` VALUES (1325, 'B4BFE90CDBA1', 11010, '2026-10-21 14:57:33.447', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565853438, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11010, \"rssi\": -65}}', '2026-10-21 14:57:33.447');
INSERT INTO `device_heartbeat_record` VALUES (1326, 'B4BFE90CDBA1', 11040, '2026-10-21 14:58:03.445', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565883438, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11040, \"rssi\": -65}}', '2026-10-21 14:58:03.446');
INSERT INTO `device_heartbeat_record` VALUES (1327, 'B4BFE90CDBA1', 11070, '2026-10-21 14:58:33.451', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565913445, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11070, \"rssi\": -65}}', '2026-10-21 14:58:33.451');
INSERT INTO `device_heartbeat_record` VALUES (1328, 'B4BFE90CDBA1', 11100, '2026-10-21 14:59:03.468', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565943460, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11100, \"rssi\": -65}}', '2026-10-21 14:59:03.468');
INSERT INTO `device_heartbeat_record` VALUES (1329, 'B4BFE90CDBA1', 11130, '2026-10-21 14:59:33.477', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792565973462, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11130, \"rssi\": -65}}', '2026-10-21 14:59:33.477');
INSERT INTO `device_heartbeat_record` VALUES (1330, 'B4BFE90CDBA1', 11160, '2026-10-21 15:00:03.483', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566003476, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11160, \"rssi\": -65}}', '2026-10-21 15:00:03.483');
INSERT INTO `device_heartbeat_record` VALUES (1331, 'B4BFE90CDBA1', 11190, '2026-10-21 15:00:33.495', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566033481, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11190, \"rssi\": -65}}', '2026-10-21 15:00:33.495');
INSERT INTO `device_heartbeat_record` VALUES (1332, 'B4BFE90CDBA1', 11220, '2026-10-21 15:01:03.493', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566063484, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11220, \"rssi\": -65}}', '2026-10-21 15:01:03.493');
INSERT INTO `device_heartbeat_record` VALUES (1333, 'B4BFE90CDBA1', 11250, '2026-10-21 15:01:33.495', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566093486, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11250, \"rssi\": -65}}', '2026-10-21 15:01:33.495');
INSERT INTO `device_heartbeat_record` VALUES (1334, 'B4BFE90CDBA1', 11280, '2026-10-21 15:02:03.498', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566123488, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11280, \"rssi\": -65}}', '2026-10-21 15:02:03.498');
INSERT INTO `device_heartbeat_record` VALUES (1335, 'B4BFE90CDBA1', 11310, '2026-10-21 15:02:33.500', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566153493, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11310, \"rssi\": -65}}', '2026-10-21 15:02:33.500');
INSERT INTO `device_heartbeat_record` VALUES (1336, 'B4BFE90CDBA1', 11340, '2026-10-21 15:03:03.508', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566183502, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11340, \"rssi\": -65}}', '2026-10-21 15:03:03.508');
INSERT INTO `device_heartbeat_record` VALUES (1337, 'B4BFE90CDBA1', 11370, '2026-10-21 15:03:33.511', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566213503, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11370, \"rssi\": -65}}', '2026-10-21 15:03:33.511');
INSERT INTO `device_heartbeat_record` VALUES (1338, 'B4BFE90CDBA1', 11400, '2026-10-21 15:04:03.522', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566243515, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11400, \"rssi\": -65}}', '2026-10-21 15:04:03.522');
INSERT INTO `device_heartbeat_record` VALUES (1339, 'B4BFE90CDBA1', 11430, '2026-10-21 15:04:33.540', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566273526, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11430, \"rssi\": -65}}', '2026-10-21 15:04:33.540');
INSERT INTO `device_heartbeat_record` VALUES (1340, 'B4BFE90CDBA1', 11460, '2026-10-21 15:05:03.538', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566303528, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11460, \"rssi\": -65}}', '2026-10-21 15:05:03.538');
INSERT INTO `device_heartbeat_record` VALUES (1341, 'B4BFE90CDBA1', 11490, '2026-10-21 15:05:33.540', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566333532, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11490, \"rssi\": -65}}', '2026-10-21 15:05:33.540');
INSERT INTO `device_heartbeat_record` VALUES (1342, 'B4BFE90CDBA1', 11520, '2026-10-21 15:06:03.548', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566363540, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11520, \"rssi\": -65}}', '2026-10-21 15:06:03.548');
INSERT INTO `device_heartbeat_record` VALUES (1343, 'B4BFE90CDBA1', 11550, '2026-10-21 15:06:33.550', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566393544, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11550, \"rssi\": -65}}', '2026-10-21 15:06:33.551');
INSERT INTO `device_heartbeat_record` VALUES (1344, 'B4BFE90CDBA1', 11580, '2026-10-21 15:07:03.555', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566423548, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11580, \"rssi\": -65}}', '2026-10-21 15:07:03.555');
INSERT INTO `device_heartbeat_record` VALUES (1345, 'B4BFE90CDBA1', 11610, '2026-10-21 15:07:33.563', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566453553, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11610, \"rssi\": -65}}', '2026-10-21 15:07:33.564');
INSERT INTO `device_heartbeat_record` VALUES (1346, 'B4BFE90CDBA1', 11640, '2026-10-21 15:08:03.577', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566483563, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11640, \"rssi\": -65}}', '2026-10-21 15:08:03.577');
INSERT INTO `device_heartbeat_record` VALUES (1347, 'B4BFE90CDBA1', 11670, '2026-10-21 15:08:33.580', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566513574, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11670, \"rssi\": -65}}', '2026-10-21 15:08:33.581');
INSERT INTO `device_heartbeat_record` VALUES (1348, 'B4BFE90CDBA1', 11700, '2026-10-21 15:09:03.588', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566543575, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11700, \"rssi\": -65}}', '2026-10-21 15:09:03.588');
INSERT INTO `device_heartbeat_record` VALUES (1349, 'B4BFE90CDBA1', 11730, '2026-10-21 15:09:33.589', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566573582, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11730, \"rssi\": -65}}', '2026-10-21 15:09:33.590');
INSERT INTO `device_heartbeat_record` VALUES (1350, 'B4BFE90CDBA1', 11760, '2026-10-21 15:10:03.607', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566603594, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11760, \"rssi\": -65}}', '2026-10-21 15:10:03.607');
INSERT INTO `device_heartbeat_record` VALUES (1351, 'B4BFE90CDBA1', 11790, '2026-10-21 15:10:33.607', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566633600, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11790, \"rssi\": -65}}', '2026-10-21 15:10:33.607');
INSERT INTO `device_heartbeat_record` VALUES (1352, 'B4BFE90CDBA1', 11820, '2026-10-21 15:11:03.617', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566663608, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11820, \"rssi\": -65}}', '2026-10-21 15:11:03.617');
INSERT INTO `device_heartbeat_record` VALUES (1353, 'B4BFE90CDBA1', 11850, '2026-10-21 15:11:33.618', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566693613, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11850, \"rssi\": -65}}', '2026-10-21 15:11:33.618');
INSERT INTO `device_heartbeat_record` VALUES (1354, 'B4BFE90CDBA1', 11880, '2026-10-21 15:12:03.630', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566723625, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11880, \"rssi\": -65}}', '2026-10-21 15:12:03.630');
INSERT INTO `device_heartbeat_record` VALUES (1355, 'B4BFE90CDBA1', 11910, '2026-10-21 15:12:33.640', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566753633, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11910, \"rssi\": -65}}', '2026-10-21 15:12:33.641');
INSERT INTO `device_heartbeat_record` VALUES (1356, 'B4BFE90CDBA1', 11940, '2026-10-21 15:13:03.662', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566783647, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11940, \"rssi\": -65}}', '2026-10-21 15:13:03.662');
INSERT INTO `device_heartbeat_record` VALUES (1357, 'B4BFE90CDBA1', 11970, '2026-10-21 15:13:33.663', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566813655, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11970, \"rssi\": -65}}', '2026-10-21 15:13:33.663');
INSERT INTO `device_heartbeat_record` VALUES (1358, 'B4BFE90CDBA1', 12000, '2026-10-21 15:14:03.671', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566843660, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12000, \"rssi\": -65}}', '2026-10-21 15:14:03.671');
INSERT INTO `device_heartbeat_record` VALUES (1359, 'B4BFE90CDBA1', 12030, '2026-10-21 15:14:33.684', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566873675, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12030, \"rssi\": -65}}', '2026-10-21 15:14:33.684');
INSERT INTO `device_heartbeat_record` VALUES (1360, 'B4BFE90CDBA1', 12060, '2026-10-21 15:15:03.698', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566903690, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12060, \"rssi\": -65}}', '2026-10-21 15:15:03.698');
INSERT INTO `device_heartbeat_record` VALUES (1361, 'B4BFE90CDBA1', 12090, '2026-10-21 15:15:33.710', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566933701, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12090, \"rssi\": -65}}', '2026-10-21 15:15:33.711');
INSERT INTO `device_heartbeat_record` VALUES (1362, 'B4BFE90CDBA1', 12120, '2026-10-21 15:16:03.717', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566963711, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12120, \"rssi\": -65}}', '2026-10-21 15:16:03.717');
INSERT INTO `device_heartbeat_record` VALUES (1363, 'B4BFE90CDBA1', 12150, '2026-10-21 15:16:33.729', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792566993724, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12150, \"rssi\": -65}}', '2026-10-21 15:16:33.729');
INSERT INTO `device_heartbeat_record` VALUES (1364, 'B4BFE90CDBA1', 12180, '2026-10-21 15:17:03.734', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567023728, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12180, \"rssi\": -65}}', '2026-10-21 15:17:03.734');
INSERT INTO `device_heartbeat_record` VALUES (1365, 'B4BFE90CDBA1', 12210, '2026-10-21 15:17:33.750', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567053741, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12210, \"rssi\": -65}}', '2026-10-21 15:17:33.751');
INSERT INTO `device_heartbeat_record` VALUES (1366, 'B4BFE90CDBA1', 12240, '2026-10-21 15:18:03.752', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567083747, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12240, \"rssi\": -65}}', '2026-10-21 15:18:03.753');
INSERT INTO `device_heartbeat_record` VALUES (1367, 'B4BFE90CDBA1', 12270, '2026-10-21 15:18:33.766', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567113759, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12270, \"rssi\": -65}}', '2026-10-21 15:18:33.766');
INSERT INTO `device_heartbeat_record` VALUES (1368, 'B4BFE90CDBA1', 12300, '2026-10-21 15:19:03.782', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567143771, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12300, \"rssi\": -65}}', '2026-10-21 15:19:03.783');
INSERT INTO `device_heartbeat_record` VALUES (1369, 'B4BFE90CDBA1', 12330, '2026-10-21 15:19:33.790', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567173782, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12330, \"rssi\": -65}}', '2026-10-21 15:19:33.791');
INSERT INTO `device_heartbeat_record` VALUES (1370, 'B4BFE90CDBA1', 12360, '2026-10-21 15:20:03.803', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567203790, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12360, \"rssi\": -65}}', '2026-10-21 15:20:03.804');
INSERT INTO `device_heartbeat_record` VALUES (1371, 'B4BFE90CDBA1', 12390, '2026-10-21 15:20:33.802', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567233790, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12390, \"rssi\": -65}}', '2026-10-21 15:20:33.802');
INSERT INTO `device_heartbeat_record` VALUES (1372, 'B4BFE90CDBA1', 12420, '2026-10-21 15:21:03.806', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567263791, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12420, \"rssi\": -65}}', '2026-10-21 15:21:03.806');
INSERT INTO `device_heartbeat_record` VALUES (1373, 'B4BFE90CDBA1', 12450, '2026-10-21 15:21:33.806', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567293800, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12450, \"rssi\": -65}}', '2026-10-21 15:21:33.806');
INSERT INTO `device_heartbeat_record` VALUES (1374, 'B4BFE90CDBA1', 12480, '2026-10-21 15:22:03.819', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567323806, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12480, \"rssi\": -65}}', '2026-10-21 15:22:03.820');
INSERT INTO `device_heartbeat_record` VALUES (1375, 'B4BFE90CDBA1', 12510, '2026-10-21 15:22:33.816', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567353809, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12510, \"rssi\": -65}}', '2026-10-21 15:22:33.817');
INSERT INTO `device_heartbeat_record` VALUES (1376, 'B4BFE90CDBA1', 12540, '2026-10-21 15:23:03.834', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567383820, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12540, \"rssi\": -65}}', '2026-10-21 15:23:03.834');
INSERT INTO `device_heartbeat_record` VALUES (1377, 'B4BFE90CDBA1', 12570, '2026-10-21 15:23:33.832', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567413826, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12570, \"rssi\": -65}}', '2026-10-21 15:23:33.832');
INSERT INTO `device_heartbeat_record` VALUES (1378, 'B4BFE90CDBA1', 12600, '2026-10-21 15:24:03.835', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567443827, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12600, \"rssi\": -65}}', '2026-10-21 15:24:03.835');
INSERT INTO `device_heartbeat_record` VALUES (1379, 'B4BFE90CDBA1', 12630, '2026-10-21 15:24:33.837', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567473830, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12630, \"rssi\": -65}}', '2026-10-21 15:24:33.837');
INSERT INTO `device_heartbeat_record` VALUES (1380, 'B4BFE90CDBA1', 12660, '2026-10-21 15:25:03.852', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567503838, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12660, \"rssi\": -65}}', '2026-10-21 15:25:03.852');
INSERT INTO `device_heartbeat_record` VALUES (1381, 'B4BFE90CDBA1', 12690, '2026-10-21 15:25:33.846', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567533838, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12690, \"rssi\": -65}}', '2026-10-21 15:25:33.846');
INSERT INTO `device_heartbeat_record` VALUES (1382, 'B4BFE90CDBA1', 12720, '2026-10-21 15:26:03.849', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567563843, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12720, \"rssi\": -65}}', '2026-10-21 15:26:03.849');
INSERT INTO `device_heartbeat_record` VALUES (1383, 'B4BFE90CDBA1', 12750, '2026-10-21 15:26:33.857', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567593849, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12750, \"rssi\": -65}}', '2026-10-21 15:26:33.857');
INSERT INTO `device_heartbeat_record` VALUES (1384, 'B4BFE90CDBA1', 12780, '2026-10-21 15:27:03.867', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567623861, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12780, \"rssi\": -65}}', '2026-10-21 15:27:03.869');
INSERT INTO `device_heartbeat_record` VALUES (1385, 'B4BFE90CDBA1', 12810, '2026-10-21 15:27:33.886', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567653872, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12810, \"rssi\": -65}}', '2026-10-21 15:27:33.886');
INSERT INTO `device_heartbeat_record` VALUES (1386, 'B4BFE90CDBA1', 12840, '2026-10-21 15:28:03.898', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567683886, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12840, \"rssi\": -65}}', '2026-10-21 15:28:03.898');
INSERT INTO `device_heartbeat_record` VALUES (1387, 'B4BFE90CDBA1', 12870, '2026-10-21 15:28:33.917', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567713902, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12870, \"rssi\": -65}}', '2026-10-21 15:28:33.917');
INSERT INTO `device_heartbeat_record` VALUES (1388, 'B4BFE90CDBA1', 12900, '2026-10-21 15:29:03.927', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567743916, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12900, \"rssi\": -65}}', '2026-10-21 15:29:03.927');
INSERT INTO `device_heartbeat_record` VALUES (1389, 'B4BFE90CDBA1', 12930, '2026-10-21 15:29:33.934', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567773928, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12930, \"rssi\": -65}}', '2026-10-21 15:29:33.934');
INSERT INTO `device_heartbeat_record` VALUES (1390, 'B4BFE90CDBA1', 12960, '2026-10-21 15:30:03.940', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567803931, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12960, \"rssi\": -65}}', '2026-10-21 15:30:03.940');
INSERT INTO `device_heartbeat_record` VALUES (1391, 'B4BFE90CDBA1', 12990, '2026-10-21 15:30:33.945', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567833933, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12990, \"rssi\": -65}}', '2026-10-21 15:30:33.945');
INSERT INTO `device_heartbeat_record` VALUES (1392, 'B4BFE90CDBA1', 13020, '2026-10-21 15:31:03.960', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567863949, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13020, \"rssi\": -65}}', '2026-10-21 15:31:03.960');
INSERT INTO `device_heartbeat_record` VALUES (1393, 'B4BFE90CDBA1', 13050, '2026-10-21 15:31:33.966', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567893957, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13050, \"rssi\": -65}}', '2026-10-21 15:31:33.966');
INSERT INTO `device_heartbeat_record` VALUES (1394, 'B4BFE90CDBA1', 13080, '2026-10-21 15:32:03.983', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567923967, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13080, \"rssi\": -65}}', '2026-10-21 15:32:03.984');
INSERT INTO `device_heartbeat_record` VALUES (1395, 'B4BFE90CDBA1', 13110, '2026-10-21 15:32:33.988', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567953974, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13110, \"rssi\": -65}}', '2026-10-21 15:32:33.988');
INSERT INTO `device_heartbeat_record` VALUES (1396, 'B4BFE90CDBA1', 13140, '2026-10-21 15:33:03.998', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792567983985, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13140, \"rssi\": -65}}', '2026-10-21 15:33:03.998');
INSERT INTO `device_heartbeat_record` VALUES (1397, 'B4BFE90CDBA1', 13170, '2026-10-21 15:33:34.005', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568013995, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13170, \"rssi\": -65}}', '2026-10-21 15:33:34.005');
INSERT INTO `device_heartbeat_record` VALUES (1398, 'B4BFE90CDBA1', 13200, '2026-10-21 15:34:04.014', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568044001, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13200, \"rssi\": -65}}', '2026-10-21 15:34:04.014');
INSERT INTO `device_heartbeat_record` VALUES (1399, 'B4BFE90CDBA1', 13230, '2026-10-21 15:34:34.005', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568074001, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13230, \"rssi\": -65}}', '2026-10-21 15:34:34.006');
INSERT INTO `device_heartbeat_record` VALUES (1400, 'B4BFE90CDBA1', 13260, '2026-10-21 15:35:04.024', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568104010, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13260, \"rssi\": -65}}', '2026-10-21 15:35:04.024');
INSERT INTO `device_heartbeat_record` VALUES (1401, 'B4BFE90CDBA1', 13290, '2026-10-21 15:35:34.031', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568134021, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13290, \"rssi\": -65}}', '2026-10-21 15:35:34.031');
INSERT INTO `device_heartbeat_record` VALUES (1402, 'B4BFE90CDBA1', 13320, '2026-10-21 15:36:04.045', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568164030, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13320, \"rssi\": -65}}', '2026-10-21 15:36:04.046');
INSERT INTO `device_heartbeat_record` VALUES (1403, 'B4BFE90CDBA1', 13350, '2026-10-21 15:36:34.048', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568194037, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13350, \"rssi\": -65}}', '2026-10-21 15:36:34.048');
INSERT INTO `device_heartbeat_record` VALUES (1404, 'B4BFE90CDBA1', 13380, '2026-10-21 15:37:04.060', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568224047, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13380, \"rssi\": -65}}', '2026-10-21 15:37:04.061');
INSERT INTO `device_heartbeat_record` VALUES (1405, 'B4BFE90CDBA1', 13410, '2026-10-21 15:37:34.063', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568254054, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13410, \"rssi\": -65}}', '2026-10-21 15:37:34.063');
INSERT INTO `device_heartbeat_record` VALUES (1406, 'B4BFE90CDBA1', 13440, '2026-10-21 15:38:04.070', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568284060, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13440, \"rssi\": -65}}', '2026-10-21 15:38:04.070');
INSERT INTO `device_heartbeat_record` VALUES (1407, 'B4BFE90CDBA1', 13470, '2026-10-21 15:38:34.079', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568314067, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13470, \"rssi\": -65}}', '2026-10-21 15:38:34.079');
INSERT INTO `device_heartbeat_record` VALUES (1408, 'B4BFE90CDBA1', 13500, '2026-10-21 15:39:04.092', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568344077, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13500, \"rssi\": -65}}', '2026-10-21 15:39:04.093');
INSERT INTO `device_heartbeat_record` VALUES (1409, 'B4BFE90CDBA1', 13530, '2026-10-21 15:39:34.106', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568374092, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13530, \"rssi\": -65}}', '2026-10-21 15:39:34.106');
INSERT INTO `device_heartbeat_record` VALUES (1410, 'B4BFE90CDBA1', 13560, '2026-10-21 15:40:04.120', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568404108, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13560, \"rssi\": -65}}', '2026-10-21 15:40:04.120');
INSERT INTO `device_heartbeat_record` VALUES (1411, 'B4BFE90CDBA1', 13590, '2026-10-21 15:40:34.124', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568434112, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13590, \"rssi\": -65}}', '2026-10-21 15:40:34.125');
INSERT INTO `device_heartbeat_record` VALUES (1412, 'B4BFE90CDBA1', 13620, '2026-10-21 15:41:04.136', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568464124, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13620, \"rssi\": -65}}', '2026-10-21 15:41:04.137');
INSERT INTO `device_heartbeat_record` VALUES (1413, 'B4BFE90CDBA1', 13650, '2026-10-21 15:41:34.137', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568494125, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13650, \"rssi\": -65}}', '2026-10-21 15:41:34.138');
INSERT INTO `device_heartbeat_record` VALUES (1414, 'B4BFE90CDBA1', 13680, '2026-10-21 15:42:04.151', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568524138, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13680, \"rssi\": -65}}', '2026-10-21 15:42:04.152');
INSERT INTO `device_heartbeat_record` VALUES (1415, 'B4BFE90CDBA1', 13710, '2026-10-21 15:42:34.153', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568554143, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13710, \"rssi\": -65}}', '2026-10-21 15:42:34.153');
INSERT INTO `device_heartbeat_record` VALUES (1416, 'B4BFE90CDBA1', 13740, '2026-10-21 15:43:04.160', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568584147, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13740, \"rssi\": -65}}', '2026-10-21 15:43:04.160');
INSERT INTO `device_heartbeat_record` VALUES (1417, 'B4BFE90CDBA1', 13770, '2026-10-21 15:43:34.167', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568614154, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13770, \"rssi\": -65}}', '2026-10-21 15:43:34.167');
INSERT INTO `device_heartbeat_record` VALUES (1418, 'B4BFE90CDBA1', 13800, '2026-10-21 15:44:04.183', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568644169, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13800, \"rssi\": -65}}', '2026-10-21 15:44:04.183');
INSERT INTO `device_heartbeat_record` VALUES (1419, 'B4BFE90CDBA1', 13830, '2026-10-21 15:44:34.185', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568674174, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13830, \"rssi\": -65}}', '2026-10-21 15:44:34.185');
INSERT INTO `device_heartbeat_record` VALUES (1420, 'B4BFE90CDBA1', 13860, '2026-10-21 15:45:04.201', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568704186, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13860, \"rssi\": -65}}', '2026-10-21 15:45:04.201');
INSERT INTO `device_heartbeat_record` VALUES (1421, 'B4BFE90CDBA1', 13890, '2026-10-21 15:45:34.206', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568734197, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13890, \"rssi\": -65}}', '2026-10-21 15:45:34.206');
INSERT INTO `device_heartbeat_record` VALUES (1422, 'B4BFE90CDBA1', 13920, '2026-10-21 15:46:04.216', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568764203, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13920, \"rssi\": -65}}', '2026-10-21 15:46:04.217');
INSERT INTO `device_heartbeat_record` VALUES (1423, 'B4BFE90CDBA1', 13950, '2026-10-21 15:46:34.225', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568794214, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13950, \"rssi\": -65}}', '2026-10-21 15:46:34.225');
INSERT INTO `device_heartbeat_record` VALUES (1424, 'B4BFE90CDBA1', 13980, '2026-10-21 15:47:04.229', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568824216, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13980, \"rssi\": -65}}', '2026-10-21 15:47:04.229');
INSERT INTO `device_heartbeat_record` VALUES (1425, 'B4BFE90CDBA1', 14010, '2026-10-21 15:47:34.242', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568854229, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14010, \"rssi\": -65}}', '2026-10-21 15:47:34.242');
INSERT INTO `device_heartbeat_record` VALUES (1426, 'B4BFE90CDBA1', 14040, '2026-10-21 15:48:04.260', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568884245, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14040, \"rssi\": -65}}', '2026-10-21 15:48:04.260');
INSERT INTO `device_heartbeat_record` VALUES (1427, 'B4BFE90CDBA1', 14070, '2026-10-21 15:48:34.269', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568914261, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14070, \"rssi\": -65}}', '2026-10-21 15:48:34.269');
INSERT INTO `device_heartbeat_record` VALUES (1428, 'B4BFE90CDBA1', 14100, '2026-10-21 15:49:04.287', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568944275, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14100, \"rssi\": -65}}', '2026-10-21 15:49:04.287');
INSERT INTO `device_heartbeat_record` VALUES (1429, 'B4BFE90CDBA1', 14130, '2026-10-21 15:49:34.300', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792568974284, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14130, \"rssi\": -65}}', '2026-10-21 15:49:34.300');
INSERT INTO `device_heartbeat_record` VALUES (1430, 'B4BFE90CDBA1', 14160, '2026-10-21 15:50:04.310', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569004298, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14160, \"rssi\": -65}}', '2026-10-21 15:50:04.310');
INSERT INTO `device_heartbeat_record` VALUES (1431, 'B4BFE90CDBA1', 14190, '2026-10-21 15:50:34.323', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569034311, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14190, \"rssi\": -65}}', '2026-10-21 15:50:34.323');
INSERT INTO `device_heartbeat_record` VALUES (1432, 'B4BFE90CDBA1', 14220, '2026-10-21 15:51:04.335', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569064325, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14220, \"rssi\": -65}}', '2026-10-21 15:51:04.335');
INSERT INTO `device_heartbeat_record` VALUES (1433, 'B4BFE90CDBA1', 14250, '2026-10-21 15:51:34.349', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569094338, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14250, \"rssi\": -65}}', '2026-10-21 15:51:34.349');
INSERT INTO `device_heartbeat_record` VALUES (1434, 'B4BFE90CDBA1', 14280, '2026-10-21 15:52:04.351', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569124342, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14280, \"rssi\": -65}}', '2026-10-21 15:52:04.351');
INSERT INTO `device_heartbeat_record` VALUES (1435, 'B4BFE90CDBA1', 14310, '2026-10-21 15:52:34.356', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569154344, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14310, \"rssi\": -65}}', '2026-10-21 15:52:34.356');
INSERT INTO `device_heartbeat_record` VALUES (1436, 'B4BFE90CDBA1', 14340, '2026-10-21 15:53:04.369', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569184359, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14340, \"rssi\": -65}}', '2026-10-21 15:53:04.369');
INSERT INTO `device_heartbeat_record` VALUES (1437, 'B4BFE90CDBA1', 14370, '2026-10-21 15:53:34.370', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569214360, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14370, \"rssi\": -65}}', '2026-10-21 15:53:34.370');
INSERT INTO `device_heartbeat_record` VALUES (1438, 'B4BFE90CDBA1', 14400, '2026-10-21 15:54:04.385', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569244372, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14400, \"rssi\": -65}}', '2026-10-21 15:54:04.385');
INSERT INTO `device_heartbeat_record` VALUES (1439, 'B4BFE90CDBA1', 14430, '2026-10-21 15:54:34.389', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569274375, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14430, \"rssi\": -65}}', '2026-10-21 15:54:34.389');
INSERT INTO `device_heartbeat_record` VALUES (1440, 'B4BFE90CDBA1', 14460, '2026-10-21 15:55:04.395', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569304383, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14460, \"rssi\": -65}}', '2026-10-21 15:55:04.396');
INSERT INTO `device_heartbeat_record` VALUES (1441, 'B4BFE90CDBA1', 14490, '2026-10-21 15:55:34.397', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569334384, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14490, \"rssi\": -65}}', '2026-10-21 15:55:34.397');
INSERT INTO `device_heartbeat_record` VALUES (1442, 'B4BFE90CDBA1', 14520, '2026-10-21 15:56:04.409', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569364395, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14520, \"rssi\": -65}}', '2026-10-21 15:56:04.409');
INSERT INTO `device_heartbeat_record` VALUES (1443, 'B4BFE90CDBA1', 14550, '2026-10-21 15:56:34.411', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569394401, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14550, \"rssi\": -65}}', '2026-10-21 15:56:34.411');
INSERT INTO `device_heartbeat_record` VALUES (1444, 'B4BFE90CDBA1', 14580, '2026-10-21 15:57:04.411', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569424404, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14580, \"rssi\": -65}}', '2026-10-21 15:57:04.411');
INSERT INTO `device_heartbeat_record` VALUES (1445, 'B4BFE90CDBA1', 14610, '2026-10-21 15:57:34.431', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569454417, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14610, \"rssi\": -65}}', '2026-10-21 15:57:34.431');
INSERT INTO `device_heartbeat_record` VALUES (1446, 'B4BFE90CDBA1', 14640, '2026-10-21 15:58:04.442', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569484426, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14640, \"rssi\": -65}}', '2026-10-21 15:58:04.444');
INSERT INTO `device_heartbeat_record` VALUES (1447, 'B4BFE90CDBA1', 14670, '2026-10-21 15:58:34.446', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569514435, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14670, \"rssi\": -65}}', '2026-10-21 15:58:34.446');
INSERT INTO `device_heartbeat_record` VALUES (1448, 'B4BFE90CDBA1', 14700, '2026-10-21 15:59:04.455', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569544444, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14700, \"rssi\": -65}}', '2026-10-21 15:59:04.455');
INSERT INTO `device_heartbeat_record` VALUES (1449, 'B4BFE90CDBA1', 14730, '2026-10-21 15:59:34.457', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569574447, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14730, \"rssi\": -65}}', '2026-10-21 15:59:34.457');
INSERT INTO `device_heartbeat_record` VALUES (1450, 'B4BFE90CDBA1', 14760, '2026-10-21 16:00:04.466', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569604452, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14760, \"rssi\": -65}}', '2026-10-21 16:00:04.466');
INSERT INTO `device_heartbeat_record` VALUES (1451, 'B4BFE90CDBA1', 14790, '2026-10-21 16:00:34.477', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569634464, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14790, \"rssi\": -65}}', '2026-10-21 16:00:34.477');
INSERT INTO `device_heartbeat_record` VALUES (1452, 'B4BFE90CDBA1', 14820, '2026-10-21 16:01:04.480', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569664468, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14820, \"rssi\": -65}}', '2026-10-21 16:01:04.480');
INSERT INTO `device_heartbeat_record` VALUES (1453, 'B4BFE90CDBA1', 14850, '2026-10-21 16:01:34.490', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569694480, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14850, \"rssi\": -65}}', '2026-10-21 16:01:34.490');
INSERT INTO `device_heartbeat_record` VALUES (1454, 'B4BFE90CDBA1', 14880, '2026-10-21 16:02:04.505', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569724495, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14880, \"rssi\": -65}}', '2026-10-21 16:02:04.505');
INSERT INTO `device_heartbeat_record` VALUES (1455, 'B4BFE90CDBA1', 14910, '2026-10-21 16:02:34.517', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569754505, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14910, \"rssi\": -65}}', '2026-10-21 16:02:34.517');
INSERT INTO `device_heartbeat_record` VALUES (1456, 'B4BFE90CDBA1', 14940, '2026-10-21 16:03:04.529', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569784515, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14940, \"rssi\": -65}}', '2026-10-21 16:03:04.529');
INSERT INTO `device_heartbeat_record` VALUES (1457, 'B4BFE90CDBA1', 14970, '2026-10-21 16:03:34.532', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569814521, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14970, \"rssi\": -65}}', '2026-10-21 16:03:34.532');
INSERT INTO `device_heartbeat_record` VALUES (1458, 'B4BFE90CDBA1', 15000, '2026-10-21 16:04:04.550', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569844532, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15000, \"rssi\": -65}}', '2026-10-21 16:04:04.550');
INSERT INTO `device_heartbeat_record` VALUES (1459, 'B4BFE90CDBA1', 15030, '2026-10-21 16:04:34.545', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569874537, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15030, \"rssi\": -65}}', '2026-10-21 16:04:34.545');
INSERT INTO `device_heartbeat_record` VALUES (1460, 'B4BFE90CDBA1', 15060, '2026-10-21 16:05:04.544', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569904537, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15060, \"rssi\": -65}}', '2026-10-21 16:05:04.544');
INSERT INTO `device_heartbeat_record` VALUES (1461, 'B4BFE90CDBA1', 15090, '2026-10-21 16:05:34.555', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569934546, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15090, \"rssi\": -65}}', '2026-10-21 16:05:34.555');
INSERT INTO `device_heartbeat_record` VALUES (1462, 'B4BFE90CDBA1', 15120, '2026-10-21 16:06:04.571', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569964557, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15120, \"rssi\": -65}}', '2026-10-21 16:06:04.571');
INSERT INTO `device_heartbeat_record` VALUES (1463, 'B4BFE90CDBA1', 15150, '2026-10-21 16:06:34.583', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792569994573, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15150, \"rssi\": -65}}', '2026-10-21 16:06:34.583');
INSERT INTO `device_heartbeat_record` VALUES (1464, 'B4BFE90CDBA1', 15180, '2026-10-21 16:07:04.587', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570024581, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15180, \"rssi\": -65}}', '2026-10-21 16:07:04.587');
INSERT INTO `device_heartbeat_record` VALUES (1465, 'B4BFE90CDBA1', 15210, '2026-10-21 16:07:34.598', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570054586, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15210, \"rssi\": -65}}', '2026-10-21 16:07:34.598');
INSERT INTO `device_heartbeat_record` VALUES (1466, 'B4BFE90CDBA1', 15240, '2026-10-21 16:08:04.601', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570084586, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15240, \"rssi\": -65}}', '2026-10-21 16:08:04.601');
INSERT INTO `device_heartbeat_record` VALUES (1467, 'B4BFE90CDBA1', 15270, '2026-10-21 16:08:34.607', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570114595, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15270, \"rssi\": -65}}', '2026-10-21 16:08:34.608');
INSERT INTO `device_heartbeat_record` VALUES (1468, 'B4BFE90CDBA1', 15300, '2026-10-21 16:09:04.614', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570144607, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15300, \"rssi\": -65}}', '2026-10-21 16:09:04.615');
INSERT INTO `device_heartbeat_record` VALUES (1469, 'B4BFE90CDBA1', 15330, '2026-10-21 16:09:34.629', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570174618, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15330, \"rssi\": -65}}', '2026-10-21 16:09:34.630');
INSERT INTO `device_heartbeat_record` VALUES (1470, 'B4BFE90CDBA1', 15360, '2026-10-21 16:10:04.636', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570204625, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15360, \"rssi\": -65}}', '2026-10-21 16:10:04.636');
INSERT INTO `device_heartbeat_record` VALUES (1471, 'B4BFE90CDBA1', 15390, '2026-10-21 16:10:34.653', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570234639, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15390, \"rssi\": -65}}', '2026-10-21 16:10:34.653');
INSERT INTO `device_heartbeat_record` VALUES (1472, 'B4BFE90CDBA1', 15420, '2026-10-21 16:11:04.655', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570264646, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15420, \"rssi\": -65}}', '2026-10-21 16:11:04.656');
INSERT INTO `device_heartbeat_record` VALUES (1473, 'B4BFE90CDBA1', 15450, '2026-10-21 16:11:34.669', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570294660, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15450, \"rssi\": -65}}', '2026-10-21 16:11:34.669');
INSERT INTO `device_heartbeat_record` VALUES (1474, 'B4BFE90CDBA1', 15480, '2026-10-21 16:12:04.678', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570324671, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15480, \"rssi\": -65}}', '2026-10-21 16:12:04.678');
INSERT INTO `device_heartbeat_record` VALUES (1475, 'B4BFE90CDBA1', 15510, '2026-10-21 16:12:34.684', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570354673, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15510, \"rssi\": -65}}', '2026-10-21 16:12:34.684');
INSERT INTO `device_heartbeat_record` VALUES (1476, 'B4BFE90CDBA1', 15540, '2026-10-21 16:13:04.693', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570384686, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15540, \"rssi\": -65}}', '2026-10-21 16:13:04.694');
INSERT INTO `device_heartbeat_record` VALUES (1477, 'B4BFE90CDBA1', 15570, '2026-10-21 16:13:34.702', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570414696, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15570, \"rssi\": -65}}', '2026-10-21 16:13:34.702');
INSERT INTO `device_heartbeat_record` VALUES (1478, 'B4BFE90CDBA1', 15600, '2026-10-21 16:14:04.708', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570444698, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15600, \"rssi\": -65}}', '2026-10-21 16:14:04.708');
INSERT INTO `device_heartbeat_record` VALUES (1479, 'B4BFE90CDBA1', 15630, '2026-10-21 16:14:34.711', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570474703, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15630, \"rssi\": -65}}', '2026-10-21 16:14:34.711');
INSERT INTO `device_heartbeat_record` VALUES (1480, 'B4BFE90CDBA1', 15660, '2026-10-21 16:15:04.718', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570504709, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15660, \"rssi\": -65}}', '2026-10-21 16:15:04.718');
INSERT INTO `device_heartbeat_record` VALUES (1481, 'B4BFE90CDBA1', 15690, '2026-10-21 16:15:34.731', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570534725, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15690, \"rssi\": -65}}', '2026-10-21 16:15:34.731');
INSERT INTO `device_heartbeat_record` VALUES (1482, 'B4BFE90CDBA1', 15720, '2026-10-21 16:16:04.747', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570564738, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15720, \"rssi\": -65}}', '2026-10-21 16:16:04.747');
INSERT INTO `device_heartbeat_record` VALUES (1483, 'B4BFE90CDBA1', 15750, '2026-10-21 16:16:34.754', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570594747, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15750, \"rssi\": -65}}', '2026-10-21 16:16:34.754');
INSERT INTO `device_heartbeat_record` VALUES (1484, 'B4BFE90CDBA1', 15780, '2026-10-21 16:17:04.764', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570624750, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15780, \"rssi\": -65}}', '2026-10-21 16:17:04.765');
INSERT INTO `device_heartbeat_record` VALUES (1485, 'B4BFE90CDBA1', 15810, '2026-10-21 16:17:34.771', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570654762, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15810, \"rssi\": -65}}', '2026-10-21 16:17:34.771');
INSERT INTO `device_heartbeat_record` VALUES (1486, 'B4BFE90CDBA1', 15840, '2026-10-21 16:18:04.775', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570684767, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15840, \"rssi\": -65}}', '2026-10-21 16:18:04.775');
INSERT INTO `device_heartbeat_record` VALUES (1487, 'B4BFE90CDBA1', 15870, '2026-10-21 16:18:34.780', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570714775, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15870, \"rssi\": -65}}', '2026-10-21 16:18:34.780');
INSERT INTO `device_heartbeat_record` VALUES (1488, 'B4BFE90CDBA1', 15900, '2026-10-21 16:19:04.789', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570744783, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15900, \"rssi\": -65}}', '2026-10-21 16:19:04.790');
INSERT INTO `device_heartbeat_record` VALUES (1489, 'B4BFE90CDBA1', 15930, '2026-10-21 16:19:34.795', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570774788, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15930, \"rssi\": -65}}', '2026-10-21 16:19:34.795');
INSERT INTO `device_heartbeat_record` VALUES (1490, 'B4BFE90CDBA1', 15960, '2026-10-21 16:20:04.795', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570804789, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15960, \"rssi\": -65}}', '2026-10-21 16:20:04.795');
INSERT INTO `device_heartbeat_record` VALUES (1491, 'B4BFE90CDBA1', 15990, '2026-10-21 16:20:34.816', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570834805, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 15990, \"rssi\": -65}}', '2026-10-21 16:20:34.816');
INSERT INTO `device_heartbeat_record` VALUES (1492, 'B4BFE90CDBA1', 16020, '2026-10-21 16:21:04.828', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570864821, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16020, \"rssi\": -65}}', '2026-10-21 16:21:04.828');
INSERT INTO `device_heartbeat_record` VALUES (1493, 'B4BFE90CDBA1', 16050, '2026-10-21 16:21:34.829', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570894823, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16050, \"rssi\": -65}}', '2026-10-21 16:21:34.830');
INSERT INTO `device_heartbeat_record` VALUES (1494, 'B4BFE90CDBA1', 16080, '2026-10-21 16:22:04.835', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570924823, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16080, \"rssi\": -65}}', '2026-10-21 16:22:04.835');
INSERT INTO `device_heartbeat_record` VALUES (1495, 'B4BFE90CDBA1', 16110, '2026-10-21 16:22:34.839', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570954828, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16110, \"rssi\": -65}}', '2026-10-21 16:22:34.840');
INSERT INTO `device_heartbeat_record` VALUES (1496, 'B4BFE90CDBA1', 16140, '2026-10-21 16:23:04.856', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792570984844, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16140, \"rssi\": -65}}', '2026-10-21 16:23:04.856');
INSERT INTO `device_heartbeat_record` VALUES (1497, 'B4BFE90CDBA1', 16170, '2026-10-21 16:23:34.864', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571014851, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16170, \"rssi\": -65}}', '2026-10-21 16:23:34.864');
INSERT INTO `device_heartbeat_record` VALUES (1498, 'B4BFE90CDBA1', 16200, '2026-10-21 16:24:04.884', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571044867, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16200, \"rssi\": -65}}', '2026-10-21 16:24:04.885');
INSERT INTO `device_heartbeat_record` VALUES (1499, 'B4BFE90CDBA1', 16230, '2026-10-21 16:24:34.887', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571074877, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16230, \"rssi\": -65}}', '2026-10-21 16:24:34.887');
INSERT INTO `device_heartbeat_record` VALUES (1500, 'B4BFE90CDBA1', 16260, '2026-10-21 16:25:04.888', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571104879, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16260, \"rssi\": -65}}', '2026-10-21 16:25:04.888');
INSERT INTO `device_heartbeat_record` VALUES (1501, 'B4BFE90CDBA1', 16290, '2026-10-21 16:25:34.897', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571134887, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16290, \"rssi\": -65}}', '2026-10-21 16:25:34.897');
INSERT INTO `device_heartbeat_record` VALUES (1502, 'B4BFE90CDBA1', 16320, '2026-10-21 16:26:04.915', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571164901, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16320, \"rssi\": -65}}', '2026-10-21 16:26:04.915');
INSERT INTO `device_heartbeat_record` VALUES (1503, 'B4BFE90CDBA1', 16350, '2026-10-21 16:26:34.916', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571194907, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16350, \"rssi\": -65}}', '2026-10-21 16:26:34.916');
INSERT INTO `device_heartbeat_record` VALUES (1504, 'B4BFE90CDBA1', 16380, '2026-10-21 16:27:04.928', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571224922, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16380, \"rssi\": -65}}', '2026-10-21 16:27:04.928');
INSERT INTO `device_heartbeat_record` VALUES (1505, 'B4BFE90CDBA1', 16410, '2026-10-21 16:27:34.949', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571254933, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16410, \"rssi\": -65}}', '2026-10-21 16:27:34.949');
INSERT INTO `device_heartbeat_record` VALUES (1506, 'B4BFE90CDBA1', 16440, '2026-10-21 16:28:04.948', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571284940, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16440, \"rssi\": -65}}', '2026-10-21 16:28:04.948');
INSERT INTO `device_heartbeat_record` VALUES (1507, 'B4BFE90CDBA1', 16470, '2026-10-21 16:28:34.970', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571314955, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16470, \"rssi\": -65}}', '2026-10-21 16:28:34.971');
INSERT INTO `device_heartbeat_record` VALUES (1508, 'B4BFE90CDBA1', 16500, '2026-10-21 16:29:04.979', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571344966, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16500, \"rssi\": -65}}', '2026-10-21 16:29:04.980');
INSERT INTO `device_heartbeat_record` VALUES (1509, 'B4BFE90CDBA1', 16530, '2026-10-21 16:29:34.984', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571374971, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16530, \"rssi\": -65}}', '2026-10-21 16:29:34.984');
INSERT INTO `device_heartbeat_record` VALUES (1510, 'B4BFE90CDBA1', 16560, '2026-10-21 16:30:04.980', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571404973, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16560, \"rssi\": -65}}', '2026-10-21 16:30:04.980');
INSERT INTO `device_heartbeat_record` VALUES (1511, 'B4BFE90CDBA1', 16590, '2026-10-21 16:30:35.035', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571434984, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16590, \"rssi\": -65}}', '2026-10-21 16:30:35.035');
INSERT INTO `device_heartbeat_record` VALUES (1512, 'B4BFE90CDBA1', 16620, '2026-10-21 16:31:04.998', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571464989, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16620, \"rssi\": -65}}', '2026-10-21 16:31:04.998');
INSERT INTO `device_heartbeat_record` VALUES (1513, 'B4BFE90CDBA1', 16650, '2026-10-21 16:31:35.006', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571494997, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16650, \"rssi\": -65}}', '2026-10-21 16:31:35.006');
INSERT INTO `device_heartbeat_record` VALUES (1514, 'B4BFE90CDBA1', 16680, '2026-10-21 16:32:05.014', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571525000, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16680, \"rssi\": -65}}', '2026-10-21 16:32:05.014');
INSERT INTO `device_heartbeat_record` VALUES (1515, 'B4BFE90CDBA1', 16710, '2026-10-21 16:32:35.028', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571555015, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16710, \"rssi\": -65}}', '2026-10-21 16:32:35.028');
INSERT INTO `device_heartbeat_record` VALUES (1516, 'B4BFE90CDBA1', 16740, '2026-10-21 16:33:05.036', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571585024, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16740, \"rssi\": -65}}', '2026-10-21 16:33:05.037');
INSERT INTO `device_heartbeat_record` VALUES (1517, 'B4BFE90CDBA1', 16770, '2026-10-21 16:33:35.042', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571615032, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16770, \"rssi\": -65}}', '2026-10-21 16:33:35.042');
INSERT INTO `device_heartbeat_record` VALUES (1518, 'B4BFE90CDBA1', 16800, '2026-10-21 16:34:05.051', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571645041, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16800, \"rssi\": -65}}', '2026-10-21 16:34:05.051');
INSERT INTO `device_heartbeat_record` VALUES (1519, 'B4BFE90CDBA1', 16830, '2026-10-21 16:34:35.058', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571675046, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16830, \"rssi\": -65}}', '2026-10-21 16:34:35.059');
INSERT INTO `device_heartbeat_record` VALUES (1520, 'B4BFE90CDBA1', 16860, '2026-10-21 16:35:05.063', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571705049, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16860, \"rssi\": -65}}', '2026-10-21 16:35:05.064');
INSERT INTO `device_heartbeat_record` VALUES (1521, 'B4BFE90CDBA1', 16890, '2026-10-21 16:35:35.074', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571735055, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16890, \"rssi\": -65}}', '2026-10-21 16:35:35.075');
INSERT INTO `device_heartbeat_record` VALUES (1522, 'B4BFE90CDBA1', 16920, '2026-10-21 16:36:05.075', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571765062, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16920, \"rssi\": -65}}', '2026-10-21 16:36:05.075');
INSERT INTO `device_heartbeat_record` VALUES (1523, 'B4BFE90CDBA1', 16950, '2026-10-21 16:36:35.082', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571795069, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16950, \"rssi\": -65}}', '2026-10-21 16:36:35.083');
INSERT INTO `device_heartbeat_record` VALUES (1524, 'B4BFE90CDBA1', 16980, '2026-10-21 16:37:05.088', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571825076, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 16980, \"rssi\": -65}}', '2026-10-21 16:37:05.089');
INSERT INTO `device_heartbeat_record` VALUES (1525, 'B4BFE90CDBA1', 17010, '2026-10-21 16:37:35.104', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571855091, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17010, \"rssi\": -65}}', '2026-10-21 16:37:35.104');
INSERT INTO `device_heartbeat_record` VALUES (1526, 'B4BFE90CDBA1', 17040, '2026-10-21 16:38:05.105', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571885095, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17040, \"rssi\": -65}}', '2026-10-21 16:38:05.105');
INSERT INTO `device_heartbeat_record` VALUES (1527, 'B4BFE90CDBA1', 17070, '2026-10-21 16:38:35.117', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571915108, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17070, \"rssi\": -65}}', '2026-10-21 16:38:35.117');
INSERT INTO `device_heartbeat_record` VALUES (1528, 'B4BFE90CDBA1', 17100, '2026-10-21 16:39:05.125', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571945118, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17100, \"rssi\": -65}}', '2026-10-21 16:39:05.125');
INSERT INTO `device_heartbeat_record` VALUES (1529, 'B4BFE90CDBA1', 17130, '2026-10-21 16:39:35.136', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792571975122, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17130, \"rssi\": -65}}', '2026-10-21 16:39:35.136');
INSERT INTO `device_heartbeat_record` VALUES (1530, 'B4BFE90CDBA1', 17160, '2026-10-21 16:40:05.147', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572005138, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17160, \"rssi\": -65}}', '2026-10-21 16:40:05.147');
INSERT INTO `device_heartbeat_record` VALUES (1531, 'B4BFE90CDBA1', 17190, '2026-10-21 16:40:35.149', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572035141, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17190, \"rssi\": -65}}', '2026-10-21 16:40:35.150');
INSERT INTO `device_heartbeat_record` VALUES (1532, 'B4BFE90CDBA1', 17220, '2026-10-21 16:41:05.150', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572065142, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17220, \"rssi\": -65}}', '2026-10-21 16:41:05.151');
INSERT INTO `device_heartbeat_record` VALUES (1533, 'B4BFE90CDBA1', 17250, '2026-10-21 16:41:35.173', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572095157, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17250, \"rssi\": -65}}', '2026-10-21 16:41:35.174');
INSERT INTO `device_heartbeat_record` VALUES (1534, 'B4BFE90CDBA1', 17280, '2026-10-21 16:42:05.171', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572125162, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17280, \"rssi\": -65}}', '2026-10-21 16:42:05.171');
INSERT INTO `device_heartbeat_record` VALUES (1535, 'B4BFE90CDBA1', 17310, '2026-10-21 16:42:35.186', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572155174, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17310, \"rssi\": -65}}', '2026-10-21 16:42:35.186');
INSERT INTO `device_heartbeat_record` VALUES (1536, 'B4BFE90CDBA1', 17340, '2026-10-21 16:43:05.186', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572185179, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17340, \"rssi\": -65}}', '2026-10-21 16:43:05.186');
INSERT INTO `device_heartbeat_record` VALUES (1537, 'B4BFE90CDBA1', 17370, '2026-10-21 16:43:35.194', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572215182, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17370, \"rssi\": -65}}', '2026-10-21 16:43:35.194');
INSERT INTO `device_heartbeat_record` VALUES (1538, 'B4BFE90CDBA1', 17400, '2026-10-21 16:44:05.197', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572245186, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17400, \"rssi\": -65}}', '2026-10-21 16:44:05.197');
INSERT INTO `device_heartbeat_record` VALUES (1539, 'B4BFE90CDBA1', 17430, '2026-10-21 16:44:35.200', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572275191, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17430, \"rssi\": -65}}', '2026-10-21 16:44:35.200');
INSERT INTO `device_heartbeat_record` VALUES (1540, 'B4BFE90CDBA1', 17460, '2026-10-21 16:45:05.207', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572305198, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17460, \"rssi\": -65}}', '2026-10-21 16:45:05.207');
INSERT INTO `device_heartbeat_record` VALUES (1541, 'B4BFE90CDBA1', 17490, '2026-10-21 16:45:35.214', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572335204, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17490, \"rssi\": -65}}', '2026-10-21 16:45:35.215');
INSERT INTO `device_heartbeat_record` VALUES (1542, 'B4BFE90CDBA1', 17520, '2026-10-21 16:46:05.226', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572365216, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17520, \"rssi\": -65}}', '2026-10-21 16:46:05.226');
INSERT INTO `device_heartbeat_record` VALUES (1543, 'B4BFE90CDBA1', 17550, '2026-10-21 16:46:35.242', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572395231, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17550, \"rssi\": -65}}', '2026-10-21 16:46:35.242');
INSERT INTO `device_heartbeat_record` VALUES (1544, 'B4BFE90CDBA1', 17580, '2026-10-21 16:47:05.243', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572425233, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17580, \"rssi\": -65}}', '2026-10-21 16:47:05.244');
INSERT INTO `device_heartbeat_record` VALUES (1545, 'B4BFE90CDBA1', 17610, '2026-10-21 16:47:35.246', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572455235, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17610, \"rssi\": -65}}', '2026-10-21 16:47:35.246');
INSERT INTO `device_heartbeat_record` VALUES (1546, 'B4BFE90CDBA1', 17640, '2026-10-21 16:48:05.257', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572485248, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17640, \"rssi\": -65}}', '2026-10-21 16:48:05.258');
INSERT INTO `device_heartbeat_record` VALUES (1547, 'B4BFE90CDBA1', 17670, '2026-10-21 16:48:35.272', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572515260, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17670, \"rssi\": -65}}', '2026-10-21 16:48:35.272');
INSERT INTO `device_heartbeat_record` VALUES (1548, 'B4BFE90CDBA1', 17700, '2026-10-21 16:49:05.279', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572545263, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17700, \"rssi\": -65}}', '2026-10-21 16:49:05.280');
INSERT INTO `device_heartbeat_record` VALUES (1549, 'B4BFE90CDBA1', 17730, '2026-10-21 16:49:35.292', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572575279, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17730, \"rssi\": -65}}', '2026-10-21 16:49:35.293');
INSERT INTO `device_heartbeat_record` VALUES (1550, 'B4BFE90CDBA1', 17760, '2026-10-21 16:50:05.307', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572605295, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17760, \"rssi\": -65}}', '2026-10-21 16:50:05.307');
INSERT INTO `device_heartbeat_record` VALUES (1551, 'B4BFE90CDBA1', 17790, '2026-10-21 16:50:35.307', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572635299, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17790, \"rssi\": -65}}', '2026-10-21 16:50:35.308');
INSERT INTO `device_heartbeat_record` VALUES (1552, 'B4BFE90CDBA1', 17820, '2026-10-21 16:51:05.319', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572665308, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17820, \"rssi\": -65}}', '2026-10-21 16:51:05.319');
INSERT INTO `device_heartbeat_record` VALUES (1553, 'B4BFE90CDBA1', 17850, '2026-10-21 16:51:35.328', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572695321, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17850, \"rssi\": -65}}', '2026-10-21 16:51:35.328');
INSERT INTO `device_heartbeat_record` VALUES (1554, 'B4BFE90CDBA1', 17880, '2026-10-21 16:52:05.334', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572725325, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17880, \"rssi\": -65}}', '2026-10-21 16:52:05.335');
INSERT INTO `device_heartbeat_record` VALUES (1555, 'B4BFE90CDBA1', 17910, '2026-10-21 16:52:35.377', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572755334, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17910, \"rssi\": -65}}', '2026-10-21 16:52:35.377');
INSERT INTO `device_heartbeat_record` VALUES (1556, 'B4BFE90CDBA1', 17940, '2026-10-21 16:53:05.352', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572785340, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17940, \"rssi\": -65}}', '2026-10-21 16:53:05.352');
INSERT INTO `device_heartbeat_record` VALUES (1557, 'B4BFE90CDBA1', 17970, '2026-10-21 16:53:35.357', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572815349, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 17970, \"rssi\": -65}}', '2026-10-21 16:53:35.357');
INSERT INTO `device_heartbeat_record` VALUES (1558, 'B4BFE90CDBA1', 18000, '2026-10-21 16:54:05.365', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572845353, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18000, \"rssi\": -65}}', '2026-10-21 16:54:05.365');
INSERT INTO `device_heartbeat_record` VALUES (1559, 'B4BFE90CDBA1', 18030, '2026-10-21 16:54:35.381', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572875366, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18030, \"rssi\": -65}}', '2026-10-21 16:54:35.382');
INSERT INTO `device_heartbeat_record` VALUES (1560, 'B4BFE90CDBA1', 18060, '2026-10-21 16:55:05.381', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572905374, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18060, \"rssi\": -65}}', '2026-10-21 16:55:05.381');
INSERT INTO `device_heartbeat_record` VALUES (1561, 'B4BFE90CDBA1', 18090, '2026-10-21 16:55:35.402', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572935390, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18090, \"rssi\": -65}}', '2026-10-21 16:55:35.402');
INSERT INTO `device_heartbeat_record` VALUES (1562, 'B4BFE90CDBA1', 18120, '2026-10-21 16:56:05.406', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572965397, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18120, \"rssi\": -65}}', '2026-10-21 16:56:05.406');
INSERT INTO `device_heartbeat_record` VALUES (1563, 'B4BFE90CDBA1', 18150, '2026-10-21 16:56:35.417', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792572995406, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18150, \"rssi\": -65}}', '2026-10-21 16:56:35.417');
INSERT INTO `device_heartbeat_record` VALUES (1564, 'B4BFE90CDBA1', 18180, '2026-10-21 16:57:05.415', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573025407, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18180, \"rssi\": -65}}', '2026-10-21 16:57:05.416');
INSERT INTO `device_heartbeat_record` VALUES (1565, 'B4BFE90CDBA1', 18210, '2026-10-21 16:57:35.426', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573055419, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18210, \"rssi\": -65}}', '2026-10-21 16:57:35.426');
INSERT INTO `device_heartbeat_record` VALUES (1566, 'B4BFE90CDBA1', 18240, '2026-10-21 16:58:05.433', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573085419, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18240, \"rssi\": -65}}', '2026-10-21 16:58:05.433');
INSERT INTO `device_heartbeat_record` VALUES (1567, 'B4BFE90CDBA1', 18270, '2026-10-21 16:58:35.427', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573115421, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18270, \"rssi\": -65}}', '2026-10-21 16:58:35.427');
INSERT INTO `device_heartbeat_record` VALUES (1568, 'B4BFE90CDBA1', 18300, '2026-10-21 16:59:05.430', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573145422, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18300, \"rssi\": -65}}', '2026-10-21 16:59:05.430');
INSERT INTO `device_heartbeat_record` VALUES (1569, 'B4BFE90CDBA1', 18330, '2026-10-21 16:59:35.447', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573175433, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18330, \"rssi\": -65}}', '2026-10-21 16:59:35.447');
INSERT INTO `device_heartbeat_record` VALUES (1570, 'B4BFE90CDBA1', 18360, '2026-10-21 17:00:05.457', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573205442, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18360, \"rssi\": -65}}', '2026-10-21 17:00:05.457');
INSERT INTO `device_heartbeat_record` VALUES (1571, 'B4BFE90CDBA1', 18390, '2026-10-21 17:00:35.463', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573235452, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18390, \"rssi\": -65}}', '2026-10-21 17:00:35.463');
INSERT INTO `device_heartbeat_record` VALUES (1572, 'B4BFE90CDBA1', 18420, '2026-10-21 17:01:05.474', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573265468, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18420, \"rssi\": -65}}', '2026-10-21 17:01:05.474');
INSERT INTO `device_heartbeat_record` VALUES (1573, 'B4BFE90CDBA1', 18450, '2026-10-21 17:01:35.511', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573295480, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18450, \"rssi\": -65}}', '2026-10-21 17:01:35.511');
INSERT INTO `device_heartbeat_record` VALUES (1574, 'B4BFE90CDBA1', 18480, '2026-10-21 17:02:05.503', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573325494, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18480, \"rssi\": -65}}', '2026-10-21 17:02:05.504');
INSERT INTO `device_heartbeat_record` VALUES (1575, 'B4BFE90CDBA1', 18510, '2026-10-21 17:02:35.511', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573355505, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18510, \"rssi\": -65}}', '2026-10-21 17:02:35.511');
INSERT INTO `device_heartbeat_record` VALUES (1576, 'B4BFE90CDBA1', 18540, '2026-10-21 17:03:05.529', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573385517, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18540, \"rssi\": -65}}', '2026-10-21 17:03:05.529');
INSERT INTO `device_heartbeat_record` VALUES (1577, 'B4BFE90CDBA1', 18570, '2026-10-21 17:03:35.532', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573415522, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18570, \"rssi\": -65}}', '2026-10-21 17:03:35.532');
INSERT INTO `device_heartbeat_record` VALUES (1578, 'B4BFE90CDBA1', 18600, '2026-10-21 17:04:05.550', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573445529, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18600, \"rssi\": -65}}', '2026-10-21 17:04:05.551');
INSERT INTO `device_heartbeat_record` VALUES (1579, 'B4BFE90CDBA1', 18630, '2026-10-21 17:04:35.549', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573475533, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18630, \"rssi\": -65}}', '2026-10-21 17:04:35.551');
INSERT INTO `device_heartbeat_record` VALUES (1580, 'B4BFE90CDBA1', 18660, '2026-10-21 17:05:05.553', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573505546, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18660, \"rssi\": -65}}', '2026-10-21 17:05:05.554');
INSERT INTO `device_heartbeat_record` VALUES (1581, 'B4BFE90CDBA1', 18690, '2026-10-21 17:05:35.567', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573535561, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18690, \"rssi\": -65}}', '2026-10-21 17:05:35.567');
INSERT INTO `device_heartbeat_record` VALUES (1582, 'B4BFE90CDBA1', 18720, '2026-10-21 17:06:05.633', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573565577, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18720, \"rssi\": -65}}', '2026-10-21 17:06:05.633');
INSERT INTO `device_heartbeat_record` VALUES (1583, 'B4BFE90CDBA1', 18750, '2026-10-21 17:06:35.603', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573595589, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18750, \"rssi\": -65}}', '2026-10-21 17:06:35.604');
INSERT INTO `device_heartbeat_record` VALUES (1584, 'B4BFE90CDBA1', 18780, '2026-10-21 17:07:05.624', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573625605, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18780, \"rssi\": -65}}', '2026-10-21 17:07:05.625');
INSERT INTO `device_heartbeat_record` VALUES (1585, 'B4BFE90CDBA1', 18810, '2026-10-21 17:07:35.623', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573655613, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18810, \"rssi\": -65}}', '2026-10-21 17:07:35.624');
INSERT INTO `device_heartbeat_record` VALUES (1586, 'B4BFE90CDBA1', 18840, '2026-10-21 17:08:05.627', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573685621, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18840, \"rssi\": -65}}', '2026-10-21 17:08:05.627');
INSERT INTO `device_heartbeat_record` VALUES (1587, 'B4BFE90CDBA1', 18900, '2026-10-21 17:09:05.680', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573745635, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18900, \"rssi\": -65}}', '2026-10-21 17:09:05.683');
INSERT INTO `device_heartbeat_record` VALUES (1588, 'B4BFE90CDBA1', 18930, '2026-10-21 17:09:35.698', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573775644, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18930, \"rssi\": -65}}', '2026-10-21 17:09:35.698');
INSERT INTO `device_heartbeat_record` VALUES (1589, 'B4BFE90CDBA1', 18960, '2026-10-21 17:10:05.680', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573805661, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18960, \"rssi\": -65}}', '2026-10-21 17:10:05.681');
INSERT INTO `device_heartbeat_record` VALUES (1590, 'B4BFE90CDBA1', 18990, '2026-10-21 17:10:35.682', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573835672, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 18990, \"rssi\": -65}}', '2026-10-21 17:10:35.682');
INSERT INTO `device_heartbeat_record` VALUES (1591, 'B4BFE90CDBA1', 19020, '2026-10-21 17:11:05.687', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573865679, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 19020, \"rssi\": -65}}', '2026-10-21 17:11:05.687');
INSERT INTO `device_heartbeat_record` VALUES (1592, 'B4BFE90CDBA1', 19050, '2026-10-21 17:11:35.702', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792573895693, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 19050, \"rssi\": -65}}', '2026-10-21 17:11:35.702');
INSERT INTO `device_heartbeat_record` VALUES (1593, 'B4BFE90CDBA1', 19710, '2026-10-21 17:22:35.916', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574555900, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 19710, \"rssi\": -65}}', '2026-10-21 17:22:35.919');
INSERT INTO `device_heartbeat_record` VALUES (1594, 'B4BFE90CDBA1', 19740, '2026-10-21 17:23:05.916', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574585906, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 19740, \"rssi\": -65}}', '2026-10-21 17:23:05.917');
INSERT INTO `device_heartbeat_record` VALUES (1595, 'B4BFE90CDBA1', 19770, '2026-10-21 17:23:35.946', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574615921, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 19770, \"rssi\": -65}}', '2026-10-21 17:23:35.947');
INSERT INTO `device_heartbeat_record` VALUES (1596, 'B4BFE90CDBA1', 19800, '2026-10-21 17:24:05.948', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574645928, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 19800, \"rssi\": -65}}', '2026-10-21 17:24:05.949');
INSERT INTO `device_heartbeat_record` VALUES (1597, 'B4BFE90CDBA1', 19830, '2026-10-21 17:24:35.949', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574675937, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 19830, \"rssi\": -65}}', '2026-10-21 17:24:35.949');
INSERT INTO `device_heartbeat_record` VALUES (1598, 'B4BFE90CDBA1', 19860, '2026-10-21 17:25:05.963', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574705942, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 19860, \"rssi\": -65}}', '2026-10-21 17:25:05.964');
INSERT INTO `device_heartbeat_record` VALUES (1599, 'B4BFE90CDBA1', 19890, '2026-10-21 17:25:35.964', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574735956, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 19890, \"rssi\": -65}}', '2026-10-21 17:25:35.964');
INSERT INTO `device_heartbeat_record` VALUES (1600, 'B4BFE90CDBA1', 19920, '2026-10-21 17:26:05.979', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574765959, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 19920, \"rssi\": -65}}', '2026-10-21 17:26:05.979');
INSERT INTO `device_heartbeat_record` VALUES (1601, 'B4BFE90CDBA1', 19950, '2026-10-21 17:26:35.990', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574795970, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 19950, \"rssi\": -65}}', '2026-10-21 17:26:35.991');
INSERT INTO `device_heartbeat_record` VALUES (1602, 'B4BFE90CDBA1', 19980, '2026-10-21 17:27:05.994', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574825974, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 19980, \"rssi\": -65}}', '2026-10-21 17:27:05.995');
INSERT INTO `device_heartbeat_record` VALUES (1603, 'B4BFE90CDBA1', 20010, '2026-10-21 17:27:36.001', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574855990, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20010, \"rssi\": -65}}', '2026-10-21 17:27:36.001');
INSERT INTO `device_heartbeat_record` VALUES (1604, 'B4BFE90CDBA1', 20040, '2026-10-21 17:28:06.001', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574885993, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20040, \"rssi\": -65}}', '2026-10-21 17:28:06.003');
INSERT INTO `device_heartbeat_record` VALUES (1605, 'B4BFE90CDBA1', 20070, '2026-10-21 17:28:36.037', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574915998, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20070, \"rssi\": -65}}', '2026-10-21 17:28:36.038');
INSERT INTO `device_heartbeat_record` VALUES (1606, 'B4BFE90CDBA1', 20100, '2026-10-21 17:29:06.016', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574946009, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20100, \"rssi\": -65}}', '2026-10-21 17:29:06.018');
INSERT INTO `device_heartbeat_record` VALUES (1607, 'B4BFE90CDBA1', 20130, '2026-10-21 17:29:36.019', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792574976011, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20130, \"rssi\": -65}}', '2026-10-21 17:29:36.020');
INSERT INTO `device_heartbeat_record` VALUES (1608, 'B4BFE90CDBA1', 20190, '2026-10-21 17:30:36.045', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575036036, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20190, \"rssi\": -65}}', '2026-10-21 17:30:36.046');
INSERT INTO `device_heartbeat_record` VALUES (1609, 'B4BFE90CDBA1', 20220, '2026-10-21 17:31:06.063', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575066047, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20220, \"rssi\": -65}}', '2026-10-21 17:31:06.064');
INSERT INTO `device_heartbeat_record` VALUES (1610, 'B4BFE90CDBA1', 20250, '2026-10-21 17:31:36.077', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575096061, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20250, \"rssi\": -65}}', '2026-10-21 17:31:36.078');
INSERT INTO `device_heartbeat_record` VALUES (1611, 'B4BFE90CDBA1', 20280, '2026-10-21 17:32:06.086', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575126065, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20280, \"rssi\": -65}}', '2026-10-21 17:32:06.088');
INSERT INTO `device_heartbeat_record` VALUES (1612, 'B4BFE90CDBA1', 20310, '2026-10-21 17:32:36.100', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575156076, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20310, \"rssi\": -65}}', '2026-10-21 17:32:36.101');
INSERT INTO `device_heartbeat_record` VALUES (1613, 'B4BFE90CDBA1', 20340, '2026-10-21 17:33:06.102', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575186082, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20340, \"rssi\": -65}}', '2026-10-21 17:33:06.103');
INSERT INTO `device_heartbeat_record` VALUES (1614, 'B4BFE90CDBA1', 20370, '2026-10-21 17:33:36.113', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575216090, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20370, \"rssi\": -65}}', '2026-10-21 17:33:36.113');
INSERT INTO `device_heartbeat_record` VALUES (1615, 'B4BFE90CDBA1', 20400, '2026-10-21 17:34:06.119', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575246095, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20400, \"rssi\": -65}}', '2026-10-21 17:34:06.120');
INSERT INTO `device_heartbeat_record` VALUES (1616, 'B4BFE90CDBA1', 20430, '2026-10-21 17:34:36.127', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575276111, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20430, \"rssi\": -65}}', '2026-10-21 17:34:36.128');
INSERT INTO `device_heartbeat_record` VALUES (1617, 'B4BFE90CDBA1', 20460, '2026-10-21 17:35:06.147', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575306125, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20460, \"rssi\": -65}}', '2026-10-21 17:35:06.148');
INSERT INTO `device_heartbeat_record` VALUES (1618, 'B4BFE90CDBA1', 20490, '2026-10-21 17:35:36.146', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575336137, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20490, \"rssi\": -65}}', '2026-10-21 17:35:36.147');
INSERT INTO `device_heartbeat_record` VALUES (1619, 'B4BFE90CDBA1', 20520, '2026-10-21 17:36:06.158', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575366144, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20520, \"rssi\": -65}}', '2026-10-21 17:36:06.158');
INSERT INTO `device_heartbeat_record` VALUES (1620, 'B4BFE90CDBA1', 20550, '2026-10-21 17:36:36.167', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575396147, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20550, \"rssi\": -65}}', '2026-10-21 17:36:36.168');
INSERT INTO `device_heartbeat_record` VALUES (1621, 'B4BFE90CDBA1', 20580, '2026-10-21 17:37:06.180', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575426161, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20580, \"rssi\": -65}}', '2026-10-21 17:37:06.181');
INSERT INTO `device_heartbeat_record` VALUES (1622, 'B4BFE90CDBA1', 20610, '2026-10-21 17:37:36.197', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575456178, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20610, \"rssi\": -65}}', '2026-10-21 17:37:36.198');
INSERT INTO `device_heartbeat_record` VALUES (1623, 'B4BFE90CDBA1', 20670, '2026-10-21 17:38:36.231', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575516200, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20670, \"rssi\": -65}}', '2026-10-21 17:38:36.236');
INSERT INTO `device_heartbeat_record` VALUES (1624, 'B4BFE90CDBA1', 20730, '2026-10-21 17:39:36.230', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575576206, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20730, \"rssi\": -65}}', '2026-10-21 17:39:36.233');
INSERT INTO `device_heartbeat_record` VALUES (1625, 'B4BFE90CDBA1', 20760, '2026-10-21 17:40:06.237', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575606218, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20760, \"rssi\": -65}}', '2026-10-21 17:40:06.239');
INSERT INTO `device_heartbeat_record` VALUES (1626, 'B4BFE90CDBA1', 20790, '2026-10-21 17:40:36.247', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575636225, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20790, \"rssi\": -65}}', '2026-10-21 17:40:36.248');
INSERT INTO `device_heartbeat_record` VALUES (1627, 'B4BFE90CDBA1', 20820, '2026-10-21 17:41:06.246', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575666233, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20820, \"rssi\": -65}}', '2026-10-21 17:41:06.246');
INSERT INTO `device_heartbeat_record` VALUES (1628, 'B4BFE90CDBA1', 20850, '2026-10-21 17:41:36.280', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575696250, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20850, \"rssi\": -65}}', '2026-10-21 17:41:36.281');
INSERT INTO `device_heartbeat_record` VALUES (1629, 'B4BFE90CDBA1', 20880, '2026-10-21 17:42:06.269', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575726258, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20880, \"rssi\": -65}}', '2026-10-21 17:42:06.269');
INSERT INTO `device_heartbeat_record` VALUES (1630, 'B4BFE90CDBA1', 20910, '2026-10-21 17:42:36.290', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575756272, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20910, \"rssi\": -65}}', '2026-10-21 17:42:36.290');
INSERT INTO `device_heartbeat_record` VALUES (1631, 'B4BFE90CDBA1', 20940, '2026-10-21 17:43:06.297', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575786287, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20940, \"rssi\": -65}}', '2026-10-21 17:43:06.298');
INSERT INTO `device_heartbeat_record` VALUES (1632, 'B4BFE90CDBA1', 20970, '2026-10-21 17:43:36.332', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575816300, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 20970, \"rssi\": -65}}', '2026-10-21 17:43:36.337');
INSERT INTO `device_heartbeat_record` VALUES (1633, 'B4BFE90CDBA1', 21000, '2026-10-21 17:44:06.320', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575846314, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21000, \"rssi\": -65}}', '2026-10-21 17:44:06.321');
INSERT INTO `device_heartbeat_record` VALUES (1634, 'B4BFE90CDBA1', 21030, '2026-10-21 17:44:36.355', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575876327, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21030, \"rssi\": -65}}', '2026-10-21 17:44:36.356');
INSERT INTO `device_heartbeat_record` VALUES (1635, 'B4BFE90CDBA1', 21060, '2026-10-21 17:45:06.345', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575906336, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21060, \"rssi\": -65}}', '2026-10-21 17:45:06.345');
INSERT INTO `device_heartbeat_record` VALUES (1636, 'B4BFE90CDBA1', 21090, '2026-10-21 17:45:36.361', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575936350, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21090, \"rssi\": -65}}', '2026-10-21 17:45:36.363');
INSERT INTO `device_heartbeat_record` VALUES (1637, 'B4BFE90CDBA1', 21120, '2026-10-21 17:46:06.371', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575966355, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21120, \"rssi\": -65}}', '2026-10-21 17:46:06.372');
INSERT INTO `device_heartbeat_record` VALUES (1638, 'B4BFE90CDBA1', 21150, '2026-10-21 17:46:36.375', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792575996362, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21150, \"rssi\": -65}}', '2026-10-21 17:46:36.375');
INSERT INTO `device_heartbeat_record` VALUES (1639, 'B4BFE90CDBA1', 21180, '2026-10-21 17:47:06.392', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792576026372, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21180, \"rssi\": -65}}', '2026-10-21 17:47:06.393');
INSERT INTO `device_heartbeat_record` VALUES (1640, 'B4BFE90CDBA1', 21210, '2026-10-21 17:47:36.390', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792576056375, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21210, \"rssi\": -65}}', '2026-10-21 17:47:36.391');
INSERT INTO `device_heartbeat_record` VALUES (1641, 'B4BFE90CDBA1', 21240, '2026-10-21 17:48:06.396', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792576086381, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21240, \"rssi\": -65}}', '2026-10-21 17:48:06.396');
INSERT INTO `device_heartbeat_record` VALUES (1642, 'B4BFE90CDBA1', 21270, '2026-10-21 17:48:36.398', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792576116388, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21270, \"rssi\": -65}}', '2026-10-21 17:48:36.398');
INSERT INTO `device_heartbeat_record` VALUES (1643, 'B4BFE90CDBA1', 21300, '2026-10-21 17:49:06.408', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792576146395, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21300, \"rssi\": -65}}', '2026-10-21 17:49:06.409');
INSERT INTO `device_heartbeat_record` VALUES (1644, 'B4BFE90CDBA1', 21330, '2026-10-21 17:49:36.435', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792576176410, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21330, \"rssi\": -65}}', '2026-10-21 17:49:36.437');
INSERT INTO `device_heartbeat_record` VALUES (1645, 'B4BFE90CDBA1', 21360, '2026-10-21 17:50:06.437', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792576206426, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21360, \"rssi\": -65}}', '2026-10-21 17:50:06.438');
INSERT INTO `device_heartbeat_record` VALUES (1646, 'B4BFE90CDBA1', 21390, '2026-10-21 17:50:36.470', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792576236442, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21390, \"rssi\": -65}}', '2026-10-21 17:50:36.471');

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
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_info
-- ----------------------------
INSERT INTO `device_info` VALUES (17, 'B4BFE90CDBA1', NULL, 'SmartHome-v1', '1.0.29', '-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE8zar+dQEYR6DJufqcRGDjC0EcsQd\ntN/H04gMIANmeQZhhhyzu4Xu8PTsS8Li8ilp9GgHSBX+/bOgQrGLpVEhuw==\n-----END PUBLIC KEY-----\n', NULL, NULL, 0, 'heartbeat_timeout', '2026-10-21 17:46:46.329', '2026-10-22 08:52:36.848', '2026-10-21 17:50:36.457', 21390, '{\"led\": 3, \"mos\": 8, \"servo\": 2}', NULL, NULL, NULL, NULL, NULL, NULL, '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1792576236442, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 21390, \"rssi\": -65}}', '2026-10-20 17:51:33.769', '2026-10-22 08:52:36.848');

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
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '统一MQTT认证账号表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_mqtt_auth
-- ----------------------------
INSERT INTO `device_mqtt_auth` VALUES (1, 'PROVISION_USER', 'f43c57babf15d80cd5e961e6dee8b1795dcff8805ca9a4aabc2d048d2499f172', '767f13ac5e1c4dbdddb7f4c288bb085b', 0, 1, NULL, '2026-10-15 18:36:10.738', '2026-10-17 16:20:53.331');
INSERT INTO `device_mqtt_auth` VALUES (2, 'java-backend', 'fae340eae69a2dfad416154a5d47474ce546d2c2ba9bc57fa8c0b833a6886aff', '667f13ac5e1c4dbdddb7f4c288bb0856', 1, 1, NULL, '2026-10-15 18:36:43.369', '2026-10-21 11:50:01.894');
INSERT INTO `device_mqtt_auth` VALUES (12, 'B4BFE90CDBA1', 'ac147b441405e9f2fe7baa89497a93e6a43f1e638af0ec2f4f8730f6b9c5ab31', '8d8a2ce38515681eefe1864c044ba353', 0, 1, 'B4BFE90CDBA1', '2026-10-20 17:14:56.940', '2026-10-20 17:51:33.862');

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
INSERT INTO `device_whitelist` VALUES (1, 'B4BFE90CDBA1', '2610171622', 1, NULL, '2026-10-17 16:22:22.910', '2026-10-17 16:22:22.910');

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
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_login_log
-- ----------------------------
INSERT INTO `sys_login_log` VALUES (1, 'public1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-26 16:55:48.565');
INSERT INTO `sys_login_log` VALUES (2, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 16:56:11.482');
INSERT INTO `sys_login_log` VALUES (3, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-26 16:56:26.942');
INSERT INTO `sys_login_log` VALUES (4, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 16:56:37.634');
INSERT INTO `sys_login_log` VALUES (5, 'babo', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-26 16:57:16.935');
INSERT INTO `sys_login_log` VALUES (6, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-26 16:57:31.991');
INSERT INTO `sys_login_log` VALUES (7, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-26 16:57:32.699');
INSERT INTO `sys_login_log` VALUES (8, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-26 16:57:33.281');
INSERT INTO `sys_login_log` VALUES (9, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-26 16:57:33.895');
INSERT INTO `sys_login_log` VALUES (10, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-26 16:57:34.473');
INSERT INTO `sys_login_log` VALUES (11, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定，请稍后再试', '2026-10-26 16:57:34.746');
INSERT INTO `sys_login_log` VALUES (12, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定，请稍后再试', '2026-10-26 16:57:44.786');
INSERT INTO `sys_login_log` VALUES (13, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定，请稍后再试', '2026-10-26 16:58:32.080');
INSERT INTO `sys_login_log` VALUES (14, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已禁用', '2026-10-26 16:58:44.031');
INSERT INTO `sys_login_log` VALUES (15, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 17:16:40.969');
INSERT INTO `sys_login_log` VALUES (16, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 17:22:47.817');
INSERT INTO `sys_login_log` VALUES (17, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 17:24:44.712');
INSERT INTO `sys_login_log` VALUES (18, 'tom123', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 17:25:35.367');
INSERT INTO `sys_login_log` VALUES (19, 'tom123', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 17:27:28.119');
INSERT INTO `sys_login_log` VALUES (20, 'tom123', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 17:29:38.381');
INSERT INTO `sys_login_log` VALUES (21, 'tom123', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 17:30:21.640');
INSERT INTO `sys_login_log` VALUES (22, 'tom123', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 17:32:14.886');
INSERT INTO `sys_login_log` VALUES (23, 'tom123', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 17:40:46.453');
INSERT INTO `sys_login_log` VALUES (24, 'tom123', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 17:41:58.326');
INSERT INTO `sys_login_log` VALUES (25, 'tom123', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 17:47:37.622');
INSERT INTO `sys_login_log` VALUES (26, 'tom123', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-26 17:49:28.473');

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
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_permission
-- ----------------------------
INSERT INTO `sys_permission` VALUES (13, 'device:list', '查询设备列表', 'API', 'device', 'read', '获取设备分页列表', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (14, 'device:read', '查看设备详情', 'API', 'device', 'read', '获取单台设备详细信息', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (15, 'device:create', '添加设备', 'API', 'device', 'create', '录入新设备', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (16, 'device:update', '修改设备', 'API', 'device', 'update', '修改设备名称、位置等信息', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (17, 'device:delete', '删除设备', 'API', 'device', 'delete', '移除设备', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (18, 'device:bind', '绑定设备', 'API', 'device', 'update', '用户绑定设备', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (19, 'device:unbind', '解绑设备', 'API', 'device', 'update', '用户解绑设备', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (20, 'command:send', '下发指令', 'API', 'command', 'create', '向设备下发控制指令(mos/led/servo等)', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (21, 'firmware:list', '查询固件', 'API', 'firmware', 'read', '查看固件版本列表', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (22, 'firmware:upload', '上传固件', 'API', 'firmware', 'create', '上传新的固件包', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (23, 'ota:create', '发起OTA', 'API', 'ota', 'create', '发起固件升级任务', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (24, 'ota:cancel', '取消OTA', 'API', 'ota', 'update', '取消正在进行的升级任务', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (25, 'alert:list', '查询告警', 'API', 'alert', 'read', '查看告警记录', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (26, 'alert:handle', '处理告警', 'API', 'alert', 'update', '确认或解决告警', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (27, 'user:list', '查询用户', 'API', 'user', 'read', '查看用户列表', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (28, 'user:create', '创建用户', 'API', 'user', 'create', '管理员添加用户', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (29, 'user:update', '修改用户', 'API', 'user', 'update', '修改用户状态或角色', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (30, 'system:config', '系统配置', 'API', 'system', 'update', '修改系统级参数', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户Refresh Token表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_refresh_token
-- ----------------------------
INSERT INTO `sys_refresh_token` VALUES (1, 6, '94ca57cdac2f6e40b18b55fbd7651d1609cd44bc77e008b3d722c54bbc0654ed', 'web', '2026-11-02 17:16:40.865', 0, '2026-10-26 17:16:40.868', '2026-10-26 17:16:40.868');
INSERT INTO `sys_refresh_token` VALUES (2, 6, '242143e2441c410f9377e2adf787ead60666ffd0377cc9563eb15dd469745a9b', 'web', '2026-11-02 17:22:47.729', 0, '2026-10-26 17:22:47.733', '2026-10-26 17:22:47.733');
INSERT INTO `sys_refresh_token` VALUES (3, 5, '63c86c169546d4dcbbea92aa2987474f981877bf2442a3e589a4a8ac18e9c29f', 'web', '2026-11-02 17:24:44.703', 0, '2026-10-26 17:24:44.704', '2026-10-26 17:24:44.704');
INSERT INTO `sys_refresh_token` VALUES (4, 1, '4358d5811368131a7588522a5d5715501748a6410f838b221d3f877a6ff61ab7', 'web', '2026-11-02 17:25:35.358', 0, '2026-10-26 17:25:35.358', '2026-10-26 17:25:35.358');
INSERT INTO `sys_refresh_token` VALUES (5, 1, '682af4b65f09ab6e610dedb634a0efcda35de9bc6bb1be81aa9d2b3456a492c5', 'web', '2026-11-02 17:27:28.113', 1, '2026-10-26 17:27:28.113', '2026-10-26 17:28:48.449');
INSERT INTO `sys_refresh_token` VALUES (6, 1, '51744a53fe318ba9b8e78bd8bf76c5e2ebdd3041fa1ae3f794767369c9023745', 'web', '2026-11-02 17:29:38.371', 0, '2026-10-26 17:29:38.372', '2026-10-26 17:29:38.372');
INSERT INTO `sys_refresh_token` VALUES (7, 1, 'f07a3ccb4d2a3eeaff586823a0f84abbce1301d0185839a183f6b91ada1671a1', 'web', '2026-11-02 17:30:21.635', 1, '2026-10-26 17:30:21.635', '2026-10-26 17:30:59.296');
INSERT INTO `sys_refresh_token` VALUES (8, 1, '89c1f3f5f6ec777792c8f138c0726665a2f33a48821a3ca4033b3d5a96b8b59d', 'web', '2026-11-02 17:32:14.877', 1, '2026-10-26 17:32:14.877', '2026-10-26 17:32:49.278');
INSERT INTO `sys_refresh_token` VALUES (9, 1, '3cddd7257bc1849692f53fdaca27c1e2cc89cf146bc71e468876724981756c54', 'web', '2026-11-02 17:32:49.302', 0, '2026-10-26 17:32:49.302', '2026-10-26 17:32:49.302');
INSERT INTO `sys_refresh_token` VALUES (10, 1, 'e77949feb3cc315181ad4d97ae74f9b6e3a77ecb71f23ec71c9d02cbf412d906', 'web', '2026-11-02 17:40:46.446', 1, '2026-10-26 17:40:46.446', '2026-10-26 17:41:40.464');
INSERT INTO `sys_refresh_token` VALUES (11, 1, '4d21b71caa1210cc575500f3cd7ace337e85f3391c5dd0aff3dfaa6b9a11b963', 'web', '2026-11-02 17:41:58.318', 1, '2026-10-26 17:41:58.319', '2026-10-26 17:42:45.480');
INSERT INTO `sys_refresh_token` VALUES (12, 1, '528124e34542ff5ab2d15382c5cb3ae4538a69c27be319d8a55bef26bb8193db', 'web', '2026-11-02 17:42:45.487', 0, '2026-10-26 17:42:45.487', '2026-10-26 17:42:45.487');
INSERT INTO `sys_refresh_token` VALUES (13, 1, '6c2cefe23297b1ae046661ec895fe590d026992e329bfad473869722a447f96e', 'web', '2026-11-02 17:47:37.617', 1, '2026-10-26 17:47:37.617', '2026-10-26 17:48:26.874');
INSERT INTO `sys_refresh_token` VALUES (14, 1, 'c9b4ea1843a4d4313a9d081b1857d46ff1b2dd77ffe25002d32267b0798a25b6', 'web', '2026-11-02 17:48:26.879', 1, '2026-10-26 17:48:26.879', '2026-10-26 17:48:48.214');
INSERT INTO `sys_refresh_token` VALUES (15, 1, 'ad11b99aba2d0a940ec3a175c0aa4deff5beef5eb7b6f8840330f91612bdd4c1', 'web', '2026-11-02 17:48:48.222', 0, '2026-10-26 17:48:48.222', '2026-10-26 17:48:48.222');
INSERT INTO `sys_refresh_token` VALUES (16, 1, 'e7e08f9e228919c5611ea1b08a1e0799265086ec147162787cd086a4bcd91c8c', 'web', '2026-11-02 17:49:28.467', 1, '2026-10-26 17:49:28.467', '2026-10-26 17:49:51.624');

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
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (4, 'ADMIN', '超级管理员', '系统最高权限，管理所有设备、用户及系统配置', 1, 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_role` VALUES (5, 'OPS', '运维人员', '负责设备管理、固件升级、告警处理，不可修改系统核心配置', 1, 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_role` VALUES (6, 'USER', '普通用户', '终端用户，只能查看和控制自己绑定的设备', 1, 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户-角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_info
-- ----------------------------
INSERT INTO `sys_role_info` VALUES (1, 4, 6, '2026-10-26 16:06:00');
INSERT INTO `sys_role_info` VALUES (2, 5, 4, '2026-10-26 16:23:05');
INSERT INTO `sys_role_info` VALUES (3, 6, 6, '2026-10-26 16:26:56');

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
) ENGINE = InnoDB AUTO_INCREMENT = 72 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色-权限关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_permission
-- ----------------------------
INSERT INTO `sys_role_permission` VALUES (19, 4, 26, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (20, 4, 25, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (21, 4, 20, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (22, 4, 18, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (23, 4, 15, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (24, 4, 17, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (25, 4, 13, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (26, 4, 14, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (27, 4, 19, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (28, 4, 16, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (29, 4, 21, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (30, 4, 22, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (31, 4, 24, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (32, 4, 23, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (33, 4, 30, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (34, 4, 28, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (35, 4, 27, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (36, 4, 29, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (50, 5, 25, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (51, 5, 26, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (52, 5, 20, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (53, 5, 13, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (54, 5, 14, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (55, 5, 15, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (56, 5, 16, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (57, 5, 17, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (58, 5, 18, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (59, 5, 19, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (60, 5, 21, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (61, 5, 22, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (62, 5, 23, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (63, 5, 24, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (65, 6, 20, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (66, 6, 18, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (67, 6, 13, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (68, 6, 14, '2026-10-26 16:03:52');
INSERT INTO `sys_role_permission` VALUES (69, 6, 19, '2026-10-26 16:03:52');

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
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'tom123', '$2a$12$tEFa.HGblOLYEOOUhB9B.u/3iUQdzPgKoi5puXnp4Itxqiz5QAATC', 'tom123', '123@qq.com', '17786174112', 1, '2026-10-26 17:49:28', '2026-10-26 11:53:23', '2026-10-26 17:49:28', 0);
INSERT INTO `sys_user` VALUES (2, 'kity123#DEL#2', '$2a$12$iZlVyeaysy/Nhs/YC7.sxOh6CDw6iF1H/5/XwRBGORFJp/0YUSq9G', 'kity123', '123@qq.com', '17786174112', 1, '2026-10-26 15:49:27', '2026-10-26 14:47:38', '2026-10-26 17:24:57', 1);
INSERT INTO `sys_user` VALUES (4, 'babo123#DEL#4', '$2a$12$AN/XgPPH3FwFqBUEx5ayKeeY7wzHsH.gwnuUfz6FY0v6HJAACyJ9m', 'babo123', '123@qq.com', '17786174112', 1, '2026-10-26 16:24:01', '2026-10-26 16:06:00', '2026-10-26 16:34:23', 1);
INSERT INTO `sys_user` VALUES (5, 'admin', '$2a$12$wThUxuRGa5RP6rpEtpfKAerFg0OOo312Wo5aqSUEWvflU/Z0tPIim', 'admin123', '123@qq.com', '17786174112', 1, '2026-10-26 17:24:45', '2026-10-26 16:23:05', '2026-10-26 17:24:45', 0);
INSERT INTO `sys_user` VALUES (6, 'public', '$2a$12$Vs84o9vWNOPlTWSFoJboD.uRIhbzR18sCr/D/YtcGbbynee69LNFO', 'public123', '123@qq.com', '17786174112', 1, '2026-10-26 17:22:48', '2026-10-26 16:26:56', '2026-10-26 17:22:48', 0);

SET FOREIGN_KEY_CHECKS = 1;
