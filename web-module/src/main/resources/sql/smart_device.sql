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

 Date: 27/10/2026 18:23:49
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
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备绑定关系表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_binding
-- ----------------------------
INSERT INTO `device_binding` VALUES (1, 'MAC123456789', DEFAULT, 6, 0, '2026-10-27 10:38:49', '2026-10-27 10:42:01', '2026-10-27 10:38:49', '2026-10-27 10:38:49');
INSERT INTO `device_binding` VALUES (2, 'MAC123456789', DEFAULT, 7, 1, '2026-10-27 10:42:35', NULL, '2026-10-27 10:42:35', '2026-10-27 10:42:35');
INSERT INTO `device_binding` VALUES (3, 'AABBCCDDEE11', DEFAULT, 7, 1, '2026-10-27 10:51:11', NULL, '2026-10-27 10:51:11', '2026-10-27 11:15:27');
INSERT INTO `device_binding` VALUES (4, 'AABBCCDDEEC7', DEFAULT, 6, 1, '2026-10-27 11:42:37', NULL, '2026-10-27 11:42:37', '2026-10-27 11:42:37');
INSERT INTO `device_binding` VALUES (5, 'B4BFE90CDBA1', DEFAULT, 7, 1, '2026-10-27 11:50:00', NULL, '2026-10-27 11:50:00', '2026-10-27 11:50:00');

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
) ENGINE = InnoDB AUTO_INCREMENT = 118 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备下行控制指令表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_command
-- ----------------------------
INSERT INTO `device_command` VALUES (113, 'ddf6d3b52fa2460da4aa8e6f09c74391', 'B4BFE90CDBA1', 'start', 'ota', NULL, '{\"url\": \"http://localhost:8000/firmware/firmware_1.0.40_20261027152646.bin\", \"size\": 12031776, \"sha256\": \"e1463d554118ee97c8e7b8fc479a5bad61e34658b588d3f291111954acdd9c78\", \"version\": \"1.0.40\"}', 1, 0, 3, 1, 3, '网络错误: [WinError 10061] 由于目标计算机积极拒绝，无法连接。', '{\"otaState\": \"failed\", \"toVersion\": \"1.0.40\"}', 'admin', 'WEB', '2026-10-27 16:18:09.246', '2026-10-27 15:48:09.650', '2026-10-27 15:48:14.401', '2026-10-27 15:48:09.246', '2026-10-27 15:48:14.409');
INSERT INTO `device_command` VALUES (114, '4c8fd342a34543d38ab13222e6fa895c', 'B4BFE90CDBA1', 'start', 'ota', NULL, '{\"url\": \"http://localhost:8000/firmware/firmware_1.0.40_20261027152646.bin\", \"size\": 12031776, \"sha256\": \"e1463d554118ee97c8e7b8fc479a5bad61e34658b588d3f291111954acdd9c78\", \"version\": \"1.0.40\"}', 1, 0, 2, 1, 3, NULL, '{\"otaState\": \"success\", \"toVersion\": \"1.0.40\"}', 'admin', 'WEB', '2026-10-27 16:21:31.034', '2026-10-27 15:51:31.054', '2026-10-27 15:51:39.777', '2026-10-27 15:51:31.034', '2026-10-27 15:51:39.781');
INSERT INTO `device_command` VALUES (115, 'b9e2e2530f174aa990257ab000d39c64', 'B4BFE90CDBA1', 'start', 'ota', NULL, '{\"url\": \"http://localhost:8000/firmware/firmware_1.0.41_20261027170333.bin\", \"size\": 12031776, \"sha256\": \"e1463d554118ee97c8e7b8fc479a5bad61e34658b588d3f291111954acdd9c78\", \"version\": \"1.0.41\"}', 1, 0, 2, 1, 3, NULL, '{\"otaState\": \"success\", \"toVersion\": \"1.0.41\"}', 'user_7', 'APP', '2026-10-27 17:36:06.630', '2026-10-27 17:06:07.059', '2026-10-27 17:06:15.768', '2026-10-27 17:06:06.630', '2026-10-27 17:06:15.770');
INSERT INTO `device_command` VALUES (116, 'e4602d9d000648e5a0cac603ef91a56b', 'B4BFE90CDBA1', 'set', 'led', 1, '{\"state\": 1}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_7', 'APP', '2026-10-27 17:37:49.886', '2026-10-27 17:37:20.260', '2026-10-27 17:37:20.273', '2026-10-27 17:37:19.886', '2026-10-27 17:37:20.277');
INSERT INTO `device_command` VALUES (117, '3a8c90ae03f04a8a99d9329f5e45b35b', 'B4BFE90CDBA1', 'set', 'led', 1, '{\"state\": 0}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_7', 'APP', '2026-10-27 17:39:09.560', '2026-10-27 17:38:39.569', '2026-10-27 17:38:39.576', '2026-10-27 17:38:39.560', '2026-10-27 17:38:39.581');

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
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '固件版本表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_firmware
-- ----------------------------
INSERT INTO `device_firmware` VALUES (20, '1.0.40', 'WOMI_DEVICE', 'ota批量升级测试', 'http://localhost:8000/firmware/firmware_1.0.40_20261027152646.bin', 'firmware_1.0.40_20261014145050.bin', 'D:\\data\\firmware\\firmware_1.0.40_20261027152646.bin', 'b02193f879a8b03013eec4b223d13e40', 'e1463d554118ee97c8e7b8fc479a5bad61e34658b588d3f291111954acdd9c78', 12031776, 'admin', '2026-10-27 15:26:46.742', 1, '2026-10-27 15:26:46.743', '2026-10-27 15:26:46.743');
INSERT INTO `device_firmware` VALUES (21, '1.0.41', 'SmartHome-v1', '固件更新', 'http://localhost:8000/firmware/firmware_1.0.41_20261027170333.bin', 'firmware_1.0.41_20261014145050.bin', 'D:\\data\\firmware\\firmware_1.0.41_20261027170333.bin', 'b02193f879a8b03013eec4b223d13e40', 'e1463d554118ee97c8e7b8fc479a5bad61e34658b588d3f291111954acdd9c78', 12031776, 'admin', '2026-10-27 17:03:34.327', 1, '2026-10-27 17:03:34.337', '2026-10-27 17:03:34.337');

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
) ENGINE = InnoDB AUTO_INCREMENT = 2164 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '心跳记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_heartbeat_record
-- ----------------------------
INSERT INTO `device_heartbeat_record` VALUES (1647, 'B4BFE90CDBA1', 30, '2026-10-27 13:56:28.520', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080588507, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 30, \"rssi\": -65}}', '2026-10-27 13:56:28.521');
INSERT INTO `device_heartbeat_record` VALUES (1648, 'B4BFE90CDBA1', 60, '2026-10-27 13:56:58.559', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080618548, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 60, \"rssi\": -65}}', '2026-10-27 13:56:58.559');
INSERT INTO `device_heartbeat_record` VALUES (1649, 'B4BFE90CDBA1', 90, '2026-10-27 13:57:28.576', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080648561, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 90, \"rssi\": -65}}', '2026-10-27 13:57:28.577');
INSERT INTO `device_heartbeat_record` VALUES (1650, 'B4BFE90CDBA1', 120, '2026-10-27 13:57:58.580', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080678567, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 120, \"rssi\": -65}}', '2026-10-27 13:57:58.580');
INSERT INTO `device_heartbeat_record` VALUES (1651, 'B4BFE90CDBA1', 150, '2026-10-27 13:58:28.593', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080708575, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 150, \"rssi\": -65}}', '2026-10-27 13:58:28.594');
INSERT INTO `device_heartbeat_record` VALUES (1652, 'B4BFE90CDBA1', 180, '2026-10-27 13:58:58.597', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080738585, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 180, \"rssi\": -65}}', '2026-10-27 13:58:58.597');
INSERT INTO `device_heartbeat_record` VALUES (1653, 'B4BFE90CDBA1', 210, '2026-10-27 13:59:28.612', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080768593, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 210, \"rssi\": -65}}', '2026-10-27 13:59:28.613');
INSERT INTO `device_heartbeat_record` VALUES (1654, 'B4BFE90CDBA1', 240, '2026-10-27 13:59:58.624', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080798604, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 240, \"rssi\": -65}}', '2026-10-27 13:59:58.624');
INSERT INTO `device_heartbeat_record` VALUES (1655, 'B4BFE90CDBA1', 270, '2026-10-27 14:00:28.623', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080828615, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 270, \"rssi\": -65}}', '2026-10-27 14:00:28.623');
INSERT INTO `device_heartbeat_record` VALUES (1656, 'B4BFE90CDBA1', 300, '2026-10-27 14:00:58.633', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080858626, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 300, \"rssi\": -65}}', '2026-10-27 14:00:58.634');
INSERT INTO `device_heartbeat_record` VALUES (1657, 'B4BFE90CDBA1', 330, '2026-10-27 14:01:28.649', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080888639, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 330, \"rssi\": -65}}', '2026-10-27 14:01:28.650');
INSERT INTO `device_heartbeat_record` VALUES (1658, 'B4BFE90CDBA1', 360, '2026-10-27 14:01:58.691', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080918654, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 360, \"rssi\": -65}}', '2026-10-27 14:01:58.692');
INSERT INTO `device_heartbeat_record` VALUES (1659, 'B4BFE90CDBA1', 390, '2026-10-27 14:02:28.682', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080948667, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 390, \"rssi\": -65}}', '2026-10-27 14:02:28.682');
INSERT INTO `device_heartbeat_record` VALUES (1660, 'B4BFE90CDBA1', 420, '2026-10-27 14:02:58.686', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793080978677, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 420, \"rssi\": -65}}', '2026-10-27 14:02:58.687');
INSERT INTO `device_heartbeat_record` VALUES (1661, 'B4BFE90CDBA1', 450, '2026-10-27 14:03:28.695', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081008684, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 450, \"rssi\": -65}}', '2026-10-27 14:03:28.696');
INSERT INTO `device_heartbeat_record` VALUES (1662, 'B4BFE90CDBA1', 480, '2026-10-27 14:03:58.704', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081038689, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 480, \"rssi\": -65}}', '2026-10-27 14:03:58.704');
INSERT INTO `device_heartbeat_record` VALUES (1663, 'B4BFE90CDBA1', 510, '2026-10-27 14:04:28.707', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081068696, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 510, \"rssi\": -65}}', '2026-10-27 14:04:28.708');
INSERT INTO `device_heartbeat_record` VALUES (1664, 'B4BFE90CDBA1', 540, '2026-10-27 14:04:58.720', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081098699, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 540, \"rssi\": -65}}', '2026-10-27 14:04:58.724');
INSERT INTO `device_heartbeat_record` VALUES (1665, 'B4BFE90CDBA1', 570, '2026-10-27 14:05:28.724', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081128713, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 570, \"rssi\": -65}}', '2026-10-27 14:05:28.725');
INSERT INTO `device_heartbeat_record` VALUES (1666, 'B4BFE90CDBA1', 600, '2026-10-27 14:05:58.985', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081158725, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 600, \"rssi\": -65}}', '2026-10-27 14:05:58.999');
INSERT INTO `device_heartbeat_record` VALUES (1667, 'B4BFE90CDBA1', 630, '2026-10-27 14:06:29.832', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081188731, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 630, \"rssi\": -65}}', '2026-10-27 14:06:29.833');
INSERT INTO `device_heartbeat_record` VALUES (1668, 'B4BFE90CDBA1', 660, '2026-10-27 14:06:58.748', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081218739, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 660, \"rssi\": -65}}', '2026-10-27 14:06:58.749');
INSERT INTO `device_heartbeat_record` VALUES (1669, 'B4BFE90CDBA1', 690, '2026-10-27 14:07:28.763', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081248750, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 690, \"rssi\": -65}}', '2026-10-27 14:07:28.763');
INSERT INTO `device_heartbeat_record` VALUES (1670, 'B4BFE90CDBA1', 720, '2026-10-27 14:07:58.778', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081278760, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 720, \"rssi\": -65}}', '2026-10-27 14:07:58.779');
INSERT INTO `device_heartbeat_record` VALUES (1671, 'B4BFE90CDBA1', 750, '2026-10-27 14:08:28.790', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081308774, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 750, \"rssi\": -65}}', '2026-10-27 14:08:28.790');
INSERT INTO `device_heartbeat_record` VALUES (1672, 'B4BFE90CDBA1', 780, '2026-10-27 14:08:58.802', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081338792, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 780, \"rssi\": -65}}', '2026-10-27 14:08:58.802');
INSERT INTO `device_heartbeat_record` VALUES (1673, 'B4BFE90CDBA1', 810, '2026-10-27 14:09:28.822', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081368806, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 810, \"rssi\": -65}}', '2026-10-27 14:09:28.823');
INSERT INTO `device_heartbeat_record` VALUES (1674, 'B4BFE90CDBA1', 840, '2026-10-27 14:09:58.822', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081398809, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 840, \"rssi\": -65}}', '2026-10-27 14:09:58.822');
INSERT INTO `device_heartbeat_record` VALUES (1675, 'B4BFE90CDBA1', 870, '2026-10-27 14:10:28.822', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081428811, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 870, \"rssi\": -65}}', '2026-10-27 14:10:28.822');
INSERT INTO `device_heartbeat_record` VALUES (1676, 'B4BFE90CDBA1', 900, '2026-10-27 14:10:58.822', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081458817, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 900, \"rssi\": -65}}', '2026-10-27 14:10:58.823');
INSERT INTO `device_heartbeat_record` VALUES (1677, 'B4BFE90CDBA1', 930, '2026-10-27 14:11:28.843', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081488829, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 930, \"rssi\": -65}}', '2026-10-27 14:11:28.844');
INSERT INTO `device_heartbeat_record` VALUES (1678, 'B4BFE90CDBA1', 960, '2026-10-27 14:11:58.840', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081518831, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 960, \"rssi\": -65}}', '2026-10-27 14:11:58.841');
INSERT INTO `device_heartbeat_record` VALUES (1679, 'B4BFE90CDBA1', 990, '2026-10-27 14:12:28.855', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081548843, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 990, \"rssi\": -65}}', '2026-10-27 14:12:28.856');
INSERT INTO `device_heartbeat_record` VALUES (1680, 'B4BFE90CDBA1', 1020, '2026-10-27 14:12:58.857', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081578847, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1020, \"rssi\": -65}}', '2026-10-27 14:12:58.858');
INSERT INTO `device_heartbeat_record` VALUES (1681, 'B4BFE90CDBA1', 1050, '2026-10-27 14:13:28.899', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081608862, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1050, \"rssi\": -65}}', '2026-10-27 14:13:28.899');
INSERT INTO `device_heartbeat_record` VALUES (1682, 'B4BFE90CDBA1', 1080, '2026-10-27 14:13:58.878', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081638864, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1080, \"rssi\": -65}}', '2026-10-27 14:13:58.878');
INSERT INTO `device_heartbeat_record` VALUES (1683, 'B4BFE90CDBA1', 1110, '2026-10-27 14:14:28.876', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081668865, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1110, \"rssi\": -65}}', '2026-10-27 14:14:28.877');
INSERT INTO `device_heartbeat_record` VALUES (1684, 'B4BFE90CDBA1', 1140, '2026-10-27 14:14:58.897', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081698880, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1140, \"rssi\": -65}}', '2026-10-27 14:14:58.898');
INSERT INTO `device_heartbeat_record` VALUES (1685, 'B4BFE90CDBA1', 1170, '2026-10-27 14:15:28.900', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081728891, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1170, \"rssi\": -65}}', '2026-10-27 14:15:28.900');
INSERT INTO `device_heartbeat_record` VALUES (1686, 'B4BFE90CDBA1', 1200, '2026-10-27 14:15:58.910', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081758898, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1200, \"rssi\": -65}}', '2026-10-27 14:15:58.910');
INSERT INTO `device_heartbeat_record` VALUES (1687, 'B4BFE90CDBA1', 1230, '2026-10-27 14:16:28.962', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081788912, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1230, \"rssi\": -65}}', '2026-10-27 14:16:28.964');
INSERT INTO `device_heartbeat_record` VALUES (1688, 'B4BFE90CDBA1', 1260, '2026-10-27 14:16:58.924', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081818916, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1260, \"rssi\": -65}}', '2026-10-27 14:16:58.925');
INSERT INTO `device_heartbeat_record` VALUES (1689, 'B4BFE90CDBA1', 1290, '2026-10-27 14:17:28.940', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081848930, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1290, \"rssi\": -65}}', '2026-10-27 14:17:28.979');
INSERT INTO `device_heartbeat_record` VALUES (1690, 'B4BFE90CDBA1', 1320, '2026-10-27 14:17:58.945', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793081878935, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1320, \"rssi\": -65}}', '2026-10-27 14:17:58.946');
INSERT INTO `device_heartbeat_record` VALUES (1691, 'B4BFE90CDBA1', 30, '2026-10-27 14:22:30.847', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082150669, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 30, \"rssi\": -65}}', '2026-10-27 14:22:30.848');
INSERT INTO `device_heartbeat_record` VALUES (1692, 'B4BFE90CDBA1', 60, '2026-10-27 14:23:00.690', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082180674, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 60, \"rssi\": -65}}', '2026-10-27 14:23:00.691');
INSERT INTO `device_heartbeat_record` VALUES (1693, 'B4BFE90CDBA1', 90, '2026-10-27 14:23:30.701', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082210690, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 90, \"rssi\": -65}}', '2026-10-27 14:23:30.702');
INSERT INTO `device_heartbeat_record` VALUES (1694, 'B4BFE90CDBA1', 120, '2026-10-27 14:24:00.719', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082240703, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 120, \"rssi\": -65}}', '2026-10-27 14:24:00.719');
INSERT INTO `device_heartbeat_record` VALUES (1695, 'B4BFE90CDBA1', 150, '2026-10-27 14:24:30.724', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082270715, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 150, \"rssi\": -65}}', '2026-10-27 14:24:30.724');
INSERT INTO `device_heartbeat_record` VALUES (1696, 'B4BFE90CDBA1', 180, '2026-10-27 14:25:00.744', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082300720, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 180, \"rssi\": -65}}', '2026-10-27 14:25:00.745');
INSERT INTO `device_heartbeat_record` VALUES (1697, 'B4BFE90CDBA1', 210, '2026-10-27 14:25:30.749', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082330725, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 210, \"rssi\": -65}}', '2026-10-27 14:25:30.749');
INSERT INTO `device_heartbeat_record` VALUES (1698, 'B4BFE90CDBA1', 240, '2026-10-27 14:26:00.783', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082360744, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 240, \"rssi\": -65}}', '2026-10-27 14:26:00.783');
INSERT INTO `device_heartbeat_record` VALUES (1699, 'B4BFE90CDBA1', 270, '2026-10-27 14:26:30.780', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082390754, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 270, \"rssi\": -65}}', '2026-10-27 14:26:30.781');
INSERT INTO `device_heartbeat_record` VALUES (1700, 'B4BFE90CDBA1', 300, '2026-10-27 14:27:00.799', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082420774, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 300, \"rssi\": -65}}', '2026-10-27 14:27:00.800');
INSERT INTO `device_heartbeat_record` VALUES (1701, 'B4BFE90CDBA1', 330, '2026-10-27 14:27:30.809', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082450787, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 330, \"rssi\": -65}}', '2026-10-27 14:27:30.810');
INSERT INTO `device_heartbeat_record` VALUES (1702, 'B4BFE90CDBA1', 360, '2026-10-27 14:28:00.806', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082480796, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 360, \"rssi\": -65}}', '2026-10-27 14:28:00.807');
INSERT INTO `device_heartbeat_record` VALUES (1703, 'B4BFE90CDBA1', 390, '2026-10-27 14:28:30.825', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082510805, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 390, \"rssi\": -65}}', '2026-10-27 14:28:30.829');
INSERT INTO `device_heartbeat_record` VALUES (1704, 'B4BFE90CDBA1', 420, '2026-10-27 14:29:00.830', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082540822, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 420, \"rssi\": -65}}', '2026-10-27 14:29:00.831');
INSERT INTO `device_heartbeat_record` VALUES (1705, 'B4BFE90CDBA1', 450, '2026-10-27 14:29:30.862', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082570822, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 450, \"rssi\": -65}}', '2026-10-27 14:29:30.864');
INSERT INTO `device_heartbeat_record` VALUES (1706, 'B4BFE90CDBA1', 480, '2026-10-27 14:30:00.844', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082600827, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 480, \"rssi\": -65}}', '2026-10-27 14:30:00.845');
INSERT INTO `device_heartbeat_record` VALUES (1707, 'B4BFE90CDBA1', 510, '2026-10-27 14:30:30.857', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082630839, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 510, \"rssi\": -65}}', '2026-10-27 14:30:30.858');
INSERT INTO `device_heartbeat_record` VALUES (1708, 'B4BFE90CDBA1', 540, '2026-10-27 14:31:00.863', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082660844, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 540, \"rssi\": -65}}', '2026-10-27 14:31:00.864');
INSERT INTO `device_heartbeat_record` VALUES (1709, 'B4BFE90CDBA1', 570, '2026-10-27 14:31:30.874', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082690857, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 570, \"rssi\": -65}}', '2026-10-27 14:31:30.875');
INSERT INTO `device_heartbeat_record` VALUES (1710, 'B4BFE90CDBA1', 600, '2026-10-27 14:32:00.884', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082720872, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 600, \"rssi\": -65}}', '2026-10-27 14:32:00.887');
INSERT INTO `device_heartbeat_record` VALUES (1711, 'B4BFE90CDBA1', 630, '2026-10-27 14:32:30.896', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082750884, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 630, \"rssi\": -65}}', '2026-10-27 14:32:30.896');
INSERT INTO `device_heartbeat_record` VALUES (1712, 'B4BFE90CDBA1', 660, '2026-10-27 14:33:00.901', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082780895, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 660, \"rssi\": -65}}', '2026-10-27 14:33:00.901');
INSERT INTO `device_heartbeat_record` VALUES (1713, 'B4BFE90CDBA1', 690, '2026-10-27 14:33:30.918', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082810903, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 690, \"rssi\": -65}}', '2026-10-27 14:33:30.919');
INSERT INTO `device_heartbeat_record` VALUES (1714, 'B4BFE90CDBA1', 720, '2026-10-27 14:34:00.960', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082840916, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 720, \"rssi\": -65}}', '2026-10-27 14:34:00.960');
INSERT INTO `device_heartbeat_record` VALUES (1715, 'B4BFE90CDBA1', 750, '2026-10-27 14:34:30.938', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082870923, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 750, \"rssi\": -65}}', '2026-10-27 14:34:30.939');
INSERT INTO `device_heartbeat_record` VALUES (1716, 'B4BFE90CDBA1', 780, '2026-10-27 14:35:00.952', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082900943, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 780, \"rssi\": -65}}', '2026-10-27 14:35:00.952');
INSERT INTO `device_heartbeat_record` VALUES (1717, 'B4BFE90CDBA1', 810, '2026-10-27 14:35:30.966', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082930950, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 810, \"rssi\": -65}}', '2026-10-27 14:35:30.968');
INSERT INTO `device_heartbeat_record` VALUES (1718, 'B4BFE90CDBA1', 840, '2026-10-27 14:36:00.967', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082960955, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 840, \"rssi\": -65}}', '2026-10-27 14:36:00.967');
INSERT INTO `device_heartbeat_record` VALUES (1719, 'B4BFE90CDBA1', 870, '2026-10-27 14:36:30.971', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793082990959, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 870, \"rssi\": -65}}', '2026-10-27 14:36:30.972');
INSERT INTO `device_heartbeat_record` VALUES (1720, 'B4BFE90CDBA1', 900, '2026-10-27 14:37:00.969', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083020961, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 900, \"rssi\": -65}}', '2026-10-27 14:37:00.970');
INSERT INTO `device_heartbeat_record` VALUES (1721, 'B4BFE90CDBA1', 930, '2026-10-27 14:37:30.985', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083050971, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 930, \"rssi\": -65}}', '2026-10-27 14:37:30.986');
INSERT INTO `device_heartbeat_record` VALUES (1722, 'B4BFE90CDBA1', 960, '2026-10-27 14:38:01.000', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083080981, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 960, \"rssi\": -65}}', '2026-10-27 14:38:01.001');
INSERT INTO `device_heartbeat_record` VALUES (1723, 'B4BFE90CDBA1', 990, '2026-10-27 14:38:30.993', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083110984, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 990, \"rssi\": -65}}', '2026-10-27 14:38:30.993');
INSERT INTO `device_heartbeat_record` VALUES (1724, 'B4BFE90CDBA1', 1020, '2026-10-27 14:39:00.994', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083140985, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1020, \"rssi\": -65}}', '2026-10-27 14:39:00.994');
INSERT INTO `device_heartbeat_record` VALUES (1725, 'B4BFE90CDBA1', 1050, '2026-10-27 14:39:31.005', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083170987, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1050, \"rssi\": -65}}', '2026-10-27 14:39:31.005');
INSERT INTO `device_heartbeat_record` VALUES (1726, 'B4BFE90CDBA1', 1080, '2026-10-27 14:40:01.006', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083200996, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1080, \"rssi\": -65}}', '2026-10-27 14:40:01.007');
INSERT INTO `device_heartbeat_record` VALUES (1727, 'B4BFE90CDBA1', 1110, '2026-10-27 14:40:31.011', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083230997, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1110, \"rssi\": -65}}', '2026-10-27 14:40:31.012');
INSERT INTO `device_heartbeat_record` VALUES (1728, 'B4BFE90CDBA1', 1140, '2026-10-27 14:41:01.027', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083261010, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1140, \"rssi\": -65}}', '2026-10-27 14:41:01.027');
INSERT INTO `device_heartbeat_record` VALUES (1729, 'B4BFE90CDBA1', 1170, '2026-10-27 14:41:31.030', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083291017, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1170, \"rssi\": -65}}', '2026-10-27 14:41:31.031');
INSERT INTO `device_heartbeat_record` VALUES (1730, 'B4BFE90CDBA1', 1200, '2026-10-27 14:42:01.064', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083321035, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1200, \"rssi\": -65}}', '2026-10-27 14:42:01.064');
INSERT INTO `device_heartbeat_record` VALUES (1731, 'B4BFE90CDBA1', 1230, '2026-10-27 14:42:31.051', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083351036, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1230, \"rssi\": -65}}', '2026-10-27 14:42:31.052');
INSERT INTO `device_heartbeat_record` VALUES (1732, 'B4BFE90CDBA1', 1260, '2026-10-27 14:43:01.060', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083381047, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1260, \"rssi\": -65}}', '2026-10-27 14:43:01.060');
INSERT INTO `device_heartbeat_record` VALUES (1733, 'B4BFE90CDBA1', 1290, '2026-10-27 14:43:31.067', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083411057, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1290, \"rssi\": -65}}', '2026-10-27 14:43:31.068');
INSERT INTO `device_heartbeat_record` VALUES (1734, 'B4BFE90CDBA1', 1320, '2026-10-27 14:44:01.081', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083441062, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1320, \"rssi\": -65}}', '2026-10-27 14:44:01.084');
INSERT INTO `device_heartbeat_record` VALUES (1735, 'B4BFE90CDBA1', 1350, '2026-10-27 14:44:31.076', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083471065, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1350, \"rssi\": -65}}', '2026-10-27 14:44:31.076');
INSERT INTO `device_heartbeat_record` VALUES (1736, 'B4BFE90CDBA1', 1380, '2026-10-27 14:45:01.088', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083501075, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1380, \"rssi\": -65}}', '2026-10-27 14:45:01.090');
INSERT INTO `device_heartbeat_record` VALUES (1737, 'B4BFE90CDBA1', 1410, '2026-10-27 14:45:31.094', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083531084, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1410, \"rssi\": -65}}', '2026-10-27 14:45:31.094');
INSERT INTO `device_heartbeat_record` VALUES (1738, 'B4BFE90CDBA1', 1440, '2026-10-27 14:46:01.117', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083561094, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1440, \"rssi\": -65}}', '2026-10-27 14:46:01.118');
INSERT INTO `device_heartbeat_record` VALUES (1739, 'B4BFE90CDBA1', 1470, '2026-10-27 14:46:31.146', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083591105, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1470, \"rssi\": -65}}', '2026-10-27 14:46:31.148');
INSERT INTO `device_heartbeat_record` VALUES (1740, 'B4BFE90CDBA1', 1500, '2026-10-27 14:47:01.128', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083621121, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1500, \"rssi\": -65}}', '2026-10-27 14:47:01.129');
INSERT INTO `device_heartbeat_record` VALUES (1741, 'B4BFE90CDBA1', 1530, '2026-10-27 14:47:31.234', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083651135, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1530, \"rssi\": -65}}', '2026-10-27 14:47:31.245');
INSERT INTO `device_heartbeat_record` VALUES (1742, 'B4BFE90CDBA1', 1560, '2026-10-27 14:48:01.163', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083681143, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1560, \"rssi\": -65}}', '2026-10-27 14:48:01.164');
INSERT INTO `device_heartbeat_record` VALUES (1743, 'B4BFE90CDBA1', 1590, '2026-10-27 14:48:31.173', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083711159, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1590, \"rssi\": -65}}', '2026-10-27 14:48:31.174');
INSERT INTO `device_heartbeat_record` VALUES (1744, 'B4BFE90CDBA1', 1620, '2026-10-27 14:49:01.181', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083741170, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1620, \"rssi\": -65}}', '2026-10-27 14:49:01.182');
INSERT INTO `device_heartbeat_record` VALUES (1745, 'B4BFE90CDBA1', 1650, '2026-10-27 14:49:31.206', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083771185, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1650, \"rssi\": -65}}', '2026-10-27 14:49:31.207');
INSERT INTO `device_heartbeat_record` VALUES (1746, 'B4BFE90CDBA1', 1680, '2026-10-27 14:50:01.216', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083801199, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1680, \"rssi\": -65}}', '2026-10-27 14:50:01.217');
INSERT INTO `device_heartbeat_record` VALUES (1747, 'B4BFE90CDBA1', 1710, '2026-10-27 14:50:31.228', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083831213, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1710, \"rssi\": -65}}', '2026-10-27 14:50:31.229');
INSERT INTO `device_heartbeat_record` VALUES (1748, 'B4BFE90CDBA1', 1740, '2026-10-27 14:51:01.232', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083861218, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1740, \"rssi\": -65}}', '2026-10-27 14:51:01.232');
INSERT INTO `device_heartbeat_record` VALUES (1749, 'B4BFE90CDBA1', 1770, '2026-10-27 14:51:31.230', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083891224, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1770, \"rssi\": -65}}', '2026-10-27 14:51:31.230');
INSERT INTO `device_heartbeat_record` VALUES (1750, 'B4BFE90CDBA1', 1800, '2026-10-27 14:52:01.248', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083921232, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1800, \"rssi\": -65}}', '2026-10-27 14:52:01.248');
INSERT INTO `device_heartbeat_record` VALUES (1751, 'B4BFE90CDBA1', 1830, '2026-10-27 14:52:31.251', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083951235, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1830, \"rssi\": -65}}', '2026-10-27 14:52:31.252');
INSERT INTO `device_heartbeat_record` VALUES (1752, 'B4BFE90CDBA1', 1860, '2026-10-27 14:53:01.257', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793083981237, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1860, \"rssi\": -65}}', '2026-10-27 14:53:01.258');
INSERT INTO `device_heartbeat_record` VALUES (1753, 'B4BFE90CDBA1', 1890, '2026-10-27 14:53:31.268', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084011251, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1890, \"rssi\": -65}}', '2026-10-27 14:53:31.269');
INSERT INTO `device_heartbeat_record` VALUES (1754, 'B4BFE90CDBA1', 1920, '2026-10-27 14:54:01.273', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084041260, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1920, \"rssi\": -65}}', '2026-10-27 14:54:01.274');
INSERT INTO `device_heartbeat_record` VALUES (1755, 'B4BFE90CDBA1', 1950, '2026-10-27 14:54:31.288', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084071266, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1950, \"rssi\": -65}}', '2026-10-27 14:54:31.290');
INSERT INTO `device_heartbeat_record` VALUES (1756, 'B4BFE90CDBA1', 1980, '2026-10-27 14:55:01.305', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084101281, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1980, \"rssi\": -65}}', '2026-10-27 14:55:01.306');
INSERT INTO `device_heartbeat_record` VALUES (1757, 'B4BFE90CDBA1', 2010, '2026-10-27 14:55:31.311', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084131290, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2010, \"rssi\": -65}}', '2026-10-27 14:55:31.312');
INSERT INTO `device_heartbeat_record` VALUES (1758, 'B4BFE90CDBA1', 2040, '2026-10-27 14:56:01.313', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084161295, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2040, \"rssi\": -65}}', '2026-10-27 14:56:01.313');
INSERT INTO `device_heartbeat_record` VALUES (1759, 'B4BFE90CDBA1', 2070, '2026-10-27 14:56:31.317', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084191306, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2070, \"rssi\": -65}}', '2026-10-27 14:56:31.318');
INSERT INTO `device_heartbeat_record` VALUES (1760, 'B4BFE90CDBA1', 2100, '2026-10-27 14:57:01.337', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084221317, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2100, \"rssi\": -65}}', '2026-10-27 14:57:01.337');
INSERT INTO `device_heartbeat_record` VALUES (1761, 'B4BFE90CDBA1', 2130, '2026-10-27 14:57:31.346', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084251331, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2130, \"rssi\": -65}}', '2026-10-27 14:57:31.346');
INSERT INTO `device_heartbeat_record` VALUES (1762, 'B4BFE90CDBA1', 2160, '2026-10-27 14:58:01.346', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084281337, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2160, \"rssi\": -65}}', '2026-10-27 14:58:01.346');
INSERT INTO `device_heartbeat_record` VALUES (1763, 'B4BFE90CDBA1', 2190, '2026-10-27 14:58:31.356', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084311340, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2190, \"rssi\": -65}}', '2026-10-27 14:58:31.357');
INSERT INTO `device_heartbeat_record` VALUES (1764, 'B4BFE90CDBA1', 2220, '2026-10-27 14:59:01.365', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084341356, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2220, \"rssi\": -65}}', '2026-10-27 14:59:01.365');
INSERT INTO `device_heartbeat_record` VALUES (1765, 'B4BFE90CDBA1', 2250, '2026-10-27 14:59:31.372', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084371361, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2250, \"rssi\": -65}}', '2026-10-27 14:59:31.372');
INSERT INTO `device_heartbeat_record` VALUES (1766, 'B4BFE90CDBA1', 2280, '2026-10-27 15:00:01.373', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084401364, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2280, \"rssi\": -65}}', '2026-10-27 15:00:01.373');
INSERT INTO `device_heartbeat_record` VALUES (1767, 'B4BFE90CDBA1', 2310, '2026-10-27 15:00:31.374', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084431367, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2310, \"rssi\": -65}}', '2026-10-27 15:00:31.374');
INSERT INTO `device_heartbeat_record` VALUES (1768, 'B4BFE90CDBA1', 2340, '2026-10-27 15:01:01.393', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084461373, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2340, \"rssi\": -65}}', '2026-10-27 15:01:01.441');
INSERT INTO `device_heartbeat_record` VALUES (1769, 'B4BFE90CDBA1', 2370, '2026-10-27 15:01:31.391', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084491381, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2370, \"rssi\": -65}}', '2026-10-27 15:01:31.392');
INSERT INTO `device_heartbeat_record` VALUES (1770, 'B4BFE90CDBA1', 2400, '2026-10-27 15:02:01.435', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084521388, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2400, \"rssi\": -65}}', '2026-10-27 15:02:01.441');
INSERT INTO `device_heartbeat_record` VALUES (1771, 'B4BFE90CDBA1', 2430, '2026-10-27 15:02:31.406', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084551397, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2430, \"rssi\": -65}}', '2026-10-27 15:02:31.407');
INSERT INTO `device_heartbeat_record` VALUES (1772, 'B4BFE90CDBA1', 2460, '2026-10-27 15:03:01.420', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084581406, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2460, \"rssi\": -65}}', '2026-10-27 15:03:01.420');
INSERT INTO `device_heartbeat_record` VALUES (1773, 'B4BFE90CDBA1', 2490, '2026-10-27 15:03:31.429', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084611417, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2490, \"rssi\": -65}}', '2026-10-27 15:03:31.430');
INSERT INTO `device_heartbeat_record` VALUES (1774, 'B4BFE90CDBA1', 2520, '2026-10-27 15:04:01.448', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084641425, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2520, \"rssi\": -65}}', '2026-10-27 15:04:01.449');
INSERT INTO `device_heartbeat_record` VALUES (1775, 'B4BFE90CDBA1', 2550, '2026-10-27 15:04:31.468', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084671428, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2550, \"rssi\": -65}}', '2026-10-27 15:04:31.468');
INSERT INTO `device_heartbeat_record` VALUES (1776, 'B4BFE90CDBA1', 2580, '2026-10-27 15:05:01.454', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084701437, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2580, \"rssi\": -65}}', '2026-10-27 15:05:01.456');
INSERT INTO `device_heartbeat_record` VALUES (1777, 'B4BFE90CDBA1', 2610, '2026-10-27 15:05:31.466', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084731451, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2610, \"rssi\": -65}}', '2026-10-27 15:05:31.466');
INSERT INTO `device_heartbeat_record` VALUES (1778, 'B4BFE90CDBA1', 2640, '2026-10-27 15:06:01.505', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084761467, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2640, \"rssi\": -65}}', '2026-10-27 15:06:01.506');
INSERT INTO `device_heartbeat_record` VALUES (1779, 'B4BFE90CDBA1', 2670, '2026-10-27 15:06:31.492', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084791482, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2670, \"rssi\": -65}}', '2026-10-27 15:06:31.493');
INSERT INTO `device_heartbeat_record` VALUES (1780, 'B4BFE90CDBA1', 2700, '2026-10-27 15:07:01.505', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084821496, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2700, \"rssi\": -65}}', '2026-10-27 15:07:01.506');
INSERT INTO `device_heartbeat_record` VALUES (1781, 'B4BFE90CDBA1', 2730, '2026-10-27 15:07:31.517', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084851500, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2730, \"rssi\": -65}}', '2026-10-27 15:07:31.519');
INSERT INTO `device_heartbeat_record` VALUES (1782, 'B4BFE90CDBA1', 2760, '2026-10-27 15:08:01.519', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084881510, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2760, \"rssi\": -65}}', '2026-10-27 15:08:01.520');
INSERT INTO `device_heartbeat_record` VALUES (1783, 'B4BFE90CDBA1', 2790, '2026-10-27 15:08:31.533', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084911520, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2790, \"rssi\": -65}}', '2026-10-27 15:08:31.534');
INSERT INTO `device_heartbeat_record` VALUES (1784, 'B4BFE90CDBA1', 2820, '2026-10-27 15:09:01.536', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084941523, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2820, \"rssi\": -65}}', '2026-10-27 15:09:01.536');
INSERT INTO `device_heartbeat_record` VALUES (1785, 'B4BFE90CDBA1', 2850, '2026-10-27 15:09:31.560', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793084971540, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2850, \"rssi\": -65}}', '2026-10-27 15:09:31.561');
INSERT INTO `device_heartbeat_record` VALUES (1786, 'B4BFE90CDBA1', 2880, '2026-10-27 15:10:01.568', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085001551, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2880, \"rssi\": -65}}', '2026-10-27 15:10:01.569');
INSERT INTO `device_heartbeat_record` VALUES (1787, 'B4BFE90CDBA1', 2910, '2026-10-27 15:10:31.590', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085031566, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2910, \"rssi\": -65}}', '2026-10-27 15:10:31.592');
INSERT INTO `device_heartbeat_record` VALUES (1788, 'B4BFE90CDBA1', 2940, '2026-10-27 15:11:01.595', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085061582, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2940, \"rssi\": -65}}', '2026-10-27 15:11:01.596');
INSERT INTO `device_heartbeat_record` VALUES (1789, 'B4BFE90CDBA1', 2970, '2026-10-27 15:11:31.610', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085091587, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2970, \"rssi\": -65}}', '2026-10-27 15:11:31.612');
INSERT INTO `device_heartbeat_record` VALUES (1790, 'B4BFE90CDBA1', 3000, '2026-10-27 15:12:01.609', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085121597, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3000, \"rssi\": -65}}', '2026-10-27 15:12:01.611');
INSERT INTO `device_heartbeat_record` VALUES (1791, 'B4BFE90CDBA1', 3030, '2026-10-27 15:12:31.629', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085151608, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3030, \"rssi\": -65}}', '2026-10-27 15:12:31.630');
INSERT INTO `device_heartbeat_record` VALUES (1792, 'B4BFE90CDBA1', 3060, '2026-10-27 15:13:01.623', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085181615, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3060, \"rssi\": -65}}', '2026-10-27 15:13:01.623');
INSERT INTO `device_heartbeat_record` VALUES (1793, 'B4BFE90CDBA1', 3090, '2026-10-27 15:13:31.651', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085211629, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3090, \"rssi\": -65}}', '2026-10-27 15:13:31.652');
INSERT INTO `device_heartbeat_record` VALUES (1794, 'B4BFE90CDBA1', 3120, '2026-10-27 15:14:01.662', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085241642, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3120, \"rssi\": -65}}', '2026-10-27 15:14:01.664');
INSERT INTO `device_heartbeat_record` VALUES (1795, 'B4BFE90CDBA1', 3150, '2026-10-27 15:14:31.657', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085271647, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3150, \"rssi\": -65}}', '2026-10-27 15:14:31.657');
INSERT INTO `device_heartbeat_record` VALUES (1796, 'B4BFE90CDBA1', 3180, '2026-10-27 15:15:01.665', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085301658, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3180, \"rssi\": -65}}', '2026-10-27 15:15:01.666');
INSERT INTO `device_heartbeat_record` VALUES (1797, 'B4BFE90CDBA1', 3210, '2026-10-27 15:15:31.670', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085331658, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3210, \"rssi\": -65}}', '2026-10-27 15:15:31.671');
INSERT INTO `device_heartbeat_record` VALUES (1798, 'B4BFE90CDBA1', 3240, '2026-10-27 15:16:01.678', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085361664, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3240, \"rssi\": -65}}', '2026-10-27 15:16:01.679');
INSERT INTO `device_heartbeat_record` VALUES (1799, 'B4BFE90CDBA1', 3270, '2026-10-27 15:16:31.714', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085391670, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3270, \"rssi\": -65}}', '2026-10-27 15:16:31.719');
INSERT INTO `device_heartbeat_record` VALUES (1800, 'B4BFE90CDBA1', 3300, '2026-10-27 15:17:01.694', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085421684, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3300, \"rssi\": -65}}', '2026-10-27 15:17:01.695');
INSERT INTO `device_heartbeat_record` VALUES (1801, 'B4BFE90CDBA1', 3330, '2026-10-27 15:17:31.702', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085451688, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3330, \"rssi\": -65}}', '2026-10-27 15:17:31.703');
INSERT INTO `device_heartbeat_record` VALUES (1802, 'B4BFE90CDBA1', 3360, '2026-10-27 15:18:01.696', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085481689, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3360, \"rssi\": -65}}', '2026-10-27 15:18:01.697');
INSERT INTO `device_heartbeat_record` VALUES (1803, 'B4BFE90CDBA1', 3390, '2026-10-27 15:18:31.715', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085511696, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3390, \"rssi\": -65}}', '2026-10-27 15:18:31.716');
INSERT INTO `device_heartbeat_record` VALUES (1804, 'B4BFE90CDBA1', 3420, '2026-10-27 15:19:01.720', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085541704, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3420, \"rssi\": -65}}', '2026-10-27 15:19:01.721');
INSERT INTO `device_heartbeat_record` VALUES (1805, 'B4BFE90CDBA1', 3450, '2026-10-27 15:19:31.724', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085571717, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3450, \"rssi\": -65}}', '2026-10-27 15:19:31.725');
INSERT INTO `device_heartbeat_record` VALUES (1806, 'B4BFE90CDBA1', 3480, '2026-10-27 15:20:01.744', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085601722, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3480, \"rssi\": -65}}', '2026-10-27 15:20:01.745');
INSERT INTO `device_heartbeat_record` VALUES (1807, 'B4BFE90CDBA1', 3510, '2026-10-27 15:20:31.740', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085631734, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3510, \"rssi\": -65}}', '2026-10-27 15:20:31.741');
INSERT INTO `device_heartbeat_record` VALUES (1808, 'B4BFE90CDBA1', 3660, '2026-10-27 15:23:01.808', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085781793, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3660, \"rssi\": -65}}', '2026-10-27 15:23:01.812');
INSERT INTO `device_heartbeat_record` VALUES (1809, 'B4BFE90CDBA1', 3690, '2026-10-27 15:23:31.810', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085811798, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3690, \"rssi\": -65}}', '2026-10-27 15:23:31.811');
INSERT INTO `device_heartbeat_record` VALUES (1810, 'B4BFE90CDBA1', 3720, '2026-10-27 15:24:01.836', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085841815, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3720, \"rssi\": -65}}', '2026-10-27 15:24:01.836');
INSERT INTO `device_heartbeat_record` VALUES (1811, 'B4BFE90CDBA1', 3750, '2026-10-27 15:24:31.869', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085871829, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3750, \"rssi\": -65}}', '2026-10-27 15:24:31.870');
INSERT INTO `device_heartbeat_record` VALUES (1812, 'B4BFE90CDBA1', 3780, '2026-10-27 15:25:01.883', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085901841, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3780, \"rssi\": -65}}', '2026-10-27 15:25:01.884');
INSERT INTO `device_heartbeat_record` VALUES (1813, 'B4BFE90CDBA1', 3810, '2026-10-27 15:25:31.893', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085931873, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3810, \"rssi\": -65}}', '2026-10-27 15:25:31.894');
INSERT INTO `device_heartbeat_record` VALUES (1814, 'B4BFE90CDBA1', 3840, '2026-10-27 15:26:01.898', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085961885, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3840, \"rssi\": -65}}', '2026-10-27 15:26:01.899');
INSERT INTO `device_heartbeat_record` VALUES (1815, 'B4BFE90CDBA1', 3870, '2026-10-27 15:26:31.897', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793085991886, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3870, \"rssi\": -65}}', '2026-10-27 15:26:31.897');
INSERT INTO `device_heartbeat_record` VALUES (1816, 'B4BFE90CDBA1', 3900, '2026-10-27 15:27:01.900', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086021891, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3900, \"rssi\": -65}}', '2026-10-27 15:27:01.900');
INSERT INTO `device_heartbeat_record` VALUES (1817, 'B4BFE90CDBA1', 3930, '2026-10-27 15:27:31.926', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086051901, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3930, \"rssi\": -65}}', '2026-10-27 15:27:31.927');
INSERT INTO `device_heartbeat_record` VALUES (1818, 'B4BFE90CDBA1', 3960, '2026-10-27 15:28:01.926', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086081911, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3960, \"rssi\": -65}}', '2026-10-27 15:28:01.926');
INSERT INTO `device_heartbeat_record` VALUES (1819, 'B4BFE90CDBA1', 3990, '2026-10-27 15:28:31.943', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086111924, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 3990, \"rssi\": -65}}', '2026-10-27 15:28:31.945');
INSERT INTO `device_heartbeat_record` VALUES (1820, 'B4BFE90CDBA1', 4020, '2026-10-27 15:29:01.961', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086141933, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4020, \"rssi\": -65}}', '2026-10-27 15:29:01.966');
INSERT INTO `device_heartbeat_record` VALUES (1821, 'B4BFE90CDBA1', 4050, '2026-10-27 15:29:31.967', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086171942, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4050, \"rssi\": -65}}', '2026-10-27 15:29:31.968');
INSERT INTO `device_heartbeat_record` VALUES (1822, 'B4BFE90CDBA1', 4080, '2026-10-27 15:30:01.958', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086201952, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4080, \"rssi\": -65}}', '2026-10-27 15:30:01.959');
INSERT INTO `device_heartbeat_record` VALUES (1823, 'B4BFE90CDBA1', 4110, '2026-10-27 15:30:31.978', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086231966, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4110, \"rssi\": -65}}', '2026-10-27 15:30:31.978');
INSERT INTO `device_heartbeat_record` VALUES (1824, 'B4BFE90CDBA1', 4140, '2026-10-27 15:31:01.983', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086261975, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4140, \"rssi\": -65}}', '2026-10-27 15:31:01.984');
INSERT INTO `device_heartbeat_record` VALUES (1825, 'B4BFE90CDBA1', 4170, '2026-10-27 15:31:31.984', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086291976, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4170, \"rssi\": -65}}', '2026-10-27 15:31:31.984');
INSERT INTO `device_heartbeat_record` VALUES (1826, 'B4BFE90CDBA1', 4200, '2026-10-27 15:32:01.999', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086321991, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4200, \"rssi\": -65}}', '2026-10-27 15:32:01.999');
INSERT INTO `device_heartbeat_record` VALUES (1827, 'B4BFE90CDBA1', 4230, '2026-10-27 15:32:32.014', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086352004, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4230, \"rssi\": -65}}', '2026-10-27 15:32:32.016');
INSERT INTO `device_heartbeat_record` VALUES (1828, 'B4BFE90CDBA1', 4260, '2026-10-27 15:33:02.016', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086382008, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4260, \"rssi\": -65}}', '2026-10-27 15:33:02.017');
INSERT INTO `device_heartbeat_record` VALUES (1829, 'B4BFE90CDBA1', 4290, '2026-10-27 15:33:32.021', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086412011, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4290, \"rssi\": -65}}', '2026-10-27 15:33:32.021');
INSERT INTO `device_heartbeat_record` VALUES (1830, 'B4BFE90CDBA1', 4320, '2026-10-27 15:34:02.039', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086442016, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4320, \"rssi\": -65}}', '2026-10-27 15:34:02.040');
INSERT INTO `device_heartbeat_record` VALUES (1831, 'B4BFE90CDBA1', 4350, '2026-10-27 15:34:32.030', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086472019, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4350, \"rssi\": -65}}', '2026-10-27 15:34:32.031');
INSERT INTO `device_heartbeat_record` VALUES (1832, 'B4BFE90CDBA1', 4380, '2026-10-27 15:35:02.054', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086502036, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4380, \"rssi\": -65}}', '2026-10-27 15:35:02.055');
INSERT INTO `device_heartbeat_record` VALUES (1833, 'B4BFE90CDBA1', 4410, '2026-10-27 15:35:32.088', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086532055, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4410, \"rssi\": -65}}', '2026-10-27 15:35:32.090');
INSERT INTO `device_heartbeat_record` VALUES (1834, 'B4BFE90CDBA1', 4440, '2026-10-27 15:36:02.089', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086562068, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4440, \"rssi\": -65}}', '2026-10-27 15:36:02.089');
INSERT INTO `device_heartbeat_record` VALUES (1835, 'B4BFE90CDBA1', 4470, '2026-10-27 15:36:32.088', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086592071, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4470, \"rssi\": -65}}', '2026-10-27 15:36:32.090');
INSERT INTO `device_heartbeat_record` VALUES (1836, 'B4BFE90CDBA1', 4500, '2026-10-27 15:37:02.091', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086622082, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4500, \"rssi\": -65}}', '2026-10-27 15:37:02.092');
INSERT INTO `device_heartbeat_record` VALUES (1837, 'B4BFE90CDBA1', 4530, '2026-10-27 15:37:32.092', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086652085, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4530, \"rssi\": -65}}', '2026-10-27 15:37:32.092');
INSERT INTO `device_heartbeat_record` VALUES (1838, 'B4BFE90CDBA1', 4560, '2026-10-27 15:38:02.103', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086682096, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4560, \"rssi\": -65}}', '2026-10-27 15:38:02.103');
INSERT INTO `device_heartbeat_record` VALUES (1839, 'B4BFE90CDBA1', 4590, '2026-10-27 15:38:32.128', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086712108, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4590, \"rssi\": -65}}', '2026-10-27 15:38:32.129');
INSERT INTO `device_heartbeat_record` VALUES (1840, 'B4BFE90CDBA1', 4620, '2026-10-27 15:39:02.131', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086742121, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4620, \"rssi\": -65}}', '2026-10-27 15:39:02.131');
INSERT INTO `device_heartbeat_record` VALUES (1841, 'B4BFE90CDBA1', 4650, '2026-10-27 15:39:32.149', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086772129, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4650, \"rssi\": -65}}', '2026-10-27 15:39:32.150');
INSERT INTO `device_heartbeat_record` VALUES (1842, 'B4BFE90CDBA1', 4680, '2026-10-27 15:40:02.143', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086802132, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4680, \"rssi\": -65}}', '2026-10-27 15:40:02.143');
INSERT INTO `device_heartbeat_record` VALUES (1843, 'B4BFE90CDBA1', 4710, '2026-10-27 15:40:32.163', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086832147, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4710, \"rssi\": -65}}', '2026-10-27 15:40:32.164');
INSERT INTO `device_heartbeat_record` VALUES (1844, 'B4BFE90CDBA1', 4740, '2026-10-27 15:41:02.170', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086862153, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4740, \"rssi\": -65}}', '2026-10-27 15:41:02.171');
INSERT INTO `device_heartbeat_record` VALUES (1845, 'B4BFE90CDBA1', 4770, '2026-10-27 15:41:32.167', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086892156, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4770, \"rssi\": -65}}', '2026-10-27 15:41:32.167');
INSERT INTO `device_heartbeat_record` VALUES (1846, 'B4BFE90CDBA1', 4800, '2026-10-27 15:42:02.186', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086922170, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4800, \"rssi\": -65}}', '2026-10-27 15:42:02.188');
INSERT INTO `device_heartbeat_record` VALUES (1847, 'B4BFE90CDBA1', 4830, '2026-10-27 15:42:32.194', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086952175, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4830, \"rssi\": -65}}', '2026-10-27 15:42:32.198');
INSERT INTO `device_heartbeat_record` VALUES (1848, 'B4BFE90CDBA1', 4860, '2026-10-27 15:43:02.203', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793086982181, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4860, \"rssi\": -65}}', '2026-10-27 15:43:02.204');
INSERT INTO `device_heartbeat_record` VALUES (1849, 'B4BFE90CDBA1', 4890, '2026-10-27 15:43:32.201', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087012190, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4890, \"rssi\": -65}}', '2026-10-27 15:43:32.202');
INSERT INTO `device_heartbeat_record` VALUES (1850, 'B4BFE90CDBA1', 4920, '2026-10-27 15:44:02.216', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087042196, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4920, \"rssi\": -65}}', '2026-10-27 15:44:02.217');
INSERT INTO `device_heartbeat_record` VALUES (1851, 'B4BFE90CDBA1', 4950, '2026-10-27 15:44:32.254', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087072210, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4950, \"rssi\": -65}}', '2026-10-27 15:44:32.255');
INSERT INTO `device_heartbeat_record` VALUES (1852, 'B4BFE90CDBA1', 4980, '2026-10-27 15:45:02.241', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087102221, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 4980, \"rssi\": -65}}', '2026-10-27 15:45:02.242');
INSERT INTO `device_heartbeat_record` VALUES (1853, 'B4BFE90CDBA1', 5010, '2026-10-27 15:45:32.248', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087132233, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5010, \"rssi\": -65}}', '2026-10-27 15:45:32.248');
INSERT INTO `device_heartbeat_record` VALUES (1854, 'B4BFE90CDBA1', 5040, '2026-10-27 15:46:02.257', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087162240, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5040, \"rssi\": -65}}', '2026-10-27 15:46:02.259');
INSERT INTO `device_heartbeat_record` VALUES (1855, 'B4BFE90CDBA1', 5070, '2026-10-27 15:46:32.266', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087192254, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5070, \"rssi\": -65}}', '2026-10-27 15:46:32.266');
INSERT INTO `device_heartbeat_record` VALUES (1856, 'B4BFE90CDBA1', 5100, '2026-10-27 15:47:02.268', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087222257, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5100, \"rssi\": -65}}', '2026-10-27 15:47:02.269');
INSERT INTO `device_heartbeat_record` VALUES (1857, 'B4BFE90CDBA1', 5130, '2026-10-27 15:47:32.282', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087252271, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5130, \"rssi\": -65}}', '2026-10-27 15:47:32.283');
INSERT INTO `device_heartbeat_record` VALUES (1858, 'B4BFE90CDBA1', 5160, '2026-10-27 15:48:02.293', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087282277, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5160, \"rssi\": -65}}', '2026-10-27 15:48:02.293');
INSERT INTO `device_heartbeat_record` VALUES (1859, 'B4BFE90CDBA1', 5190, '2026-10-27 15:48:32.300', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087312290, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5190, \"rssi\": -65}}', '2026-10-27 15:48:32.301');
INSERT INTO `device_heartbeat_record` VALUES (1860, 'B4BFE90CDBA1', 5220, '2026-10-27 15:49:02.315', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087342294, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5220, \"rssi\": -65}}', '2026-10-27 15:49:02.316');
INSERT INTO `device_heartbeat_record` VALUES (1861, 'B4BFE90CDBA1', 5250, '2026-10-27 15:49:32.318', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087372297, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5250, \"rssi\": -65}}', '2026-10-27 15:49:32.318');
INSERT INTO `device_heartbeat_record` VALUES (1862, 'B4BFE90CDBA1', 5280, '2026-10-27 15:50:02.309', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087402299, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5280, \"rssi\": -65}}', '2026-10-27 15:50:02.309');
INSERT INTO `device_heartbeat_record` VALUES (1863, 'B4BFE90CDBA1', 5310, '2026-10-27 15:50:32.329', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087432307, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5310, \"rssi\": -65}}', '2026-10-27 15:50:32.331');
INSERT INTO `device_heartbeat_record` VALUES (1864, 'B4BFE90CDBA1', 5340, '2026-10-27 15:51:02.329', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087462320, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5340, \"rssi\": -65}}', '2026-10-27 15:51:02.330');
INSERT INTO `device_heartbeat_record` VALUES (1865, 'B4BFE90CDBA1', 5370, '2026-10-27 15:51:32.351', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087492330, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5370, \"rssi\": -65}}', '2026-10-27 15:51:32.353');
INSERT INTO `device_heartbeat_record` VALUES (1866, 'B4BFE90CDBA1', 5400, '2026-10-27 15:52:02.391', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087522347, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5400, \"rssi\": -65}}', '2026-10-27 15:52:02.392');
INSERT INTO `device_heartbeat_record` VALUES (1867, 'B4BFE90CDBA1', 5430, '2026-10-27 15:52:32.365', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087552355, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5430, \"rssi\": -65}}', '2026-10-27 15:52:32.366');
INSERT INTO `device_heartbeat_record` VALUES (1868, 'B4BFE90CDBA1', 5460, '2026-10-27 15:53:02.362', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087582356, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5460, \"rssi\": -65}}', '2026-10-27 15:53:02.363');
INSERT INTO `device_heartbeat_record` VALUES (1869, 'B4BFE90CDBA1', 5490, '2026-10-27 15:53:32.375', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087612368, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5490, \"rssi\": -65}}', '2026-10-27 15:53:32.375');
INSERT INTO `device_heartbeat_record` VALUES (1870, 'B4BFE90CDBA1', 5520, '2026-10-27 15:54:02.382', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087642368, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5520, \"rssi\": -65}}', '2026-10-27 15:54:02.383');
INSERT INTO `device_heartbeat_record` VALUES (1871, 'B4BFE90CDBA1', 5550, '2026-10-27 15:54:32.396', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087672383, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5550, \"rssi\": -65}}', '2026-10-27 15:54:32.397');
INSERT INTO `device_heartbeat_record` VALUES (1872, 'B4BFE90CDBA1', 5580, '2026-10-27 15:55:02.409', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087702395, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5580, \"rssi\": -65}}', '2026-10-27 15:55:02.409');
INSERT INTO `device_heartbeat_record` VALUES (1873, 'B4BFE90CDBA1', 5610, '2026-10-27 15:55:32.423', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087732411, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5610, \"rssi\": -65}}', '2026-10-27 15:55:32.423');
INSERT INTO `device_heartbeat_record` VALUES (1874, 'B4BFE90CDBA1', 5640, '2026-10-27 15:56:02.437', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087762417, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5640, \"rssi\": -65}}', '2026-10-27 15:56:02.438');
INSERT INTO `device_heartbeat_record` VALUES (1875, 'B4BFE90CDBA1', 5670, '2026-10-27 15:56:32.442', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087792431, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5670, \"rssi\": -65}}', '2026-10-27 15:56:32.442');
INSERT INTO `device_heartbeat_record` VALUES (1876, 'B4BFE90CDBA1', 5700, '2026-10-27 15:57:02.458', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087822446, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5700, \"rssi\": -65}}', '2026-10-27 15:57:02.458');
INSERT INTO `device_heartbeat_record` VALUES (1877, 'B4BFE90CDBA1', 5730, '2026-10-27 15:57:32.472', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087852459, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5730, \"rssi\": -65}}', '2026-10-27 15:57:32.473');
INSERT INTO `device_heartbeat_record` VALUES (1878, 'B4BFE90CDBA1', 5760, '2026-10-27 15:58:02.484', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087882469, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5760, \"rssi\": -65}}', '2026-10-27 15:58:02.484');
INSERT INTO `device_heartbeat_record` VALUES (1879, 'B4BFE90CDBA1', 5790, '2026-10-27 15:58:32.488', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087912472, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5790, \"rssi\": -65}}', '2026-10-27 15:58:32.488');
INSERT INTO `device_heartbeat_record` VALUES (1880, 'B4BFE90CDBA1', 5820, '2026-10-27 15:59:02.493', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087942488, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5820, \"rssi\": -65}}', '2026-10-27 15:59:02.493');
INSERT INTO `device_heartbeat_record` VALUES (1881, 'B4BFE90CDBA1', 5850, '2026-10-27 15:59:32.545', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793087972503, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5850, \"rssi\": -65}}', '2026-10-27 15:59:32.546');
INSERT INTO `device_heartbeat_record` VALUES (1882, 'B4BFE90CDBA1', 5880, '2026-10-27 16:00:02.529', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088002515, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5880, \"rssi\": -65}}', '2026-10-27 16:00:02.529');
INSERT INTO `device_heartbeat_record` VALUES (1883, 'B4BFE90CDBA1', 5910, '2026-10-27 16:00:32.535', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088032527, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5910, \"rssi\": -65}}', '2026-10-27 16:00:32.535');
INSERT INTO `device_heartbeat_record` VALUES (1884, 'B4BFE90CDBA1', 5940, '2026-10-27 16:01:02.533', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088062526, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5940, \"rssi\": -65}}', '2026-10-27 16:01:02.533');
INSERT INTO `device_heartbeat_record` VALUES (1885, 'B4BFE90CDBA1', 5970, '2026-10-27 16:01:32.549', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088092537, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 5970, \"rssi\": -65}}', '2026-10-27 16:01:32.549');
INSERT INTO `device_heartbeat_record` VALUES (1886, 'B4BFE90CDBA1', 6000, '2026-10-27 16:02:02.563', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088122549, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6000, \"rssi\": -65}}', '2026-10-27 16:02:02.564');
INSERT INTO `device_heartbeat_record` VALUES (1887, 'B4BFE90CDBA1', 6030, '2026-10-27 16:02:32.568', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088152554, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6030, \"rssi\": -65}}', '2026-10-27 16:02:32.569');
INSERT INTO `device_heartbeat_record` VALUES (1888, 'B4BFE90CDBA1', 6060, '2026-10-27 16:03:02.570', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088182560, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6060, \"rssi\": -65}}', '2026-10-27 16:03:02.570');
INSERT INTO `device_heartbeat_record` VALUES (1889, 'B4BFE90CDBA1', 6090, '2026-10-27 16:03:32.586', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088212573, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6090, \"rssi\": -65}}', '2026-10-27 16:03:32.594');
INSERT INTO `device_heartbeat_record` VALUES (1890, 'B4BFE90CDBA1', 6120, '2026-10-27 16:04:02.608', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088242585, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6120, \"rssi\": -65}}', '2026-10-27 16:04:02.609');
INSERT INTO `device_heartbeat_record` VALUES (1891, 'B4BFE90CDBA1', 6150, '2026-10-27 16:04:32.618', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088272595, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6150, \"rssi\": -65}}', '2026-10-27 16:04:32.619');
INSERT INTO `device_heartbeat_record` VALUES (1892, 'B4BFE90CDBA1', 6180, '2026-10-27 16:05:02.614', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088302602, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6180, \"rssi\": -65}}', '2026-10-27 16:05:02.615');
INSERT INTO `device_heartbeat_record` VALUES (1893, 'B4BFE90CDBA1', 6210, '2026-10-27 16:05:32.620', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088332610, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6210, \"rssi\": -65}}', '2026-10-27 16:05:32.621');
INSERT INTO `device_heartbeat_record` VALUES (1894, 'B4BFE90CDBA1', 6240, '2026-10-27 16:06:02.627', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088362613, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6240, \"rssi\": -65}}', '2026-10-27 16:06:02.627');
INSERT INTO `device_heartbeat_record` VALUES (1895, 'B4BFE90CDBA1', 6270, '2026-10-27 16:06:32.634', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088392620, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6270, \"rssi\": -65}}', '2026-10-27 16:06:32.636');
INSERT INTO `device_heartbeat_record` VALUES (1896, 'B4BFE90CDBA1', 6300, '2026-10-27 16:07:02.644', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088422633, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6300, \"rssi\": -65}}', '2026-10-27 16:07:02.644');
INSERT INTO `device_heartbeat_record` VALUES (1897, 'B4BFE90CDBA1', 6330, '2026-10-27 16:07:32.650', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088452639, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6330, \"rssi\": -65}}', '2026-10-27 16:07:32.651');
INSERT INTO `device_heartbeat_record` VALUES (1898, 'B4BFE90CDBA1', 6360, '2026-10-27 16:08:02.668', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088482653, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6360, \"rssi\": -65}}', '2026-10-27 16:08:02.669');
INSERT INTO `device_heartbeat_record` VALUES (1899, 'B4BFE90CDBA1', 6390, '2026-10-27 16:08:32.669', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088512657, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6390, \"rssi\": -65}}', '2026-10-27 16:08:32.669');
INSERT INTO `device_heartbeat_record` VALUES (1900, 'B4BFE90CDBA1', 6420, '2026-10-27 16:09:02.682', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088542673, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6420, \"rssi\": -65}}', '2026-10-27 16:09:02.682');
INSERT INTO `device_heartbeat_record` VALUES (1901, 'B4BFE90CDBA1', 6450, '2026-10-27 16:09:32.696', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088572683, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6450, \"rssi\": -65}}', '2026-10-27 16:09:32.697');
INSERT INTO `device_heartbeat_record` VALUES (1902, 'B4BFE90CDBA1', 6480, '2026-10-27 16:10:02.707', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088602697, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6480, \"rssi\": -65}}', '2026-10-27 16:10:02.707');
INSERT INTO `device_heartbeat_record` VALUES (1903, 'B4BFE90CDBA1', 6510, '2026-10-27 16:10:32.715', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088632703, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6510, \"rssi\": -65}}', '2026-10-27 16:10:32.715');
INSERT INTO `device_heartbeat_record` VALUES (1904, 'B4BFE90CDBA1', 6540, '2026-10-27 16:11:02.723', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088662713, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6540, \"rssi\": -65}}', '2026-10-27 16:11:02.723');
INSERT INTO `device_heartbeat_record` VALUES (1905, 'B4BFE90CDBA1', 6570, '2026-10-27 16:11:32.737', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088692716, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6570, \"rssi\": -65}}', '2026-10-27 16:11:32.737');
INSERT INTO `device_heartbeat_record` VALUES (1906, 'B4BFE90CDBA1', 6600, '2026-10-27 16:12:02.732', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088722721, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6600, \"rssi\": -65}}', '2026-10-27 16:12:02.732');
INSERT INTO `device_heartbeat_record` VALUES (1907, 'B4BFE90CDBA1', 6630, '2026-10-27 16:12:32.747', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088752733, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6630, \"rssi\": -65}}', '2026-10-27 16:12:32.748');
INSERT INTO `device_heartbeat_record` VALUES (1908, 'B4BFE90CDBA1', 6660, '2026-10-27 16:13:02.750', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088782737, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6660, \"rssi\": -65}}', '2026-10-27 16:13:02.751');
INSERT INTO `device_heartbeat_record` VALUES (1909, 'B4BFE90CDBA1', 6690, '2026-10-27 16:13:32.749', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088812739, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6690, \"rssi\": -65}}', '2026-10-27 16:13:32.749');
INSERT INTO `device_heartbeat_record` VALUES (1910, 'B4BFE90CDBA1', 6720, '2026-10-27 16:14:02.762', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088842751, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6720, \"rssi\": -65}}', '2026-10-27 16:14:02.764');
INSERT INTO `device_heartbeat_record` VALUES (1911, 'B4BFE90CDBA1', 6750, '2026-10-27 16:14:32.769', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088872758, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6750, \"rssi\": -65}}', '2026-10-27 16:14:32.769');
INSERT INTO `device_heartbeat_record` VALUES (1912, 'B4BFE90CDBA1', 6780, '2026-10-27 16:15:02.784', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088902773, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6780, \"rssi\": -65}}', '2026-10-27 16:15:02.784');
INSERT INTO `device_heartbeat_record` VALUES (1913, 'B4BFE90CDBA1', 6810, '2026-10-27 16:15:32.798', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088932784, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6810, \"rssi\": -65}}', '2026-10-27 16:15:32.799');
INSERT INTO `device_heartbeat_record` VALUES (1914, 'B4BFE90CDBA1', 6840, '2026-10-27 16:16:02.798', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088962789, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6840, \"rssi\": -65}}', '2026-10-27 16:16:02.798');
INSERT INTO `device_heartbeat_record` VALUES (1915, 'B4BFE90CDBA1', 6870, '2026-10-27 16:16:32.818', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793088992805, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6870, \"rssi\": -65}}', '2026-10-27 16:16:32.819');
INSERT INTO `device_heartbeat_record` VALUES (1916, 'B4BFE90CDBA1', 6900, '2026-10-27 16:17:02.824', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089022814, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6900, \"rssi\": -65}}', '2026-10-27 16:17:02.825');
INSERT INTO `device_heartbeat_record` VALUES (1917, 'B4BFE90CDBA1', 6930, '2026-10-27 16:17:32.843', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089052830, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6930, \"rssi\": -65}}', '2026-10-27 16:17:32.843');
INSERT INTO `device_heartbeat_record` VALUES (1918, 'B4BFE90CDBA1', 6960, '2026-10-27 16:18:02.850', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089082836, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6960, \"rssi\": -65}}', '2026-10-27 16:18:02.850');
INSERT INTO `device_heartbeat_record` VALUES (1919, 'B4BFE90CDBA1', 6990, '2026-10-27 16:18:32.855', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089112845, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 6990, \"rssi\": -65}}', '2026-10-27 16:18:32.855');
INSERT INTO `device_heartbeat_record` VALUES (1920, 'B4BFE90CDBA1', 7020, '2026-10-27 16:19:02.867', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089142856, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7020, \"rssi\": -65}}', '2026-10-27 16:19:02.867');
INSERT INTO `device_heartbeat_record` VALUES (1921, 'B4BFE90CDBA1', 7050, '2026-10-27 16:19:32.886', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089172871, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7050, \"rssi\": -65}}', '2026-10-27 16:19:32.886');
INSERT INTO `device_heartbeat_record` VALUES (1922, 'B4BFE90CDBA1', 7080, '2026-10-27 16:20:02.892', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089202877, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7080, \"rssi\": -65}}', '2026-10-27 16:20:02.893');
INSERT INTO `device_heartbeat_record` VALUES (1923, 'B4BFE90CDBA1', 7110, '2026-10-27 16:20:32.902', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089232892, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7110, \"rssi\": -65}}', '2026-10-27 16:20:32.902');
INSERT INTO `device_heartbeat_record` VALUES (1924, 'B4BFE90CDBA1', 7140, '2026-10-27 16:21:02.905', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089262896, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7140, \"rssi\": -65}}', '2026-10-27 16:21:02.907');
INSERT INTO `device_heartbeat_record` VALUES (1925, 'B4BFE90CDBA1', 7170, '2026-10-27 16:21:32.919', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089292906, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7170, \"rssi\": -65}}', '2026-10-27 16:21:32.919');
INSERT INTO `device_heartbeat_record` VALUES (1926, 'B4BFE90CDBA1', 7200, '2026-10-27 16:22:02.929', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089322918, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7200, \"rssi\": -65}}', '2026-10-27 16:22:02.930');
INSERT INTO `device_heartbeat_record` VALUES (1927, 'B4BFE90CDBA1', 7230, '2026-10-27 16:22:32.950', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089352933, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7230, \"rssi\": -65}}', '2026-10-27 16:22:32.950');
INSERT INTO `device_heartbeat_record` VALUES (1928, 'B4BFE90CDBA1', 7260, '2026-10-27 16:23:02.958', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089382945, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7260, \"rssi\": -65}}', '2026-10-27 16:23:02.959');
INSERT INTO `device_heartbeat_record` VALUES (1929, 'B4BFE90CDBA1', 7290, '2026-10-27 16:23:32.969', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089412954, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7290, \"rssi\": -65}}', '2026-10-27 16:23:32.969');
INSERT INTO `device_heartbeat_record` VALUES (1930, 'B4BFE90CDBA1', 7320, '2026-10-27 16:24:02.968', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089442955, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7320, \"rssi\": -65}}', '2026-10-27 16:24:02.969');
INSERT INTO `device_heartbeat_record` VALUES (1931, 'B4BFE90CDBA1', 7350, '2026-10-27 16:24:32.979', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089472971, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7350, \"rssi\": -65}}', '2026-10-27 16:24:32.979');
INSERT INTO `device_heartbeat_record` VALUES (1932, 'B4BFE90CDBA1', 7380, '2026-10-27 16:25:03.029', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089502986, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7380, \"rssi\": -65}}', '2026-10-27 16:25:03.030');
INSERT INTO `device_heartbeat_record` VALUES (1933, 'B4BFE90CDBA1', 7410, '2026-10-27 16:25:33.008', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089532994, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7410, \"rssi\": -65}}', '2026-10-27 16:25:33.009');
INSERT INTO `device_heartbeat_record` VALUES (1934, 'B4BFE90CDBA1', 7440, '2026-10-27 16:26:03.004', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089562995, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7440, \"rssi\": -65}}', '2026-10-27 16:26:03.004');
INSERT INTO `device_heartbeat_record` VALUES (1935, 'B4BFE90CDBA1', 7470, '2026-10-27 16:26:33.020', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089593009, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7470, \"rssi\": -65}}', '2026-10-27 16:26:33.021');
INSERT INTO `device_heartbeat_record` VALUES (1936, 'B4BFE90CDBA1', 7500, '2026-10-27 16:27:03.036', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089623024, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7500, \"rssi\": -65}}', '2026-10-27 16:27:03.036');
INSERT INTO `device_heartbeat_record` VALUES (1937, 'B4BFE90CDBA1', 7530, '2026-10-27 16:27:33.052', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089653035, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7530, \"rssi\": -65}}', '2026-10-27 16:27:33.053');
INSERT INTO `device_heartbeat_record` VALUES (1938, 'B4BFE90CDBA1', 7560, '2026-10-27 16:28:03.057', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089683045, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7560, \"rssi\": -65}}', '2026-10-27 16:28:03.057');
INSERT INTO `device_heartbeat_record` VALUES (1939, 'B4BFE90CDBA1', 7590, '2026-10-27 16:28:33.078', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089713063, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7590, \"rssi\": -65}}', '2026-10-27 16:28:33.078');
INSERT INTO `device_heartbeat_record` VALUES (1940, 'B4BFE90CDBA1', 7620, '2026-10-27 16:29:03.081', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089743072, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7620, \"rssi\": -65}}', '2026-10-27 16:29:03.082');
INSERT INTO `device_heartbeat_record` VALUES (1941, 'B4BFE90CDBA1', 7650, '2026-10-27 16:29:33.083', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089773073, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7650, \"rssi\": -65}}', '2026-10-27 16:29:33.084');
INSERT INTO `device_heartbeat_record` VALUES (1942, 'B4BFE90CDBA1', 7680, '2026-10-27 16:30:03.094', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089803077, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7680, \"rssi\": -65}}', '2026-10-27 16:30:03.095');
INSERT INTO `device_heartbeat_record` VALUES (1943, 'B4BFE90CDBA1', 7710, '2026-10-27 16:30:33.107', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089833091, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7710, \"rssi\": -65}}', '2026-10-27 16:30:33.108');
INSERT INTO `device_heartbeat_record` VALUES (1944, 'B4BFE90CDBA1', 7740, '2026-10-27 16:31:03.114', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089863097, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7740, \"rssi\": -65}}', '2026-10-27 16:31:03.114');
INSERT INTO `device_heartbeat_record` VALUES (1945, 'B4BFE90CDBA1', 7770, '2026-10-27 16:31:33.116', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089893106, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7770, \"rssi\": -65}}', '2026-10-27 16:31:33.117');
INSERT INTO `device_heartbeat_record` VALUES (1946, 'B4BFE90CDBA1', 7800, '2026-10-27 16:32:03.140', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089923121, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7800, \"rssi\": -65}}', '2026-10-27 16:32:03.140');
INSERT INTO `device_heartbeat_record` VALUES (1947, 'B4BFE90CDBA1', 7830, '2026-10-27 16:32:33.142', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089953130, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7830, \"rssi\": -65}}', '2026-10-27 16:32:33.143');
INSERT INTO `device_heartbeat_record` VALUES (1948, 'B4BFE90CDBA1', 7860, '2026-10-27 16:33:03.154', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793089983144, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7860, \"rssi\": -65}}', '2026-10-27 16:33:03.155');
INSERT INTO `device_heartbeat_record` VALUES (1949, 'B4BFE90CDBA1', 7890, '2026-10-27 16:33:33.170', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090013157, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7890, \"rssi\": -65}}', '2026-10-27 16:33:33.171');
INSERT INTO `device_heartbeat_record` VALUES (1950, 'B4BFE90CDBA1', 7920, '2026-10-27 16:34:03.177', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090043167, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7920, \"rssi\": -65}}', '2026-10-27 16:34:03.177');
INSERT INTO `device_heartbeat_record` VALUES (1951, 'B4BFE90CDBA1', 7950, '2026-10-27 16:34:33.187', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090073173, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7950, \"rssi\": -65}}', '2026-10-27 16:34:33.187');
INSERT INTO `device_heartbeat_record` VALUES (1952, 'B4BFE90CDBA1', 7980, '2026-10-27 16:35:03.193', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090103188, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 7980, \"rssi\": -65}}', '2026-10-27 16:35:03.195');
INSERT INTO `device_heartbeat_record` VALUES (1953, 'B4BFE90CDBA1', 8010, '2026-10-27 16:35:33.202', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090133193, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8010, \"rssi\": -65}}', '2026-10-27 16:35:33.202');
INSERT INTO `device_heartbeat_record` VALUES (1954, 'B4BFE90CDBA1', 8040, '2026-10-27 16:36:03.209', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090163198, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8040, \"rssi\": -65}}', '2026-10-27 16:36:03.210');
INSERT INTO `device_heartbeat_record` VALUES (1955, 'B4BFE90CDBA1', 8070, '2026-10-27 16:36:33.222', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090193211, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8070, \"rssi\": -65}}', '2026-10-27 16:36:33.222');
INSERT INTO `device_heartbeat_record` VALUES (1956, 'B4BFE90CDBA1', 8100, '2026-10-27 16:37:03.230', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090223223, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8100, \"rssi\": -65}}', '2026-10-27 16:37:03.230');
INSERT INTO `device_heartbeat_record` VALUES (1957, 'B4BFE90CDBA1', 8130, '2026-10-27 16:37:33.242', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090253230, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8130, \"rssi\": -65}}', '2026-10-27 16:37:33.242');
INSERT INTO `device_heartbeat_record` VALUES (1958, 'B4BFE90CDBA1', 8160, '2026-10-27 16:38:03.242', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090283231, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8160, \"rssi\": -65}}', '2026-10-27 16:38:03.242');
INSERT INTO `device_heartbeat_record` VALUES (1959, 'B4BFE90CDBA1', 8190, '2026-10-27 16:38:33.243', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090313237, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8190, \"rssi\": -65}}', '2026-10-27 16:38:33.244');
INSERT INTO `device_heartbeat_record` VALUES (1960, 'B4BFE90CDBA1', 8220, '2026-10-27 16:39:03.248', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090343239, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8220, \"rssi\": -65}}', '2026-10-27 16:39:03.248');
INSERT INTO `device_heartbeat_record` VALUES (1961, 'B4BFE90CDBA1', 8250, '2026-10-27 16:39:33.267', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090373254, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8250, \"rssi\": -65}}', '2026-10-27 16:39:33.268');
INSERT INTO `device_heartbeat_record` VALUES (1962, 'B4BFE90CDBA1', 8280, '2026-10-27 16:40:03.271', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090403263, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8280, \"rssi\": -65}}', '2026-10-27 16:40:03.271');
INSERT INTO `device_heartbeat_record` VALUES (1963, 'B4BFE90CDBA1', 8310, '2026-10-27 16:40:33.279', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090433270, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8310, \"rssi\": -65}}', '2026-10-27 16:40:33.279');
INSERT INTO `device_heartbeat_record` VALUES (1964, 'B4BFE90CDBA1', 8340, '2026-10-27 16:41:03.286', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090463277, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8340, \"rssi\": -65}}', '2026-10-27 16:41:03.287');
INSERT INTO `device_heartbeat_record` VALUES (1965, 'B4BFE90CDBA1', 8370, '2026-10-27 16:41:33.295', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090493283, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8370, \"rssi\": -65}}', '2026-10-27 16:41:33.295');
INSERT INTO `device_heartbeat_record` VALUES (1966, 'B4BFE90CDBA1', 8400, '2026-10-27 16:42:03.299', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090523291, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8400, \"rssi\": -65}}', '2026-10-27 16:42:03.300');
INSERT INTO `device_heartbeat_record` VALUES (1967, 'B4BFE90CDBA1', 8430, '2026-10-27 16:42:33.315', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090553302, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8430, \"rssi\": -65}}', '2026-10-27 16:42:33.315');
INSERT INTO `device_heartbeat_record` VALUES (1968, 'B4BFE90CDBA1', 8460, '2026-10-27 16:43:03.320', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090583308, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8460, \"rssi\": -65}}', '2026-10-27 16:43:03.320');
INSERT INTO `device_heartbeat_record` VALUES (1969, 'B4BFE90CDBA1', 8490, '2026-10-27 16:43:33.333', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090613323, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8490, \"rssi\": -65}}', '2026-10-27 16:43:33.333');
INSERT INTO `device_heartbeat_record` VALUES (1970, 'B4BFE90CDBA1', 8520, '2026-10-27 16:44:03.340', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090643327, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8520, \"rssi\": -65}}', '2026-10-27 16:44:03.341');
INSERT INTO `device_heartbeat_record` VALUES (1971, 'B4BFE90CDBA1', 8550, '2026-10-27 16:44:33.351', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090673339, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8550, \"rssi\": -65}}', '2026-10-27 16:44:33.352');
INSERT INTO `device_heartbeat_record` VALUES (1972, 'B4BFE90CDBA1', 8580, '2026-10-27 16:45:03.361', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090703348, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8580, \"rssi\": -65}}', '2026-10-27 16:45:03.361');
INSERT INTO `device_heartbeat_record` VALUES (1973, 'B4BFE90CDBA1', 8610, '2026-10-27 16:45:33.371', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090733355, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8610, \"rssi\": -65}}', '2026-10-27 16:45:33.371');
INSERT INTO `device_heartbeat_record` VALUES (1974, 'B4BFE90CDBA1', 8640, '2026-10-27 16:46:03.376', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090763364, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8640, \"rssi\": -65}}', '2026-10-27 16:46:03.377');
INSERT INTO `device_heartbeat_record` VALUES (1975, 'B4BFE90CDBA1', 8670, '2026-10-27 16:46:33.388', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090793376, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8670, \"rssi\": -65}}', '2026-10-27 16:46:33.388');
INSERT INTO `device_heartbeat_record` VALUES (1976, 'B4BFE90CDBA1', 8700, '2026-10-27 16:47:03.399', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090823390, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8700, \"rssi\": -65}}', '2026-10-27 16:47:03.400');
INSERT INTO `device_heartbeat_record` VALUES (1977, 'B4BFE90CDBA1', 8730, '2026-10-27 16:47:33.406', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090853391, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8730, \"rssi\": -65}}', '2026-10-27 16:47:33.407');
INSERT INTO `device_heartbeat_record` VALUES (1978, 'B4BFE90CDBA1', 8760, '2026-10-27 16:48:03.414', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090883402, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8760, \"rssi\": -65}}', '2026-10-27 16:48:03.414');
INSERT INTO `device_heartbeat_record` VALUES (1979, 'B4BFE90CDBA1', 8790, '2026-10-27 16:48:33.414', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090913405, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8790, \"rssi\": -65}}', '2026-10-27 16:48:33.414');
INSERT INTO `device_heartbeat_record` VALUES (1980, 'B4BFE90CDBA1', 8820, '2026-10-27 16:49:03.419', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090943409, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8820, \"rssi\": -65}}', '2026-10-27 16:49:03.419');
INSERT INTO `device_heartbeat_record` VALUES (1981, 'B4BFE90CDBA1', 8850, '2026-10-27 16:49:33.424', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793090973411, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8850, \"rssi\": -65}}', '2026-10-27 16:49:33.425');
INSERT INTO `device_heartbeat_record` VALUES (1982, 'B4BFE90CDBA1', 8880, '2026-10-27 16:50:03.430', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091003417, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8880, \"rssi\": -65}}', '2026-10-27 16:50:03.431');
INSERT INTO `device_heartbeat_record` VALUES (1983, 'B4BFE90CDBA1', 8910, '2026-10-27 16:50:33.441', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091033430, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8910, \"rssi\": -65}}', '2026-10-27 16:50:33.441');
INSERT INTO `device_heartbeat_record` VALUES (1984, 'B4BFE90CDBA1', 8940, '2026-10-27 16:51:03.448', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091063438, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8940, \"rssi\": -65}}', '2026-10-27 16:51:03.448');
INSERT INTO `device_heartbeat_record` VALUES (1985, 'B4BFE90CDBA1', 8970, '2026-10-27 16:51:33.462', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091093447, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 8970, \"rssi\": -65}}', '2026-10-27 16:51:33.462');
INSERT INTO `device_heartbeat_record` VALUES (1986, 'B4BFE90CDBA1', 9000, '2026-10-27 16:52:03.464', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091123452, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9000, \"rssi\": -65}}', '2026-10-27 16:52:03.465');
INSERT INTO `device_heartbeat_record` VALUES (1987, 'B4BFE90CDBA1', 9030, '2026-10-27 16:52:33.467', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091153455, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9030, \"rssi\": -65}}', '2026-10-27 16:52:33.467');
INSERT INTO `device_heartbeat_record` VALUES (1988, 'B4BFE90CDBA1', 9060, '2026-10-27 16:53:03.468', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091183461, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9060, \"rssi\": -65}}', '2026-10-27 16:53:03.468');
INSERT INTO `device_heartbeat_record` VALUES (1989, 'B4BFE90CDBA1', 9090, '2026-10-27 16:53:33.481', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091213472, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9090, \"rssi\": -65}}', '2026-10-27 16:53:33.481');
INSERT INTO `device_heartbeat_record` VALUES (1990, 'B4BFE90CDBA1', 9120, '2026-10-27 16:54:03.496', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091243483, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9120, \"rssi\": -65}}', '2026-10-27 16:54:03.497');
INSERT INTO `device_heartbeat_record` VALUES (1991, 'B4BFE90CDBA1', 9150, '2026-10-27 16:54:33.497', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091273486, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9150, \"rssi\": -65}}', '2026-10-27 16:54:33.497');
INSERT INTO `device_heartbeat_record` VALUES (1992, 'B4BFE90CDBA1', 9180, '2026-10-27 16:55:03.507', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091303498, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9180, \"rssi\": -65}}', '2026-10-27 16:55:03.507');
INSERT INTO `device_heartbeat_record` VALUES (1993, 'B4BFE90CDBA1', 9210, '2026-10-27 16:55:33.508', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091333500, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9210, \"rssi\": -65}}', '2026-10-27 16:55:33.509');
INSERT INTO `device_heartbeat_record` VALUES (1994, 'B4BFE90CDBA1', 9240, '2026-10-27 16:56:03.522', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091363512, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9240, \"rssi\": -65}}', '2026-10-27 16:56:03.522');
INSERT INTO `device_heartbeat_record` VALUES (1995, 'B4BFE90CDBA1', 9270, '2026-10-27 16:56:33.529', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091393513, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9270, \"rssi\": -65}}', '2026-10-27 16:56:33.530');
INSERT INTO `device_heartbeat_record` VALUES (1996, 'B4BFE90CDBA1', 9330, '2026-10-27 16:57:33.563', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091453535, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9330, \"rssi\": -65}}', '2026-10-27 16:57:33.564');
INSERT INTO `device_heartbeat_record` VALUES (1997, 'B4BFE90CDBA1', 9360, '2026-10-27 16:58:03.558', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091483547, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9360, \"rssi\": -65}}', '2026-10-27 16:58:03.558');
INSERT INTO `device_heartbeat_record` VALUES (1998, 'B4BFE90CDBA1', 9390, '2026-10-27 16:58:33.565', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091513551, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9390, \"rssi\": -65}}', '2026-10-27 16:58:33.565');
INSERT INTO `device_heartbeat_record` VALUES (1999, 'B4BFE90CDBA1', 9420, '2026-10-27 16:59:03.574', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091543567, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9420, \"rssi\": -65}}', '2026-10-27 16:59:03.574');
INSERT INTO `device_heartbeat_record` VALUES (2000, 'B4BFE90CDBA1', 9450, '2026-10-27 16:59:33.584', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091573569, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9450, \"rssi\": -65}}', '2026-10-27 16:59:33.585');
INSERT INTO `device_heartbeat_record` VALUES (2001, 'B4BFE90CDBA1', 9480, '2026-10-27 17:00:03.613', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091603579, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9480, \"rssi\": -65}}', '2026-10-27 17:00:03.613');
INSERT INTO `device_heartbeat_record` VALUES (2002, 'B4BFE90CDBA1', 9510, '2026-10-27 17:00:33.649', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091633623, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9510, \"rssi\": -65}}', '2026-10-27 17:00:33.651');
INSERT INTO `device_heartbeat_record` VALUES (2003, 'B4BFE90CDBA1', 9540, '2026-10-27 17:01:03.650', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091663642, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9540, \"rssi\": -65}}', '2026-10-27 17:01:03.650');
INSERT INTO `device_heartbeat_record` VALUES (2004, 'B4BFE90CDBA1', 9570, '2026-10-27 17:01:33.659', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091693646, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9570, \"rssi\": -65}}', '2026-10-27 17:01:33.660');
INSERT INTO `device_heartbeat_record` VALUES (2005, 'B4BFE90CDBA1', 9600, '2026-10-27 17:02:03.683', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091723663, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9600, \"rssi\": -65}}', '2026-10-27 17:02:03.684');
INSERT INTO `device_heartbeat_record` VALUES (2006, 'B4BFE90CDBA1', 9630, '2026-10-27 17:02:33.684', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091753664, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9630, \"rssi\": -65}}', '2026-10-27 17:02:33.685');
INSERT INTO `device_heartbeat_record` VALUES (2007, 'B4BFE90CDBA1', 9660, '2026-10-27 17:03:03.690', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091783681, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9660, \"rssi\": -65}}', '2026-10-27 17:03:03.690');
INSERT INTO `device_heartbeat_record` VALUES (2008, 'B4BFE90CDBA1', 9690, '2026-10-27 17:03:33.712', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091813696, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9690, \"rssi\": -65}}', '2026-10-27 17:03:33.712');
INSERT INTO `device_heartbeat_record` VALUES (2009, 'B4BFE90CDBA1', 9720, '2026-10-27 17:04:03.718', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091843709, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9720, \"rssi\": -65}}', '2026-10-27 17:04:03.719');
INSERT INTO `device_heartbeat_record` VALUES (2010, 'B4BFE90CDBA1', 9750, '2026-10-27 17:04:33.733', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091873720, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9750, \"rssi\": -65}}', '2026-10-27 17:04:33.733');
INSERT INTO `device_heartbeat_record` VALUES (2011, 'B4BFE90CDBA1', 9780, '2026-10-27 17:05:03.747', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091903732, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9780, \"rssi\": -65}}', '2026-10-27 17:05:03.748');
INSERT INTO `device_heartbeat_record` VALUES (2012, 'B4BFE90CDBA1', 9810, '2026-10-27 17:05:33.760', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091933739, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9810, \"rssi\": -65}}', '2026-10-27 17:05:33.760');
INSERT INTO `device_heartbeat_record` VALUES (2013, 'B4BFE90CDBA1', 9840, '2026-10-27 17:06:03.762', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091963743, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9840, \"rssi\": -65}}', '2026-10-27 17:06:03.762');
INSERT INTO `device_heartbeat_record` VALUES (2014, 'B4BFE90CDBA1', 9870, '2026-10-27 17:06:33.787', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793091993747, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9870, \"rssi\": -65}}', '2026-10-27 17:06:33.787');
INSERT INTO `device_heartbeat_record` VALUES (2015, 'B4BFE90CDBA1', 9900, '2026-10-27 17:07:03.758', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092023751, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9900, \"rssi\": -65}}', '2026-10-27 17:07:03.758');
INSERT INTO `device_heartbeat_record` VALUES (2016, 'B4BFE90CDBA1', 9930, '2026-10-27 17:07:33.785', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092053767, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9930, \"rssi\": -65}}', '2026-10-27 17:07:33.786');
INSERT INTO `device_heartbeat_record` VALUES (2017, 'B4BFE90CDBA1', 9960, '2026-10-27 17:08:03.777', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092083769, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9960, \"rssi\": -65}}', '2026-10-27 17:08:03.778');
INSERT INTO `device_heartbeat_record` VALUES (2018, 'B4BFE90CDBA1', 9990, '2026-10-27 17:08:33.795', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092113779, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 9990, \"rssi\": -65}}', '2026-10-27 17:08:33.797');
INSERT INTO `device_heartbeat_record` VALUES (2019, 'B4BFE90CDBA1', 10020, '2026-10-27 17:09:03.794', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092143781, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10020, \"rssi\": -65}}', '2026-10-27 17:09:03.794');
INSERT INTO `device_heartbeat_record` VALUES (2020, 'B4BFE90CDBA1', 10050, '2026-10-27 17:09:33.808', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092173791, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10050, \"rssi\": -65}}', '2026-10-27 17:09:33.809');
INSERT INTO `device_heartbeat_record` VALUES (2021, 'B4BFE90CDBA1', 10080, '2026-10-27 17:10:03.810', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092203795, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10080, \"rssi\": -65}}', '2026-10-27 17:10:03.810');
INSERT INTO `device_heartbeat_record` VALUES (2022, 'B4BFE90CDBA1', 10110, '2026-10-27 17:10:33.825', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092233810, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10110, \"rssi\": -65}}', '2026-10-27 17:10:33.826');
INSERT INTO `device_heartbeat_record` VALUES (2023, 'B4BFE90CDBA1', 10140, '2026-10-27 17:11:03.828', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092263815, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10140, \"rssi\": -65}}', '2026-10-27 17:11:03.828');
INSERT INTO `device_heartbeat_record` VALUES (2024, 'B4BFE90CDBA1', 10170, '2026-10-27 17:11:33.833', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092293818, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10170, \"rssi\": -65}}', '2026-10-27 17:11:33.834');
INSERT INTO `device_heartbeat_record` VALUES (2025, 'B4BFE90CDBA1', 10200, '2026-10-27 17:12:03.836', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092323823, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10200, \"rssi\": -65}}', '2026-10-27 17:12:03.837');
INSERT INTO `device_heartbeat_record` VALUES (2026, 'B4BFE90CDBA1', 10230, '2026-10-27 17:12:33.840', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092353827, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10230, \"rssi\": -65}}', '2026-10-27 17:12:33.841');
INSERT INTO `device_heartbeat_record` VALUES (2027, 'B4BFE90CDBA1', 10260, '2026-10-27 17:13:03.855', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092383840, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10260, \"rssi\": -65}}', '2026-10-27 17:13:03.857');
INSERT INTO `device_heartbeat_record` VALUES (2028, 'B4BFE90CDBA1', 10290, '2026-10-27 17:13:33.864', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092413848, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10290, \"rssi\": -65}}', '2026-10-27 17:13:33.866');
INSERT INTO `device_heartbeat_record` VALUES (2029, 'B4BFE90CDBA1', 10320, '2026-10-27 17:14:03.880', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092443861, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10320, \"rssi\": -65}}', '2026-10-27 17:14:03.880');
INSERT INTO `device_heartbeat_record` VALUES (2030, 'B4BFE90CDBA1', 10350, '2026-10-27 17:14:33.890', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092473873, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10350, \"rssi\": -65}}', '2026-10-27 17:14:33.891');
INSERT INTO `device_heartbeat_record` VALUES (2031, 'B4BFE90CDBA1', 10380, '2026-10-27 17:15:03.899', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092503885, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10380, \"rssi\": -65}}', '2026-10-27 17:15:03.899');
INSERT INTO `device_heartbeat_record` VALUES (2032, 'B4BFE90CDBA1', 10410, '2026-10-27 17:15:33.899', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092533889, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10410, \"rssi\": -65}}', '2026-10-27 17:15:33.900');
INSERT INTO `device_heartbeat_record` VALUES (2033, 'B4BFE90CDBA1', 10440, '2026-10-27 17:16:03.918', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092563901, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10440, \"rssi\": -65}}', '2026-10-27 17:16:03.919');
INSERT INTO `device_heartbeat_record` VALUES (2034, 'B4BFE90CDBA1', 10470, '2026-10-27 17:16:33.931', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092593913, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10470, \"rssi\": -65}}', '2026-10-27 17:16:33.932');
INSERT INTO `device_heartbeat_record` VALUES (2035, 'B4BFE90CDBA1', 10500, '2026-10-27 17:17:03.940', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092623917, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10500, \"rssi\": -65}}', '2026-10-27 17:17:03.941');
INSERT INTO `device_heartbeat_record` VALUES (2036, 'B4BFE90CDBA1', 10530, '2026-10-27 17:17:33.944', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092653922, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10530, \"rssi\": -65}}', '2026-10-27 17:17:33.945');
INSERT INTO `device_heartbeat_record` VALUES (2037, 'B4BFE90CDBA1', 10560, '2026-10-27 17:18:03.945', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092683937, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10560, \"rssi\": -65}}', '2026-10-27 17:18:03.948');
INSERT INTO `device_heartbeat_record` VALUES (2038, 'B4BFE90CDBA1', 10590, '2026-10-27 17:18:33.954', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092713949, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10590, \"rssi\": -65}}', '2026-10-27 17:18:33.956');
INSERT INTO `device_heartbeat_record` VALUES (2039, 'B4BFE90CDBA1', 10620, '2026-10-27 17:19:03.960', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092743952, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10620, \"rssi\": -65}}', '2026-10-27 17:19:03.960');
INSERT INTO `device_heartbeat_record` VALUES (2040, 'B4BFE90CDBA1', 10650, '2026-10-27 17:19:33.963', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092773955, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10650, \"rssi\": -65}}', '2026-10-27 17:19:33.963');
INSERT INTO `device_heartbeat_record` VALUES (2041, 'B4BFE90CDBA1', 10680, '2026-10-27 17:20:03.980', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092803971, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10680, \"rssi\": -65}}', '2026-10-27 17:20:03.980');
INSERT INTO `device_heartbeat_record` VALUES (2042, 'B4BFE90CDBA1', 10710, '2026-10-27 17:20:34.004', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092833985, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10710, \"rssi\": -65}}', '2026-10-27 17:20:34.005');
INSERT INTO `device_heartbeat_record` VALUES (2043, 'B4BFE90CDBA1', 10740, '2026-10-27 17:21:04.008', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092863997, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10740, \"rssi\": -65}}', '2026-10-27 17:21:04.008');
INSERT INTO `device_heartbeat_record` VALUES (2044, 'B4BFE90CDBA1', 10770, '2026-10-27 17:21:34.022', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092894008, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10770, \"rssi\": -65}}', '2026-10-27 17:21:34.022');
INSERT INTO `device_heartbeat_record` VALUES (2045, 'B4BFE90CDBA1', 10800, '2026-10-27 17:22:04.031', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092924024, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10800, \"rssi\": -65}}', '2026-10-27 17:22:04.032');
INSERT INTO `device_heartbeat_record` VALUES (2046, 'B4BFE90CDBA1', 10830, '2026-10-27 17:22:34.039', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092954034, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10830, \"rssi\": -65}}', '2026-10-27 17:22:34.039');
INSERT INTO `device_heartbeat_record` VALUES (2047, 'B4BFE90CDBA1', 10860, '2026-10-27 17:23:04.055', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793092984040, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10860, \"rssi\": -65}}', '2026-10-27 17:23:04.055');
INSERT INTO `device_heartbeat_record` VALUES (2048, 'B4BFE90CDBA1', 10890, '2026-10-27 17:23:34.066', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093014053, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10890, \"rssi\": -65}}', '2026-10-27 17:23:34.067');
INSERT INTO `device_heartbeat_record` VALUES (2049, 'B4BFE90CDBA1', 10920, '2026-10-27 17:24:04.067', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093044058, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10920, \"rssi\": -65}}', '2026-10-27 17:24:04.067');
INSERT INTO `device_heartbeat_record` VALUES (2050, 'B4BFE90CDBA1', 10950, '2026-10-27 17:24:34.075', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093074061, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10950, \"rssi\": -65}}', '2026-10-27 17:24:34.075');
INSERT INTO `device_heartbeat_record` VALUES (2051, 'B4BFE90CDBA1', 10980, '2026-10-27 17:25:04.083', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093104063, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 10980, \"rssi\": -65}}', '2026-10-27 17:25:04.084');
INSERT INTO `device_heartbeat_record` VALUES (2052, 'B4BFE90CDBA1', 11010, '2026-10-27 17:25:34.099', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093134078, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11010, \"rssi\": -65}}', '2026-10-27 17:25:34.099');
INSERT INTO `device_heartbeat_record` VALUES (2053, 'B4BFE90CDBA1', 11070, '2026-10-27 17:26:34.119', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093194095, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11070, \"rssi\": -65}}', '2026-10-27 17:26:34.120');
INSERT INTO `device_heartbeat_record` VALUES (2054, 'B4BFE90CDBA1', 11100, '2026-10-27 17:27:04.114', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093224098, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11100, \"rssi\": -65}}', '2026-10-27 17:27:04.115');
INSERT INTO `device_heartbeat_record` VALUES (2055, 'B4BFE90CDBA1', 11130, '2026-10-27 17:27:34.124', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093254110, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11130, \"rssi\": -65}}', '2026-10-27 17:27:34.125');
INSERT INTO `device_heartbeat_record` VALUES (2056, 'B4BFE90CDBA1', 11160, '2026-10-27 17:28:04.134', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093284122, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11160, \"rssi\": -65}}', '2026-10-27 17:28:04.134');
INSERT INTO `device_heartbeat_record` VALUES (2057, 'B4BFE90CDBA1', 11190, '2026-10-27 17:28:34.157', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093314135, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11190, \"rssi\": -65}}', '2026-10-27 17:28:34.158');
INSERT INTO `device_heartbeat_record` VALUES (2058, 'B4BFE90CDBA1', 11220, '2026-10-27 17:29:04.164', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093344151, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11220, \"rssi\": -65}}', '2026-10-27 17:29:04.165');
INSERT INTO `device_heartbeat_record` VALUES (2059, 'B4BFE90CDBA1', 11250, '2026-10-27 17:29:34.173', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093374159, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11250, \"rssi\": -65}}', '2026-10-27 17:29:34.173');
INSERT INTO `device_heartbeat_record` VALUES (2060, 'B4BFE90CDBA1', 11280, '2026-10-27 17:30:04.188', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093404166, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11280, \"rssi\": -65}}', '2026-10-27 17:30:04.188');
INSERT INTO `device_heartbeat_record` VALUES (2061, 'B4BFE90CDBA1', 11310, '2026-10-27 17:30:34.178', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093434169, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11310, \"rssi\": -65}}', '2026-10-27 17:30:34.179');
INSERT INTO `device_heartbeat_record` VALUES (2062, 'B4BFE90CDBA1', 11340, '2026-10-27 17:31:04.194', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093464182, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11340, \"rssi\": -65}}', '2026-10-27 17:31:04.194');
INSERT INTO `device_heartbeat_record` VALUES (2063, 'B4BFE90CDBA1', 11370, '2026-10-27 17:31:34.199', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093494184, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11370, \"rssi\": -65}}', '2026-10-27 17:31:34.199');
INSERT INTO `device_heartbeat_record` VALUES (2064, 'B4BFE90CDBA1', 11400, '2026-10-27 17:32:04.206', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093524192, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11400, \"rssi\": -65}}', '2026-10-27 17:32:04.206');
INSERT INTO `device_heartbeat_record` VALUES (2065, 'B4BFE90CDBA1', 11430, '2026-10-27 17:32:34.215', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093554207, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11430, \"rssi\": -65}}', '2026-10-27 17:32:34.215');
INSERT INTO `device_heartbeat_record` VALUES (2066, 'B4BFE90CDBA1', 11460, '2026-10-27 17:33:04.231', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093584220, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11460, \"rssi\": -65}}', '2026-10-27 17:33:04.232');
INSERT INTO `device_heartbeat_record` VALUES (2067, 'B4BFE90CDBA1', 11490, '2026-10-27 17:33:34.234', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093614227, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11490, \"rssi\": -65}}', '2026-10-27 17:33:34.235');
INSERT INTO `device_heartbeat_record` VALUES (2068, 'B4BFE90CDBA1', 11520, '2026-10-27 17:34:04.263', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093644236, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11520, \"rssi\": -65}}', '2026-10-27 17:34:04.264');
INSERT INTO `device_heartbeat_record` VALUES (2069, 'B4BFE90CDBA1', 11550, '2026-10-27 17:34:34.264', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093674241, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11550, \"rssi\": -65}}', '2026-10-27 17:34:34.265');
INSERT INTO `device_heartbeat_record` VALUES (2070, 'B4BFE90CDBA1', 11610, '2026-10-27 17:35:34.327', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093734251, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11610, \"rssi\": -65}}', '2026-10-27 17:35:34.329');
INSERT INTO `device_heartbeat_record` VALUES (2071, 'B4BFE90CDBA1', 11640, '2026-10-27 17:36:04.334', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093764295, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11640, \"rssi\": -65}}', '2026-10-27 17:36:04.334');
INSERT INTO `device_heartbeat_record` VALUES (2072, 'B4BFE90CDBA1', 11670, '2026-10-27 17:36:34.348', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093794332, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11670, \"rssi\": -65}}', '2026-10-27 17:36:34.349');
INSERT INTO `device_heartbeat_record` VALUES (2073, 'B4BFE90CDBA1', 11700, '2026-10-27 17:37:04.359', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093824341, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11700, \"rssi\": -65}}', '2026-10-27 17:37:04.360');
INSERT INTO `device_heartbeat_record` VALUES (2074, 'B4BFE90CDBA1', 11730, '2026-10-27 17:37:34.356', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093854345, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11730, \"rssi\": -65}}', '2026-10-27 17:37:34.357');
INSERT INTO `device_heartbeat_record` VALUES (2075, 'B4BFE90CDBA1', 11760, '2026-10-27 17:38:04.370', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093884348, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11760, \"rssi\": -65}}', '2026-10-27 17:38:04.370');
INSERT INTO `device_heartbeat_record` VALUES (2076, 'B4BFE90CDBA1', 11790, '2026-10-27 17:38:34.369', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093914354, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11790, \"rssi\": -65}}', '2026-10-27 17:38:34.370');
INSERT INTO `device_heartbeat_record` VALUES (2077, 'B4BFE90CDBA1', 11820, '2026-10-27 17:39:04.380', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093944355, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11820, \"rssi\": -65}}', '2026-10-27 17:39:04.380');
INSERT INTO `device_heartbeat_record` VALUES (2078, 'B4BFE90CDBA1', 11850, '2026-10-27 17:39:34.383', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793093974362, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11850, \"rssi\": -65}}', '2026-10-27 17:39:34.383');
INSERT INTO `device_heartbeat_record` VALUES (2079, 'B4BFE90CDBA1', 11880, '2026-10-27 17:40:04.378', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094004364, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11880, \"rssi\": -65}}', '2026-10-27 17:40:04.379');
INSERT INTO `device_heartbeat_record` VALUES (2080, 'B4BFE90CDBA1', 11910, '2026-10-27 17:40:34.392', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094034367, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11910, \"rssi\": -65}}', '2026-10-27 17:40:34.393');
INSERT INTO `device_heartbeat_record` VALUES (2081, 'B4BFE90CDBA1', 11940, '2026-10-27 17:41:04.389', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094064371, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11940, \"rssi\": -65}}', '2026-10-27 17:41:04.390');
INSERT INTO `device_heartbeat_record` VALUES (2082, 'B4BFE90CDBA1', 11970, '2026-10-27 17:41:34.394', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094094381, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 11970, \"rssi\": -65}}', '2026-10-27 17:41:34.395');
INSERT INTO `device_heartbeat_record` VALUES (2083, 'B4BFE90CDBA1', 12000, '2026-10-27 17:42:04.402', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094124382, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12000, \"rssi\": -65}}', '2026-10-27 17:42:04.403');
INSERT INTO `device_heartbeat_record` VALUES (2084, 'B4BFE90CDBA1', 12030, '2026-10-27 17:42:34.410', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094154390, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12030, \"rssi\": -65}}', '2026-10-27 17:42:34.411');
INSERT INTO `device_heartbeat_record` VALUES (2085, 'B4BFE90CDBA1', 12060, '2026-10-27 17:43:04.418', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094184391, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12060, \"rssi\": -65}}', '2026-10-27 17:43:04.420');
INSERT INTO `device_heartbeat_record` VALUES (2086, 'B4BFE90CDBA1', 12090, '2026-10-27 17:43:34.440', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094214408, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12090, \"rssi\": -65}}', '2026-10-27 17:43:34.440');
INSERT INTO `device_heartbeat_record` VALUES (2087, 'B4BFE90CDBA1', 12120, '2026-10-27 17:44:04.432', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094244421, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12120, \"rssi\": -65}}', '2026-10-27 17:44:04.433');
INSERT INTO `device_heartbeat_record` VALUES (2088, 'B4BFE90CDBA1', 12150, '2026-10-27 17:44:34.449', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094274431, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12150, \"rssi\": -65}}', '2026-10-27 17:44:34.450');
INSERT INTO `device_heartbeat_record` VALUES (2089, 'B4BFE90CDBA1', 12180, '2026-10-27 17:45:04.472', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094304447, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12180, \"rssi\": -65}}', '2026-10-27 17:45:04.473');
INSERT INTO `device_heartbeat_record` VALUES (2090, 'B4BFE90CDBA1', 12210, '2026-10-27 17:45:34.487', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094334464, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12210, \"rssi\": -65}}', '2026-10-27 17:45:34.488');
INSERT INTO `device_heartbeat_record` VALUES (2091, 'B4BFE90CDBA1', 12240, '2026-10-27 17:46:04.488', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094364475, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12240, \"rssi\": -65}}', '2026-10-27 17:46:04.488');
INSERT INTO `device_heartbeat_record` VALUES (2092, 'B4BFE90CDBA1', 12270, '2026-10-27 17:46:34.510', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094394486, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12270, \"rssi\": -65}}', '2026-10-27 17:46:34.510');
INSERT INTO `device_heartbeat_record` VALUES (2093, 'B4BFE90CDBA1', 12300, '2026-10-27 17:47:04.513', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094424498, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12300, \"rssi\": -65}}', '2026-10-27 17:47:04.515');
INSERT INTO `device_heartbeat_record` VALUES (2094, 'B4BFE90CDBA1', 12330, '2026-10-27 17:47:34.529', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094454513, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12330, \"rssi\": -65}}', '2026-10-27 17:47:34.529');
INSERT INTO `device_heartbeat_record` VALUES (2095, 'B4BFE90CDBA1', 12360, '2026-10-27 17:48:04.551', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094484522, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12360, \"rssi\": -65}}', '2026-10-27 17:48:04.551');
INSERT INTO `device_heartbeat_record` VALUES (2096, 'B4BFE90CDBA1', 12390, '2026-10-27 17:48:34.544', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094514532, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12390, \"rssi\": -65}}', '2026-10-27 17:48:34.544');
INSERT INTO `device_heartbeat_record` VALUES (2097, 'B4BFE90CDBA1', 12420, '2026-10-27 17:49:04.561', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094544549, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12420, \"rssi\": -65}}', '2026-10-27 17:49:04.561');
INSERT INTO `device_heartbeat_record` VALUES (2098, 'B4BFE90CDBA1', 12450, '2026-10-27 17:49:34.577', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094574555, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12450, \"rssi\": -65}}', '2026-10-27 17:49:34.580');
INSERT INTO `device_heartbeat_record` VALUES (2099, 'B4BFE90CDBA1', 12480, '2026-10-27 17:50:04.576', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094604559, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12480, \"rssi\": -65}}', '2026-10-27 17:50:04.578');
INSERT INTO `device_heartbeat_record` VALUES (2100, 'B4BFE90CDBA1', 12510, '2026-10-27 17:50:34.586', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094634569, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12510, \"rssi\": -65}}', '2026-10-27 17:50:34.587');
INSERT INTO `device_heartbeat_record` VALUES (2101, 'B4BFE90CDBA1', 12540, '2026-10-27 17:51:04.599', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094664584, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12540, \"rssi\": -65}}', '2026-10-27 17:51:04.599');
INSERT INTO `device_heartbeat_record` VALUES (2102, 'B4BFE90CDBA1', 12570, '2026-10-27 17:51:34.621', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094694601, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12570, \"rssi\": -65}}', '2026-10-27 17:51:34.622');
INSERT INTO `device_heartbeat_record` VALUES (2103, 'B4BFE90CDBA1', 12600, '2026-10-27 17:52:04.637', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094724610, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12600, \"rssi\": -65}}', '2026-10-27 17:52:04.637');
INSERT INTO `device_heartbeat_record` VALUES (2104, 'B4BFE90CDBA1', 12630, '2026-10-27 17:52:34.640', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094754625, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12630, \"rssi\": -65}}', '2026-10-27 17:52:34.642');
INSERT INTO `device_heartbeat_record` VALUES (2105, 'B4BFE90CDBA1', 12660, '2026-10-27 17:53:04.655', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094784631, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12660, \"rssi\": -65}}', '2026-10-27 17:53:04.656');
INSERT INTO `device_heartbeat_record` VALUES (2106, 'B4BFE90CDBA1', 12690, '2026-10-27 17:53:34.659', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094814645, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12690, \"rssi\": -65}}', '2026-10-27 17:53:34.660');
INSERT INTO `device_heartbeat_record` VALUES (2107, 'B4BFE90CDBA1', 12720, '2026-10-27 17:54:04.659', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094844647, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12720, \"rssi\": -65}}', '2026-10-27 17:54:04.659');
INSERT INTO `device_heartbeat_record` VALUES (2108, 'B4BFE90CDBA1', 12750, '2026-10-27 17:54:34.701', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094874669, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12750, \"rssi\": -65}}', '2026-10-27 17:54:34.701');
INSERT INTO `device_heartbeat_record` VALUES (2109, 'B4BFE90CDBA1', 12780, '2026-10-27 17:55:04.706', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094904692, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12780, \"rssi\": -65}}', '2026-10-27 17:55:04.706');
INSERT INTO `device_heartbeat_record` VALUES (2110, 'B4BFE90CDBA1', 12810, '2026-10-27 17:55:34.710', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094934699, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12810, \"rssi\": -65}}', '2026-10-27 17:55:34.711');
INSERT INTO `device_heartbeat_record` VALUES (2111, 'B4BFE90CDBA1', 12840, '2026-10-27 17:56:04.741', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094964712, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12840, \"rssi\": -65}}', '2026-10-27 17:56:04.743');
INSERT INTO `device_heartbeat_record` VALUES (2112, 'B4BFE90CDBA1', 12870, '2026-10-27 17:56:34.743', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793094994726, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12870, \"rssi\": -65}}', '2026-10-27 17:56:34.778');
INSERT INTO `device_heartbeat_record` VALUES (2113, 'B4BFE90CDBA1', 12900, '2026-10-27 17:57:04.746', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095024731, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12900, \"rssi\": -65}}', '2026-10-27 17:57:04.746');
INSERT INTO `device_heartbeat_record` VALUES (2114, 'B4BFE90CDBA1', 12930, '2026-10-27 17:57:34.757', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095054739, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12930, \"rssi\": -65}}', '2026-10-27 17:57:34.757');
INSERT INTO `device_heartbeat_record` VALUES (2115, 'B4BFE90CDBA1', 12960, '2026-10-27 17:58:04.761', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095084750, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12960, \"rssi\": -65}}', '2026-10-27 17:58:04.762');
INSERT INTO `device_heartbeat_record` VALUES (2116, 'B4BFE90CDBA1', 12990, '2026-10-27 17:58:34.775', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095114758, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 12990, \"rssi\": -65}}', '2026-10-27 17:58:34.777');
INSERT INTO `device_heartbeat_record` VALUES (2117, 'B4BFE90CDBA1', 13020, '2026-10-27 17:59:04.779', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095144764, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13020, \"rssi\": -65}}', '2026-10-27 17:59:04.781');
INSERT INTO `device_heartbeat_record` VALUES (2118, 'B4BFE90CDBA1', 13050, '2026-10-27 17:59:34.801', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095174775, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13050, \"rssi\": -65}}', '2026-10-27 17:59:34.803');
INSERT INTO `device_heartbeat_record` VALUES (2119, 'B4BFE90CDBA1', 13080, '2026-10-27 18:00:04.804', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095204789, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13080, \"rssi\": -65}}', '2026-10-27 18:00:04.804');
INSERT INTO `device_heartbeat_record` VALUES (2120, 'B4BFE90CDBA1', 13110, '2026-10-27 18:00:34.819', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095234795, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13110, \"rssi\": -65}}', '2026-10-27 18:00:34.820');
INSERT INTO `device_heartbeat_record` VALUES (2121, 'B4BFE90CDBA1', 13140, '2026-10-27 18:01:04.810', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095264798, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13140, \"rssi\": -65}}', '2026-10-27 18:01:04.811');
INSERT INTO `device_heartbeat_record` VALUES (2122, 'B4BFE90CDBA1', 13170, '2026-10-27 18:01:34.822', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095294802, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13170, \"rssi\": -65}}', '2026-10-27 18:01:34.822');
INSERT INTO `device_heartbeat_record` VALUES (2123, 'B4BFE90CDBA1', 13200, '2026-10-27 18:02:04.825', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095324817, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13200, \"rssi\": -65}}', '2026-10-27 18:02:04.825');
INSERT INTO `device_heartbeat_record` VALUES (2124, 'B4BFE90CDBA1', 13230, '2026-10-27 18:02:34.846', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095354832, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13230, \"rssi\": -65}}', '2026-10-27 18:02:34.846');
INSERT INTO `device_heartbeat_record` VALUES (2125, 'B4BFE90CDBA1', 13260, '2026-10-27 18:03:04.897', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095384842, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13260, \"rssi\": -65}}', '2026-10-27 18:03:04.900');
INSERT INTO `device_heartbeat_record` VALUES (2126, 'B4BFE90CDBA1', 13290, '2026-10-27 18:03:34.879', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095414855, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13290, \"rssi\": -65}}', '2026-10-27 18:03:34.880');
INSERT INTO `device_heartbeat_record` VALUES (2127, 'B4BFE90CDBA1', 13320, '2026-10-27 18:04:04.872', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095444863, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13320, \"rssi\": -65}}', '2026-10-27 18:04:04.872');
INSERT INTO `device_heartbeat_record` VALUES (2128, 'B4BFE90CDBA1', 13350, '2026-10-27 18:04:34.903', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095474879, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13350, \"rssi\": -65}}', '2026-10-27 18:04:34.904');
INSERT INTO `device_heartbeat_record` VALUES (2129, 'B4BFE90CDBA1', 13380, '2026-10-27 18:05:04.901', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095504882, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13380, \"rssi\": -65}}', '2026-10-27 18:05:04.902');
INSERT INTO `device_heartbeat_record` VALUES (2130, 'B4BFE90CDBA1', 13410, '2026-10-27 18:05:34.897', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095534885, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13410, \"rssi\": -65}}', '2026-10-27 18:05:34.898');
INSERT INTO `device_heartbeat_record` VALUES (2131, 'B4BFE90CDBA1', 13440, '2026-10-27 18:06:04.910', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095564900, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13440, \"rssi\": -65}}', '2026-10-27 18:06:04.910');
INSERT INTO `device_heartbeat_record` VALUES (2132, 'B4BFE90CDBA1', 13470, '2026-10-27 18:06:34.921', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095594903, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13470, \"rssi\": -65}}', '2026-10-27 18:06:34.921');
INSERT INTO `device_heartbeat_record` VALUES (2133, 'B4BFE90CDBA1', 13500, '2026-10-27 18:07:04.919', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095624909, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13500, \"rssi\": -65}}', '2026-10-27 18:07:04.928');
INSERT INTO `device_heartbeat_record` VALUES (2134, 'B4BFE90CDBA1', 13530, '2026-10-27 18:07:34.925', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095654914, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13530, \"rssi\": -65}}', '2026-10-27 18:07:34.925');
INSERT INTO `device_heartbeat_record` VALUES (2135, 'B4BFE90CDBA1', 13560, '2026-10-27 18:08:04.940', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095684927, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13560, \"rssi\": -65}}', '2026-10-27 18:08:04.940');
INSERT INTO `device_heartbeat_record` VALUES (2136, 'B4BFE90CDBA1', 13590, '2026-10-27 18:08:34.943', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095714932, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13590, \"rssi\": -65}}', '2026-10-27 18:08:34.943');
INSERT INTO `device_heartbeat_record` VALUES (2137, 'B4BFE90CDBA1', 13620, '2026-10-27 18:09:04.958', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095744937, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13620, \"rssi\": -65}}', '2026-10-27 18:09:04.958');
INSERT INTO `device_heartbeat_record` VALUES (2138, 'B4BFE90CDBA1', 13650, '2026-10-27 18:09:34.956', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095774944, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13650, \"rssi\": -65}}', '2026-10-27 18:09:34.957');
INSERT INTO `device_heartbeat_record` VALUES (2139, 'B4BFE90CDBA1', 13680, '2026-10-27 18:10:04.967', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095804954, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13680, \"rssi\": -65}}', '2026-10-27 18:10:04.968');
INSERT INTO `device_heartbeat_record` VALUES (2140, 'B4BFE90CDBA1', 13710, '2026-10-27 18:10:34.976', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095834965, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13710, \"rssi\": -65}}', '2026-10-27 18:10:34.977');
INSERT INTO `device_heartbeat_record` VALUES (2141, 'B4BFE90CDBA1', 13740, '2026-10-27 18:11:04.977', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095864969, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13740, \"rssi\": -65}}', '2026-10-27 18:11:04.977');
INSERT INTO `device_heartbeat_record` VALUES (2142, 'B4BFE90CDBA1', 13770, '2026-10-27 18:11:34.993', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095894984, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13770, \"rssi\": -65}}', '2026-10-27 18:11:34.993');
INSERT INTO `device_heartbeat_record` VALUES (2143, 'B4BFE90CDBA1', 13800, '2026-10-27 18:12:05.001', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095924990, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13800, \"rssi\": -65}}', '2026-10-27 18:12:05.001');
INSERT INTO `device_heartbeat_record` VALUES (2144, 'B4BFE90CDBA1', 13830, '2026-10-27 18:12:35.007', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095955000, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13830, \"rssi\": -65}}', '2026-10-27 18:12:35.007');
INSERT INTO `device_heartbeat_record` VALUES (2145, 'B4BFE90CDBA1', 13860, '2026-10-27 18:13:05.023', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793095985001, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13860, \"rssi\": -65}}', '2026-10-27 18:13:05.024');
INSERT INTO `device_heartbeat_record` VALUES (2146, 'B4BFE90CDBA1', 13890, '2026-10-27 18:13:35.013', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096015004, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13890, \"rssi\": -65}}', '2026-10-27 18:13:35.013');
INSERT INTO `device_heartbeat_record` VALUES (2147, 'B4BFE90CDBA1', 13920, '2026-10-27 18:14:05.051', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096045017, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13920, \"rssi\": -65}}', '2026-10-27 18:14:05.051');
INSERT INTO `device_heartbeat_record` VALUES (2148, 'B4BFE90CDBA1', 13950, '2026-10-27 18:14:35.063', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096075049, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13950, \"rssi\": -65}}', '2026-10-27 18:14:35.063');
INSERT INTO `device_heartbeat_record` VALUES (2149, 'B4BFE90CDBA1', 13980, '2026-10-27 18:15:05.066', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096105055, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 13980, \"rssi\": -65}}', '2026-10-27 18:15:05.066');
INSERT INTO `device_heartbeat_record` VALUES (2150, 'B4BFE90CDBA1', 14010, '2026-10-27 18:15:35.072', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096135065, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14010, \"rssi\": -65}}', '2026-10-27 18:15:35.072');
INSERT INTO `device_heartbeat_record` VALUES (2151, 'B4BFE90CDBA1', 14040, '2026-10-27 18:16:05.090', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096165079, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14040, \"rssi\": -65}}', '2026-10-27 18:16:05.091');
INSERT INTO `device_heartbeat_record` VALUES (2152, 'B4BFE90CDBA1', 14070, '2026-10-27 18:16:35.103', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096195079, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14070, \"rssi\": -65}}', '2026-10-27 18:16:35.104');
INSERT INTO `device_heartbeat_record` VALUES (2153, 'B4BFE90CDBA1', 14100, '2026-10-27 18:17:05.096', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096225085, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14100, \"rssi\": -65}}', '2026-10-27 18:17:05.097');
INSERT INTO `device_heartbeat_record` VALUES (2154, 'B4BFE90CDBA1', 14130, '2026-10-27 18:17:35.104', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096255094, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14130, \"rssi\": -65}}', '2026-10-27 18:17:35.105');
INSERT INTO `device_heartbeat_record` VALUES (2155, 'B4BFE90CDBA1', 14160, '2026-10-27 18:18:05.123', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096285102, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14160, \"rssi\": -65}}', '2026-10-27 18:18:05.123');
INSERT INTO `device_heartbeat_record` VALUES (2156, 'B4BFE90CDBA1', 14190, '2026-10-27 18:18:35.126', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096315118, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14190, \"rssi\": -65}}', '2026-10-27 18:18:35.126');
INSERT INTO `device_heartbeat_record` VALUES (2157, 'B4BFE90CDBA1', 14220, '2026-10-27 18:19:05.141', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096345125, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14220, \"rssi\": -65}}', '2026-10-27 18:19:05.142');
INSERT INTO `device_heartbeat_record` VALUES (2158, 'B4BFE90CDBA1', 14250, '2026-10-27 18:19:35.142', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096375126, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14250, \"rssi\": -65}}', '2026-10-27 18:19:35.142');
INSERT INTO `device_heartbeat_record` VALUES (2159, 'B4BFE90CDBA1', 14280, '2026-10-27 18:20:05.175', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096405136, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14280, \"rssi\": -65}}', '2026-10-27 18:20:05.176');
INSERT INTO `device_heartbeat_record` VALUES (2160, 'B4BFE90CDBA1', 14310, '2026-10-27 18:20:35.161', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096435147, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14310, \"rssi\": -65}}', '2026-10-27 18:20:35.161');
INSERT INTO `device_heartbeat_record` VALUES (2161, 'B4BFE90CDBA1', 14340, '2026-10-27 18:21:05.237', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096465155, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14340, \"rssi\": -65}}', '2026-10-27 18:21:05.237');
INSERT INTO `device_heartbeat_record` VALUES (2162, 'B4BFE90CDBA1', 14370, '2026-10-27 18:21:35.181', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096495169, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14370, \"rssi\": -65}}', '2026-10-27 18:21:35.181');
INSERT INTO `device_heartbeat_record` VALUES (2163, 'B4BFE90CDBA1', 14400, '2026-10-27 18:22:05.197', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096525183, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14400, \"rssi\": -65}}', '2026-10-27 18:22:05.197');

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
) ENGINE = InnoDB AUTO_INCREMENT = 33 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_info
-- ----------------------------
INSERT INTO `device_info` VALUES (18, 'AABBCCDDEEFF', '客厅温湿度计', 'SmartHome-v1', NULL, NULL, '一楼客厅', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 10:00:03.905', '2026-10-27 10:00:03.905');
INSERT INTO `device_info` VALUES (19, 'MAC123456789', '大厅温湿度计', 'SmartHome-v1', NULL, NULL, '二楼客厅', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 10:36:30.479', '2026-10-27 10:36:30.479');
INSERT INTO `device_info` VALUES (20, 'AABBCCDDEE11', '厨房温湿度计', 'SmartHome-v1', NULL, NULL, '一楼厨房', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 10:50:03.177', '2026-10-27 11:15:27.656');
INSERT INTO `device_info` VALUES (21, 'AABBCCDDEE12', '厨房温湿度计', 'SmartHome-v1', NULL, NULL, '一楼厨房', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 10:51:40.013', '2026-10-27 11:15:27.656');
INSERT INTO `device_info` VALUES (22, 'AABBCCDDEE13', '厨房温湿度计', 'SmartHome-v1', NULL, NULL, '一楼厨房', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 10:51:47.858', '2026-10-27 11:15:27.656');
INSERT INTO `device_info` VALUES (23, 'AABBCCDDEE15', '卧室温湿度计', 'SmartHome-v1', NULL, NULL, '一楼卧室', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 11:22:33.509', '2026-10-27 11:23:00.399');
INSERT INTO `device_info` VALUES (24, 'AABBCCDDEE16', '卧室温湿度计', 'SmartHome-v1', NULL, NULL, '二楼卧室', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 11:23:23.852', '2026-10-27 11:40:19.420');
INSERT INTO `device_info` VALUES (25, 'AABBCCDDEE17', '卧室温湿度计', 'SmartHome-v1', NULL, NULL, '三楼卧室', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 11:24:47.861', '2026-10-27 11:40:19.420');
INSERT INTO `device_info` VALUES (26, 'AABBCCDDEEB7', '卧室温湿度计', 'SmartHome-v1', NULL, NULL, '三楼卧室', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 11:26:25.533', '2026-10-27 11:40:19.420');
INSERT INTO `device_info` VALUES (27, 'AABBCCDDEEA7', '卧室温湿度计', 'SmartHome-v1', NULL, NULL, '三楼大厅', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 11:38:23.904', '2026-10-27 11:38:23.904');
INSERT INTO `device_info` VALUES (28, 'AABBCCDDEEC7', '厨房大灯', 'SmartHome-v1', NULL, NULL, '一楼厨房', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 11:41:06.153', '2026-10-27 11:41:06.153');
INSERT INTO `device_info` VALUES (32, 'B4BFE90CDBA1', '卧室大灯', 'SmartHome-v1', '1.0.41', '-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE2fvpPtLF8nBeo56M2EOpOzuuu0Ru\ne8PyA6TnL/APMrUcAVJWQrdpu+bAjVzJhtgCFRIeRcbvhWUE19ReGbTZvQ==\n-----END PUBLIC KEY-----\n', '一楼', NULL, 1, NULL, '2026-10-27 17:35:15.156', '2026-10-27 14:19:25.197', '2026-10-27 18:22:05.189', 14400, '{\"led\": 3, \"mos\": 8, \"servo\": 2}', NULL, 'success', 100, '2026-10-27 17:06:15.757', '1.0.41', NULL, '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793096525183, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 14400, \"rssi\": -65}}', '2026-10-27 11:48:59.234', '2026-10-27 18:22:05.189');

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
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '统一MQTT认证账号表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_mqtt_auth
-- ----------------------------
INSERT INTO `device_mqtt_auth` VALUES (1, 'PROVISION_USER', 'f43c57babf15d80cd5e961e6dee8b1795dcff8805ca9a4aabc2d048d2499f172', '767f13ac5e1c4dbdddb7f4c288bb085b', 0, 1, NULL, '2026-10-15 18:36:10.738', '2026-10-17 16:20:53.331');
INSERT INTO `device_mqtt_auth` VALUES (2, 'java-backend', 'fae340eae69a2dfad416154a5d47474ce546d2c2ba9bc57fa8c0b833a6886aff', '667f13ac5e1c4dbdddb7f4c288bb0856', 1, 1, NULL, '2026-10-15 18:36:43.369', '2026-10-21 11:50:01.894');
INSERT INTO `device_mqtt_auth` VALUES (13, 'B4BFE90CDBA1', '62dab16f76d6185991185e014d8a8aa9f59ac58e792f0d377caf5ef3163d7d5a', '489cbab6fbf82240813827b70894d9f4', 0, 1, 'B4BFE90CDBA1', '2026-10-27 13:56:28.036', '2026-10-27 13:56:28.036');

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
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备白名单（产线导入，允许注册的设备）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_whitelist
-- ----------------------------
INSERT INTO `device_whitelist` VALUES (2, 'MAC123456789', NULL, 1, '管理员后台录入自动生成', '2026-10-27 10:36:30.567', '2026-10-27 10:36:30.567');
INSERT INTO `device_whitelist` VALUES (3, 'AABBCCDDEE11', NULL, 1, '管理员后台录入自动生成', '2026-10-27 10:50:03.180', '2026-10-27 11:15:27.679');
INSERT INTO `device_whitelist` VALUES (4, 'AABBCCDDEE12', NULL, 1, '管理员后台录入自动生成', '2026-10-27 10:51:40.016', '2026-10-27 11:15:27.679');
INSERT INTO `device_whitelist` VALUES (5, 'AABBCCDDEE13', NULL, 1, '管理员后台录入自动生成', '2026-10-27 10:51:47.859', '2026-10-27 11:15:27.679');
INSERT INTO `device_whitelist` VALUES (6, 'AABBCCDDEE15', NULL, 1, '管理员后台录入自动生成', '2026-10-27 11:22:33.512', '2026-10-27 11:23:00.404');
INSERT INTO `device_whitelist` VALUES (7, 'AABBCCDDEE16', NULL, 1, '管理员后台录入自动生成', '2026-10-27 11:23:23.937', '2026-10-27 11:39:13.793');
INSERT INTO `device_whitelist` VALUES (8, 'AABBCCDDEE17', NULL, 1, '管理员后台录入自动生成', '2026-10-27 11:24:47.973', '2026-10-27 11:39:13.793');
INSERT INTO `device_whitelist` VALUES (9, 'AABBCCDDEEB7', NULL, 1, '管理员后台录入自动生成', '2026-10-27 11:26:25.538', '2026-10-27 11:39:33.472');
INSERT INTO `device_whitelist` VALUES (10, 'AABBCCDDEEA7', NULL, 1, '管理员后台录入自动生成', '2026-10-27 11:38:23.909', '2026-10-27 11:38:23.909');
INSERT INTO `device_whitelist` VALUES (11, 'AABBCCDDEEC7', NULL, 1, '管理员后台录入自动生成', '2026-10-27 11:41:06.158', '2026-10-27 11:41:06.158');
INSERT INTO `device_whitelist` VALUES (15, 'B4BFE90CDBA1', NULL, 1, '管理员后台录入自动生成', '2026-10-27 11:48:59.341', '2026-10-27 11:48:59.341');

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
) ENGINE = InnoDB AUTO_INCREMENT = 65 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录日志表' ROW_FORMAT = Dynamic;

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
INSERT INTO `sys_login_log` VALUES (27, 'tom123', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 09:12:22.899');
INSERT INTO `sys_login_log` VALUES (28, 'tom1234', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-27 09:12:29.800');
INSERT INTO `sys_login_log` VALUES (29, 'tom1234', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-27 09:12:37.247');
INSERT INTO `sys_login_log` VALUES (30, 'tom1234', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-27 09:12:38.038');
INSERT INTO `sys_login_log` VALUES (31, 'tom1234', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-27 09:12:38.660');
INSERT INTO `sys_login_log` VALUES (32, 'tom1234', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-27 09:12:39.256');
INSERT INTO `sys_login_log` VALUES (33, 'tom1234', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-27 09:12:39.552');
INSERT INTO `sys_login_log` VALUES (34, 'tom1234', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-27 09:12:40.805');
INSERT INTO `sys_login_log` VALUES (35, 'tom1234', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-27 09:12:41.420');
INSERT INTO `sys_login_log` VALUES (36, 'tom1234', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-27 09:15:38.888');
INSERT INTO `sys_login_log` VALUES (37, 'tom1234', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-27 09:28:06.319');
INSERT INTO `sys_login_log` VALUES (38, 'tom123', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 09:28:10.194');
INSERT INTO `sys_login_log` VALUES (39, 'tom1233', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-27 09:31:30.902');
INSERT INTO `sys_login_log` VALUES (40, 'tom1233', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-27 09:58:51.945');
INSERT INTO `sys_login_log` VALUES (41, 'admin123', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-27 09:59:00.062');
INSERT INTO `sys_login_log` VALUES (42, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 09:59:11.718');
INSERT INTO `sys_login_log` VALUES (43, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 10:33:48.123');
INSERT INTO `sys_login_log` VALUES (44, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 10:38:01.303');
INSERT INTO `sys_login_log` VALUES (45, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 10:40:44.864');
INSERT INTO `sys_login_log` VALUES (46, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 10:41:34.569');
INSERT INTO `sys_login_log` VALUES (47, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 10:42:13.295');
INSERT INTO `sys_login_log` VALUES (48, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 10:49:13.385');
INSERT INTO `sys_login_log` VALUES (49, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 10:50:48.274');
INSERT INTO `sys_login_log` VALUES (50, '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-27 11:21:44.154');
INSERT INTO `sys_login_log` VALUES (51, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 11:21:57.549');
INSERT INTO `sys_login_log` VALUES (52, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 11:38:04.357');
INSERT INTO `sys_login_log` VALUES (53, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-27 11:41:35.747');
INSERT INTO `sys_login_log` VALUES (54, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-27 11:41:41.813');
INSERT INTO `sys_login_log` VALUES (55, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 11:41:46.118');
INSERT INTO `sys_login_log` VALUES (56, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 11:44:31.006');
INSERT INTO `sys_login_log` VALUES (57, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 11:49:33.837');
INSERT INTO `sys_login_log` VALUES (58, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 15:02:59.100');
INSERT INTO `sys_login_log` VALUES (59, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 15:24:14.465');
INSERT INTO `sys_login_log` VALUES (60, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 16:59:21.043');
INSERT INTO `sys_login_log` VALUES (61, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 17:04:45.276');
INSERT INTO `sys_login_log` VALUES (62, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 17:05:26.524');
INSERT INTO `sys_login_log` VALUES (63, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 17:35:33.638');
INSERT INTO `sys_login_log` VALUES (64, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-27 17:42:01.041');

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
) ENGINE = InnoDB AUTO_INCREMENT = 33 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `sys_permission` VALUES (23, 'ota:create', '发起OTA', 'API', 'ota', 'create', '批量下发OTA升级任务', 1, '2026-10-26 16:03:52', '2026-10-27 15:15:12', 0);
INSERT INTO `sys_permission` VALUES (24, 'ota:cancel', '取消OTA', 'API', 'ota', 'update', '取消正在进行的升级任务', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (25, 'alert:list', '查询告警', 'API', 'alert', 'read', '查看告警记录', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (26, 'alert:handle', '处理告警', 'API', 'alert', 'update', '确认或解决告警', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (27, 'user:list', '查询用户', 'API', 'user', 'read', '查看用户列表', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (28, 'user:create', '创建用户', 'API', 'user', 'create', '管理员添加用户', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (29, 'user:update', '修改用户', 'API', 'user', 'update', '修改用户状态或角色', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (30, 'system:config', '系统配置', 'API', 'system', 'update', '修改系统级参数', 1, '2026-10-26 16:03:52', '2026-10-26 16:03:52', 0);
INSERT INTO `sys_permission` VALUES (31, 'firmware:delete', '删除固件', 'API', 'firmware', 'delete', '删除废弃的固件包', 1, '2026-10-27 15:09:44', '2026-10-27 15:09:44', 0);
INSERT INTO `sys_permission` VALUES (32, 'ota:list', '查询固件', 'API', 'firmware', 'select', '查询所有的固件包', 1, '2026-10-27 15:12:10', '2026-10-27 15:12:10', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户Refresh Token表' ROW_FORMAT = Dynamic;

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
INSERT INTO `sys_refresh_token` VALUES (17, 1, '37eed65e7d92ef4f6ad120c722fd33eeedce816b6b7e28452106ee56165db52a', 'web', '2026-11-03 09:12:22.742', 0, '2026-10-27 09:12:22.749', '2026-10-27 09:12:22.749');
INSERT INTO `sys_refresh_token` VALUES (18, 1, 'e66c49f8db6e6fd8c7f87ee81af48b8f285c52513978616bbe0ca18f4eaf77d0', 'web', '2026-11-03 09:28:10.178', 0, '2026-10-27 09:28:10.179', '2026-10-27 09:28:10.179');
INSERT INTO `sys_refresh_token` VALUES (19, 5, 'e5066bbfeba8df9c526a1658959ec3bf9555f88e31ebbdf7335c027c73707ab2', 'web', '2026-11-03 09:59:11.699', 0, '2026-10-27 09:59:11.700', '2026-10-27 09:59:11.700');
INSERT INTO `sys_refresh_token` VALUES (20, 5, '7168d2319b48a86203db29c2c8fd504c172fc25f57447dfebfd8174e7300f521', 'web', '2026-11-03 10:33:48.031', 0, '2026-10-27 10:33:48.033', '2026-10-27 10:33:48.033');
INSERT INTO `sys_refresh_token` VALUES (21, 6, '7eec4d9d16427e595a000a575bbcf72c08659939cefb0fcb43150a5001100ef4', 'web', '2026-11-03 10:38:01.288', 0, '2026-10-27 10:38:01.289', '2026-10-27 10:38:01.289');
INSERT INTO `sys_refresh_token` VALUES (22, 7, 'f9a79af48e442ff5ba1a1b953c4c2bee3f9f52e6de057e416860c47932d7d6e6', 'web', '2026-11-03 10:40:44.855', 0, '2026-10-27 10:40:44.856', '2026-10-27 10:40:44.856');
INSERT INTO `sys_refresh_token` VALUES (23, 6, '28801d5722c61a3975e7eca0f74b07f8346acd1559c0db6a95bc4ef77df19872', 'web', '2026-11-03 10:41:34.561', 0, '2026-10-27 10:41:34.562', '2026-10-27 10:41:34.562');
INSERT INTO `sys_refresh_token` VALUES (24, 7, '3b61745d97f6cdf1e531fec24e5baafdb6f24ae5a2db088ec1fc4fc6a5b878de', 'web', '2026-11-03 10:42:13.286', 0, '2026-10-27 10:42:13.287', '2026-10-27 10:42:13.287');
INSERT INTO `sys_refresh_token` VALUES (25, 5, '7d5b9174ffb03e243baa1f70312c61693542233877e46680588687d684f27d42', 'web', '2026-11-03 10:49:13.375', 0, '2026-10-27 10:49:13.376', '2026-10-27 10:49:13.376');
INSERT INTO `sys_refresh_token` VALUES (26, 7, '926180b4675d755bf274e48c68289cfda69b7156364cd49ce3be70deef267eb3', 'web', '2026-11-03 10:50:48.265', 0, '2026-10-27 10:50:48.265', '2026-10-27 10:50:48.265');
INSERT INTO `sys_refresh_token` VALUES (27, 5, 'c5b52985f44b3898ffb9f9da6b0eacb7bd03ac2bda2329e80069a123a5895f9c', 'web', '2026-11-03 11:21:57.536', 0, '2026-10-27 11:21:57.536', '2026-10-27 11:21:57.536');
INSERT INTO `sys_refresh_token` VALUES (28, 5, '5f314c4971dc44e3b318ab62694fc4f27055b68881e989916fd7d9af0a5faf66', 'web', '2026-11-03 11:38:04.249', 0, '2026-10-27 11:38:04.251', '2026-10-27 11:38:04.251');
INSERT INTO `sys_refresh_token` VALUES (29, 6, '2197a0effd927d7ed335e46036160e7295c73407293173e3614cea26274a803b', 'web', '2026-11-03 11:41:46.110', 0, '2026-10-27 11:41:46.111', '2026-10-27 11:41:46.111');
INSERT INTO `sys_refresh_token` VALUES (30, 5, '10a43872daaa1eff83169d21a2d7969e6baad9667ea5fc909c761544d327a5fd', 'web', '2026-11-03 11:44:30.999', 0, '2026-10-27 11:44:30.999', '2026-10-27 11:44:30.999');
INSERT INTO `sys_refresh_token` VALUES (31, 7, '53a91302e9580c8fc15bcb7cebb3c61c8094a357b164575ded2bffaf1d62892c', 'web', '2026-11-03 11:49:33.817', 0, '2026-10-27 11:49:33.818', '2026-10-27 11:49:33.818');
INSERT INTO `sys_refresh_token` VALUES (32, 5, '9ab2ff46643697ee6b0b96da887f3f35811da1b59fab4be5f5c558d250717656', 'web', '2026-11-03 15:02:59.080', 0, '2026-10-27 15:02:59.081', '2026-10-27 15:02:59.081');
INSERT INTO `sys_refresh_token` VALUES (33, 5, 'b99459a209277c1972394c1d95012be3976044bde74cf61d7e620f9bfbcec6d6', 'web', '2026-11-03 15:24:14.444', 0, '2026-10-27 15:24:14.445', '2026-10-27 15:24:14.445');
INSERT INTO `sys_refresh_token` VALUES (34, 7, 'fb35c772c12a54add9ffb81cf537736cbbab70f8a04899f7466af5d271fa0536', 'web', '2026-11-03 16:59:21.013', 0, '2026-10-27 16:59:21.014', '2026-10-27 16:59:21.014');
INSERT INTO `sys_refresh_token` VALUES (35, 6, '0ac748d3023c1650f3849181d0429c11026908c43689a533f5d2e7416b916441', 'web', '2026-11-03 17:04:45.261', 0, '2026-10-27 17:04:45.263', '2026-10-27 17:04:45.263');
INSERT INTO `sys_refresh_token` VALUES (36, 7, '641f9b111efc3b204124a978c3725ecb67d5fa6e811fc8ece4cf14f29484eb46', 'web', '2026-11-03 17:05:26.518', 0, '2026-10-27 17:05:26.518', '2026-10-27 17:05:26.518');
INSERT INTO `sys_refresh_token` VALUES (37, 7, '8042391dfb908ef280173e6292cdc307c858e4b343b15618a0356da10859ef3d', 'web', '2026-11-03 17:35:33.529', 0, '2026-10-27 17:35:33.532', '2026-10-27 17:35:33.532');
INSERT INTO `sys_refresh_token` VALUES (38, 6, '5069186e1a50beb5fad69c38e0112e80e86e2ca4a03b93c0221050f8e09c397f', 'web', '2026-11-03 17:42:01.031', 0, '2026-10-27 17:42:01.031', '2026-10-27 17:42:01.031');

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户-角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_info
-- ----------------------------
INSERT INTO `sys_role_info` VALUES (1, 4, 6, '2026-10-26 16:06:00');
INSERT INTO `sys_role_info` VALUES (2, 5, 4, '2026-10-26 16:23:05');
INSERT INTO `sys_role_info` VALUES (3, 6, 6, '2026-10-26 16:26:56');
INSERT INTO `sys_role_info` VALUES (4, 7, 6, '2026-10-27 10:40:28');

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
) ENGINE = InnoDB AUTO_INCREMENT = 74 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色-权限关联表' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `sys_role_permission` VALUES (72, 4, 31, '2026-10-27 15:09:44');
INSERT INTO `sys_role_permission` VALUES (73, 4, 32, '2026-10-27 15:12:10');

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
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'tom123', '$2a$12$tEFa.HGblOLYEOOUhB9B.u/3iUQdzPgKoi5puXnp4Itxqiz5QAATC', 'tom123', '123@qq.com', '17786174112', 1, '2026-10-27 09:28:10', '2026-10-26 11:53:23', '2026-10-27 09:28:10', 0);
INSERT INTO `sys_user` VALUES (2, 'kity123#DEL#2', '$2a$12$iZlVyeaysy/Nhs/YC7.sxOh6CDw6iF1H/5/XwRBGORFJp/0YUSq9G', 'kity123', '123@qq.com', '17786174112', 1, '2026-10-26 15:49:27', '2026-10-26 14:47:38', '2026-10-26 17:24:57', 1);
INSERT INTO `sys_user` VALUES (4, 'babo123#DEL#4', '$2a$12$AN/XgPPH3FwFqBUEx5ayKeeY7wzHsH.gwnuUfz6FY0v6HJAACyJ9m', 'babo123', '123@qq.com', '17786174112', 1, '2026-10-26 16:24:01', '2026-10-26 16:06:00', '2026-10-26 16:34:23', 1);
INSERT INTO `sys_user` VALUES (5, 'admin', '$2a$12$wThUxuRGa5RP6rpEtpfKAerFg0OOo312Wo5aqSUEWvflU/Z0tPIim', 'admin123', '123@qq.com', '17786174112', 1, '2026-10-27 15:24:14', '2026-10-26 16:23:05', '2026-10-27 15:24:14', 0);
INSERT INTO `sys_user` VALUES (6, 'public', '$2a$12$Vs84o9vWNOPlTWSFoJboD.uRIhbzR18sCr/D/YtcGbbynee69LNFO', 'public123', '123@qq.com', '17786174112', 1, '2026-10-27 17:42:01', '2026-10-26 16:26:56', '2026-10-27 17:42:01', 0);
INSERT INTO `sys_user` VALUES (7, 'test', '$2a$12$0PgccZ.RtVPrw0KdgUGU6uLdz.rRQ69QRYX2oAnJmbO8D05eZpHdm', 'test123', '123@qq.com', '17786174112', 1, '2026-10-27 17:35:34', '2026-10-27 10:40:29', '2026-10-27 17:35:34', 0);

SET FOREIGN_KEY_CHECKS = 1;
