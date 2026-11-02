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

 Date: 02/11/2026 11:40:22
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
) ENGINE = InnoDB AUTO_INCREMENT = 749 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备告警记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_alert_record
-- ----------------------------
INSERT INTO `device_alert_record` VALUES (1, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 13:52:16.615', '2026-10-28 13:52:16.615');
INSERT INTO `device_alert_record` VALUES (2, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 13:53:06.659', '2026-10-28 13:53:06.659');
INSERT INTO `device_alert_record` VALUES (3, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 13:53:56.708', '2026-10-28 13:53:56.708');
INSERT INTO `device_alert_record` VALUES (4, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 13:54:46.755', '2026-10-28 13:54:46.755');
INSERT INTO `device_alert_record` VALUES (5, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 13:55:36.797', '2026-10-28 13:55:36.797');
INSERT INTO `device_alert_record` VALUES (6, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 13:56:26.843', '2026-10-28 13:56:26.843');
INSERT INTO `device_alert_record` VALUES (7, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 13:57:16.862', '2026-10-28 13:57:16.862');
INSERT INTO `device_alert_record` VALUES (8, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 13:58:06.905', '2026-10-28 13:58:06.905');
INSERT INTO `device_alert_record` VALUES (9, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 13:58:56.940', '2026-10-28 13:58:56.940');
INSERT INTO `device_alert_record` VALUES (10, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 13:59:46.970', '2026-10-28 13:59:46.970');
INSERT INTO `device_alert_record` VALUES (11, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:00:37.016', '2026-10-28 14:00:37.016');
INSERT INTO `device_alert_record` VALUES (12, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:10:37.529', '2026-10-28 14:10:37.529');
INSERT INTO `device_alert_record` VALUES (13, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:11:27.568', '2026-10-28 14:11:27.568');
INSERT INTO `device_alert_record` VALUES (14, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:12:17.606', '2026-10-28 14:12:17.606');
INSERT INTO `device_alert_record` VALUES (15, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:13:07.645', '2026-10-28 14:13:07.645');
INSERT INTO `device_alert_record` VALUES (16, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:13:57.704', '2026-10-28 14:13:57.704');
INSERT INTO `device_alert_record` VALUES (17, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:14:47.746', '2026-10-28 14:14:47.746');
INSERT INTO `device_alert_record` VALUES (18, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:15:37.814', '2026-10-28 14:15:37.814');
INSERT INTO `device_alert_record` VALUES (19, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:16:27.885', '2026-10-28 14:16:27.885');
INSERT INTO `device_alert_record` VALUES (20, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:17:17.897', '2026-10-28 14:17:17.897');
INSERT INTO `device_alert_record` VALUES (21, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:18:07.938', '2026-10-28 14:18:07.938');
INSERT INTO `device_alert_record` VALUES (22, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:18:57.967', '2026-10-28 14:18:57.967');
INSERT INTO `device_alert_record` VALUES (23, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:19:48.015', '2026-10-28 14:19:48.015');
INSERT INTO `device_alert_record` VALUES (24, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:20:38.050', '2026-10-28 14:20:38.050');
INSERT INTO `device_alert_record` VALUES (25, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:21:28.113', '2026-10-28 14:21:28.113');
INSERT INTO `device_alert_record` VALUES (26, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:22:18.125', '2026-10-28 14:22:18.125');
INSERT INTO `device_alert_record` VALUES (27, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:23:08.182', '2026-10-28 14:23:08.182');
INSERT INTO `device_alert_record` VALUES (28, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:23:58.220', '2026-10-28 14:23:58.220');
INSERT INTO `device_alert_record` VALUES (29, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:24:48.271', '2026-10-28 14:24:48.271');
INSERT INTO `device_alert_record` VALUES (30, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:25:38.305', '2026-10-28 14:25:38.305');
INSERT INTO `device_alert_record` VALUES (31, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:26:28.347', '2026-10-28 14:26:28.347');
INSERT INTO `device_alert_record` VALUES (32, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:27:18.368', '2026-10-28 14:27:18.368');
INSERT INTO `device_alert_record` VALUES (33, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:28:08.415', '2026-10-28 14:28:08.415');
INSERT INTO `device_alert_record` VALUES (34, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:28:58.456', '2026-10-28 14:28:58.456');
INSERT INTO `device_alert_record` VALUES (35, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:29:48.505', '2026-10-28 14:29:48.505');
INSERT INTO `device_alert_record` VALUES (36, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:30:38.550', '2026-10-28 14:30:38.550');
INSERT INTO `device_alert_record` VALUES (37, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:31:28.597', '2026-10-28 14:31:28.597');
INSERT INTO `device_alert_record` VALUES (38, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:32:18.620', '2026-10-28 14:32:18.620');
INSERT INTO `device_alert_record` VALUES (39, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:33:08.648', '2026-10-28 14:33:08.648');
INSERT INTO `device_alert_record` VALUES (40, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:33:58.717', '2026-10-28 14:33:58.717');
INSERT INTO `device_alert_record` VALUES (41, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:34:48.763', '2026-10-28 14:34:48.763');
INSERT INTO `device_alert_record` VALUES (42, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:35:38.811', '2026-10-28 14:35:38.811');
INSERT INTO `device_alert_record` VALUES (43, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:36:28.843', '2026-10-28 14:36:28.843');
INSERT INTO `device_alert_record` VALUES (44, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:37:18.903', '2026-10-28 14:37:18.903');
INSERT INTO `device_alert_record` VALUES (45, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:38:08.931', '2026-10-28 14:38:08.931');
INSERT INTO `device_alert_record` VALUES (46, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:38:58.985', '2026-10-28 14:38:58.985');
INSERT INTO `device_alert_record` VALUES (47, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:39:49.019', '2026-10-28 14:39:49.019');
INSERT INTO `device_alert_record` VALUES (48, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:40:39.071', '2026-10-28 14:40:39.071');
INSERT INTO `device_alert_record` VALUES (49, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:41:29.106', '2026-10-28 14:41:29.106');
INSERT INTO `device_alert_record` VALUES (50, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:42:19.158', '2026-10-28 14:42:19.158');
INSERT INTO `device_alert_record` VALUES (51, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:43:09.207', '2026-10-28 14:43:09.207');
INSERT INTO `device_alert_record` VALUES (52, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:43:59.263', '2026-10-28 14:43:59.263');
INSERT INTO `device_alert_record` VALUES (53, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:44:49.318', '2026-10-28 14:44:49.318');
INSERT INTO `device_alert_record` VALUES (54, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:45:39.355', '2026-10-28 14:45:39.355');
INSERT INTO `device_alert_record` VALUES (55, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:46:29.416', '2026-10-28 14:46:29.416');
INSERT INTO `device_alert_record` VALUES (56, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:47:19.447', '2026-10-28 14:47:19.447');
INSERT INTO `device_alert_record` VALUES (57, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:48:09.483', '2026-10-28 14:48:09.483');
INSERT INTO `device_alert_record` VALUES (58, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:48:59.546', '2026-10-28 14:48:59.546');
INSERT INTO `device_alert_record` VALUES (59, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:49:49.571', '2026-10-28 14:49:49.571');
INSERT INTO `device_alert_record` VALUES (60, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:50:39.621', '2026-10-28 14:50:39.621');
INSERT INTO `device_alert_record` VALUES (61, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:51:25.443', '2026-10-28 14:51:25.443');
INSERT INTO `device_alert_record` VALUES (62, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:52:15.484', '2026-10-28 14:52:15.484');
INSERT INTO `device_alert_record` VALUES (63, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:53:05.532', '2026-10-28 14:53:05.532');
INSERT INTO `device_alert_record` VALUES (64, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:53:55.582', '2026-10-28 14:53:55.582');
INSERT INTO `device_alert_record` VALUES (65, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:54:45.645', '2026-10-28 14:54:45.645');
INSERT INTO `device_alert_record` VALUES (66, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:55:35.674', '2026-10-28 14:55:35.674');
INSERT INTO `device_alert_record` VALUES (67, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:56:25.723', '2026-10-28 14:56:25.723');
INSERT INTO `device_alert_record` VALUES (68, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:57:15.774', '2026-10-28 14:57:15.774');
INSERT INTO `device_alert_record` VALUES (69, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:58:05.815', '2026-10-28 14:58:05.815');
INSERT INTO `device_alert_record` VALUES (70, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:58:55.893', '2026-10-28 14:58:55.893');
INSERT INTO `device_alert_record` VALUES (71, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 14:59:45.923', '2026-10-28 14:59:45.923');
INSERT INTO `device_alert_record` VALUES (72, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:00:35.964', '2026-10-28 15:00:35.964');
INSERT INTO `device_alert_record` VALUES (73, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:01:26.017', '2026-10-28 15:01:26.017');
INSERT INTO `device_alert_record` VALUES (74, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:03:30.363', '2026-10-28 15:03:30.363');
INSERT INTO `device_alert_record` VALUES (75, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:04:20.385', '2026-10-28 15:04:20.385');
INSERT INTO `device_alert_record` VALUES (76, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:05:10.439', '2026-10-28 15:05:10.439');
INSERT INTO `device_alert_record` VALUES (77, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:06:00.476', '2026-10-28 15:06:00.476');
INSERT INTO `device_alert_record` VALUES (78, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:06:50.513', '2026-10-28 15:06:50.513');
INSERT INTO `device_alert_record` VALUES (79, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:07:40.575', '2026-10-28 15:07:40.575');
INSERT INTO `device_alert_record` VALUES (80, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:13:19.117', '2026-10-28 15:13:19.117');
INSERT INTO `device_alert_record` VALUES (81, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:14:09.155', '2026-10-28 15:14:09.155');
INSERT INTO `device_alert_record` VALUES (82, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:14:59.209', '2026-10-28 15:14:59.209');
INSERT INTO `device_alert_record` VALUES (83, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:32:30.099', '2026-10-28 15:32:30.099');
INSERT INTO `device_alert_record` VALUES (84, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:33:20.155', '2026-10-28 15:33:20.155');
INSERT INTO `device_alert_record` VALUES (85, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:34:10.191', '2026-10-28 15:34:10.191');
INSERT INTO `device_alert_record` VALUES (86, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:35:00.241', '2026-10-28 15:35:00.241');
INSERT INTO `device_alert_record` VALUES (87, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:35:50.289', '2026-10-28 15:35:50.289');
INSERT INTO `device_alert_record` VALUES (88, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:36:40.321', '2026-10-28 15:36:40.321');
INSERT INTO `device_alert_record` VALUES (89, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:37:30.804', '2026-10-28 15:37:30.804');
INSERT INTO `device_alert_record` VALUES (90, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:38:20.902', '2026-10-28 15:38:20.902');
INSERT INTO `device_alert_record` VALUES (91, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:39:10.925', '2026-10-28 15:39:10.925');
INSERT INTO `device_alert_record` VALUES (92, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:40:00.955', '2026-10-28 15:40:00.955');
INSERT INTO `device_alert_record` VALUES (93, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:40:51.004', '2026-10-28 15:40:51.004');
INSERT INTO `device_alert_record` VALUES (94, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:41:41.030', '2026-10-28 15:41:41.030');
INSERT INTO `device_alert_record` VALUES (95, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:42:31.062', '2026-10-28 15:42:31.062');
INSERT INTO `device_alert_record` VALUES (96, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:43:21.112', '2026-10-28 15:43:21.112');
INSERT INTO `device_alert_record` VALUES (97, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:44:11.160', '2026-10-28 15:44:11.160');
INSERT INTO `device_alert_record` VALUES (98, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:45:01.213', '2026-10-28 15:45:01.213');
INSERT INTO `device_alert_record` VALUES (99, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:45:51.248', '2026-10-28 15:45:51.248');
INSERT INTO `device_alert_record` VALUES (100, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:46:41.301', '2026-10-28 15:46:41.301');
INSERT INTO `device_alert_record` VALUES (101, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:47:31.356', '2026-10-28 15:47:31.356');
INSERT INTO `device_alert_record` VALUES (102, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:48:21.402', '2026-10-28 15:48:21.402');
INSERT INTO `device_alert_record` VALUES (103, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:49:11.433', '2026-10-28 15:49:11.433');
INSERT INTO `device_alert_record` VALUES (104, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:50:01.487', '2026-10-28 15:50:01.487');
INSERT INTO `device_alert_record` VALUES (105, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:50:51.544', '2026-10-28 15:50:51.544');
INSERT INTO `device_alert_record` VALUES (106, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:51:41.607', '2026-10-28 15:51:41.607');
INSERT INTO `device_alert_record` VALUES (107, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:52:31.642', '2026-10-28 15:52:31.642');
INSERT INTO `device_alert_record` VALUES (108, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:53:21.691', '2026-10-28 15:53:21.691');
INSERT INTO `device_alert_record` VALUES (109, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:54:11.736', '2026-10-28 15:54:11.736');
INSERT INTO `device_alert_record` VALUES (110, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:55:01.780', '2026-10-28 15:55:01.780');
INSERT INTO `device_alert_record` VALUES (111, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:55:51.822', '2026-10-28 15:55:51.822');
INSERT INTO `device_alert_record` VALUES (112, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:56:41.875', '2026-10-28 15:56:41.875');
INSERT INTO `device_alert_record` VALUES (113, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:57:31.908', '2026-10-28 15:57:31.908');
INSERT INTO `device_alert_record` VALUES (114, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:58:21.960', '2026-10-28 15:58:21.960');
INSERT INTO `device_alert_record` VALUES (115, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 15:59:12.016', '2026-10-28 15:59:12.016');
INSERT INTO `device_alert_record` VALUES (116, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:00:02.074', '2026-10-28 16:00:02.074');
INSERT INTO `device_alert_record` VALUES (117, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:00:52.093', '2026-10-28 16:00:52.093');
INSERT INTO `device_alert_record` VALUES (118, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:01:42.137', '2026-10-28 16:01:42.137');
INSERT INTO `device_alert_record` VALUES (119, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:02:32.191', '2026-10-28 16:02:32.191');
INSERT INTO `device_alert_record` VALUES (120, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:03:22.252', '2026-10-28 16:03:22.252');
INSERT INTO `device_alert_record` VALUES (121, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:04:12.286', '2026-10-28 16:04:12.286');
INSERT INTO `device_alert_record` VALUES (122, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:05:02.343', '2026-10-28 16:05:02.343');
INSERT INTO `device_alert_record` VALUES (123, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:05:52.378', '2026-10-28 16:05:52.378');
INSERT INTO `device_alert_record` VALUES (124, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:06:42.407', '2026-10-28 16:06:42.407');
INSERT INTO `device_alert_record` VALUES (125, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:07:32.452', '2026-10-28 16:07:32.452');
INSERT INTO `device_alert_record` VALUES (126, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:08:22.509', '2026-10-28 16:08:22.509');
INSERT INTO `device_alert_record` VALUES (127, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:09:12.538', '2026-10-28 16:09:12.538');
INSERT INTO `device_alert_record` VALUES (128, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:10:02.588', '2026-10-28 16:10:02.588');
INSERT INTO `device_alert_record` VALUES (129, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:10:52.617', '2026-10-28 16:10:52.617');
INSERT INTO `device_alert_record` VALUES (130, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:11:42.653', '2026-10-28 16:11:42.653');
INSERT INTO `device_alert_record` VALUES (131, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:12:32.705', '2026-10-28 16:12:32.705');
INSERT INTO `device_alert_record` VALUES (132, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:13:22.744', '2026-10-28 16:13:22.744');
INSERT INTO `device_alert_record` VALUES (133, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:14:12.779', '2026-10-28 16:14:12.779');
INSERT INTO `device_alert_record` VALUES (134, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:15:02.807', '2026-10-28 16:15:02.807');
INSERT INTO `device_alert_record` VALUES (135, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:15:52.849', '2026-10-28 16:15:52.849');
INSERT INTO `device_alert_record` VALUES (136, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:16:42.903', '2026-10-28 16:16:42.903');
INSERT INTO `device_alert_record` VALUES (137, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:17:32.934', '2026-10-28 16:17:32.934');
INSERT INTO `device_alert_record` VALUES (138, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:18:22.992', '2026-10-28 16:18:22.992');
INSERT INTO `device_alert_record` VALUES (139, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:19:13.038', '2026-10-28 16:19:13.038');
INSERT INTO `device_alert_record` VALUES (140, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:20:03.066', '2026-10-28 16:20:03.066');
INSERT INTO `device_alert_record` VALUES (141, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:20:53.108', '2026-10-28 16:20:53.108');
INSERT INTO `device_alert_record` VALUES (142, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:21:43.147', '2026-10-28 16:21:43.147');
INSERT INTO `device_alert_record` VALUES (143, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:22:33.171', '2026-10-28 16:22:33.171');
INSERT INTO `device_alert_record` VALUES (144, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:23:23.226', '2026-10-28 16:23:23.226');
INSERT INTO `device_alert_record` VALUES (145, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:24:13.260', '2026-10-28 16:24:13.260');
INSERT INTO `device_alert_record` VALUES (146, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:25:03.313', '2026-10-28 16:25:03.313');
INSERT INTO `device_alert_record` VALUES (147, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:25:53.360', '2026-10-28 16:25:53.360');
INSERT INTO `device_alert_record` VALUES (148, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:26:43.428', '2026-10-28 16:26:43.428');
INSERT INTO `device_alert_record` VALUES (149, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:27:33.452', '2026-10-28 16:27:33.452');
INSERT INTO `device_alert_record` VALUES (150, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:28:23.493', '2026-10-28 16:28:23.493');
INSERT INTO `device_alert_record` VALUES (151, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:29:11.890', '2026-10-28 16:29:11.890');
INSERT INTO `device_alert_record` VALUES (152, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:30:01.935', '2026-10-28 16:30:01.935');
INSERT INTO `device_alert_record` VALUES (153, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:30:51.978', '2026-10-28 16:30:51.978');
INSERT INTO `device_alert_record` VALUES (154, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:31:42.028', '2026-10-28 16:31:42.028');
INSERT INTO `device_alert_record` VALUES (155, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:32:32.072', '2026-10-28 16:32:32.072');
INSERT INTO `device_alert_record` VALUES (156, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:33:22.113', '2026-10-28 16:33:22.113');
INSERT INTO `device_alert_record` VALUES (157, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:34:12.155', '2026-10-28 16:34:12.155');
INSERT INTO `device_alert_record` VALUES (158, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:35:02.196', '2026-10-28 16:35:02.196');
INSERT INTO `device_alert_record` VALUES (159, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:35:52.231', '2026-10-28 16:35:52.231');
INSERT INTO `device_alert_record` VALUES (160, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:36:42.271', '2026-10-28 16:36:42.271');
INSERT INTO `device_alert_record` VALUES (161, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:37:32.320', '2026-10-28 16:37:32.320');
INSERT INTO `device_alert_record` VALUES (162, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:38:22.380', '2026-10-28 16:38:22.380');
INSERT INTO `device_alert_record` VALUES (163, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:39:12.429', '2026-10-28 16:39:12.429');
INSERT INTO `device_alert_record` VALUES (164, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:40:02.491', '2026-10-28 16:40:02.491');
INSERT INTO `device_alert_record` VALUES (165, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:40:52.530', '2026-10-28 16:40:52.530');
INSERT INTO `device_alert_record` VALUES (166, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:41:42.572', '2026-10-28 16:41:42.572');
INSERT INTO `device_alert_record` VALUES (167, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:42:32.619', '2026-10-28 16:42:32.619');
INSERT INTO `device_alert_record` VALUES (168, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:43:22.653', '2026-10-28 16:43:22.653');
INSERT INTO `device_alert_record` VALUES (169, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:44:12.694', '2026-10-28 16:44:12.694');
INSERT INTO `device_alert_record` VALUES (170, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:45:02.732', '2026-10-28 16:45:02.732');
INSERT INTO `device_alert_record` VALUES (171, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:45:52.789', '2026-10-28 16:45:52.789');
INSERT INTO `device_alert_record` VALUES (172, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:46:42.821', '2026-10-28 16:46:42.821');
INSERT INTO `device_alert_record` VALUES (173, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:47:32.854', '2026-10-28 16:47:32.854');
INSERT INTO `device_alert_record` VALUES (174, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:48:22.894', '2026-10-28 16:48:22.894');
INSERT INTO `device_alert_record` VALUES (175, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:49:12.959', '2026-10-28 16:49:12.959');
INSERT INTO `device_alert_record` VALUES (176, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:50:03.005', '2026-10-28 16:50:03.005');
INSERT INTO `device_alert_record` VALUES (177, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:50:53.034', '2026-10-28 16:50:53.034');
INSERT INTO `device_alert_record` VALUES (178, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:51:43.069', '2026-10-28 16:51:43.069');
INSERT INTO `device_alert_record` VALUES (179, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:52:33.130', '2026-10-28 16:52:33.130');
INSERT INTO `device_alert_record` VALUES (180, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:53:23.173', '2026-10-28 16:53:23.173');
INSERT INTO `device_alert_record` VALUES (181, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:54:13.219', '2026-10-28 16:54:13.219');
INSERT INTO `device_alert_record` VALUES (182, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:55:03.263', '2026-10-28 16:55:03.263');
INSERT INTO `device_alert_record` VALUES (183, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:55:53.301', '2026-10-28 16:55:53.301');
INSERT INTO `device_alert_record` VALUES (184, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:56:43.390', '2026-10-28 16:56:43.390');
INSERT INTO `device_alert_record` VALUES (185, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:57:33.465', '2026-10-28 16:57:33.465');
INSERT INTO `device_alert_record` VALUES (186, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:58:23.488', '2026-10-28 16:58:23.488');
INSERT INTO `device_alert_record` VALUES (187, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 16:59:13.517', '2026-10-28 16:59:13.517');
INSERT INTO `device_alert_record` VALUES (188, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:00:03.576', '2026-10-28 17:00:03.576');
INSERT INTO `device_alert_record` VALUES (189, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:00:53.625', '2026-10-28 17:00:53.625');
INSERT INTO `device_alert_record` VALUES (190, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:01:43.689', '2026-10-28 17:01:43.689');
INSERT INTO `device_alert_record` VALUES (191, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:02:33.757', '2026-10-28 17:02:33.757');
INSERT INTO `device_alert_record` VALUES (192, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:03:23.816', '2026-10-28 17:03:23.816');
INSERT INTO `device_alert_record` VALUES (193, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:04:13.868', '2026-10-28 17:04:13.868');
INSERT INTO `device_alert_record` VALUES (194, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:05:03.938', '2026-10-28 17:05:03.938');
INSERT INTO `device_alert_record` VALUES (195, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:05:54.019', '2026-10-28 17:05:54.019');
INSERT INTO `device_alert_record` VALUES (196, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:06:44.041', '2026-10-28 17:06:44.041');
INSERT INTO `device_alert_record` VALUES (197, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:07:34.100', '2026-10-28 17:07:34.100');
INSERT INTO `device_alert_record` VALUES (198, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:08:24.163', '2026-10-28 17:08:24.163');
INSERT INTO `device_alert_record` VALUES (199, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:09:14.244', '2026-10-28 17:09:14.244');
INSERT INTO `device_alert_record` VALUES (200, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:10:04.318', '2026-10-28 17:10:04.318');
INSERT INTO `device_alert_record` VALUES (201, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:10:54.355', '2026-10-28 17:10:54.355');
INSERT INTO `device_alert_record` VALUES (202, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:11:44.381', '2026-10-28 17:11:44.381');
INSERT INTO `device_alert_record` VALUES (203, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:12:34.429', '2026-10-28 17:12:34.429');
INSERT INTO `device_alert_record` VALUES (204, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:13:24.485', '2026-10-28 17:13:24.485');
INSERT INTO `device_alert_record` VALUES (205, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:14:14.518', '2026-10-28 17:14:14.518');
INSERT INTO `device_alert_record` VALUES (206, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:15:04.580', '2026-10-28 17:15:04.580');
INSERT INTO `device_alert_record` VALUES (207, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:15:54.603', '2026-10-28 17:15:54.603');
INSERT INTO `device_alert_record` VALUES (208, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:16:44.666', '2026-10-28 17:16:44.666');
INSERT INTO `device_alert_record` VALUES (209, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:17:34.698', '2026-10-28 17:17:34.698');
INSERT INTO `device_alert_record` VALUES (210, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:18:24.750', '2026-10-28 17:18:24.750');
INSERT INTO `device_alert_record` VALUES (211, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:19:14.815', '2026-10-28 17:19:14.815');
INSERT INTO `device_alert_record` VALUES (212, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:20:04.841', '2026-10-28 17:20:04.841');
INSERT INTO `device_alert_record` VALUES (213, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:20:54.873', '2026-10-28 17:20:54.873');
INSERT INTO `device_alert_record` VALUES (214, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:21:44.931', '2026-10-28 17:21:44.931');
INSERT INTO `device_alert_record` VALUES (215, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:22:34.962', '2026-10-28 17:22:34.962');
INSERT INTO `device_alert_record` VALUES (216, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:23:25.006', '2026-10-28 17:23:25.006');
INSERT INTO `device_alert_record` VALUES (217, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:24:15.056', '2026-10-28 17:24:15.056');
INSERT INTO `device_alert_record` VALUES (218, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:25:05.119', '2026-10-28 17:25:05.119');
INSERT INTO `device_alert_record` VALUES (219, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:25:55.169', '2026-10-28 17:25:55.169');
INSERT INTO `device_alert_record` VALUES (220, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:26:45.216', '2026-10-28 17:26:45.216');
INSERT INTO `device_alert_record` VALUES (221, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:27:35.263', '2026-10-28 17:27:35.263');
INSERT INTO `device_alert_record` VALUES (222, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:28:25.290', '2026-10-28 17:28:25.290');
INSERT INTO `device_alert_record` VALUES (223, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:29:15.339', '2026-10-28 17:29:15.339');
INSERT INTO `device_alert_record` VALUES (224, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:30:05.378', '2026-10-28 17:30:05.378');
INSERT INTO `device_alert_record` VALUES (225, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:30:55.428', '2026-10-28 17:30:55.428');
INSERT INTO `device_alert_record` VALUES (226, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:31:45.484', '2026-10-28 17:31:45.484');
INSERT INTO `device_alert_record` VALUES (227, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:32:35.535', '2026-10-28 17:32:35.535');
INSERT INTO `device_alert_record` VALUES (228, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:33:25.565', '2026-10-28 17:33:25.565');
INSERT INTO `device_alert_record` VALUES (229, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:34:15.601', '2026-10-28 17:34:15.601');
INSERT INTO `device_alert_record` VALUES (230, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:35:05.650', '2026-10-28 17:35:05.650');
INSERT INTO `device_alert_record` VALUES (231, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:35:55.681', '2026-10-28 17:35:55.681');
INSERT INTO `device_alert_record` VALUES (232, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:36:45.723', '2026-10-28 17:36:45.723');
INSERT INTO `device_alert_record` VALUES (233, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:37:35.744', '2026-10-28 17:37:35.744');
INSERT INTO `device_alert_record` VALUES (234, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:38:25.796', '2026-10-28 17:38:25.796');
INSERT INTO `device_alert_record` VALUES (235, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:39:15.861', '2026-10-28 17:39:15.861');
INSERT INTO `device_alert_record` VALUES (236, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:40:05.902', '2026-10-28 17:40:05.902');
INSERT INTO `device_alert_record` VALUES (237, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:40:55.949', '2026-10-28 17:40:55.949');
INSERT INTO `device_alert_record` VALUES (238, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:41:46.000', '2026-10-28 17:41:46.000');
INSERT INTO `device_alert_record` VALUES (239, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:42:36.030', '2026-10-28 17:42:36.030');
INSERT INTO `device_alert_record` VALUES (240, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:43:26.065', '2026-10-28 17:43:26.065');
INSERT INTO `device_alert_record` VALUES (241, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:44:16.150', '2026-10-28 17:44:16.150');
INSERT INTO `device_alert_record` VALUES (242, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:45:06.199', '2026-10-28 17:45:06.199');
INSERT INTO `device_alert_record` VALUES (243, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:45:56.229', '2026-10-28 17:45:56.229');
INSERT INTO `device_alert_record` VALUES (244, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:46:46.281', '2026-10-28 17:46:46.281');
INSERT INTO `device_alert_record` VALUES (245, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:47:36.334', '2026-10-28 17:47:36.334');
INSERT INTO `device_alert_record` VALUES (246, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:48:26.375', '2026-10-28 17:48:26.375');
INSERT INTO `device_alert_record` VALUES (247, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:49:16.428', '2026-10-28 17:49:16.428');
INSERT INTO `device_alert_record` VALUES (248, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:50:06.471', '2026-10-28 17:50:06.471');
INSERT INTO `device_alert_record` VALUES (249, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:50:56.530', '2026-10-28 17:50:56.530');
INSERT INTO `device_alert_record` VALUES (250, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:51:46.579', '2026-10-28 17:51:46.579');
INSERT INTO `device_alert_record` VALUES (251, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:52:36.631', '2026-10-28 17:52:36.631');
INSERT INTO `device_alert_record` VALUES (252, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:53:26.654', '2026-10-28 17:53:26.654');
INSERT INTO `device_alert_record` VALUES (253, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:54:16.712', '2026-10-28 17:54:16.712');
INSERT INTO `device_alert_record` VALUES (254, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:55:06.774', '2026-10-28 17:55:06.774');
INSERT INTO `device_alert_record` VALUES (255, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:55:56.831', '2026-10-28 17:55:56.831');
INSERT INTO `device_alert_record` VALUES (256, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:56:46.826', '2026-10-28 17:56:46.826');
INSERT INTO `device_alert_record` VALUES (257, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:57:36.882', '2026-10-28 17:57:36.882');
INSERT INTO `device_alert_record` VALUES (258, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:58:26.932', '2026-10-28 17:58:26.932');
INSERT INTO `device_alert_record` VALUES (259, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 17:59:17.009', '2026-10-28 17:59:17.009');
INSERT INTO `device_alert_record` VALUES (260, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:00:07.031', '2026-10-28 18:00:07.031');
INSERT INTO `device_alert_record` VALUES (261, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:00:57.067', '2026-10-28 18:00:57.067');
INSERT INTO `device_alert_record` VALUES (262, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:01:47.115', '2026-10-28 18:01:47.115');
INSERT INTO `device_alert_record` VALUES (263, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:02:37.150', '2026-10-28 18:02:37.150');
INSERT INTO `device_alert_record` VALUES (264, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:03:27.230', '2026-10-28 18:03:27.230');
INSERT INTO `device_alert_record` VALUES (265, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:07:09.488', '2026-10-28 18:07:09.488');
INSERT INTO `device_alert_record` VALUES (266, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:07:59.527', '2026-10-28 18:07:59.527');
INSERT INTO `device_alert_record` VALUES (267, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:08:49.588', '2026-10-28 18:08:49.588');
INSERT INTO `device_alert_record` VALUES (268, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:09:39.622', '2026-10-28 18:09:39.622');
INSERT INTO `device_alert_record` VALUES (269, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:10:29.675', '2026-10-28 18:10:29.675');
INSERT INTO `device_alert_record` VALUES (270, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:11:19.725', '2026-10-28 18:11:19.725');
INSERT INTO `device_alert_record` VALUES (271, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:12:09.770', '2026-10-28 18:12:09.770');
INSERT INTO `device_alert_record` VALUES (272, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:12:59.853', '2026-10-28 18:12:59.853');
INSERT INTO `device_alert_record` VALUES (273, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:15:30.000', '2026-10-28 18:15:30.000');
INSERT INTO `device_alert_record` VALUES (274, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:16:20.043', '2026-10-28 18:16:20.043');
INSERT INTO `device_alert_record` VALUES (275, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:17:10.094', '2026-10-28 18:17:10.094');
INSERT INTO `device_alert_record` VALUES (276, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:18:00.132', '2026-10-28 18:18:00.132');
INSERT INTO `device_alert_record` VALUES (277, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:18:50.161', '2026-10-28 18:18:50.161');
INSERT INTO `device_alert_record` VALUES (278, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:19:40.189', '2026-10-28 18:19:40.189');
INSERT INTO `device_alert_record` VALUES (279, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:20:30.230', '2026-10-28 18:20:30.230');
INSERT INTO `device_alert_record` VALUES (280, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:21:20.263', '2026-10-28 18:21:20.263');
INSERT INTO `device_alert_record` VALUES (281, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:22:10.299', '2026-10-28 18:22:10.299');
INSERT INTO `device_alert_record` VALUES (282, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:23:00.354', '2026-10-28 18:23:00.354');
INSERT INTO `device_alert_record` VALUES (283, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:23:50.415', '2026-10-28 18:23:50.415');
INSERT INTO `device_alert_record` VALUES (284, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:24:40.481', '2026-10-28 18:24:40.481');
INSERT INTO `device_alert_record` VALUES (285, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:25:30.551', '2026-10-28 18:25:30.551');
INSERT INTO `device_alert_record` VALUES (286, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:26:20.580', '2026-10-28 18:26:20.580');
INSERT INTO `device_alert_record` VALUES (287, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:27:10.623', '2026-10-28 18:27:10.623');
INSERT INTO `device_alert_record` VALUES (288, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:28:00.672', '2026-10-28 18:28:00.672');
INSERT INTO `device_alert_record` VALUES (289, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:28:50.707', '2026-10-28 18:28:50.707');
INSERT INTO `device_alert_record` VALUES (290, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:29:40.767', '2026-10-28 18:29:40.767');
INSERT INTO `device_alert_record` VALUES (291, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:30:30.822', '2026-10-28 18:30:30.822');
INSERT INTO `device_alert_record` VALUES (292, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:36:21.210', '2026-10-28 18:36:21.210');
INSERT INTO `device_alert_record` VALUES (293, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:37:11.220', '2026-10-28 18:37:11.220');
INSERT INTO `device_alert_record` VALUES (294, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:38:01.236', '2026-10-28 18:38:01.236');
INSERT INTO `device_alert_record` VALUES (295, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:38:51.265', '2026-10-28 18:38:51.265');
INSERT INTO `device_alert_record` VALUES (296, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:39:41.334', '2026-10-28 18:39:41.334');
INSERT INTO `device_alert_record` VALUES (297, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:40:31.355', '2026-10-28 18:40:31.355');
INSERT INTO `device_alert_record` VALUES (298, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:41:21.400', '2026-10-28 18:41:21.400');
INSERT INTO `device_alert_record` VALUES (299, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:42:11.471', '2026-10-28 18:42:11.471');
INSERT INTO `device_alert_record` VALUES (300, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:43:01.504', '2026-10-28 18:43:01.504');
INSERT INTO `device_alert_record` VALUES (301, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:43:51.537', '2026-10-28 18:43:51.537');
INSERT INTO `device_alert_record` VALUES (302, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:44:41.601', '2026-10-28 18:44:41.601');
INSERT INTO `device_alert_record` VALUES (303, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:45:31.652', '2026-10-28 18:45:31.652');
INSERT INTO `device_alert_record` VALUES (304, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:46:21.702', '2026-10-28 18:46:21.702');
INSERT INTO `device_alert_record` VALUES (305, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:47:11.734', '2026-10-28 18:47:11.734');
INSERT INTO `device_alert_record` VALUES (306, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:48:01.951', '2026-10-28 18:48:01.951');
INSERT INTO `device_alert_record` VALUES (307, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:48:52.016', '2026-10-28 18:48:52.016');
INSERT INTO `device_alert_record` VALUES (308, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:49:42.071', '2026-10-28 18:49:42.071');
INSERT INTO `device_alert_record` VALUES (309, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:50:32.120', '2026-10-28 18:50:32.120');
INSERT INTO `device_alert_record` VALUES (310, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:51:22.165', '2026-10-28 18:51:22.165');
INSERT INTO `device_alert_record` VALUES (311, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:52:12.231', '2026-10-28 18:52:12.231');
INSERT INTO `device_alert_record` VALUES (312, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:53:02.252', '2026-10-28 18:53:02.252');
INSERT INTO `device_alert_record` VALUES (313, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:53:52.310', '2026-10-28 18:53:52.310');
INSERT INTO `device_alert_record` VALUES (314, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:54:42.379', '2026-10-28 18:54:42.379');
INSERT INTO `device_alert_record` VALUES (315, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:55:32.395', '2026-10-28 18:55:32.395');
INSERT INTO `device_alert_record` VALUES (316, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:56:22.439', '2026-10-28 18:56:22.439');
INSERT INTO `device_alert_record` VALUES (317, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:57:12.471', '2026-10-28 18:57:12.471');
INSERT INTO `device_alert_record` VALUES (318, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:58:02.531', '2026-10-28 18:58:02.531');
INSERT INTO `device_alert_record` VALUES (319, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:58:52.571', '2026-10-28 18:58:52.571');
INSERT INTO `device_alert_record` VALUES (320, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 18:59:42.606', '2026-10-28 18:59:42.606');
INSERT INTO `device_alert_record` VALUES (321, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:00:32.660', '2026-10-28 19:00:32.660');
INSERT INTO `device_alert_record` VALUES (322, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:01:22.687', '2026-10-28 19:01:22.687');
INSERT INTO `device_alert_record` VALUES (323, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:03:52.844', '2026-10-28 19:03:52.844');
INSERT INTO `device_alert_record` VALUES (324, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:04:42.889', '2026-10-28 19:04:42.889');
INSERT INTO `device_alert_record` VALUES (325, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:05:32.938', '2026-10-28 19:05:32.938');
INSERT INTO `device_alert_record` VALUES (326, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:06:22.986', '2026-10-28 19:06:22.986');
INSERT INTO `device_alert_record` VALUES (327, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:07:13.059', '2026-10-28 19:07:13.059');
INSERT INTO `device_alert_record` VALUES (328, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:08:03.066', '2026-10-28 19:08:03.066');
INSERT INTO `device_alert_record` VALUES (329, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:08:53.162', '2026-10-28 19:08:53.162');
INSERT INTO `device_alert_record` VALUES (330, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:09:43.173', '2026-10-28 19:09:43.173');
INSERT INTO `device_alert_record` VALUES (331, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:10:33.213', '2026-10-28 19:10:33.213');
INSERT INTO `device_alert_record` VALUES (332, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:11:23.253', '2026-10-28 19:11:23.253');
INSERT INTO `device_alert_record` VALUES (333, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:14:43.446', '2026-10-28 19:14:43.446');
INSERT INTO `device_alert_record` VALUES (334, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:15:33.488', '2026-10-28 19:15:33.488');
INSERT INTO `device_alert_record` VALUES (335, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:16:23.532', '2026-10-28 19:16:23.532');
INSERT INTO `device_alert_record` VALUES (336, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:17:13.600', '2026-10-28 19:17:13.600');
INSERT INTO `device_alert_record` VALUES (337, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:18:53.701', '2026-10-28 19:18:53.701');
INSERT INTO `device_alert_record` VALUES (338, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:23:03.921', '2026-10-28 19:23:03.921');
INSERT INTO `device_alert_record` VALUES (339, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:23:53.974', '2026-10-28 19:23:53.974');
INSERT INTO `device_alert_record` VALUES (340, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:24:44.015', '2026-10-28 19:24:44.015');
INSERT INTO `device_alert_record` VALUES (341, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:25:34.054', '2026-10-28 19:25:34.054');
INSERT INTO `device_alert_record` VALUES (342, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:26:24.100', '2026-10-28 19:26:24.100');
INSERT INTO `device_alert_record` VALUES (343, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:27:14.180', '2026-10-28 19:27:14.180');
INSERT INTO `device_alert_record` VALUES (344, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:28:04.192', '2026-10-28 19:28:04.192');
INSERT INTO `device_alert_record` VALUES (345, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:28:54.228', '2026-10-28 19:28:54.228');
INSERT INTO `device_alert_record` VALUES (346, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:29:44.282', '2026-10-28 19:29:44.282');
INSERT INTO `device_alert_record` VALUES (347, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:30:34.338', '2026-10-28 19:30:34.338');
INSERT INTO `device_alert_record` VALUES (348, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-28 19:31:24.376', '2026-10-28 19:31:24.376');
INSERT INTO `device_alert_record` VALUES (349, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 08:57:39.763', '2026-10-29 08:57:39.766');
INSERT INTO `device_alert_record` VALUES (350, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 08:58:29.800', '2026-10-29 08:58:29.800');
INSERT INTO `device_alert_record` VALUES (351, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 08:59:19.879', '2026-10-29 08:59:19.879');
INSERT INTO `device_alert_record` VALUES (352, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:00:09.893', '2026-10-29 09:00:09.893');
INSERT INTO `device_alert_record` VALUES (353, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:00:59.919', '2026-10-29 09:00:59.920');
INSERT INTO `device_alert_record` VALUES (354, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:01:49.962', '2026-10-29 09:01:49.962');
INSERT INTO `device_alert_record` VALUES (355, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:02:40.001', '2026-10-29 09:02:40.001');
INSERT INTO `device_alert_record` VALUES (356, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:03:30.051', '2026-10-29 09:03:30.051');
INSERT INTO `device_alert_record` VALUES (357, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:04:20.093', '2026-10-29 09:04:20.093');
INSERT INTO `device_alert_record` VALUES (358, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:05:10.142', '2026-10-29 09:05:10.142');
INSERT INTO `device_alert_record` VALUES (359, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:06:00.185', '2026-10-29 09:06:00.186');
INSERT INTO `device_alert_record` VALUES (360, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:06:50.220', '2026-10-29 09:06:50.220');
INSERT INTO `device_alert_record` VALUES (361, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:07:40.299', '2026-10-29 09:07:40.299');
INSERT INTO `device_alert_record` VALUES (362, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:08:30.308', '2026-10-29 09:08:30.308');
INSERT INTO `device_alert_record` VALUES (363, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:09:20.378', '2026-10-29 09:09:20.378');
INSERT INTO `device_alert_record` VALUES (364, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:10:10.403', '2026-10-29 09:10:10.403');
INSERT INTO `device_alert_record` VALUES (365, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:11:00.456', '2026-10-29 09:11:00.458');
INSERT INTO `device_alert_record` VALUES (366, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:11:50.499', '2026-10-29 09:11:50.501');
INSERT INTO `device_alert_record` VALUES (367, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:12:40.547', '2026-10-29 09:12:40.547');
INSERT INTO `device_alert_record` VALUES (368, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:13:30.580', '2026-10-29 09:13:30.580');
INSERT INTO `device_alert_record` VALUES (369, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:14:20.621', '2026-10-29 09:14:20.621');
INSERT INTO `device_alert_record` VALUES (370, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:15:10.681', '2026-10-29 09:15:10.681');
INSERT INTO `device_alert_record` VALUES (371, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:16:00.716', '2026-10-29 09:16:00.717');
INSERT INTO `device_alert_record` VALUES (372, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:16:50.775', '2026-10-29 09:16:50.775');
INSERT INTO `device_alert_record` VALUES (373, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:17:40.823', '2026-10-29 09:17:40.823');
INSERT INTO `device_alert_record` VALUES (374, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:18:30.842', '2026-10-29 09:18:30.843');
INSERT INTO `device_alert_record` VALUES (375, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:19:20.871', '2026-10-29 09:19:20.871');
INSERT INTO `device_alert_record` VALUES (376, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:20:10.913', '2026-10-29 09:20:10.913');
INSERT INTO `device_alert_record` VALUES (377, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:21:00.973', '2026-10-29 09:21:00.973');
INSERT INTO `device_alert_record` VALUES (378, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:21:51.034', '2026-10-29 09:21:51.035');
INSERT INTO `device_alert_record` VALUES (379, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:22:41.080', '2026-10-29 09:22:41.081');
INSERT INTO `device_alert_record` VALUES (380, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:23:31.134', '2026-10-29 09:23:31.134');
INSERT INTO `device_alert_record` VALUES (381, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:24:21.180', '2026-10-29 09:24:21.180');
INSERT INTO `device_alert_record` VALUES (382, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:25:11.223', '2026-10-29 09:25:11.224');
INSERT INTO `device_alert_record` VALUES (383, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:26:01.279', '2026-10-29 09:26:01.279');
INSERT INTO `device_alert_record` VALUES (384, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:26:51.303', '2026-10-29 09:26:51.304');
INSERT INTO `device_alert_record` VALUES (385, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:27:41.338', '2026-10-29 09:27:41.338');
INSERT INTO `device_alert_record` VALUES (386, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:28:31.399', '2026-10-29 09:28:31.399');
INSERT INTO `device_alert_record` VALUES (387, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:29:21.455', '2026-10-29 09:29:21.456');
INSERT INTO `device_alert_record` VALUES (388, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:30:11.508', '2026-10-29 09:30:11.509');
INSERT INTO `device_alert_record` VALUES (389, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:31:01.566', '2026-10-29 09:31:01.566');
INSERT INTO `device_alert_record` VALUES (390, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:31:51.607', '2026-10-29 09:31:51.607');
INSERT INTO `device_alert_record` VALUES (391, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:32:41.666', '2026-10-29 09:32:41.666');
INSERT INTO `device_alert_record` VALUES (392, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:33:31.687', '2026-10-29 09:33:31.687');
INSERT INTO `device_alert_record` VALUES (393, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:34:21.735', '2026-10-29 09:34:21.735');
INSERT INTO `device_alert_record` VALUES (394, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:35:11.773', '2026-10-29 09:35:11.773');
INSERT INTO `device_alert_record` VALUES (395, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:36:01.828', '2026-10-29 09:36:01.829');
INSERT INTO `device_alert_record` VALUES (396, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:36:51.870', '2026-10-29 09:36:51.870');
INSERT INTO `device_alert_record` VALUES (397, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:37:41.924', '2026-10-29 09:37:41.924');
INSERT INTO `device_alert_record` VALUES (398, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:38:31.970', '2026-10-29 09:38:31.970');
INSERT INTO `device_alert_record` VALUES (399, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:39:22.013', '2026-10-29 09:39:22.014');
INSERT INTO `device_alert_record` VALUES (400, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:40:12.033', '2026-10-29 09:40:12.033');
INSERT INTO `device_alert_record` VALUES (401, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:41:02.075', '2026-10-29 09:41:02.084');
INSERT INTO `device_alert_record` VALUES (402, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:41:52.113', '2026-10-29 09:41:52.114');
INSERT INTO `device_alert_record` VALUES (403, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:42:42.141', '2026-10-29 09:42:42.141');
INSERT INTO `device_alert_record` VALUES (404, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:43:32.193', '2026-10-29 09:43:32.193');
INSERT INTO `device_alert_record` VALUES (405, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:44:22.230', '2026-10-29 09:44:22.231');
INSERT INTO `device_alert_record` VALUES (406, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:45:12.279', '2026-10-29 09:45:12.279');
INSERT INTO `device_alert_record` VALUES (407, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:46:02.344', '2026-10-29 09:46:02.345');
INSERT INTO `device_alert_record` VALUES (408, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:46:52.368', '2026-10-29 09:46:52.368');
INSERT INTO `device_alert_record` VALUES (409, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:47:42.427', '2026-10-29 09:47:42.432');
INSERT INTO `device_alert_record` VALUES (410, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:48:32.451', '2026-10-29 09:48:32.451');
INSERT INTO `device_alert_record` VALUES (411, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:49:22.494', '2026-10-29 09:49:22.494');
INSERT INTO `device_alert_record` VALUES (412, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:50:12.531', '2026-10-29 09:50:12.531');
INSERT INTO `device_alert_record` VALUES (413, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:51:02.596', '2026-10-29 09:51:02.596');
INSERT INTO `device_alert_record` VALUES (414, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:51:52.664', '2026-10-29 09:51:52.665');
INSERT INTO `device_alert_record` VALUES (415, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:52:42.712', '2026-10-29 09:52:42.712');
INSERT INTO `device_alert_record` VALUES (416, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:53:32.749', '2026-10-29 09:53:32.750');
INSERT INTO `device_alert_record` VALUES (417, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:54:22.790', '2026-10-29 09:54:22.790');
INSERT INTO `device_alert_record` VALUES (418, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:55:12.857', '2026-10-29 09:55:12.859');
INSERT INTO `device_alert_record` VALUES (419, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:56:02.880', '2026-10-29 09:56:02.880');
INSERT INTO `device_alert_record` VALUES (420, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:56:52.906', '2026-10-29 09:56:52.907');
INSERT INTO `device_alert_record` VALUES (421, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:57:42.936', '2026-10-29 09:57:42.937');
INSERT INTO `device_alert_record` VALUES (422, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:58:32.977', '2026-10-29 09:58:32.977');
INSERT INTO `device_alert_record` VALUES (423, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 09:59:23.025', '2026-10-29 09:59:23.025');
INSERT INTO `device_alert_record` VALUES (424, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:00:13.071', '2026-10-29 10:00:13.071');
INSERT INTO `device_alert_record` VALUES (425, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:01:03.108', '2026-10-29 10:01:03.108');
INSERT INTO `device_alert_record` VALUES (426, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:01:53.160', '2026-10-29 10:01:53.160');
INSERT INTO `device_alert_record` VALUES (427, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:02:43.192', '2026-10-29 10:02:43.193');
INSERT INTO `device_alert_record` VALUES (428, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:03:33.224', '2026-10-29 10:03:33.225');
INSERT INTO `device_alert_record` VALUES (429, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:04:23.280', '2026-10-29 10:04:23.281');
INSERT INTO `device_alert_record` VALUES (430, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:05:13.325', '2026-10-29 10:05:13.325');
INSERT INTO `device_alert_record` VALUES (431, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:06:03.365', '2026-10-29 10:06:03.366');
INSERT INTO `device_alert_record` VALUES (432, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:06:53.412', '2026-10-29 10:06:53.412');
INSERT INTO `device_alert_record` VALUES (433, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:07:43.462', '2026-10-29 10:07:43.462');
INSERT INTO `device_alert_record` VALUES (434, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:08:33.507', '2026-10-29 10:08:33.507');
INSERT INTO `device_alert_record` VALUES (435, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:09:23.539', '2026-10-29 10:09:23.539');
INSERT INTO `device_alert_record` VALUES (436, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:10:13.577', '2026-10-29 10:10:13.577');
INSERT INTO `device_alert_record` VALUES (437, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:11:03.637', '2026-10-29 10:11:03.637');
INSERT INTO `device_alert_record` VALUES (438, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:11:53.685', '2026-10-29 10:11:53.685');
INSERT INTO `device_alert_record` VALUES (439, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:12:43.732', '2026-10-29 10:12:43.732');
INSERT INTO `device_alert_record` VALUES (440, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:13:33.777', '2026-10-29 10:13:33.777');
INSERT INTO `device_alert_record` VALUES (441, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:14:23.828', '2026-10-29 10:14:23.828');
INSERT INTO `device_alert_record` VALUES (442, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:15:13.880', '2026-10-29 10:15:13.880');
INSERT INTO `device_alert_record` VALUES (443, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:16:03.910', '2026-10-29 10:16:03.910');
INSERT INTO `device_alert_record` VALUES (444, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:16:53.949', '2026-10-29 10:16:53.949');
INSERT INTO `device_alert_record` VALUES (445, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:17:43.991', '2026-10-29 10:17:43.992');
INSERT INTO `device_alert_record` VALUES (446, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:18:34.038', '2026-10-29 10:18:34.039');
INSERT INTO `device_alert_record` VALUES (447, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:20:14.118', '2026-10-29 10:20:14.120');
INSERT INTO `device_alert_record` VALUES (448, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:21:04.168', '2026-10-29 10:21:04.168');
INSERT INTO `device_alert_record` VALUES (449, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:21:54.196', '2026-10-29 10:21:54.196');
INSERT INTO `device_alert_record` VALUES (450, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:22:44.246', '2026-10-29 10:22:44.246');
INSERT INTO `device_alert_record` VALUES (451, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:23:34.298', '2026-10-29 10:23:34.298');
INSERT INTO `device_alert_record` VALUES (452, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:24:24.344', '2026-10-29 10:24:24.344');
INSERT INTO `device_alert_record` VALUES (453, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:25:14.385', '2026-10-29 10:25:14.385');
INSERT INTO `device_alert_record` VALUES (454, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:26:04.436', '2026-10-29 10:26:04.436');
INSERT INTO `device_alert_record` VALUES (455, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:26:54.485', '2026-10-29 10:26:54.485');
INSERT INTO `device_alert_record` VALUES (456, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:27:44.525', '2026-10-29 10:27:44.525');
INSERT INTO `device_alert_record` VALUES (457, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:28:34.562', '2026-10-29 10:28:34.562');
INSERT INTO `device_alert_record` VALUES (458, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:29:24.608', '2026-10-29 10:29:24.609');
INSERT INTO `device_alert_record` VALUES (459, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:30:14.665', '2026-10-29 10:30:14.665');
INSERT INTO `device_alert_record` VALUES (460, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:31:04.706', '2026-10-29 10:31:04.706');
INSERT INTO `device_alert_record` VALUES (461, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:31:54.730', '2026-10-29 10:31:54.730');
INSERT INTO `device_alert_record` VALUES (462, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:32:44.793', '2026-10-29 10:32:44.793');
INSERT INTO `device_alert_record` VALUES (463, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:33:34.848', '2026-10-29 10:33:34.848');
INSERT INTO `device_alert_record` VALUES (464, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:34:24.907', '2026-10-29 10:34:24.908');
INSERT INTO `device_alert_record` VALUES (465, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:35:14.983', '2026-10-29 10:35:14.983');
INSERT INTO `device_alert_record` VALUES (466, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:36:04.987', '2026-10-29 10:36:04.988');
INSERT INTO `device_alert_record` VALUES (467, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:36:55.048', '2026-10-29 10:36:55.048');
INSERT INTO `device_alert_record` VALUES (468, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:37:45.051', '2026-10-29 10:37:45.052');
INSERT INTO `device_alert_record` VALUES (469, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:38:35.092', '2026-10-29 10:38:35.092');
INSERT INTO `device_alert_record` VALUES (470, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:39:25.131', '2026-10-29 10:39:25.132');
INSERT INTO `device_alert_record` VALUES (471, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:40:15.185', '2026-10-29 10:40:15.185');
INSERT INTO `device_alert_record` VALUES (472, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:41:05.260', '2026-10-29 10:41:05.260');
INSERT INTO `device_alert_record` VALUES (473, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:41:55.304', '2026-10-29 10:41:55.304');
INSERT INTO `device_alert_record` VALUES (474, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:42:45.354', '2026-10-29 10:42:45.354');
INSERT INTO `device_alert_record` VALUES (475, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:43:35.390', '2026-10-29 10:43:35.390');
INSERT INTO `device_alert_record` VALUES (476, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:44:25.437', '2026-10-29 10:44:25.437');
INSERT INTO `device_alert_record` VALUES (477, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:45:15.475', '2026-10-29 10:45:15.475');
INSERT INTO `device_alert_record` VALUES (478, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:46:05.522', '2026-10-29 10:46:05.523');
INSERT INTO `device_alert_record` VALUES (479, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:46:55.577', '2026-10-29 10:46:55.578');
INSERT INTO `device_alert_record` VALUES (480, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:47:45.607', '2026-10-29 10:47:45.607');
INSERT INTO `device_alert_record` VALUES (481, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:48:35.642', '2026-10-29 10:48:35.642');
INSERT INTO `device_alert_record` VALUES (482, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:49:25.697', '2026-10-29 10:49:25.697');
INSERT INTO `device_alert_record` VALUES (483, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:50:15.757', '2026-10-29 10:50:15.757');
INSERT INTO `device_alert_record` VALUES (484, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:51:05.825', '2026-10-29 10:51:05.825');
INSERT INTO `device_alert_record` VALUES (485, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:51:55.874', '2026-10-29 10:51:55.875');
INSERT INTO `device_alert_record` VALUES (486, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:52:45.912', '2026-10-29 10:52:45.912');
INSERT INTO `device_alert_record` VALUES (487, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:53:35.960', '2026-10-29 10:53:35.960');
INSERT INTO `device_alert_record` VALUES (488, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:54:26.028', '2026-10-29 10:54:26.029');
INSERT INTO `device_alert_record` VALUES (489, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:55:16.074', '2026-10-29 10:55:16.080');
INSERT INTO `device_alert_record` VALUES (490, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:56:06.141', '2026-10-29 10:56:06.141');
INSERT INTO `device_alert_record` VALUES (491, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:56:56.202', '2026-10-29 10:56:56.203');
INSERT INTO `device_alert_record` VALUES (492, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:57:46.251', '2026-10-29 10:57:46.251');
INSERT INTO `device_alert_record` VALUES (493, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:58:36.278', '2026-10-29 10:58:36.278');
INSERT INTO `device_alert_record` VALUES (494, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 10:59:26.322', '2026-10-29 10:59:26.324');
INSERT INTO `device_alert_record` VALUES (495, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:00:16.351', '2026-10-29 11:00:16.352');
INSERT INTO `device_alert_record` VALUES (496, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:01:06.374', '2026-10-29 11:01:06.374');
INSERT INTO `device_alert_record` VALUES (497, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:01:56.414', '2026-10-29 11:01:56.414');
INSERT INTO `device_alert_record` VALUES (498, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:02:46.443', '2026-10-29 11:02:46.443');
INSERT INTO `device_alert_record` VALUES (499, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:03:36.502', '2026-10-29 11:03:36.502');
INSERT INTO `device_alert_record` VALUES (500, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:04:26.558', '2026-10-29 11:04:26.558');
INSERT INTO `device_alert_record` VALUES (501, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:05:16.607', '2026-10-29 11:05:16.607');
INSERT INTO `device_alert_record` VALUES (502, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:06:06.645', '2026-10-29 11:06:06.645');
INSERT INTO `device_alert_record` VALUES (503, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:06:56.667', '2026-10-29 11:06:56.667');
INSERT INTO `device_alert_record` VALUES (504, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:07:46.690', '2026-10-29 11:07:46.691');
INSERT INTO `device_alert_record` VALUES (505, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:08:36.724', '2026-10-29 11:08:36.724');
INSERT INTO `device_alert_record` VALUES (506, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:09:26.770', '2026-10-29 11:09:26.770');
INSERT INTO `device_alert_record` VALUES (507, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:10:16.816', '2026-10-29 11:10:16.816');
INSERT INTO `device_alert_record` VALUES (508, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:11:06.852', '2026-10-29 11:11:06.853');
INSERT INTO `device_alert_record` VALUES (509, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:11:56.882', '2026-10-29 11:11:56.882');
INSERT INTO `device_alert_record` VALUES (510, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:12:46.920', '2026-10-29 11:12:46.921');
INSERT INTO `device_alert_record` VALUES (511, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:13:36.946', '2026-10-29 11:13:36.947');
INSERT INTO `device_alert_record` VALUES (512, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:14:26.996', '2026-10-29 11:14:26.996');
INSERT INTO `device_alert_record` VALUES (513, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:15:17.027', '2026-10-29 11:15:17.027');
INSERT INTO `device_alert_record` VALUES (514, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:16:07.066', '2026-10-29 11:16:07.067');
INSERT INTO `device_alert_record` VALUES (515, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:16:57.114', '2026-10-29 11:16:57.115');
INSERT INTO `device_alert_record` VALUES (516, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:17:47.153', '2026-10-29 11:17:47.155');
INSERT INTO `device_alert_record` VALUES (517, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:18:37.194', '2026-10-29 11:18:37.194');
INSERT INTO `device_alert_record` VALUES (518, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:19:27.229', '2026-10-29 11:19:27.230');
INSERT INTO `device_alert_record` VALUES (519, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:20:17.276', '2026-10-29 11:20:17.277');
INSERT INTO `device_alert_record` VALUES (520, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:21:07.309', '2026-10-29 11:21:07.309');
INSERT INTO `device_alert_record` VALUES (521, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:21:57.364', '2026-10-29 11:21:57.364');
INSERT INTO `device_alert_record` VALUES (522, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:22:47.417', '2026-10-29 11:22:47.418');
INSERT INTO `device_alert_record` VALUES (523, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:23:37.454', '2026-10-29 11:23:37.454');
INSERT INTO `device_alert_record` VALUES (524, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:24:27.493', '2026-10-29 11:24:27.494');
INSERT INTO `device_alert_record` VALUES (525, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:25:17.544', '2026-10-29 11:25:17.544');
INSERT INTO `device_alert_record` VALUES (526, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:26:07.601', '2026-10-29 11:26:07.601');
INSERT INTO `device_alert_record` VALUES (527, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:26:57.652', '2026-10-29 11:26:57.653');
INSERT INTO `device_alert_record` VALUES (528, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:27:47.688', '2026-10-29 11:27:47.690');
INSERT INTO `device_alert_record` VALUES (529, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:28:37.758', '2026-10-29 11:28:37.758');
INSERT INTO `device_alert_record` VALUES (530, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:29:27.794', '2026-10-29 11:29:27.795');
INSERT INTO `device_alert_record` VALUES (531, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:30:17.824', '2026-10-29 11:30:17.824');
INSERT INTO `device_alert_record` VALUES (532, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:31:07.860', '2026-10-29 11:31:07.860');
INSERT INTO `device_alert_record` VALUES (533, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:31:57.914', '2026-10-29 11:31:57.914');
INSERT INTO `device_alert_record` VALUES (534, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:32:47.958', '2026-10-29 11:32:47.959');
INSERT INTO `device_alert_record` VALUES (535, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:33:37.986', '2026-10-29 11:33:37.986');
INSERT INTO `device_alert_record` VALUES (536, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:34:28.013', '2026-10-29 11:34:28.013');
INSERT INTO `device_alert_record` VALUES (537, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:35:18.052', '2026-10-29 11:35:18.052');
INSERT INTO `device_alert_record` VALUES (538, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:36:08.088', '2026-10-29 11:36:08.089');
INSERT INTO `device_alert_record` VALUES (539, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:36:58.123', '2026-10-29 11:36:58.123');
INSERT INTO `device_alert_record` VALUES (540, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:37:48.154', '2026-10-29 11:37:48.154');
INSERT INTO `device_alert_record` VALUES (541, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:38:38.192', '2026-10-29 11:38:38.192');
INSERT INTO `device_alert_record` VALUES (542, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:39:28.228', '2026-10-29 11:39:28.230');
INSERT INTO `device_alert_record` VALUES (543, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:40:18.261', '2026-10-29 11:40:18.264');
INSERT INTO `device_alert_record` VALUES (544, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:41:08.316', '2026-10-29 11:41:08.317');
INSERT INTO `device_alert_record` VALUES (545, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:41:58.398', '2026-10-29 11:41:58.399');
INSERT INTO `device_alert_record` VALUES (546, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:42:48.415', '2026-10-29 11:42:48.415');
INSERT INTO `device_alert_record` VALUES (547, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:43:38.516', '2026-10-29 11:43:38.518');
INSERT INTO `device_alert_record` VALUES (548, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:48:38.724', '2026-10-29 11:48:38.725');
INSERT INTO `device_alert_record` VALUES (549, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:53:38.982', '2026-10-29 11:53:38.982');
INSERT INTO `device_alert_record` VALUES (550, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 11:58:39.222', '2026-10-29 11:58:39.222');
INSERT INTO `device_alert_record` VALUES (551, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 12:03:39.475', '2026-10-29 12:03:39.475');
INSERT INTO `device_alert_record` VALUES (552, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 12:08:39.758', '2026-10-29 12:08:39.761');
INSERT INTO `device_alert_record` VALUES (553, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 12:13:40.013', '2026-10-29 12:13:40.013');
INSERT INTO `device_alert_record` VALUES (554, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 12:18:40.300', '2026-10-29 12:18:40.300');
INSERT INTO `device_alert_record` VALUES (555, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 12:23:40.596', '2026-10-29 12:23:40.596');
INSERT INTO `device_alert_record` VALUES (556, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 12:28:40.859', '2026-10-29 12:28:40.859');
INSERT INTO `device_alert_record` VALUES (557, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 12:33:41.135', '2026-10-29 12:33:41.136');
INSERT INTO `device_alert_record` VALUES (558, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 12:38:41.411', '2026-10-29 12:38:41.412');
INSERT INTO `device_alert_record` VALUES (559, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 12:43:41.669', '2026-10-29 12:43:41.669');
INSERT INTO `device_alert_record` VALUES (560, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 12:48:41.901', '2026-10-29 12:48:41.901');
INSERT INTO `device_alert_record` VALUES (561, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 12:53:42.156', '2026-10-29 12:53:42.156');
INSERT INTO `device_alert_record` VALUES (562, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 12:58:42.431', '2026-10-29 12:58:42.431');
INSERT INTO `device_alert_record` VALUES (563, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 13:03:42.700', '2026-10-29 13:03:42.701');
INSERT INTO `device_alert_record` VALUES (564, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 13:08:42.973', '2026-10-29 13:08:42.973');
INSERT INTO `device_alert_record` VALUES (565, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 13:13:43.217', '2026-10-29 13:13:43.217');
INSERT INTO `device_alert_record` VALUES (566, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 13:18:43.465', '2026-10-29 13:18:43.466');
INSERT INTO `device_alert_record` VALUES (567, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 13:23:43.718', '2026-10-29 13:23:43.719');
INSERT INTO `device_alert_record` VALUES (568, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 13:28:43.986', '2026-10-29 13:28:43.987');
INSERT INTO `device_alert_record` VALUES (569, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 13:33:44.281', '2026-10-29 13:33:44.281');
INSERT INTO `device_alert_record` VALUES (570, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 13:40:24.658', '2026-10-29 13:40:24.660');
INSERT INTO `device_alert_record` VALUES (571, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 13:45:24.907', '2026-10-29 13:45:24.908');
INSERT INTO `device_alert_record` VALUES (572, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 13:50:25.185', '2026-10-29 13:50:25.186');
INSERT INTO `device_alert_record` VALUES (573, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 13:55:25.437', '2026-10-29 13:55:25.441');
INSERT INTO `device_alert_record` VALUES (574, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 14:00:25.720', '2026-10-29 14:00:25.721');
INSERT INTO `device_alert_record` VALUES (575, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 14:05:26.003', '2026-10-29 14:05:26.004');
INSERT INTO `device_alert_record` VALUES (576, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 14:10:26.278', '2026-10-29 14:10:26.278');
INSERT INTO `device_alert_record` VALUES (577, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 14:15:26.566', '2026-10-29 14:15:26.567');
INSERT INTO `device_alert_record` VALUES (578, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 14:20:26.779', '2026-10-29 14:20:26.780');
INSERT INTO `device_alert_record` VALUES (579, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 14:25:27.050', '2026-10-29 14:25:27.050');
INSERT INTO `device_alert_record` VALUES (580, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 14:30:27.331', '2026-10-29 14:30:27.332');
INSERT INTO `device_alert_record` VALUES (581, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 14:35:27.607', '2026-10-29 14:35:27.607');
INSERT INTO `device_alert_record` VALUES (582, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 14:40:27.880', '2026-10-29 14:40:27.880');
INSERT INTO `device_alert_record` VALUES (583, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 14:45:28.142', '2026-10-29 14:45:28.142');
INSERT INTO `device_alert_record` VALUES (584, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 14:50:28.401', '2026-10-29 14:50:28.402');
INSERT INTO `device_alert_record` VALUES (585, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 14:55:28.627', '2026-10-29 14:55:28.629');
INSERT INTO `device_alert_record` VALUES (586, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 15:00:28.906', '2026-10-29 15:00:28.906');
INSERT INTO `device_alert_record` VALUES (587, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 15:05:29.170', '2026-10-29 15:05:29.171');
INSERT INTO `device_alert_record` VALUES (588, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 15:10:29.381', '2026-10-29 15:10:29.381');
INSERT INTO `device_alert_record` VALUES (589, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 15:15:29.689', '2026-10-29 15:15:29.690');
INSERT INTO `device_alert_record` VALUES (590, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 15:20:29.946', '2026-10-29 15:20:29.946');
INSERT INTO `device_alert_record` VALUES (591, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 15:25:30.178', '2026-10-29 15:25:30.178');
INSERT INTO `device_alert_record` VALUES (592, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 15:30:30.436', '2026-10-29 15:30:30.436');
INSERT INTO `device_alert_record` VALUES (593, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 15:35:30.764', '2026-10-29 15:35:30.764');
INSERT INTO `device_alert_record` VALUES (594, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 15:40:31.032', '2026-10-29 15:40:31.033');
INSERT INTO `device_alert_record` VALUES (595, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 15:45:31.253', '2026-10-29 15:45:31.253');
INSERT INTO `device_alert_record` VALUES (596, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 15:50:31.510', '2026-10-29 15:50:31.510');
INSERT INTO `device_alert_record` VALUES (597, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 15:55:31.765', '2026-10-29 15:55:31.765');
INSERT INTO `device_alert_record` VALUES (598, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 16:00:32.033', '2026-10-29 16:00:32.033');
INSERT INTO `device_alert_record` VALUES (599, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 16:05:32.328', '2026-10-29 16:05:32.328');
INSERT INTO `device_alert_record` VALUES (600, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 16:10:32.548', '2026-10-29 16:10:32.548');
INSERT INTO `device_alert_record` VALUES (601, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 16:15:32.762', '2026-10-29 16:15:32.763');
INSERT INTO `device_alert_record` VALUES (602, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 16:20:32.983', '2026-10-29 16:20:32.983');
INSERT INTO `device_alert_record` VALUES (603, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 16:25:33.235', '2026-10-29 16:25:33.235');
INSERT INTO `device_alert_record` VALUES (604, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 16:30:33.536', '2026-10-29 16:30:33.536');
INSERT INTO `device_alert_record` VALUES (605, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 16:35:33.809', '2026-10-29 16:35:33.809');
INSERT INTO `device_alert_record` VALUES (606, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 16:40:34.073', '2026-10-29 16:40:34.073');
INSERT INTO `device_alert_record` VALUES (607, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 16:45:34.337', '2026-10-29 16:45:34.337');
INSERT INTO `device_alert_record` VALUES (608, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 16:50:34.675', '2026-10-29 16:50:34.675');
INSERT INTO `device_alert_record` VALUES (609, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 16:55:34.902', '2026-10-29 16:55:34.903');
INSERT INTO `device_alert_record` VALUES (610, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 17:00:35.167', '2026-10-29 17:00:35.168');
INSERT INTO `device_alert_record` VALUES (611, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 17:05:35.423', '2026-10-29 17:05:35.423');
INSERT INTO `device_alert_record` VALUES (612, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 17:10:35.683', '2026-10-29 17:10:35.709');
INSERT INTO `device_alert_record` VALUES (613, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 17:15:35.938', '2026-10-29 17:15:35.939');
INSERT INTO `device_alert_record` VALUES (614, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 17:20:36.203', '2026-10-29 17:20:36.203');
INSERT INTO `device_alert_record` VALUES (615, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 17:25:36.482', '2026-10-29 17:25:36.483');
INSERT INTO `device_alert_record` VALUES (616, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 17:30:36.763', '2026-10-29 17:30:36.763');
INSERT INTO `device_alert_record` VALUES (617, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 17:35:37.054', '2026-10-29 17:35:37.054');
INSERT INTO `device_alert_record` VALUES (618, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 17:40:37.306', '2026-10-29 17:40:37.308');
INSERT INTO `device_alert_record` VALUES (619, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 17:45:37.576', '2026-10-29 17:45:37.576');
INSERT INTO `device_alert_record` VALUES (620, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 17:50:37.839', '2026-10-29 17:50:37.839');
INSERT INTO `device_alert_record` VALUES (621, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 17:55:38.090', '2026-10-29 17:55:38.090');
INSERT INTO `device_alert_record` VALUES (622, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-29 18:00:38.360', '2026-10-29 18:00:38.360');
INSERT INTO `device_alert_record` VALUES (623, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 09:54:31.896', '2026-10-30 09:54:31.897');
INSERT INTO `device_alert_record` VALUES (624, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 09:59:32.091', '2026-10-30 09:59:32.091');
INSERT INTO `device_alert_record` VALUES (625, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 10:04:32.382', '2026-10-30 10:04:32.382');
INSERT INTO `device_alert_record` VALUES (626, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 10:09:32.607', '2026-10-30 10:09:32.607');
INSERT INTO `device_alert_record` VALUES (627, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 10:14:33.003', '2026-10-30 10:14:33.003');
INSERT INTO `device_alert_record` VALUES (628, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 10:19:33.229', '2026-10-30 10:19:33.229');
INSERT INTO `device_alert_record` VALUES (629, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 10:24:33.464', '2026-10-30 10:24:33.464');
INSERT INTO `device_alert_record` VALUES (630, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 10:29:33.696', '2026-10-30 10:29:33.696');
INSERT INTO `device_alert_record` VALUES (631, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 10:34:34.021', '2026-10-30 10:34:34.021');
INSERT INTO `device_alert_record` VALUES (632, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 10:39:34.268', '2026-10-30 10:39:34.268');
INSERT INTO `device_alert_record` VALUES (633, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 10:44:34.534', '2026-10-30 10:44:34.534');
INSERT INTO `device_alert_record` VALUES (634, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 10:49:34.806', '2026-10-30 10:49:34.806');
INSERT INTO `device_alert_record` VALUES (635, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 10:54:35.044', '2026-10-30 10:54:35.044');
INSERT INTO `device_alert_record` VALUES (636, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 10:59:35.342', '2026-10-30 10:59:35.342');
INSERT INTO `device_alert_record` VALUES (637, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 11:04:35.517', '2026-10-30 11:04:35.517');
INSERT INTO `device_alert_record` VALUES (638, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 11:09:35.721', '2026-10-30 11:09:35.721');
INSERT INTO `device_alert_record` VALUES (639, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 11:14:42.283', '2026-10-30 11:14:42.285');
INSERT INTO `device_alert_record` VALUES (640, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 11:19:44.419', '2026-10-30 11:19:44.422');
INSERT INTO `device_alert_record` VALUES (641, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 11:24:44.705', '2026-10-30 11:24:44.706');
INSERT INTO `device_alert_record` VALUES (642, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 11:29:45.004', '2026-10-30 11:29:45.006');
INSERT INTO `device_alert_record` VALUES (643, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 11:34:45.288', '2026-10-30 11:34:45.290');
INSERT INTO `device_alert_record` VALUES (644, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 11:39:45.586', '2026-10-30 11:39:45.588');
INSERT INTO `device_alert_record` VALUES (645, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 11:44:45.862', '2026-10-30 11:44:45.864');
INSERT INTO `device_alert_record` VALUES (646, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 11:49:46.106', '2026-10-30 11:49:46.107');
INSERT INTO `device_alert_record` VALUES (647, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 11:54:46.392', '2026-10-30 11:54:46.392');
INSERT INTO `device_alert_record` VALUES (648, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 11:59:46.641', '2026-10-30 11:59:46.643');
INSERT INTO `device_alert_record` VALUES (649, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 12:05:17.800', '2026-10-30 12:05:17.800');
INSERT INTO `device_alert_record` VALUES (650, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 12:10:18.125', '2026-10-30 12:10:18.125');
INSERT INTO `device_alert_record` VALUES (651, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 12:15:18.434', '2026-10-30 12:15:18.434');
INSERT INTO `device_alert_record` VALUES (652, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 12:20:18.682', '2026-10-30 12:20:18.682');
INSERT INTO `device_alert_record` VALUES (653, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 12:25:18.916', '2026-10-30 12:25:18.916');
INSERT INTO `device_alert_record` VALUES (654, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 12:30:19.175', '2026-10-30 12:30:19.176');
INSERT INTO `device_alert_record` VALUES (655, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 12:35:19.424', '2026-10-30 12:35:19.425');
INSERT INTO `device_alert_record` VALUES (656, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 12:40:19.734', '2026-10-30 12:40:19.735');
INSERT INTO `device_alert_record` VALUES (657, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 12:45:20.016', '2026-10-30 12:45:20.016');
INSERT INTO `device_alert_record` VALUES (658, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 12:50:20.280', '2026-10-30 12:50:20.280');
INSERT INTO `device_alert_record` VALUES (659, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 12:55:20.568', '2026-10-30 12:55:20.568');
INSERT INTO `device_alert_record` VALUES (660, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 13:00:20.817', '2026-10-30 13:00:20.817');
INSERT INTO `device_alert_record` VALUES (661, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 13:05:21.041', '2026-10-30 13:05:21.041');
INSERT INTO `device_alert_record` VALUES (662, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 13:10:21.318', '2026-10-30 13:10:21.318');
INSERT INTO `device_alert_record` VALUES (663, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 13:15:21.579', '2026-10-30 13:15:21.580');
INSERT INTO `device_alert_record` VALUES (664, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 13:20:21.871', '2026-10-30 13:20:21.871');
INSERT INTO `device_alert_record` VALUES (665, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 13:25:22.184', '2026-10-30 13:25:22.184');
INSERT INTO `device_alert_record` VALUES (666, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 13:30:22.419', '2026-10-30 13:30:22.419');
INSERT INTO `device_alert_record` VALUES (667, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 13:35:22.682', '2026-10-30 13:35:22.682');
INSERT INTO `device_alert_record` VALUES (668, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 13:40:22.929', '2026-10-30 13:40:22.929');
INSERT INTO `device_alert_record` VALUES (669, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 13:45:23.180', '2026-10-30 13:45:23.180');
INSERT INTO `device_alert_record` VALUES (670, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 13:50:23.390', '2026-10-30 13:50:23.390');
INSERT INTO `device_alert_record` VALUES (671, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 13:55:23.645', '2026-10-30 13:55:23.645');
INSERT INTO `device_alert_record` VALUES (672, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 14:00:23.909', '2026-10-30 14:00:23.909');
INSERT INTO `device_alert_record` VALUES (673, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 14:05:24.147', '2026-10-30 14:05:24.147');
INSERT INTO `device_alert_record` VALUES (674, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 14:10:24.452', '2026-10-30 14:10:24.452');
INSERT INTO `device_alert_record` VALUES (675, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 14:15:24.695', '2026-10-30 14:15:24.695');
INSERT INTO `device_alert_record` VALUES (676, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 14:20:24.970', '2026-10-30 14:20:24.970');
INSERT INTO `device_alert_record` VALUES (677, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 14:25:25.269', '2026-10-30 14:25:25.269');
INSERT INTO `device_alert_record` VALUES (678, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 14:30:25.487', '2026-10-30 14:30:25.488');
INSERT INTO `device_alert_record` VALUES (679, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 14:35:25.787', '2026-10-30 14:35:25.787');
INSERT INTO `device_alert_record` VALUES (680, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 14:40:26.062', '2026-10-30 14:40:26.063');
INSERT INTO `device_alert_record` VALUES (681, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 14:45:26.301', '2026-10-30 14:45:26.302');
INSERT INTO `device_alert_record` VALUES (682, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 14:50:26.581', '2026-10-30 14:50:26.583');
INSERT INTO `device_alert_record` VALUES (683, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 14:55:26.823', '2026-10-30 14:55:26.823');
INSERT INTO `device_alert_record` VALUES (684, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 15:00:27.086', '2026-10-30 15:00:27.088');
INSERT INTO `device_alert_record` VALUES (685, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 15:05:27.329', '2026-10-30 15:05:27.329');
INSERT INTO `device_alert_record` VALUES (686, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 15:10:27.583', '2026-10-30 15:10:27.583');
INSERT INTO `device_alert_record` VALUES (687, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 15:15:27.824', '2026-10-30 15:15:27.824');
INSERT INTO `device_alert_record` VALUES (688, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-10-30 15:20:28.034', '2026-10-30 15:20:28.034');
INSERT INTO `device_alert_record` VALUES (689, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 14:37:31.366', '2026-11-01 14:37:31.372');
INSERT INTO `device_alert_record` VALUES (690, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 14:42:31.643', '2026-11-01 14:42:31.644');
INSERT INTO `device_alert_record` VALUES (691, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 14:47:31.954', '2026-11-01 14:47:31.955');
INSERT INTO `device_alert_record` VALUES (692, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 14:52:32.222', '2026-11-01 14:52:32.223');
INSERT INTO `device_alert_record` VALUES (693, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 14:57:32.534', '2026-11-01 14:57:32.537');
INSERT INTO `device_alert_record` VALUES (694, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 15:02:32.802', '2026-11-01 15:02:32.803');
INSERT INTO `device_alert_record` VALUES (695, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 15:07:33.046', '2026-11-01 15:07:33.046');
INSERT INTO `device_alert_record` VALUES (696, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 15:12:33.309', '2026-11-01 15:12:33.309');
INSERT INTO `device_alert_record` VALUES (697, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 15:17:33.563', '2026-11-01 15:17:33.569');
INSERT INTO `device_alert_record` VALUES (698, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 15:22:33.797', '2026-11-01 15:22:33.798');
INSERT INTO `device_alert_record` VALUES (699, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 15:27:34.082', '2026-11-01 15:27:34.085');
INSERT INTO `device_alert_record` VALUES (700, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 15:32:34.417', '2026-11-01 15:32:34.421');
INSERT INTO `device_alert_record` VALUES (701, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 15:37:34.672', '2026-11-01 15:37:34.673');
INSERT INTO `device_alert_record` VALUES (702, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 15:42:35.015', '2026-11-01 15:42:35.015');
INSERT INTO `device_alert_record` VALUES (703, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 15:47:35.327', '2026-11-01 15:47:35.328');
INSERT INTO `device_alert_record` VALUES (704, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 15:52:35.598', '2026-11-01 15:52:35.600');
INSERT INTO `device_alert_record` VALUES (705, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 15:57:35.861', '2026-11-01 15:57:35.861');
INSERT INTO `device_alert_record` VALUES (706, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 16:02:36.156', '2026-11-01 16:02:36.161');
INSERT INTO `device_alert_record` VALUES (707, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 16:07:36.432', '2026-11-01 16:07:36.435');
INSERT INTO `device_alert_record` VALUES (708, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 16:12:36.666', '2026-11-01 16:12:36.672');
INSERT INTO `device_alert_record` VALUES (709, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 16:17:36.954', '2026-11-01 16:17:36.955');
INSERT INTO `device_alert_record` VALUES (710, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 16:22:37.228', '2026-11-01 16:22:37.228');
INSERT INTO `device_alert_record` VALUES (711, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 16:28:25.504', '2026-11-01 16:28:25.506');
INSERT INTO `device_alert_record` VALUES (712, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 16:33:25.814', '2026-11-01 16:33:25.815');
INSERT INTO `device_alert_record` VALUES (713, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 16:38:26.076', '2026-11-01 16:38:26.077');
INSERT INTO `device_alert_record` VALUES (714, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 16:43:26.388', '2026-11-01 16:43:26.388');
INSERT INTO `device_alert_record` VALUES (715, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 16:48:26.635', '2026-11-01 16:48:26.636');
INSERT INTO `device_alert_record` VALUES (716, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 16:53:26.855', '2026-11-01 16:53:26.855');
INSERT INTO `device_alert_record` VALUES (717, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 16:58:29.791', '2026-11-01 16:58:29.794');
INSERT INTO `device_alert_record` VALUES (718, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 17:03:30.059', '2026-11-01 17:03:30.059');
INSERT INTO `device_alert_record` VALUES (719, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 17:08:30.330', '2026-11-01 17:08:30.331');
INSERT INTO `device_alert_record` VALUES (720, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 17:13:30.629', '2026-11-01 17:13:30.632');
INSERT INTO `device_alert_record` VALUES (721, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 17:19:20.948', '2026-11-01 17:19:20.951');
INSERT INTO `device_alert_record` VALUES (722, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 17:24:21.254', '2026-11-01 17:24:21.261');
INSERT INTO `device_alert_record` VALUES (723, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 17:29:21.633', '2026-11-01 17:29:21.653');
INSERT INTO `device_alert_record` VALUES (724, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 17:34:21.887', '2026-11-01 17:34:21.887');
INSERT INTO `device_alert_record` VALUES (725, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 17:39:22.216', '2026-11-01 17:39:22.220');
INSERT INTO `device_alert_record` VALUES (726, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 17:44:22.511', '2026-11-01 17:44:22.515');
INSERT INTO `device_alert_record` VALUES (727, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 17:49:22.770', '2026-11-01 17:49:22.774');
INSERT INTO `device_alert_record` VALUES (728, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 17:55:03.502', '2026-11-01 17:55:03.503');
INSERT INTO `device_alert_record` VALUES (729, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 18:01:06.812', '2026-11-01 18:01:06.814');
INSERT INTO `device_alert_record` VALUES (730, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 18:06:07.116', '2026-11-01 18:06:07.122');
INSERT INTO `device_alert_record` VALUES (731, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 18:11:41.810', '2026-11-01 18:11:41.827');
INSERT INTO `device_alert_record` VALUES (732, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 18:17:22.716', '2026-11-01 18:17:22.724');
INSERT INTO `device_alert_record` VALUES (733, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 18:22:22.923', '2026-11-01 18:22:22.926');
INSERT INTO `device_alert_record` VALUES (734, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 18:27:23.225', '2026-11-01 18:27:23.228');
INSERT INTO `device_alert_record` VALUES (735, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 18:33:10.921', '2026-11-01 18:33:10.930');
INSERT INTO `device_alert_record` VALUES (736, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 18:38:38.510', '2026-11-01 18:38:38.513');
INSERT INTO `device_alert_record` VALUES (737, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 18:43:38.786', '2026-11-01 18:43:38.789');
INSERT INTO `device_alert_record` VALUES (738, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 18:48:39.035', '2026-11-01 18:48:39.036');
INSERT INTO `device_alert_record` VALUES (739, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 18:53:39.325', '2026-11-01 18:53:39.326');
INSERT INTO `device_alert_record` VALUES (740, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-01 18:58:39.617', '2026-11-01 18:58:39.618');
INSERT INTO `device_alert_record` VALUES (741, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-02 10:22:22.471', '2026-11-02 10:22:22.475');
INSERT INTO `device_alert_record` VALUES (742, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-02 10:27:22.683', '2026-11-02 10:27:22.683');
INSERT INTO `device_alert_record` VALUES (743, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-02 10:32:22.967', '2026-11-02 10:32:22.967');
INSERT INTO `device_alert_record` VALUES (744, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-02 10:37:23.202', '2026-11-02 10:37:23.203');
INSERT INTO `device_alert_record` VALUES (745, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-02 10:42:23.477', '2026-11-02 10:42:23.477');
INSERT INTO `device_alert_record` VALUES (746, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-02 10:47:23.736', '2026-11-02 10:47:23.736');
INSERT INTO `device_alert_record` VALUES (747, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-02 10:52:24.011', '2026-11-02 10:52:24.012');
INSERT INTO `device_alert_record` VALUES (748, 'B4BFE90CDBA1', 'temp', 3, 'threshold', '数值 35.5 超过上限 30.0', 35.5, 30, 0, NULL, NULL, '2026-11-02 10:57:24.266', '2026-11-02 10:57:24.268');

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
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备绑定关系表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_binding
-- ----------------------------
INSERT INTO `device_binding` VALUES (1, 'MAC123456789', DEFAULT, 6, 0, '2026-10-27 10:38:49', '2026-10-27 10:42:01', '2026-10-27 10:38:49', '2026-10-27 10:38:49');
INSERT INTO `device_binding` VALUES (2, 'MAC123456789', DEFAULT, 7, 1, '2026-10-27 10:42:35', NULL, '2026-10-27 10:42:35', '2026-10-27 10:42:35');
INSERT INTO `device_binding` VALUES (3, 'AABBCCDDEE11', DEFAULT, 7, 1, '2026-10-27 10:51:11', NULL, '2026-10-27 10:51:11', '2026-10-27 11:15:27');
INSERT INTO `device_binding` VALUES (4, 'AABBCCDDEEC7', DEFAULT, 6, 1, '2026-10-27 11:42:37', NULL, '2026-10-27 11:42:37', '2026-10-27 11:42:37');
INSERT INTO `device_binding` VALUES (9, 'B4BFE90CDBA1', DEFAULT, 10, 0, '2026-11-02 10:17:58', '2026-11-02 10:58:32', '2026-11-02 10:17:58', '2026-11-02 10:58:31');
INSERT INTO `device_binding` VALUES (10, 'B4BFE90CDBA1', DEFAULT, 9, 1, '2026-11-02 11:02:47', NULL, '2026-11-02 11:02:47', '2026-11-02 11:02:47');

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
) ENGINE = InnoDB AUTO_INCREMENT = 201 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备下行控制指令表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_command
-- ----------------------------
INSERT INTO `device_command` VALUES (184, '121dcdc3c6bf43e39fa7b6a3a5ec810f', 'B4BFE90CDBA1', 'off', 'led', 3, '{\"state\": 0}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:08:24.269', '2026-11-02 11:07:54.649', '2026-11-02 11:07:54.987', '2026-11-02 11:07:54.269', '2026-11-02 11:07:54.991');
INSERT INTO `device_command` VALUES (185, '3e96e2a9870c477585f29b477da5cb67', 'B4BFE90CDBA1', 'off', 'led', 1, '{\"state\": 1}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:08:30.533', '2026-11-02 11:08:00.539', '2026-11-02 11:08:00.860', '2026-11-02 11:08:00.533', '2026-11-02 11:08:00.861');
INSERT INTO `device_command` VALUES (186, 'd28776fe66bb435a99f499bd1701f953', 'B4BFE90CDBA1', 'on', 'led', 1, '{\"state\": 1}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:08:44.021', '2026-11-02 11:08:14.026', '2026-11-02 11:08:14.341', '2026-11-02 11:08:14.021', '2026-11-02 11:08:14.342');
INSERT INTO `device_command` VALUES (187, '5239085b6e9d41098dadc9c703f390c5', 'B4BFE90CDBA1', 'on', 'led', 2, '{\"state\": 1}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:08:52.531', '2026-11-02 11:08:22.535', '2026-11-02 11:08:22.861', '2026-11-02 11:08:22.531', '2026-11-02 11:08:22.866');
INSERT INTO `device_command` VALUES (188, 'd297c1e58199404b942dde9a4b7c1cbe', 'B4BFE90CDBA1', 'on', 'led', 2, '{\"state\": 0}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:12:28.384', '2026-11-02 11:11:58.737', '2026-11-02 11:11:59.062', '2026-11-02 11:11:58.384', '2026-11-02 11:11:59.065');
INSERT INTO `device_command` VALUES (189, '9aaef21d0c024c38a6e8a91c7bc54548', 'B4BFE90CDBA1', 'on', 'led', 3, '{\"state\": 0}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:12:44.934', '2026-11-02 11:12:14.966', '2026-11-02 11:12:15.267', '2026-11-02 11:12:14.934', '2026-11-02 11:12:15.269');
INSERT INTO `device_command` VALUES (190, 'a990d54e07014b5db5c8eed6a68f9439', 'B4BFE90CDBA1', 'on', 'led', 3, '{\"state\": 1}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:12:51.852', '2026-11-02 11:12:21.862', '2026-11-02 11:12:22.192', '2026-11-02 11:12:21.852', '2026-11-02 11:12:22.196');
INSERT INTO `device_command` VALUES (191, 'f62476173c4a481f95ddc552bfae0a0c', 'B4BFE90CDBA1', 'on', 'led', 3, '{\"state\": 1}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:12:52.680', '2026-11-02 11:12:22.687', '2026-11-02 11:12:23.015', '2026-11-02 11:12:22.680', '2026-11-02 11:12:23.020');
INSERT INTO `device_command` VALUES (192, '57bf999fd16841589c5d4fbe1626367a', 'B4BFE90CDBA1', 'off', 'led', 3, '{\"state\": 0}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:13:05.395', '2026-11-02 11:12:35.404', '2026-11-02 11:12:35.728', '2026-11-02 11:12:35.395', '2026-11-02 11:12:35.730');
INSERT INTO `device_command` VALUES (193, '14b48927089745a7b4e2d171691dd2ba', 'B4BFE90CDBA1', 'off', 'led', 3, '{\"state\": 1}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:15:12.471', '2026-11-02 11:14:42.479', '2026-11-02 11:14:42.824', '2026-11-02 11:14:42.471', '2026-11-02 11:14:42.824');
INSERT INTO `device_command` VALUES (194, 'b248db71d8384dd29f4473b8a7607dab', 'B4BFE90CDBA1', 'on', 'led', 3, '{\"state\": 1}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:15:40.529', '2026-11-02 11:15:10.896', '2026-11-02 11:15:11.212', '2026-11-02 11:15:10.529', '2026-11-02 11:15:11.215');
INSERT INTO `device_command` VALUES (195, '31d14e3de82044949f136d2d33f40b72', 'B4BFE90CDBA1', 'off', 'led', 3, '{\"state\": 0}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:15:56.318', '2026-11-02 11:15:26.326', '2026-11-02 11:15:26.658', '2026-11-02 11:15:26.318', '2026-11-02 11:15:26.660');
INSERT INTO `device_command` VALUES (196, '4c140e80efed4c8c953c572905cdf66b', 'B4BFE90CDBA1', 'off', 'led', 3, '{\"state\": 0}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"led\"}', 'user_9', 'WEB', '2026-11-02 11:15:57.388', '2026-11-02 11:15:27.395', '2026-11-02 11:15:27.720', '2026-11-02 11:15:27.388', '2026-11-02 11:15:27.722');
INSERT INTO `device_command` VALUES (197, '08b14236dedf425e866921382b845021', 'B4BFE90CDBA1', 'on', 'mos', 3, '{\"state\": 1}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"mos\"}', 'user_9', 'WEB', '2026-11-02 11:18:38.005', '2026-11-02 11:18:08.011', '2026-11-02 11:18:08.342', '2026-11-02 11:18:08.005', '2026-11-02 11:18:08.347');
INSERT INTO `device_command` VALUES (198, '389667806c3f4f19afb3fb0ac795b4d8', 'B4BFE90CDBA1', 'on', 'mos', 3, '{\"state\": 1}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"mos\"}', 'user_9', 'WEB', '2026-11-02 11:32:15.764', '2026-11-02 11:31:46.138', '2026-11-02 11:31:46.463', '2026-11-02 11:31:45.764', '2026-11-02 11:31:46.466');
INSERT INTO `device_command` VALUES (199, 'bb82e55439b9426c9f8aecabd64bfe3e', 'B4BFE90CDBA1', 'off', 'mos', 3, '{\"state\": 0}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"mos\"}', 'user_9', 'WEB', '2026-11-02 11:32:25.099', '2026-11-02 11:31:55.110', '2026-11-02 11:31:55.439', '2026-11-02 11:31:55.099', '2026-11-02 11:31:55.443');
INSERT INTO `device_command` VALUES (200, 'be964aca4cb44f84ab2b73df80cefdf5', 'B4BFE90CDBA1', 'on', 'mos', 4, '{\"state\": 1}', 1, 0, 2, 1, 3, NULL, '{\"target\": \"mos\"}', 'user_9', 'WEB', '2026-11-02 11:32:42.029', '2026-11-02 11:32:12.039', '2026-11-02 11:32:12.367', '2026-11-02 11:32:12.029', '2026-11-02 11:32:12.370');

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
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备事件记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_event_record
-- ----------------------------
INSERT INTO `device_event_record` VALUES (28, 'B4BFE90CDBA1', 'error', NULL, 'ERR_SENSOR_001', '地址为2的湿度传感器通信超时', NULL, NULL, NULL, NULL, '{\"code\": \"ERR_SENSOR_001\", \"type\": \"error\", \"message\": \"地址为2的湿度传感器通信超时\"}', '2026-11-02 11:07:57.381', '2026-11-02 11:07:57.393');

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
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '固件版本表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_firmware
-- ----------------------------
INSERT INTO `device_firmware` VALUES (22, '1.0.42', 'WOMI_DEVICE_1', NULL, 'http://localhost:8000/firmware/firmware_1.0.42_20261101174922.bin', 'firmware_1.0.4_20261008210642.bin', 'D:\\data\\firmware\\firmware_1.0.42_20261101174922.bin', 'b02193f879a8b03013eec4b223d13e40', 'e1463d554118ee97c8e7b8fc479a5bad61e34658b588d3f291111954acdd9c78', 12031776, 'system', '2026-11-01 17:49:23.046', 1, '2026-11-01 17:49:23.050', '2026-11-01 17:49:23.050');
INSERT INTO `device_firmware` VALUES (23, '1.0.43', '桌宠', NULL, 'http://localhost:8000/firmware/firmware_1.0.43_20261102105632.bin', 'firmware_1.0.1_20261008202740.bin', 'D:\\data\\firmware\\firmware_1.0.43_20261102105632.bin', '3656f8585655a4c9f5958977807fa046', '4f405702820268aa6879c5fe48a7629b2d5eb2cc9b044bf1141af6c2279a801e', 1099072, 'system', '2026-11-02 10:56:32.797', 1, '2026-11-02 10:56:32.799', '2026-11-02 10:56:32.799');

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
) ENGINE = InnoDB AUTO_INCREMENT = 5436 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '心跳记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_heartbeat_record
-- ----------------------------
INSERT INTO `device_heartbeat_record` VALUES (5369, 'B4BFE90CDBA1', 30, '2026-11-02 11:06:50.796', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793588810789, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 30, \"rssi\": -65}}', '2026-11-02 11:06:50.796');
INSERT INTO `device_heartbeat_record` VALUES (5370, 'B4BFE90CDBA1', 30, '2026-11-02 11:07:12.404', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793588832373, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 30, \"rssi\": -65, \"free_heap\": 149906, \"voltage\": 3.4, \"core_temp\": 46.5}}', '2026-11-02 11:07:12.404');
INSERT INTO `device_heartbeat_record` VALUES (5371, 'B4BFE90CDBA1', 60, '2026-11-02 11:07:42.390', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793588862380, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 60, \"rssi\": -58, \"free_heap\": 176325, \"voltage\": 3.38, \"core_temp\": 46.1}}', '2026-11-02 11:07:42.390');
INSERT INTO `device_heartbeat_record` VALUES (5372, 'B4BFE90CDBA1', 90, '2026-11-02 11:08:12.403', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793588892381, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 90, \"rssi\": -65, \"free_heap\": 162593, \"voltage\": 3.28, \"core_temp\": 48.6}}', '2026-11-02 11:08:12.404');
INSERT INTO `device_heartbeat_record` VALUES (5373, 'B4BFE90CDBA1', 120, '2026-11-02 11:08:42.392', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793588922383, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 120, \"rssi\": -67, \"free_heap\": 170411, \"voltage\": 3.23, \"core_temp\": 47.3}}', '2026-11-02 11:08:42.392');
INSERT INTO `device_heartbeat_record` VALUES (5374, 'B4BFE90CDBA1', 150, '2026-11-02 11:09:12.408', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793588952397, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 150, \"rssi\": -71, \"free_heap\": 128804, \"voltage\": 3.36, \"core_temp\": 46.6}}', '2026-11-02 11:09:12.408');
INSERT INTO `device_heartbeat_record` VALUES (5375, 'B4BFE90CDBA1', 180, '2026-11-02 11:09:42.412', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793588982402, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 180, \"rssi\": -73, \"free_heap\": 151874, \"voltage\": 3.22, \"core_temp\": 47.7}}', '2026-11-02 11:09:42.412');
INSERT INTO `device_heartbeat_record` VALUES (5376, 'B4BFE90CDBA1', 210, '2026-11-02 11:10:12.424', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589012416, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 210, \"rssi\": -55, \"free_heap\": 148878, \"voltage\": 3.38, \"core_temp\": 50.0}}', '2026-11-02 11:10:12.424');
INSERT INTO `device_heartbeat_record` VALUES (5377, 'B4BFE90CDBA1', 240, '2026-11-02 11:10:42.440', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589042425, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 240, \"rssi\": -58, \"free_heap\": 169638, \"voltage\": 3.29, \"core_temp\": 51.0}}', '2026-11-02 11:10:42.442');
INSERT INTO `device_heartbeat_record` VALUES (5378, 'B4BFE90CDBA1', 300, '2026-11-02 11:11:42.450', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589102434, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 300, \"rssi\": -66, \"free_heap\": 156941, \"voltage\": 3.24, \"core_temp\": 45.1}}', '2026-11-02 11:11:42.453');
INSERT INTO `device_heartbeat_record` VALUES (5379, 'B4BFE90CDBA1', 330, '2026-11-02 11:12:12.458', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589132438, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 330, \"rssi\": -70, \"free_heap\": 175903, \"voltage\": 3.25, \"core_temp\": 50.6}}', '2026-11-02 11:12:12.459');
INSERT INTO `device_heartbeat_record` VALUES (5380, 'B4BFE90CDBA1', 360, '2026-11-02 11:12:42.463', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589162453, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 360, \"rssi\": -62, \"free_heap\": 133351, \"voltage\": 3.28, \"core_temp\": 51.9}}', '2026-11-02 11:12:42.463');
INSERT INTO `device_heartbeat_record` VALUES (5381, 'B4BFE90CDBA1', 390, '2026-11-02 11:13:12.480', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589192468, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 390, \"rssi\": -60, \"free_heap\": 127293, \"voltage\": 3.29, \"core_temp\": 53.3}}', '2026-11-02 11:13:12.480');
INSERT INTO `device_heartbeat_record` VALUES (5382, 'B4BFE90CDBA1', 420, '2026-11-02 11:13:42.487', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589222475, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 420, \"rssi\": -74, \"free_heap\": 155074, \"voltage\": 3.24, \"core_temp\": 49.6}}', '2026-11-02 11:13:42.487');
INSERT INTO `device_heartbeat_record` VALUES (5383, 'B4BFE90CDBA1', 450, '2026-11-02 11:14:12.505', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589252488, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 450, \"rssi\": -75, \"free_heap\": 173885, \"voltage\": 3.28, \"core_temp\": 49.7}}', '2026-11-02 11:14:12.505');
INSERT INTO `device_heartbeat_record` VALUES (5384, 'B4BFE90CDBA1', 480, '2026-11-02 11:14:42.790', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589282503, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 480, \"rssi\": -73, \"free_heap\": 138849, \"voltage\": 3.24, \"core_temp\": 54.1}}', '2026-11-02 11:14:42.790');
INSERT INTO `device_heartbeat_record` VALUES (5385, 'B4BFE90CDBA1', 510, '2026-11-02 11:15:12.530', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589312509, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 510, \"rssi\": -57, \"free_heap\": 143139, \"voltage\": 3.24, \"core_temp\": 49.4}}', '2026-11-02 11:15:12.531');
INSERT INTO `device_heartbeat_record` VALUES (5386, 'B4BFE90CDBA1', 540, '2026-11-02 11:15:42.526', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589342510, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 540, \"rssi\": -55, \"free_heap\": 126793, \"voltage\": 3.33, \"core_temp\": 51.0}}', '2026-11-02 11:15:42.527');
INSERT INTO `device_heartbeat_record` VALUES (5387, 'B4BFE90CDBA1', 570, '2026-11-02 11:16:12.534', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589372517, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 570, \"rssi\": -70, \"free_heap\": 124593, \"voltage\": 3.24, \"core_temp\": 47.9}}', '2026-11-02 11:16:12.535');
INSERT INTO `device_heartbeat_record` VALUES (5388, 'B4BFE90CDBA1', 600, '2026-11-02 11:16:42.544', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589402530, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 600, \"rssi\": -72, \"free_heap\": 169911, \"voltage\": 3.28, \"core_temp\": 45.2}}', '2026-11-02 11:16:42.544');
INSERT INTO `device_heartbeat_record` VALUES (5389, 'B4BFE90CDBA1', 630, '2026-11-02 11:17:12.555', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589432540, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 630, \"rssi\": -55, \"free_heap\": 141820, \"voltage\": 3.33, \"core_temp\": 54.5}}', '2026-11-02 11:17:12.555');
INSERT INTO `device_heartbeat_record` VALUES (5390, 'B4BFE90CDBA1', 660, '2026-11-02 11:17:42.567', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589462554, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 660, \"rssi\": -74, \"free_heap\": 121746, \"voltage\": 3.31, \"core_temp\": 52.8}}', '2026-11-02 11:17:42.567');
INSERT INTO `device_heartbeat_record` VALUES (5391, 'B4BFE90CDBA1', 690, '2026-11-02 11:18:12.571', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589492563, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 690, \"rssi\": -60, \"free_heap\": 128710, \"voltage\": 3.34, \"core_temp\": 52.4}}', '2026-11-02 11:18:12.571');
INSERT INTO `device_heartbeat_record` VALUES (5392, 'B4BFE90CDBA1', 720, '2026-11-02 11:18:42.584', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589522573, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 720, \"rssi\": -74, \"free_heap\": 126907, \"voltage\": 3.32, \"core_temp\": 50.8}}', '2026-11-02 11:18:42.585');
INSERT INTO `device_heartbeat_record` VALUES (5393, 'B4BFE90CDBA1', 750, '2026-11-02 11:19:12.587', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589552577, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 750, \"rssi\": -68, \"free_heap\": 166065, \"voltage\": 3.33, \"core_temp\": 47.2}}', '2026-11-02 11:19:12.587');
INSERT INTO `device_heartbeat_record` VALUES (5394, 'B4BFE90CDBA1', 780, '2026-11-02 11:19:42.605', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589582592, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 780, \"rssi\": -66, \"free_heap\": 135873, \"voltage\": 3.39, \"core_temp\": 45.0}}', '2026-11-02 11:19:42.605');
INSERT INTO `device_heartbeat_record` VALUES (5395, 'B4BFE90CDBA1', 810, '2026-11-02 11:20:12.616', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589612607, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 810, \"rssi\": -64, \"free_heap\": 178592, \"voltage\": 3.32, \"core_temp\": 52.0}}', '2026-11-02 11:20:12.616');
INSERT INTO `device_heartbeat_record` VALUES (5396, 'B4BFE90CDBA1', 840, '2026-11-02 11:20:42.630', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589642617, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 840, \"rssi\": -65, \"free_heap\": 159469, \"voltage\": 3.27, \"core_temp\": 47.5}}', '2026-11-02 11:20:42.630');
INSERT INTO `device_heartbeat_record` VALUES (5397, 'B4BFE90CDBA1', 870, '2026-11-02 11:21:12.650', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589672633, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 870, \"rssi\": -57, \"free_heap\": 155258, \"voltage\": 3.24, \"core_temp\": 49.5}}', '2026-11-02 11:21:12.650');
INSERT INTO `device_heartbeat_record` VALUES (5398, 'B4BFE90CDBA1', 900, '2026-11-02 11:21:42.651', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589702638, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 900, \"rssi\": -68, \"free_heap\": 146142, \"voltage\": 3.37, \"core_temp\": 49.0}}', '2026-11-02 11:21:42.651');
INSERT INTO `device_heartbeat_record` VALUES (5399, 'B4BFE90CDBA1', 930, '2026-11-02 11:22:12.669', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589732655, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 930, \"rssi\": -64, \"free_heap\": 153205, \"voltage\": 3.38, \"core_temp\": 48.6}}', '2026-11-02 11:22:12.669');
INSERT INTO `device_heartbeat_record` VALUES (5400, 'B4BFE90CDBA1', 960, '2026-11-02 11:22:42.677', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589762665, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 960, \"rssi\": -61, \"free_heap\": 157961, \"voltage\": 3.3, \"core_temp\": 51.7}}', '2026-11-02 11:22:42.677');
INSERT INTO `device_heartbeat_record` VALUES (5401, 'B4BFE90CDBA1', 990, '2026-11-02 11:23:12.688', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589792675, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 990, \"rssi\": -55, \"free_heap\": 175592, \"voltage\": 3.38, \"core_temp\": 53.6}}', '2026-11-02 11:23:12.688');
INSERT INTO `device_heartbeat_record` VALUES (5402, 'B4BFE90CDBA1', 1020, '2026-11-02 11:23:42.688', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589822678, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1020, \"rssi\": -65, \"free_heap\": 125942, \"voltage\": 3.21, \"core_temp\": 50.0}}', '2026-11-02 11:23:42.688');
INSERT INTO `device_heartbeat_record` VALUES (5403, 'B4BFE90CDBA1', 1050, '2026-11-02 11:24:12.704', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589852693, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1050, \"rssi\": -73, \"free_heap\": 158988, \"voltage\": 3.21, \"core_temp\": 54.1}}', '2026-11-02 11:24:12.704');
INSERT INTO `device_heartbeat_record` VALUES (5404, 'B4BFE90CDBA1', 1080, '2026-11-02 11:24:42.713', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589882704, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1080, \"rssi\": -66, \"free_heap\": 148045, \"voltage\": 3.21, \"core_temp\": 49.9}}', '2026-11-02 11:24:42.713');
INSERT INTO `device_heartbeat_record` VALUES (5405, 'B4BFE90CDBA1', 1110, '2026-11-02 11:25:12.723', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589912712, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1110, \"rssi\": -68, \"free_heap\": 178511, \"voltage\": 3.33, \"core_temp\": 50.0}}', '2026-11-02 11:25:12.723');
INSERT INTO `device_heartbeat_record` VALUES (5406, 'B4BFE90CDBA1', 1140, '2026-11-02 11:25:42.728', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589942719, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1140, \"rssi\": -55, \"free_heap\": 146087, \"voltage\": 3.3, \"core_temp\": 48.9}}', '2026-11-02 11:25:42.729');
INSERT INTO `device_heartbeat_record` VALUES (5407, 'B4BFE90CDBA1', 1170, '2026-11-02 11:26:12.738', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793589972729, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1170, \"rssi\": -58, \"free_heap\": 154786, \"voltage\": 3.32, \"core_temp\": 46.4}}', '2026-11-02 11:26:12.738');
INSERT INTO `device_heartbeat_record` VALUES (5408, 'B4BFE90CDBA1', 1200, '2026-11-02 11:26:42.753', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590002743, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1200, \"rssi\": -55, \"free_heap\": 133669, \"voltage\": 3.26, \"core_temp\": 52.8}}', '2026-11-02 11:26:42.753');
INSERT INTO `device_heartbeat_record` VALUES (5409, 'B4BFE90CDBA1', 1230, '2026-11-02 11:27:12.766', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590032756, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1230, \"rssi\": -66, \"free_heap\": 168361, \"voltage\": 3.37, \"core_temp\": 49.6}}', '2026-11-02 11:27:12.766');
INSERT INTO `device_heartbeat_record` VALUES (5410, 'B4BFE90CDBA1', 1260, '2026-11-02 11:27:42.784', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590062771, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1260, \"rssi\": -64, \"free_heap\": 139628, \"voltage\": 3.4, \"core_temp\": 45.2}}', '2026-11-02 11:27:42.784');
INSERT INTO `device_heartbeat_record` VALUES (5411, 'B4BFE90CDBA1', 1290, '2026-11-02 11:28:12.796', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590092783, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1290, \"rssi\": -67, \"free_heap\": 121475, \"voltage\": 3.32, \"core_temp\": 50.4}}', '2026-11-02 11:28:12.796');
INSERT INTO `device_heartbeat_record` VALUES (5412, 'B4BFE90CDBA1', 1320, '2026-11-02 11:28:42.799', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590122790, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1320, \"rssi\": -61, \"free_heap\": 128563, \"voltage\": 3.22, \"core_temp\": 46.7}}', '2026-11-02 11:28:42.800');
INSERT INTO `device_heartbeat_record` VALUES (5413, 'B4BFE90CDBA1', 1350, '2026-11-02 11:29:12.811', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590152797, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1350, \"rssi\": -67, \"free_heap\": 142274, \"voltage\": 3.39, \"core_temp\": 50.6}}', '2026-11-02 11:29:12.812');
INSERT INTO `device_heartbeat_record` VALUES (5414, 'B4BFE90CDBA1', 1380, '2026-11-02 11:29:42.817', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590182805, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1380, \"rssi\": -75, \"free_heap\": 138103, \"voltage\": 3.27, \"core_temp\": 51.3}}', '2026-11-02 11:29:42.817');
INSERT INTO `device_heartbeat_record` VALUES (5415, 'B4BFE90CDBA1', 1410, '2026-11-02 11:30:12.821', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590212808, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1410, \"rssi\": -57, \"free_heap\": 145595, \"voltage\": 3.28, \"core_temp\": 46.3}}', '2026-11-02 11:30:12.821');
INSERT INTO `device_heartbeat_record` VALUES (5416, 'B4BFE90CDBA1', 1440, '2026-11-02 11:30:42.831', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590242822, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1440, \"rssi\": -62, \"free_heap\": 146683, \"voltage\": 3.32, \"core_temp\": 51.2}}', '2026-11-02 11:30:42.831');
INSERT INTO `device_heartbeat_record` VALUES (5417, 'B4BFE90CDBA1', 1470, '2026-11-02 11:31:12.843', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590272837, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1470, \"rssi\": -63, \"free_heap\": 125452, \"voltage\": 3.22, \"core_temp\": 46.6}}', '2026-11-02 11:31:12.843');
INSERT INTO `device_heartbeat_record` VALUES (5418, 'B4BFE90CDBA1', 1500, '2026-11-02 11:31:42.894', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590302848, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1500, \"rssi\": -68, \"free_heap\": 122963, \"voltage\": 3.27, \"core_temp\": 51.7}}', '2026-11-02 11:31:42.895');
INSERT INTO `device_heartbeat_record` VALUES (5419, 'B4BFE90CDBA1', 1530, '2026-11-02 11:32:12.874', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590332855, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1530, \"rssi\": -75, \"free_heap\": 147649, \"voltage\": 3.26, \"core_temp\": 50.2}}', '2026-11-02 11:32:12.875');
INSERT INTO `device_heartbeat_record` VALUES (5420, 'B4BFE90CDBA1', 1560, '2026-11-02 11:32:42.886', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590362867, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1560, \"rssi\": -70, \"free_heap\": 132353, \"voltage\": 3.34, \"core_temp\": 51.2}}', '2026-11-02 11:32:42.887');
INSERT INTO `device_heartbeat_record` VALUES (5421, 'B4BFE90CDBA1', 1590, '2026-11-02 11:33:12.882', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590392869, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1590, \"rssi\": -65, \"free_heap\": 145330, \"voltage\": 3.28, \"core_temp\": 48.2}}', '2026-11-02 11:33:12.882');
INSERT INTO `device_heartbeat_record` VALUES (5422, 'B4BFE90CDBA1', 1620, '2026-11-02 11:33:42.894', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590422880, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1620, \"rssi\": -71, \"free_heap\": 127571, \"voltage\": 3.35, \"core_temp\": 53.5}}', '2026-11-02 11:33:42.895');
INSERT INTO `device_heartbeat_record` VALUES (5423, 'B4BFE90CDBA1', 1650, '2026-11-02 11:34:12.897', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590452885, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1650, \"rssi\": -68, \"free_heap\": 158064, \"voltage\": 3.31, \"core_temp\": 53.9}}', '2026-11-02 11:34:12.897');
INSERT INTO `device_heartbeat_record` VALUES (5424, 'B4BFE90CDBA1', 1680, '2026-11-02 11:34:42.906', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590482896, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1680, \"rssi\": -64, \"free_heap\": 139855, \"voltage\": 3.31, \"core_temp\": 49.5}}', '2026-11-02 11:34:42.906');
INSERT INTO `device_heartbeat_record` VALUES (5425, 'B4BFE90CDBA1', 1710, '2026-11-02 11:35:12.912', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590512903, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1710, \"rssi\": -64, \"free_heap\": 145576, \"voltage\": 3.4, \"core_temp\": 45.3}}', '2026-11-02 11:35:12.912');
INSERT INTO `device_heartbeat_record` VALUES (5426, 'B4BFE90CDBA1', 1740, '2026-11-02 11:35:42.921', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590542915, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1740, \"rssi\": -69, \"free_heap\": 165707, \"voltage\": 3.36, \"core_temp\": 51.4}}', '2026-11-02 11:35:42.922');
INSERT INTO `device_heartbeat_record` VALUES (5427, 'B4BFE90CDBA1', 1770, '2026-11-02 11:36:12.936', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590572930, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1770, \"rssi\": -55, \"free_heap\": 142752, \"voltage\": 3.36, \"core_temp\": 52.6}}', '2026-11-02 11:36:12.936');
INSERT INTO `device_heartbeat_record` VALUES (5428, 'B4BFE90CDBA1', 1800, '2026-11-02 11:36:42.960', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590602942, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1800, \"rssi\": -63, \"free_heap\": 121164, \"voltage\": 3.37, \"core_temp\": 46.9}}', '2026-11-02 11:36:42.960');
INSERT INTO `device_heartbeat_record` VALUES (5429, 'B4BFE90CDBA1', 1830, '2026-11-02 11:37:12.962', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590632954, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1830, \"rssi\": -61, \"free_heap\": 170332, \"voltage\": 3.27, \"core_temp\": 51.1}}', '2026-11-02 11:37:12.962');
INSERT INTO `device_heartbeat_record` VALUES (5430, 'B4BFE90CDBA1', 1860, '2026-11-02 11:37:42.966', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590662957, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1860, \"rssi\": -73, \"free_heap\": 150894, \"voltage\": 3.22, \"core_temp\": 53.3}}', '2026-11-02 11:37:42.966');
INSERT INTO `device_heartbeat_record` VALUES (5431, 'B4BFE90CDBA1', 1890, '2026-11-02 11:38:12.973', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590692963, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1890, \"rssi\": -64, \"free_heap\": 179112, \"voltage\": 3.31, \"core_temp\": 50.6}}', '2026-11-02 11:38:12.973');
INSERT INTO `device_heartbeat_record` VALUES (5432, 'B4BFE90CDBA1', 1920, '2026-11-02 11:38:42.981', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590722975, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1920, \"rssi\": -58, \"free_heap\": 150902, \"voltage\": 3.21, \"core_temp\": 47.3}}', '2026-11-02 11:38:42.981');
INSERT INTO `device_heartbeat_record` VALUES (5433, 'B4BFE90CDBA1', 1950, '2026-11-02 11:39:12.995', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590752983, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1950, \"rssi\": -55, \"free_heap\": 133874, \"voltage\": 3.29, \"core_temp\": 54.0}}', '2026-11-02 11:39:12.996');
INSERT INTO `device_heartbeat_record` VALUES (5434, 'B4BFE90CDBA1', 1980, '2026-11-02 11:39:43.007', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590782995, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1980, \"rssi\": -57, \"free_heap\": 142197, \"voltage\": 3.4, \"core_temp\": 49.3}}', '2026-11-02 11:39:43.007');
INSERT INTO `device_heartbeat_record` VALUES (5435, 'B4BFE90CDBA1', 2010, '2026-11-02 11:40:13.004', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590812997, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2010, \"rssi\": -61, \"free_heap\": 162541, \"voltage\": 3.22, \"core_temp\": 50.6}}', '2026-11-02 11:40:13.004');

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
  INDEX `idx_online`(`online` ASC) USING BTREE,
  INDEX `idx_last_heartbeat`(`last_heartbeat_time` ASC) USING BTREE,
  INDEX `idx_ota_state`(`ota_state` ASC) USING BTREE,
  INDEX `idx_group_id`(`group_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_device_id_deleted`(`device_id` ASC, `deleted` ASC) USING BTREE,
  UNIQUE INDEX `uk_bind_code_deleted`(`bind_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_info
-- ----------------------------
INSERT INTO `device_info` VALUES (19, 'MAC123456789', '大厅温湿度计', 'SmartHome-v1', NULL, NULL, NULL, '二楼客厅', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 10:36:30.479', '2026-10-27 10:36:30.479', 0);
INSERT INTO `device_info` VALUES (20, 'AABBCCDDEE11', '厨房温湿度计', 'SmartHome-v1', NULL, NULL, NULL, '一楼厨房', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 10:50:03.177', '2026-10-27 11:15:27.656', 0);
INSERT INTO `device_info` VALUES (21, 'AABBCCDDEE12', '厨房温湿度计', 'SmartHome-v1', NULL, NULL, NULL, '一楼厨房', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 10:51:40.013', '2026-10-27 11:15:27.656', 0);
INSERT INTO `device_info` VALUES (22, 'AABBCCDDEE13', '厨房温湿度计', 'SmartHome-v1', NULL, NULL, NULL, '一楼厨房', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 10:51:47.858', '2026-10-27 11:15:27.656', 0);
INSERT INTO `device_info` VALUES (23, 'AABBCCDDEE15', '卧室温湿度计', 'SmartHome-v1', NULL, NULL, NULL, '一楼卧室', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 11:22:33.509', '2026-10-27 11:23:00.399', 0);
INSERT INTO `device_info` VALUES (24, 'AABBCCDDEE16', '卧室温湿度计', 'SmartHome-v1', NULL, NULL, NULL, '二楼卧室', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 11:23:23.852', '2026-10-27 11:40:19.420', 0);
INSERT INTO `device_info` VALUES (25, 'AABBCCDDEE17', '卧室温湿度计', 'SmartHome-v1', NULL, NULL, NULL, '三楼卧室', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 11:24:47.861', '2026-10-27 11:40:19.420', 0);
INSERT INTO `device_info` VALUES (26, 'AABBCCDDEEB7', '卧室温湿度计', 'SmartHome-v1', NULL, NULL, NULL, '三楼卧室', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 11:26:25.533', '2026-10-27 11:40:19.420', 0);
INSERT INTO `device_info` VALUES (27, 'AABBCCDDEEA7', '卧室温湿度计', 'SmartHome-v1', NULL, NULL, NULL, '三楼大厅', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 11:38:23.904', '2026-10-27 11:38:23.904', 0);
INSERT INTO `device_info` VALUES (28, 'AABBCCDDEEC7', '厨房大灯', 'SmartHome-v1', NULL, NULL, NULL, '一楼厨房', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-27 11:41:06.153', '2026-10-27 11:41:06.153', 0);
INSERT INTO `device_info` VALUES (34, 'B4BFE90CDBA2', '卧室大灯', 'SmartHome-v1', NULL, NULL, 'C97E7F', '一楼', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-11-01 18:59:21.571', '2026-11-01 18:59:21.571', 0);
INSERT INTO `device_info` VALUES (35, 'B4BFE90CDBA1', '阳台大灯', 'SmartHome-v1', '1.0.29', '-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEaQmN0xWz7sfwYfLWRdeC9MhFwK9k\nyLzqqz3EZuiFqcy/6eIQ0D96onhRyPG+IkQPDgP8NToOoLtm8iJhk9zUhQ==\n-----END PUBLIC KEY-----\n', 'B9AC18', '一楼阳台', NULL, 1, NULL, '2026-11-02 10:54:03.771', '2026-11-02 10:59:29.451', '2026-11-02 11:31:12.840', 1470, '{\"led\": 3, \"mos\": 8, \"relay\": 1, \"servo\": 2}', '{\"led_1\": 1, \"led_2\": 1, \"led_3\": 0, \"mos_1\": 0, \"mos_2\": 0, \"mos_3\": 1, \"mos_4\": 0, \"mos_5\": 0, \"mos_6\": 0, \"mos_7\": 0, \"mos_8\": 0, \"relay_1\": 0, \"servo_1\": 90, \"servo_2\": 90}', NULL, NULL, NULL, NULL, NULL, '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590272837, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 1470, \"rssi\": -63, \"free_heap\": 125452, \"voltage\": 3.22, \"core_temp\": 46.6}}', '2026-11-02 10:15:16.991', '2026-11-02 11:31:12.840', 35);
INSERT INTO `device_info` VALUES (36, 'B4BFE90CDBA1', '阳台大灯', 'SmartHome-v1', '1.0.29', '-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEf7HIqnFOEL1n5OOAFuz4EGRQonjI\nIBSzyhL0OXnQeFCebS6JADoZrvCFfgJbyOr8yQHos47f5DHm6UOdo8sV9w==\n-----END PUBLIC KEY-----\n', 'FC1D64', '一楼阳台', NULL, 1, NULL, '2026-11-02 11:31:26.526', NULL, '2026-11-02 11:40:13.000', 2010, '{\"led\": 3, \"mos\": 8, \"relay\": 1, \"servo\": 2}', '{\"led_1\": 0, \"led_2\": 0, \"led_3\": 0, \"mos_1\": 0, \"mos_2\": 0, \"mos_3\": 0, \"mos_4\": 1, \"mos_5\": 0, \"mos_6\": 0, \"mos_7\": 0, \"mos_8\": 0, \"relay_1\": 0, \"servo_1\": 90, \"servo_2\": 90}', NULL, NULL, NULL, NULL, NULL, '{\"device\": \"B4BFE90CDBA1\", \"type\": \"heartbeat\", \"timestamp\": 1793590812997, \"data\": {\"product\": \"SmartHome-v1\", \"uptime\": 2010, \"rssi\": -61, \"free_heap\": 162541, \"voltage\": 3.22, \"core_temp\": 50.6}}', '2026-11-02 11:02:18.063', '2026-11-02 11:40:13.000', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '统一MQTT认证账号表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_mqtt_auth
-- ----------------------------
INSERT INTO `device_mqtt_auth` VALUES (1, 'PROVISION_USER', 'f43c57babf15d80cd5e961e6dee8b1795dcff8805ca9a4aabc2d048d2499f172', '767f13ac5e1c4dbdddb7f4c288bb085b', 0, 1, NULL, '2026-10-15 18:36:10.738', '2026-10-17 16:20:53.331');
INSERT INTO `device_mqtt_auth` VALUES (2, 'java-backend', 'fae340eae69a2dfad416154a5d47474ce546d2c2ba9bc57fa8c0b833a6886aff', '667f13ac5e1c4dbdddb7f4c288bb0856', 1, 1, NULL, '2026-10-15 18:36:43.369', '2026-10-21 11:50:01.894');
INSERT INTO `device_mqtt_auth` VALUES (15, 'B4BFE90CDBA1', '28e96147661d943342e97d2337a28048a797879055f6b377a05646cdf29d726d', '37429ad44a80d1de6b0319f2b64c08e2', 0, 1, 'B4BFE90CDBA1', '2026-11-02 11:06:50.375', '2026-11-02 11:06:50.375');

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
  INDEX `idx_timestamp`(`timestamp` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 86359 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '传感器数据历史表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_sensor_record
-- ----------------------------
INSERT INTO `device_sensor_record` VALUES (84321, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.6, '℃', NULL, NULL, '2026-11-02 10:58:34.303', '2026-11-02 10:58:34.303');
INSERT INTO `device_sensor_record` VALUES (84322, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.9, '%', NULL, NULL, '2026-11-02 10:58:34.303', '2026-11-02 10:58:34.303');
INSERT INTO `device_sensor_record` VALUES (84323, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35.5, 'μg/m³', NULL, NULL, '2026-11-02 10:58:34.303', '2026-11-02 10:58:34.303');
INSERT INTO `device_sensor_record` VALUES (84324, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 533.2, 'ppm', NULL, NULL, '2026-11-02 10:58:34.303', '2026-11-02 10:58:34.303');
INSERT INTO `device_sensor_record` VALUES (84325, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 278.9, 'lx', NULL, NULL, '2026-11-02 10:58:34.303', '2026-11-02 10:58:34.303');
INSERT INTO `device_sensor_record` VALUES (84326, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.1, '℃', NULL, NULL, '2026-11-02 10:58:34.303', '2026-11-02 10:58:34.303');
INSERT INTO `device_sensor_record` VALUES (84327, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 26, '℃', NULL, NULL, '2026-11-02 10:58:34.303', '2026-11-02 10:58:34.303');
INSERT INTO `device_sensor_record` VALUES (84328, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.5, '℃', NULL, NULL, '2026-11-02 10:58:34.303', '2026-11-02 10:58:34.303');
INSERT INTO `device_sensor_record` VALUES (84329, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 10:58:34.303', '2026-11-02 10:58:34.303');
INSERT INTO `device_sensor_record` VALUES (84330, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 176637, 'bytes', NULL, NULL, '2026-11-02 10:58:34.303', '2026-11-02 10:58:34.303');
INSERT INTO `device_sensor_record` VALUES (84331, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-02 10:58:44.310', '2026-11-02 10:58:44.310');
INSERT INTO `device_sensor_record` VALUES (84332, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.8, '%', NULL, NULL, '2026-11-02 10:58:44.310', '2026-11-02 10:58:44.310');
INSERT INTO `device_sensor_record` VALUES (84333, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 44.6, 'μg/m³', NULL, NULL, '2026-11-02 10:58:44.310', '2026-11-02 10:58:44.310');
INSERT INTO `device_sensor_record` VALUES (84334, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 588.2, 'ppm', NULL, NULL, '2026-11-02 10:58:44.310', '2026-11-02 10:58:44.310');
INSERT INTO `device_sensor_record` VALUES (84335, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 259.4, 'lx', NULL, NULL, '2026-11-02 10:58:44.310', '2026-11-02 10:58:44.310');
INSERT INTO `device_sensor_record` VALUES (84336, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.5, '℃', NULL, NULL, '2026-11-02 10:58:44.310', '2026-11-02 10:58:44.310');
INSERT INTO `device_sensor_record` VALUES (84337, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.3, '℃', NULL, NULL, '2026-11-02 10:58:44.310', '2026-11-02 10:58:44.310');
INSERT INTO `device_sensor_record` VALUES (84338, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50, '℃', NULL, NULL, '2026-11-02 10:58:44.310', '2026-11-02 10:58:44.310');
INSERT INTO `device_sensor_record` VALUES (84339, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-02 10:58:44.310', '2026-11-02 10:58:44.310');
INSERT INTO `device_sensor_record` VALUES (84340, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 148710, 'bytes', NULL, NULL, '2026-11-02 10:58:44.310', '2026-11-02 10:58:44.310');
INSERT INTO `device_sensor_record` VALUES (84341, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.4, '℃', NULL, NULL, '2026-11-02 10:58:54.322', '2026-11-02 10:58:54.322');
INSERT INTO `device_sensor_record` VALUES (84342, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.3, '%', NULL, NULL, '2026-11-02 10:58:54.322', '2026-11-02 10:58:54.322');
INSERT INTO `device_sensor_record` VALUES (84343, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 45.6, 'μg/m³', NULL, NULL, '2026-11-02 10:58:54.322', '2026-11-02 10:58:54.322');
INSERT INTO `device_sensor_record` VALUES (84344, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 408.6, 'ppm', NULL, NULL, '2026-11-02 10:58:54.322', '2026-11-02 10:58:54.322');
INSERT INTO `device_sensor_record` VALUES (84345, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 356.7, 'lx', NULL, NULL, '2026-11-02 10:58:54.322', '2026-11-02 10:58:54.322');
INSERT INTO `device_sensor_record` VALUES (84346, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.5, '℃', NULL, NULL, '2026-11-02 10:58:54.322', '2026-11-02 10:58:54.322');
INSERT INTO `device_sensor_record` VALUES (84347, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 10:58:54.322', '2026-11-02 10:58:54.322');
INSERT INTO `device_sensor_record` VALUES (84348, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.8, '℃', NULL, NULL, '2026-11-02 10:58:54.322', '2026-11-02 10:58:54.322');
INSERT INTO `device_sensor_record` VALUES (84349, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 10:58:54.322', '2026-11-02 10:58:54.322');
INSERT INTO `device_sensor_record` VALUES (84350, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 169424, 'bytes', NULL, NULL, '2026-11-02 10:58:54.322', '2026-11-02 10:58:54.322');
INSERT INTO `device_sensor_record` VALUES (84351, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 10:59:04.326', '2026-11-02 10:59:04.326');
INSERT INTO `device_sensor_record` VALUES (84352, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 50.6, '%', NULL, NULL, '2026-11-02 10:59:04.326', '2026-11-02 10:59:04.326');
INSERT INTO `device_sensor_record` VALUES (84353, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 10:59:04.326', '2026-11-02 10:59:04.326');
INSERT INTO `device_sensor_record` VALUES (84354, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 507.6, 'ppm', NULL, NULL, '2026-11-02 10:59:04.326', '2026-11-02 10:59:04.326');
INSERT INTO `device_sensor_record` VALUES (84355, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 791.2, 'lx', NULL, NULL, '2026-11-02 10:59:04.326', '2026-11-02 10:59:04.326');
INSERT INTO `device_sensor_record` VALUES (84356, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.6, '℃', NULL, NULL, '2026-11-02 10:59:04.326', '2026-11-02 10:59:04.326');
INSERT INTO `device_sensor_record` VALUES (84357, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 10:59:04.326', '2026-11-02 10:59:04.326');
INSERT INTO `device_sensor_record` VALUES (84358, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.8, '℃', NULL, NULL, '2026-11-02 10:59:04.326', '2026-11-02 10:59:04.326');
INSERT INTO `device_sensor_record` VALUES (84359, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-02 10:59:04.326', '2026-11-02 10:59:04.326');
INSERT INTO `device_sensor_record` VALUES (84360, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 147282, 'bytes', NULL, NULL, '2026-11-02 10:59:04.326', '2026-11-02 10:59:04.326');
INSERT INTO `device_sensor_record` VALUES (84361, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.1, '℃', NULL, NULL, '2026-11-02 10:59:14.327', '2026-11-02 10:59:14.327');
INSERT INTO `device_sensor_record` VALUES (84362, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.9, '%', NULL, NULL, '2026-11-02 10:59:14.327', '2026-11-02 10:59:14.327');
INSERT INTO `device_sensor_record` VALUES (84363, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 42.9, 'μg/m³', NULL, NULL, '2026-11-02 10:59:14.327', '2026-11-02 10:59:14.327');
INSERT INTO `device_sensor_record` VALUES (84364, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 464.4, 'ppm', NULL, NULL, '2026-11-02 10:59:14.327', '2026-11-02 10:59:14.327');
INSERT INTO `device_sensor_record` VALUES (84365, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 714.7, 'lx', NULL, NULL, '2026-11-02 10:59:14.327', '2026-11-02 10:59:14.327');
INSERT INTO `device_sensor_record` VALUES (84366, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-02 10:59:14.327', '2026-11-02 10:59:14.327');
INSERT INTO `device_sensor_record` VALUES (84367, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 10:59:14.327', '2026-11-02 10:59:14.327');
INSERT INTO `device_sensor_record` VALUES (84368, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.3, '℃', NULL, NULL, '2026-11-02 10:59:14.327', '2026-11-02 10:59:14.327');
INSERT INTO `device_sensor_record` VALUES (84369, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-02 10:59:14.327', '2026-11-02 10:59:14.327');
INSERT INTO `device_sensor_record` VALUES (84370, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 152723, 'bytes', NULL, NULL, '2026-11-02 10:59:14.327', '2026-11-02 10:59:14.327');
INSERT INTO `device_sensor_record` VALUES (84371, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-02 10:59:24.336', '2026-11-02 10:59:24.336');
INSERT INTO `device_sensor_record` VALUES (84372, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 57.3, '%', NULL, NULL, '2026-11-02 10:59:24.336', '2026-11-02 10:59:24.336');
INSERT INTO `device_sensor_record` VALUES (84373, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35.5, 'μg/m³', NULL, NULL, '2026-11-02 10:59:24.336', '2026-11-02 10:59:24.336');
INSERT INTO `device_sensor_record` VALUES (84374, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 566.9, 'ppm', NULL, NULL, '2026-11-02 10:59:24.336', '2026-11-02 10:59:24.336');
INSERT INTO `device_sensor_record` VALUES (84375, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 575.3, 'lx', NULL, NULL, '2026-11-02 10:59:24.336', '2026-11-02 10:59:24.336');
INSERT INTO `device_sensor_record` VALUES (84376, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-02 10:59:24.336', '2026-11-02 10:59:24.336');
INSERT INTO `device_sensor_record` VALUES (84377, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-02 10:59:24.336', '2026-11-02 10:59:24.336');
INSERT INTO `device_sensor_record` VALUES (84378, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.8, '℃', NULL, NULL, '2026-11-02 10:59:24.336', '2026-11-02 10:59:24.336');
INSERT INTO `device_sensor_record` VALUES (84379, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-02 10:59:24.336', '2026-11-02 10:59:24.336');
INSERT INTO `device_sensor_record` VALUES (84380, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 164565, 'bytes', NULL, NULL, '2026-11-02 10:59:24.336', '2026-11-02 10:59:24.336');
INSERT INTO `device_sensor_record` VALUES (84381, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'slave-1-temperature', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:07:12.386', '2026-11-02 11:07:12.394');
INSERT INTO `device_sensor_record` VALUES (84382, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'slave-2-humidity', 'humidity', 55, '%', NULL, NULL, '2026-11-02 11:07:12.386', '2026-11-02 11:07:12.395');
INSERT INTO `device_sensor_record` VALUES (84383, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'slave-3-pm25', 'pm25', 35, 'μg/m³', NULL, NULL, '2026-11-02 11:07:12.386', '2026-11-02 11:07:12.395');
INSERT INTO `device_sensor_record` VALUES (84384, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'slave-4-co2', 'co2', 450, 'ppm', NULL, NULL, '2026-11-02 11:07:12.386', '2026-11-02 11:07:12.395');
INSERT INTO `device_sensor_record` VALUES (84385, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'slave-5-illuminance', 'illuminance', 300, 'lx', NULL, NULL, '2026-11-02 11:07:12.386', '2026-11-02 11:07:12.395');
INSERT INTO `device_sensor_record` VALUES (84386, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'slave-6-temperature-ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:07:12.386', '2026-11-02 11:07:12.395');
INSERT INTO `device_sensor_record` VALUES (84387, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'slave-6-temperature-ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 11:07:12.386', '2026-11-02 11:07:12.395');
INSERT INTO `device_sensor_record` VALUES (84388, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-02 11:07:12.407', '2026-11-02 11:07:12.407');
INSERT INTO `device_sensor_record` VALUES (84389, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 51.6, '%', NULL, NULL, '2026-11-02 11:07:12.407', '2026-11-02 11:07:12.407');
INSERT INTO `device_sensor_record` VALUES (84390, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35.2, 'μg/m³', NULL, NULL, '2026-11-02 11:07:12.407', '2026-11-02 11:07:12.407');
INSERT INTO `device_sensor_record` VALUES (84391, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 409.1, 'ppm', NULL, NULL, '2026-11-02 11:07:12.407', '2026-11-02 11:07:12.407');
INSERT INTO `device_sensor_record` VALUES (84392, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 217.1, 'lx', NULL, NULL, '2026-11-02 11:07:12.407', '2026-11-02 11:07:12.407');
INSERT INTO `device_sensor_record` VALUES (84393, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.5, '℃', NULL, NULL, '2026-11-02 11:07:12.407', '2026-11-02 11:07:12.407');
INSERT INTO `device_sensor_record` VALUES (84394, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:07:12.407', '2026-11-02 11:07:12.407');
INSERT INTO `device_sensor_record` VALUES (84395, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.2, '℃', NULL, NULL, '2026-11-02 11:07:12.407', '2026-11-02 11:07:12.407');
INSERT INTO `device_sensor_record` VALUES (84396, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:07:12.407', '2026-11-02 11:07:12.407');
INSERT INTO `device_sensor_record` VALUES (84397, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 160529, 'bytes', NULL, NULL, '2026-11-02 11:07:12.407', '2026-11-02 11:07:12.407');
INSERT INTO `device_sensor_record` VALUES (84398, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26, '℃', NULL, NULL, '2026-11-02 11:07:22.390', '2026-11-02 11:07:22.390');
INSERT INTO `device_sensor_record` VALUES (84399, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.8, '%', NULL, NULL, '2026-11-02 11:07:22.390', '2026-11-02 11:07:22.390');
INSERT INTO `device_sensor_record` VALUES (84400, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 49.9, 'μg/m³', NULL, NULL, '2026-11-02 11:07:22.390', '2026-11-02 11:07:22.390');
INSERT INTO `device_sensor_record` VALUES (84401, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 462, 'ppm', NULL, NULL, '2026-11-02 11:07:22.390', '2026-11-02 11:07:22.390');
INSERT INTO `device_sensor_record` VALUES (84402, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 123.8, 'lx', NULL, NULL, '2026-11-02 11:07:22.390', '2026-11-02 11:07:22.390');
INSERT INTO `device_sensor_record` VALUES (84403, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-02 11:07:22.390', '2026-11-02 11:07:22.390');
INSERT INTO `device_sensor_record` VALUES (84404, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.6, '℃', NULL, NULL, '2026-11-02 11:07:22.390', '2026-11-02 11:07:22.390');
INSERT INTO `device_sensor_record` VALUES (84405, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.1, '℃', NULL, NULL, '2026-11-02 11:07:22.390', '2026-11-02 11:07:22.390');
INSERT INTO `device_sensor_record` VALUES (84406, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:07:22.390', '2026-11-02 11:07:22.390');
INSERT INTO `device_sensor_record` VALUES (84407, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 129773, 'bytes', NULL, NULL, '2026-11-02 11:07:22.390', '2026-11-02 11:07:22.390');
INSERT INTO `device_sensor_record` VALUES (84408, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.9, '℃', NULL, NULL, '2026-11-02 11:07:32.398', '2026-11-02 11:07:32.398');
INSERT INTO `device_sensor_record` VALUES (84409, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.1, '%', NULL, NULL, '2026-11-02 11:07:32.398', '2026-11-02 11:07:32.398');
INSERT INTO `device_sensor_record` VALUES (84410, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 38.7, 'μg/m³', NULL, NULL, '2026-11-02 11:07:32.398', '2026-11-02 11:07:32.398');
INSERT INTO `device_sensor_record` VALUES (84411, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 400.1, 'ppm', NULL, NULL, '2026-11-02 11:07:32.398', '2026-11-02 11:07:32.398');
INSERT INTO `device_sensor_record` VALUES (84412, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 164, 'lx', NULL, NULL, '2026-11-02 11:07:32.398', '2026-11-02 11:07:32.398');
INSERT INTO `device_sensor_record` VALUES (84413, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-02 11:07:32.398', '2026-11-02 11:07:32.398');
INSERT INTO `device_sensor_record` VALUES (84414, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.9, '℃', NULL, NULL, '2026-11-02 11:07:32.398', '2026-11-02 11:07:32.398');
INSERT INTO `device_sensor_record` VALUES (84415, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.4, '℃', NULL, NULL, '2026-11-02 11:07:32.398', '2026-11-02 11:07:32.398');
INSERT INTO `device_sensor_record` VALUES (84416, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-02 11:07:32.398', '2026-11-02 11:07:32.398');
INSERT INTO `device_sensor_record` VALUES (84417, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 160364, 'bytes', NULL, NULL, '2026-11-02 11:07:32.398', '2026-11-02 11:07:32.398');
INSERT INTO `device_sensor_record` VALUES (84418, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.8, '℃', NULL, NULL, '2026-11-02 11:07:42.398', '2026-11-02 11:07:42.398');
INSERT INTO `device_sensor_record` VALUES (84419, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.6, '%', NULL, NULL, '2026-11-02 11:07:42.398', '2026-11-02 11:07:42.398');
INSERT INTO `device_sensor_record` VALUES (84420, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 29.4, 'μg/m³', NULL, NULL, '2026-11-02 11:07:42.398', '2026-11-02 11:07:42.398');
INSERT INTO `device_sensor_record` VALUES (84421, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 593.3, 'ppm', NULL, NULL, '2026-11-02 11:07:42.398', '2026-11-02 11:07:42.398');
INSERT INTO `device_sensor_record` VALUES (84422, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 555.7, 'lx', NULL, NULL, '2026-11-02 11:07:42.398', '2026-11-02 11:07:42.398');
INSERT INTO `device_sensor_record` VALUES (84423, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-02 11:07:42.398', '2026-11-02 11:07:42.398');
INSERT INTO `device_sensor_record` VALUES (84424, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-02 11:07:42.398', '2026-11-02 11:07:42.398');
INSERT INTO `device_sensor_record` VALUES (84425, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.5, '℃', NULL, NULL, '2026-11-02 11:07:42.398', '2026-11-02 11:07:42.398');
INSERT INTO `device_sensor_record` VALUES (84426, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:07:42.398', '2026-11-02 11:07:42.398');
INSERT INTO `device_sensor_record` VALUES (84427, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 160879, 'bytes', NULL, NULL, '2026-11-02 11:07:42.398', '2026-11-02 11:07:42.398');
INSERT INTO `device_sensor_record` VALUES (84428, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:07:52.411', '2026-11-02 11:07:52.411');
INSERT INTO `device_sensor_record` VALUES (84429, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 57.3, '%', NULL, NULL, '2026-11-02 11:07:52.411', '2026-11-02 11:07:52.411');
INSERT INTO `device_sensor_record` VALUES (84430, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:07:52.411', '2026-11-02 11:07:52.411');
INSERT INTO `device_sensor_record` VALUES (84431, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 438.4, 'ppm', NULL, NULL, '2026-11-02 11:07:52.411', '2026-11-02 11:07:52.411');
INSERT INTO `device_sensor_record` VALUES (84432, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 427.5, 'lx', NULL, NULL, '2026-11-02 11:07:52.411', '2026-11-02 11:07:52.411');
INSERT INTO `device_sensor_record` VALUES (84433, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-02 11:07:52.411', '2026-11-02 11:07:52.411');
INSERT INTO `device_sensor_record` VALUES (84434, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-02 11:07:52.411', '2026-11-02 11:07:52.411');
INSERT INTO `device_sensor_record` VALUES (84435, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.5, '℃', NULL, NULL, '2026-11-02 11:07:52.411', '2026-11-02 11:07:52.411');
INSERT INTO `device_sensor_record` VALUES (84436, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.4, 'V', NULL, NULL, '2026-11-02 11:07:52.411', '2026-11-02 11:07:52.411');
INSERT INTO `device_sensor_record` VALUES (84437, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 167997, 'bytes', NULL, NULL, '2026-11-02 11:07:52.411', '2026-11-02 11:07:52.411');
INSERT INTO `device_sensor_record` VALUES (84438, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:08:02.414', '2026-11-02 11:08:02.414');
INSERT INTO `device_sensor_record` VALUES (84439, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 50.4, '%', NULL, NULL, '2026-11-02 11:08:02.414', '2026-11-02 11:08:02.414');
INSERT INTO `device_sensor_record` VALUES (84440, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 38.1, 'μg/m³', NULL, NULL, '2026-11-02 11:08:02.414', '2026-11-02 11:08:02.414');
INSERT INTO `device_sensor_record` VALUES (84441, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 538, 'ppm', NULL, NULL, '2026-11-02 11:08:02.414', '2026-11-02 11:08:02.414');
INSERT INTO `device_sensor_record` VALUES (84442, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 200.7, 'lx', NULL, NULL, '2026-11-02 11:08:02.414', '2026-11-02 11:08:02.414');
INSERT INTO `device_sensor_record` VALUES (84443, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.3, '℃', NULL, NULL, '2026-11-02 11:08:02.414', '2026-11-02 11:08:02.414');
INSERT INTO `device_sensor_record` VALUES (84444, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-02 11:08:02.414', '2026-11-02 11:08:02.414');
INSERT INTO `device_sensor_record` VALUES (84445, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.1, '℃', NULL, NULL, '2026-11-02 11:08:02.414', '2026-11-02 11:08:02.414');
INSERT INTO `device_sensor_record` VALUES (84446, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-02 11:08:02.414', '2026-11-02 11:08:02.414');
INSERT INTO `device_sensor_record` VALUES (84447, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 165994, 'bytes', NULL, NULL, '2026-11-02 11:08:02.414', '2026-11-02 11:08:02.414');
INSERT INTO `device_sensor_record` VALUES (84448, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.8, '℃', NULL, NULL, '2026-11-02 11:08:12.417', '2026-11-02 11:08:12.417');
INSERT INTO `device_sensor_record` VALUES (84449, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.6, '%', NULL, NULL, '2026-11-02 11:08:12.417', '2026-11-02 11:08:12.417');
INSERT INTO `device_sensor_record` VALUES (84450, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 28.3, 'μg/m³', NULL, NULL, '2026-11-02 11:08:12.417', '2026-11-02 11:08:12.417');
INSERT INTO `device_sensor_record` VALUES (84451, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 452.2, 'ppm', NULL, NULL, '2026-11-02 11:08:12.417', '2026-11-02 11:08:12.417');
INSERT INTO `device_sensor_record` VALUES (84452, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 646.8, 'lx', NULL, NULL, '2026-11-02 11:08:12.417', '2026-11-02 11:08:12.417');
INSERT INTO `device_sensor_record` VALUES (84453, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-02 11:08:12.417', '2026-11-02 11:08:12.417');
INSERT INTO `device_sensor_record` VALUES (84454, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.6, '℃', NULL, NULL, '2026-11-02 11:08:12.417', '2026-11-02 11:08:12.417');
INSERT INTO `device_sensor_record` VALUES (84455, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.4, '℃', NULL, NULL, '2026-11-02 11:08:12.417', '2026-11-02 11:08:12.417');
INSERT INTO `device_sensor_record` VALUES (84456, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-02 11:08:12.417', '2026-11-02 11:08:12.417');
INSERT INTO `device_sensor_record` VALUES (84457, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 175520, 'bytes', NULL, NULL, '2026-11-02 11:08:12.417', '2026-11-02 11:08:12.417');
INSERT INTO `device_sensor_record` VALUES (84458, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-02 11:08:22.420', '2026-11-02 11:08:22.420');
INSERT INTO `device_sensor_record` VALUES (84459, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 50.7, '%', NULL, NULL, '2026-11-02 11:08:22.420', '2026-11-02 11:08:22.420');
INSERT INTO `device_sensor_record` VALUES (84460, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 34.4, 'μg/m³', NULL, NULL, '2026-11-02 11:08:22.420', '2026-11-02 11:08:22.420');
INSERT INTO `device_sensor_record` VALUES (84461, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 599.8, 'ppm', NULL, NULL, '2026-11-02 11:08:22.420', '2026-11-02 11:08:22.420');
INSERT INTO `device_sensor_record` VALUES (84462, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 505.1, 'lx', NULL, NULL, '2026-11-02 11:08:22.420', '2026-11-02 11:08:22.420');
INSERT INTO `device_sensor_record` VALUES (84463, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.9, '℃', NULL, NULL, '2026-11-02 11:08:22.420', '2026-11-02 11:08:22.420');
INSERT INTO `device_sensor_record` VALUES (84464, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:08:22.420', '2026-11-02 11:08:22.420');
INSERT INTO `device_sensor_record` VALUES (84465, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.2, '℃', NULL, NULL, '2026-11-02 11:08:22.420', '2026-11-02 11:08:22.420');
INSERT INTO `device_sensor_record` VALUES (84466, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.29, 'V', NULL, NULL, '2026-11-02 11:08:22.420', '2026-11-02 11:08:22.420');
INSERT INTO `device_sensor_record` VALUES (84467, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 173654, 'bytes', NULL, NULL, '2026-11-02 11:08:22.420', '2026-11-02 11:08:22.420');
INSERT INTO `device_sensor_record` VALUES (84468, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:08:32.428', '2026-11-02 11:08:32.428');
INSERT INTO `device_sensor_record` VALUES (84469, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.8, '%', NULL, NULL, '2026-11-02 11:08:32.428', '2026-11-02 11:08:32.428');
INSERT INTO `device_sensor_record` VALUES (84470, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 28.8, 'μg/m³', NULL, NULL, '2026-11-02 11:08:32.428', '2026-11-02 11:08:32.428');
INSERT INTO `device_sensor_record` VALUES (84471, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 588, 'ppm', NULL, NULL, '2026-11-02 11:08:32.428', '2026-11-02 11:08:32.428');
INSERT INTO `device_sensor_record` VALUES (84472, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 397, 'lx', NULL, NULL, '2026-11-02 11:08:32.428', '2026-11-02 11:08:32.428');
INSERT INTO `device_sensor_record` VALUES (84473, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-02 11:08:32.428', '2026-11-02 11:08:32.428');
INSERT INTO `device_sensor_record` VALUES (84474, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-02 11:08:32.428', '2026-11-02 11:08:32.428');
INSERT INTO `device_sensor_record` VALUES (84475, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.1, '℃', NULL, NULL, '2026-11-02 11:08:32.428', '2026-11-02 11:08:32.428');
INSERT INTO `device_sensor_record` VALUES (84476, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.39, 'V', NULL, NULL, '2026-11-02 11:08:32.428', '2026-11-02 11:08:32.428');
INSERT INTO `device_sensor_record` VALUES (84477, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 166535, 'bytes', NULL, NULL, '2026-11-02 11:08:32.428', '2026-11-02 11:08:32.428');
INSERT INTO `device_sensor_record` VALUES (84478, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:08:42.432', '2026-11-02 11:08:42.432');
INSERT INTO `device_sensor_record` VALUES (84479, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.3, '%', NULL, NULL, '2026-11-02 11:08:42.432', '2026-11-02 11:08:42.432');
INSERT INTO `device_sensor_record` VALUES (84480, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:08:42.432', '2026-11-02 11:08:42.432');
INSERT INTO `device_sensor_record` VALUES (84481, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 442.3, 'ppm', NULL, NULL, '2026-11-02 11:08:42.432', '2026-11-02 11:08:42.432');
INSERT INTO `device_sensor_record` VALUES (84482, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 667.4, 'lx', NULL, NULL, '2026-11-02 11:08:42.432', '2026-11-02 11:08:42.432');
INSERT INTO `device_sensor_record` VALUES (84483, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.2, '℃', NULL, NULL, '2026-11-02 11:08:42.432', '2026-11-02 11:08:42.432');
INSERT INTO `device_sensor_record` VALUES (84484, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:08:42.432', '2026-11-02 11:08:42.432');
INSERT INTO `device_sensor_record` VALUES (84485, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.1, '℃', NULL, NULL, '2026-11-02 11:08:42.432', '2026-11-02 11:08:42.432');
INSERT INTO `device_sensor_record` VALUES (84486, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-02 11:08:42.432', '2026-11-02 11:08:42.432');
INSERT INTO `device_sensor_record` VALUES (84487, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 171593, 'bytes', NULL, NULL, '2026-11-02 11:08:42.432', '2026-11-02 11:08:42.432');
INSERT INTO `device_sensor_record` VALUES (84488, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:08:52.442', '2026-11-02 11:08:52.442');
INSERT INTO `device_sensor_record` VALUES (84489, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.8, '%', NULL, NULL, '2026-11-02 11:08:52.442', '2026-11-02 11:08:52.442');
INSERT INTO `device_sensor_record` VALUES (84490, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35, 'μg/m³', NULL, NULL, '2026-11-02 11:08:52.442', '2026-11-02 11:08:52.442');
INSERT INTO `device_sensor_record` VALUES (84491, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 445.1, 'ppm', NULL, NULL, '2026-11-02 11:08:52.442', '2026-11-02 11:08:52.442');
INSERT INTO `device_sensor_record` VALUES (84492, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 741.7, 'lx', NULL, NULL, '2026-11-02 11:08:52.442', '2026-11-02 11:08:52.442');
INSERT INTO `device_sensor_record` VALUES (84493, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.7, '℃', NULL, NULL, '2026-11-02 11:08:52.442', '2026-11-02 11:08:52.442');
INSERT INTO `device_sensor_record` VALUES (84494, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.4, '℃', NULL, NULL, '2026-11-02 11:08:52.442', '2026-11-02 11:08:52.442');
INSERT INTO `device_sensor_record` VALUES (84495, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.1, '℃', NULL, NULL, '2026-11-02 11:08:52.442', '2026-11-02 11:08:52.442');
INSERT INTO `device_sensor_record` VALUES (84496, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:08:52.442', '2026-11-02 11:08:52.442');
INSERT INTO `device_sensor_record` VALUES (84497, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 171835, 'bytes', NULL, NULL, '2026-11-02 11:08:52.442', '2026-11-02 11:08:52.442');
INSERT INTO `device_sensor_record` VALUES (84498, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:09:02.458', '2026-11-02 11:09:02.458');
INSERT INTO `device_sensor_record` VALUES (84499, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.7, '%', NULL, NULL, '2026-11-02 11:09:02.458', '2026-11-02 11:09:02.458');
INSERT INTO `device_sensor_record` VALUES (84500, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 45.9, 'μg/m³', NULL, NULL, '2026-11-02 11:09:02.458', '2026-11-02 11:09:02.458');
INSERT INTO `device_sensor_record` VALUES (84501, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 433.7, 'ppm', NULL, NULL, '2026-11-02 11:09:02.458', '2026-11-02 11:09:02.458');
INSERT INTO `device_sensor_record` VALUES (84502, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 732.4, 'lx', NULL, NULL, '2026-11-02 11:09:02.458', '2026-11-02 11:09:02.458');
INSERT INTO `device_sensor_record` VALUES (84503, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.7, '℃', NULL, NULL, '2026-11-02 11:09:02.458', '2026-11-02 11:09:02.458');
INSERT INTO `device_sensor_record` VALUES (84504, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-02 11:09:02.458', '2026-11-02 11:09:02.458');
INSERT INTO `device_sensor_record` VALUES (84505, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.7, '℃', NULL, NULL, '2026-11-02 11:09:02.458', '2026-11-02 11:09:02.458');
INSERT INTO `device_sensor_record` VALUES (84506, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.4, 'V', NULL, NULL, '2026-11-02 11:09:02.458', '2026-11-02 11:09:02.458');
INSERT INTO `device_sensor_record` VALUES (84507, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 125957, 'bytes', NULL, NULL, '2026-11-02 11:09:02.458', '2026-11-02 11:09:02.458');
INSERT INTO `device_sensor_record` VALUES (84508, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:09:12.460', '2026-11-02 11:09:12.460');
INSERT INTO `device_sensor_record` VALUES (84509, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.7, '%', NULL, NULL, '2026-11-02 11:09:12.460', '2026-11-02 11:09:12.460');
INSERT INTO `device_sensor_record` VALUES (84510, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 42.5, 'μg/m³', NULL, NULL, '2026-11-02 11:09:12.460', '2026-11-02 11:09:12.460');
INSERT INTO `device_sensor_record` VALUES (84511, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 498.2, 'ppm', NULL, NULL, '2026-11-02 11:09:12.460', '2026-11-02 11:09:12.460');
INSERT INTO `device_sensor_record` VALUES (84512, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 189.4, 'lx', NULL, NULL, '2026-11-02 11:09:12.460', '2026-11-02 11:09:12.460');
INSERT INTO `device_sensor_record` VALUES (84513, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-02 11:09:12.460', '2026-11-02 11:09:12.460');
INSERT INTO `device_sensor_record` VALUES (84514, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-02 11:09:12.460', '2026-11-02 11:09:12.460');
INSERT INTO `device_sensor_record` VALUES (84515, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.5, '℃', NULL, NULL, '2026-11-02 11:09:12.460', '2026-11-02 11:09:12.460');
INSERT INTO `device_sensor_record` VALUES (84516, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.29, 'V', NULL, NULL, '2026-11-02 11:09:12.460', '2026-11-02 11:09:12.460');
INSERT INTO `device_sensor_record` VALUES (84517, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 171545, 'bytes', NULL, NULL, '2026-11-02 11:09:12.460', '2026-11-02 11:09:12.460');
INSERT INTO `device_sensor_record` VALUES (84518, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:09:22.471', '2026-11-02 11:09:22.471');
INSERT INTO `device_sensor_record` VALUES (84519, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 69.1, '%', NULL, NULL, '2026-11-02 11:09:22.471', '2026-11-02 11:09:22.471');
INSERT INTO `device_sensor_record` VALUES (84520, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 37.6, 'μg/m³', NULL, NULL, '2026-11-02 11:09:22.471', '2026-11-02 11:09:22.471');
INSERT INTO `device_sensor_record` VALUES (84521, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 444, 'ppm', NULL, NULL, '2026-11-02 11:09:22.471', '2026-11-02 11:09:22.471');
INSERT INTO `device_sensor_record` VALUES (84522, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 450.2, 'lx', NULL, NULL, '2026-11-02 11:09:22.471', '2026-11-02 11:09:22.471');
INSERT INTO `device_sensor_record` VALUES (84523, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.3, '℃', NULL, NULL, '2026-11-02 11:09:22.471', '2026-11-02 11:09:22.471');
INSERT INTO `device_sensor_record` VALUES (84524, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:09:22.471', '2026-11-02 11:09:22.471');
INSERT INTO `device_sensor_record` VALUES (84525, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.9, '℃', NULL, NULL, '2026-11-02 11:09:22.471', '2026-11-02 11:09:22.471');
INSERT INTO `device_sensor_record` VALUES (84526, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.4, 'V', NULL, NULL, '2026-11-02 11:09:22.471', '2026-11-02 11:09:22.471');
INSERT INTO `device_sensor_record` VALUES (84527, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 155950, 'bytes', NULL, NULL, '2026-11-02 11:09:22.471', '2026-11-02 11:09:22.471');
INSERT INTO `device_sensor_record` VALUES (84528, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:09:32.475', '2026-11-02 11:09:32.475');
INSERT INTO `device_sensor_record` VALUES (84529, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 57.9, '%', NULL, NULL, '2026-11-02 11:09:32.475', '2026-11-02 11:09:32.475');
INSERT INTO `device_sensor_record` VALUES (84530, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:09:32.475', '2026-11-02 11:09:32.475');
INSERT INTO `device_sensor_record` VALUES (84531, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 402, 'ppm', NULL, NULL, '2026-11-02 11:09:32.475', '2026-11-02 11:09:32.475');
INSERT INTO `device_sensor_record` VALUES (84532, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 788, 'lx', NULL, NULL, '2026-11-02 11:09:32.475', '2026-11-02 11:09:32.475');
INSERT INTO `device_sensor_record` VALUES (84533, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:09:32.475', '2026-11-02 11:09:32.475');
INSERT INTO `device_sensor_record` VALUES (84534, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.3, '℃', NULL, NULL, '2026-11-02 11:09:32.475', '2026-11-02 11:09:32.475');
INSERT INTO `device_sensor_record` VALUES (84535, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.1, '℃', NULL, NULL, '2026-11-02 11:09:32.475', '2026-11-02 11:09:32.475');
INSERT INTO `device_sensor_record` VALUES (84536, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-02 11:09:32.475', '2026-11-02 11:09:32.475');
INSERT INTO `device_sensor_record` VALUES (84537, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 176696, 'bytes', NULL, NULL, '2026-11-02 11:09:32.475', '2026-11-02 11:09:32.475');
INSERT INTO `device_sensor_record` VALUES (84538, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-02 11:09:42.484', '2026-11-02 11:09:42.484');
INSERT INTO `device_sensor_record` VALUES (84539, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.4, '%', NULL, NULL, '2026-11-02 11:09:42.484', '2026-11-02 11:09:42.484');
INSERT INTO `device_sensor_record` VALUES (84540, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35, 'μg/m³', NULL, NULL, '2026-11-02 11:09:42.484', '2026-11-02 11:09:42.484');
INSERT INTO `device_sensor_record` VALUES (84541, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 565.1, 'ppm', NULL, NULL, '2026-11-02 11:09:42.484', '2026-11-02 11:09:42.484');
INSERT INTO `device_sensor_record` VALUES (84542, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 173.4, 'lx', NULL, NULL, '2026-11-02 11:09:42.484', '2026-11-02 11:09:42.484');
INSERT INTO `device_sensor_record` VALUES (84543, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.8, '℃', NULL, NULL, '2026-11-02 11:09:42.484', '2026-11-02 11:09:42.484');
INSERT INTO `device_sensor_record` VALUES (84544, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:09:42.484', '2026-11-02 11:09:42.484');
INSERT INTO `device_sensor_record` VALUES (84545, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.4, '℃', NULL, NULL, '2026-11-02 11:09:42.484', '2026-11-02 11:09:42.484');
INSERT INTO `device_sensor_record` VALUES (84546, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-02 11:09:42.484', '2026-11-02 11:09:42.484');
INSERT INTO `device_sensor_record` VALUES (84547, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 161719, 'bytes', NULL, NULL, '2026-11-02 11:09:42.484', '2026-11-02 11:09:42.484');
INSERT INTO `device_sensor_record` VALUES (84548, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.8, '℃', NULL, NULL, '2026-11-02 11:09:52.498', '2026-11-02 11:09:52.498');
INSERT INTO `device_sensor_record` VALUES (84549, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.2, '%', NULL, NULL, '2026-11-02 11:09:52.498', '2026-11-02 11:09:52.498');
INSERT INTO `device_sensor_record` VALUES (84550, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.3, 'μg/m³', NULL, NULL, '2026-11-02 11:09:52.498', '2026-11-02 11:09:52.498');
INSERT INTO `device_sensor_record` VALUES (84551, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 407.2, 'ppm', NULL, NULL, '2026-11-02 11:09:52.498', '2026-11-02 11:09:52.498');
INSERT INTO `device_sensor_record` VALUES (84552, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 706.9, 'lx', NULL, NULL, '2026-11-02 11:09:52.498', '2026-11-02 11:09:52.498');
INSERT INTO `device_sensor_record` VALUES (84553, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-02 11:09:52.498', '2026-11-02 11:09:52.498');
INSERT INTO `device_sensor_record` VALUES (84554, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:09:52.498', '2026-11-02 11:09:52.498');
INSERT INTO `device_sensor_record` VALUES (84555, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.1, '℃', NULL, NULL, '2026-11-02 11:09:52.498', '2026-11-02 11:09:52.498');
INSERT INTO `device_sensor_record` VALUES (84556, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:09:52.498', '2026-11-02 11:09:52.498');
INSERT INTO `device_sensor_record` VALUES (84557, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 160920, 'bytes', NULL, NULL, '2026-11-02 11:09:52.498', '2026-11-02 11:09:52.498');
INSERT INTO `device_sensor_record` VALUES (84558, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 28, '℃', NULL, NULL, '2026-11-02 11:10:02.512', '2026-11-02 11:10:02.512');
INSERT INTO `device_sensor_record` VALUES (84559, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.8, '%', NULL, NULL, '2026-11-02 11:10:02.512', '2026-11-02 11:10:02.512');
INSERT INTO `device_sensor_record` VALUES (84560, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 37.6, 'μg/m³', NULL, NULL, '2026-11-02 11:10:02.512', '2026-11-02 11:10:02.512');
INSERT INTO `device_sensor_record` VALUES (84561, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 493.6, 'ppm', NULL, NULL, '2026-11-02 11:10:02.512', '2026-11-02 11:10:02.512');
INSERT INTO `device_sensor_record` VALUES (84562, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 237.6, 'lx', NULL, NULL, '2026-11-02 11:10:02.512', '2026-11-02 11:10:02.512');
INSERT INTO `device_sensor_record` VALUES (84563, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.4, '℃', NULL, NULL, '2026-11-02 11:10:02.512', '2026-11-02 11:10:02.512');
INSERT INTO `device_sensor_record` VALUES (84564, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.6, '℃', NULL, NULL, '2026-11-02 11:10:02.512', '2026-11-02 11:10:02.512');
INSERT INTO `device_sensor_record` VALUES (84565, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.7, '℃', NULL, NULL, '2026-11-02 11:10:02.512', '2026-11-02 11:10:02.512');
INSERT INTO `device_sensor_record` VALUES (84566, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-02 11:10:02.512', '2026-11-02 11:10:02.512');
INSERT INTO `device_sensor_record` VALUES (84567, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 156156, 'bytes', NULL, NULL, '2026-11-02 11:10:02.512', '2026-11-02 11:10:02.512');
INSERT INTO `device_sensor_record` VALUES (84568, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.8, '℃', NULL, NULL, '2026-11-02 11:10:12.527', '2026-11-02 11:10:12.527');
INSERT INTO `device_sensor_record` VALUES (84569, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.9, '%', NULL, NULL, '2026-11-02 11:10:12.527', '2026-11-02 11:10:12.527');
INSERT INTO `device_sensor_record` VALUES (84570, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 29.2, 'μg/m³', NULL, NULL, '2026-11-02 11:10:12.527', '2026-11-02 11:10:12.527');
INSERT INTO `device_sensor_record` VALUES (84571, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 589.4, 'ppm', NULL, NULL, '2026-11-02 11:10:12.527', '2026-11-02 11:10:12.527');
INSERT INTO `device_sensor_record` VALUES (84572, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 508.4, 'lx', NULL, NULL, '2026-11-02 11:10:12.527', '2026-11-02 11:10:12.527');
INSERT INTO `device_sensor_record` VALUES (84573, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-02 11:10:12.527', '2026-11-02 11:10:12.527');
INSERT INTO `device_sensor_record` VALUES (84574, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.4, '℃', NULL, NULL, '2026-11-02 11:10:12.527', '2026-11-02 11:10:12.527');
INSERT INTO `device_sensor_record` VALUES (84575, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.7, '℃', NULL, NULL, '2026-11-02 11:10:12.527', '2026-11-02 11:10:12.527');
INSERT INTO `device_sensor_record` VALUES (84576, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.22, 'V', NULL, NULL, '2026-11-02 11:10:12.527', '2026-11-02 11:10:12.527');
INSERT INTO `device_sensor_record` VALUES (84577, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 162367, 'bytes', NULL, NULL, '2026-11-02 11:10:12.527', '2026-11-02 11:10:12.527');
INSERT INTO `device_sensor_record` VALUES (84578, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:10:22.537', '2026-11-02 11:10:22.537');
INSERT INTO `device_sensor_record` VALUES (84579, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.2, '%', NULL, NULL, '2026-11-02 11:10:22.537', '2026-11-02 11:10:22.537');
INSERT INTO `device_sensor_record` VALUES (84580, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:10:22.537', '2026-11-02 11:10:22.537');
INSERT INTO `device_sensor_record` VALUES (84581, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 530.8, 'ppm', NULL, NULL, '2026-11-02 11:10:22.537', '2026-11-02 11:10:22.537');
INSERT INTO `device_sensor_record` VALUES (84582, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 544.5, 'lx', NULL, NULL, '2026-11-02 11:10:22.537', '2026-11-02 11:10:22.537');
INSERT INTO `device_sensor_record` VALUES (84583, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.4, '℃', NULL, NULL, '2026-11-02 11:10:22.537', '2026-11-02 11:10:22.537');
INSERT INTO `device_sensor_record` VALUES (84584, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.7, '℃', NULL, NULL, '2026-11-02 11:10:22.537', '2026-11-02 11:10:22.537');
INSERT INTO `device_sensor_record` VALUES (84585, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.7, '℃', NULL, NULL, '2026-11-02 11:10:22.537', '2026-11-02 11:10:22.537');
INSERT INTO `device_sensor_record` VALUES (84586, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:10:22.537', '2026-11-02 11:10:22.537');
INSERT INTO `device_sensor_record` VALUES (84587, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 128345, 'bytes', NULL, NULL, '2026-11-02 11:10:22.537', '2026-11-02 11:10:22.537');
INSERT INTO `device_sensor_record` VALUES (84588, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.9, '℃', NULL, NULL, '2026-11-02 11:10:32.552', '2026-11-02 11:10:32.552');
INSERT INTO `device_sensor_record` VALUES (84589, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.9, '%', NULL, NULL, '2026-11-02 11:10:32.552', '2026-11-02 11:10:32.552');
INSERT INTO `device_sensor_record` VALUES (84590, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 34.7, 'μg/m³', NULL, NULL, '2026-11-02 11:10:32.552', '2026-11-02 11:10:32.552');
INSERT INTO `device_sensor_record` VALUES (84591, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 470.4, 'ppm', NULL, NULL, '2026-11-02 11:10:32.552', '2026-11-02 11:10:32.552');
INSERT INTO `device_sensor_record` VALUES (84592, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 246.5, 'lx', NULL, NULL, '2026-11-02 11:10:32.552', '2026-11-02 11:10:32.552');
INSERT INTO `device_sensor_record` VALUES (84593, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-02 11:10:32.552', '2026-11-02 11:10:32.552');
INSERT INTO `device_sensor_record` VALUES (84594, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.8, '℃', NULL, NULL, '2026-11-02 11:10:32.552', '2026-11-02 11:10:32.552');
INSERT INTO `device_sensor_record` VALUES (84595, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.9, '℃', NULL, NULL, '2026-11-02 11:10:32.552', '2026-11-02 11:10:32.552');
INSERT INTO `device_sensor_record` VALUES (84596, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-02 11:10:32.552', '2026-11-02 11:10:32.552');
INSERT INTO `device_sensor_record` VALUES (84597, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 133977, 'bytes', NULL, NULL, '2026-11-02 11:10:32.552', '2026-11-02 11:10:32.552');
INSERT INTO `device_sensor_record` VALUES (84598, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-02 11:10:42.556', '2026-11-02 11:10:42.556');
INSERT INTO `device_sensor_record` VALUES (84599, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.2, '%', NULL, NULL, '2026-11-02 11:10:42.556', '2026-11-02 11:10:42.556');
INSERT INTO `device_sensor_record` VALUES (84600, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 27.1, 'μg/m³', NULL, NULL, '2026-11-02 11:10:42.556', '2026-11-02 11:10:42.556');
INSERT INTO `device_sensor_record` VALUES (84601, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 507.6, 'ppm', NULL, NULL, '2026-11-02 11:10:42.556', '2026-11-02 11:10:42.556');
INSERT INTO `device_sensor_record` VALUES (84602, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 204.6, 'lx', NULL, NULL, '2026-11-02 11:10:42.556', '2026-11-02 11:10:42.556');
INSERT INTO `device_sensor_record` VALUES (84603, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-02 11:10:42.556', '2026-11-02 11:10:42.556');
INSERT INTO `device_sensor_record` VALUES (84604, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-02 11:10:42.556', '2026-11-02 11:10:42.556');
INSERT INTO `device_sensor_record` VALUES (84605, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.3, '℃', NULL, NULL, '2026-11-02 11:10:42.556', '2026-11-02 11:10:42.556');
INSERT INTO `device_sensor_record` VALUES (84606, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-02 11:10:42.556', '2026-11-02 11:10:42.556');
INSERT INTO `device_sensor_record` VALUES (84607, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 137284, 'bytes', NULL, NULL, '2026-11-02 11:10:42.556', '2026-11-02 11:10:42.556');
INSERT INTO `device_sensor_record` VALUES (84608, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.6, '℃', NULL, NULL, '2026-11-02 11:10:52.563', '2026-11-02 11:10:52.563');
INSERT INTO `device_sensor_record` VALUES (84609, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.9, '%', NULL, NULL, '2026-11-02 11:10:52.563', '2026-11-02 11:10:52.563');
INSERT INTO `device_sensor_record` VALUES (84610, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 22.9, 'μg/m³', NULL, NULL, '2026-11-02 11:10:52.563', '2026-11-02 11:10:52.563');
INSERT INTO `device_sensor_record` VALUES (84611, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 499.2, 'ppm', NULL, NULL, '2026-11-02 11:10:52.563', '2026-11-02 11:10:52.563');
INSERT INTO `device_sensor_record` VALUES (84612, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 187.1, 'lx', NULL, NULL, '2026-11-02 11:10:52.563', '2026-11-02 11:10:52.563');
INSERT INTO `device_sensor_record` VALUES (84613, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-02 11:10:52.563', '2026-11-02 11:10:52.563');
INSERT INTO `device_sensor_record` VALUES (84614, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.5, '℃', NULL, NULL, '2026-11-02 11:10:52.563', '2026-11-02 11:10:52.563');
INSERT INTO `device_sensor_record` VALUES (84615, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.6, '℃', NULL, NULL, '2026-11-02 11:10:52.563', '2026-11-02 11:10:52.563');
INSERT INTO `device_sensor_record` VALUES (84616, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-02 11:10:52.563', '2026-11-02 11:10:52.563');
INSERT INTO `device_sensor_record` VALUES (84617, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 156328, 'bytes', NULL, NULL, '2026-11-02 11:10:52.563', '2026-11-02 11:10:52.563');
INSERT INTO `device_sensor_record` VALUES (84618, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-02 11:11:02.571', '2026-11-02 11:11:02.571');
INSERT INTO `device_sensor_record` VALUES (84619, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.8, '%', NULL, NULL, '2026-11-02 11:11:02.571', '2026-11-02 11:11:02.571');
INSERT INTO `device_sensor_record` VALUES (84620, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 36.4, 'μg/m³', NULL, NULL, '2026-11-02 11:11:02.571', '2026-11-02 11:11:02.571');
INSERT INTO `device_sensor_record` VALUES (84621, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 496.2, 'ppm', NULL, NULL, '2026-11-02 11:11:02.571', '2026-11-02 11:11:02.571');
INSERT INTO `device_sensor_record` VALUES (84622, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 771.1, 'lx', NULL, NULL, '2026-11-02 11:11:02.571', '2026-11-02 11:11:02.571');
INSERT INTO `device_sensor_record` VALUES (84623, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.6, '℃', NULL, NULL, '2026-11-02 11:11:02.571', '2026-11-02 11:11:02.571');
INSERT INTO `device_sensor_record` VALUES (84624, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:11:02.571', '2026-11-02 11:11:02.571');
INSERT INTO `device_sensor_record` VALUES (84625, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.1, '℃', NULL, NULL, '2026-11-02 11:11:02.571', '2026-11-02 11:11:02.571');
INSERT INTO `device_sensor_record` VALUES (84626, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:11:02.571', '2026-11-02 11:11:02.571');
INSERT INTO `device_sensor_record` VALUES (84627, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 139864, 'bytes', NULL, NULL, '2026-11-02 11:11:02.571', '2026-11-02 11:11:02.571');
INSERT INTO `device_sensor_record` VALUES (84628, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'slave-1-temperature', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:11:31.742', '2026-11-02 11:11:31.761');
INSERT INTO `device_sensor_record` VALUES (84629, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'slave-2-humidity', 'humidity', 55, '%', NULL, NULL, '2026-11-02 11:11:31.742', '2026-11-02 11:11:31.830');
INSERT INTO `device_sensor_record` VALUES (84630, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'slave-3-pm25', 'pm25', 35, 'μg/m³', NULL, NULL, '2026-11-02 11:11:31.742', '2026-11-02 11:11:31.831');
INSERT INTO `device_sensor_record` VALUES (84631, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'slave-4-co2', 'co2', 450, 'ppm', NULL, NULL, '2026-11-02 11:11:31.742', '2026-11-02 11:11:31.831');
INSERT INTO `device_sensor_record` VALUES (84632, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'slave-5-illuminance', 'illuminance', 300, 'lx', NULL, NULL, '2026-11-02 11:11:31.742', '2026-11-02 11:11:31.831');
INSERT INTO `device_sensor_record` VALUES (84633, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'slave-6-temperature-ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:11:31.742', '2026-11-02 11:11:31.832');
INSERT INTO `device_sensor_record` VALUES (84634, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'slave-6-temperature-ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 11:11:31.742', '2026-11-02 11:11:31.833');
INSERT INTO `device_sensor_record` VALUES (84635, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.5, '℃', NULL, NULL, '2026-11-02 11:11:32.582', '2026-11-02 11:11:32.582');
INSERT INTO `device_sensor_record` VALUES (84636, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62.8, '%', NULL, NULL, '2026-11-02 11:11:32.582', '2026-11-02 11:11:32.582');
INSERT INTO `device_sensor_record` VALUES (84637, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 45.5, 'μg/m³', NULL, NULL, '2026-11-02 11:11:32.582', '2026-11-02 11:11:32.582');
INSERT INTO `device_sensor_record` VALUES (84638, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 474.8, 'ppm', NULL, NULL, '2026-11-02 11:11:32.582', '2026-11-02 11:11:32.582');
INSERT INTO `device_sensor_record` VALUES (84639, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 418, 'lx', NULL, NULL, '2026-11-02 11:11:32.582', '2026-11-02 11:11:32.582');
INSERT INTO `device_sensor_record` VALUES (84640, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.9, '℃', NULL, NULL, '2026-11-02 11:11:32.582', '2026-11-02 11:11:32.582');
INSERT INTO `device_sensor_record` VALUES (84641, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:11:32.582', '2026-11-02 11:11:32.582');
INSERT INTO `device_sensor_record` VALUES (84642, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.8, '℃', NULL, NULL, '2026-11-02 11:11:32.582', '2026-11-02 11:11:32.582');
INSERT INTO `device_sensor_record` VALUES (84643, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.22, 'V', NULL, NULL, '2026-11-02 11:11:32.582', '2026-11-02 11:11:32.582');
INSERT INTO `device_sensor_record` VALUES (84644, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 173243, 'bytes', NULL, NULL, '2026-11-02 11:11:32.582', '2026-11-02 11:11:32.582');
INSERT INTO `device_sensor_record` VALUES (84645, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.6, '℃', NULL, NULL, '2026-11-02 11:11:42.642', '2026-11-02 11:11:42.642');
INSERT INTO `device_sensor_record` VALUES (84646, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.6, '%', NULL, NULL, '2026-11-02 11:11:42.642', '2026-11-02 11:11:42.642');
INSERT INTO `device_sensor_record` VALUES (84647, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 36.9, 'μg/m³', NULL, NULL, '2026-11-02 11:11:42.642', '2026-11-02 11:11:42.642');
INSERT INTO `device_sensor_record` VALUES (84648, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 429, 'ppm', NULL, NULL, '2026-11-02 11:11:42.642', '2026-11-02 11:11:42.642');
INSERT INTO `device_sensor_record` VALUES (84649, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 758, 'lx', NULL, NULL, '2026-11-02 11:11:42.642', '2026-11-02 11:11:42.642');
INSERT INTO `device_sensor_record` VALUES (84650, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-02 11:11:42.642', '2026-11-02 11:11:42.642');
INSERT INTO `device_sensor_record` VALUES (84651, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 11:11:42.642', '2026-11-02 11:11:42.642');
INSERT INTO `device_sensor_record` VALUES (84652, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.1, '℃', NULL, NULL, '2026-11-02 11:11:42.642', '2026-11-02 11:11:42.642');
INSERT INTO `device_sensor_record` VALUES (84653, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-02 11:11:42.642', '2026-11-02 11:11:42.642');
INSERT INTO `device_sensor_record` VALUES (84654, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 136099, 'bytes', NULL, NULL, '2026-11-02 11:11:42.642', '2026-11-02 11:11:42.642');
INSERT INTO `device_sensor_record` VALUES (84655, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27, '℃', NULL, NULL, '2026-11-02 11:11:52.639', '2026-11-02 11:11:52.639');
INSERT INTO `device_sensor_record` VALUES (84656, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.2, '%', NULL, NULL, '2026-11-02 11:11:52.639', '2026-11-02 11:11:52.639');
INSERT INTO `device_sensor_record` VALUES (84657, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 38.6, 'μg/m³', NULL, NULL, '2026-11-02 11:11:52.639', '2026-11-02 11:11:52.639');
INSERT INTO `device_sensor_record` VALUES (84658, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 559.9, 'ppm', NULL, NULL, '2026-11-02 11:11:52.639', '2026-11-02 11:11:52.639');
INSERT INTO `device_sensor_record` VALUES (84659, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 224.5, 'lx', NULL, NULL, '2026-11-02 11:11:52.639', '2026-11-02 11:11:52.639');
INSERT INTO `device_sensor_record` VALUES (84660, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-02 11:11:52.639', '2026-11-02 11:11:52.639');
INSERT INTO `device_sensor_record` VALUES (84661, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-02 11:11:52.639', '2026-11-02 11:11:52.639');
INSERT INTO `device_sensor_record` VALUES (84662, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53, '℃', NULL, NULL, '2026-11-02 11:11:52.639', '2026-11-02 11:11:52.639');
INSERT INTO `device_sensor_record` VALUES (84663, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-02 11:11:52.639', '2026-11-02 11:11:52.639');
INSERT INTO `device_sensor_record` VALUES (84664, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 140855, 'bytes', NULL, NULL, '2026-11-02 11:11:52.639', '2026-11-02 11:11:52.639');
INSERT INTO `device_sensor_record` VALUES (84665, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:12:02.645', '2026-11-02 11:12:02.645');
INSERT INTO `device_sensor_record` VALUES (84666, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.9, '%', NULL, NULL, '2026-11-02 11:12:02.645', '2026-11-02 11:12:02.645');
INSERT INTO `device_sensor_record` VALUES (84667, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:12:02.645', '2026-11-02 11:12:02.645');
INSERT INTO `device_sensor_record` VALUES (84668, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 444.4, 'ppm', NULL, NULL, '2026-11-02 11:12:02.645', '2026-11-02 11:12:02.645');
INSERT INTO `device_sensor_record` VALUES (84669, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 445.5, 'lx', NULL, NULL, '2026-11-02 11:12:02.645', '2026-11-02 11:12:02.645');
INSERT INTO `device_sensor_record` VALUES (84670, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.7, '℃', NULL, NULL, '2026-11-02 11:12:02.645', '2026-11-02 11:12:02.645');
INSERT INTO `device_sensor_record` VALUES (84671, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:12:02.645', '2026-11-02 11:12:02.645');
INSERT INTO `device_sensor_record` VALUES (84672, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.4, '℃', NULL, NULL, '2026-11-02 11:12:02.645', '2026-11-02 11:12:02.645');
INSERT INTO `device_sensor_record` VALUES (84673, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.22, 'V', NULL, NULL, '2026-11-02 11:12:02.645', '2026-11-02 11:12:02.645');
INSERT INTO `device_sensor_record` VALUES (84674, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 148566, 'bytes', NULL, NULL, '2026-11-02 11:12:02.645', '2026-11-02 11:12:02.645');
INSERT INTO `device_sensor_record` VALUES (84675, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.3, '℃', NULL, NULL, '2026-11-02 11:12:12.664', '2026-11-02 11:12:12.664');
INSERT INTO `device_sensor_record` VALUES (84676, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.1, '%', NULL, NULL, '2026-11-02 11:12:12.664', '2026-11-02 11:12:12.664');
INSERT INTO `device_sensor_record` VALUES (84677, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.2, 'μg/m³', NULL, NULL, '2026-11-02 11:12:12.664', '2026-11-02 11:12:12.664');
INSERT INTO `device_sensor_record` VALUES (84678, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 556.6, 'ppm', NULL, NULL, '2026-11-02 11:12:12.664', '2026-11-02 11:12:12.664');
INSERT INTO `device_sensor_record` VALUES (84679, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 535.1, 'lx', NULL, NULL, '2026-11-02 11:12:12.664', '2026-11-02 11:12:12.664');
INSERT INTO `device_sensor_record` VALUES (84680, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20, '℃', NULL, NULL, '2026-11-02 11:12:12.664', '2026-11-02 11:12:12.664');
INSERT INTO `device_sensor_record` VALUES (84681, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-02 11:12:12.664', '2026-11-02 11:12:12.664');
INSERT INTO `device_sensor_record` VALUES (84682, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.6, '℃', NULL, NULL, '2026-11-02 11:12:12.664', '2026-11-02 11:12:12.664');
INSERT INTO `device_sensor_record` VALUES (84683, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-02 11:12:12.664', '2026-11-02 11:12:12.664');
INSERT INTO `device_sensor_record` VALUES (84684, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 174936, 'bytes', NULL, NULL, '2026-11-02 11:12:12.664', '2026-11-02 11:12:12.664');
INSERT INTO `device_sensor_record` VALUES (84685, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:12:22.671', '2026-11-02 11:12:22.671');
INSERT INTO `device_sensor_record` VALUES (84686, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.6, '%', NULL, NULL, '2026-11-02 11:12:22.671', '2026-11-02 11:12:22.671');
INSERT INTO `device_sensor_record` VALUES (84687, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35.2, 'μg/m³', NULL, NULL, '2026-11-02 11:12:22.671', '2026-11-02 11:12:22.671');
INSERT INTO `device_sensor_record` VALUES (84688, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 556.5, 'ppm', NULL, NULL, '2026-11-02 11:12:22.671', '2026-11-02 11:12:22.671');
INSERT INTO `device_sensor_record` VALUES (84689, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 139.6, 'lx', NULL, NULL, '2026-11-02 11:12:22.671', '2026-11-02 11:12:22.671');
INSERT INTO `device_sensor_record` VALUES (84690, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.6, '℃', NULL, NULL, '2026-11-02 11:12:22.671', '2026-11-02 11:12:22.671');
INSERT INTO `device_sensor_record` VALUES (84691, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.4, '℃', NULL, NULL, '2026-11-02 11:12:22.671', '2026-11-02 11:12:22.671');
INSERT INTO `device_sensor_record` VALUES (84692, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.9, '℃', NULL, NULL, '2026-11-02 11:12:22.671', '2026-11-02 11:12:22.671');
INSERT INTO `device_sensor_record` VALUES (84693, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-02 11:12:22.671', '2026-11-02 11:12:22.671');
INSERT INTO `device_sensor_record` VALUES (84694, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 161658, 'bytes', NULL, NULL, '2026-11-02 11:12:22.671', '2026-11-02 11:12:22.671');
INSERT INTO `device_sensor_record` VALUES (84695, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.8, '℃', NULL, NULL, '2026-11-02 11:12:32.682', '2026-11-02 11:12:32.682');
INSERT INTO `device_sensor_record` VALUES (84696, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 69.5, '%', NULL, NULL, '2026-11-02 11:12:32.682', '2026-11-02 11:12:32.682');
INSERT INTO `device_sensor_record` VALUES (84697, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.4, 'μg/m³', NULL, NULL, '2026-11-02 11:12:32.682', '2026-11-02 11:12:32.682');
INSERT INTO `device_sensor_record` VALUES (84698, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 550.6, 'ppm', NULL, NULL, '2026-11-02 11:12:32.682', '2026-11-02 11:12:32.682');
INSERT INTO `device_sensor_record` VALUES (84699, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 653.8, 'lx', NULL, NULL, '2026-11-02 11:12:32.682', '2026-11-02 11:12:32.682');
INSERT INTO `device_sensor_record` VALUES (84700, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:12:32.682', '2026-11-02 11:12:32.682');
INSERT INTO `device_sensor_record` VALUES (84701, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-02 11:12:32.682', '2026-11-02 11:12:32.682');
INSERT INTO `device_sensor_record` VALUES (84702, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.9, '℃', NULL, NULL, '2026-11-02 11:12:32.682', '2026-11-02 11:12:32.682');
INSERT INTO `device_sensor_record` VALUES (84703, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-02 11:12:32.682', '2026-11-02 11:12:32.682');
INSERT INTO `device_sensor_record` VALUES (84704, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 149154, 'bytes', NULL, NULL, '2026-11-02 11:12:32.682', '2026-11-02 11:12:32.682');
INSERT INTO `device_sensor_record` VALUES (84705, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27, '℃', NULL, NULL, '2026-11-02 11:12:42.691', '2026-11-02 11:12:42.691');
INSERT INTO `device_sensor_record` VALUES (84706, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.7, '%', NULL, NULL, '2026-11-02 11:12:42.691', '2026-11-02 11:12:42.691');
INSERT INTO `device_sensor_record` VALUES (84707, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 24, 'μg/m³', NULL, NULL, '2026-11-02 11:12:42.691', '2026-11-02 11:12:42.691');
INSERT INTO `device_sensor_record` VALUES (84708, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 415.2, 'ppm', NULL, NULL, '2026-11-02 11:12:42.691', '2026-11-02 11:12:42.691');
INSERT INTO `device_sensor_record` VALUES (84709, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 725.2, 'lx', NULL, NULL, '2026-11-02 11:12:42.691', '2026-11-02 11:12:42.691');
INSERT INTO `device_sensor_record` VALUES (84710, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:12:42.691', '2026-11-02 11:12:42.691');
INSERT INTO `device_sensor_record` VALUES (84711, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:12:42.691', '2026-11-02 11:12:42.691');
INSERT INTO `device_sensor_record` VALUES (84712, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.1, '℃', NULL, NULL, '2026-11-02 11:12:42.691', '2026-11-02 11:12:42.691');
INSERT INTO `device_sensor_record` VALUES (84713, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:12:42.691', '2026-11-02 11:12:42.691');
INSERT INTO `device_sensor_record` VALUES (84714, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 121329, 'bytes', NULL, NULL, '2026-11-02 11:12:42.691', '2026-11-02 11:12:42.691');
INSERT INTO `device_sensor_record` VALUES (84715, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:12:52.702', '2026-11-02 11:12:52.702');
INSERT INTO `device_sensor_record` VALUES (84716, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.4, '%', NULL, NULL, '2026-11-02 11:12:52.702', '2026-11-02 11:12:52.702');
INSERT INTO `device_sensor_record` VALUES (84717, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:12:52.702', '2026-11-02 11:12:52.702');
INSERT INTO `device_sensor_record` VALUES (84718, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 424.2, 'ppm', NULL, NULL, '2026-11-02 11:12:52.702', '2026-11-02 11:12:52.702');
INSERT INTO `device_sensor_record` VALUES (84719, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 705.7, 'lx', NULL, NULL, '2026-11-02 11:12:52.702', '2026-11-02 11:12:52.702');
INSERT INTO `device_sensor_record` VALUES (84720, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-02 11:12:52.702', '2026-11-02 11:12:52.702');
INSERT INTO `device_sensor_record` VALUES (84721, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-02 11:12:52.702', '2026-11-02 11:12:52.702');
INSERT INTO `device_sensor_record` VALUES (84722, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.3, '℃', NULL, NULL, '2026-11-02 11:12:52.702', '2026-11-02 11:12:52.702');
INSERT INTO `device_sensor_record` VALUES (84723, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-02 11:12:52.702', '2026-11-02 11:12:52.702');
INSERT INTO `device_sensor_record` VALUES (84724, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 121791, 'bytes', NULL, NULL, '2026-11-02 11:12:52.702', '2026-11-02 11:12:52.702');
INSERT INTO `device_sensor_record` VALUES (84725, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.4, '℃', NULL, NULL, '2026-11-02 11:13:02.718', '2026-11-02 11:13:02.718');
INSERT INTO `device_sensor_record` VALUES (84726, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.5, '%', NULL, NULL, '2026-11-02 11:13:02.718', '2026-11-02 11:13:02.718');
INSERT INTO `device_sensor_record` VALUES (84727, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 44.7, 'μg/m³', NULL, NULL, '2026-11-02 11:13:02.718', '2026-11-02 11:13:02.718');
INSERT INTO `device_sensor_record` VALUES (84728, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 591.7, 'ppm', NULL, NULL, '2026-11-02 11:13:02.718', '2026-11-02 11:13:02.718');
INSERT INTO `device_sensor_record` VALUES (84729, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 334, 'lx', NULL, NULL, '2026-11-02 11:13:02.718', '2026-11-02 11:13:02.718');
INSERT INTO `device_sensor_record` VALUES (84730, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.7, '℃', NULL, NULL, '2026-11-02 11:13:02.718', '2026-11-02 11:13:02.718');
INSERT INTO `device_sensor_record` VALUES (84731, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-02 11:13:02.718', '2026-11-02 11:13:02.718');
INSERT INTO `device_sensor_record` VALUES (84732, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.7, '℃', NULL, NULL, '2026-11-02 11:13:02.718', '2026-11-02 11:13:02.718');
INSERT INTO `device_sensor_record` VALUES (84733, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-02 11:13:02.718', '2026-11-02 11:13:02.718');
INSERT INTO `device_sensor_record` VALUES (84734, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 156436, 'bytes', NULL, NULL, '2026-11-02 11:13:02.718', '2026-11-02 11:13:02.718');
INSERT INTO `device_sensor_record` VALUES (84735, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.8, '℃', NULL, NULL, '2026-11-02 11:13:12.719', '2026-11-02 11:13:12.719');
INSERT INTO `device_sensor_record` VALUES (84736, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.7, '%', NULL, NULL, '2026-11-02 11:13:12.719', '2026-11-02 11:13:12.719');
INSERT INTO `device_sensor_record` VALUES (84737, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 38.9, 'μg/m³', NULL, NULL, '2026-11-02 11:13:12.719', '2026-11-02 11:13:12.719');
INSERT INTO `device_sensor_record` VALUES (84738, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 473.5, 'ppm', NULL, NULL, '2026-11-02 11:13:12.719', '2026-11-02 11:13:12.719');
INSERT INTO `device_sensor_record` VALUES (84739, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 536.4, 'lx', NULL, NULL, '2026-11-02 11:13:12.719', '2026-11-02 11:13:12.719');
INSERT INTO `device_sensor_record` VALUES (84740, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-02 11:13:12.719', '2026-11-02 11:13:12.719');
INSERT INTO `device_sensor_record` VALUES (84741, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 11:13:12.719', '2026-11-02 11:13:12.719');
INSERT INTO `device_sensor_record` VALUES (84742, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.5, '℃', NULL, NULL, '2026-11-02 11:13:12.719', '2026-11-02 11:13:12.719');
INSERT INTO `device_sensor_record` VALUES (84743, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.29, 'V', NULL, NULL, '2026-11-02 11:13:12.719', '2026-11-02 11:13:12.719');
INSERT INTO `device_sensor_record` VALUES (84744, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 166715, 'bytes', NULL, NULL, '2026-11-02 11:13:12.719', '2026-11-02 11:13:12.719');
INSERT INTO `device_sensor_record` VALUES (84745, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-02 11:13:22.730', '2026-11-02 11:13:22.730');
INSERT INTO `device_sensor_record` VALUES (84746, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.6, '%', NULL, NULL, '2026-11-02 11:13:22.730', '2026-11-02 11:13:22.730');
INSERT INTO `device_sensor_record` VALUES (84747, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 50, 'μg/m³', NULL, NULL, '2026-11-02 11:13:22.730', '2026-11-02 11:13:22.730');
INSERT INTO `device_sensor_record` VALUES (84748, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 461.7, 'ppm', NULL, NULL, '2026-11-02 11:13:22.730', '2026-11-02 11:13:22.730');
INSERT INTO `device_sensor_record` VALUES (84749, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 419.8, 'lx', NULL, NULL, '2026-11-02 11:13:22.730', '2026-11-02 11:13:22.730');
INSERT INTO `device_sensor_record` VALUES (84750, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.3, '℃', NULL, NULL, '2026-11-02 11:13:22.730', '2026-11-02 11:13:22.730');
INSERT INTO `device_sensor_record` VALUES (84751, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-02 11:13:22.730', '2026-11-02 11:13:22.730');
INSERT INTO `device_sensor_record` VALUES (84752, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.6, '℃', NULL, NULL, '2026-11-02 11:13:22.730', '2026-11-02 11:13:22.730');
INSERT INTO `device_sensor_record` VALUES (84753, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:13:22.730', '2026-11-02 11:13:22.730');
INSERT INTO `device_sensor_record` VALUES (84754, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 136834, 'bytes', NULL, NULL, '2026-11-02 11:13:22.730', '2026-11-02 11:13:22.730');
INSERT INTO `device_sensor_record` VALUES (84755, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.1, '℃', NULL, NULL, '2026-11-02 11:13:32.731', '2026-11-02 11:13:32.731');
INSERT INTO `device_sensor_record` VALUES (84756, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55, '%', NULL, NULL, '2026-11-02 11:13:32.731', '2026-11-02 11:13:32.731');
INSERT INTO `device_sensor_record` VALUES (84757, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 33.8, 'μg/m³', NULL, NULL, '2026-11-02 11:13:32.731', '2026-11-02 11:13:32.731');
INSERT INTO `device_sensor_record` VALUES (84758, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 466.9, 'ppm', NULL, NULL, '2026-11-02 11:13:32.731', '2026-11-02 11:13:32.731');
INSERT INTO `device_sensor_record` VALUES (84759, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 701.3, 'lx', NULL, NULL, '2026-11-02 11:13:32.731', '2026-11-02 11:13:32.731');
INSERT INTO `device_sensor_record` VALUES (84760, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-02 11:13:32.731', '2026-11-02 11:13:32.731');
INSERT INTO `device_sensor_record` VALUES (84761, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:13:32.731', '2026-11-02 11:13:32.731');
INSERT INTO `device_sensor_record` VALUES (84762, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.5, '℃', NULL, NULL, '2026-11-02 11:13:32.731', '2026-11-02 11:13:32.731');
INSERT INTO `device_sensor_record` VALUES (84763, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-02 11:13:32.731', '2026-11-02 11:13:32.731');
INSERT INTO `device_sensor_record` VALUES (84764, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 127540, 'bytes', NULL, NULL, '2026-11-02 11:13:32.731', '2026-11-02 11:13:32.731');
INSERT INTO `device_sensor_record` VALUES (84765, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:13:42.743', '2026-11-02 11:13:42.743');
INSERT INTO `device_sensor_record` VALUES (84766, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.8, '%', NULL, NULL, '2026-11-02 11:13:42.743', '2026-11-02 11:13:42.743');
INSERT INTO `device_sensor_record` VALUES (84767, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:13:42.743', '2026-11-02 11:13:42.743');
INSERT INTO `device_sensor_record` VALUES (84768, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 588, 'ppm', NULL, NULL, '2026-11-02 11:13:42.743', '2026-11-02 11:13:42.743');
INSERT INTO `device_sensor_record` VALUES (84769, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 673.1, 'lx', NULL, NULL, '2026-11-02 11:13:42.743', '2026-11-02 11:13:42.743');
INSERT INTO `device_sensor_record` VALUES (84770, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-02 11:13:42.743', '2026-11-02 11:13:42.743');
INSERT INTO `device_sensor_record` VALUES (84771, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-02 11:13:42.743', '2026-11-02 11:13:42.743');
INSERT INTO `device_sensor_record` VALUES (84772, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51, '℃', NULL, NULL, '2026-11-02 11:13:42.743', '2026-11-02 11:13:42.743');
INSERT INTO `device_sensor_record` VALUES (84773, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-02 11:13:42.743', '2026-11-02 11:13:42.743');
INSERT INTO `device_sensor_record` VALUES (84774, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 137773, 'bytes', NULL, NULL, '2026-11-02 11:13:42.743', '2026-11-02 11:13:42.743');
INSERT INTO `device_sensor_record` VALUES (84775, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.8, '℃', NULL, NULL, '2026-11-02 11:13:52.749', '2026-11-02 11:13:52.749');
INSERT INTO `device_sensor_record` VALUES (84776, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.4, '%', NULL, NULL, '2026-11-02 11:13:52.749', '2026-11-02 11:13:52.749');
INSERT INTO `device_sensor_record` VALUES (84777, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 38.1, 'μg/m³', NULL, NULL, '2026-11-02 11:13:52.749', '2026-11-02 11:13:52.749');
INSERT INTO `device_sensor_record` VALUES (84778, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 425.1, 'ppm', NULL, NULL, '2026-11-02 11:13:52.749', '2026-11-02 11:13:52.749');
INSERT INTO `device_sensor_record` VALUES (84779, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 168.2, 'lx', NULL, NULL, '2026-11-02 11:13:52.749', '2026-11-02 11:13:52.749');
INSERT INTO `device_sensor_record` VALUES (84780, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 23, '℃', NULL, NULL, '2026-11-02 11:13:52.749', '2026-11-02 11:13:52.749');
INSERT INTO `device_sensor_record` VALUES (84781, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:13:52.749', '2026-11-02 11:13:52.749');
INSERT INTO `device_sensor_record` VALUES (84782, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.6, '℃', NULL, NULL, '2026-11-02 11:13:52.749', '2026-11-02 11:13:52.749');
INSERT INTO `device_sensor_record` VALUES (84783, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-02 11:13:52.749', '2026-11-02 11:13:52.749');
INSERT INTO `device_sensor_record` VALUES (84784, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 133995, 'bytes', NULL, NULL, '2026-11-02 11:13:52.749', '2026-11-02 11:13:52.749');
INSERT INTO `device_sensor_record` VALUES (84785, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.8, '℃', NULL, NULL, '2026-11-02 11:14:02.757', '2026-11-02 11:14:02.757');
INSERT INTO `device_sensor_record` VALUES (84786, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.3, '%', NULL, NULL, '2026-11-02 11:14:02.757', '2026-11-02 11:14:02.757');
INSERT INTO `device_sensor_record` VALUES (84787, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 48.6, 'μg/m³', NULL, NULL, '2026-11-02 11:14:02.757', '2026-11-02 11:14:02.757');
INSERT INTO `device_sensor_record` VALUES (84788, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 570, 'ppm', NULL, NULL, '2026-11-02 11:14:02.757', '2026-11-02 11:14:02.757');
INSERT INTO `device_sensor_record` VALUES (84789, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 775.1, 'lx', NULL, NULL, '2026-11-02 11:14:02.757', '2026-11-02 11:14:02.757');
INSERT INTO `device_sensor_record` VALUES (84790, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 23, '℃', NULL, NULL, '2026-11-02 11:14:02.757', '2026-11-02 11:14:02.757');
INSERT INTO `device_sensor_record` VALUES (84791, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.6, '℃', NULL, NULL, '2026-11-02 11:14:02.757', '2026-11-02 11:14:02.757');
INSERT INTO `device_sensor_record` VALUES (84792, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.2, '℃', NULL, NULL, '2026-11-02 11:14:02.757', '2026-11-02 11:14:02.757');
INSERT INTO `device_sensor_record` VALUES (84793, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:14:02.757', '2026-11-02 11:14:02.757');
INSERT INTO `device_sensor_record` VALUES (84794, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 138933, 'bytes', NULL, NULL, '2026-11-02 11:14:02.757', '2026-11-02 11:14:02.757');
INSERT INTO `device_sensor_record` VALUES (84795, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.1, '℃', NULL, NULL, '2026-11-02 11:14:12.775', '2026-11-02 11:14:12.775');
INSERT INTO `device_sensor_record` VALUES (84796, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 50.7, '%', NULL, NULL, '2026-11-02 11:14:12.775', '2026-11-02 11:14:12.775');
INSERT INTO `device_sensor_record` VALUES (84797, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.7, 'μg/m³', NULL, NULL, '2026-11-02 11:14:12.775', '2026-11-02 11:14:12.775');
INSERT INTO `device_sensor_record` VALUES (84798, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 585.9, 'ppm', NULL, NULL, '2026-11-02 11:14:12.775', '2026-11-02 11:14:12.775');
INSERT INTO `device_sensor_record` VALUES (84799, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 416.6, 'lx', NULL, NULL, '2026-11-02 11:14:12.775', '2026-11-02 11:14:12.775');
INSERT INTO `device_sensor_record` VALUES (84800, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-02 11:14:12.775', '2026-11-02 11:14:12.775');
INSERT INTO `device_sensor_record` VALUES (84801, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-02 11:14:12.775', '2026-11-02 11:14:12.775');
INSERT INTO `device_sensor_record` VALUES (84802, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.3, '℃', NULL, NULL, '2026-11-02 11:14:12.775', '2026-11-02 11:14:12.775');
INSERT INTO `device_sensor_record` VALUES (84803, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-02 11:14:12.775', '2026-11-02 11:14:12.775');
INSERT INTO `device_sensor_record` VALUES (84804, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 126633, 'bytes', NULL, NULL, '2026-11-02 11:14:12.775', '2026-11-02 11:14:12.775');
INSERT INTO `device_sensor_record` VALUES (84805, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:14:22.777', '2026-11-02 11:14:22.777');
INSERT INTO `device_sensor_record` VALUES (84806, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62.8, '%', NULL, NULL, '2026-11-02 11:14:22.777', '2026-11-02 11:14:22.777');
INSERT INTO `device_sensor_record` VALUES (84807, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.5, 'μg/m³', NULL, NULL, '2026-11-02 11:14:22.777', '2026-11-02 11:14:22.777');
INSERT INTO `device_sensor_record` VALUES (84808, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 504.1, 'ppm', NULL, NULL, '2026-11-02 11:14:22.777', '2026-11-02 11:14:22.777');
INSERT INTO `device_sensor_record` VALUES (84809, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 500.7, 'lx', NULL, NULL, '2026-11-02 11:14:22.777', '2026-11-02 11:14:22.777');
INSERT INTO `device_sensor_record` VALUES (84810, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.5, '℃', NULL, NULL, '2026-11-02 11:14:22.777', '2026-11-02 11:14:22.777');
INSERT INTO `device_sensor_record` VALUES (84811, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.3, '℃', NULL, NULL, '2026-11-02 11:14:22.777', '2026-11-02 11:14:22.777');
INSERT INTO `device_sensor_record` VALUES (84812, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.3, '℃', NULL, NULL, '2026-11-02 11:14:22.777', '2026-11-02 11:14:22.777');
INSERT INTO `device_sensor_record` VALUES (84813, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-02 11:14:22.777', '2026-11-02 11:14:22.777');
INSERT INTO `device_sensor_record` VALUES (84814, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 139648, 'bytes', NULL, NULL, '2026-11-02 11:14:22.777', '2026-11-02 11:14:22.777');
INSERT INTO `device_sensor_record` VALUES (84815, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:14:32.782', '2026-11-02 11:14:32.782');
INSERT INTO `device_sensor_record` VALUES (84816, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 50.2, '%', NULL, NULL, '2026-11-02 11:14:32.782', '2026-11-02 11:14:32.782');
INSERT INTO `device_sensor_record` VALUES (84817, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:14:32.782', '2026-11-02 11:14:32.782');
INSERT INTO `device_sensor_record` VALUES (84818, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 599.8, 'ppm', NULL, NULL, '2026-11-02 11:14:32.782', '2026-11-02 11:14:32.782');
INSERT INTO `device_sensor_record` VALUES (84819, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 113.6, 'lx', NULL, NULL, '2026-11-02 11:14:32.782', '2026-11-02 11:14:32.782');
INSERT INTO `device_sensor_record` VALUES (84820, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.3, '℃', NULL, NULL, '2026-11-02 11:14:32.782', '2026-11-02 11:14:32.782');
INSERT INTO `device_sensor_record` VALUES (84821, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-02 11:14:32.782', '2026-11-02 11:14:32.782');
INSERT INTO `device_sensor_record` VALUES (84822, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.4, '℃', NULL, NULL, '2026-11-02 11:14:32.782', '2026-11-02 11:14:32.782');
INSERT INTO `device_sensor_record` VALUES (84823, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-02 11:14:32.782', '2026-11-02 11:14:32.782');
INSERT INTO `device_sensor_record` VALUES (84824, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 124286, 'bytes', NULL, NULL, '2026-11-02 11:14:32.782', '2026-11-02 11:14:32.782');
INSERT INTO `device_sensor_record` VALUES (84825, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.9, '℃', NULL, NULL, '2026-11-02 11:14:42.827', '2026-11-02 11:14:42.827');
INSERT INTO `device_sensor_record` VALUES (84826, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.7, '%', NULL, NULL, '2026-11-02 11:14:42.827', '2026-11-02 11:14:42.827');
INSERT INTO `device_sensor_record` VALUES (84827, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 27.1, 'μg/m³', NULL, NULL, '2026-11-02 11:14:42.827', '2026-11-02 11:14:42.827');
INSERT INTO `device_sensor_record` VALUES (84828, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 559.7, 'ppm', NULL, NULL, '2026-11-02 11:14:42.827', '2026-11-02 11:14:42.827');
INSERT INTO `device_sensor_record` VALUES (84829, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 448.3, 'lx', NULL, NULL, '2026-11-02 11:14:42.827', '2026-11-02 11:14:42.827');
INSERT INTO `device_sensor_record` VALUES (84830, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-02 11:14:42.827', '2026-11-02 11:14:42.827');
INSERT INTO `device_sensor_record` VALUES (84831, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:14:42.827', '2026-11-02 11:14:42.827');
INSERT INTO `device_sensor_record` VALUES (84832, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49, '℃', NULL, NULL, '2026-11-02 11:14:42.827', '2026-11-02 11:14:42.827');
INSERT INTO `device_sensor_record` VALUES (84833, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.4, 'V', NULL, NULL, '2026-11-02 11:14:42.827', '2026-11-02 11:14:42.827');
INSERT INTO `device_sensor_record` VALUES (84834, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 151743, 'bytes', NULL, NULL, '2026-11-02 11:14:42.827', '2026-11-02 11:14:42.827');
INSERT INTO `device_sensor_record` VALUES (84835, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'slave-1-temperature', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:14:54.215', '2026-11-02 11:14:54.232');
INSERT INTO `device_sensor_record` VALUES (84836, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'slave-2-humidity', 'humidity', 55, '%', NULL, NULL, '2026-11-02 11:14:54.215', '2026-11-02 11:14:54.292');
INSERT INTO `device_sensor_record` VALUES (84837, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'slave-3-pm25', 'pm25', 35, 'μg/m³', NULL, NULL, '2026-11-02 11:14:54.215', '2026-11-02 11:14:54.293');
INSERT INTO `device_sensor_record` VALUES (84838, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'slave-4-co2', 'co2', 450, 'ppm', NULL, NULL, '2026-11-02 11:14:54.215', '2026-11-02 11:14:54.293');
INSERT INTO `device_sensor_record` VALUES (84839, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'slave-5-illuminance', 'illuminance', 300, 'lx', NULL, NULL, '2026-11-02 11:14:54.215', '2026-11-02 11:14:54.293');
INSERT INTO `device_sensor_record` VALUES (84840, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'slave-6-temperature-ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:14:54.215', '2026-11-02 11:14:54.293');
INSERT INTO `device_sensor_record` VALUES (84841, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'slave-6-temperature-ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 11:14:54.215', '2026-11-02 11:14:54.295');
INSERT INTO `device_sensor_record` VALUES (84842, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:15:02.813', '2026-11-02 11:15:02.813');
INSERT INTO `device_sensor_record` VALUES (84843, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 69.3, '%', NULL, NULL, '2026-11-02 11:15:02.813', '2026-11-02 11:15:02.813');
INSERT INTO `device_sensor_record` VALUES (84844, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 43.1, 'μg/m³', NULL, NULL, '2026-11-02 11:15:02.813', '2026-11-02 11:15:02.813');
INSERT INTO `device_sensor_record` VALUES (84845, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 584.7, 'ppm', NULL, NULL, '2026-11-02 11:15:02.813', '2026-11-02 11:15:02.813');
INSERT INTO `device_sensor_record` VALUES (84846, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 484.3, 'lx', NULL, NULL, '2026-11-02 11:15:02.813', '2026-11-02 11:15:02.813');
INSERT INTO `device_sensor_record` VALUES (84847, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-02 11:15:02.813', '2026-11-02 11:15:02.813');
INSERT INTO `device_sensor_record` VALUES (84848, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 11:15:02.813', '2026-11-02 11:15:02.813');
INSERT INTO `device_sensor_record` VALUES (84849, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.3, '℃', NULL, NULL, '2026-11-02 11:15:02.813', '2026-11-02 11:15:02.813');
INSERT INTO `device_sensor_record` VALUES (84850, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.29, 'V', NULL, NULL, '2026-11-02 11:15:02.813', '2026-11-02 11:15:02.813');
INSERT INTO `device_sensor_record` VALUES (84851, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 173079, 'bytes', NULL, NULL, '2026-11-02 11:15:02.813', '2026-11-02 11:15:02.813');
INSERT INTO `device_sensor_record` VALUES (84852, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:15:12.832', '2026-11-02 11:15:12.832');
INSERT INTO `device_sensor_record` VALUES (84853, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.7, '%', NULL, NULL, '2026-11-02 11:15:12.832', '2026-11-02 11:15:12.832');
INSERT INTO `device_sensor_record` VALUES (84854, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 33.6, 'μg/m³', NULL, NULL, '2026-11-02 11:15:12.832', '2026-11-02 11:15:12.832');
INSERT INTO `device_sensor_record` VALUES (84855, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 537.7, 'ppm', NULL, NULL, '2026-11-02 11:15:12.832', '2026-11-02 11:15:12.832');
INSERT INTO `device_sensor_record` VALUES (84856, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 510.6, 'lx', NULL, NULL, '2026-11-02 11:15:12.832', '2026-11-02 11:15:12.832');
INSERT INTO `device_sensor_record` VALUES (84857, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 23, '℃', NULL, NULL, '2026-11-02 11:15:12.832', '2026-11-02 11:15:12.832');
INSERT INTO `device_sensor_record` VALUES (84858, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-02 11:15:12.832', '2026-11-02 11:15:12.832');
INSERT INTO `device_sensor_record` VALUES (84859, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.8, '℃', NULL, NULL, '2026-11-02 11:15:12.832', '2026-11-02 11:15:12.832');
INSERT INTO `device_sensor_record` VALUES (84860, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-02 11:15:12.832', '2026-11-02 11:15:12.832');
INSERT INTO `device_sensor_record` VALUES (84861, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 174222, 'bytes', NULL, NULL, '2026-11-02 11:15:12.832', '2026-11-02 11:15:12.832');
INSERT INTO `device_sensor_record` VALUES (84862, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:15:22.842', '2026-11-02 11:15:22.842');
INSERT INTO `device_sensor_record` VALUES (84863, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 69.4, '%', NULL, NULL, '2026-11-02 11:15:22.842', '2026-11-02 11:15:22.842');
INSERT INTO `device_sensor_record` VALUES (84864, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:15:22.842', '2026-11-02 11:15:22.842');
INSERT INTO `device_sensor_record` VALUES (84865, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 558.7, 'ppm', NULL, NULL, '2026-11-02 11:15:22.842', '2026-11-02 11:15:22.842');
INSERT INTO `device_sensor_record` VALUES (84866, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 457.9, 'lx', NULL, NULL, '2026-11-02 11:15:22.842', '2026-11-02 11:15:22.842');
INSERT INTO `device_sensor_record` VALUES (84867, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.7, '℃', NULL, NULL, '2026-11-02 11:15:22.842', '2026-11-02 11:15:22.842');
INSERT INTO `device_sensor_record` VALUES (84868, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-02 11:15:22.842', '2026-11-02 11:15:22.842');
INSERT INTO `device_sensor_record` VALUES (84869, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.3, '℃', NULL, NULL, '2026-11-02 11:15:22.842', '2026-11-02 11:15:22.842');
INSERT INTO `device_sensor_record` VALUES (84870, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-02 11:15:22.842', '2026-11-02 11:15:22.842');
INSERT INTO `device_sensor_record` VALUES (84871, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 120597, 'bytes', NULL, NULL, '2026-11-02 11:15:22.842', '2026-11-02 11:15:22.842');
INSERT INTO `device_sensor_record` VALUES (84872, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.3, '℃', NULL, NULL, '2026-11-02 11:15:32.849', '2026-11-02 11:15:32.849');
INSERT INTO `device_sensor_record` VALUES (84873, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.3, '%', NULL, NULL, '2026-11-02 11:15:32.849', '2026-11-02 11:15:32.849');
INSERT INTO `device_sensor_record` VALUES (84874, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 44.2, 'μg/m³', NULL, NULL, '2026-11-02 11:15:32.849', '2026-11-02 11:15:32.849');
INSERT INTO `device_sensor_record` VALUES (84875, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 423.2, 'ppm', NULL, NULL, '2026-11-02 11:15:32.849', '2026-11-02 11:15:32.849');
INSERT INTO `device_sensor_record` VALUES (84876, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 750.7, 'lx', NULL, NULL, '2026-11-02 11:15:32.849', '2026-11-02 11:15:32.849');
INSERT INTO `device_sensor_record` VALUES (84877, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.5, '℃', NULL, NULL, '2026-11-02 11:15:32.849', '2026-11-02 11:15:32.849');
INSERT INTO `device_sensor_record` VALUES (84878, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-02 11:15:32.849', '2026-11-02 11:15:32.849');
INSERT INTO `device_sensor_record` VALUES (84879, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.2, '℃', NULL, NULL, '2026-11-02 11:15:32.849', '2026-11-02 11:15:32.849');
INSERT INTO `device_sensor_record` VALUES (84880, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-02 11:15:32.849', '2026-11-02 11:15:32.849');
INSERT INTO `device_sensor_record` VALUES (84881, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 133791, 'bytes', NULL, NULL, '2026-11-02 11:15:32.849', '2026-11-02 11:15:32.849');
INSERT INTO `device_sensor_record` VALUES (84882, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.5, '℃', NULL, NULL, '2026-11-02 11:15:42.858', '2026-11-02 11:15:42.858');
INSERT INTO `device_sensor_record` VALUES (84883, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56, '%', NULL, NULL, '2026-11-02 11:15:42.858', '2026-11-02 11:15:42.858');
INSERT INTO `device_sensor_record` VALUES (84884, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 37.3, 'μg/m³', NULL, NULL, '2026-11-02 11:15:42.858', '2026-11-02 11:15:42.858');
INSERT INTO `device_sensor_record` VALUES (84885, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 422.7, 'ppm', NULL, NULL, '2026-11-02 11:15:42.858', '2026-11-02 11:15:42.858');
INSERT INTO `device_sensor_record` VALUES (84886, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 294.7, 'lx', NULL, NULL, '2026-11-02 11:15:42.858', '2026-11-02 11:15:42.858');
INSERT INTO `device_sensor_record` VALUES (84887, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.5, '℃', NULL, NULL, '2026-11-02 11:15:42.858', '2026-11-02 11:15:42.858');
INSERT INTO `device_sensor_record` VALUES (84888, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 11:15:42.858', '2026-11-02 11:15:42.858');
INSERT INTO `device_sensor_record` VALUES (84889, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.1, '℃', NULL, NULL, '2026-11-02 11:15:42.858', '2026-11-02 11:15:42.858');
INSERT INTO `device_sensor_record` VALUES (84890, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-02 11:15:42.858', '2026-11-02 11:15:42.858');
INSERT INTO `device_sensor_record` VALUES (84891, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 129934, 'bytes', NULL, NULL, '2026-11-02 11:15:42.858', '2026-11-02 11:15:42.858');
INSERT INTO `device_sensor_record` VALUES (84892, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:15:52.868', '2026-11-02 11:15:52.868');
INSERT INTO `device_sensor_record` VALUES (84893, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54, '%', NULL, NULL, '2026-11-02 11:15:52.868', '2026-11-02 11:15:52.868');
INSERT INTO `device_sensor_record` VALUES (84894, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 41.1, 'μg/m³', NULL, NULL, '2026-11-02 11:15:52.868', '2026-11-02 11:15:52.868');
INSERT INTO `device_sensor_record` VALUES (84895, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 543.3, 'ppm', NULL, NULL, '2026-11-02 11:15:52.868', '2026-11-02 11:15:52.868');
INSERT INTO `device_sensor_record` VALUES (84896, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 726.8, 'lx', NULL, NULL, '2026-11-02 11:15:52.868', '2026-11-02 11:15:52.868');
INSERT INTO `device_sensor_record` VALUES (84897, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-02 11:15:52.868', '2026-11-02 11:15:52.868');
INSERT INTO `device_sensor_record` VALUES (84898, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:15:52.868', '2026-11-02 11:15:52.868');
INSERT INTO `device_sensor_record` VALUES (84899, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.7, '℃', NULL, NULL, '2026-11-02 11:15:52.868', '2026-11-02 11:15:52.868');
INSERT INTO `device_sensor_record` VALUES (84900, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-02 11:15:52.868', '2026-11-02 11:15:52.868');
INSERT INTO `device_sensor_record` VALUES (84901, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 165238, 'bytes', NULL, NULL, '2026-11-02 11:15:52.868', '2026-11-02 11:15:52.868');
INSERT INTO `device_sensor_record` VALUES (84902, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.8, '℃', NULL, NULL, '2026-11-02 11:16:02.869', '2026-11-02 11:16:02.869');
INSERT INTO `device_sensor_record` VALUES (84903, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.4, '%', NULL, NULL, '2026-11-02 11:16:02.869', '2026-11-02 11:16:02.869');
INSERT INTO `device_sensor_record` VALUES (84904, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.1, 'μg/m³', NULL, NULL, '2026-11-02 11:16:02.869', '2026-11-02 11:16:02.869');
INSERT INTO `device_sensor_record` VALUES (84905, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 417.4, 'ppm', NULL, NULL, '2026-11-02 11:16:02.869', '2026-11-02 11:16:02.869');
INSERT INTO `device_sensor_record` VALUES (84906, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 443.5, 'lx', NULL, NULL, '2026-11-02 11:16:02.869', '2026-11-02 11:16:02.869');
INSERT INTO `device_sensor_record` VALUES (84907, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.5, '℃', NULL, NULL, '2026-11-02 11:16:02.869', '2026-11-02 11:16:02.869');
INSERT INTO `device_sensor_record` VALUES (84908, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.3, '℃', NULL, NULL, '2026-11-02 11:16:02.869', '2026-11-02 11:16:02.869');
INSERT INTO `device_sensor_record` VALUES (84909, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.4, '℃', NULL, NULL, '2026-11-02 11:16:02.869', '2026-11-02 11:16:02.869');
INSERT INTO `device_sensor_record` VALUES (84910, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-02 11:16:02.869', '2026-11-02 11:16:02.869');
INSERT INTO `device_sensor_record` VALUES (84911, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 167028, 'bytes', NULL, NULL, '2026-11-02 11:16:02.869', '2026-11-02 11:16:02.869');
INSERT INTO `device_sensor_record` VALUES (84912, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:16:12.882', '2026-11-02 11:16:12.882');
INSERT INTO `device_sensor_record` VALUES (84913, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 69.8, '%', NULL, NULL, '2026-11-02 11:16:12.882', '2026-11-02 11:16:12.882');
INSERT INTO `device_sensor_record` VALUES (84914, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:16:12.882', '2026-11-02 11:16:12.882');
INSERT INTO `device_sensor_record` VALUES (84915, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 565.6, 'ppm', NULL, NULL, '2026-11-02 11:16:12.882', '2026-11-02 11:16:12.882');
INSERT INTO `device_sensor_record` VALUES (84916, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 194.6, 'lx', NULL, NULL, '2026-11-02 11:16:12.882', '2026-11-02 11:16:12.882');
INSERT INTO `device_sensor_record` VALUES (84917, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.6, '℃', NULL, NULL, '2026-11-02 11:16:12.882', '2026-11-02 11:16:12.882');
INSERT INTO `device_sensor_record` VALUES (84918, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:16:12.882', '2026-11-02 11:16:12.882');
INSERT INTO `device_sensor_record` VALUES (84919, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.4, '℃', NULL, NULL, '2026-11-02 11:16:12.882', '2026-11-02 11:16:12.882');
INSERT INTO `device_sensor_record` VALUES (84920, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-02 11:16:12.882', '2026-11-02 11:16:12.882');
INSERT INTO `device_sensor_record` VALUES (84921, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 139615, 'bytes', NULL, NULL, '2026-11-02 11:16:12.882', '2026-11-02 11:16:12.882');
INSERT INTO `device_sensor_record` VALUES (84922, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.6, '℃', NULL, NULL, '2026-11-02 11:16:22.884', '2026-11-02 11:16:22.884');
INSERT INTO `device_sensor_record` VALUES (84923, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.8, '%', NULL, NULL, '2026-11-02 11:16:22.884', '2026-11-02 11:16:22.884');
INSERT INTO `device_sensor_record` VALUES (84924, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35.8, 'μg/m³', NULL, NULL, '2026-11-02 11:16:22.884', '2026-11-02 11:16:22.884');
INSERT INTO `device_sensor_record` VALUES (84925, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 589.5, 'ppm', NULL, NULL, '2026-11-02 11:16:22.884', '2026-11-02 11:16:22.884');
INSERT INTO `device_sensor_record` VALUES (84926, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 205.1, 'lx', NULL, NULL, '2026-11-02 11:16:22.884', '2026-11-02 11:16:22.884');
INSERT INTO `device_sensor_record` VALUES (84927, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-02 11:16:22.884', '2026-11-02 11:16:22.884');
INSERT INTO `device_sensor_record` VALUES (84928, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.9, '℃', NULL, NULL, '2026-11-02 11:16:22.884', '2026-11-02 11:16:22.884');
INSERT INTO `device_sensor_record` VALUES (84929, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.2, '℃', NULL, NULL, '2026-11-02 11:16:22.884', '2026-11-02 11:16:22.884');
INSERT INTO `device_sensor_record` VALUES (84930, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-02 11:16:22.884', '2026-11-02 11:16:22.884');
INSERT INTO `device_sensor_record` VALUES (84931, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 157877, 'bytes', NULL, NULL, '2026-11-02 11:16:22.884', '2026-11-02 11:16:22.884');
INSERT INTO `device_sensor_record` VALUES (84932, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.1, '℃', NULL, NULL, '2026-11-02 11:16:32.891', '2026-11-02 11:16:32.891');
INSERT INTO `device_sensor_record` VALUES (84933, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.3, '%', NULL, NULL, '2026-11-02 11:16:32.891', '2026-11-02 11:16:32.891');
INSERT INTO `device_sensor_record` VALUES (84934, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 20.5, 'μg/m³', NULL, NULL, '2026-11-02 11:16:32.891', '2026-11-02 11:16:32.891');
INSERT INTO `device_sensor_record` VALUES (84935, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 532.4, 'ppm', NULL, NULL, '2026-11-02 11:16:32.891', '2026-11-02 11:16:32.891');
INSERT INTO `device_sensor_record` VALUES (84936, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 139.3, 'lx', NULL, NULL, '2026-11-02 11:16:32.891', '2026-11-02 11:16:32.891');
INSERT INTO `device_sensor_record` VALUES (84937, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-02 11:16:32.891', '2026-11-02 11:16:32.891');
INSERT INTO `device_sensor_record` VALUES (84938, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.2, '℃', NULL, NULL, '2026-11-02 11:16:32.891', '2026-11-02 11:16:32.891');
INSERT INTO `device_sensor_record` VALUES (84939, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.9, '℃', NULL, NULL, '2026-11-02 11:16:32.891', '2026-11-02 11:16:32.891');
INSERT INTO `device_sensor_record` VALUES (84940, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-02 11:16:32.891', '2026-11-02 11:16:32.891');
INSERT INTO `device_sensor_record` VALUES (84941, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 172606, 'bytes', NULL, NULL, '2026-11-02 11:16:32.891', '2026-11-02 11:16:32.891');
INSERT INTO `device_sensor_record` VALUES (84942, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:16:42.892', '2026-11-02 11:16:42.892');
INSERT INTO `device_sensor_record` VALUES (84943, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.7, '%', NULL, NULL, '2026-11-02 11:16:42.892', '2026-11-02 11:16:42.892');
INSERT INTO `device_sensor_record` VALUES (84944, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.2, 'μg/m³', NULL, NULL, '2026-11-02 11:16:42.892', '2026-11-02 11:16:42.892');
INSERT INTO `device_sensor_record` VALUES (84945, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 563.6, 'ppm', NULL, NULL, '2026-11-02 11:16:42.892', '2026-11-02 11:16:42.892');
INSERT INTO `device_sensor_record` VALUES (84946, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 779.8, 'lx', NULL, NULL, '2026-11-02 11:16:42.892', '2026-11-02 11:16:42.892');
INSERT INTO `device_sensor_record` VALUES (84947, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.6, '℃', NULL, NULL, '2026-11-02 11:16:42.892', '2026-11-02 11:16:42.892');
INSERT INTO `device_sensor_record` VALUES (84948, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:16:42.892', '2026-11-02 11:16:42.892');
INSERT INTO `device_sensor_record` VALUES (84949, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.4, '℃', NULL, NULL, '2026-11-02 11:16:42.892', '2026-11-02 11:16:42.892');
INSERT INTO `device_sensor_record` VALUES (84950, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-02 11:16:42.892', '2026-11-02 11:16:42.892');
INSERT INTO `device_sensor_record` VALUES (84951, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 134362, 'bytes', NULL, NULL, '2026-11-02 11:16:42.892', '2026-11-02 11:16:42.892');
INSERT INTO `device_sensor_record` VALUES (84952, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:16:52.908', '2026-11-02 11:16:52.908');
INSERT INTO `device_sensor_record` VALUES (84953, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.3, '%', NULL, NULL, '2026-11-02 11:16:52.908', '2026-11-02 11:16:52.908');
INSERT INTO `device_sensor_record` VALUES (84954, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.8, 'μg/m³', NULL, NULL, '2026-11-02 11:16:52.908', '2026-11-02 11:16:52.908');
INSERT INTO `device_sensor_record` VALUES (84955, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 422.9, 'ppm', NULL, NULL, '2026-11-02 11:16:52.908', '2026-11-02 11:16:52.908');
INSERT INTO `device_sensor_record` VALUES (84956, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 783.7, 'lx', NULL, NULL, '2026-11-02 11:16:52.908', '2026-11-02 11:16:52.908');
INSERT INTO `device_sensor_record` VALUES (84957, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 23, '℃', NULL, NULL, '2026-11-02 11:16:52.908', '2026-11-02 11:16:52.908');
INSERT INTO `device_sensor_record` VALUES (84958, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:16:52.908', '2026-11-02 11:16:52.908');
INSERT INTO `device_sensor_record` VALUES (84959, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51, '℃', NULL, NULL, '2026-11-02 11:16:52.908', '2026-11-02 11:16:52.908');
INSERT INTO `device_sensor_record` VALUES (84960, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-02 11:16:52.908', '2026-11-02 11:16:52.908');
INSERT INTO `device_sensor_record` VALUES (84961, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 144430, 'bytes', NULL, NULL, '2026-11-02 11:16:52.908', '2026-11-02 11:16:52.908');
INSERT INTO `device_sensor_record` VALUES (84962, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:17:02.921', '2026-11-02 11:17:02.921');
INSERT INTO `device_sensor_record` VALUES (84963, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.7, '%', NULL, NULL, '2026-11-02 11:17:02.921', '2026-11-02 11:17:02.921');
INSERT INTO `device_sensor_record` VALUES (84964, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:17:02.921', '2026-11-02 11:17:02.921');
INSERT INTO `device_sensor_record` VALUES (84965, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 402.9, 'ppm', NULL, NULL, '2026-11-02 11:17:02.921', '2026-11-02 11:17:02.921');
INSERT INTO `device_sensor_record` VALUES (84966, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 378.7, 'lx', NULL, NULL, '2026-11-02 11:17:02.921', '2026-11-02 11:17:02.921');
INSERT INTO `device_sensor_record` VALUES (84967, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-02 11:17:02.921', '2026-11-02 11:17:02.921');
INSERT INTO `device_sensor_record` VALUES (84968, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.4, '℃', NULL, NULL, '2026-11-02 11:17:02.921', '2026-11-02 11:17:02.921');
INSERT INTO `device_sensor_record` VALUES (84969, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.9, '℃', NULL, NULL, '2026-11-02 11:17:02.921', '2026-11-02 11:17:02.921');
INSERT INTO `device_sensor_record` VALUES (84970, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-02 11:17:02.921', '2026-11-02 11:17:02.921');
INSERT INTO `device_sensor_record` VALUES (84971, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 150793, 'bytes', NULL, NULL, '2026-11-02 11:17:02.921', '2026-11-02 11:17:02.921');
INSERT INTO `device_sensor_record` VALUES (84972, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:17:12.933', '2026-11-02 11:17:12.933');
INSERT INTO `device_sensor_record` VALUES (84973, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.1, '%', NULL, NULL, '2026-11-02 11:17:12.933', '2026-11-02 11:17:12.933');
INSERT INTO `device_sensor_record` VALUES (84974, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 39.3, 'μg/m³', NULL, NULL, '2026-11-02 11:17:12.933', '2026-11-02 11:17:12.933');
INSERT INTO `device_sensor_record` VALUES (84975, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 492.2, 'ppm', NULL, NULL, '2026-11-02 11:17:12.933', '2026-11-02 11:17:12.933');
INSERT INTO `device_sensor_record` VALUES (84976, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 670, 'lx', NULL, NULL, '2026-11-02 11:17:12.933', '2026-11-02 11:17:12.933');
INSERT INTO `device_sensor_record` VALUES (84977, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-02 11:17:12.933', '2026-11-02 11:17:12.933');
INSERT INTO `device_sensor_record` VALUES (84978, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-02 11:17:12.933', '2026-11-02 11:17:12.933');
INSERT INTO `device_sensor_record` VALUES (84979, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.2, '℃', NULL, NULL, '2026-11-02 11:17:12.933', '2026-11-02 11:17:12.933');
INSERT INTO `device_sensor_record` VALUES (84980, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-02 11:17:12.933', '2026-11-02 11:17:12.933');
INSERT INTO `device_sensor_record` VALUES (84981, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 132263, 'bytes', NULL, NULL, '2026-11-02 11:17:12.933', '2026-11-02 11:17:12.933');
INSERT INTO `device_sensor_record` VALUES (84982, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.6, '℃', NULL, NULL, '2026-11-02 11:17:22.941', '2026-11-02 11:17:22.941');
INSERT INTO `device_sensor_record` VALUES (84983, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.7, '%', NULL, NULL, '2026-11-02 11:17:22.941', '2026-11-02 11:17:22.941');
INSERT INTO `device_sensor_record` VALUES (84984, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 28.5, 'μg/m³', NULL, NULL, '2026-11-02 11:17:22.941', '2026-11-02 11:17:22.941');
INSERT INTO `device_sensor_record` VALUES (84985, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 512.6, 'ppm', NULL, NULL, '2026-11-02 11:17:22.941', '2026-11-02 11:17:22.941');
INSERT INTO `device_sensor_record` VALUES (84986, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 177.6, 'lx', NULL, NULL, '2026-11-02 11:17:22.941', '2026-11-02 11:17:22.941');
INSERT INTO `device_sensor_record` VALUES (84987, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.3, '℃', NULL, NULL, '2026-11-02 11:17:22.941', '2026-11-02 11:17:22.941');
INSERT INTO `device_sensor_record` VALUES (84988, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:17:22.941', '2026-11-02 11:17:22.941');
INSERT INTO `device_sensor_record` VALUES (84989, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.3, '℃', NULL, NULL, '2026-11-02 11:17:22.941', '2026-11-02 11:17:22.941');
INSERT INTO `device_sensor_record` VALUES (84990, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-02 11:17:22.941', '2026-11-02 11:17:22.941');
INSERT INTO `device_sensor_record` VALUES (84991, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 151188, 'bytes', NULL, NULL, '2026-11-02 11:17:22.941', '2026-11-02 11:17:22.941');
INSERT INTO `device_sensor_record` VALUES (84992, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 11:17:32.951', '2026-11-02 11:17:32.951');
INSERT INTO `device_sensor_record` VALUES (84993, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.3, '%', NULL, NULL, '2026-11-02 11:17:32.951', '2026-11-02 11:17:32.951');
INSERT INTO `device_sensor_record` VALUES (84994, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.2, 'μg/m³', NULL, NULL, '2026-11-02 11:17:32.951', '2026-11-02 11:17:32.951');
INSERT INTO `device_sensor_record` VALUES (84995, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 584.7, 'ppm', NULL, NULL, '2026-11-02 11:17:32.951', '2026-11-02 11:17:32.951');
INSERT INTO `device_sensor_record` VALUES (84996, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 439.8, 'lx', NULL, NULL, '2026-11-02 11:17:32.951', '2026-11-02 11:17:32.951');
INSERT INTO `device_sensor_record` VALUES (84997, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.6, '℃', NULL, NULL, '2026-11-02 11:17:32.951', '2026-11-02 11:17:32.951');
INSERT INTO `device_sensor_record` VALUES (84998, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.7, '℃', NULL, NULL, '2026-11-02 11:17:32.951', '2026-11-02 11:17:32.951');
INSERT INTO `device_sensor_record` VALUES (84999, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.2, '℃', NULL, NULL, '2026-11-02 11:17:32.951', '2026-11-02 11:17:32.951');
INSERT INTO `device_sensor_record` VALUES (85000, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-02 11:17:32.951', '2026-11-02 11:17:32.951');
INSERT INTO `device_sensor_record` VALUES (85001, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 172408, 'bytes', NULL, NULL, '2026-11-02 11:17:32.951', '2026-11-02 11:17:32.951');
INSERT INTO `device_sensor_record` VALUES (85002, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:17:42.957', '2026-11-02 11:17:42.957');
INSERT INTO `device_sensor_record` VALUES (85003, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.7, '%', NULL, NULL, '2026-11-02 11:17:42.957', '2026-11-02 11:17:42.957');
INSERT INTO `device_sensor_record` VALUES (85004, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 30.4, 'μg/m³', NULL, NULL, '2026-11-02 11:17:42.957', '2026-11-02 11:17:42.957');
INSERT INTO `device_sensor_record` VALUES (85005, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 449.6, 'ppm', NULL, NULL, '2026-11-02 11:17:42.957', '2026-11-02 11:17:42.957');
INSERT INTO `device_sensor_record` VALUES (85006, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 103.2, 'lx', NULL, NULL, '2026-11-02 11:17:42.957', '2026-11-02 11:17:42.957');
INSERT INTO `device_sensor_record` VALUES (85007, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-02 11:17:42.957', '2026-11-02 11:17:42.957');
INSERT INTO `device_sensor_record` VALUES (85008, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.4, '℃', NULL, NULL, '2026-11-02 11:17:42.957', '2026-11-02 11:17:42.957');
INSERT INTO `device_sensor_record` VALUES (85009, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.6, '℃', NULL, NULL, '2026-11-02 11:17:42.957', '2026-11-02 11:17:42.957');
INSERT INTO `device_sensor_record` VALUES (85010, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.22, 'V', NULL, NULL, '2026-11-02 11:17:42.957', '2026-11-02 11:17:42.957');
INSERT INTO `device_sensor_record` VALUES (85011, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 164611, 'bytes', NULL, NULL, '2026-11-02 11:17:42.957', '2026-11-02 11:17:42.957');
INSERT INTO `device_sensor_record` VALUES (85012, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:17:52.966', '2026-11-02 11:17:52.966');
INSERT INTO `device_sensor_record` VALUES (85013, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.4, '%', NULL, NULL, '2026-11-02 11:17:52.966', '2026-11-02 11:17:52.966');
INSERT INTO `device_sensor_record` VALUES (85014, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:17:52.966', '2026-11-02 11:17:52.966');
INSERT INTO `device_sensor_record` VALUES (85015, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 538.7, 'ppm', NULL, NULL, '2026-11-02 11:17:52.966', '2026-11-02 11:17:52.966');
INSERT INTO `device_sensor_record` VALUES (85016, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 708.3, 'lx', NULL, NULL, '2026-11-02 11:17:52.966', '2026-11-02 11:17:52.966');
INSERT INTO `device_sensor_record` VALUES (85017, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.7, '℃', NULL, NULL, '2026-11-02 11:17:52.966', '2026-11-02 11:17:52.966');
INSERT INTO `device_sensor_record` VALUES (85018, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.8, '℃', NULL, NULL, '2026-11-02 11:17:52.966', '2026-11-02 11:17:52.966');
INSERT INTO `device_sensor_record` VALUES (85019, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.4, '℃', NULL, NULL, '2026-11-02 11:17:52.966', '2026-11-02 11:17:52.966');
INSERT INTO `device_sensor_record` VALUES (85020, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.39, 'V', NULL, NULL, '2026-11-02 11:17:52.966', '2026-11-02 11:17:52.966');
INSERT INTO `device_sensor_record` VALUES (85021, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 125309, 'bytes', NULL, NULL, '2026-11-02 11:17:52.966', '2026-11-02 11:17:52.966');
INSERT INTO `device_sensor_record` VALUES (85022, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:18:02.978', '2026-11-02 11:18:02.978');
INSERT INTO `device_sensor_record` VALUES (85023, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.2, '%', NULL, NULL, '2026-11-02 11:18:02.978', '2026-11-02 11:18:02.978');
INSERT INTO `device_sensor_record` VALUES (85024, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 39.4, 'μg/m³', NULL, NULL, '2026-11-02 11:18:02.978', '2026-11-02 11:18:02.978');
INSERT INTO `device_sensor_record` VALUES (85025, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 547.3, 'ppm', NULL, NULL, '2026-11-02 11:18:02.978', '2026-11-02 11:18:02.978');
INSERT INTO `device_sensor_record` VALUES (85026, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 612.2, 'lx', NULL, NULL, '2026-11-02 11:18:02.978', '2026-11-02 11:18:02.978');
INSERT INTO `device_sensor_record` VALUES (85027, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.9, '℃', NULL, NULL, '2026-11-02 11:18:02.978', '2026-11-02 11:18:02.978');
INSERT INTO `device_sensor_record` VALUES (85028, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 11:18:02.978', '2026-11-02 11:18:02.978');
INSERT INTO `device_sensor_record` VALUES (85029, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.3, '℃', NULL, NULL, '2026-11-02 11:18:02.978', '2026-11-02 11:18:02.978');
INSERT INTO `device_sensor_record` VALUES (85030, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-02 11:18:02.978', '2026-11-02 11:18:02.978');
INSERT INTO `device_sensor_record` VALUES (85031, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 176435, 'bytes', NULL, NULL, '2026-11-02 11:18:02.978', '2026-11-02 11:18:02.978');
INSERT INTO `device_sensor_record` VALUES (85032, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:18:12.983', '2026-11-02 11:18:12.983');
INSERT INTO `device_sensor_record` VALUES (85033, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 57.7, '%', NULL, NULL, '2026-11-02 11:18:12.983', '2026-11-02 11:18:12.983');
INSERT INTO `device_sensor_record` VALUES (85034, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 34.1, 'μg/m³', NULL, NULL, '2026-11-02 11:18:12.983', '2026-11-02 11:18:12.983');
INSERT INTO `device_sensor_record` VALUES (85035, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 487.4, 'ppm', NULL, NULL, '2026-11-02 11:18:12.983', '2026-11-02 11:18:12.983');
INSERT INTO `device_sensor_record` VALUES (85036, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 305.8, 'lx', NULL, NULL, '2026-11-02 11:18:12.983', '2026-11-02 11:18:12.983');
INSERT INTO `device_sensor_record` VALUES (85037, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.5, '℃', NULL, NULL, '2026-11-02 11:18:12.983', '2026-11-02 11:18:12.983');
INSERT INTO `device_sensor_record` VALUES (85038, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:18:12.983', '2026-11-02 11:18:12.983');
INSERT INTO `device_sensor_record` VALUES (85039, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51, '℃', NULL, NULL, '2026-11-02 11:18:12.983', '2026-11-02 11:18:12.983');
INSERT INTO `device_sensor_record` VALUES (85040, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-02 11:18:12.983', '2026-11-02 11:18:12.983');
INSERT INTO `device_sensor_record` VALUES (85041, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 164787, 'bytes', NULL, NULL, '2026-11-02 11:18:12.983', '2026-11-02 11:18:12.983');
INSERT INTO `device_sensor_record` VALUES (85042, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.7, '℃', NULL, NULL, '2026-11-02 11:18:22.988', '2026-11-02 11:18:22.988');
INSERT INTO `device_sensor_record` VALUES (85043, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.6, '%', NULL, NULL, '2026-11-02 11:18:22.988', '2026-11-02 11:18:22.988');
INSERT INTO `device_sensor_record` VALUES (85044, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.6, 'μg/m³', NULL, NULL, '2026-11-02 11:18:22.988', '2026-11-02 11:18:22.988');
INSERT INTO `device_sensor_record` VALUES (85045, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 414.9, 'ppm', NULL, NULL, '2026-11-02 11:18:22.988', '2026-11-02 11:18:22.988');
INSERT INTO `device_sensor_record` VALUES (85046, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 467.2, 'lx', NULL, NULL, '2026-11-02 11:18:22.988', '2026-11-02 11:18:22.988');
INSERT INTO `device_sensor_record` VALUES (85047, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.6, '℃', NULL, NULL, '2026-11-02 11:18:22.988', '2026-11-02 11:18:22.988');
INSERT INTO `device_sensor_record` VALUES (85048, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:18:22.988', '2026-11-02 11:18:22.988');
INSERT INTO `device_sensor_record` VALUES (85049, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.1, '℃', NULL, NULL, '2026-11-02 11:18:22.988', '2026-11-02 11:18:22.988');
INSERT INTO `device_sensor_record` VALUES (85050, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-02 11:18:22.988', '2026-11-02 11:18:22.988');
INSERT INTO `device_sensor_record` VALUES (85051, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 131004, 'bytes', NULL, NULL, '2026-11-02 11:18:22.988', '2026-11-02 11:18:22.988');
INSERT INTO `device_sensor_record` VALUES (85052, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:18:32.995', '2026-11-02 11:18:32.995');
INSERT INTO `device_sensor_record` VALUES (85053, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.6, '%', NULL, NULL, '2026-11-02 11:18:32.995', '2026-11-02 11:18:32.995');
INSERT INTO `device_sensor_record` VALUES (85054, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 33, 'μg/m³', NULL, NULL, '2026-11-02 11:18:32.995', '2026-11-02 11:18:32.995');
INSERT INTO `device_sensor_record` VALUES (85055, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 466.3, 'ppm', NULL, NULL, '2026-11-02 11:18:32.995', '2026-11-02 11:18:32.995');
INSERT INTO `device_sensor_record` VALUES (85056, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 607.8, 'lx', NULL, NULL, '2026-11-02 11:18:32.995', '2026-11-02 11:18:32.995');
INSERT INTO `device_sensor_record` VALUES (85057, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.7, '℃', NULL, NULL, '2026-11-02 11:18:32.995', '2026-11-02 11:18:32.995');
INSERT INTO `device_sensor_record` VALUES (85058, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.3, '℃', NULL, NULL, '2026-11-02 11:18:32.995', '2026-11-02 11:18:32.995');
INSERT INTO `device_sensor_record` VALUES (85059, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.6, '℃', NULL, NULL, '2026-11-02 11:18:32.995', '2026-11-02 11:18:32.995');
INSERT INTO `device_sensor_record` VALUES (85060, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-02 11:18:32.995', '2026-11-02 11:18:32.995');
INSERT INTO `device_sensor_record` VALUES (85061, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 127405, 'bytes', NULL, NULL, '2026-11-02 11:18:32.995', '2026-11-02 11:18:32.995');
INSERT INTO `device_sensor_record` VALUES (85062, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:18:43.008', '2026-11-02 11:18:43.008');
INSERT INTO `device_sensor_record` VALUES (85063, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64.6, '%', NULL, NULL, '2026-11-02 11:18:43.008', '2026-11-02 11:18:43.008');
INSERT INTO `device_sensor_record` VALUES (85064, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:18:43.008', '2026-11-02 11:18:43.008');
INSERT INTO `device_sensor_record` VALUES (85065, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 494.1, 'ppm', NULL, NULL, '2026-11-02 11:18:43.008', '2026-11-02 11:18:43.008');
INSERT INTO `device_sensor_record` VALUES (85066, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 518.5, 'lx', NULL, NULL, '2026-11-02 11:18:43.008', '2026-11-02 11:18:43.008');
INSERT INTO `device_sensor_record` VALUES (85067, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-02 11:18:43.008', '2026-11-02 11:18:43.008');
INSERT INTO `device_sensor_record` VALUES (85068, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.9, '℃', NULL, NULL, '2026-11-02 11:18:43.008', '2026-11-02 11:18:43.008');
INSERT INTO `device_sensor_record` VALUES (85069, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.9, '℃', NULL, NULL, '2026-11-02 11:18:43.008', '2026-11-02 11:18:43.008');
INSERT INTO `device_sensor_record` VALUES (85070, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-02 11:18:43.008', '2026-11-02 11:18:43.008');
INSERT INTO `device_sensor_record` VALUES (85071, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 177601, 'bytes', NULL, NULL, '2026-11-02 11:18:43.008', '2026-11-02 11:18:43.008');
INSERT INTO `device_sensor_record` VALUES (85072, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-02 11:18:53.023', '2026-11-02 11:18:53.023');
INSERT INTO `device_sensor_record` VALUES (85073, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.4, '%', NULL, NULL, '2026-11-02 11:18:53.023', '2026-11-02 11:18:53.023');
INSERT INTO `device_sensor_record` VALUES (85074, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.9, 'μg/m³', NULL, NULL, '2026-11-02 11:18:53.023', '2026-11-02 11:18:53.023');
INSERT INTO `device_sensor_record` VALUES (85075, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 460.7, 'ppm', NULL, NULL, '2026-11-02 11:18:53.023', '2026-11-02 11:18:53.023');
INSERT INTO `device_sensor_record` VALUES (85076, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 641.4, 'lx', NULL, NULL, '2026-11-02 11:18:53.023', '2026-11-02 11:18:53.023');
INSERT INTO `device_sensor_record` VALUES (85077, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-02 11:18:53.023', '2026-11-02 11:18:53.023');
INSERT INTO `device_sensor_record` VALUES (85078, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-02 11:18:53.023', '2026-11-02 11:18:53.023');
INSERT INTO `device_sensor_record` VALUES (85079, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.3, '℃', NULL, NULL, '2026-11-02 11:18:53.023', '2026-11-02 11:18:53.023');
INSERT INTO `device_sensor_record` VALUES (85080, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:18:53.023', '2026-11-02 11:18:53.023');
INSERT INTO `device_sensor_record` VALUES (85081, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 148172, 'bytes', NULL, NULL, '2026-11-02 11:18:53.023', '2026-11-02 11:18:53.023');
INSERT INTO `device_sensor_record` VALUES (85082, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.5, '℃', NULL, NULL, '2026-11-02 11:19:03.034', '2026-11-02 11:19:03.034');
INSERT INTO `device_sensor_record` VALUES (85083, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60.3, '%', NULL, NULL, '2026-11-02 11:19:03.034', '2026-11-02 11:19:03.034');
INSERT INTO `device_sensor_record` VALUES (85084, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 24.8, 'μg/m³', NULL, NULL, '2026-11-02 11:19:03.034', '2026-11-02 11:19:03.034');
INSERT INTO `device_sensor_record` VALUES (85085, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 541.8, 'ppm', NULL, NULL, '2026-11-02 11:19:03.034', '2026-11-02 11:19:03.034');
INSERT INTO `device_sensor_record` VALUES (85086, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 740.5, 'lx', NULL, NULL, '2026-11-02 11:19:03.034', '2026-11-02 11:19:03.034');
INSERT INTO `device_sensor_record` VALUES (85087, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-02 11:19:03.034', '2026-11-02 11:19:03.034');
INSERT INTO `device_sensor_record` VALUES (85088, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.4, '℃', NULL, NULL, '2026-11-02 11:19:03.034', '2026-11-02 11:19:03.034');
INSERT INTO `device_sensor_record` VALUES (85089, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.2, '℃', NULL, NULL, '2026-11-02 11:19:03.034', '2026-11-02 11:19:03.034');
INSERT INTO `device_sensor_record` VALUES (85090, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:19:03.034', '2026-11-02 11:19:03.034');
INSERT INTO `device_sensor_record` VALUES (85091, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 132519, 'bytes', NULL, NULL, '2026-11-02 11:19:03.034', '2026-11-02 11:19:03.034');
INSERT INTO `device_sensor_record` VALUES (85092, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.1, '℃', NULL, NULL, '2026-11-02 11:19:13.051', '2026-11-02 11:19:13.051');
INSERT INTO `device_sensor_record` VALUES (85093, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.1, '%', NULL, NULL, '2026-11-02 11:19:13.051', '2026-11-02 11:19:13.051');
INSERT INTO `device_sensor_record` VALUES (85094, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.9, 'μg/m³', NULL, NULL, '2026-11-02 11:19:13.051', '2026-11-02 11:19:13.051');
INSERT INTO `device_sensor_record` VALUES (85095, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 532, 'ppm', NULL, NULL, '2026-11-02 11:19:13.051', '2026-11-02 11:19:13.051');
INSERT INTO `device_sensor_record` VALUES (85096, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 784.1, 'lx', NULL, NULL, '2026-11-02 11:19:13.051', '2026-11-02 11:19:13.051');
INSERT INTO `device_sensor_record` VALUES (85097, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:19:13.051', '2026-11-02 11:19:13.051');
INSERT INTO `device_sensor_record` VALUES (85098, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:19:13.051', '2026-11-02 11:19:13.051');
INSERT INTO `device_sensor_record` VALUES (85099, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.7, '℃', NULL, NULL, '2026-11-02 11:19:13.051', '2026-11-02 11:19:13.051');
INSERT INTO `device_sensor_record` VALUES (85100, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.22, 'V', NULL, NULL, '2026-11-02 11:19:13.051', '2026-11-02 11:19:13.051');
INSERT INTO `device_sensor_record` VALUES (85101, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 131115, 'bytes', NULL, NULL, '2026-11-02 11:19:13.051', '2026-11-02 11:19:13.051');
INSERT INTO `device_sensor_record` VALUES (85102, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-02 11:19:23.065', '2026-11-02 11:19:23.065');
INSERT INTO `device_sensor_record` VALUES (85103, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.5, '%', NULL, NULL, '2026-11-02 11:19:23.065', '2026-11-02 11:19:23.065');
INSERT INTO `device_sensor_record` VALUES (85104, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 29.5, 'μg/m³', NULL, NULL, '2026-11-02 11:19:23.065', '2026-11-02 11:19:23.065');
INSERT INTO `device_sensor_record` VALUES (85105, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 594.3, 'ppm', NULL, NULL, '2026-11-02 11:19:23.065', '2026-11-02 11:19:23.065');
INSERT INTO `device_sensor_record` VALUES (85106, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 371.7, 'lx', NULL, NULL, '2026-11-02 11:19:23.065', '2026-11-02 11:19:23.065');
INSERT INTO `device_sensor_record` VALUES (85107, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.7, '℃', NULL, NULL, '2026-11-02 11:19:23.065', '2026-11-02 11:19:23.065');
INSERT INTO `device_sensor_record` VALUES (85108, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-02 11:19:23.065', '2026-11-02 11:19:23.065');
INSERT INTO `device_sensor_record` VALUES (85109, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.2, '℃', NULL, NULL, '2026-11-02 11:19:23.065', '2026-11-02 11:19:23.065');
INSERT INTO `device_sensor_record` VALUES (85110, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-02 11:19:23.065', '2026-11-02 11:19:23.065');
INSERT INTO `device_sensor_record` VALUES (85111, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 130689, 'bytes', NULL, NULL, '2026-11-02 11:19:23.065', '2026-11-02 11:19:23.065');
INSERT INTO `device_sensor_record` VALUES (85112, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:19:33.078', '2026-11-02 11:19:33.078');
INSERT INTO `device_sensor_record` VALUES (85113, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.5, '%', NULL, NULL, '2026-11-02 11:19:33.078', '2026-11-02 11:19:33.078');
INSERT INTO `device_sensor_record` VALUES (85114, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:19:33.078', '2026-11-02 11:19:33.078');
INSERT INTO `device_sensor_record` VALUES (85115, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 455.6, 'ppm', NULL, NULL, '2026-11-02 11:19:33.078', '2026-11-02 11:19:33.078');
INSERT INTO `device_sensor_record` VALUES (85116, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 686.7, 'lx', NULL, NULL, '2026-11-02 11:19:33.078', '2026-11-02 11:19:33.078');
INSERT INTO `device_sensor_record` VALUES (85117, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-02 11:19:33.078', '2026-11-02 11:19:33.078');
INSERT INTO `device_sensor_record` VALUES (85118, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-02 11:19:33.078', '2026-11-02 11:19:33.078');
INSERT INTO `device_sensor_record` VALUES (85119, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.4, '℃', NULL, NULL, '2026-11-02 11:19:33.078', '2026-11-02 11:19:33.078');
INSERT INTO `device_sensor_record` VALUES (85120, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-02 11:19:33.078', '2026-11-02 11:19:33.078');
INSERT INTO `device_sensor_record` VALUES (85121, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 165799, 'bytes', NULL, NULL, '2026-11-02 11:19:33.078', '2026-11-02 11:19:33.078');
INSERT INTO `device_sensor_record` VALUES (85122, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:19:43.091', '2026-11-02 11:19:43.091');
INSERT INTO `device_sensor_record` VALUES (85123, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 51.5, '%', NULL, NULL, '2026-11-02 11:19:43.091', '2026-11-02 11:19:43.091');
INSERT INTO `device_sensor_record` VALUES (85124, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 47.5, 'μg/m³', NULL, NULL, '2026-11-02 11:19:43.091', '2026-11-02 11:19:43.091');
INSERT INTO `device_sensor_record` VALUES (85125, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 429.4, 'ppm', NULL, NULL, '2026-11-02 11:19:43.091', '2026-11-02 11:19:43.091');
INSERT INTO `device_sensor_record` VALUES (85126, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 579.9, 'lx', NULL, NULL, '2026-11-02 11:19:43.091', '2026-11-02 11:19:43.091');
INSERT INTO `device_sensor_record` VALUES (85127, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.5, '℃', NULL, NULL, '2026-11-02 11:19:43.091', '2026-11-02 11:19:43.091');
INSERT INTO `device_sensor_record` VALUES (85128, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.4, '℃', NULL, NULL, '2026-11-02 11:19:43.091', '2026-11-02 11:19:43.091');
INSERT INTO `device_sensor_record` VALUES (85129, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.3, '℃', NULL, NULL, '2026-11-02 11:19:43.091', '2026-11-02 11:19:43.091');
INSERT INTO `device_sensor_record` VALUES (85130, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.4, 'V', NULL, NULL, '2026-11-02 11:19:43.091', '2026-11-02 11:19:43.091');
INSERT INTO `device_sensor_record` VALUES (85131, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 125651, 'bytes', NULL, NULL, '2026-11-02 11:19:43.091', '2026-11-02 11:19:43.091');
INSERT INTO `device_sensor_record` VALUES (85132, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.2, '℃', NULL, NULL, '2026-11-02 11:19:53.097', '2026-11-02 11:19:53.097');
INSERT INTO `device_sensor_record` VALUES (85133, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.5, '%', NULL, NULL, '2026-11-02 11:19:53.097', '2026-11-02 11:19:53.097');
INSERT INTO `device_sensor_record` VALUES (85134, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 34.3, 'μg/m³', NULL, NULL, '2026-11-02 11:19:53.097', '2026-11-02 11:19:53.097');
INSERT INTO `device_sensor_record` VALUES (85135, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 501.5, 'ppm', NULL, NULL, '2026-11-02 11:19:53.097', '2026-11-02 11:19:53.097');
INSERT INTO `device_sensor_record` VALUES (85136, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 703, 'lx', NULL, NULL, '2026-11-02 11:19:53.097', '2026-11-02 11:19:53.097');
INSERT INTO `device_sensor_record` VALUES (85137, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.8, '℃', NULL, NULL, '2026-11-02 11:19:53.097', '2026-11-02 11:19:53.097');
INSERT INTO `device_sensor_record` VALUES (85138, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.5, '℃', NULL, NULL, '2026-11-02 11:19:53.097', '2026-11-02 11:19:53.097');
INSERT INTO `device_sensor_record` VALUES (85139, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.2, '℃', NULL, NULL, '2026-11-02 11:19:53.097', '2026-11-02 11:19:53.097');
INSERT INTO `device_sensor_record` VALUES (85140, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-02 11:19:53.097', '2026-11-02 11:19:53.097');
INSERT INTO `device_sensor_record` VALUES (85141, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 139613, 'bytes', NULL, NULL, '2026-11-02 11:19:53.097', '2026-11-02 11:19:53.097');
INSERT INTO `device_sensor_record` VALUES (85142, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.3, '℃', NULL, NULL, '2026-11-02 11:20:03.112', '2026-11-02 11:20:03.112');
INSERT INTO `device_sensor_record` VALUES (85143, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.5, '%', NULL, NULL, '2026-11-02 11:20:03.112', '2026-11-02 11:20:03.112');
INSERT INTO `device_sensor_record` VALUES (85144, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 47.5, 'μg/m³', NULL, NULL, '2026-11-02 11:20:03.112', '2026-11-02 11:20:03.112');
INSERT INTO `device_sensor_record` VALUES (85145, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 416.8, 'ppm', NULL, NULL, '2026-11-02 11:20:03.112', '2026-11-02 11:20:03.112');
INSERT INTO `device_sensor_record` VALUES (85146, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 121.7, 'lx', NULL, NULL, '2026-11-02 11:20:03.112', '2026-11-02 11:20:03.112');
INSERT INTO `device_sensor_record` VALUES (85147, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.5, '℃', NULL, NULL, '2026-11-02 11:20:03.112', '2026-11-02 11:20:03.112');
INSERT INTO `device_sensor_record` VALUES (85148, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-02 11:20:03.112', '2026-11-02 11:20:03.112');
INSERT INTO `device_sensor_record` VALUES (85149, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.2, '℃', NULL, NULL, '2026-11-02 11:20:03.112', '2026-11-02 11:20:03.112');
INSERT INTO `device_sensor_record` VALUES (85150, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-02 11:20:03.112', '2026-11-02 11:20:03.112');
INSERT INTO `device_sensor_record` VALUES (85151, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 146076, 'bytes', NULL, NULL, '2026-11-02 11:20:03.112', '2026-11-02 11:20:03.112');
INSERT INTO `device_sensor_record` VALUES (85152, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:20:13.113', '2026-11-02 11:20:13.113');
INSERT INTO `device_sensor_record` VALUES (85153, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.4, '%', NULL, NULL, '2026-11-02 11:20:13.113', '2026-11-02 11:20:13.113');
INSERT INTO `device_sensor_record` VALUES (85154, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 40.5, 'μg/m³', NULL, NULL, '2026-11-02 11:20:13.113', '2026-11-02 11:20:13.113');
INSERT INTO `device_sensor_record` VALUES (85155, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 441.9, 'ppm', NULL, NULL, '2026-11-02 11:20:13.113', '2026-11-02 11:20:13.113');
INSERT INTO `device_sensor_record` VALUES (85156, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 287.8, 'lx', NULL, NULL, '2026-11-02 11:20:13.113', '2026-11-02 11:20:13.113');
INSERT INTO `device_sensor_record` VALUES (85157, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-02 11:20:13.113', '2026-11-02 11:20:13.113');
INSERT INTO `device_sensor_record` VALUES (85158, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-02 11:20:13.113', '2026-11-02 11:20:13.113');
INSERT INTO `device_sensor_record` VALUES (85159, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.5, '℃', NULL, NULL, '2026-11-02 11:20:13.113', '2026-11-02 11:20:13.113');
INSERT INTO `device_sensor_record` VALUES (85160, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:20:13.113', '2026-11-02 11:20:13.113');
INSERT INTO `device_sensor_record` VALUES (85161, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 141815, 'bytes', NULL, NULL, '2026-11-02 11:20:13.113', '2026-11-02 11:20:13.113');
INSERT INTO `device_sensor_record` VALUES (85162, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:20:23.122', '2026-11-02 11:20:23.122');
INSERT INTO `device_sensor_record` VALUES (85163, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64.7, '%', NULL, NULL, '2026-11-02 11:20:23.122', '2026-11-02 11:20:23.122');
INSERT INTO `device_sensor_record` VALUES (85164, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:20:23.122', '2026-11-02 11:20:23.122');
INSERT INTO `device_sensor_record` VALUES (85165, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 528.6, 'ppm', NULL, NULL, '2026-11-02 11:20:23.122', '2026-11-02 11:20:23.122');
INSERT INTO `device_sensor_record` VALUES (85166, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 242.3, 'lx', NULL, NULL, '2026-11-02 11:20:23.122', '2026-11-02 11:20:23.122');
INSERT INTO `device_sensor_record` VALUES (85167, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-02 11:20:23.122', '2026-11-02 11:20:23.122');
INSERT INTO `device_sensor_record` VALUES (85168, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.4, '℃', NULL, NULL, '2026-11-02 11:20:23.122', '2026-11-02 11:20:23.122');
INSERT INTO `device_sensor_record` VALUES (85169, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.3, '℃', NULL, NULL, '2026-11-02 11:20:23.122', '2026-11-02 11:20:23.122');
INSERT INTO `device_sensor_record` VALUES (85170, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:20:23.122', '2026-11-02 11:20:23.122');
INSERT INTO `device_sensor_record` VALUES (85171, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 165213, 'bytes', NULL, NULL, '2026-11-02 11:20:23.122', '2026-11-02 11:20:23.122');
INSERT INTO `device_sensor_record` VALUES (85172, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.2, '℃', NULL, NULL, '2026-11-02 11:20:33.136', '2026-11-02 11:20:33.136');
INSERT INTO `device_sensor_record` VALUES (85173, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.7, '%', NULL, NULL, '2026-11-02 11:20:33.136', '2026-11-02 11:20:33.136');
INSERT INTO `device_sensor_record` VALUES (85174, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.4, 'μg/m³', NULL, NULL, '2026-11-02 11:20:33.136', '2026-11-02 11:20:33.136');
INSERT INTO `device_sensor_record` VALUES (85175, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 546.4, 'ppm', NULL, NULL, '2026-11-02 11:20:33.136', '2026-11-02 11:20:33.136');
INSERT INTO `device_sensor_record` VALUES (85176, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 509.2, 'lx', NULL, NULL, '2026-11-02 11:20:33.136', '2026-11-02 11:20:33.136');
INSERT INTO `device_sensor_record` VALUES (85177, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.7, '℃', NULL, NULL, '2026-11-02 11:20:33.136', '2026-11-02 11:20:33.136');
INSERT INTO `device_sensor_record` VALUES (85178, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:20:33.136', '2026-11-02 11:20:33.136');
INSERT INTO `device_sensor_record` VALUES (85179, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.4, '℃', NULL, NULL, '2026-11-02 11:20:33.136', '2026-11-02 11:20:33.136');
INSERT INTO `device_sensor_record` VALUES (85180, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-02 11:20:33.136', '2026-11-02 11:20:33.136');
INSERT INTO `device_sensor_record` VALUES (85181, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 135558, 'bytes', NULL, NULL, '2026-11-02 11:20:33.136', '2026-11-02 11:20:33.136');
INSERT INTO `device_sensor_record` VALUES (85182, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.4, '℃', NULL, NULL, '2026-11-02 11:20:43.145', '2026-11-02 11:20:43.145');
INSERT INTO `device_sensor_record` VALUES (85183, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.6, '%', NULL, NULL, '2026-11-02 11:20:43.145', '2026-11-02 11:20:43.145');
INSERT INTO `device_sensor_record` VALUES (85184, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 24, 'μg/m³', NULL, NULL, '2026-11-02 11:20:43.145', '2026-11-02 11:20:43.145');
INSERT INTO `device_sensor_record` VALUES (85185, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 434.6, 'ppm', NULL, NULL, '2026-11-02 11:20:43.145', '2026-11-02 11:20:43.145');
INSERT INTO `device_sensor_record` VALUES (85186, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 341.7, 'lx', NULL, NULL, '2026-11-02 11:20:43.145', '2026-11-02 11:20:43.145');
INSERT INTO `device_sensor_record` VALUES (85187, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-02 11:20:43.145', '2026-11-02 11:20:43.145');
INSERT INTO `device_sensor_record` VALUES (85188, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.6, '℃', NULL, NULL, '2026-11-02 11:20:43.145', '2026-11-02 11:20:43.145');
INSERT INTO `device_sensor_record` VALUES (85189, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.9, '℃', NULL, NULL, '2026-11-02 11:20:43.145', '2026-11-02 11:20:43.145');
INSERT INTO `device_sensor_record` VALUES (85190, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-02 11:20:43.145', '2026-11-02 11:20:43.145');
INSERT INTO `device_sensor_record` VALUES (85191, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 152016, 'bytes', NULL, NULL, '2026-11-02 11:20:43.145', '2026-11-02 11:20:43.145');
INSERT INTO `device_sensor_record` VALUES (85192, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.9, '℃', NULL, NULL, '2026-11-02 11:20:53.153', '2026-11-02 11:20:53.153');
INSERT INTO `device_sensor_record` VALUES (85193, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.4, '%', NULL, NULL, '2026-11-02 11:20:53.153', '2026-11-02 11:20:53.153');
INSERT INTO `device_sensor_record` VALUES (85194, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35.7, 'μg/m³', NULL, NULL, '2026-11-02 11:20:53.153', '2026-11-02 11:20:53.153');
INSERT INTO `device_sensor_record` VALUES (85195, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 510.4, 'ppm', NULL, NULL, '2026-11-02 11:20:53.153', '2026-11-02 11:20:53.153');
INSERT INTO `device_sensor_record` VALUES (85196, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 308.6, 'lx', NULL, NULL, '2026-11-02 11:20:53.153', '2026-11-02 11:20:53.153');
INSERT INTO `device_sensor_record` VALUES (85197, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.5, '℃', NULL, NULL, '2026-11-02 11:20:53.153', '2026-11-02 11:20:53.153');
INSERT INTO `device_sensor_record` VALUES (85198, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-02 11:20:53.153', '2026-11-02 11:20:53.153');
INSERT INTO `device_sensor_record` VALUES (85199, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.9, '℃', NULL, NULL, '2026-11-02 11:20:53.153', '2026-11-02 11:20:53.153');
INSERT INTO `device_sensor_record` VALUES (85200, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-02 11:20:53.153', '2026-11-02 11:20:53.153');
INSERT INTO `device_sensor_record` VALUES (85201, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 179897, 'bytes', NULL, NULL, '2026-11-02 11:20:53.153', '2026-11-02 11:20:53.153');
INSERT INTO `device_sensor_record` VALUES (85202, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-02 11:21:03.165', '2026-11-02 11:21:03.165');
INSERT INTO `device_sensor_record` VALUES (85203, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.6, '%', NULL, NULL, '2026-11-02 11:21:03.165', '2026-11-02 11:21:03.165');
INSERT INTO `device_sensor_record` VALUES (85204, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 27.7, 'μg/m³', NULL, NULL, '2026-11-02 11:21:03.165', '2026-11-02 11:21:03.165');
INSERT INTO `device_sensor_record` VALUES (85205, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 519.7, 'ppm', NULL, NULL, '2026-11-02 11:21:03.165', '2026-11-02 11:21:03.165');
INSERT INTO `device_sensor_record` VALUES (85206, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 659.8, 'lx', NULL, NULL, '2026-11-02 11:21:03.165', '2026-11-02 11:21:03.165');
INSERT INTO `device_sensor_record` VALUES (85207, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.7, '℃', NULL, NULL, '2026-11-02 11:21:03.165', '2026-11-02 11:21:03.165');
INSERT INTO `device_sensor_record` VALUES (85208, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:21:03.165', '2026-11-02 11:21:03.165');
INSERT INTO `device_sensor_record` VALUES (85209, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.5, '℃', NULL, NULL, '2026-11-02 11:21:03.165', '2026-11-02 11:21:03.165');
INSERT INTO `device_sensor_record` VALUES (85210, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.22, 'V', NULL, NULL, '2026-11-02 11:21:03.165', '2026-11-02 11:21:03.165');
INSERT INTO `device_sensor_record` VALUES (85211, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 131105, 'bytes', NULL, NULL, '2026-11-02 11:21:03.165', '2026-11-02 11:21:03.165');
INSERT INTO `device_sensor_record` VALUES (85212, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:21:13.168', '2026-11-02 11:21:13.168');
INSERT INTO `device_sensor_record` VALUES (85213, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.3, '%', NULL, NULL, '2026-11-02 11:21:13.168', '2026-11-02 11:21:13.168');
INSERT INTO `device_sensor_record` VALUES (85214, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:21:13.168', '2026-11-02 11:21:13.168');
INSERT INTO `device_sensor_record` VALUES (85215, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 562.8, 'ppm', NULL, NULL, '2026-11-02 11:21:13.168', '2026-11-02 11:21:13.168');
INSERT INTO `device_sensor_record` VALUES (85216, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 520.7, 'lx', NULL, NULL, '2026-11-02 11:21:13.168', '2026-11-02 11:21:13.168');
INSERT INTO `device_sensor_record` VALUES (85217, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.6, '℃', NULL, NULL, '2026-11-02 11:21:13.168', '2026-11-02 11:21:13.168');
INSERT INTO `device_sensor_record` VALUES (85218, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:21:13.168', '2026-11-02 11:21:13.168');
INSERT INTO `device_sensor_record` VALUES (85219, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.4, '℃', NULL, NULL, '2026-11-02 11:21:13.168', '2026-11-02 11:21:13.168');
INSERT INTO `device_sensor_record` VALUES (85220, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-02 11:21:13.168', '2026-11-02 11:21:13.168');
INSERT INTO `device_sensor_record` VALUES (85221, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 138936, 'bytes', NULL, NULL, '2026-11-02 11:21:13.168', '2026-11-02 11:21:13.168');
INSERT INTO `device_sensor_record` VALUES (85222, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27, '℃', NULL, NULL, '2026-11-02 11:21:23.180', '2026-11-02 11:21:23.180');
INSERT INTO `device_sensor_record` VALUES (85223, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 51.7, '%', NULL, NULL, '2026-11-02 11:21:23.180', '2026-11-02 11:21:23.180');
INSERT INTO `device_sensor_record` VALUES (85224, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.6, 'μg/m³', NULL, NULL, '2026-11-02 11:21:23.180', '2026-11-02 11:21:23.180');
INSERT INTO `device_sensor_record` VALUES (85225, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 460.2, 'ppm', NULL, NULL, '2026-11-02 11:21:23.180', '2026-11-02 11:21:23.180');
INSERT INTO `device_sensor_record` VALUES (85226, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 741.1, 'lx', NULL, NULL, '2026-11-02 11:21:23.180', '2026-11-02 11:21:23.180');
INSERT INTO `device_sensor_record` VALUES (85227, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-02 11:21:23.180', '2026-11-02 11:21:23.180');
INSERT INTO `device_sensor_record` VALUES (85228, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:21:23.180', '2026-11-02 11:21:23.180');
INSERT INTO `device_sensor_record` VALUES (85229, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51, '℃', NULL, NULL, '2026-11-02 11:21:23.180', '2026-11-02 11:21:23.180');
INSERT INTO `device_sensor_record` VALUES (85230, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.39, 'V', NULL, NULL, '2026-11-02 11:21:23.180', '2026-11-02 11:21:23.180');
INSERT INTO `device_sensor_record` VALUES (85231, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 128826, 'bytes', NULL, NULL, '2026-11-02 11:21:23.180', '2026-11-02 11:21:23.180');
INSERT INTO `device_sensor_record` VALUES (85232, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-02 11:21:33.185', '2026-11-02 11:21:33.185');
INSERT INTO `device_sensor_record` VALUES (85233, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.2, '%', NULL, NULL, '2026-11-02 11:21:33.185', '2026-11-02 11:21:33.185');
INSERT INTO `device_sensor_record` VALUES (85234, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 48.3, 'μg/m³', NULL, NULL, '2026-11-02 11:21:33.185', '2026-11-02 11:21:33.185');
INSERT INTO `device_sensor_record` VALUES (85235, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 436.2, 'ppm', NULL, NULL, '2026-11-02 11:21:33.185', '2026-11-02 11:21:33.185');
INSERT INTO `device_sensor_record` VALUES (85236, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 183.1, 'lx', NULL, NULL, '2026-11-02 11:21:33.185', '2026-11-02 11:21:33.185');
INSERT INTO `device_sensor_record` VALUES (85237, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.6, '℃', NULL, NULL, '2026-11-02 11:21:33.185', '2026-11-02 11:21:33.185');
INSERT INTO `device_sensor_record` VALUES (85238, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 26, '℃', NULL, NULL, '2026-11-02 11:21:33.185', '2026-11-02 11:21:33.185');
INSERT INTO `device_sensor_record` VALUES (85239, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.4, '℃', NULL, NULL, '2026-11-02 11:21:33.185', '2026-11-02 11:21:33.185');
INSERT INTO `device_sensor_record` VALUES (85240, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-02 11:21:33.185', '2026-11-02 11:21:33.185');
INSERT INTO `device_sensor_record` VALUES (85241, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 171568, 'bytes', NULL, NULL, '2026-11-02 11:21:33.185', '2026-11-02 11:21:33.185');
INSERT INTO `device_sensor_record` VALUES (85242, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:21:43.187', '2026-11-02 11:21:43.187');
INSERT INTO `device_sensor_record` VALUES (85243, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.9, '%', NULL, NULL, '2026-11-02 11:21:43.187', '2026-11-02 11:21:43.187');
INSERT INTO `device_sensor_record` VALUES (85244, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 46.6, 'μg/m³', NULL, NULL, '2026-11-02 11:21:43.187', '2026-11-02 11:21:43.187');
INSERT INTO `device_sensor_record` VALUES (85245, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 463.8, 'ppm', NULL, NULL, '2026-11-02 11:21:43.187', '2026-11-02 11:21:43.187');
INSERT INTO `device_sensor_record` VALUES (85246, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 211.8, 'lx', NULL, NULL, '2026-11-02 11:21:43.187', '2026-11-02 11:21:43.187');
INSERT INTO `device_sensor_record` VALUES (85247, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-02 11:21:43.187', '2026-11-02 11:21:43.187');
INSERT INTO `device_sensor_record` VALUES (85248, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.7, '℃', NULL, NULL, '2026-11-02 11:21:43.187', '2026-11-02 11:21:43.187');
INSERT INTO `device_sensor_record` VALUES (85249, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.1, '℃', NULL, NULL, '2026-11-02 11:21:43.187', '2026-11-02 11:21:43.187');
INSERT INTO `device_sensor_record` VALUES (85250, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.22, 'V', NULL, NULL, '2026-11-02 11:21:43.187', '2026-11-02 11:21:43.187');
INSERT INTO `device_sensor_record` VALUES (85251, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 167552, 'bytes', NULL, NULL, '2026-11-02 11:21:43.187', '2026-11-02 11:21:43.187');
INSERT INTO `device_sensor_record` VALUES (85252, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:21:53.192', '2026-11-02 11:21:53.192');
INSERT INTO `device_sensor_record` VALUES (85253, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.1, '%', NULL, NULL, '2026-11-02 11:21:53.192', '2026-11-02 11:21:53.192');
INSERT INTO `device_sensor_record` VALUES (85254, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 31, 'μg/m³', NULL, NULL, '2026-11-02 11:21:53.192', '2026-11-02 11:21:53.192');
INSERT INTO `device_sensor_record` VALUES (85255, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 411.1, 'ppm', NULL, NULL, '2026-11-02 11:21:53.192', '2026-11-02 11:21:53.192');
INSERT INTO `device_sensor_record` VALUES (85256, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 422.6, 'lx', NULL, NULL, '2026-11-02 11:21:53.192', '2026-11-02 11:21:53.192');
INSERT INTO `device_sensor_record` VALUES (85257, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.6, '℃', NULL, NULL, '2026-11-02 11:21:53.192', '2026-11-02 11:21:53.192');
INSERT INTO `device_sensor_record` VALUES (85258, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:21:53.192', '2026-11-02 11:21:53.192');
INSERT INTO `device_sensor_record` VALUES (85259, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.9, '℃', NULL, NULL, '2026-11-02 11:21:53.192', '2026-11-02 11:21:53.192');
INSERT INTO `device_sensor_record` VALUES (85260, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.22, 'V', NULL, NULL, '2026-11-02 11:21:53.192', '2026-11-02 11:21:53.192');
INSERT INTO `device_sensor_record` VALUES (85261, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 122060, 'bytes', NULL, NULL, '2026-11-02 11:21:53.192', '2026-11-02 11:21:53.192');
INSERT INTO `device_sensor_record` VALUES (85262, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:22:03.206', '2026-11-02 11:22:03.206');
INSERT INTO `device_sensor_record` VALUES (85263, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.8, '%', NULL, NULL, '2026-11-02 11:22:03.206', '2026-11-02 11:22:03.206');
INSERT INTO `device_sensor_record` VALUES (85264, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:22:03.206', '2026-11-02 11:22:03.206');
INSERT INTO `device_sensor_record` VALUES (85265, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 570.2, 'ppm', NULL, NULL, '2026-11-02 11:22:03.206', '2026-11-02 11:22:03.206');
INSERT INTO `device_sensor_record` VALUES (85266, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 663, 'lx', NULL, NULL, '2026-11-02 11:22:03.206', '2026-11-02 11:22:03.206');
INSERT INTO `device_sensor_record` VALUES (85267, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.3, '℃', NULL, NULL, '2026-11-02 11:22:03.206', '2026-11-02 11:22:03.206');
INSERT INTO `device_sensor_record` VALUES (85268, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.6, '℃', NULL, NULL, '2026-11-02 11:22:03.206', '2026-11-02 11:22:03.206');
INSERT INTO `device_sensor_record` VALUES (85269, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.2, '℃', NULL, NULL, '2026-11-02 11:22:03.206', '2026-11-02 11:22:03.206');
INSERT INTO `device_sensor_record` VALUES (85270, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.39, 'V', NULL, NULL, '2026-11-02 11:22:03.206', '2026-11-02 11:22:03.206');
INSERT INTO `device_sensor_record` VALUES (85271, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 123994, 'bytes', NULL, NULL, '2026-11-02 11:22:03.206', '2026-11-02 11:22:03.206');
INSERT INTO `device_sensor_record` VALUES (85272, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:22:13.221', '2026-11-02 11:22:13.221');
INSERT INTO `device_sensor_record` VALUES (85273, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.9, '%', NULL, NULL, '2026-11-02 11:22:13.221', '2026-11-02 11:22:13.221');
INSERT INTO `device_sensor_record` VALUES (85274, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.8, 'μg/m³', NULL, NULL, '2026-11-02 11:22:13.221', '2026-11-02 11:22:13.221');
INSERT INTO `device_sensor_record` VALUES (85275, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 411.4, 'ppm', NULL, NULL, '2026-11-02 11:22:13.221', '2026-11-02 11:22:13.221');
INSERT INTO `device_sensor_record` VALUES (85276, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 553.3, 'lx', NULL, NULL, '2026-11-02 11:22:13.221', '2026-11-02 11:22:13.221');
INSERT INTO `device_sensor_record` VALUES (85277, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.8, '℃', NULL, NULL, '2026-11-02 11:22:13.221', '2026-11-02 11:22:13.221');
INSERT INTO `device_sensor_record` VALUES (85278, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-02 11:22:13.221', '2026-11-02 11:22:13.221');
INSERT INTO `device_sensor_record` VALUES (85279, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51, '℃', NULL, NULL, '2026-11-02 11:22:13.221', '2026-11-02 11:22:13.221');
INSERT INTO `device_sensor_record` VALUES (85280, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:22:13.221', '2026-11-02 11:22:13.221');
INSERT INTO `device_sensor_record` VALUES (85281, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 151263, 'bytes', NULL, NULL, '2026-11-02 11:22:13.221', '2026-11-02 11:22:13.221');
INSERT INTO `device_sensor_record` VALUES (85282, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27, '℃', NULL, NULL, '2026-11-02 11:22:23.236', '2026-11-02 11:22:23.236');
INSERT INTO `device_sensor_record` VALUES (85283, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.3, '%', NULL, NULL, '2026-11-02 11:22:23.236', '2026-11-02 11:22:23.236');
INSERT INTO `device_sensor_record` VALUES (85284, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 36, 'μg/m³', NULL, NULL, '2026-11-02 11:22:23.236', '2026-11-02 11:22:23.236');
INSERT INTO `device_sensor_record` VALUES (85285, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 422.1, 'ppm', NULL, NULL, '2026-11-02 11:22:23.236', '2026-11-02 11:22:23.236');
INSERT INTO `device_sensor_record` VALUES (85286, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 687.6, 'lx', NULL, NULL, '2026-11-02 11:22:23.236', '2026-11-02 11:22:23.236');
INSERT INTO `device_sensor_record` VALUES (85287, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-02 11:22:23.236', '2026-11-02 11:22:23.236');
INSERT INTO `device_sensor_record` VALUES (85288, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-02 11:22:23.236', '2026-11-02 11:22:23.236');
INSERT INTO `device_sensor_record` VALUES (85289, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.8, '℃', NULL, NULL, '2026-11-02 11:22:23.236', '2026-11-02 11:22:23.236');
INSERT INTO `device_sensor_record` VALUES (85290, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.29, 'V', NULL, NULL, '2026-11-02 11:22:23.236', '2026-11-02 11:22:23.236');
INSERT INTO `device_sensor_record` VALUES (85291, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 152577, 'bytes', NULL, NULL, '2026-11-02 11:22:23.236', '2026-11-02 11:22:23.236');
INSERT INTO `device_sensor_record` VALUES (85292, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.4, '℃', NULL, NULL, '2026-11-02 11:22:33.251', '2026-11-02 11:22:33.251');
INSERT INTO `device_sensor_record` VALUES (85293, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54, '%', NULL, NULL, '2026-11-02 11:22:33.251', '2026-11-02 11:22:33.251');
INSERT INTO `device_sensor_record` VALUES (85294, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 20, 'μg/m³', NULL, NULL, '2026-11-02 11:22:33.251', '2026-11-02 11:22:33.251');
INSERT INTO `device_sensor_record` VALUES (85295, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 539, 'ppm', NULL, NULL, '2026-11-02 11:22:33.251', '2026-11-02 11:22:33.251');
INSERT INTO `device_sensor_record` VALUES (85296, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 692.3, 'lx', NULL, NULL, '2026-11-02 11:22:33.251', '2026-11-02 11:22:33.251');
INSERT INTO `device_sensor_record` VALUES (85297, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.3, '℃', NULL, NULL, '2026-11-02 11:22:33.251', '2026-11-02 11:22:33.251');
INSERT INTO `device_sensor_record` VALUES (85298, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.7, '℃', NULL, NULL, '2026-11-02 11:22:33.251', '2026-11-02 11:22:33.251');
INSERT INTO `device_sensor_record` VALUES (85299, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.6, '℃', NULL, NULL, '2026-11-02 11:22:33.251', '2026-11-02 11:22:33.251');
INSERT INTO `device_sensor_record` VALUES (85300, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.34, 'V', NULL, NULL, '2026-11-02 11:22:33.251', '2026-11-02 11:22:33.251');
INSERT INTO `device_sensor_record` VALUES (85301, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 155697, 'bytes', NULL, NULL, '2026-11-02 11:22:33.251', '2026-11-02 11:22:33.251');
INSERT INTO `device_sensor_record` VALUES (85302, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:22:43.262', '2026-11-02 11:22:43.262');
INSERT INTO `device_sensor_record` VALUES (85303, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.3, '%', NULL, NULL, '2026-11-02 11:22:43.262', '2026-11-02 11:22:43.262');
INSERT INTO `device_sensor_record` VALUES (85304, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 46.1, 'μg/m³', NULL, NULL, '2026-11-02 11:22:43.262', '2026-11-02 11:22:43.262');
INSERT INTO `device_sensor_record` VALUES (85305, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 557.4, 'ppm', NULL, NULL, '2026-11-02 11:22:43.262', '2026-11-02 11:22:43.262');
INSERT INTO `device_sensor_record` VALUES (85306, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 428.8, 'lx', NULL, NULL, '2026-11-02 11:22:43.262', '2026-11-02 11:22:43.262');
INSERT INTO `device_sensor_record` VALUES (85307, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.7, '℃', NULL, NULL, '2026-11-02 11:22:43.262', '2026-11-02 11:22:43.262');
INSERT INTO `device_sensor_record` VALUES (85308, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.2, '℃', NULL, NULL, '2026-11-02 11:22:43.262', '2026-11-02 11:22:43.262');
INSERT INTO `device_sensor_record` VALUES (85309, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.8, '℃', NULL, NULL, '2026-11-02 11:22:43.262', '2026-11-02 11:22:43.262');
INSERT INTO `device_sensor_record` VALUES (85310, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-02 11:22:43.262', '2026-11-02 11:22:43.262');
INSERT INTO `device_sensor_record` VALUES (85311, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 174521, 'bytes', NULL, NULL, '2026-11-02 11:22:43.262', '2026-11-02 11:22:43.262');
INSERT INTO `device_sensor_record` VALUES (85312, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:22:53.270', '2026-11-02 11:22:53.270');
INSERT INTO `device_sensor_record` VALUES (85313, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.7, '%', NULL, NULL, '2026-11-02 11:22:53.270', '2026-11-02 11:22:53.270');
INSERT INTO `device_sensor_record` VALUES (85314, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:22:53.270', '2026-11-02 11:22:53.270');
INSERT INTO `device_sensor_record` VALUES (85315, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 403.5, 'ppm', NULL, NULL, '2026-11-02 11:22:53.270', '2026-11-02 11:22:53.270');
INSERT INTO `device_sensor_record` VALUES (85316, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 644.1, 'lx', NULL, NULL, '2026-11-02 11:22:53.270', '2026-11-02 11:22:53.270');
INSERT INTO `device_sensor_record` VALUES (85317, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.3, '℃', NULL, NULL, '2026-11-02 11:22:53.270', '2026-11-02 11:22:53.270');
INSERT INTO `device_sensor_record` VALUES (85318, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-02 11:22:53.270', '2026-11-02 11:22:53.270');
INSERT INTO `device_sensor_record` VALUES (85319, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.1, '℃', NULL, NULL, '2026-11-02 11:22:53.270', '2026-11-02 11:22:53.270');
INSERT INTO `device_sensor_record` VALUES (85320, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-02 11:22:53.270', '2026-11-02 11:22:53.270');
INSERT INTO `device_sensor_record` VALUES (85321, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 140733, 'bytes', NULL, NULL, '2026-11-02 11:22:53.270', '2026-11-02 11:22:53.270');
INSERT INTO `device_sensor_record` VALUES (85322, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-02 11:23:03.286', '2026-11-02 11:23:03.286');
INSERT INTO `device_sensor_record` VALUES (85323, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.2, '%', NULL, NULL, '2026-11-02 11:23:03.286', '2026-11-02 11:23:03.286');
INSERT INTO `device_sensor_record` VALUES (85324, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 25, 'μg/m³', NULL, NULL, '2026-11-02 11:23:03.286', '2026-11-02 11:23:03.286');
INSERT INTO `device_sensor_record` VALUES (85325, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 567.6, 'ppm', NULL, NULL, '2026-11-02 11:23:03.286', '2026-11-02 11:23:03.286');
INSERT INTO `device_sensor_record` VALUES (85326, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 703, 'lx', NULL, NULL, '2026-11-02 11:23:03.286', '2026-11-02 11:23:03.286');
INSERT INTO `device_sensor_record` VALUES (85327, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-02 11:23:03.286', '2026-11-02 11:23:03.286');
INSERT INTO `device_sensor_record` VALUES (85328, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-02 11:23:03.286', '2026-11-02 11:23:03.286');
INSERT INTO `device_sensor_record` VALUES (85329, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49, '℃', NULL, NULL, '2026-11-02 11:23:03.286', '2026-11-02 11:23:03.286');
INSERT INTO `device_sensor_record` VALUES (85330, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.39, 'V', NULL, NULL, '2026-11-02 11:23:03.286', '2026-11-02 11:23:03.286');
INSERT INTO `device_sensor_record` VALUES (85331, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 175533, 'bytes', NULL, NULL, '2026-11-02 11:23:03.286', '2026-11-02 11:23:03.286');
INSERT INTO `device_sensor_record` VALUES (85332, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.7, '℃', NULL, NULL, '2026-11-02 11:23:13.296', '2026-11-02 11:23:13.296');
INSERT INTO `device_sensor_record` VALUES (85333, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58, '%', NULL, NULL, '2026-11-02 11:23:13.296', '2026-11-02 11:23:13.296');
INSERT INTO `device_sensor_record` VALUES (85334, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 41.4, 'μg/m³', NULL, NULL, '2026-11-02 11:23:13.296', '2026-11-02 11:23:13.296');
INSERT INTO `device_sensor_record` VALUES (85335, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 425.9, 'ppm', NULL, NULL, '2026-11-02 11:23:13.296', '2026-11-02 11:23:13.296');
INSERT INTO `device_sensor_record` VALUES (85336, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 111.5, 'lx', NULL, NULL, '2026-11-02 11:23:13.296', '2026-11-02 11:23:13.296');
INSERT INTO `device_sensor_record` VALUES (85337, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-02 11:23:13.296', '2026-11-02 11:23:13.296');
INSERT INTO `device_sensor_record` VALUES (85338, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:23:13.296', '2026-11-02 11:23:13.296');
INSERT INTO `device_sensor_record` VALUES (85339, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.4, '℃', NULL, NULL, '2026-11-02 11:23:13.296', '2026-11-02 11:23:13.296');
INSERT INTO `device_sensor_record` VALUES (85340, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-02 11:23:13.296', '2026-11-02 11:23:13.296');
INSERT INTO `device_sensor_record` VALUES (85341, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 167619, 'bytes', NULL, NULL, '2026-11-02 11:23:13.296', '2026-11-02 11:23:13.296');
INSERT INTO `device_sensor_record` VALUES (85342, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.7, '℃', NULL, NULL, '2026-11-02 11:23:23.301', '2026-11-02 11:23:23.301');
INSERT INTO `device_sensor_record` VALUES (85343, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.2, '%', NULL, NULL, '2026-11-02 11:23:23.301', '2026-11-02 11:23:23.301');
INSERT INTO `device_sensor_record` VALUES (85344, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 43.6, 'μg/m³', NULL, NULL, '2026-11-02 11:23:23.301', '2026-11-02 11:23:23.301');
INSERT INTO `device_sensor_record` VALUES (85345, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 454.8, 'ppm', NULL, NULL, '2026-11-02 11:23:23.301', '2026-11-02 11:23:23.301');
INSERT INTO `device_sensor_record` VALUES (85346, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 792.5, 'lx', NULL, NULL, '2026-11-02 11:23:23.301', '2026-11-02 11:23:23.301');
INSERT INTO `device_sensor_record` VALUES (85347, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-02 11:23:23.301', '2026-11-02 11:23:23.301');
INSERT INTO `device_sensor_record` VALUES (85348, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:23:23.301', '2026-11-02 11:23:23.301');
INSERT INTO `device_sensor_record` VALUES (85349, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.3, '℃', NULL, NULL, '2026-11-02 11:23:23.301', '2026-11-02 11:23:23.301');
INSERT INTO `device_sensor_record` VALUES (85350, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-02 11:23:23.301', '2026-11-02 11:23:23.301');
INSERT INTO `device_sensor_record` VALUES (85351, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 144823, 'bytes', NULL, NULL, '2026-11-02 11:23:23.301', '2026-11-02 11:23:23.301');
INSERT INTO `device_sensor_record` VALUES (85352, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.9, '℃', NULL, NULL, '2026-11-02 11:23:33.314', '2026-11-02 11:23:33.314');
INSERT INTO `device_sensor_record` VALUES (85353, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.4, '%', NULL, NULL, '2026-11-02 11:23:33.314', '2026-11-02 11:23:33.314');
INSERT INTO `device_sensor_record` VALUES (85354, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 45.5, 'μg/m³', NULL, NULL, '2026-11-02 11:23:33.314', '2026-11-02 11:23:33.314');
INSERT INTO `device_sensor_record` VALUES (85355, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 533.4, 'ppm', NULL, NULL, '2026-11-02 11:23:33.314', '2026-11-02 11:23:33.314');
INSERT INTO `device_sensor_record` VALUES (85356, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 553, 'lx', NULL, NULL, '2026-11-02 11:23:33.314', '2026-11-02 11:23:33.314');
INSERT INTO `device_sensor_record` VALUES (85357, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.6, '℃', NULL, NULL, '2026-11-02 11:23:33.314', '2026-11-02 11:23:33.314');
INSERT INTO `device_sensor_record` VALUES (85358, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-02 11:23:33.314', '2026-11-02 11:23:33.314');
INSERT INTO `device_sensor_record` VALUES (85359, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.6, '℃', NULL, NULL, '2026-11-02 11:23:33.314', '2026-11-02 11:23:33.314');
INSERT INTO `device_sensor_record` VALUES (85360, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-02 11:23:33.314', '2026-11-02 11:23:33.314');
INSERT INTO `device_sensor_record` VALUES (85361, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 131651, 'bytes', NULL, NULL, '2026-11-02 11:23:33.314', '2026-11-02 11:23:33.314');
INSERT INTO `device_sensor_record` VALUES (85362, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:23:43.313', '2026-11-02 11:23:43.313');
INSERT INTO `device_sensor_record` VALUES (85363, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52, '%', NULL, NULL, '2026-11-02 11:23:43.313', '2026-11-02 11:23:43.313');
INSERT INTO `device_sensor_record` VALUES (85364, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:23:43.313', '2026-11-02 11:23:43.313');
INSERT INTO `device_sensor_record` VALUES (85365, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 403.1, 'ppm', NULL, NULL, '2026-11-02 11:23:43.313', '2026-11-02 11:23:43.313');
INSERT INTO `device_sensor_record` VALUES (85366, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 680.4, 'lx', NULL, NULL, '2026-11-02 11:23:43.313', '2026-11-02 11:23:43.313');
INSERT INTO `device_sensor_record` VALUES (85367, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.1, '℃', NULL, NULL, '2026-11-02 11:23:43.313', '2026-11-02 11:23:43.313');
INSERT INTO `device_sensor_record` VALUES (85368, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.5, '℃', NULL, NULL, '2026-11-02 11:23:43.313', '2026-11-02 11:23:43.313');
INSERT INTO `device_sensor_record` VALUES (85369, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.7, '℃', NULL, NULL, '2026-11-02 11:23:43.313', '2026-11-02 11:23:43.313');
INSERT INTO `device_sensor_record` VALUES (85370, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-02 11:23:43.313', '2026-11-02 11:23:43.313');
INSERT INTO `device_sensor_record` VALUES (85371, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 179555, 'bytes', NULL, NULL, '2026-11-02 11:23:43.313', '2026-11-02 11:23:43.313');
INSERT INTO `device_sensor_record` VALUES (85372, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-02 11:23:53.324', '2026-11-02 11:23:53.324');
INSERT INTO `device_sensor_record` VALUES (85373, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60.2, '%', NULL, NULL, '2026-11-02 11:23:53.324', '2026-11-02 11:23:53.324');
INSERT INTO `device_sensor_record` VALUES (85374, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 45.2, 'μg/m³', NULL, NULL, '2026-11-02 11:23:53.324', '2026-11-02 11:23:53.324');
INSERT INTO `device_sensor_record` VALUES (85375, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 558.8, 'ppm', NULL, NULL, '2026-11-02 11:23:53.324', '2026-11-02 11:23:53.324');
INSERT INTO `device_sensor_record` VALUES (85376, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 737.4, 'lx', NULL, NULL, '2026-11-02 11:23:53.324', '2026-11-02 11:23:53.324');
INSERT INTO `device_sensor_record` VALUES (85377, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-02 11:23:53.324', '2026-11-02 11:23:53.324');
INSERT INTO `device_sensor_record` VALUES (85378, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-02 11:23:53.324', '2026-11-02 11:23:53.324');
INSERT INTO `device_sensor_record` VALUES (85379, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.6, '℃', NULL, NULL, '2026-11-02 11:23:53.324', '2026-11-02 11:23:53.324');
INSERT INTO `device_sensor_record` VALUES (85380, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-02 11:23:53.324', '2026-11-02 11:23:53.324');
INSERT INTO `device_sensor_record` VALUES (85381, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 174186, 'bytes', NULL, NULL, '2026-11-02 11:23:53.324', '2026-11-02 11:23:53.324');
INSERT INTO `device_sensor_record` VALUES (85382, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-02 11:24:03.326', '2026-11-02 11:24:03.326');
INSERT INTO `device_sensor_record` VALUES (85383, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.4, '%', NULL, NULL, '2026-11-02 11:24:03.326', '2026-11-02 11:24:03.326');
INSERT INTO `device_sensor_record` VALUES (85384, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 22.7, 'μg/m³', NULL, NULL, '2026-11-02 11:24:03.326', '2026-11-02 11:24:03.326');
INSERT INTO `device_sensor_record` VALUES (85385, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 447.4, 'ppm', NULL, NULL, '2026-11-02 11:24:03.326', '2026-11-02 11:24:03.326');
INSERT INTO `device_sensor_record` VALUES (85386, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 471.4, 'lx', NULL, NULL, '2026-11-02 11:24:03.326', '2026-11-02 11:24:03.326');
INSERT INTO `device_sensor_record` VALUES (85387, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.6, '℃', NULL, NULL, '2026-11-02 11:24:03.326', '2026-11-02 11:24:03.326');
INSERT INTO `device_sensor_record` VALUES (85388, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:24:03.326', '2026-11-02 11:24:03.326');
INSERT INTO `device_sensor_record` VALUES (85389, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.9, '℃', NULL, NULL, '2026-11-02 11:24:03.326', '2026-11-02 11:24:03.326');
INSERT INTO `device_sensor_record` VALUES (85390, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-02 11:24:03.326', '2026-11-02 11:24:03.326');
INSERT INTO `device_sensor_record` VALUES (85391, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 133018, 'bytes', NULL, NULL, '2026-11-02 11:24:03.326', '2026-11-02 11:24:03.326');
INSERT INTO `device_sensor_record` VALUES (85392, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-02 11:24:13.334', '2026-11-02 11:24:13.334');
INSERT INTO `device_sensor_record` VALUES (85393, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 51.2, '%', NULL, NULL, '2026-11-02 11:24:13.334', '2026-11-02 11:24:13.334');
INSERT INTO `device_sensor_record` VALUES (85394, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.2, 'μg/m³', NULL, NULL, '2026-11-02 11:24:13.334', '2026-11-02 11:24:13.334');
INSERT INTO `device_sensor_record` VALUES (85395, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 545.9, 'ppm', NULL, NULL, '2026-11-02 11:24:13.334', '2026-11-02 11:24:13.334');
INSERT INTO `device_sensor_record` VALUES (85396, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 656.2, 'lx', NULL, NULL, '2026-11-02 11:24:13.334', '2026-11-02 11:24:13.334');
INSERT INTO `device_sensor_record` VALUES (85397, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-02 11:24:13.334', '2026-11-02 11:24:13.334');
INSERT INTO `device_sensor_record` VALUES (85398, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.4, '℃', NULL, NULL, '2026-11-02 11:24:13.334', '2026-11-02 11:24:13.334');
INSERT INTO `device_sensor_record` VALUES (85399, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.5, '℃', NULL, NULL, '2026-11-02 11:24:13.334', '2026-11-02 11:24:13.334');
INSERT INTO `device_sensor_record` VALUES (85400, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-02 11:24:13.334', '2026-11-02 11:24:13.334');
INSERT INTO `device_sensor_record` VALUES (85401, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 151303, 'bytes', NULL, NULL, '2026-11-02 11:24:13.334', '2026-11-02 11:24:13.334');
INSERT INTO `device_sensor_record` VALUES (85402, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.7, '℃', NULL, NULL, '2026-11-02 11:24:23.342', '2026-11-02 11:24:23.342');
INSERT INTO `device_sensor_record` VALUES (85403, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62.3, '%', NULL, NULL, '2026-11-02 11:24:23.342', '2026-11-02 11:24:23.342');
INSERT INTO `device_sensor_record` VALUES (85404, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 34.8, 'μg/m³', NULL, NULL, '2026-11-02 11:24:23.342', '2026-11-02 11:24:23.342');
INSERT INTO `device_sensor_record` VALUES (85405, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 457.2, 'ppm', NULL, NULL, '2026-11-02 11:24:23.342', '2026-11-02 11:24:23.342');
INSERT INTO `device_sensor_record` VALUES (85406, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 682.1, 'lx', NULL, NULL, '2026-11-02 11:24:23.342', '2026-11-02 11:24:23.342');
INSERT INTO `device_sensor_record` VALUES (85407, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.5, '℃', NULL, NULL, '2026-11-02 11:24:23.342', '2026-11-02 11:24:23.342');
INSERT INTO `device_sensor_record` VALUES (85408, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-02 11:24:23.342', '2026-11-02 11:24:23.342');
INSERT INTO `device_sensor_record` VALUES (85409, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.7, '℃', NULL, NULL, '2026-11-02 11:24:23.342', '2026-11-02 11:24:23.342');
INSERT INTO `device_sensor_record` VALUES (85410, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-02 11:24:23.342', '2026-11-02 11:24:23.342');
INSERT INTO `device_sensor_record` VALUES (85411, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 170902, 'bytes', NULL, NULL, '2026-11-02 11:24:23.342', '2026-11-02 11:24:23.342');
INSERT INTO `device_sensor_record` VALUES (85412, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:24:33.342', '2026-11-02 11:24:33.342');
INSERT INTO `device_sensor_record` VALUES (85413, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.2, '%', NULL, NULL, '2026-11-02 11:24:33.342', '2026-11-02 11:24:33.342');
INSERT INTO `device_sensor_record` VALUES (85414, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:24:33.342', '2026-11-02 11:24:33.342');
INSERT INTO `device_sensor_record` VALUES (85415, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 599, 'ppm', NULL, NULL, '2026-11-02 11:24:33.342', '2026-11-02 11:24:33.342');
INSERT INTO `device_sensor_record` VALUES (85416, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 350.9, 'lx', NULL, NULL, '2026-11-02 11:24:33.342', '2026-11-02 11:24:33.342');
INSERT INTO `device_sensor_record` VALUES (85417, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-02 11:24:33.342', '2026-11-02 11:24:33.342');
INSERT INTO `device_sensor_record` VALUES (85418, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.7, '℃', NULL, NULL, '2026-11-02 11:24:33.342', '2026-11-02 11:24:33.342');
INSERT INTO `device_sensor_record` VALUES (85419, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47, '℃', NULL, NULL, '2026-11-02 11:24:33.342', '2026-11-02 11:24:33.342');
INSERT INTO `device_sensor_record` VALUES (85420, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-02 11:24:33.342', '2026-11-02 11:24:33.342');
INSERT INTO `device_sensor_record` VALUES (85421, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 136462, 'bytes', NULL, NULL, '2026-11-02 11:24:33.342', '2026-11-02 11:24:33.342');
INSERT INTO `device_sensor_record` VALUES (85422, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.9, '℃', NULL, NULL, '2026-11-02 11:24:43.357', '2026-11-02 11:24:43.357');
INSERT INTO `device_sensor_record` VALUES (85423, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.2, '%', NULL, NULL, '2026-11-02 11:24:43.357', '2026-11-02 11:24:43.357');
INSERT INTO `device_sensor_record` VALUES (85424, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 20.9, 'μg/m³', NULL, NULL, '2026-11-02 11:24:43.357', '2026-11-02 11:24:43.357');
INSERT INTO `device_sensor_record` VALUES (85425, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 484.6, 'ppm', NULL, NULL, '2026-11-02 11:24:43.357', '2026-11-02 11:24:43.357');
INSERT INTO `device_sensor_record` VALUES (85426, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 190.7, 'lx', NULL, NULL, '2026-11-02 11:24:43.357', '2026-11-02 11:24:43.357');
INSERT INTO `device_sensor_record` VALUES (85427, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.2, '℃', NULL, NULL, '2026-11-02 11:24:43.357', '2026-11-02 11:24:43.357');
INSERT INTO `device_sensor_record` VALUES (85428, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.5, '℃', NULL, NULL, '2026-11-02 11:24:43.357', '2026-11-02 11:24:43.357');
INSERT INTO `device_sensor_record` VALUES (85429, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.9, '℃', NULL, NULL, '2026-11-02 11:24:43.357', '2026-11-02 11:24:43.357');
INSERT INTO `device_sensor_record` VALUES (85430, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-02 11:24:43.357', '2026-11-02 11:24:43.357');
INSERT INTO `device_sensor_record` VALUES (85431, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 146888, 'bytes', NULL, NULL, '2026-11-02 11:24:43.357', '2026-11-02 11:24:43.357');
INSERT INTO `device_sensor_record` VALUES (85432, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:24:53.376', '2026-11-02 11:24:53.376');
INSERT INTO `device_sensor_record` VALUES (85433, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60.8, '%', NULL, NULL, '2026-11-02 11:24:53.376', '2026-11-02 11:24:53.376');
INSERT INTO `device_sensor_record` VALUES (85434, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 44.1, 'μg/m³', NULL, NULL, '2026-11-02 11:24:53.376', '2026-11-02 11:24:53.376');
INSERT INTO `device_sensor_record` VALUES (85435, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 454.1, 'ppm', NULL, NULL, '2026-11-02 11:24:53.376', '2026-11-02 11:24:53.376');
INSERT INTO `device_sensor_record` VALUES (85436, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 447.2, 'lx', NULL, NULL, '2026-11-02 11:24:53.376', '2026-11-02 11:24:53.376');
INSERT INTO `device_sensor_record` VALUES (85437, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-02 11:24:53.376', '2026-11-02 11:24:53.376');
INSERT INTO `device_sensor_record` VALUES (85438, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-02 11:24:53.376', '2026-11-02 11:24:53.376');
INSERT INTO `device_sensor_record` VALUES (85439, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.1, '℃', NULL, NULL, '2026-11-02 11:24:53.376', '2026-11-02 11:24:53.376');
INSERT INTO `device_sensor_record` VALUES (85440, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-02 11:24:53.376', '2026-11-02 11:24:53.376');
INSERT INTO `device_sensor_record` VALUES (85441, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 153833, 'bytes', NULL, NULL, '2026-11-02 11:24:53.376', '2026-11-02 11:24:53.376');
INSERT INTO `device_sensor_record` VALUES (85442, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:25:03.386', '2026-11-02 11:25:03.386');
INSERT INTO `device_sensor_record` VALUES (85443, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.9, '%', NULL, NULL, '2026-11-02 11:25:03.386', '2026-11-02 11:25:03.386');
INSERT INTO `device_sensor_record` VALUES (85444, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 40.5, 'μg/m³', NULL, NULL, '2026-11-02 11:25:03.386', '2026-11-02 11:25:03.386');
INSERT INTO `device_sensor_record` VALUES (85445, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 561.9, 'ppm', NULL, NULL, '2026-11-02 11:25:03.386', '2026-11-02 11:25:03.386');
INSERT INTO `device_sensor_record` VALUES (85446, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 419.2, 'lx', NULL, NULL, '2026-11-02 11:25:03.386', '2026-11-02 11:25:03.386');
INSERT INTO `device_sensor_record` VALUES (85447, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.1, '℃', NULL, NULL, '2026-11-02 11:25:03.386', '2026-11-02 11:25:03.386');
INSERT INTO `device_sensor_record` VALUES (85448, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:25:03.386', '2026-11-02 11:25:03.386');
INSERT INTO `device_sensor_record` VALUES (85449, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.9, '℃', NULL, NULL, '2026-11-02 11:25:03.386', '2026-11-02 11:25:03.386');
INSERT INTO `device_sensor_record` VALUES (85450, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-02 11:25:03.386', '2026-11-02 11:25:03.386');
INSERT INTO `device_sensor_record` VALUES (85451, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 122991, 'bytes', NULL, NULL, '2026-11-02 11:25:03.386', '2026-11-02 11:25:03.386');
INSERT INTO `device_sensor_record` VALUES (85452, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.6, '℃', NULL, NULL, '2026-11-02 11:25:13.397', '2026-11-02 11:25:13.397');
INSERT INTO `device_sensor_record` VALUES (85453, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.7, '%', NULL, NULL, '2026-11-02 11:25:13.397', '2026-11-02 11:25:13.397');
INSERT INTO `device_sensor_record` VALUES (85454, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 39, 'μg/m³', NULL, NULL, '2026-11-02 11:25:13.397', '2026-11-02 11:25:13.397');
INSERT INTO `device_sensor_record` VALUES (85455, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 595.6, 'ppm', NULL, NULL, '2026-11-02 11:25:13.397', '2026-11-02 11:25:13.397');
INSERT INTO `device_sensor_record` VALUES (85456, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 115.3, 'lx', NULL, NULL, '2026-11-02 11:25:13.397', '2026-11-02 11:25:13.397');
INSERT INTO `device_sensor_record` VALUES (85457, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.4, '℃', NULL, NULL, '2026-11-02 11:25:13.397', '2026-11-02 11:25:13.397');
INSERT INTO `device_sensor_record` VALUES (85458, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-02 11:25:13.397', '2026-11-02 11:25:13.397');
INSERT INTO `device_sensor_record` VALUES (85459, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.7, '℃', NULL, NULL, '2026-11-02 11:25:13.397', '2026-11-02 11:25:13.397');
INSERT INTO `device_sensor_record` VALUES (85460, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-02 11:25:13.397', '2026-11-02 11:25:13.397');
INSERT INTO `device_sensor_record` VALUES (85461, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 136180, 'bytes', NULL, NULL, '2026-11-02 11:25:13.397', '2026-11-02 11:25:13.397');
INSERT INTO `device_sensor_record` VALUES (85462, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:25:23.412', '2026-11-02 11:25:23.412');
INSERT INTO `device_sensor_record` VALUES (85463, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.5, '%', NULL, NULL, '2026-11-02 11:25:23.412', '2026-11-02 11:25:23.412');
INSERT INTO `device_sensor_record` VALUES (85464, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:25:23.412', '2026-11-02 11:25:23.412');
INSERT INTO `device_sensor_record` VALUES (85465, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 404.2, 'ppm', NULL, NULL, '2026-11-02 11:25:23.412', '2026-11-02 11:25:23.412');
INSERT INTO `device_sensor_record` VALUES (85466, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 694.1, 'lx', NULL, NULL, '2026-11-02 11:25:23.412', '2026-11-02 11:25:23.412');
INSERT INTO `device_sensor_record` VALUES (85467, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:25:23.412', '2026-11-02 11:25:23.412');
INSERT INTO `device_sensor_record` VALUES (85468, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 26, '℃', NULL, NULL, '2026-11-02 11:25:23.412', '2026-11-02 11:25:23.412');
INSERT INTO `device_sensor_record` VALUES (85469, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.9, '℃', NULL, NULL, '2026-11-02 11:25:23.412', '2026-11-02 11:25:23.412');
INSERT INTO `device_sensor_record` VALUES (85470, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-02 11:25:23.412', '2026-11-02 11:25:23.412');
INSERT INTO `device_sensor_record` VALUES (85471, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 127104, 'bytes', NULL, NULL, '2026-11-02 11:25:23.412', '2026-11-02 11:25:23.412');
INSERT INTO `device_sensor_record` VALUES (85472, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.9, '℃', NULL, NULL, '2026-11-02 11:25:33.427', '2026-11-02 11:25:33.427');
INSERT INTO `device_sensor_record` VALUES (85473, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.4, '%', NULL, NULL, '2026-11-02 11:25:33.427', '2026-11-02 11:25:33.427');
INSERT INTO `device_sensor_record` VALUES (85474, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 46.8, 'μg/m³', NULL, NULL, '2026-11-02 11:25:33.427', '2026-11-02 11:25:33.427');
INSERT INTO `device_sensor_record` VALUES (85475, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 551.7, 'ppm', NULL, NULL, '2026-11-02 11:25:33.427', '2026-11-02 11:25:33.427');
INSERT INTO `device_sensor_record` VALUES (85476, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 387.3, 'lx', NULL, NULL, '2026-11-02 11:25:33.427', '2026-11-02 11:25:33.427');
INSERT INTO `device_sensor_record` VALUES (85477, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20, '℃', NULL, NULL, '2026-11-02 11:25:33.427', '2026-11-02 11:25:33.427');
INSERT INTO `device_sensor_record` VALUES (85478, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.3, '℃', NULL, NULL, '2026-11-02 11:25:33.427', '2026-11-02 11:25:33.427');
INSERT INTO `device_sensor_record` VALUES (85479, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.7, '℃', NULL, NULL, '2026-11-02 11:25:33.427', '2026-11-02 11:25:33.427');
INSERT INTO `device_sensor_record` VALUES (85480, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:25:33.427', '2026-11-02 11:25:33.427');
INSERT INTO `device_sensor_record` VALUES (85481, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 165926, 'bytes', NULL, NULL, '2026-11-02 11:25:33.427', '2026-11-02 11:25:33.427');
INSERT INTO `device_sensor_record` VALUES (85482, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:25:43.436', '2026-11-02 11:25:43.436');
INSERT INTO `device_sensor_record` VALUES (85483, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.9, '%', NULL, NULL, '2026-11-02 11:25:43.436', '2026-11-02 11:25:43.436');
INSERT INTO `device_sensor_record` VALUES (85484, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 27.7, 'μg/m³', NULL, NULL, '2026-11-02 11:25:43.436', '2026-11-02 11:25:43.436');
INSERT INTO `device_sensor_record` VALUES (85485, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 545, 'ppm', NULL, NULL, '2026-11-02 11:25:43.436', '2026-11-02 11:25:43.436');
INSERT INTO `device_sensor_record` VALUES (85486, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 418.2, 'lx', NULL, NULL, '2026-11-02 11:25:43.436', '2026-11-02 11:25:43.436');
INSERT INTO `device_sensor_record` VALUES (85487, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-02 11:25:43.436', '2026-11-02 11:25:43.436');
INSERT INTO `device_sensor_record` VALUES (85488, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:25:43.436', '2026-11-02 11:25:43.436');
INSERT INTO `device_sensor_record` VALUES (85489, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48, '℃', NULL, NULL, '2026-11-02 11:25:43.436', '2026-11-02 11:25:43.436');
INSERT INTO `device_sensor_record` VALUES (85490, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:25:43.436', '2026-11-02 11:25:43.436');
INSERT INTO `device_sensor_record` VALUES (85491, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 175999, 'bytes', NULL, NULL, '2026-11-02 11:25:43.436', '2026-11-02 11:25:43.436');
INSERT INTO `device_sensor_record` VALUES (85492, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-02 11:25:53.440', '2026-11-02 11:25:53.440');
INSERT INTO `device_sensor_record` VALUES (85493, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.8, '%', NULL, NULL, '2026-11-02 11:25:53.440', '2026-11-02 11:25:53.440');
INSERT INTO `device_sensor_record` VALUES (85494, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 37.5, 'μg/m³', NULL, NULL, '2026-11-02 11:25:53.440', '2026-11-02 11:25:53.440');
INSERT INTO `device_sensor_record` VALUES (85495, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 499.3, 'ppm', NULL, NULL, '2026-11-02 11:25:53.440', '2026-11-02 11:25:53.440');
INSERT INTO `device_sensor_record` VALUES (85496, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 601.7, 'lx', NULL, NULL, '2026-11-02 11:25:53.440', '2026-11-02 11:25:53.440');
INSERT INTO `device_sensor_record` VALUES (85497, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.5, '℃', NULL, NULL, '2026-11-02 11:25:53.440', '2026-11-02 11:25:53.440');
INSERT INTO `device_sensor_record` VALUES (85498, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:25:53.440', '2026-11-02 11:25:53.440');
INSERT INTO `device_sensor_record` VALUES (85499, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.5, '℃', NULL, NULL, '2026-11-02 11:25:53.440', '2026-11-02 11:25:53.440');
INSERT INTO `device_sensor_record` VALUES (85500, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:25:53.440', '2026-11-02 11:25:53.440');
INSERT INTO `device_sensor_record` VALUES (85501, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 169930, 'bytes', NULL, NULL, '2026-11-02 11:25:53.440', '2026-11-02 11:25:53.440');
INSERT INTO `device_sensor_record` VALUES (85502, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:26:03.456', '2026-11-02 11:26:03.456');
INSERT INTO `device_sensor_record` VALUES (85503, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 51.8, '%', NULL, NULL, '2026-11-02 11:26:03.456', '2026-11-02 11:26:03.456');
INSERT INTO `device_sensor_record` VALUES (85504, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 29.5, 'μg/m³', NULL, NULL, '2026-11-02 11:26:03.456', '2026-11-02 11:26:03.456');
INSERT INTO `device_sensor_record` VALUES (85505, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 466.8, 'ppm', NULL, NULL, '2026-11-02 11:26:03.456', '2026-11-02 11:26:03.456');
INSERT INTO `device_sensor_record` VALUES (85506, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 359.2, 'lx', NULL, NULL, '2026-11-02 11:26:03.456', '2026-11-02 11:26:03.456');
INSERT INTO `device_sensor_record` VALUES (85507, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-02 11:26:03.456', '2026-11-02 11:26:03.456');
INSERT INTO `device_sensor_record` VALUES (85508, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.8, '℃', NULL, NULL, '2026-11-02 11:26:03.456', '2026-11-02 11:26:03.456');
INSERT INTO `device_sensor_record` VALUES (85509, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.7, '℃', NULL, NULL, '2026-11-02 11:26:03.456', '2026-11-02 11:26:03.456');
INSERT INTO `device_sensor_record` VALUES (85510, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-02 11:26:03.456', '2026-11-02 11:26:03.456');
INSERT INTO `device_sensor_record` VALUES (85511, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 132331, 'bytes', NULL, NULL, '2026-11-02 11:26:03.456', '2026-11-02 11:26:03.456');
INSERT INTO `device_sensor_record` VALUES (85512, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:26:13.461', '2026-11-02 11:26:13.461');
INSERT INTO `device_sensor_record` VALUES (85513, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62.8, '%', NULL, NULL, '2026-11-02 11:26:13.461', '2026-11-02 11:26:13.461');
INSERT INTO `device_sensor_record` VALUES (85514, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:26:13.461', '2026-11-02 11:26:13.461');
INSERT INTO `device_sensor_record` VALUES (85515, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 493.5, 'ppm', NULL, NULL, '2026-11-02 11:26:13.461', '2026-11-02 11:26:13.461');
INSERT INTO `device_sensor_record` VALUES (85516, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 217.1, 'lx', NULL, NULL, '2026-11-02 11:26:13.461', '2026-11-02 11:26:13.461');
INSERT INTO `device_sensor_record` VALUES (85517, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.5, '℃', NULL, NULL, '2026-11-02 11:26:13.461', '2026-11-02 11:26:13.461');
INSERT INTO `device_sensor_record` VALUES (85518, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.4, '℃', NULL, NULL, '2026-11-02 11:26:13.461', '2026-11-02 11:26:13.461');
INSERT INTO `device_sensor_record` VALUES (85519, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.7, '℃', NULL, NULL, '2026-11-02 11:26:13.461', '2026-11-02 11:26:13.461');
INSERT INTO `device_sensor_record` VALUES (85520, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-02 11:26:13.461', '2026-11-02 11:26:13.461');
INSERT INTO `device_sensor_record` VALUES (85521, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 126873, 'bytes', NULL, NULL, '2026-11-02 11:26:13.461', '2026-11-02 11:26:13.461');
INSERT INTO `device_sensor_record` VALUES (85522, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26, '℃', NULL, NULL, '2026-11-02 11:26:23.472', '2026-11-02 11:26:23.472');
INSERT INTO `device_sensor_record` VALUES (85523, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 57.2, '%', NULL, NULL, '2026-11-02 11:26:23.472', '2026-11-02 11:26:23.472');
INSERT INTO `device_sensor_record` VALUES (85524, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 28.3, 'μg/m³', NULL, NULL, '2026-11-02 11:26:23.472', '2026-11-02 11:26:23.472');
INSERT INTO `device_sensor_record` VALUES (85525, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 558.7, 'ppm', NULL, NULL, '2026-11-02 11:26:23.472', '2026-11-02 11:26:23.472');
INSERT INTO `device_sensor_record` VALUES (85526, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 350.9, 'lx', NULL, NULL, '2026-11-02 11:26:23.472', '2026-11-02 11:26:23.472');
INSERT INTO `device_sensor_record` VALUES (85527, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-02 11:26:23.472', '2026-11-02 11:26:23.472');
INSERT INTO `device_sensor_record` VALUES (85528, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-02 11:26:23.472', '2026-11-02 11:26:23.472');
INSERT INTO `device_sensor_record` VALUES (85529, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.6, '℃', NULL, NULL, '2026-11-02 11:26:23.472', '2026-11-02 11:26:23.472');
INSERT INTO `device_sensor_record` VALUES (85530, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.34, 'V', NULL, NULL, '2026-11-02 11:26:23.472', '2026-11-02 11:26:23.472');
INSERT INTO `device_sensor_record` VALUES (85531, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 179781, 'bytes', NULL, NULL, '2026-11-02 11:26:23.472', '2026-11-02 11:26:23.472');
INSERT INTO `device_sensor_record` VALUES (85532, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.6, '℃', NULL, NULL, '2026-11-02 11:26:33.487', '2026-11-02 11:26:33.487');
INSERT INTO `device_sensor_record` VALUES (85533, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.7, '%', NULL, NULL, '2026-11-02 11:26:33.487', '2026-11-02 11:26:33.487');
INSERT INTO `device_sensor_record` VALUES (85534, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 25.4, 'μg/m³', NULL, NULL, '2026-11-02 11:26:33.487', '2026-11-02 11:26:33.487');
INSERT INTO `device_sensor_record` VALUES (85535, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 479.8, 'ppm', NULL, NULL, '2026-11-02 11:26:33.487', '2026-11-02 11:26:33.487');
INSERT INTO `device_sensor_record` VALUES (85536, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 188.9, 'lx', NULL, NULL, '2026-11-02 11:26:33.487', '2026-11-02 11:26:33.487');
INSERT INTO `device_sensor_record` VALUES (85537, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-02 11:26:33.487', '2026-11-02 11:26:33.487');
INSERT INTO `device_sensor_record` VALUES (85538, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:26:33.487', '2026-11-02 11:26:33.487');
INSERT INTO `device_sensor_record` VALUES (85539, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.7, '℃', NULL, NULL, '2026-11-02 11:26:33.487', '2026-11-02 11:26:33.487');
INSERT INTO `device_sensor_record` VALUES (85540, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-02 11:26:33.487', '2026-11-02 11:26:33.487');
INSERT INTO `device_sensor_record` VALUES (85541, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 129812, 'bytes', NULL, NULL, '2026-11-02 11:26:33.487', '2026-11-02 11:26:33.487');
INSERT INTO `device_sensor_record` VALUES (85542, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:26:43.495', '2026-11-02 11:26:43.495');
INSERT INTO `device_sensor_record` VALUES (85543, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.4, '%', NULL, NULL, '2026-11-02 11:26:43.495', '2026-11-02 11:26:43.495');
INSERT INTO `device_sensor_record` VALUES (85544, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 20.4, 'μg/m³', NULL, NULL, '2026-11-02 11:26:43.495', '2026-11-02 11:26:43.495');
INSERT INTO `device_sensor_record` VALUES (85545, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 485.8, 'ppm', NULL, NULL, '2026-11-02 11:26:43.495', '2026-11-02 11:26:43.495');
INSERT INTO `device_sensor_record` VALUES (85546, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 247.3, 'lx', NULL, NULL, '2026-11-02 11:26:43.495', '2026-11-02 11:26:43.495');
INSERT INTO `device_sensor_record` VALUES (85547, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.3, '℃', NULL, NULL, '2026-11-02 11:26:43.495', '2026-11-02 11:26:43.495');
INSERT INTO `device_sensor_record` VALUES (85548, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.6, '℃', NULL, NULL, '2026-11-02 11:26:43.495', '2026-11-02 11:26:43.495');
INSERT INTO `device_sensor_record` VALUES (85549, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.4, '℃', NULL, NULL, '2026-11-02 11:26:43.495', '2026-11-02 11:26:43.495');
INSERT INTO `device_sensor_record` VALUES (85550, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-02 11:26:43.495', '2026-11-02 11:26:43.495');
INSERT INTO `device_sensor_record` VALUES (85551, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 151175, 'bytes', NULL, NULL, '2026-11-02 11:26:43.495', '2026-11-02 11:26:43.495');
INSERT INTO `device_sensor_record` VALUES (85552, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.8, '℃', NULL, NULL, '2026-11-02 11:26:53.502', '2026-11-02 11:26:53.502');
INSERT INTO `device_sensor_record` VALUES (85553, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.6, '%', NULL, NULL, '2026-11-02 11:26:53.502', '2026-11-02 11:26:53.502');
INSERT INTO `device_sensor_record` VALUES (85554, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 36.2, 'μg/m³', NULL, NULL, '2026-11-02 11:26:53.502', '2026-11-02 11:26:53.502');
INSERT INTO `device_sensor_record` VALUES (85555, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 469.4, 'ppm', NULL, NULL, '2026-11-02 11:26:53.502', '2026-11-02 11:26:53.502');
INSERT INTO `device_sensor_record` VALUES (85556, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 448.6, 'lx', NULL, NULL, '2026-11-02 11:26:53.502', '2026-11-02 11:26:53.502');
INSERT INTO `device_sensor_record` VALUES (85557, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-02 11:26:53.502', '2026-11-02 11:26:53.502');
INSERT INTO `device_sensor_record` VALUES (85558, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-02 11:26:53.502', '2026-11-02 11:26:53.502');
INSERT INTO `device_sensor_record` VALUES (85559, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.2, '℃', NULL, NULL, '2026-11-02 11:26:53.502', '2026-11-02 11:26:53.502');
INSERT INTO `device_sensor_record` VALUES (85560, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.34, 'V', NULL, NULL, '2026-11-02 11:26:53.502', '2026-11-02 11:26:53.502');
INSERT INTO `device_sensor_record` VALUES (85561, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 144081, 'bytes', NULL, NULL, '2026-11-02 11:26:53.502', '2026-11-02 11:26:53.502');
INSERT INTO `device_sensor_record` VALUES (85562, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:27:03.513', '2026-11-02 11:27:03.513');
INSERT INTO `device_sensor_record` VALUES (85563, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.3, '%', NULL, NULL, '2026-11-02 11:27:03.513', '2026-11-02 11:27:03.513');
INSERT INTO `device_sensor_record` VALUES (85564, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:27:03.513', '2026-11-02 11:27:03.513');
INSERT INTO `device_sensor_record` VALUES (85565, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 582.5, 'ppm', NULL, NULL, '2026-11-02 11:27:03.513', '2026-11-02 11:27:03.513');
INSERT INTO `device_sensor_record` VALUES (85566, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 289.4, 'lx', NULL, NULL, '2026-11-02 11:27:03.513', '2026-11-02 11:27:03.513');
INSERT INTO `device_sensor_record` VALUES (85567, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-02 11:27:03.513', '2026-11-02 11:27:03.513');
INSERT INTO `device_sensor_record` VALUES (85568, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.6, '℃', NULL, NULL, '2026-11-02 11:27:03.513', '2026-11-02 11:27:03.513');
INSERT INTO `device_sensor_record` VALUES (85569, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46, '℃', NULL, NULL, '2026-11-02 11:27:03.513', '2026-11-02 11:27:03.513');
INSERT INTO `device_sensor_record` VALUES (85570, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:27:03.513', '2026-11-02 11:27:03.513');
INSERT INTO `device_sensor_record` VALUES (85571, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 161843, 'bytes', NULL, NULL, '2026-11-02 11:27:03.513', '2026-11-02 11:27:03.513');
INSERT INTO `device_sensor_record` VALUES (85572, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.2, '℃', NULL, NULL, '2026-11-02 11:27:13.519', '2026-11-02 11:27:13.519');
INSERT INTO `device_sensor_record` VALUES (85573, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.2, '%', NULL, NULL, '2026-11-02 11:27:13.519', '2026-11-02 11:27:13.519');
INSERT INTO `device_sensor_record` VALUES (85574, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.6, 'μg/m³', NULL, NULL, '2026-11-02 11:27:13.519', '2026-11-02 11:27:13.519');
INSERT INTO `device_sensor_record` VALUES (85575, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 400, 'ppm', NULL, NULL, '2026-11-02 11:27:13.519', '2026-11-02 11:27:13.519');
INSERT INTO `device_sensor_record` VALUES (85576, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 227, 'lx', NULL, NULL, '2026-11-02 11:27:13.519', '2026-11-02 11:27:13.519');
INSERT INTO `device_sensor_record` VALUES (85577, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.3, '℃', NULL, NULL, '2026-11-02 11:27:13.519', '2026-11-02 11:27:13.519');
INSERT INTO `device_sensor_record` VALUES (85578, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:27:13.519', '2026-11-02 11:27:13.519');
INSERT INTO `device_sensor_record` VALUES (85579, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51, '℃', NULL, NULL, '2026-11-02 11:27:13.519', '2026-11-02 11:27:13.519');
INSERT INTO `device_sensor_record` VALUES (85580, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.22, 'V', NULL, NULL, '2026-11-02 11:27:13.519', '2026-11-02 11:27:13.519');
INSERT INTO `device_sensor_record` VALUES (85581, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 131763, 'bytes', NULL, NULL, '2026-11-02 11:27:13.519', '2026-11-02 11:27:13.519');
INSERT INTO `device_sensor_record` VALUES (85582, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.7, '℃', NULL, NULL, '2026-11-02 11:27:23.525', '2026-11-02 11:27:23.525');
INSERT INTO `device_sensor_record` VALUES (85583, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.9, '%', NULL, NULL, '2026-11-02 11:27:23.525', '2026-11-02 11:27:23.525');
INSERT INTO `device_sensor_record` VALUES (85584, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 46.6, 'μg/m³', NULL, NULL, '2026-11-02 11:27:23.525', '2026-11-02 11:27:23.525');
INSERT INTO `device_sensor_record` VALUES (85585, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 549.5, 'ppm', NULL, NULL, '2026-11-02 11:27:23.525', '2026-11-02 11:27:23.525');
INSERT INTO `device_sensor_record` VALUES (85586, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 363.8, 'lx', NULL, NULL, '2026-11-02 11:27:23.525', '2026-11-02 11:27:23.525');
INSERT INTO `device_sensor_record` VALUES (85587, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-02 11:27:23.525', '2026-11-02 11:27:23.525');
INSERT INTO `device_sensor_record` VALUES (85588, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:27:23.525', '2026-11-02 11:27:23.525');
INSERT INTO `device_sensor_record` VALUES (85589, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.1, '℃', NULL, NULL, '2026-11-02 11:27:23.525', '2026-11-02 11:27:23.525');
INSERT INTO `device_sensor_record` VALUES (85590, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:27:23.525', '2026-11-02 11:27:23.525');
INSERT INTO `device_sensor_record` VALUES (85591, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 169005, 'bytes', NULL, NULL, '2026-11-02 11:27:23.525', '2026-11-02 11:27:23.525');
INSERT INTO `device_sensor_record` VALUES (85592, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26, '℃', NULL, NULL, '2026-11-02 11:27:33.537', '2026-11-02 11:27:33.537');
INSERT INTO `device_sensor_record` VALUES (85593, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.1, '%', NULL, NULL, '2026-11-02 11:27:33.537', '2026-11-02 11:27:33.537');
INSERT INTO `device_sensor_record` VALUES (85594, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 27.1, 'μg/m³', NULL, NULL, '2026-11-02 11:27:33.537', '2026-11-02 11:27:33.537');
INSERT INTO `device_sensor_record` VALUES (85595, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 479.9, 'ppm', NULL, NULL, '2026-11-02 11:27:33.537', '2026-11-02 11:27:33.537');
INSERT INTO `device_sensor_record` VALUES (85596, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 230.7, 'lx', NULL, NULL, '2026-11-02 11:27:33.537', '2026-11-02 11:27:33.537');
INSERT INTO `device_sensor_record` VALUES (85597, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-02 11:27:33.537', '2026-11-02 11:27:33.537');
INSERT INTO `device_sensor_record` VALUES (85598, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.2, '℃', NULL, NULL, '2026-11-02 11:27:33.537', '2026-11-02 11:27:33.537');
INSERT INTO `device_sensor_record` VALUES (85599, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.1, '℃', NULL, NULL, '2026-11-02 11:27:33.537', '2026-11-02 11:27:33.537');
INSERT INTO `device_sensor_record` VALUES (85600, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-02 11:27:33.537', '2026-11-02 11:27:33.537');
INSERT INTO `device_sensor_record` VALUES (85601, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 158662, 'bytes', NULL, NULL, '2026-11-02 11:27:33.537', '2026-11-02 11:27:33.537');
INSERT INTO `device_sensor_record` VALUES (85602, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.6, '℃', NULL, NULL, '2026-11-02 11:27:43.553', '2026-11-02 11:27:43.553');
INSERT INTO `device_sensor_record` VALUES (85603, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.1, '%', NULL, NULL, '2026-11-02 11:27:43.553', '2026-11-02 11:27:43.553');
INSERT INTO `device_sensor_record` VALUES (85604, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 43, 'μg/m³', NULL, NULL, '2026-11-02 11:27:43.553', '2026-11-02 11:27:43.553');
INSERT INTO `device_sensor_record` VALUES (85605, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 483.2, 'ppm', NULL, NULL, '2026-11-02 11:27:43.553', '2026-11-02 11:27:43.553');
INSERT INTO `device_sensor_record` VALUES (85606, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 380.9, 'lx', NULL, NULL, '2026-11-02 11:27:43.553', '2026-11-02 11:27:43.553');
INSERT INTO `device_sensor_record` VALUES (85607, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.6, '℃', NULL, NULL, '2026-11-02 11:27:43.553', '2026-11-02 11:27:43.553');
INSERT INTO `device_sensor_record` VALUES (85608, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-02 11:27:43.553', '2026-11-02 11:27:43.553');
INSERT INTO `device_sensor_record` VALUES (85609, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.8, '℃', NULL, NULL, '2026-11-02 11:27:43.553', '2026-11-02 11:27:43.553');
INSERT INTO `device_sensor_record` VALUES (85610, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-02 11:27:43.553', '2026-11-02 11:27:43.553');
INSERT INTO `device_sensor_record` VALUES (85611, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 126195, 'bytes', NULL, NULL, '2026-11-02 11:27:43.553', '2026-11-02 11:27:43.553');
INSERT INTO `device_sensor_record` VALUES (85612, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:27:53.570', '2026-11-02 11:27:53.570');
INSERT INTO `device_sensor_record` VALUES (85613, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 50.7, '%', NULL, NULL, '2026-11-02 11:27:53.570', '2026-11-02 11:27:53.570');
INSERT INTO `device_sensor_record` VALUES (85614, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:27:53.570', '2026-11-02 11:27:53.570');
INSERT INTO `device_sensor_record` VALUES (85615, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 489.7, 'ppm', NULL, NULL, '2026-11-02 11:27:53.570', '2026-11-02 11:27:53.570');
INSERT INTO `device_sensor_record` VALUES (85616, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 417.6, 'lx', NULL, NULL, '2026-11-02 11:27:53.570', '2026-11-02 11:27:53.570');
INSERT INTO `device_sensor_record` VALUES (85617, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.7, '℃', NULL, NULL, '2026-11-02 11:27:53.570', '2026-11-02 11:27:53.570');
INSERT INTO `device_sensor_record` VALUES (85618, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:27:53.570', '2026-11-02 11:27:53.570');
INSERT INTO `device_sensor_record` VALUES (85619, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.6, '℃', NULL, NULL, '2026-11-02 11:27:53.570', '2026-11-02 11:27:53.570');
INSERT INTO `device_sensor_record` VALUES (85620, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-02 11:27:53.570', '2026-11-02 11:27:53.570');
INSERT INTO `device_sensor_record` VALUES (85621, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 129951, 'bytes', NULL, NULL, '2026-11-02 11:27:53.570', '2026-11-02 11:27:53.570');
INSERT INTO `device_sensor_record` VALUES (85622, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.8, '℃', NULL, NULL, '2026-11-02 11:28:03.577', '2026-11-02 11:28:03.577');
INSERT INTO `device_sensor_record` VALUES (85623, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64.4, '%', NULL, NULL, '2026-11-02 11:28:03.577', '2026-11-02 11:28:03.577');
INSERT INTO `device_sensor_record` VALUES (85624, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 39.3, 'μg/m³', NULL, NULL, '2026-11-02 11:28:03.577', '2026-11-02 11:28:03.577');
INSERT INTO `device_sensor_record` VALUES (85625, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 498.4, 'ppm', NULL, NULL, '2026-11-02 11:28:03.577', '2026-11-02 11:28:03.577');
INSERT INTO `device_sensor_record` VALUES (85626, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 400.4, 'lx', NULL, NULL, '2026-11-02 11:28:03.577', '2026-11-02 11:28:03.577');
INSERT INTO `device_sensor_record` VALUES (85627, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.9, '℃', NULL, NULL, '2026-11-02 11:28:03.577', '2026-11-02 11:28:03.577');
INSERT INTO `device_sensor_record` VALUES (85628, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.2, '℃', NULL, NULL, '2026-11-02 11:28:03.577', '2026-11-02 11:28:03.577');
INSERT INTO `device_sensor_record` VALUES (85629, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.1, '℃', NULL, NULL, '2026-11-02 11:28:03.577', '2026-11-02 11:28:03.577');
INSERT INTO `device_sensor_record` VALUES (85630, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-02 11:28:03.577', '2026-11-02 11:28:03.577');
INSERT INTO `device_sensor_record` VALUES (85631, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 162846, 'bytes', NULL, NULL, '2026-11-02 11:28:03.577', '2026-11-02 11:28:03.577');
INSERT INTO `device_sensor_record` VALUES (85632, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.4, '℃', NULL, NULL, '2026-11-02 11:28:13.591', '2026-11-02 11:28:13.591');
INSERT INTO `device_sensor_record` VALUES (85633, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.5, '%', NULL, NULL, '2026-11-02 11:28:13.591', '2026-11-02 11:28:13.591');
INSERT INTO `device_sensor_record` VALUES (85634, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 37, 'μg/m³', NULL, NULL, '2026-11-02 11:28:13.591', '2026-11-02 11:28:13.591');
INSERT INTO `device_sensor_record` VALUES (85635, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 470.8, 'ppm', NULL, NULL, '2026-11-02 11:28:13.591', '2026-11-02 11:28:13.591');
INSERT INTO `device_sensor_record` VALUES (85636, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 420, 'lx', NULL, NULL, '2026-11-02 11:28:13.591', '2026-11-02 11:28:13.591');
INSERT INTO `device_sensor_record` VALUES (85637, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-02 11:28:13.591', '2026-11-02 11:28:13.591');
INSERT INTO `device_sensor_record` VALUES (85638, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-02 11:28:13.591', '2026-11-02 11:28:13.591');
INSERT INTO `device_sensor_record` VALUES (85639, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.7, '℃', NULL, NULL, '2026-11-02 11:28:13.591', '2026-11-02 11:28:13.591');
INSERT INTO `device_sensor_record` VALUES (85640, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-02 11:28:13.591', '2026-11-02 11:28:13.591');
INSERT INTO `device_sensor_record` VALUES (85641, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 171019, 'bytes', NULL, NULL, '2026-11-02 11:28:13.591', '2026-11-02 11:28:13.591');
INSERT INTO `device_sensor_record` VALUES (85642, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-02 11:28:23.606', '2026-11-02 11:28:23.606');
INSERT INTO `device_sensor_record` VALUES (85643, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.7, '%', NULL, NULL, '2026-11-02 11:28:23.606', '2026-11-02 11:28:23.606');
INSERT INTO `device_sensor_record` VALUES (85644, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 47.2, 'μg/m³', NULL, NULL, '2026-11-02 11:28:23.606', '2026-11-02 11:28:23.606');
INSERT INTO `device_sensor_record` VALUES (85645, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 524.7, 'ppm', NULL, NULL, '2026-11-02 11:28:23.606', '2026-11-02 11:28:23.606');
INSERT INTO `device_sensor_record` VALUES (85646, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 505.4, 'lx', NULL, NULL, '2026-11-02 11:28:23.606', '2026-11-02 11:28:23.606');
INSERT INTO `device_sensor_record` VALUES (85647, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-02 11:28:23.606', '2026-11-02 11:28:23.606');
INSERT INTO `device_sensor_record` VALUES (85648, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 11:28:23.606', '2026-11-02 11:28:23.606');
INSERT INTO `device_sensor_record` VALUES (85649, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.4, '℃', NULL, NULL, '2026-11-02 11:28:23.606', '2026-11-02 11:28:23.606');
INSERT INTO `device_sensor_record` VALUES (85650, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:28:23.606', '2026-11-02 11:28:23.606');
INSERT INTO `device_sensor_record` VALUES (85651, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 171158, 'bytes', NULL, NULL, '2026-11-02 11:28:23.606', '2026-11-02 11:28:23.606');
INSERT INTO `device_sensor_record` VALUES (85652, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.7, '℃', NULL, NULL, '2026-11-02 11:28:33.620', '2026-11-02 11:28:33.620');
INSERT INTO `device_sensor_record` VALUES (85653, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.4, '%', NULL, NULL, '2026-11-02 11:28:33.620', '2026-11-02 11:28:33.620');
INSERT INTO `device_sensor_record` VALUES (85654, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26.3, 'μg/m³', NULL, NULL, '2026-11-02 11:28:33.620', '2026-11-02 11:28:33.620');
INSERT INTO `device_sensor_record` VALUES (85655, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 471.3, 'ppm', NULL, NULL, '2026-11-02 11:28:33.620', '2026-11-02 11:28:33.620');
INSERT INTO `device_sensor_record` VALUES (85656, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 587, 'lx', NULL, NULL, '2026-11-02 11:28:33.620', '2026-11-02 11:28:33.620');
INSERT INTO `device_sensor_record` VALUES (85657, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:28:33.620', '2026-11-02 11:28:33.620');
INSERT INTO `device_sensor_record` VALUES (85658, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.7, '℃', NULL, NULL, '2026-11-02 11:28:33.620', '2026-11-02 11:28:33.620');
INSERT INTO `device_sensor_record` VALUES (85659, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.2, '℃', NULL, NULL, '2026-11-02 11:28:33.620', '2026-11-02 11:28:33.620');
INSERT INTO `device_sensor_record` VALUES (85660, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:28:33.620', '2026-11-02 11:28:33.620');
INSERT INTO `device_sensor_record` VALUES (85661, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 159147, 'bytes', NULL, NULL, '2026-11-02 11:28:33.620', '2026-11-02 11:28:33.620');
INSERT INTO `device_sensor_record` VALUES (85662, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:28:43.620', '2026-11-02 11:28:43.620');
INSERT INTO `device_sensor_record` VALUES (85663, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.7, '%', NULL, NULL, '2026-11-02 11:28:43.620', '2026-11-02 11:28:43.620');
INSERT INTO `device_sensor_record` VALUES (85664, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:28:43.620', '2026-11-02 11:28:43.620');
INSERT INTO `device_sensor_record` VALUES (85665, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 563.4, 'ppm', NULL, NULL, '2026-11-02 11:28:43.620', '2026-11-02 11:28:43.620');
INSERT INTO `device_sensor_record` VALUES (85666, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 618.6, 'lx', NULL, NULL, '2026-11-02 11:28:43.620', '2026-11-02 11:28:43.620');
INSERT INTO `device_sensor_record` VALUES (85667, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-02 11:28:43.620', '2026-11-02 11:28:43.620');
INSERT INTO `device_sensor_record` VALUES (85668, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:28:43.620', '2026-11-02 11:28:43.620');
INSERT INTO `device_sensor_record` VALUES (85669, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.5, '℃', NULL, NULL, '2026-11-02 11:28:43.620', '2026-11-02 11:28:43.620');
INSERT INTO `device_sensor_record` VALUES (85670, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.34, 'V', NULL, NULL, '2026-11-02 11:28:43.620', '2026-11-02 11:28:43.620');
INSERT INTO `device_sensor_record` VALUES (85671, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 151249, 'bytes', NULL, NULL, '2026-11-02 11:28:43.620', '2026-11-02 11:28:43.620');
INSERT INTO `device_sensor_record` VALUES (85672, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-02 11:28:53.622', '2026-11-02 11:28:53.622');
INSERT INTO `device_sensor_record` VALUES (85673, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.2, '%', NULL, NULL, '2026-11-02 11:28:53.622', '2026-11-02 11:28:53.622');
INSERT INTO `device_sensor_record` VALUES (85674, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.8, 'μg/m³', NULL, NULL, '2026-11-02 11:28:53.622', '2026-11-02 11:28:53.622');
INSERT INTO `device_sensor_record` VALUES (85675, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 578.9, 'ppm', NULL, NULL, '2026-11-02 11:28:53.622', '2026-11-02 11:28:53.622');
INSERT INTO `device_sensor_record` VALUES (85676, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 724.4, 'lx', NULL, NULL, '2026-11-02 11:28:53.622', '2026-11-02 11:28:53.622');
INSERT INTO `device_sensor_record` VALUES (85677, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.8, '℃', NULL, NULL, '2026-11-02 11:28:53.622', '2026-11-02 11:28:53.622');
INSERT INTO `device_sensor_record` VALUES (85678, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.2, '℃', NULL, NULL, '2026-11-02 11:28:53.622', '2026-11-02 11:28:53.622');
INSERT INTO `device_sensor_record` VALUES (85679, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.3, '℃', NULL, NULL, '2026-11-02 11:28:53.622', '2026-11-02 11:28:53.622');
INSERT INTO `device_sensor_record` VALUES (85680, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.29, 'V', NULL, NULL, '2026-11-02 11:28:53.622', '2026-11-02 11:28:53.622');
INSERT INTO `device_sensor_record` VALUES (85681, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 139568, 'bytes', NULL, NULL, '2026-11-02 11:28:53.622', '2026-11-02 11:28:53.622');
INSERT INTO `device_sensor_record` VALUES (85682, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.9, '℃', NULL, NULL, '2026-11-02 11:29:03.637', '2026-11-02 11:29:03.637');
INSERT INTO `device_sensor_record` VALUES (85683, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66, '%', NULL, NULL, '2026-11-02 11:29:03.637', '2026-11-02 11:29:03.637');
INSERT INTO `device_sensor_record` VALUES (85684, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 40.9, 'μg/m³', NULL, NULL, '2026-11-02 11:29:03.637', '2026-11-02 11:29:03.637');
INSERT INTO `device_sensor_record` VALUES (85685, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 406.3, 'ppm', NULL, NULL, '2026-11-02 11:29:03.637', '2026-11-02 11:29:03.637');
INSERT INTO `device_sensor_record` VALUES (85686, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 387, 'lx', NULL, NULL, '2026-11-02 11:29:03.637', '2026-11-02 11:29:03.637');
INSERT INTO `device_sensor_record` VALUES (85687, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.3, '℃', NULL, NULL, '2026-11-02 11:29:03.637', '2026-11-02 11:29:03.637');
INSERT INTO `device_sensor_record` VALUES (85688, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:29:03.637', '2026-11-02 11:29:03.637');
INSERT INTO `device_sensor_record` VALUES (85689, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.4, '℃', NULL, NULL, '2026-11-02 11:29:03.637', '2026-11-02 11:29:03.637');
INSERT INTO `device_sensor_record` VALUES (85690, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-02 11:29:03.637', '2026-11-02 11:29:03.637');
INSERT INTO `device_sensor_record` VALUES (85691, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 154005, 'bytes', NULL, NULL, '2026-11-02 11:29:03.637', '2026-11-02 11:29:03.637');
INSERT INTO `device_sensor_record` VALUES (85692, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.4, '℃', NULL, NULL, '2026-11-02 11:29:13.651', '2026-11-02 11:29:13.651');
INSERT INTO `device_sensor_record` VALUES (85693, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.8, '%', NULL, NULL, '2026-11-02 11:29:13.651', '2026-11-02 11:29:13.651');
INSERT INTO `device_sensor_record` VALUES (85694, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 43.4, 'μg/m³', NULL, NULL, '2026-11-02 11:29:13.651', '2026-11-02 11:29:13.651');
INSERT INTO `device_sensor_record` VALUES (85695, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 466.7, 'ppm', NULL, NULL, '2026-11-02 11:29:13.651', '2026-11-02 11:29:13.651');
INSERT INTO `device_sensor_record` VALUES (85696, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 144.4, 'lx', NULL, NULL, '2026-11-02 11:29:13.651', '2026-11-02 11:29:13.651');
INSERT INTO `device_sensor_record` VALUES (85697, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:29:13.651', '2026-11-02 11:29:13.651');
INSERT INTO `device_sensor_record` VALUES (85698, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 26, '℃', NULL, NULL, '2026-11-02 11:29:13.651', '2026-11-02 11:29:13.651');
INSERT INTO `device_sensor_record` VALUES (85699, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.4, '℃', NULL, NULL, '2026-11-02 11:29:13.651', '2026-11-02 11:29:13.651');
INSERT INTO `device_sensor_record` VALUES (85700, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:29:13.651', '2026-11-02 11:29:13.651');
INSERT INTO `device_sensor_record` VALUES (85701, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 158236, 'bytes', NULL, NULL, '2026-11-02 11:29:13.651', '2026-11-02 11:29:13.651');
INSERT INTO `device_sensor_record` VALUES (85702, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:29:23.665', '2026-11-02 11:29:23.665');
INSERT INTO `device_sensor_record` VALUES (85703, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.5, '%', NULL, NULL, '2026-11-02 11:29:23.665', '2026-11-02 11:29:23.665');
INSERT INTO `device_sensor_record` VALUES (85704, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 39.6, 'μg/m³', NULL, NULL, '2026-11-02 11:29:23.665', '2026-11-02 11:29:23.665');
INSERT INTO `device_sensor_record` VALUES (85705, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 418.1, 'ppm', NULL, NULL, '2026-11-02 11:29:23.665', '2026-11-02 11:29:23.665');
INSERT INTO `device_sensor_record` VALUES (85706, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 181, 'lx', NULL, NULL, '2026-11-02 11:29:23.665', '2026-11-02 11:29:23.665');
INSERT INTO `device_sensor_record` VALUES (85707, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.3, '℃', NULL, NULL, '2026-11-02 11:29:23.665', '2026-11-02 11:29:23.665');
INSERT INTO `device_sensor_record` VALUES (85708, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.7, '℃', NULL, NULL, '2026-11-02 11:29:23.665', '2026-11-02 11:29:23.665');
INSERT INTO `device_sensor_record` VALUES (85709, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.4, '℃', NULL, NULL, '2026-11-02 11:29:23.665', '2026-11-02 11:29:23.665');
INSERT INTO `device_sensor_record` VALUES (85710, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.22, 'V', NULL, NULL, '2026-11-02 11:29:23.665', '2026-11-02 11:29:23.665');
INSERT INTO `device_sensor_record` VALUES (85711, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 133497, 'bytes', NULL, NULL, '2026-11-02 11:29:23.665', '2026-11-02 11:29:23.665');
INSERT INTO `device_sensor_record` VALUES (85712, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:29:33.672', '2026-11-02 11:29:33.672');
INSERT INTO `device_sensor_record` VALUES (85713, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67, '%', NULL, NULL, '2026-11-02 11:29:33.672', '2026-11-02 11:29:33.672');
INSERT INTO `device_sensor_record` VALUES (85714, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:29:33.672', '2026-11-02 11:29:33.672');
INSERT INTO `device_sensor_record` VALUES (85715, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 580.9, 'ppm', NULL, NULL, '2026-11-02 11:29:33.672', '2026-11-02 11:29:33.672');
INSERT INTO `device_sensor_record` VALUES (85716, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 226.2, 'lx', NULL, NULL, '2026-11-02 11:29:33.672', '2026-11-02 11:29:33.672');
INSERT INTO `device_sensor_record` VALUES (85717, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.7, '℃', NULL, NULL, '2026-11-02 11:29:33.672', '2026-11-02 11:29:33.672');
INSERT INTO `device_sensor_record` VALUES (85718, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-02 11:29:33.672', '2026-11-02 11:29:33.672');
INSERT INTO `device_sensor_record` VALUES (85719, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.6, '℃', NULL, NULL, '2026-11-02 11:29:33.672', '2026-11-02 11:29:33.672');
INSERT INTO `device_sensor_record` VALUES (85720, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:29:33.672', '2026-11-02 11:29:33.672');
INSERT INTO `device_sensor_record` VALUES (85721, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 131110, 'bytes', NULL, NULL, '2026-11-02 11:29:33.672', '2026-11-02 11:29:33.672');
INSERT INTO `device_sensor_record` VALUES (85722, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.9, '℃', NULL, NULL, '2026-11-02 11:29:43.679', '2026-11-02 11:29:43.679');
INSERT INTO `device_sensor_record` VALUES (85723, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 50.1, '%', NULL, NULL, '2026-11-02 11:29:43.679', '2026-11-02 11:29:43.679');
INSERT INTO `device_sensor_record` VALUES (85724, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 38.7, 'μg/m³', NULL, NULL, '2026-11-02 11:29:43.679', '2026-11-02 11:29:43.679');
INSERT INTO `device_sensor_record` VALUES (85725, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 539, 'ppm', NULL, NULL, '2026-11-02 11:29:43.679', '2026-11-02 11:29:43.679');
INSERT INTO `device_sensor_record` VALUES (85726, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 487.8, 'lx', NULL, NULL, '2026-11-02 11:29:43.679', '2026-11-02 11:29:43.679');
INSERT INTO `device_sensor_record` VALUES (85727, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-02 11:29:43.679', '2026-11-02 11:29:43.679');
INSERT INTO `device_sensor_record` VALUES (85728, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 11:29:43.679', '2026-11-02 11:29:43.679');
INSERT INTO `device_sensor_record` VALUES (85729, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.7, '℃', NULL, NULL, '2026-11-02 11:29:43.679', '2026-11-02 11:29:43.679');
INSERT INTO `device_sensor_record` VALUES (85730, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-02 11:29:43.679', '2026-11-02 11:29:43.679');
INSERT INTO `device_sensor_record` VALUES (85731, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 175528, 'bytes', NULL, NULL, '2026-11-02 11:29:43.679', '2026-11-02 11:29:43.679');
INSERT INTO `device_sensor_record` VALUES (85732, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.7, '℃', NULL, NULL, '2026-11-02 11:29:53.682', '2026-11-02 11:29:53.682');
INSERT INTO `device_sensor_record` VALUES (85733, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.7, '%', NULL, NULL, '2026-11-02 11:29:53.682', '2026-11-02 11:29:53.682');
INSERT INTO `device_sensor_record` VALUES (85734, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 29.7, 'μg/m³', NULL, NULL, '2026-11-02 11:29:53.682', '2026-11-02 11:29:53.682');
INSERT INTO `device_sensor_record` VALUES (85735, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 422.1, 'ppm', NULL, NULL, '2026-11-02 11:29:53.682', '2026-11-02 11:29:53.682');
INSERT INTO `device_sensor_record` VALUES (85736, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 318.1, 'lx', NULL, NULL, '2026-11-02 11:29:53.682', '2026-11-02 11:29:53.682');
INSERT INTO `device_sensor_record` VALUES (85737, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-02 11:29:53.682', '2026-11-02 11:29:53.682');
INSERT INTO `device_sensor_record` VALUES (85738, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:29:53.682', '2026-11-02 11:29:53.682');
INSERT INTO `device_sensor_record` VALUES (85739, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.6, '℃', NULL, NULL, '2026-11-02 11:29:53.682', '2026-11-02 11:29:53.682');
INSERT INTO `device_sensor_record` VALUES (85740, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:29:53.682', '2026-11-02 11:29:53.682');
INSERT INTO `device_sensor_record` VALUES (85741, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 171909, 'bytes', NULL, NULL, '2026-11-02 11:29:53.682', '2026-11-02 11:29:53.682');
INSERT INTO `device_sensor_record` VALUES (85742, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-02 11:30:03.690', '2026-11-02 11:30:03.690');
INSERT INTO `device_sensor_record` VALUES (85743, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62.8, '%', NULL, NULL, '2026-11-02 11:30:03.690', '2026-11-02 11:30:03.690');
INSERT INTO `device_sensor_record` VALUES (85744, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35.1, 'μg/m³', NULL, NULL, '2026-11-02 11:30:03.690', '2026-11-02 11:30:03.690');
INSERT INTO `device_sensor_record` VALUES (85745, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 405, 'ppm', NULL, NULL, '2026-11-02 11:30:03.690', '2026-11-02 11:30:03.690');
INSERT INTO `device_sensor_record` VALUES (85746, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 373.1, 'lx', NULL, NULL, '2026-11-02 11:30:03.690', '2026-11-02 11:30:03.690');
INSERT INTO `device_sensor_record` VALUES (85747, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-02 11:30:03.690', '2026-11-02 11:30:03.690');
INSERT INTO `device_sensor_record` VALUES (85748, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 26, '℃', NULL, NULL, '2026-11-02 11:30:03.690', '2026-11-02 11:30:03.690');
INSERT INTO `device_sensor_record` VALUES (85749, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.4, '℃', NULL, NULL, '2026-11-02 11:30:03.690', '2026-11-02 11:30:03.690');
INSERT INTO `device_sensor_record` VALUES (85750, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-02 11:30:03.690', '2026-11-02 11:30:03.690');
INSERT INTO `device_sensor_record` VALUES (85751, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 177157, 'bytes', NULL, NULL, '2026-11-02 11:30:03.690', '2026-11-02 11:30:03.690');
INSERT INTO `device_sensor_record` VALUES (85752, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:30:13.701', '2026-11-02 11:30:13.701');
INSERT INTO `device_sensor_record` VALUES (85753, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.7, '%', NULL, NULL, '2026-11-02 11:30:13.701', '2026-11-02 11:30:13.701');
INSERT INTO `device_sensor_record` VALUES (85754, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.6, 'μg/m³', NULL, NULL, '2026-11-02 11:30:13.701', '2026-11-02 11:30:13.701');
INSERT INTO `device_sensor_record` VALUES (85755, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 411.6, 'ppm', NULL, NULL, '2026-11-02 11:30:13.701', '2026-11-02 11:30:13.701');
INSERT INTO `device_sensor_record` VALUES (85756, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 327.8, 'lx', NULL, NULL, '2026-11-02 11:30:13.701', '2026-11-02 11:30:13.701');
INSERT INTO `device_sensor_record` VALUES (85757, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 23, '℃', NULL, NULL, '2026-11-02 11:30:13.701', '2026-11-02 11:30:13.701');
INSERT INTO `device_sensor_record` VALUES (85758, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.4, '℃', NULL, NULL, '2026-11-02 11:30:13.701', '2026-11-02 11:30:13.701');
INSERT INTO `device_sensor_record` VALUES (85759, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.7, '℃', NULL, NULL, '2026-11-02 11:30:13.701', '2026-11-02 11:30:13.701');
INSERT INTO `device_sensor_record` VALUES (85760, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-02 11:30:13.701', '2026-11-02 11:30:13.701');
INSERT INTO `device_sensor_record` VALUES (85761, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 147305, 'bytes', NULL, NULL, '2026-11-02 11:30:13.701', '2026-11-02 11:30:13.701');
INSERT INTO `device_sensor_record` VALUES (85762, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:30:23.710', '2026-11-02 11:30:23.710');
INSERT INTO `device_sensor_record` VALUES (85763, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.3, '%', NULL, NULL, '2026-11-02 11:30:23.710', '2026-11-02 11:30:23.710');
INSERT INTO `device_sensor_record` VALUES (85764, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:30:23.710', '2026-11-02 11:30:23.710');
INSERT INTO `device_sensor_record` VALUES (85765, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 496, 'ppm', NULL, NULL, '2026-11-02 11:30:23.710', '2026-11-02 11:30:23.710');
INSERT INTO `device_sensor_record` VALUES (85766, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 568, 'lx', NULL, NULL, '2026-11-02 11:30:23.710', '2026-11-02 11:30:23.710');
INSERT INTO `device_sensor_record` VALUES (85767, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.5, '℃', NULL, NULL, '2026-11-02 11:30:23.710', '2026-11-02 11:30:23.710');
INSERT INTO `device_sensor_record` VALUES (85768, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-02 11:30:23.710', '2026-11-02 11:30:23.710');
INSERT INTO `device_sensor_record` VALUES (85769, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.2, '℃', NULL, NULL, '2026-11-02 11:30:23.710', '2026-11-02 11:30:23.710');
INSERT INTO `device_sensor_record` VALUES (85770, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:30:23.710', '2026-11-02 11:30:23.710');
INSERT INTO `device_sensor_record` VALUES (85771, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 150624, 'bytes', NULL, NULL, '2026-11-02 11:30:23.710', '2026-11-02 11:30:23.710');
INSERT INTO `device_sensor_record` VALUES (85772, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:30:33.718', '2026-11-02 11:30:33.718');
INSERT INTO `device_sensor_record` VALUES (85773, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53, '%', NULL, NULL, '2026-11-02 11:30:33.718', '2026-11-02 11:30:33.718');
INSERT INTO `device_sensor_record` VALUES (85774, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 27, 'μg/m³', NULL, NULL, '2026-11-02 11:30:33.718', '2026-11-02 11:30:33.718');
INSERT INTO `device_sensor_record` VALUES (85775, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 593.2, 'ppm', NULL, NULL, '2026-11-02 11:30:33.718', '2026-11-02 11:30:33.718');
INSERT INTO `device_sensor_record` VALUES (85776, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 443, 'lx', NULL, NULL, '2026-11-02 11:30:33.718', '2026-11-02 11:30:33.718');
INSERT INTO `device_sensor_record` VALUES (85777, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-02 11:30:33.718', '2026-11-02 11:30:33.718');
INSERT INTO `device_sensor_record` VALUES (85778, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-02 11:30:33.718', '2026-11-02 11:30:33.718');
INSERT INTO `device_sensor_record` VALUES (85779, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47, '℃', NULL, NULL, '2026-11-02 11:30:33.718', '2026-11-02 11:30:33.718');
INSERT INTO `device_sensor_record` VALUES (85780, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-02 11:30:33.718', '2026-11-02 11:30:33.718');
INSERT INTO `device_sensor_record` VALUES (85781, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 125855, 'bytes', NULL, NULL, '2026-11-02 11:30:33.718', '2026-11-02 11:30:33.718');
INSERT INTO `device_sensor_record` VALUES (85782, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.4, '℃', NULL, NULL, '2026-11-02 11:30:43.724', '2026-11-02 11:30:43.724');
INSERT INTO `device_sensor_record` VALUES (85783, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60.8, '%', NULL, NULL, '2026-11-02 11:30:43.724', '2026-11-02 11:30:43.724');
INSERT INTO `device_sensor_record` VALUES (85784, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 28.5, 'μg/m³', NULL, NULL, '2026-11-02 11:30:43.724', '2026-11-02 11:30:43.724');
INSERT INTO `device_sensor_record` VALUES (85785, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 511.9, 'ppm', NULL, NULL, '2026-11-02 11:30:43.724', '2026-11-02 11:30:43.724');
INSERT INTO `device_sensor_record` VALUES (85786, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 360, 'lx', NULL, NULL, '2026-11-02 11:30:43.724', '2026-11-02 11:30:43.724');
INSERT INTO `device_sensor_record` VALUES (85787, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-02 11:30:43.724', '2026-11-02 11:30:43.724');
INSERT INTO `device_sensor_record` VALUES (85788, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.8, '℃', NULL, NULL, '2026-11-02 11:30:43.724', '2026-11-02 11:30:43.724');
INSERT INTO `device_sensor_record` VALUES (85789, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.3, '℃', NULL, NULL, '2026-11-02 11:30:43.724', '2026-11-02 11:30:43.724');
INSERT INTO `device_sensor_record` VALUES (85790, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-02 11:30:43.724', '2026-11-02 11:30:43.724');
INSERT INTO `device_sensor_record` VALUES (85791, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 134578, 'bytes', NULL, NULL, '2026-11-02 11:30:43.724', '2026-11-02 11:30:43.724');
INSERT INTO `device_sensor_record` VALUES (85792, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:30:53.739', '2026-11-02 11:30:53.739');
INSERT INTO `device_sensor_record` VALUES (85793, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.4, '%', NULL, NULL, '2026-11-02 11:30:53.739', '2026-11-02 11:30:53.739');
INSERT INTO `device_sensor_record` VALUES (85794, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.4, 'μg/m³', NULL, NULL, '2026-11-02 11:30:53.739', '2026-11-02 11:30:53.739');
INSERT INTO `device_sensor_record` VALUES (85795, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 426.9, 'ppm', NULL, NULL, '2026-11-02 11:30:53.739', '2026-11-02 11:30:53.739');
INSERT INTO `device_sensor_record` VALUES (85796, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 780.6, 'lx', NULL, NULL, '2026-11-02 11:30:53.739', '2026-11-02 11:30:53.739');
INSERT INTO `device_sensor_record` VALUES (85797, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-02 11:30:53.739', '2026-11-02 11:30:53.739');
INSERT INTO `device_sensor_record` VALUES (85798, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-02 11:30:53.739', '2026-11-02 11:30:53.739');
INSERT INTO `device_sensor_record` VALUES (85799, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.2, '℃', NULL, NULL, '2026-11-02 11:30:53.739', '2026-11-02 11:30:53.739');
INSERT INTO `device_sensor_record` VALUES (85800, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:30:53.739', '2026-11-02 11:30:53.739');
INSERT INTO `device_sensor_record` VALUES (85801, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 150867, 'bytes', NULL, NULL, '2026-11-02 11:30:53.739', '2026-11-02 11:30:53.739');
INSERT INTO `device_sensor_record` VALUES (85802, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.5, '℃', NULL, NULL, '2026-11-02 11:31:03.750', '2026-11-02 11:31:03.750');
INSERT INTO `device_sensor_record` VALUES (85803, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.7, '%', NULL, NULL, '2026-11-02 11:31:03.750', '2026-11-02 11:31:03.750');
INSERT INTO `device_sensor_record` VALUES (85804, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 44.4, 'μg/m³', NULL, NULL, '2026-11-02 11:31:03.750', '2026-11-02 11:31:03.750');
INSERT INTO `device_sensor_record` VALUES (85805, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 593.2, 'ppm', NULL, NULL, '2026-11-02 11:31:03.750', '2026-11-02 11:31:03.750');
INSERT INTO `device_sensor_record` VALUES (85806, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 485.7, 'lx', NULL, NULL, '2026-11-02 11:31:03.750', '2026-11-02 11:31:03.750');
INSERT INTO `device_sensor_record` VALUES (85807, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-02 11:31:03.750', '2026-11-02 11:31:03.750');
INSERT INTO `device_sensor_record` VALUES (85808, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.7, '℃', NULL, NULL, '2026-11-02 11:31:03.750', '2026-11-02 11:31:03.750');
INSERT INTO `device_sensor_record` VALUES (85809, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.7, '℃', NULL, NULL, '2026-11-02 11:31:03.750', '2026-11-02 11:31:03.750');
INSERT INTO `device_sensor_record` VALUES (85810, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-02 11:31:03.750', '2026-11-02 11:31:03.750');
INSERT INTO `device_sensor_record` VALUES (85811, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 126910, 'bytes', NULL, NULL, '2026-11-02 11:31:03.750', '2026-11-02 11:31:03.750');
INSERT INTO `device_sensor_record` VALUES (85812, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:31:13.757', '2026-11-02 11:31:13.757');
INSERT INTO `device_sensor_record` VALUES (85813, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.4, '%', NULL, NULL, '2026-11-02 11:31:13.757', '2026-11-02 11:31:13.757');
INSERT INTO `device_sensor_record` VALUES (85814, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:31:13.757', '2026-11-02 11:31:13.757');
INSERT INTO `device_sensor_record` VALUES (85815, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 538.6, 'ppm', NULL, NULL, '2026-11-02 11:31:13.757', '2026-11-02 11:31:13.757');
INSERT INTO `device_sensor_record` VALUES (85816, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 233.5, 'lx', NULL, NULL, '2026-11-02 11:31:13.757', '2026-11-02 11:31:13.757');
INSERT INTO `device_sensor_record` VALUES (85817, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.5, '℃', NULL, NULL, '2026-11-02 11:31:13.757', '2026-11-02 11:31:13.757');
INSERT INTO `device_sensor_record` VALUES (85818, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-02 11:31:13.757', '2026-11-02 11:31:13.757');
INSERT INTO `device_sensor_record` VALUES (85819, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.2, '℃', NULL, NULL, '2026-11-02 11:31:13.757', '2026-11-02 11:31:13.757');
INSERT INTO `device_sensor_record` VALUES (85820, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.34, 'V', NULL, NULL, '2026-11-02 11:31:13.757', '2026-11-02 11:31:13.757');
INSERT INTO `device_sensor_record` VALUES (85821, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 142094, 'bytes', NULL, NULL, '2026-11-02 11:31:13.757', '2026-11-02 11:31:13.757');
INSERT INTO `device_sensor_record` VALUES (85822, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'slave-1-temperature', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:31:26.747', '2026-11-02 11:31:26.768');
INSERT INTO `device_sensor_record` VALUES (85823, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'slave-2-humidity', 'humidity', 55, '%', NULL, NULL, '2026-11-02 11:31:26.747', '2026-11-02 11:31:26.839');
INSERT INTO `device_sensor_record` VALUES (85824, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'slave-3-pm25', 'pm25', 35, 'μg/m³', NULL, NULL, '2026-11-02 11:31:26.747', '2026-11-02 11:31:26.840');
INSERT INTO `device_sensor_record` VALUES (85825, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'slave-4-co2', 'co2', 450, 'ppm', NULL, NULL, '2026-11-02 11:31:26.747', '2026-11-02 11:31:26.840');
INSERT INTO `device_sensor_record` VALUES (85826, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'slave-5-illuminance', 'illuminance', 300, 'lx', NULL, NULL, '2026-11-02 11:31:26.747', '2026-11-02 11:31:26.841');
INSERT INTO `device_sensor_record` VALUES (85827, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'slave-6-temperature-ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:31:26.747', '2026-11-02 11:31:26.841');
INSERT INTO `device_sensor_record` VALUES (85828, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'slave-6-temperature-ch2', 'temperature', 24, '℃', NULL, NULL, '2026-11-02 11:31:26.747', '2026-11-02 11:31:26.842');
INSERT INTO `device_sensor_record` VALUES (85829, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.7, '℃', NULL, NULL, '2026-11-02 11:31:33.779', '2026-11-02 11:31:33.779');
INSERT INTO `device_sensor_record` VALUES (85830, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 60.1, '%', NULL, NULL, '2026-11-02 11:31:33.779', '2026-11-02 11:31:33.779');
INSERT INTO `device_sensor_record` VALUES (85831, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.3, 'μg/m³', NULL, NULL, '2026-11-02 11:31:33.779', '2026-11-02 11:31:33.779');
INSERT INTO `device_sensor_record` VALUES (85832, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 444.4, 'ppm', NULL, NULL, '2026-11-02 11:31:33.779', '2026-11-02 11:31:33.779');
INSERT INTO `device_sensor_record` VALUES (85833, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 551.7, 'lx', NULL, NULL, '2026-11-02 11:31:33.779', '2026-11-02 11:31:33.779');
INSERT INTO `device_sensor_record` VALUES (85834, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.3, '℃', NULL, NULL, '2026-11-02 11:31:33.779', '2026-11-02 11:31:33.779');
INSERT INTO `device_sensor_record` VALUES (85835, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-02 11:31:33.779', '2026-11-02 11:31:33.779');
INSERT INTO `device_sensor_record` VALUES (85836, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.6, '℃', NULL, NULL, '2026-11-02 11:31:33.779', '2026-11-02 11:31:33.779');
INSERT INTO `device_sensor_record` VALUES (85837, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-02 11:31:33.779', '2026-11-02 11:31:33.779');
INSERT INTO `device_sensor_record` VALUES (85838, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 136123, 'bytes', NULL, NULL, '2026-11-02 11:31:33.779', '2026-11-02 11:31:33.779');
INSERT INTO `device_sensor_record` VALUES (85839, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.4, '℃', NULL, NULL, '2026-11-02 11:31:43.789', '2026-11-02 11:31:43.789');
INSERT INTO `device_sensor_record` VALUES (85840, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.2, '%', NULL, NULL, '2026-11-02 11:31:43.789', '2026-11-02 11:31:43.789');
INSERT INTO `device_sensor_record` VALUES (85841, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.6, 'μg/m³', NULL, NULL, '2026-11-02 11:31:43.789', '2026-11-02 11:31:43.789');
INSERT INTO `device_sensor_record` VALUES (85842, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 404.5, 'ppm', NULL, NULL, '2026-11-02 11:31:43.789', '2026-11-02 11:31:43.789');
INSERT INTO `device_sensor_record` VALUES (85843, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 512.5, 'lx', NULL, NULL, '2026-11-02 11:31:43.789', '2026-11-02 11:31:43.789');
INSERT INTO `device_sensor_record` VALUES (85844, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.9, '℃', NULL, NULL, '2026-11-02 11:31:43.789', '2026-11-02 11:31:43.789');
INSERT INTO `device_sensor_record` VALUES (85845, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-02 11:31:43.789', '2026-11-02 11:31:43.789');
INSERT INTO `device_sensor_record` VALUES (85846, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.5, '℃', NULL, NULL, '2026-11-02 11:31:43.789', '2026-11-02 11:31:43.789');
INSERT INTO `device_sensor_record` VALUES (85847, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-02 11:31:43.789', '2026-11-02 11:31:43.789');
INSERT INTO `device_sensor_record` VALUES (85848, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 128515, 'bytes', NULL, NULL, '2026-11-02 11:31:43.789', '2026-11-02 11:31:43.789');
INSERT INTO `device_sensor_record` VALUES (85849, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:31:53.801', '2026-11-02 11:31:53.801');
INSERT INTO `device_sensor_record` VALUES (85850, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62.9, '%', NULL, NULL, '2026-11-02 11:31:53.801', '2026-11-02 11:31:53.801');
INSERT INTO `device_sensor_record` VALUES (85851, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 37.7, 'μg/m³', NULL, NULL, '2026-11-02 11:31:53.801', '2026-11-02 11:31:53.801');
INSERT INTO `device_sensor_record` VALUES (85852, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 419, 'ppm', NULL, NULL, '2026-11-02 11:31:53.801', '2026-11-02 11:31:53.801');
INSERT INTO `device_sensor_record` VALUES (85853, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 146.7, 'lx', NULL, NULL, '2026-11-02 11:31:53.801', '2026-11-02 11:31:53.801');
INSERT INTO `device_sensor_record` VALUES (85854, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.7, '℃', NULL, NULL, '2026-11-02 11:31:53.801', '2026-11-02 11:31:53.801');
INSERT INTO `device_sensor_record` VALUES (85855, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-02 11:31:53.801', '2026-11-02 11:31:53.801');
INSERT INTO `device_sensor_record` VALUES (85856, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.6, '℃', NULL, NULL, '2026-11-02 11:31:53.801', '2026-11-02 11:31:53.801');
INSERT INTO `device_sensor_record` VALUES (85857, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-02 11:31:53.801', '2026-11-02 11:31:53.801');
INSERT INTO `device_sensor_record` VALUES (85858, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 134861, 'bytes', NULL, NULL, '2026-11-02 11:31:53.801', '2026-11-02 11:31:53.801');
INSERT INTO `device_sensor_record` VALUES (85859, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:32:03.809', '2026-11-02 11:32:03.809');
INSERT INTO `device_sensor_record` VALUES (85860, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 51.7, '%', NULL, NULL, '2026-11-02 11:32:03.809', '2026-11-02 11:32:03.809');
INSERT INTO `device_sensor_record` VALUES (85861, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:32:03.809', '2026-11-02 11:32:03.809');
INSERT INTO `device_sensor_record` VALUES (85862, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 403.9, 'ppm', NULL, NULL, '2026-11-02 11:32:03.809', '2026-11-02 11:32:03.809');
INSERT INTO `device_sensor_record` VALUES (85863, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 241.2, 'lx', NULL, NULL, '2026-11-02 11:32:03.809', '2026-11-02 11:32:03.809');
INSERT INTO `device_sensor_record` VALUES (85864, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.3, '℃', NULL, NULL, '2026-11-02 11:32:03.809', '2026-11-02 11:32:03.809');
INSERT INTO `device_sensor_record` VALUES (85865, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:32:03.809', '2026-11-02 11:32:03.809');
INSERT INTO `device_sensor_record` VALUES (85866, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50, '℃', NULL, NULL, '2026-11-02 11:32:03.809', '2026-11-02 11:32:03.809');
INSERT INTO `device_sensor_record` VALUES (85867, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-02 11:32:03.809', '2026-11-02 11:32:03.809');
INSERT INTO `device_sensor_record` VALUES (85868, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 152818, 'bytes', NULL, NULL, '2026-11-02 11:32:03.809', '2026-11-02 11:32:03.809');
INSERT INTO `device_sensor_record` VALUES (85869, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:32:13.816', '2026-11-02 11:32:13.816');
INSERT INTO `device_sensor_record` VALUES (85870, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.6, '%', NULL, NULL, '2026-11-02 11:32:13.816', '2026-11-02 11:32:13.816');
INSERT INTO `device_sensor_record` VALUES (85871, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 30.6, 'μg/m³', NULL, NULL, '2026-11-02 11:32:13.816', '2026-11-02 11:32:13.816');
INSERT INTO `device_sensor_record` VALUES (85872, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 523.5, 'ppm', NULL, NULL, '2026-11-02 11:32:13.816', '2026-11-02 11:32:13.816');
INSERT INTO `device_sensor_record` VALUES (85873, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 213.2, 'lx', NULL, NULL, '2026-11-02 11:32:13.816', '2026-11-02 11:32:13.816');
INSERT INTO `device_sensor_record` VALUES (85874, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.4, '℃', NULL, NULL, '2026-11-02 11:32:13.816', '2026-11-02 11:32:13.816');
INSERT INTO `device_sensor_record` VALUES (85875, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.5, '℃', NULL, NULL, '2026-11-02 11:32:13.816', '2026-11-02 11:32:13.816');
INSERT INTO `device_sensor_record` VALUES (85876, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.1, '℃', NULL, NULL, '2026-11-02 11:32:13.816', '2026-11-02 11:32:13.816');
INSERT INTO `device_sensor_record` VALUES (85877, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.31, 'V', NULL, NULL, '2026-11-02 11:32:13.816', '2026-11-02 11:32:13.816');
INSERT INTO `device_sensor_record` VALUES (85878, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 143749, 'bytes', NULL, NULL, '2026-11-02 11:32:13.816', '2026-11-02 11:32:13.816');
INSERT INTO `device_sensor_record` VALUES (85879, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:32:23.829', '2026-11-02 11:32:23.829');
INSERT INTO `device_sensor_record` VALUES (85880, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.8, '%', NULL, NULL, '2026-11-02 11:32:23.829', '2026-11-02 11:32:23.829');
INSERT INTO `device_sensor_record` VALUES (85881, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 33.9, 'μg/m³', NULL, NULL, '2026-11-02 11:32:23.829', '2026-11-02 11:32:23.829');
INSERT INTO `device_sensor_record` VALUES (85882, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 522.4, 'ppm', NULL, NULL, '2026-11-02 11:32:23.829', '2026-11-02 11:32:23.829');
INSERT INTO `device_sensor_record` VALUES (85883, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 230.5, 'lx', NULL, NULL, '2026-11-02 11:32:23.829', '2026-11-02 11:32:23.829');
INSERT INTO `device_sensor_record` VALUES (85884, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.1, '℃', NULL, NULL, '2026-11-02 11:32:23.829', '2026-11-02 11:32:23.829');
INSERT INTO `device_sensor_record` VALUES (85885, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-02 11:32:23.829', '2026-11-02 11:32:23.829');
INSERT INTO `device_sensor_record` VALUES (85886, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.9, '℃', NULL, NULL, '2026-11-02 11:32:23.829', '2026-11-02 11:32:23.829');
INSERT INTO `device_sensor_record` VALUES (85887, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:32:23.829', '2026-11-02 11:32:23.829');
INSERT INTO `device_sensor_record` VALUES (85888, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 143955, 'bytes', NULL, NULL, '2026-11-02 11:32:23.829', '2026-11-02 11:32:23.829');
INSERT INTO `device_sensor_record` VALUES (85889, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:32:33.845', '2026-11-02 11:32:33.845');
INSERT INTO `device_sensor_record` VALUES (85890, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.4, '%', NULL, NULL, '2026-11-02 11:32:33.845', '2026-11-02 11:32:33.845');
INSERT INTO `device_sensor_record` VALUES (85891, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.2, 'μg/m³', NULL, NULL, '2026-11-02 11:32:33.845', '2026-11-02 11:32:33.845');
INSERT INTO `device_sensor_record` VALUES (85892, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 504, 'ppm', NULL, NULL, '2026-11-02 11:32:33.845', '2026-11-02 11:32:33.845');
INSERT INTO `device_sensor_record` VALUES (85893, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 767.5, 'lx', NULL, NULL, '2026-11-02 11:32:33.845', '2026-11-02 11:32:33.845');
INSERT INTO `device_sensor_record` VALUES (85894, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-02 11:32:33.845', '2026-11-02 11:32:33.845');
INSERT INTO `device_sensor_record` VALUES (85895, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-02 11:32:33.845', '2026-11-02 11:32:33.845');
INSERT INTO `device_sensor_record` VALUES (85896, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 45.9, '℃', NULL, NULL, '2026-11-02 11:32:33.845', '2026-11-02 11:32:33.845');
INSERT INTO `device_sensor_record` VALUES (85897, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-02 11:32:33.845', '2026-11-02 11:32:33.845');
INSERT INTO `device_sensor_record` VALUES (85898, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 175002, 'bytes', NULL, NULL, '2026-11-02 11:32:33.845', '2026-11-02 11:32:33.845');
INSERT INTO `device_sensor_record` VALUES (85899, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:32:43.851', '2026-11-02 11:32:43.851');
INSERT INTO `device_sensor_record` VALUES (85900, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.2, '%', NULL, NULL, '2026-11-02 11:32:43.851', '2026-11-02 11:32:43.851');
INSERT INTO `device_sensor_record` VALUES (85901, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 41.7, 'μg/m³', NULL, NULL, '2026-11-02 11:32:43.851', '2026-11-02 11:32:43.851');
INSERT INTO `device_sensor_record` VALUES (85902, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 544.6, 'ppm', NULL, NULL, '2026-11-02 11:32:43.851', '2026-11-02 11:32:43.851');
INSERT INTO `device_sensor_record` VALUES (85903, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 657.8, 'lx', NULL, NULL, '2026-11-02 11:32:43.851', '2026-11-02 11:32:43.851');
INSERT INTO `device_sensor_record` VALUES (85904, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-02 11:32:43.851', '2026-11-02 11:32:43.851');
INSERT INTO `device_sensor_record` VALUES (85905, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-02 11:32:43.851', '2026-11-02 11:32:43.851');
INSERT INTO `device_sensor_record` VALUES (85906, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46, '℃', NULL, NULL, '2026-11-02 11:32:43.851', '2026-11-02 11:32:43.851');
INSERT INTO `device_sensor_record` VALUES (85907, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:32:43.851', '2026-11-02 11:32:43.851');
INSERT INTO `device_sensor_record` VALUES (85908, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 150142, 'bytes', NULL, NULL, '2026-11-02 11:32:43.851', '2026-11-02 11:32:43.851');
INSERT INTO `device_sensor_record` VALUES (85909, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:32:53.865', '2026-11-02 11:32:53.865');
INSERT INTO `device_sensor_record` VALUES (85910, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.7, '%', NULL, NULL, '2026-11-02 11:32:53.865', '2026-11-02 11:32:53.865');
INSERT INTO `device_sensor_record` VALUES (85911, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:32:53.865', '2026-11-02 11:32:53.865');
INSERT INTO `device_sensor_record` VALUES (85912, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 592, 'ppm', NULL, NULL, '2026-11-02 11:32:53.865', '2026-11-02 11:32:53.865');
INSERT INTO `device_sensor_record` VALUES (85913, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 489.8, 'lx', NULL, NULL, '2026-11-02 11:32:53.865', '2026-11-02 11:32:53.865');
INSERT INTO `device_sensor_record` VALUES (85914, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.3, '℃', NULL, NULL, '2026-11-02 11:32:53.865', '2026-11-02 11:32:53.865');
INSERT INTO `device_sensor_record` VALUES (85915, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-02 11:32:53.865', '2026-11-02 11:32:53.865');
INSERT INTO `device_sensor_record` VALUES (85916, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.2, '℃', NULL, NULL, '2026-11-02 11:32:53.865', '2026-11-02 11:32:53.865');
INSERT INTO `device_sensor_record` VALUES (85917, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-02 11:32:53.865', '2026-11-02 11:32:53.865');
INSERT INTO `device_sensor_record` VALUES (85918, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 144358, 'bytes', NULL, NULL, '2026-11-02 11:32:53.865', '2026-11-02 11:32:53.865');
INSERT INTO `device_sensor_record` VALUES (85919, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.8, '℃', NULL, NULL, '2026-11-02 11:33:03.878', '2026-11-02 11:33:03.878');
INSERT INTO `device_sensor_record` VALUES (85920, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64.5, '%', NULL, NULL, '2026-11-02 11:33:03.878', '2026-11-02 11:33:03.878');
INSERT INTO `device_sensor_record` VALUES (85921, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 29, 'μg/m³', NULL, NULL, '2026-11-02 11:33:03.878', '2026-11-02 11:33:03.878');
INSERT INTO `device_sensor_record` VALUES (85922, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 477.5, 'ppm', NULL, NULL, '2026-11-02 11:33:03.878', '2026-11-02 11:33:03.878');
INSERT INTO `device_sensor_record` VALUES (85923, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 578.8, 'lx', NULL, NULL, '2026-11-02 11:33:03.878', '2026-11-02 11:33:03.878');
INSERT INTO `device_sensor_record` VALUES (85924, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-02 11:33:03.878', '2026-11-02 11:33:03.878');
INSERT INTO `device_sensor_record` VALUES (85925, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:33:03.878', '2026-11-02 11:33:03.878');
INSERT INTO `device_sensor_record` VALUES (85926, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.6, '℃', NULL, NULL, '2026-11-02 11:33:03.878', '2026-11-02 11:33:03.878');
INSERT INTO `device_sensor_record` VALUES (85927, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-02 11:33:03.878', '2026-11-02 11:33:03.878');
INSERT INTO `device_sensor_record` VALUES (85928, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 145878, 'bytes', NULL, NULL, '2026-11-02 11:33:03.878', '2026-11-02 11:33:03.878');
INSERT INTO `device_sensor_record` VALUES (85929, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.6, '℃', NULL, NULL, '2026-11-02 11:33:13.881', '2026-11-02 11:33:13.881');
INSERT INTO `device_sensor_record` VALUES (85930, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.9, '%', NULL, NULL, '2026-11-02 11:33:13.881', '2026-11-02 11:33:13.881');
INSERT INTO `device_sensor_record` VALUES (85931, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 47.8, 'μg/m³', NULL, NULL, '2026-11-02 11:33:13.881', '2026-11-02 11:33:13.881');
INSERT INTO `device_sensor_record` VALUES (85932, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 495.7, 'ppm', NULL, NULL, '2026-11-02 11:33:13.881', '2026-11-02 11:33:13.881');
INSERT INTO `device_sensor_record` VALUES (85933, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 643.3, 'lx', NULL, NULL, '2026-11-02 11:33:13.881', '2026-11-02 11:33:13.881');
INSERT INTO `device_sensor_record` VALUES (85934, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-02 11:33:13.881', '2026-11-02 11:33:13.881');
INSERT INTO `device_sensor_record` VALUES (85935, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 26, '℃', NULL, NULL, '2026-11-02 11:33:13.881', '2026-11-02 11:33:13.881');
INSERT INTO `device_sensor_record` VALUES (85936, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.7, '℃', NULL, NULL, '2026-11-02 11:33:13.881', '2026-11-02 11:33:13.881');
INSERT INTO `device_sensor_record` VALUES (85937, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-02 11:33:13.881', '2026-11-02 11:33:13.881');
INSERT INTO `device_sensor_record` VALUES (85938, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 152102, 'bytes', NULL, NULL, '2026-11-02 11:33:13.881', '2026-11-02 11:33:13.881');
INSERT INTO `device_sensor_record` VALUES (85939, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.4, '℃', NULL, NULL, '2026-11-02 11:33:23.886', '2026-11-02 11:33:23.886');
INSERT INTO `device_sensor_record` VALUES (85940, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.1, '%', NULL, NULL, '2026-11-02 11:33:23.886', '2026-11-02 11:33:23.886');
INSERT INTO `device_sensor_record` VALUES (85941, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 27.4, 'μg/m³', NULL, NULL, '2026-11-02 11:33:23.886', '2026-11-02 11:33:23.886');
INSERT INTO `device_sensor_record` VALUES (85942, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 435.7, 'ppm', NULL, NULL, '2026-11-02 11:33:23.886', '2026-11-02 11:33:23.886');
INSERT INTO `device_sensor_record` VALUES (85943, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 196.2, 'lx', NULL, NULL, '2026-11-02 11:33:23.886', '2026-11-02 11:33:23.886');
INSERT INTO `device_sensor_record` VALUES (85944, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20, '℃', NULL, NULL, '2026-11-02 11:33:23.886', '2026-11-02 11:33:23.886');
INSERT INTO `device_sensor_record` VALUES (85945, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.1, '℃', NULL, NULL, '2026-11-02 11:33:23.886', '2026-11-02 11:33:23.886');
INSERT INTO `device_sensor_record` VALUES (85946, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.2, '℃', NULL, NULL, '2026-11-02 11:33:23.886', '2026-11-02 11:33:23.886');
INSERT INTO `device_sensor_record` VALUES (85947, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-02 11:33:23.886', '2026-11-02 11:33:23.886');
INSERT INTO `device_sensor_record` VALUES (85948, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 125296, 'bytes', NULL, NULL, '2026-11-02 11:33:23.886', '2026-11-02 11:33:23.886');
INSERT INTO `device_sensor_record` VALUES (85949, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-02 11:33:33.890', '2026-11-02 11:33:33.890');
INSERT INTO `device_sensor_record` VALUES (85950, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64.1, '%', NULL, NULL, '2026-11-02 11:33:33.890', '2026-11-02 11:33:33.890');
INSERT INTO `device_sensor_record` VALUES (85951, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26, 'μg/m³', NULL, NULL, '2026-11-02 11:33:33.890', '2026-11-02 11:33:33.890');
INSERT INTO `device_sensor_record` VALUES (85952, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 484, 'ppm', NULL, NULL, '2026-11-02 11:33:33.890', '2026-11-02 11:33:33.890');
INSERT INTO `device_sensor_record` VALUES (85953, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 336.5, 'lx', NULL, NULL, '2026-11-02 11:33:33.890', '2026-11-02 11:33:33.890');
INSERT INTO `device_sensor_record` VALUES (85954, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.9, '℃', NULL, NULL, '2026-11-02 11:33:33.890', '2026-11-02 11:33:33.890');
INSERT INTO `device_sensor_record` VALUES (85955, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:33:33.890', '2026-11-02 11:33:33.890');
INSERT INTO `device_sensor_record` VALUES (85956, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.5, '℃', NULL, NULL, '2026-11-02 11:33:33.890', '2026-11-02 11:33:33.890');
INSERT INTO `device_sensor_record` VALUES (85957, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:33:33.890', '2026-11-02 11:33:33.890');
INSERT INTO `device_sensor_record` VALUES (85958, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 173939, 'bytes', NULL, NULL, '2026-11-02 11:33:33.890', '2026-11-02 11:33:33.890');
INSERT INTO `device_sensor_record` VALUES (85959, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:33:43.897', '2026-11-02 11:33:43.897');
INSERT INTO `device_sensor_record` VALUES (85960, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62, '%', NULL, NULL, '2026-11-02 11:33:43.897', '2026-11-02 11:33:43.897');
INSERT INTO `device_sensor_record` VALUES (85961, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:33:43.897', '2026-11-02 11:33:43.897');
INSERT INTO `device_sensor_record` VALUES (85962, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 566.6, 'ppm', NULL, NULL, '2026-11-02 11:33:43.897', '2026-11-02 11:33:43.897');
INSERT INTO `device_sensor_record` VALUES (85963, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 213.8, 'lx', NULL, NULL, '2026-11-02 11:33:43.897', '2026-11-02 11:33:43.897');
INSERT INTO `device_sensor_record` VALUES (85964, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-02 11:33:43.897', '2026-11-02 11:33:43.897');
INSERT INTO `device_sensor_record` VALUES (85965, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:33:43.897', '2026-11-02 11:33:43.897');
INSERT INTO `device_sensor_record` VALUES (85966, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.8, '℃', NULL, NULL, '2026-11-02 11:33:43.897', '2026-11-02 11:33:43.897');
INSERT INTO `device_sensor_record` VALUES (85967, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-02 11:33:43.897', '2026-11-02 11:33:43.897');
INSERT INTO `device_sensor_record` VALUES (85968, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 171529, 'bytes', NULL, NULL, '2026-11-02 11:33:43.897', '2026-11-02 11:33:43.897');
INSERT INTO `device_sensor_record` VALUES (85969, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.2, '℃', NULL, NULL, '2026-11-02 11:33:53.916', '2026-11-02 11:33:53.916');
INSERT INTO `device_sensor_record` VALUES (85970, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 68.8, '%', NULL, NULL, '2026-11-02 11:33:53.916', '2026-11-02 11:33:53.916');
INSERT INTO `device_sensor_record` VALUES (85971, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 43, 'μg/m³', NULL, NULL, '2026-11-02 11:33:53.916', '2026-11-02 11:33:53.916');
INSERT INTO `device_sensor_record` VALUES (85972, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 569.6, 'ppm', NULL, NULL, '2026-11-02 11:33:53.916', '2026-11-02 11:33:53.916');
INSERT INTO `device_sensor_record` VALUES (85973, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 312, 'lx', NULL, NULL, '2026-11-02 11:33:53.916', '2026-11-02 11:33:53.916');
INSERT INTO `device_sensor_record` VALUES (85974, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.3, '℃', NULL, NULL, '2026-11-02 11:33:53.916', '2026-11-02 11:33:53.916');
INSERT INTO `device_sensor_record` VALUES (85975, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:33:53.916', '2026-11-02 11:33:53.916');
INSERT INTO `device_sensor_record` VALUES (85976, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50, '℃', NULL, NULL, '2026-11-02 11:33:53.916', '2026-11-02 11:33:53.916');
INSERT INTO `device_sensor_record` VALUES (85977, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.4, 'V', NULL, NULL, '2026-11-02 11:33:53.916', '2026-11-02 11:33:53.916');
INSERT INTO `device_sensor_record` VALUES (85978, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 173938, 'bytes', NULL, NULL, '2026-11-02 11:33:53.916', '2026-11-02 11:33:53.916');
INSERT INTO `device_sensor_record` VALUES (85979, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-02 11:34:03.921', '2026-11-02 11:34:03.921');
INSERT INTO `device_sensor_record` VALUES (85980, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 50.5, '%', NULL, NULL, '2026-11-02 11:34:03.921', '2026-11-02 11:34:03.921');
INSERT INTO `device_sensor_record` VALUES (85981, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.5, 'μg/m³', NULL, NULL, '2026-11-02 11:34:03.921', '2026-11-02 11:34:03.921');
INSERT INTO `device_sensor_record` VALUES (85982, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 476.1, 'ppm', NULL, NULL, '2026-11-02 11:34:03.921', '2026-11-02 11:34:03.921');
INSERT INTO `device_sensor_record` VALUES (85983, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 569.9, 'lx', NULL, NULL, '2026-11-02 11:34:03.921', '2026-11-02 11:34:03.921');
INSERT INTO `device_sensor_record` VALUES (85984, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.7, '℃', NULL, NULL, '2026-11-02 11:34:03.921', '2026-11-02 11:34:03.921');
INSERT INTO `device_sensor_record` VALUES (85985, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-02 11:34:03.921', '2026-11-02 11:34:03.921');
INSERT INTO `device_sensor_record` VALUES (85986, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.9, '℃', NULL, NULL, '2026-11-02 11:34:03.921', '2026-11-02 11:34:03.921');
INSERT INTO `device_sensor_record` VALUES (85987, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-02 11:34:03.921', '2026-11-02 11:34:03.921');
INSERT INTO `device_sensor_record` VALUES (85988, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 127576, 'bytes', NULL, NULL, '2026-11-02 11:34:03.921', '2026-11-02 11:34:03.921');
INSERT INTO `device_sensor_record` VALUES (85989, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:34:13.938', '2026-11-02 11:34:13.938');
INSERT INTO `device_sensor_record` VALUES (85990, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52, '%', NULL, NULL, '2026-11-02 11:34:13.938', '2026-11-02 11:34:13.938');
INSERT INTO `device_sensor_record` VALUES (85991, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 41.1, 'μg/m³', NULL, NULL, '2026-11-02 11:34:13.938', '2026-11-02 11:34:13.938');
INSERT INTO `device_sensor_record` VALUES (85992, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 566.1, 'ppm', NULL, NULL, '2026-11-02 11:34:13.938', '2026-11-02 11:34:13.938');
INSERT INTO `device_sensor_record` VALUES (85993, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 585.9, 'lx', NULL, NULL, '2026-11-02 11:34:13.938', '2026-11-02 11:34:13.938');
INSERT INTO `device_sensor_record` VALUES (85994, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-02 11:34:13.938', '2026-11-02 11:34:13.938');
INSERT INTO `device_sensor_record` VALUES (85995, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.1, '℃', NULL, NULL, '2026-11-02 11:34:13.938', '2026-11-02 11:34:13.938');
INSERT INTO `device_sensor_record` VALUES (85996, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.4, '℃', NULL, NULL, '2026-11-02 11:34:13.938', '2026-11-02 11:34:13.938');
INSERT INTO `device_sensor_record` VALUES (85997, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.39, 'V', NULL, NULL, '2026-11-02 11:34:13.938', '2026-11-02 11:34:13.938');
INSERT INTO `device_sensor_record` VALUES (85998, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 140599, 'bytes', NULL, NULL, '2026-11-02 11:34:13.938', '2026-11-02 11:34:13.938');
INSERT INTO `device_sensor_record` VALUES (85999, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:34:23.946', '2026-11-02 11:34:23.946');
INSERT INTO `device_sensor_record` VALUES (86000, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.3, '%', NULL, NULL, '2026-11-02 11:34:23.946', '2026-11-02 11:34:23.946');
INSERT INTO `device_sensor_record` VALUES (86001, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 37.6, 'μg/m³', NULL, NULL, '2026-11-02 11:34:23.946', '2026-11-02 11:34:23.946');
INSERT INTO `device_sensor_record` VALUES (86002, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 530.8, 'ppm', NULL, NULL, '2026-11-02 11:34:23.946', '2026-11-02 11:34:23.946');
INSERT INTO `device_sensor_record` VALUES (86003, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 786.2, 'lx', NULL, NULL, '2026-11-02 11:34:23.946', '2026-11-02 11:34:23.946');
INSERT INTO `device_sensor_record` VALUES (86004, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.6, '℃', NULL, NULL, '2026-11-02 11:34:23.946', '2026-11-02 11:34:23.946');
INSERT INTO `device_sensor_record` VALUES (86005, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.9, '℃', NULL, NULL, '2026-11-02 11:34:23.946', '2026-11-02 11:34:23.946');
INSERT INTO `device_sensor_record` VALUES (86006, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.2, '℃', NULL, NULL, '2026-11-02 11:34:23.946', '2026-11-02 11:34:23.946');
INSERT INTO `device_sensor_record` VALUES (86007, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-02 11:34:23.946', '2026-11-02 11:34:23.946');
INSERT INTO `device_sensor_record` VALUES (86008, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 143355, 'bytes', NULL, NULL, '2026-11-02 11:34:23.946', '2026-11-02 11:34:23.946');
INSERT INTO `device_sensor_record` VALUES (86009, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:34:33.946', '2026-11-02 11:34:33.946');
INSERT INTO `device_sensor_record` VALUES (86010, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.7, '%', NULL, NULL, '2026-11-02 11:34:33.946', '2026-11-02 11:34:33.946');
INSERT INTO `device_sensor_record` VALUES (86011, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:34:33.946', '2026-11-02 11:34:33.946');
INSERT INTO `device_sensor_record` VALUES (86012, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 595.7, 'ppm', NULL, NULL, '2026-11-02 11:34:33.946', '2026-11-02 11:34:33.946');
INSERT INTO `device_sensor_record` VALUES (86013, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 352.9, 'lx', NULL, NULL, '2026-11-02 11:34:33.946', '2026-11-02 11:34:33.946');
INSERT INTO `device_sensor_record` VALUES (86014, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.3, '℃', NULL, NULL, '2026-11-02 11:34:33.946', '2026-11-02 11:34:33.946');
INSERT INTO `device_sensor_record` VALUES (86015, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-02 11:34:33.946', '2026-11-02 11:34:33.946');
INSERT INTO `device_sensor_record` VALUES (86016, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.4, '℃', NULL, NULL, '2026-11-02 11:34:33.946', '2026-11-02 11:34:33.946');
INSERT INTO `device_sensor_record` VALUES (86017, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.32, 'V', NULL, NULL, '2026-11-02 11:34:33.946', '2026-11-02 11:34:33.946');
INSERT INTO `device_sensor_record` VALUES (86018, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 157097, 'bytes', NULL, NULL, '2026-11-02 11:34:33.946', '2026-11-02 11:34:33.946');
INSERT INTO `device_sensor_record` VALUES (86019, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.4, '℃', NULL, NULL, '2026-11-02 11:34:43.960', '2026-11-02 11:34:43.960');
INSERT INTO `device_sensor_record` VALUES (86020, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.1, '%', NULL, NULL, '2026-11-02 11:34:43.960', '2026-11-02 11:34:43.960');
INSERT INTO `device_sensor_record` VALUES (86021, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 26, 'μg/m³', NULL, NULL, '2026-11-02 11:34:43.960', '2026-11-02 11:34:43.960');
INSERT INTO `device_sensor_record` VALUES (86022, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 598.3, 'ppm', NULL, NULL, '2026-11-02 11:34:43.960', '2026-11-02 11:34:43.960');
INSERT INTO `device_sensor_record` VALUES (86023, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 531.9, 'lx', NULL, NULL, '2026-11-02 11:34:43.960', '2026-11-02 11:34:43.960');
INSERT INTO `device_sensor_record` VALUES (86024, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-02 11:34:43.960', '2026-11-02 11:34:43.960');
INSERT INTO `device_sensor_record` VALUES (86025, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:34:43.960', '2026-11-02 11:34:43.960');
INSERT INTO `device_sensor_record` VALUES (86026, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.9, '℃', NULL, NULL, '2026-11-02 11:34:43.960', '2026-11-02 11:34:43.960');
INSERT INTO `device_sensor_record` VALUES (86027, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:34:43.960', '2026-11-02 11:34:43.960');
INSERT INTO `device_sensor_record` VALUES (86028, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 159722, 'bytes', NULL, NULL, '2026-11-02 11:34:43.960', '2026-11-02 11:34:43.960');
INSERT INTO `device_sensor_record` VALUES (86029, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.9, '℃', NULL, NULL, '2026-11-02 11:34:53.961', '2026-11-02 11:34:53.961');
INSERT INTO `device_sensor_record` VALUES (86030, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.2, '%', NULL, NULL, '2026-11-02 11:34:53.961', '2026-11-02 11:34:53.961');
INSERT INTO `device_sensor_record` VALUES (86031, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 25.4, 'μg/m³', NULL, NULL, '2026-11-02 11:34:53.961', '2026-11-02 11:34:53.961');
INSERT INTO `device_sensor_record` VALUES (86032, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 570.9, 'ppm', NULL, NULL, '2026-11-02 11:34:53.961', '2026-11-02 11:34:53.961');
INSERT INTO `device_sensor_record` VALUES (86033, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 760.7, 'lx', NULL, NULL, '2026-11-02 11:34:53.961', '2026-11-02 11:34:53.961');
INSERT INTO `device_sensor_record` VALUES (86034, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-02 11:34:53.961', '2026-11-02 11:34:53.961');
INSERT INTO `device_sensor_record` VALUES (86035, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23, '℃', NULL, NULL, '2026-11-02 11:34:53.961', '2026-11-02 11:34:53.961');
INSERT INTO `device_sensor_record` VALUES (86036, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.1, '℃', NULL, NULL, '2026-11-02 11:34:53.961', '2026-11-02 11:34:53.961');
INSERT INTO `device_sensor_record` VALUES (86037, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:34:53.961', '2026-11-02 11:34:53.961');
INSERT INTO `device_sensor_record` VALUES (86038, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 120222, 'bytes', NULL, NULL, '2026-11-02 11:34:53.961', '2026-11-02 11:34:53.961');
INSERT INTO `device_sensor_record` VALUES (86039, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.1, '℃', NULL, NULL, '2026-11-02 11:35:03.969', '2026-11-02 11:35:03.969');
INSERT INTO `device_sensor_record` VALUES (86040, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.7, '%', NULL, NULL, '2026-11-02 11:35:03.969', '2026-11-02 11:35:03.969');
INSERT INTO `device_sensor_record` VALUES (86041, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 29.5, 'μg/m³', NULL, NULL, '2026-11-02 11:35:03.969', '2026-11-02 11:35:03.969');
INSERT INTO `device_sensor_record` VALUES (86042, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 543.6, 'ppm', NULL, NULL, '2026-11-02 11:35:03.969', '2026-11-02 11:35:03.969');
INSERT INTO `device_sensor_record` VALUES (86043, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 415.2, 'lx', NULL, NULL, '2026-11-02 11:35:03.969', '2026-11-02 11:35:03.969');
INSERT INTO `device_sensor_record` VALUES (86044, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-02 11:35:03.969', '2026-11-02 11:35:03.969');
INSERT INTO `device_sensor_record` VALUES (86045, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-02 11:35:03.969', '2026-11-02 11:35:03.969');
INSERT INTO `device_sensor_record` VALUES (86046, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.9, '℃', NULL, NULL, '2026-11-02 11:35:03.969', '2026-11-02 11:35:03.969');
INSERT INTO `device_sensor_record` VALUES (86047, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-02 11:35:03.969', '2026-11-02 11:35:03.969');
INSERT INTO `device_sensor_record` VALUES (86048, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 163314, 'bytes', NULL, NULL, '2026-11-02 11:35:03.969', '2026-11-02 11:35:03.969');
INSERT INTO `device_sensor_record` VALUES (86049, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:35:13.977', '2026-11-02 11:35:13.977');
INSERT INTO `device_sensor_record` VALUES (86050, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.2, '%', NULL, NULL, '2026-11-02 11:35:13.977', '2026-11-02 11:35:13.977');
INSERT INTO `device_sensor_record` VALUES (86051, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 38.4, 'μg/m³', NULL, NULL, '2026-11-02 11:35:13.977', '2026-11-02 11:35:13.977');
INSERT INTO `device_sensor_record` VALUES (86052, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 505.1, 'ppm', NULL, NULL, '2026-11-02 11:35:13.977', '2026-11-02 11:35:13.977');
INSERT INTO `device_sensor_record` VALUES (86053, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 143.2, 'lx', NULL, NULL, '2026-11-02 11:35:13.977', '2026-11-02 11:35:13.977');
INSERT INTO `device_sensor_record` VALUES (86054, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:35:13.977', '2026-11-02 11:35:13.977');
INSERT INTO `device_sensor_record` VALUES (86055, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:35:13.977', '2026-11-02 11:35:13.977');
INSERT INTO `device_sensor_record` VALUES (86056, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.8, '℃', NULL, NULL, '2026-11-02 11:35:13.977', '2026-11-02 11:35:13.977');
INSERT INTO `device_sensor_record` VALUES (86057, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-02 11:35:13.977', '2026-11-02 11:35:13.977');
INSERT INTO `device_sensor_record` VALUES (86058, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 168492, 'bytes', NULL, NULL, '2026-11-02 11:35:13.977', '2026-11-02 11:35:13.977');
INSERT INTO `device_sensor_record` VALUES (86059, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:35:23.984', '2026-11-02 11:35:23.984');
INSERT INTO `device_sensor_record` VALUES (86060, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.6, '%', NULL, NULL, '2026-11-02 11:35:23.984', '2026-11-02 11:35:23.984');
INSERT INTO `device_sensor_record` VALUES (86061, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:35:23.984', '2026-11-02 11:35:23.984');
INSERT INTO `device_sensor_record` VALUES (86062, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 487.1, 'ppm', NULL, NULL, '2026-11-02 11:35:23.984', '2026-11-02 11:35:23.984');
INSERT INTO `device_sensor_record` VALUES (86063, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 158.4, 'lx', NULL, NULL, '2026-11-02 11:35:23.984', '2026-11-02 11:35:23.984');
INSERT INTO `device_sensor_record` VALUES (86064, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.3, '℃', NULL, NULL, '2026-11-02 11:35:23.984', '2026-11-02 11:35:23.984');
INSERT INTO `device_sensor_record` VALUES (86065, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-02 11:35:23.984', '2026-11-02 11:35:23.984');
INSERT INTO `device_sensor_record` VALUES (86066, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.5, '℃', NULL, NULL, '2026-11-02 11:35:23.984', '2026-11-02 11:35:23.984');
INSERT INTO `device_sensor_record` VALUES (86067, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-02 11:35:23.984', '2026-11-02 11:35:23.984');
INSERT INTO `device_sensor_record` VALUES (86068, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 122763, 'bytes', NULL, NULL, '2026-11-02 11:35:23.984', '2026-11-02 11:35:23.984');
INSERT INTO `device_sensor_record` VALUES (86069, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:35:33.980', '2026-11-02 11:35:33.980');
INSERT INTO `device_sensor_record` VALUES (86070, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.8, '%', NULL, NULL, '2026-11-02 11:35:33.980', '2026-11-02 11:35:33.980');
INSERT INTO `device_sensor_record` VALUES (86071, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 37.4, 'μg/m³', NULL, NULL, '2026-11-02 11:35:33.980', '2026-11-02 11:35:33.980');
INSERT INTO `device_sensor_record` VALUES (86072, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 416.5, 'ppm', NULL, NULL, '2026-11-02 11:35:33.980', '2026-11-02 11:35:33.980');
INSERT INTO `device_sensor_record` VALUES (86073, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 442.6, 'lx', NULL, NULL, '2026-11-02 11:35:33.980', '2026-11-02 11:35:33.980');
INSERT INTO `device_sensor_record` VALUES (86074, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-02 11:35:33.980', '2026-11-02 11:35:33.980');
INSERT INTO `device_sensor_record` VALUES (86075, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.6, '℃', NULL, NULL, '2026-11-02 11:35:33.980', '2026-11-02 11:35:33.980');
INSERT INTO `device_sensor_record` VALUES (86076, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.1, '℃', NULL, NULL, '2026-11-02 11:35:33.980', '2026-11-02 11:35:33.980');
INSERT INTO `device_sensor_record` VALUES (86077, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:35:33.980', '2026-11-02 11:35:33.980');
INSERT INTO `device_sensor_record` VALUES (86078, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 153962, 'bytes', NULL, NULL, '2026-11-02 11:35:33.980', '2026-11-02 11:35:33.980');
INSERT INTO `device_sensor_record` VALUES (86079, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.4, '℃', NULL, NULL, '2026-11-02 11:35:43.997', '2026-11-02 11:35:43.997');
INSERT INTO `device_sensor_record` VALUES (86080, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 62, '%', NULL, NULL, '2026-11-02 11:35:43.997', '2026-11-02 11:35:43.997');
INSERT INTO `device_sensor_record` VALUES (86081, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 49.1, 'μg/m³', NULL, NULL, '2026-11-02 11:35:43.997', '2026-11-02 11:35:43.997');
INSERT INTO `device_sensor_record` VALUES (86082, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 534.2, 'ppm', NULL, NULL, '2026-11-02 11:35:43.997', '2026-11-02 11:35:43.997');
INSERT INTO `device_sensor_record` VALUES (86083, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 678.2, 'lx', NULL, NULL, '2026-11-02 11:35:43.997', '2026-11-02 11:35:43.997');
INSERT INTO `device_sensor_record` VALUES (86084, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.2, '℃', NULL, NULL, '2026-11-02 11:35:43.997', '2026-11-02 11:35:43.997');
INSERT INTO `device_sensor_record` VALUES (86085, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.7, '℃', NULL, NULL, '2026-11-02 11:35:43.997', '2026-11-02 11:35:43.997');
INSERT INTO `device_sensor_record` VALUES (86086, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.2, '℃', NULL, NULL, '2026-11-02 11:35:43.997', '2026-11-02 11:35:43.997');
INSERT INTO `device_sensor_record` VALUES (86087, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-02 11:35:43.997', '2026-11-02 11:35:43.997');
INSERT INTO `device_sensor_record` VALUES (86088, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 124721, 'bytes', NULL, NULL, '2026-11-02 11:35:43.997', '2026-11-02 11:35:43.997');
INSERT INTO `device_sensor_record` VALUES (86089, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27, '℃', NULL, NULL, '2026-11-02 11:35:54.000', '2026-11-02 11:35:54.000');
INSERT INTO `device_sensor_record` VALUES (86090, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 64, '%', NULL, NULL, '2026-11-02 11:35:54.000', '2026-11-02 11:35:54.000');
INSERT INTO `device_sensor_record` VALUES (86091, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 33.7, 'μg/m³', NULL, NULL, '2026-11-02 11:35:54.000', '2026-11-02 11:35:54.000');
INSERT INTO `device_sensor_record` VALUES (86092, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 431.6, 'ppm', NULL, NULL, '2026-11-02 11:35:54.000', '2026-11-02 11:35:54.000');
INSERT INTO `device_sensor_record` VALUES (86093, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 316.3, 'lx', NULL, NULL, '2026-11-02 11:35:54.000', '2026-11-02 11:35:54.000');
INSERT INTO `device_sensor_record` VALUES (86094, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.1, '℃', NULL, NULL, '2026-11-02 11:35:54.000', '2026-11-02 11:35:54.000');
INSERT INTO `device_sensor_record` VALUES (86095, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.2, '℃', NULL, NULL, '2026-11-02 11:35:54.000', '2026-11-02 11:35:54.000');
INSERT INTO `device_sensor_record` VALUES (86096, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 50.1, '℃', NULL, NULL, '2026-11-02 11:35:54.000', '2026-11-02 11:35:54.000');
INSERT INTO `device_sensor_record` VALUES (86097, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:35:54.000', '2026-11-02 11:35:54.000');
INSERT INTO `device_sensor_record` VALUES (86098, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 123124, 'bytes', NULL, NULL, '2026-11-02 11:35:54.000', '2026-11-02 11:35:54.000');
INSERT INTO `device_sensor_record` VALUES (86099, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.4, '℃', NULL, NULL, '2026-11-02 11:36:04.012', '2026-11-02 11:36:04.012');
INSERT INTO `device_sensor_record` VALUES (86100, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.9, '%', NULL, NULL, '2026-11-02 11:36:04.012', '2026-11-02 11:36:04.012');
INSERT INTO `device_sensor_record` VALUES (86101, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 34.1, 'μg/m³', NULL, NULL, '2026-11-02 11:36:04.012', '2026-11-02 11:36:04.012');
INSERT INTO `device_sensor_record` VALUES (86102, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 594.9, 'ppm', NULL, NULL, '2026-11-02 11:36:04.012', '2026-11-02 11:36:04.012');
INSERT INTO `device_sensor_record` VALUES (86103, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 252.8, 'lx', NULL, NULL, '2026-11-02 11:36:04.012', '2026-11-02 11:36:04.012');
INSERT INTO `device_sensor_record` VALUES (86104, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-02 11:36:04.012', '2026-11-02 11:36:04.012');
INSERT INTO `device_sensor_record` VALUES (86105, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.2, '℃', NULL, NULL, '2026-11-02 11:36:04.012', '2026-11-02 11:36:04.012');
INSERT INTO `device_sensor_record` VALUES (86106, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52, '℃', NULL, NULL, '2026-11-02 11:36:04.012', '2026-11-02 11:36:04.012');
INSERT INTO `device_sensor_record` VALUES (86107, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:36:04.012', '2026-11-02 11:36:04.012');
INSERT INTO `device_sensor_record` VALUES (86108, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 133490, 'bytes', NULL, NULL, '2026-11-02 11:36:04.012', '2026-11-02 11:36:04.012');
INSERT INTO `device_sensor_record` VALUES (86109, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:36:14.015', '2026-11-02 11:36:14.015');
INSERT INTO `device_sensor_record` VALUES (86110, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.8, '%', NULL, NULL, '2026-11-02 11:36:14.015', '2026-11-02 11:36:14.015');
INSERT INTO `device_sensor_record` VALUES (86111, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:36:14.015', '2026-11-02 11:36:14.015');
INSERT INTO `device_sensor_record` VALUES (86112, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 437.1, 'ppm', NULL, NULL, '2026-11-02 11:36:14.015', '2026-11-02 11:36:14.015');
INSERT INTO `device_sensor_record` VALUES (86113, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 536.5, 'lx', NULL, NULL, '2026-11-02 11:36:14.015', '2026-11-02 11:36:14.015');
INSERT INTO `device_sensor_record` VALUES (86114, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-02 11:36:14.015', '2026-11-02 11:36:14.015');
INSERT INTO `device_sensor_record` VALUES (86115, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.8, '℃', NULL, NULL, '2026-11-02 11:36:14.015', '2026-11-02 11:36:14.015');
INSERT INTO `device_sensor_record` VALUES (86116, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.1, '℃', NULL, NULL, '2026-11-02 11:36:14.015', '2026-11-02 11:36:14.015');
INSERT INTO `device_sensor_record` VALUES (86117, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.4, 'V', NULL, NULL, '2026-11-02 11:36:14.015', '2026-11-02 11:36:14.015');
INSERT INTO `device_sensor_record` VALUES (86118, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 135922, 'bytes', NULL, NULL, '2026-11-02 11:36:14.015', '2026-11-02 11:36:14.015');
INSERT INTO `device_sensor_record` VALUES (86119, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.2, '℃', NULL, NULL, '2026-11-02 11:36:24.031', '2026-11-02 11:36:24.031');
INSERT INTO `device_sensor_record` VALUES (86120, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63.4, '%', NULL, NULL, '2026-11-02 11:36:24.031', '2026-11-02 11:36:24.031');
INSERT INTO `device_sensor_record` VALUES (86121, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 25.1, 'μg/m³', NULL, NULL, '2026-11-02 11:36:24.031', '2026-11-02 11:36:24.031');
INSERT INTO `device_sensor_record` VALUES (86122, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 560.8, 'ppm', NULL, NULL, '2026-11-02 11:36:24.031', '2026-11-02 11:36:24.031');
INSERT INTO `device_sensor_record` VALUES (86123, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 282.8, 'lx', NULL, NULL, '2026-11-02 11:36:24.031', '2026-11-02 11:36:24.031');
INSERT INTO `device_sensor_record` VALUES (86124, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22, '℃', NULL, NULL, '2026-11-02 11:36:24.031', '2026-11-02 11:36:24.031');
INSERT INTO `device_sensor_record` VALUES (86125, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.7, '℃', NULL, NULL, '2026-11-02 11:36:24.031', '2026-11-02 11:36:24.031');
INSERT INTO `device_sensor_record` VALUES (86126, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.3, '℃', NULL, NULL, '2026-11-02 11:36:24.031', '2026-11-02 11:36:24.031');
INSERT INTO `device_sensor_record` VALUES (86127, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-02 11:36:24.031', '2026-11-02 11:36:24.031');
INSERT INTO `device_sensor_record` VALUES (86128, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 165250, 'bytes', NULL, NULL, '2026-11-02 11:36:24.031', '2026-11-02 11:36:24.031');
INSERT INTO `device_sensor_record` VALUES (86129, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:36:34.033', '2026-11-02 11:36:34.033');
INSERT INTO `device_sensor_record` VALUES (86130, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.3, '%', NULL, NULL, '2026-11-02 11:36:34.033', '2026-11-02 11:36:34.033');
INSERT INTO `device_sensor_record` VALUES (86131, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 35.4, 'μg/m³', NULL, NULL, '2026-11-02 11:36:34.033', '2026-11-02 11:36:34.033');
INSERT INTO `device_sensor_record` VALUES (86132, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 413.3, 'ppm', NULL, NULL, '2026-11-02 11:36:34.033', '2026-11-02 11:36:34.033');
INSERT INTO `device_sensor_record` VALUES (86133, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 393, 'lx', NULL, NULL, '2026-11-02 11:36:34.033', '2026-11-02 11:36:34.033');
INSERT INTO `device_sensor_record` VALUES (86134, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.7, '℃', NULL, NULL, '2026-11-02 11:36:34.033', '2026-11-02 11:36:34.033');
INSERT INTO `device_sensor_record` VALUES (86135, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:36:34.033', '2026-11-02 11:36:34.033');
INSERT INTO `device_sensor_record` VALUES (86136, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.5, '℃', NULL, NULL, '2026-11-02 11:36:34.033', '2026-11-02 11:36:34.033');
INSERT INTO `device_sensor_record` VALUES (86137, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-02 11:36:34.033', '2026-11-02 11:36:34.033');
INSERT INTO `device_sensor_record` VALUES (86138, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 176628, 'bytes', NULL, NULL, '2026-11-02 11:36:34.033', '2026-11-02 11:36:34.033');
INSERT INTO `device_sensor_record` VALUES (86139, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.5, '℃', NULL, NULL, '2026-11-02 11:36:44.035', '2026-11-02 11:36:44.035');
INSERT INTO `device_sensor_record` VALUES (86140, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.7, '%', NULL, NULL, '2026-11-02 11:36:44.035', '2026-11-02 11:36:44.035');
INSERT INTO `device_sensor_record` VALUES (86141, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 47.5, 'μg/m³', NULL, NULL, '2026-11-02 11:36:44.035', '2026-11-02 11:36:44.035');
INSERT INTO `device_sensor_record` VALUES (86142, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 466, 'ppm', NULL, NULL, '2026-11-02 11:36:44.035', '2026-11-02 11:36:44.035');
INSERT INTO `device_sensor_record` VALUES (86143, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 468.4, 'lx', NULL, NULL, '2026-11-02 11:36:44.035', '2026-11-02 11:36:44.035');
INSERT INTO `device_sensor_record` VALUES (86144, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.2, '℃', NULL, NULL, '2026-11-02 11:36:44.035', '2026-11-02 11:36:44.035');
INSERT INTO `device_sensor_record` VALUES (86145, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.1, '℃', NULL, NULL, '2026-11-02 11:36:44.035', '2026-11-02 11:36:44.035');
INSERT INTO `device_sensor_record` VALUES (86146, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.8, '℃', NULL, NULL, '2026-11-02 11:36:44.035', '2026-11-02 11:36:44.035');
INSERT INTO `device_sensor_record` VALUES (86147, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.23, 'V', NULL, NULL, '2026-11-02 11:36:44.035', '2026-11-02 11:36:44.035');
INSERT INTO `device_sensor_record` VALUES (86148, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 160531, 'bytes', NULL, NULL, '2026-11-02 11:36:44.035', '2026-11-02 11:36:44.035');
INSERT INTO `device_sensor_record` VALUES (86149, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.2, '℃', NULL, NULL, '2026-11-02 11:36:54.042', '2026-11-02 11:36:54.042');
INSERT INTO `device_sensor_record` VALUES (86150, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.7, '%', NULL, NULL, '2026-11-02 11:36:54.042', '2026-11-02 11:36:54.042');
INSERT INTO `device_sensor_record` VALUES (86151, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 40.5, 'μg/m³', NULL, NULL, '2026-11-02 11:36:54.042', '2026-11-02 11:36:54.042');
INSERT INTO `device_sensor_record` VALUES (86152, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 437.7, 'ppm', NULL, NULL, '2026-11-02 11:36:54.042', '2026-11-02 11:36:54.042');
INSERT INTO `device_sensor_record` VALUES (86153, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 318.1, 'lx', NULL, NULL, '2026-11-02 11:36:54.042', '2026-11-02 11:36:54.042');
INSERT INTO `device_sensor_record` VALUES (86154, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.9, '℃', NULL, NULL, '2026-11-02 11:36:54.042', '2026-11-02 11:36:54.042');
INSERT INTO `device_sensor_record` VALUES (86155, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.8, '℃', NULL, NULL, '2026-11-02 11:36:54.042', '2026-11-02 11:36:54.042');
INSERT INTO `device_sensor_record` VALUES (86156, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.1, '℃', NULL, NULL, '2026-11-02 11:36:54.042', '2026-11-02 11:36:54.042');
INSERT INTO `device_sensor_record` VALUES (86157, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-02 11:36:54.042', '2026-11-02 11:36:54.042');
INSERT INTO `device_sensor_record` VALUES (86158, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 146231, 'bytes', NULL, NULL, '2026-11-02 11:36:54.042', '2026-11-02 11:36:54.042');
INSERT INTO `device_sensor_record` VALUES (86159, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:37:04.051', '2026-11-02 11:37:04.051');
INSERT INTO `device_sensor_record` VALUES (86160, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.6, '%', NULL, NULL, '2026-11-02 11:37:04.051', '2026-11-02 11:37:04.051');
INSERT INTO `device_sensor_record` VALUES (86161, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:37:04.051', '2026-11-02 11:37:04.051');
INSERT INTO `device_sensor_record` VALUES (86162, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 466.2, 'ppm', NULL, NULL, '2026-11-02 11:37:04.051', '2026-11-02 11:37:04.051');
INSERT INTO `device_sensor_record` VALUES (86163, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 564.3, 'lx', NULL, NULL, '2026-11-02 11:37:04.051', '2026-11-02 11:37:04.051');
INSERT INTO `device_sensor_record` VALUES (86164, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.2, '℃', NULL, NULL, '2026-11-02 11:37:04.051', '2026-11-02 11:37:04.051');
INSERT INTO `device_sensor_record` VALUES (86165, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.4, '℃', NULL, NULL, '2026-11-02 11:37:04.051', '2026-11-02 11:37:04.051');
INSERT INTO `device_sensor_record` VALUES (86166, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.2, '℃', NULL, NULL, '2026-11-02 11:37:04.051', '2026-11-02 11:37:04.051');
INSERT INTO `device_sensor_record` VALUES (86167, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-02 11:37:04.051', '2026-11-02 11:37:04.051');
INSERT INTO `device_sensor_record` VALUES (86168, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 169671, 'bytes', NULL, NULL, '2026-11-02 11:37:04.051', '2026-11-02 11:37:04.051');
INSERT INTO `device_sensor_record` VALUES (86169, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-02 11:37:14.057', '2026-11-02 11:37:14.057');
INSERT INTO `device_sensor_record` VALUES (86170, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 56.8, '%', NULL, NULL, '2026-11-02 11:37:14.057', '2026-11-02 11:37:14.057');
INSERT INTO `device_sensor_record` VALUES (86171, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 25.1, 'μg/m³', NULL, NULL, '2026-11-02 11:37:14.057', '2026-11-02 11:37:14.057');
INSERT INTO `device_sensor_record` VALUES (86172, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 459.4, 'ppm', NULL, NULL, '2026-11-02 11:37:14.057', '2026-11-02 11:37:14.057');
INSERT INTO `device_sensor_record` VALUES (86173, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 400.2, 'lx', NULL, NULL, '2026-11-02 11:37:14.057', '2026-11-02 11:37:14.057');
INSERT INTO `device_sensor_record` VALUES (86174, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.1, '℃', NULL, NULL, '2026-11-02 11:37:14.057', '2026-11-02 11:37:14.057');
INSERT INTO `device_sensor_record` VALUES (86175, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:37:14.057', '2026-11-02 11:37:14.057');
INSERT INTO `device_sensor_record` VALUES (86176, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46, '℃', NULL, NULL, '2026-11-02 11:37:14.057', '2026-11-02 11:37:14.057');
INSERT INTO `device_sensor_record` VALUES (86177, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:37:14.057', '2026-11-02 11:37:14.057');
INSERT INTO `device_sensor_record` VALUES (86178, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 123204, 'bytes', NULL, NULL, '2026-11-02 11:37:14.057', '2026-11-02 11:37:14.057');
INSERT INTO `device_sensor_record` VALUES (86179, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.7, '℃', NULL, NULL, '2026-11-02 11:37:24.058', '2026-11-02 11:37:24.058');
INSERT INTO `device_sensor_record` VALUES (86180, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55.8, '%', NULL, NULL, '2026-11-02 11:37:24.058', '2026-11-02 11:37:24.058');
INSERT INTO `device_sensor_record` VALUES (86181, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 48.4, 'μg/m³', NULL, NULL, '2026-11-02 11:37:24.058', '2026-11-02 11:37:24.058');
INSERT INTO `device_sensor_record` VALUES (86182, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 501.4, 'ppm', NULL, NULL, '2026-11-02 11:37:24.058', '2026-11-02 11:37:24.058');
INSERT INTO `device_sensor_record` VALUES (86183, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 207.2, 'lx', NULL, NULL, '2026-11-02 11:37:24.058', '2026-11-02 11:37:24.058');
INSERT INTO `device_sensor_record` VALUES (86184, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.1, '℃', NULL, NULL, '2026-11-02 11:37:24.058', '2026-11-02 11:37:24.058');
INSERT INTO `device_sensor_record` VALUES (86185, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23, '℃', NULL, NULL, '2026-11-02 11:37:24.058', '2026-11-02 11:37:24.058');
INSERT INTO `device_sensor_record` VALUES (86186, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.5, '℃', NULL, NULL, '2026-11-02 11:37:24.058', '2026-11-02 11:37:24.058');
INSERT INTO `device_sensor_record` VALUES (86187, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.33, 'V', NULL, NULL, '2026-11-02 11:37:24.058', '2026-11-02 11:37:24.058');
INSERT INTO `device_sensor_record` VALUES (86188, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 123105, 'bytes', NULL, NULL, '2026-11-02 11:37:24.058', '2026-11-02 11:37:24.058');
INSERT INTO `device_sensor_record` VALUES (86189, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.5, '℃', NULL, NULL, '2026-11-02 11:37:34.063', '2026-11-02 11:37:34.063');
INSERT INTO `device_sensor_record` VALUES (86190, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.9, '%', NULL, NULL, '2026-11-02 11:37:34.063', '2026-11-02 11:37:34.063');
INSERT INTO `device_sensor_record` VALUES (86191, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 42.8, 'μg/m³', NULL, NULL, '2026-11-02 11:37:34.063', '2026-11-02 11:37:34.063');
INSERT INTO `device_sensor_record` VALUES (86192, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 484.9, 'ppm', NULL, NULL, '2026-11-02 11:37:34.063', '2026-11-02 11:37:34.063');
INSERT INTO `device_sensor_record` VALUES (86193, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 113.8, 'lx', NULL, NULL, '2026-11-02 11:37:34.063', '2026-11-02 11:37:34.063');
INSERT INTO `device_sensor_record` VALUES (86194, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.5, '℃', NULL, NULL, '2026-11-02 11:37:34.063', '2026-11-02 11:37:34.063');
INSERT INTO `device_sensor_record` VALUES (86195, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.6, '℃', NULL, NULL, '2026-11-02 11:37:34.063', '2026-11-02 11:37:34.063');
INSERT INTO `device_sensor_record` VALUES (86196, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.4, '℃', NULL, NULL, '2026-11-02 11:37:34.063', '2026-11-02 11:37:34.063');
INSERT INTO `device_sensor_record` VALUES (86197, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.2, 'V', NULL, NULL, '2026-11-02 11:37:34.063', '2026-11-02 11:37:34.063');
INSERT INTO `device_sensor_record` VALUES (86198, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 145715, 'bytes', NULL, NULL, '2026-11-02 11:37:34.063', '2026-11-02 11:37:34.063');
INSERT INTO `device_sensor_record` VALUES (86199, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.2, '℃', NULL, NULL, '2026-11-02 11:37:44.077', '2026-11-02 11:37:44.077');
INSERT INTO `device_sensor_record` VALUES (86200, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.5, '%', NULL, NULL, '2026-11-02 11:37:44.077', '2026-11-02 11:37:44.077');
INSERT INTO `device_sensor_record` VALUES (86201, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 43.7, 'μg/m³', NULL, NULL, '2026-11-02 11:37:44.077', '2026-11-02 11:37:44.077');
INSERT INTO `device_sensor_record` VALUES (86202, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 474.9, 'ppm', NULL, NULL, '2026-11-02 11:37:44.077', '2026-11-02 11:37:44.077');
INSERT INTO `device_sensor_record` VALUES (86203, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 259.1, 'lx', NULL, NULL, '2026-11-02 11:37:44.077', '2026-11-02 11:37:44.077');
INSERT INTO `device_sensor_record` VALUES (86204, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.3, '℃', NULL, NULL, '2026-11-02 11:37:44.077', '2026-11-02 11:37:44.077');
INSERT INTO `device_sensor_record` VALUES (86205, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:37:44.077', '2026-11-02 11:37:44.077');
INSERT INTO `device_sensor_record` VALUES (86206, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48.6, '℃', NULL, NULL, '2026-11-02 11:37:44.077', '2026-11-02 11:37:44.077');
INSERT INTO `device_sensor_record` VALUES (86207, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.38, 'V', NULL, NULL, '2026-11-02 11:37:44.077', '2026-11-02 11:37:44.077');
INSERT INTO `device_sensor_record` VALUES (86208, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 172056, 'bytes', NULL, NULL, '2026-11-02 11:37:44.077', '2026-11-02 11:37:44.077');
INSERT INTO `device_sensor_record` VALUES (86209, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:37:54.087', '2026-11-02 11:37:54.087');
INSERT INTO `device_sensor_record` VALUES (86210, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.8, '%', NULL, NULL, '2026-11-02 11:37:54.087', '2026-11-02 11:37:54.087');
INSERT INTO `device_sensor_record` VALUES (86211, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:37:54.087', '2026-11-02 11:37:54.087');
INSERT INTO `device_sensor_record` VALUES (86212, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 468.6, 'ppm', NULL, NULL, '2026-11-02 11:37:54.087', '2026-11-02 11:37:54.087');
INSERT INTO `device_sensor_record` VALUES (86213, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 383.5, 'lx', NULL, NULL, '2026-11-02 11:37:54.087', '2026-11-02 11:37:54.087');
INSERT INTO `device_sensor_record` VALUES (86214, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.9, '℃', NULL, NULL, '2026-11-02 11:37:54.087', '2026-11-02 11:37:54.087');
INSERT INTO `device_sensor_record` VALUES (86215, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.3, '℃', NULL, NULL, '2026-11-02 11:37:54.087', '2026-11-02 11:37:54.087');
INSERT INTO `device_sensor_record` VALUES (86216, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.4, '℃', NULL, NULL, '2026-11-02 11:37:54.087', '2026-11-02 11:37:54.087');
INSERT INTO `device_sensor_record` VALUES (86217, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-02 11:37:54.087', '2026-11-02 11:37:54.087');
INSERT INTO `device_sensor_record` VALUES (86218, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 173135, 'bytes', NULL, NULL, '2026-11-02 11:37:54.087', '2026-11-02 11:37:54.087');
INSERT INTO `device_sensor_record` VALUES (86219, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.1, '℃', NULL, NULL, '2026-11-02 11:38:04.093', '2026-11-02 11:38:04.093');
INSERT INTO `device_sensor_record` VALUES (86220, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.9, '%', NULL, NULL, '2026-11-02 11:38:04.093', '2026-11-02 11:38:04.093');
INSERT INTO `device_sensor_record` VALUES (86221, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 29.9, 'μg/m³', NULL, NULL, '2026-11-02 11:38:04.093', '2026-11-02 11:38:04.093');
INSERT INTO `device_sensor_record` VALUES (86222, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 521.9, 'ppm', NULL, NULL, '2026-11-02 11:38:04.093', '2026-11-02 11:38:04.093');
INSERT INTO `device_sensor_record` VALUES (86223, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 442.7, 'lx', NULL, NULL, '2026-11-02 11:38:04.093', '2026-11-02 11:38:04.093');
INSERT INTO `device_sensor_record` VALUES (86224, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.8, '℃', NULL, NULL, '2026-11-02 11:38:04.093', '2026-11-02 11:38:04.093');
INSERT INTO `device_sensor_record` VALUES (86225, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23, '℃', NULL, NULL, '2026-11-02 11:38:04.093', '2026-11-02 11:38:04.093');
INSERT INTO `device_sensor_record` VALUES (86226, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 48, '℃', NULL, NULL, '2026-11-02 11:38:04.093', '2026-11-02 11:38:04.093');
INSERT INTO `device_sensor_record` VALUES (86227, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.36, 'V', NULL, NULL, '2026-11-02 11:38:04.093', '2026-11-02 11:38:04.093');
INSERT INTO `device_sensor_record` VALUES (86228, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 168506, 'bytes', NULL, NULL, '2026-11-02 11:38:04.093', '2026-11-02 11:38:04.093');
INSERT INTO `device_sensor_record` VALUES (86229, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.8, '℃', NULL, NULL, '2026-11-02 11:38:14.109', '2026-11-02 11:38:14.109');
INSERT INTO `device_sensor_record` VALUES (86230, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 65.4, '%', NULL, NULL, '2026-11-02 11:38:14.109', '2026-11-02 11:38:14.109');
INSERT INTO `device_sensor_record` VALUES (86231, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 42.3, 'μg/m³', NULL, NULL, '2026-11-02 11:38:14.109', '2026-11-02 11:38:14.109');
INSERT INTO `device_sensor_record` VALUES (86232, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 497.6, 'ppm', NULL, NULL, '2026-11-02 11:38:14.109', '2026-11-02 11:38:14.109');
INSERT INTO `device_sensor_record` VALUES (86233, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 368.4, 'lx', NULL, NULL, '2026-11-02 11:38:14.109', '2026-11-02 11:38:14.109');
INSERT INTO `device_sensor_record` VALUES (86234, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-02 11:38:14.109', '2026-11-02 11:38:14.109');
INSERT INTO `device_sensor_record` VALUES (86235, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:38:14.109', '2026-11-02 11:38:14.109');
INSERT INTO `device_sensor_record` VALUES (86236, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.1, '℃', NULL, NULL, '2026-11-02 11:38:14.109', '2026-11-02 11:38:14.109');
INSERT INTO `device_sensor_record` VALUES (86237, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-02 11:38:14.109', '2026-11-02 11:38:14.109');
INSERT INTO `device_sensor_record` VALUES (86238, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 174701, 'bytes', NULL, NULL, '2026-11-02 11:38:14.109', '2026-11-02 11:38:14.109');
INSERT INTO `device_sensor_record` VALUES (86239, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.4, '℃', NULL, NULL, '2026-11-02 11:38:24.115', '2026-11-02 11:38:24.115');
INSERT INTO `device_sensor_record` VALUES (86240, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 58.1, '%', NULL, NULL, '2026-11-02 11:38:24.115', '2026-11-02 11:38:24.115');
INSERT INTO `device_sensor_record` VALUES (86241, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 44.3, 'μg/m³', NULL, NULL, '2026-11-02 11:38:24.115', '2026-11-02 11:38:24.115');
INSERT INTO `device_sensor_record` VALUES (86242, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 450.2, 'ppm', NULL, NULL, '2026-11-02 11:38:24.115', '2026-11-02 11:38:24.115');
INSERT INTO `device_sensor_record` VALUES (86243, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 263.3, 'lx', NULL, NULL, '2026-11-02 11:38:24.115', '2026-11-02 11:38:24.115');
INSERT INTO `device_sensor_record` VALUES (86244, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.7, '℃', NULL, NULL, '2026-11-02 11:38:24.115', '2026-11-02 11:38:24.115');
INSERT INTO `device_sensor_record` VALUES (86245, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-02 11:38:24.115', '2026-11-02 11:38:24.115');
INSERT INTO `device_sensor_record` VALUES (86246, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.2, '℃', NULL, NULL, '2026-11-02 11:38:24.115', '2026-11-02 11:38:24.115');
INSERT INTO `device_sensor_record` VALUES (86247, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.35, 'V', NULL, NULL, '2026-11-02 11:38:24.115', '2026-11-02 11:38:24.115');
INSERT INTO `device_sensor_record` VALUES (86248, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 124328, 'bytes', NULL, NULL, '2026-11-02 11:38:24.115', '2026-11-02 11:38:24.115');
INSERT INTO `device_sensor_record` VALUES (86249, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-02 11:38:34.123', '2026-11-02 11:38:34.123');
INSERT INTO `device_sensor_record` VALUES (86250, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.5, '%', NULL, NULL, '2026-11-02 11:38:34.123', '2026-11-02 11:38:34.123');
INSERT INTO `device_sensor_record` VALUES (86251, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 32.5, 'μg/m³', NULL, NULL, '2026-11-02 11:38:34.123', '2026-11-02 11:38:34.123');
INSERT INTO `device_sensor_record` VALUES (86252, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 540.6, 'ppm', NULL, NULL, '2026-11-02 11:38:34.123', '2026-11-02 11:38:34.123');
INSERT INTO `device_sensor_record` VALUES (86253, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 523.3, 'lx', NULL, NULL, '2026-11-02 11:38:34.123', '2026-11-02 11:38:34.123');
INSERT INTO `device_sensor_record` VALUES (86254, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.6, '℃', NULL, NULL, '2026-11-02 11:38:34.123', '2026-11-02 11:38:34.123');
INSERT INTO `device_sensor_record` VALUES (86255, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:38:34.123', '2026-11-02 11:38:34.123');
INSERT INTO `device_sensor_record` VALUES (86256, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 46.6, '℃', NULL, NULL, '2026-11-02 11:38:34.123', '2026-11-02 11:38:34.123');
INSERT INTO `device_sensor_record` VALUES (86257, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.25, 'V', NULL, NULL, '2026-11-02 11:38:34.123', '2026-11-02 11:38:34.123');
INSERT INTO `device_sensor_record` VALUES (86258, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 135221, 'bytes', NULL, NULL, '2026-11-02 11:38:34.123', '2026-11-02 11:38:34.123');
INSERT INTO `device_sensor_record` VALUES (86259, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:38:44.139', '2026-11-02 11:38:44.139');
INSERT INTO `device_sensor_record` VALUES (86260, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 61.5, '%', NULL, NULL, '2026-11-02 11:38:44.139', '2026-11-02 11:38:44.139');
INSERT INTO `device_sensor_record` VALUES (86261, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:38:44.139', '2026-11-02 11:38:44.139');
INSERT INTO `device_sensor_record` VALUES (86262, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 418.7, 'ppm', NULL, NULL, '2026-11-02 11:38:44.139', '2026-11-02 11:38:44.139');
INSERT INTO `device_sensor_record` VALUES (86263, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 444.2, 'lx', NULL, NULL, '2026-11-02 11:38:44.139', '2026-11-02 11:38:44.139');
INSERT INTO `device_sensor_record` VALUES (86264, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.7, '℃', NULL, NULL, '2026-11-02 11:38:44.139', '2026-11-02 11:38:44.139');
INSERT INTO `device_sensor_record` VALUES (86265, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:38:44.139', '2026-11-02 11:38:44.139');
INSERT INTO `device_sensor_record` VALUES (86266, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.9, '℃', NULL, NULL, '2026-11-02 11:38:44.139', '2026-11-02 11:38:44.139');
INSERT INTO `device_sensor_record` VALUES (86267, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.29, 'V', NULL, NULL, '2026-11-02 11:38:44.139', '2026-11-02 11:38:44.139');
INSERT INTO `device_sensor_record` VALUES (86268, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 129531, 'bytes', NULL, NULL, '2026-11-02 11:38:44.139', '2026-11-02 11:38:44.139');
INSERT INTO `device_sensor_record` VALUES (86269, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25.3, '℃', NULL, NULL, '2026-11-02 11:38:54.153', '2026-11-02 11:38:54.153');
INSERT INTO `device_sensor_record` VALUES (86270, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 66.6, '%', NULL, NULL, '2026-11-02 11:38:54.153', '2026-11-02 11:38:54.153');
INSERT INTO `device_sensor_record` VALUES (86271, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 49.7, 'μg/m³', NULL, NULL, '2026-11-02 11:38:54.153', '2026-11-02 11:38:54.153');
INSERT INTO `device_sensor_record` VALUES (86272, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 470.1, 'ppm', NULL, NULL, '2026-11-02 11:38:54.153', '2026-11-02 11:38:54.153');
INSERT INTO `device_sensor_record` VALUES (86273, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 550.9, 'lx', NULL, NULL, '2026-11-02 11:38:54.153', '2026-11-02 11:38:54.153');
INSERT INTO `device_sensor_record` VALUES (86274, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.8, '℃', NULL, NULL, '2026-11-02 11:38:54.153', '2026-11-02 11:38:54.153');
INSERT INTO `device_sensor_record` VALUES (86275, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 24.9, '℃', NULL, NULL, '2026-11-02 11:38:54.153', '2026-11-02 11:38:54.153');
INSERT INTO `device_sensor_record` VALUES (86276, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.7, '℃', NULL, NULL, '2026-11-02 11:38:54.153', '2026-11-02 11:38:54.153');
INSERT INTO `device_sensor_record` VALUES (86277, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.24, 'V', NULL, NULL, '2026-11-02 11:38:54.153', '2026-11-02 11:38:54.153');
INSERT INTO `device_sensor_record` VALUES (86278, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 154419, 'bytes', NULL, NULL, '2026-11-02 11:38:54.153', '2026-11-02 11:38:54.153');
INSERT INTO `device_sensor_record` VALUES (86279, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.3, '℃', NULL, NULL, '2026-11-02 11:39:04.164', '2026-11-02 11:39:04.164');
INSERT INTO `device_sensor_record` VALUES (86280, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 53.9, '%', NULL, NULL, '2026-11-02 11:39:04.164', '2026-11-02 11:39:04.164');
INSERT INTO `device_sensor_record` VALUES (86281, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 21.2, 'μg/m³', NULL, NULL, '2026-11-02 11:39:04.164', '2026-11-02 11:39:04.164');
INSERT INTO `device_sensor_record` VALUES (86282, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 446, 'ppm', NULL, NULL, '2026-11-02 11:39:04.164', '2026-11-02 11:39:04.164');
INSERT INTO `device_sensor_record` VALUES (86283, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 506.7, 'lx', NULL, NULL, '2026-11-02 11:39:04.164', '2026-11-02 11:39:04.164');
INSERT INTO `device_sensor_record` VALUES (86284, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.9, '℃', NULL, NULL, '2026-11-02 11:39:04.164', '2026-11-02 11:39:04.164');
INSERT INTO `device_sensor_record` VALUES (86285, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.5, '℃', NULL, NULL, '2026-11-02 11:39:04.164', '2026-11-02 11:39:04.164');
INSERT INTO `device_sensor_record` VALUES (86286, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 52.6, '℃', NULL, NULL, '2026-11-02 11:39:04.164', '2026-11-02 11:39:04.164');
INSERT INTO `device_sensor_record` VALUES (86287, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.37, 'V', NULL, NULL, '2026-11-02 11:39:04.164', '2026-11-02 11:39:04.164');
INSERT INTO `device_sensor_record` VALUES (86288, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 129688, 'bytes', NULL, NULL, '2026-11-02 11:39:04.164', '2026-11-02 11:39:04.164');
INSERT INTO `device_sensor_record` VALUES (86289, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.6, '℃', NULL, NULL, '2026-11-02 11:39:14.172', '2026-11-02 11:39:14.172');
INSERT INTO `device_sensor_record` VALUES (86290, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 59.7, '%', NULL, NULL, '2026-11-02 11:39:14.172', '2026-11-02 11:39:14.172');
INSERT INTO `device_sensor_record` VALUES (86291, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 24.4, 'μg/m³', NULL, NULL, '2026-11-02 11:39:14.172', '2026-11-02 11:39:14.172');
INSERT INTO `device_sensor_record` VALUES (86292, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 446.8, 'ppm', NULL, NULL, '2026-11-02 11:39:14.172', '2026-11-02 11:39:14.172');
INSERT INTO `device_sensor_record` VALUES (86293, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 589.2, 'lx', NULL, NULL, '2026-11-02 11:39:14.172', '2026-11-02 11:39:14.172');
INSERT INTO `device_sensor_record` VALUES (86294, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.2, '℃', NULL, NULL, '2026-11-02 11:39:14.172', '2026-11-02 11:39:14.172');
INSERT INTO `device_sensor_record` VALUES (86295, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.7, '℃', NULL, NULL, '2026-11-02 11:39:14.172', '2026-11-02 11:39:14.172');
INSERT INTO `device_sensor_record` VALUES (86296, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51, '℃', NULL, NULL, '2026-11-02 11:39:14.172', '2026-11-02 11:39:14.172');
INSERT INTO `device_sensor_record` VALUES (86297, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-02 11:39:14.172', '2026-11-02 11:39:14.172');
INSERT INTO `device_sensor_record` VALUES (86298, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 169491, 'bytes', NULL, NULL, '2026-11-02 11:39:14.172', '2026-11-02 11:39:14.172');
INSERT INTO `device_sensor_record` VALUES (86299, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.6, '℃', NULL, NULL, '2026-11-02 11:39:24.187', '2026-11-02 11:39:24.187');
INSERT INTO `device_sensor_record` VALUES (86300, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.6, '%', NULL, NULL, '2026-11-02 11:39:24.187', '2026-11-02 11:39:24.187');
INSERT INTO `device_sensor_record` VALUES (86301, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 43.9, 'μg/m³', NULL, NULL, '2026-11-02 11:39:24.187', '2026-11-02 11:39:24.187');
INSERT INTO `device_sensor_record` VALUES (86302, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 475.7, 'ppm', NULL, NULL, '2026-11-02 11:39:24.187', '2026-11-02 11:39:24.187');
INSERT INTO `device_sensor_record` VALUES (86303, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 506.3, 'lx', NULL, NULL, '2026-11-02 11:39:24.187', '2026-11-02 11:39:24.187');
INSERT INTO `device_sensor_record` VALUES (86304, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-02 11:39:24.187', '2026-11-02 11:39:24.187');
INSERT INTO `device_sensor_record` VALUES (86305, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.3, '℃', NULL, NULL, '2026-11-02 11:39:24.187', '2026-11-02 11:39:24.187');
INSERT INTO `device_sensor_record` VALUES (86306, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 53.6, '℃', NULL, NULL, '2026-11-02 11:39:24.187', '2026-11-02 11:39:24.187');
INSERT INTO `device_sensor_record` VALUES (86307, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.27, 'V', NULL, NULL, '2026-11-02 11:39:24.187', '2026-11-02 11:39:24.187');
INSERT INTO `device_sensor_record` VALUES (86308, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 161137, 'bytes', NULL, NULL, '2026-11-02 11:39:24.187', '2026-11-02 11:39:24.187');
INSERT INTO `device_sensor_record` VALUES (86309, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 35.5, '℃', NULL, NULL, '2026-11-02 11:39:34.198', '2026-11-02 11:39:34.198');
INSERT INTO `device_sensor_record` VALUES (86310, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 55, '%', NULL, NULL, '2026-11-02 11:39:34.198', '2026-11-02 11:39:34.198');
INSERT INTO `device_sensor_record` VALUES (86311, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 150, 'μg/m³', NULL, NULL, '2026-11-02 11:39:34.198', '2026-11-02 11:39:34.198');
INSERT INTO `device_sensor_record` VALUES (86312, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 490.2, 'ppm', NULL, NULL, '2026-11-02 11:39:34.198', '2026-11-02 11:39:34.198');
INSERT INTO `device_sensor_record` VALUES (86313, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 490.1, 'lx', NULL, NULL, '2026-11-02 11:39:34.198', '2026-11-02 11:39:34.198');
INSERT INTO `device_sensor_record` VALUES (86314, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.5, '℃', NULL, NULL, '2026-11-02 11:39:34.198', '2026-11-02 11:39:34.198');
INSERT INTO `device_sensor_record` VALUES (86315, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.3, '℃', NULL, NULL, '2026-11-02 11:39:34.198', '2026-11-02 11:39:34.198');
INSERT INTO `device_sensor_record` VALUES (86316, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 54.1, '℃', NULL, NULL, '2026-11-02 11:39:34.198', '2026-11-02 11:39:34.198');
INSERT INTO `device_sensor_record` VALUES (86317, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.29, 'V', NULL, NULL, '2026-11-02 11:39:34.198', '2026-11-02 11:39:34.198');
INSERT INTO `device_sensor_record` VALUES (86318, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 139793, 'bytes', NULL, NULL, '2026-11-02 11:39:34.198', '2026-11-02 11:39:34.198');
INSERT INTO `device_sensor_record` VALUES (86319, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 24.5, '℃', NULL, NULL, '2026-11-02 11:39:44.214', '2026-11-02 11:39:44.214');
INSERT INTO `device_sensor_record` VALUES (86320, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 54.8, '%', NULL, NULL, '2026-11-02 11:39:44.214', '2026-11-02 11:39:44.214');
INSERT INTO `device_sensor_record` VALUES (86321, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.8, 'μg/m³', NULL, NULL, '2026-11-02 11:39:44.214', '2026-11-02 11:39:44.214');
INSERT INTO `device_sensor_record` VALUES (86322, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 470.8, 'ppm', NULL, NULL, '2026-11-02 11:39:44.214', '2026-11-02 11:39:44.214');
INSERT INTO `device_sensor_record` VALUES (86323, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 711.4, 'lx', NULL, NULL, '2026-11-02 11:39:44.214', '2026-11-02 11:39:44.214');
INSERT INTO `device_sensor_record` VALUES (86324, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 20.3, '℃', NULL, NULL, '2026-11-02 11:39:44.214', '2026-11-02 11:39:44.214');
INSERT INTO `device_sensor_record` VALUES (86325, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.8, '℃', NULL, NULL, '2026-11-02 11:39:44.214', '2026-11-02 11:39:44.214');
INSERT INTO `device_sensor_record` VALUES (86326, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 49.2, '℃', NULL, NULL, '2026-11-02 11:39:44.214', '2026-11-02 11:39:44.214');
INSERT INTO `device_sensor_record` VALUES (86327, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.21, 'V', NULL, NULL, '2026-11-02 11:39:44.214', '2026-11-02 11:39:44.214');
INSERT INTO `device_sensor_record` VALUES (86328, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 164546, 'bytes', NULL, NULL, '2026-11-02 11:39:44.214', '2026-11-02 11:39:44.214');
INSERT INTO `device_sensor_record` VALUES (86329, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 26.9, '℃', NULL, NULL, '2026-11-02 11:39:54.217', '2026-11-02 11:39:54.217');
INSERT INTO `device_sensor_record` VALUES (86330, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 52.4, '%', NULL, NULL, '2026-11-02 11:39:54.217', '2026-11-02 11:39:54.217');
INSERT INTO `device_sensor_record` VALUES (86331, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 23.1, 'μg/m³', NULL, NULL, '2026-11-02 11:39:54.217', '2026-11-02 11:39:54.217');
INSERT INTO `device_sensor_record` VALUES (86332, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 430.7, 'ppm', NULL, NULL, '2026-11-02 11:39:54.217', '2026-11-02 11:39:54.217');
INSERT INTO `device_sensor_record` VALUES (86333, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 112.8, 'lx', NULL, NULL, '2026-11-02 11:39:54.217', '2026-11-02 11:39:54.217');
INSERT INTO `device_sensor_record` VALUES (86334, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21.4, '℃', NULL, NULL, '2026-11-02 11:39:54.217', '2026-11-02 11:39:54.217');
INSERT INTO `device_sensor_record` VALUES (86335, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 25.2, '℃', NULL, NULL, '2026-11-02 11:39:54.217', '2026-11-02 11:39:54.217');
INSERT INTO `device_sensor_record` VALUES (86336, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.9, '℃', NULL, NULL, '2026-11-02 11:39:54.217', '2026-11-02 11:39:54.217');
INSERT INTO `device_sensor_record` VALUES (86337, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.28, 'V', NULL, NULL, '2026-11-02 11:39:54.217', '2026-11-02 11:39:54.217');
INSERT INTO `device_sensor_record` VALUES (86338, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 137857, 'bytes', NULL, NULL, '2026-11-02 11:39:54.217', '2026-11-02 11:39:54.217');
INSERT INTO `device_sensor_record` VALUES (86339, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 25, '℃', NULL, NULL, '2026-11-02 11:40:04.235', '2026-11-02 11:40:04.235');
INSERT INTO `device_sensor_record` VALUES (86340, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 63, '%', NULL, NULL, '2026-11-02 11:40:04.235', '2026-11-02 11:40:04.235');
INSERT INTO `device_sensor_record` VALUES (86341, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 44, 'μg/m³', NULL, NULL, '2026-11-02 11:40:04.235', '2026-11-02 11:40:04.235');
INSERT INTO `device_sensor_record` VALUES (86342, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 571.4, 'ppm', NULL, NULL, '2026-11-02 11:40:04.235', '2026-11-02 11:40:04.235');
INSERT INTO `device_sensor_record` VALUES (86343, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 725.5, 'lx', NULL, NULL, '2026-11-02 11:40:04.235', '2026-11-02 11:40:04.235');
INSERT INTO `device_sensor_record` VALUES (86344, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 21, '℃', NULL, NULL, '2026-11-02 11:40:04.235', '2026-11-02 11:40:04.235');
INSERT INTO `device_sensor_record` VALUES (86345, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.6, '℃', NULL, NULL, '2026-11-02 11:40:04.235', '2026-11-02 11:40:04.235');
INSERT INTO `device_sensor_record` VALUES (86346, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 47.4, '℃', NULL, NULL, '2026-11-02 11:40:04.235', '2026-11-02 11:40:04.235');
INSERT INTO `device_sensor_record` VALUES (86347, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.26, 'V', NULL, NULL, '2026-11-02 11:40:04.235', '2026-11-02 11:40:04.235');
INSERT INTO `device_sensor_record` VALUES (86348, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 153946, 'bytes', NULL, NULL, '2026-11-02 11:40:04.235', '2026-11-02 11:40:04.235');
INSERT INTO `device_sensor_record` VALUES (86349, 'B4BFE90CDBA1', 'slave', 1, NULL, NULL, 'temp', 'temperature', 27.7, '℃', NULL, NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:40:14.245');
INSERT INTO `device_sensor_record` VALUES (86350, 'B4BFE90CDBA1', 'slave', 2, NULL, NULL, 'humi', 'humidity', 67.3, '%', NULL, NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:40:14.245');
INSERT INTO `device_sensor_record` VALUES (86351, 'B4BFE90CDBA1', 'slave', 3, NULL, NULL, 'pm25', 'pm25', 40, 'μg/m³', NULL, NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:40:14.245');
INSERT INTO `device_sensor_record` VALUES (86352, 'B4BFE90CDBA1', 'slave', 4, NULL, NULL, 'co2', 'co2', 424.7, 'ppm', NULL, NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:40:14.245');
INSERT INTO `device_sensor_record` VALUES (86353, 'B4BFE90CDBA1', 'slave', 5, NULL, NULL, 'lux', 'illuminance', 792, 'lx', NULL, NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:40:14.245');
INSERT INTO `device_sensor_record` VALUES (86354, 'B4BFE90CDBA1', 'slave', 6, NULL, 1, 'temp_ch1', 'temperature', 22.6, '℃', NULL, NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:40:14.245');
INSERT INTO `device_sensor_record` VALUES (86355, 'B4BFE90CDBA1', 'slave', 6, NULL, 2, 'temp_ch2', 'temperature', 23.6, '℃', NULL, NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:40:14.245');
INSERT INTO `device_sensor_record` VALUES (86356, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'chip_temp', 'temperature', 51.9, '℃', NULL, NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:40:14.245');
INSERT INTO `device_sensor_record` VALUES (86357, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'system_voltage', 'voltage', 3.3, 'V', NULL, NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:40:14.245');
INSERT INTO `device_sensor_record` VALUES (86358, 'B4BFE90CDBA1', 'host', NULL, NULL, NULL, 'free_heap', 'memory', 166252, 'bytes', NULL, NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:40:14.245');

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
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '传感器阈值配置表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备从机数据表(在线即存在，离线即删除)' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_slave_data
-- ----------------------------
INSERT INTO `device_slave_data` VALUES (32, 'B4BFE90CDBA1', 1, 'temperature', NULL, '2026-11-02 11:07:12.386', 27.7, '℃', NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:07:12.390');
INSERT INTO `device_slave_data` VALUES (33, 'B4BFE90CDBA1', 2, 'humidity', NULL, '2026-11-02 11:07:12.386', 67.3, '%', NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:07:12.390');
INSERT INTO `device_slave_data` VALUES (34, 'B4BFE90CDBA1', 3, 'pm25', NULL, '2026-11-02 11:07:12.386', 40, 'μg/m³', NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:07:12.390');
INSERT INTO `device_slave_data` VALUES (35, 'B4BFE90CDBA1', 4, 'co2', NULL, '2026-11-02 11:07:12.386', 424.7, 'ppm', NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:07:12.391');
INSERT INTO `device_slave_data` VALUES (36, 'B4BFE90CDBA1', 5, 'illuminance', NULL, '2026-11-02 11:07:12.386', 792, 'lx', NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:07:12.391');
INSERT INTO `device_slave_data` VALUES (37, 'B4BFE90CDBA1', 6, 'temperature', 1, '2026-11-02 11:07:12.386', 23.6, '℃', NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:07:12.391');
INSERT INTO `device_slave_data` VALUES (38, 'B4BFE90CDBA1', 6, 'temperature', 2, '2026-11-02 11:07:12.386', 23.6, '℃', NULL, '2026-11-02 11:40:14.245', '2026-11-02 11:07:12.391');

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
) ENGINE = InnoDB AUTO_INCREMENT = 87 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备状态时序表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_state_record
-- ----------------------------
INSERT INTO `device_state_record` VALUES (70, 'B4BFE90CDBA1', 'led', 3, '{\"state\": 0}', '2026-11-02 11:07:54.930', '2026-11-02 11:07:54.972');
INSERT INTO `device_state_record` VALUES (71, 'B4BFE90CDBA1', 'led', 1, '{\"state\": 0}', '2026-11-02 11:08:00.840', '2026-11-02 11:08:00.851');
INSERT INTO `device_state_record` VALUES (72, 'B4BFE90CDBA1', 'led', 1, '{\"state\": 1}', '2026-11-02 11:08:14.326', '2026-11-02 11:08:14.334');
INSERT INTO `device_state_record` VALUES (73, 'B4BFE90CDBA1', 'led', 2, '{\"state\": 1}', '2026-11-02 11:08:22.836', '2026-11-02 11:08:22.849');
INSERT INTO `device_state_record` VALUES (74, 'B4BFE90CDBA1', 'led', 2, '{\"state\": 1}', '2026-11-02 11:11:59.032', '2026-11-02 11:11:59.051');
INSERT INTO `device_state_record` VALUES (75, 'B4BFE90CDBA1', 'led', 3, '{\"state\": 1}', '2026-11-02 11:12:15.241', '2026-11-02 11:12:15.258');
INSERT INTO `device_state_record` VALUES (76, 'B4BFE90CDBA1', 'led', 3, '{\"state\": 1}', '2026-11-02 11:12:22.161', '2026-11-02 11:12:22.183');
INSERT INTO `device_state_record` VALUES (77, 'B4BFE90CDBA1', 'led', 3, '{\"state\": 1}', '2026-11-02 11:12:22.988', '2026-11-02 11:12:23.003');
INSERT INTO `device_state_record` VALUES (78, 'B4BFE90CDBA1', 'led', 3, '{\"state\": 0}', '2026-11-02 11:12:35.704', '2026-11-02 11:12:35.719');
INSERT INTO `device_state_record` VALUES (79, 'B4BFE90CDBA1', 'led', 3, '{\"state\": 0}', '2026-11-02 11:14:42.779', '2026-11-02 11:14:42.819');
INSERT INTO `device_state_record` VALUES (80, 'B4BFE90CDBA1', 'led', 3, '{\"state\": 1}', '2026-11-02 11:15:11.187', '2026-11-02 11:15:11.199');
INSERT INTO `device_state_record` VALUES (81, 'B4BFE90CDBA1', 'led', 3, '{\"state\": 0}', '2026-11-02 11:15:26.625', '2026-11-02 11:15:26.643');
INSERT INTO `device_state_record` VALUES (82, 'B4BFE90CDBA1', 'led', 3, '{\"state\": 0}', '2026-11-02 11:15:27.695', '2026-11-02 11:15:27.708');
INSERT INTO `device_state_record` VALUES (83, 'B4BFE90CDBA1', 'mos', 3, '{\"state\": 1}', '2026-11-02 11:18:08.311', '2026-11-02 11:18:08.327');
INSERT INTO `device_state_record` VALUES (84, 'B4BFE90CDBA1', 'mos', 3, '{\"state\": 1}', '2026-11-02 11:31:46.434', '2026-11-02 11:31:46.450');
INSERT INTO `device_state_record` VALUES (85, 'B4BFE90CDBA1', 'mos', 3, '{\"state\": 0}', '2026-11-02 11:31:55.409', '2026-11-02 11:31:55.425');
INSERT INTO `device_state_record` VALUES (86, 'B4BFE90CDBA1', 'mos', 4, '{\"state\": 1}', '2026-11-02 11:32:12.338', '2026-11-02 11:32:12.356');

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
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备白名单（产线导入，允许注册的设备）' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `device_whitelist` VALUES (17, 'B4BFE90CDBA2', NULL, 1, '管理员后台录入自动生成', '2026-11-01 18:59:21.585', '2026-11-01 18:59:21.585');
INSERT INTO `device_whitelist` VALUES (19, 'B4BFE90CDBA1', NULL, 1, '管理员后台录入自动生成', '2026-11-02 11:02:18.068', '2026-11-02 11:02:18.068');

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
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'MQTT死信队列' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dead_letter
-- ----------------------------
INSERT INTO `sys_dead_letter` VALUES (5, 'device/B4BFE90CDBA1/state', '{\"device\": \"B4BFE90CDBA1\", \"type\": \"state\", \"data\": {\"target\": \"led\", \"channel\": 1, \"state\": 1}}', '状态上报缺少 target 或 state', 1, 1, 0, '2026-11-01 18:39:41.643', '2026-11-01 18:42:15.246');

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
) ENGINE = InnoDB AUTO_INCREMENT = 180 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录日志表' ROW_FORMAT = Dynamic;

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
INSERT INTO `sys_login_log` VALUES (65, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 14:11:14.862');
INSERT INTO `sys_login_log` VALUES (66, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 14:11:57.611');
INSERT INTO `sys_login_log` VALUES (67, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 15:31:58.229');
INSERT INTO `sys_login_log` VALUES (68, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 15:32:56.692');
INSERT INTO `sys_login_log` VALUES (69, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 15:34:26.340');
INSERT INTO `sys_login_log` VALUES (70, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 17:58:02.195');
INSERT INTO `sys_login_log` VALUES (71, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 17:59:15.976');
INSERT INTO `sys_login_log` VALUES (72, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 17:59:39.151');
INSERT INTO `sys_login_log` VALUES (73, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:00:24.161');
INSERT INTO `sys_login_log` VALUES (74, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:03:37.484');
INSERT INTO `sys_login_log` VALUES (75, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:07:31.766');
INSERT INTO `sys_login_log` VALUES (76, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:14:00.944');
INSERT INTO `sys_login_log` VALUES (77, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:15:00.171');
INSERT INTO `sys_login_log` VALUES (78, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:18:41.924');
INSERT INTO `sys_login_log` VALUES (79, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:19:14.437');
INSERT INTO `sys_login_log` VALUES (80, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:36:27.835');
INSERT INTO `sys_login_log` VALUES (81, 'mary', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:37:24.515');
INSERT INTO `sys_login_log` VALUES (82, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:40:02.740');
INSERT INTO `sys_login_log` VALUES (83, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:40:20.500');
INSERT INTO `sys_login_log` VALUES (84, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:40:43.591');
INSERT INTO `sys_login_log` VALUES (85, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:42:01.783');
INSERT INTO `sys_login_log` VALUES (86, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:44:51.909');
INSERT INTO `sys_login_log` VALUES (87, 'public', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:49:58.867');
INSERT INTO `sys_login_log` VALUES (88, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 18:50:15.661');
INSERT INTO `sys_login_log` VALUES (89, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 19:03:46.523');
INSERT INTO `sys_login_log` VALUES (90, 'test1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:03:51.571');
INSERT INTO `sys_login_log` VALUES (91, 'test1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:03:52.457');
INSERT INTO `sys_login_log` VALUES (92, 'test1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:03:53.176');
INSERT INTO `sys_login_log` VALUES (93, 'test1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:03:53.825');
INSERT INTO `sys_login_log` VALUES (94, 'test1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:03:54.450');
INSERT INTO `sys_login_log` VALUES (95, 'test1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:03:54.693');
INSERT INTO `sys_login_log` VALUES (96, 'test2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:03:59.169');
INSERT INTO `sys_login_log` VALUES (97, 'test2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:03:59.915');
INSERT INTO `sys_login_log` VALUES (98, 'test2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:00.590');
INSERT INTO `sys_login_log` VALUES (99, 'test2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:02.087');
INSERT INTO `sys_login_log` VALUES (100, 'test2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:02.772');
INSERT INTO `sys_login_log` VALUES (101, 'test2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:04:03.082');
INSERT INTO `sys_login_log` VALUES (102, 'test3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:08.757');
INSERT INTO `sys_login_log` VALUES (103, 'test3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:09.336');
INSERT INTO `sys_login_log` VALUES (104, 'test3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:09.997');
INSERT INTO `sys_login_log` VALUES (105, 'test3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:10.521');
INSERT INTO `sys_login_log` VALUES (106, 'test3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:11.109');
INSERT INTO `sys_login_log` VALUES (107, 'test3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:04:11.411');
INSERT INTO `sys_login_log` VALUES (108, 'test3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:04:12.065');
INSERT INTO `sys_login_log` VALUES (109, 'test4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:16.088');
INSERT INTO `sys_login_log` VALUES (110, 'test4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:16.689');
INSERT INTO `sys_login_log` VALUES (111, 'test4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:17.283');
INSERT INTO `sys_login_log` VALUES (112, 'test4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:17.821');
INSERT INTO `sys_login_log` VALUES (113, 'test4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:04:18.355');
INSERT INTO `sys_login_log` VALUES (114, 'test4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:04:18.603');
INSERT INTO `sys_login_log` VALUES (115, 'test5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:04:22.697');
INSERT INTO `sys_login_log` VALUES (116, 'test5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:04:23.209');
INSERT INTO `sys_login_log` VALUES (117, 'test5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:04:23.544');
INSERT INTO `sys_login_log` VALUES (118, 'test5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:04:23.698');
INSERT INTO `sys_login_log` VALUES (119, 'test5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:04:23.865');
INSERT INTO `sys_login_log` VALUES (120, 'test5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:04:24.018');
INSERT INTO `sys_login_log` VALUES (121, 'test5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:04:24.155');
INSERT INTO `sys_login_log` VALUES (122, 'test5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:04:24.290');
INSERT INTO `sys_login_log` VALUES (123, 'test5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:05:19.194');
INSERT INTO `sys_login_log` VALUES (124, 'test6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:05:25.256');
INSERT INTO `sys_login_log` VALUES (125, 'test6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:05:26.778');
INSERT INTO `sys_login_log` VALUES (126, 'test6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:29:28.120');
INSERT INTO `sys_login_log` VALUES (127, 'test6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:29:48.478');
INSERT INTO `sys_login_log` VALUES (128, 'test6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:30:02.583');
INSERT INTO `sys_login_log` VALUES (129, 'test6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:30:03.078');
INSERT INTO `sys_login_log` VALUES (130, 'test6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '用户名或密码错误', '2026-10-28 19:30:03.554');
INSERT INTO `sys_login_log` VALUES (131, 'test6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:30:03.768');
INSERT INTO `sys_login_log` VALUES (132, 'test6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:30:03.883');
INSERT INTO `sys_login_log` VALUES (133, 'test6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:30:04.037');
INSERT INTO `sys_login_log` VALUES (134, 'test6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 0, '账号已锁定', '2026-10-28 19:30:04.165');
INSERT INTO `sys_login_log` VALUES (135, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-28 19:30:40.510');
INSERT INTO `sys_login_log` VALUES (136, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-29 12:07:38.875');
INSERT INTO `sys_login_log` VALUES (137, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-10-30 17:22:47.279');
INSERT INTO `sys_login_log` VALUES (138, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 16:53:24.843');
INSERT INTO `sys_login_log` VALUES (139, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 16:53:52.687');
INSERT INTO `sys_login_log` VALUES (140, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 16:55:18.054');
INSERT INTO `sys_login_log` VALUES (141, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 16:58:20.976');
INSERT INTO `sys_login_log` VALUES (142, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:02:46.196');
INSERT INTO `sys_login_log` VALUES (143, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:07:03.027');
INSERT INTO `sys_login_log` VALUES (144, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:08:08.956');
INSERT INTO `sys_login_log` VALUES (145, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:10:40.255');
INSERT INTO `sys_login_log` VALUES (146, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:13:08.144');
INSERT INTO `sys_login_log` VALUES (147, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:19:33.288');
INSERT INTO `sys_login_log` VALUES (148, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:31:05.680');
INSERT INTO `sys_login_log` VALUES (149, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:32:42.886');
INSERT INTO `sys_login_log` VALUES (150, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:34:28.810');
INSERT INTO `sys_login_log` VALUES (151, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:35:08.576');
INSERT INTO `sys_login_log` VALUES (152, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:36:12.950');
INSERT INTO `sys_login_log` VALUES (153, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:38:05.965');
INSERT INTO `sys_login_log` VALUES (154, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:38:32.036');
INSERT INTO `sys_login_log` VALUES (155, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:39:25.494');
INSERT INTO `sys_login_log` VALUES (156, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:41:34.065');
INSERT INTO `sys_login_log` VALUES (157, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:42:57.086');
INSERT INTO `sys_login_log` VALUES (158, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:45:09.136');
INSERT INTO `sys_login_log` VALUES (159, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 17:48:22.827');
INSERT INTO `sys_login_log` VALUES (160, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 18:20:18.605');
INSERT INTO `sys_login_log` VALUES (161, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 18:34:42.370');
INSERT INTO `sys_login_log` VALUES (162, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 18:34:46.304');
INSERT INTO `sys_login_log` VALUES (163, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 18:40:36.758');
INSERT INTO `sys_login_log` VALUES (164, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 18:45:20.531');
INSERT INTO `sys_login_log` VALUES (165, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 18:45:29.819');
INSERT INTO `sys_login_log` VALUES (166, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 18:58:39.100');
INSERT INTO `sys_login_log` VALUES (167, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-01 18:58:48.975');
INSERT INTO `sys_login_log` VALUES (168, 'lucy', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-02 09:44:21.852');
INSERT INTO `sys_login_log` VALUES (169, 'test', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-02 09:45:06.408');
INSERT INTO `sys_login_log` VALUES (170, 'lucy', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-02 09:47:01.775');
INSERT INTO `sys_login_log` VALUES (171, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-02 09:49:17.103');
INSERT INTO `sys_login_log` VALUES (172, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-02 10:14:31.246');
INSERT INTO `sys_login_log` VALUES (173, 'bard', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-02 10:17:21.493');
INSERT INTO `sys_login_log` VALUES (174, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-02 10:55:14.832');
INSERT INTO `sys_login_log` VALUES (175, 'lucy', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-02 11:01:20.977');
INSERT INTO `sys_login_log` VALUES (176, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-02 11:02:02.687');
INSERT INTO `sys_login_log` VALUES (177, 'lucy', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-02 11:07:44.507');
INSERT INTO `sys_login_log` VALUES (178, 'lucy', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-02 11:11:45.325');
INSERT INTO `sys_login_log` VALUES (179, 'lucy', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 1, '登录成功', '2026-11-02 11:33:00.393');

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
) ENGINE = InnoDB AUTO_INCREMENT = 110 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户Refresh Token表' ROW_FORMAT = Dynamic;

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
INSERT INTO `sys_refresh_token` VALUES (39, 6, 'd38e28144bc9d6d3fc33cd5e48f22f4a0fab5f1562027625cad225437869c981', 'web', '2026-11-04 14:11:14.833', 0, '2026-10-28 14:11:14.834', '2026-10-28 14:11:14.834');
INSERT INTO `sys_refresh_token` VALUES (40, 7, 'eeb82ddf79f16a0dd3ed0b8814587e460e827b3635756aa24e43abbfe72b79c0', 'web', '2026-11-04 14:11:57.598', 0, '2026-10-28 14:11:57.598', '2026-10-28 14:11:57.598');
INSERT INTO `sys_refresh_token` VALUES (41, 7, '59851a0e8ef7fa967afc2e2145c172e2f46ac57260593bcbb5473015154970ea', 'web', '2026-11-04 15:31:58.215', 0, '2026-10-28 15:31:58.215', '2026-10-28 15:31:58.215');
INSERT INTO `sys_refresh_token` VALUES (42, 7, '43acea744eb349f43c208b6b74df22830fc1e69e665a6fa07852b6381dd845de', 'web', '2026-11-04 15:32:56.681', 0, '2026-10-28 15:32:56.681', '2026-10-28 15:32:56.681');
INSERT INTO `sys_refresh_token` VALUES (43, 6, '7ba133f75cd6961e5f5f39d1dd75cba33779fe2a47abaebcabca69c72af48aed', 'web', '2026-11-04 15:34:26.333', 0, '2026-10-28 15:34:26.333', '2026-10-28 15:34:26.333');
INSERT INTO `sys_refresh_token` VALUES (44, 6, '5a8d279c98dfe404f851fd3132cc2c779ad4eb759dc46b5b19a68b5d746f91b2', 'web', '2026-11-04 17:58:02.174', 0, '2026-10-28 17:58:02.175', '2026-10-28 17:58:02.175');
INSERT INTO `sys_refresh_token` VALUES (45, 6, 'b1178bbea0893d9f006fac47dd131876c06a04e4a252df9bb20befe73e86509f', 'web', '2026-11-04 17:59:15.961', 0, '2026-10-28 17:59:15.963', '2026-10-28 17:59:15.963');
INSERT INTO `sys_refresh_token` VALUES (46, 7, 'bb1de926fbfa55a708d25cc1e04d289c107ec4b8a55d0ee7d28e497da0937915', 'web', '2026-11-04 17:59:39.144', 0, '2026-10-28 17:59:39.144', '2026-10-28 17:59:39.144');
INSERT INTO `sys_refresh_token` VALUES (47, 5, 'c21190140db02283518a13f6f353069bfb21e6b1b492e45439696934c15ca9e9', 'web', '2026-11-04 18:00:24.154', 0, '2026-10-28 18:00:24.154', '2026-10-28 18:00:24.154');
INSERT INTO `sys_refresh_token` VALUES (48, 5, '45ffa3ac3f9459bc6498b7f465f9687b0f8dc7b517c114b3f8e0ec546e9c6c44', 'web', '2026-11-04 18:03:37.469', 0, '2026-10-28 18:03:37.470', '2026-10-28 18:03:37.470');
INSERT INTO `sys_refresh_token` VALUES (49, 5, '39f39a67edc3c1df6fe13dc69014b591d9b401500ea3b5dccf0017baa4366ae1', 'web', '2026-11-04 18:07:31.754', 0, '2026-10-28 18:07:31.755', '2026-10-28 18:07:31.755');
INSERT INTO `sys_refresh_token` VALUES (50, 5, '66de63941a42b2bf47ad9ee6ea2a408c97fdad042b67cf0177261d50ef184997', 'web', '2026-11-04 18:14:00.933', 0, '2026-10-28 18:14:00.933', '2026-10-28 18:14:00.933');
INSERT INTO `sys_refresh_token` VALUES (51, 5, 'a59810f9d9a628feb00d6cad8b85d173bc2b8c75002dc78ca3a6ab5684a91b82', 'web', '2026-11-04 18:15:00.157', 0, '2026-10-28 18:15:00.159', '2026-10-28 18:15:00.159');
INSERT INTO `sys_refresh_token` VALUES (52, 7, '9f3471cf2aef7f9e404e4d72bb36236e858049111955e37cbb85b09f930504c4', 'web', '2026-11-04 18:18:41.915', 0, '2026-10-28 18:18:41.915', '2026-10-28 18:18:41.915');
INSERT INTO `sys_refresh_token` VALUES (53, 6, 'dbe3dee9846880bb109686acbc1be3830efe7ac0bc7bfb013f266287b7164e81', 'web', '2026-11-04 18:19:14.432', 0, '2026-10-28 18:19:14.432', '2026-10-28 18:19:14.432');
INSERT INTO `sys_refresh_token` VALUES (54, 6, '619444ce66f73f3d92b67a36661fe5287b7583391bfe76bca50075509b3a8463', 'web', '2026-11-04 18:36:27.819', 0, '2026-10-28 18:36:27.822', '2026-10-28 18:36:27.822');
INSERT INTO `sys_refresh_token` VALUES (55, 8, '5f6bec70cc4054a34f98a2fdd9868edc4ffdfa7b833d86c1e5082fa2892c6218', 'web', '2026-11-04 18:37:24.507', 1, '2026-10-28 18:37:24.508', '2026-10-28 18:37:31.751');
INSERT INTO `sys_refresh_token` VALUES (56, 8, 'cd8ded9abca7e3845c1ad94057c2eb9d04633afdee09441dc8aae7add723b4a5', 'web', '2026-11-04 18:37:31.762', 0, '2026-10-28 18:37:31.762', '2026-10-28 18:37:31.762');
INSERT INTO `sys_refresh_token` VALUES (57, 5, '15b52e9f9ff128c3fb3b5c620286b4f192e41b9ba6476dd16dca87d6506ecda6', 'web', '2026-11-04 18:40:02.727', 0, '2026-10-28 18:40:02.728', '2026-10-28 18:40:02.728');
INSERT INTO `sys_refresh_token` VALUES (58, 5, 'fa3784047fe71a4e5fc1446d365375acc012e9046715d6d6bb54d5dfd80a2370', 'web', '2026-11-04 18:40:20.496', 0, '2026-10-28 18:40:20.496', '2026-10-28 18:40:20.496');
INSERT INTO `sys_refresh_token` VALUES (59, 5, 'cb5e04e1316ee5d2f4ae29f9d9b70de1bbfcad6bba6a1032945fea825d9966ab', 'web', '2026-11-04 18:40:43.587', 0, '2026-10-28 18:40:43.588', '2026-10-28 18:40:43.588');
INSERT INTO `sys_refresh_token` VALUES (60, 5, 'fe5b6213768f9f1477587b12c61125b571ef5d829a4c5aca9306155fe2f7a6a8', 'web', '2026-11-04 18:42:01.772', 0, '2026-10-28 18:42:01.773', '2026-10-28 18:42:01.773');
INSERT INTO `sys_refresh_token` VALUES (61, 5, '0bf1ff47e0287aa4b690fad750328719fd322640250156ddc47d265ddb242b55', 'web', '2026-11-04 18:44:51.902', 0, '2026-10-28 18:44:51.903', '2026-10-28 18:44:51.903');
INSERT INTO `sys_refresh_token` VALUES (62, 6, '512a74a9ca20a55b1d4e60871805493d72b73fa4b6b3a77aba1d41dfc8473db9', 'web', '2026-11-04 18:49:58.852', 0, '2026-10-28 18:49:58.854', '2026-10-28 18:49:58.854');
INSERT INTO `sys_refresh_token` VALUES (63, 7, '3a6a49a028d7394415c22ea47022a1c5c7cab0270a3aac1ac34cd67ee30c3ecf', 'web', '2026-11-04 18:50:15.656', 0, '2026-10-28 18:50:15.656', '2026-10-28 18:50:15.656');
INSERT INTO `sys_refresh_token` VALUES (64, 7, '340f04e98562cac6e78e905552f92dd8d99709ede9085f55e2fa89b4646495c7', 'web', '2026-11-04 19:03:46.510', 0, '2026-10-28 19:03:46.512', '2026-10-28 19:03:46.512');
INSERT INTO `sys_refresh_token` VALUES (65, 5, 'd2c35ca5710a9e6e03ebf21fea9431c6e45d3e48b96013bc56e4795242a85718', 'web', '2026-11-04 19:30:40.494', 0, '2026-10-28 19:30:40.494', '2026-10-28 19:30:40.494');
INSERT INTO `sys_refresh_token` VALUES (66, 5, '614fac85d192d3c2c70c1434658471f4116cdb72b7173b3135e0e24eb1d3a067', 'web', '2026-11-05 12:07:38.857', 0, '2026-10-29 12:07:38.860', '2026-10-29 12:07:38.860');
INSERT INTO `sys_refresh_token` VALUES (67, 5, 'b440f305b74bb9456a7bdc3ee7194d48791678152cef58ee6d14eb58f772a460', 'web', '2026-11-06 17:22:47.145', 0, '2026-10-30 17:22:47.153', '2026-10-30 17:22:47.153');
INSERT INTO `sys_refresh_token` VALUES (68, 5, 'ad4296a594b7b67855957ed7cf36bcdb83999c6cc8414934f67f68db5f7e4dce', 'web', '2026-11-08 16:53:24.819', 0, '2026-11-01 16:53:24.822', '2026-11-01 16:53:24.822');
INSERT INTO `sys_refresh_token` VALUES (69, 5, '08b3d4e669da1c727fc589aaf71b512726df67f88aa474bba7a93d9ddcfdb8f0', 'web', '2026-11-08 16:53:52.683', 1, '2026-11-01 16:53:52.684', '2026-11-01 16:54:36.914');
INSERT INTO `sys_refresh_token` VALUES (70, 5, '90531dc3196945657c0f93f4be44d3c801c8ab5a13f6d6da4493378788824c23', 'web', '2026-11-08 16:55:18.050', 0, '2026-11-01 16:55:18.050', '2026-11-01 16:55:18.050');
INSERT INTO `sys_refresh_token` VALUES (71, 5, 'e67e69cff7b5630d967f4d566a389a1a0a23423c6e1ff5e3b8035fb841756cb0', 'web', '2026-11-08 16:58:20.972', 0, '2026-11-01 16:58:20.972', '2026-11-01 16:58:20.972');
INSERT INTO `sys_refresh_token` VALUES (72, 5, '299aa1b66434ed32e6cd3f8eedd7390a72db231a1a975c45c2f44ace635b62df', 'web', '2026-11-08 17:02:46.192', 0, '2026-11-01 17:02:46.192', '2026-11-01 17:02:46.192');
INSERT INTO `sys_refresh_token` VALUES (73, 5, '8025b8c40a8b93f6c48fea5fc92652317c029536b080412b9365cdfb15d0904b', 'web', '2026-11-08 17:07:03.016', 0, '2026-11-01 17:07:03.017', '2026-11-01 17:07:03.017');
INSERT INTO `sys_refresh_token` VALUES (74, 5, '7fc8585202aaa62394d45ee14dd692a8a2a5f2d9b592dad7051b779de23fe7c6', 'web', '2026-11-08 17:08:08.945', 0, '2026-11-01 17:08:08.947', '2026-11-01 17:08:08.947');
INSERT INTO `sys_refresh_token` VALUES (75, 5, 'fc41b698c22b0bb1923e9d72e1d4aedd92ca55185be91e51fc52846ca5d2d23a', 'web', '2026-11-08 17:10:40.246', 0, '2026-11-01 17:10:40.247', '2026-11-01 17:10:40.247');
INSERT INTO `sys_refresh_token` VALUES (76, 5, 'b2afd9f064990fd44ec8de09e1c3a2a41bd85a8e41890d6820e49ed20130118d', 'web', '2026-11-08 17:13:08.126', 0, '2026-11-01 17:13:08.127', '2026-11-01 17:13:08.127');
INSERT INTO `sys_refresh_token` VALUES (77, 5, '757bc9bb0319edc3f9ad41b454f9bc51912ebb00fd324416fe1308d583193880', 'web', '2026-11-08 17:19:33.280', 0, '2026-11-01 17:19:33.281', '2026-11-01 17:19:33.281');
INSERT INTO `sys_refresh_token` VALUES (78, 5, 'd443a3eda39e38057c736a8eaa0d6a3cd7b838db4b3d26a7d17188dc9fd3e6f1', 'web', '2026-11-08 17:31:05.668', 0, '2026-11-01 17:31:05.670', '2026-11-01 17:31:05.670');
INSERT INTO `sys_refresh_token` VALUES (79, 5, '3b6c78a63cb2dce02cce3ccdf58ef2e8eb1e1d4d918f091811428a5a77c4d62d', 'web', '2026-11-08 17:32:42.880', 0, '2026-11-01 17:32:42.880', '2026-11-01 17:32:42.880');
INSERT INTO `sys_refresh_token` VALUES (80, 5, '19ff7c206beb01cc76642055c4506770d10d83105af652969dca1e2e95798b0e', 'web', '2026-11-08 17:34:28.807', 0, '2026-11-01 17:34:28.807', '2026-11-01 17:34:28.807');
INSERT INTO `sys_refresh_token` VALUES (81, 5, '7bbe97443839156710e2ba4cc1c650c78211e90c19160f01a5b4439086d7efac', 'web', '2026-11-08 17:35:08.565', 0, '2026-11-01 17:35:08.566', '2026-11-01 17:35:08.566');
INSERT INTO `sys_refresh_token` VALUES (82, 5, 'b6ed8f6e4a8d57d68af8977195dff5074dbb3e4db494ae8e57f1258b2ff162eb', 'web', '2026-11-08 17:36:12.947', 0, '2026-11-01 17:36:12.947', '2026-11-01 17:36:12.947');
INSERT INTO `sys_refresh_token` VALUES (83, 5, '8741ed19fd3774d4c0ff25a40d910c4b327a4a3dd892df4d4b3828ffc1a2b8e0', 'web', '2026-11-08 17:38:05.961', 0, '2026-11-01 17:38:05.961', '2026-11-01 17:38:05.961');
INSERT INTO `sys_refresh_token` VALUES (84, 5, 'c24740e3f0edfdb780fd1e7bdf48fab873c649f6a086d4429a17c25141149d53', 'web', '2026-11-08 17:38:32.033', 0, '2026-11-01 17:38:32.033', '2026-11-01 17:38:32.033');
INSERT INTO `sys_refresh_token` VALUES (85, 5, 'f662216e4090d4fc8bd2a018f93bf5bde4000939dc8d12bfe82355dc3c9eb768', 'web', '2026-11-08 17:39:25.489', 0, '2026-11-01 17:39:25.489', '2026-11-01 17:39:25.489');
INSERT INTO `sys_refresh_token` VALUES (86, 5, 'edb2341808e81b32e88ecb2d1bd294520b24eb6f36d68538b369bbe7e5665cd8', 'web', '2026-11-08 17:41:34.057', 0, '2026-11-01 17:41:34.057', '2026-11-01 17:41:34.057');
INSERT INTO `sys_refresh_token` VALUES (87, 5, '8a3e2651afda9a65b6fc9e020bced44693ca9ada7af1edf0e619b9851b1b76ee', 'web', '2026-11-08 17:42:57.082', 0, '2026-11-01 17:42:57.082', '2026-11-01 17:42:57.082');
INSERT INTO `sys_refresh_token` VALUES (88, 5, 'b84672da02142ed2531e9572d4276a47bfcf144632b0459b7f8c12bf11ee2e36', 'web', '2026-11-08 17:45:09.126', 0, '2026-11-01 17:45:09.127', '2026-11-01 17:45:09.127');
INSERT INTO `sys_refresh_token` VALUES (89, 5, '1daa5d64118630f4c49133fd368109d4a0f297409fb6f18e5f35cc4f315f56c9', 'web', '2026-11-08 17:48:22.812', 0, '2026-11-01 17:48:22.815', '2026-11-01 17:48:22.815');
INSERT INTO `sys_refresh_token` VALUES (90, 5, '778110d3e3aef546eb372beadef4b5e443d5642faf6b3fcba7c96cbd622c820f', 'web', '2026-11-08 18:20:18.520', 0, '2026-11-01 18:20:18.592', '2026-11-01 18:20:18.592');
INSERT INTO `sys_refresh_token` VALUES (91, 7, 'ba8da73408cd8b52032a937d2c7fd4eaab0e21619418f33bfdc1a233b826a469', 'web', '2026-11-08 18:34:42.356', 0, '2026-11-01 18:34:42.358', '2026-11-01 18:34:42.358');
INSERT INTO `sys_refresh_token` VALUES (92, 7, 'ad3bb85332e317fb70d125b4eea4d83fba10d838c789e41af18012789b8ff407', 'web', '2026-11-08 18:34:46.295', 0, '2026-11-01 18:34:46.295', '2026-11-01 18:34:46.295');
INSERT INTO `sys_refresh_token` VALUES (93, 5, '4f1aa20995992d944436a59e88b7afd75a729f3f74d7cd49ebf476c35d977eed', 'web', '2026-11-08 18:40:36.752', 0, '2026-11-01 18:40:36.752', '2026-11-01 18:40:36.752');
INSERT INTO `sys_refresh_token` VALUES (94, 5, 'e22d5b5bce3ed49ea5fbfd9ab40ea6e0bdf006a6018ee038a8ae6d1453ba755d', 'web', '2026-11-08 18:45:20.526', 0, '2026-11-01 18:45:20.527', '2026-11-01 18:45:20.527');
INSERT INTO `sys_refresh_token` VALUES (95, 7, '0500fe3959207ca758930b531a07ebd9613c06ebc39133ea53a77c3ea163ab77', 'web', '2026-11-08 18:45:29.815', 0, '2026-11-01 18:45:29.815', '2026-11-01 18:45:29.815');
INSERT INTO `sys_refresh_token` VALUES (96, 7, '3659a2f03e9a85d100787f6a417229008aa249d40164f4c33f77f0b6087b34a9', 'web', '2026-11-08 18:58:39.093', 0, '2026-11-01 18:58:39.093', '2026-11-01 18:58:39.093');
INSERT INTO `sys_refresh_token` VALUES (97, 5, '2a050133aa9891a2783199aa9f1febfecea5be250a10d40801f621c297488393', 'web', '2026-11-08 18:58:48.972', 0, '2026-11-01 18:58:48.973', '2026-11-01 18:58:48.973');
INSERT INTO `sys_refresh_token` VALUES (98, 9, 'cf6803fb9fb427ab19baeb5c7c9f8b7b758664cac40323b1078afdb0a557a308', 'web', '2026-11-09 09:44:21.840', 0, '2026-11-02 09:44:21.841', '2026-11-02 09:44:21.841');
INSERT INTO `sys_refresh_token` VALUES (99, 7, 'cddd2536e38500eb96a2d5add2579217f85e2d97173c228fe6cf1d37d12c7198', 'web', '2026-11-09 09:45:06.402', 0, '2026-11-02 09:45:06.402', '2026-11-02 09:45:06.402');
INSERT INTO `sys_refresh_token` VALUES (100, 9, '4c0677dacb38e352862d712c4ff51697167b851a692ab75c3a01d593cc3bb3eb', 'web', '2026-11-09 09:47:01.769', 0, '2026-11-02 09:47:01.769', '2026-11-02 09:47:01.769');
INSERT INTO `sys_refresh_token` VALUES (101, 5, '9a00f2d14c504289b1c1506f4551f557912671f7770719d715abd6ec3cd54391', 'web', '2026-11-09 09:49:17.099', 0, '2026-11-02 09:49:17.099', '2026-11-02 09:49:17.099');
INSERT INTO `sys_refresh_token` VALUES (102, 5, 'd2a7854d57fd18be31bf6f4c190438282683f51915b41a66d172faa270b6fbd7', 'web', '2026-11-09 10:14:31.239', 0, '2026-11-02 10:14:31.240', '2026-11-02 10:14:31.240');
INSERT INTO `sys_refresh_token` VALUES (103, 10, 'd8b202f3d15bf02fd7d601d433be2ddf71d10a03e34ec3f59f56da13736663ef', 'web', '2026-11-09 10:17:21.489', 1, '2026-11-02 10:17:21.489', '2026-11-02 10:54:45.169');
INSERT INTO `sys_refresh_token` VALUES (104, 5, 'd5deba9917b438b4af1b829a637bf6adf6fdf6927332aa160a88b7e1f4cda1a8', 'web', '2026-11-09 10:55:14.821', 0, '2026-11-02 10:55:14.822', '2026-11-02 10:55:14.822');
INSERT INTO `sys_refresh_token` VALUES (105, 9, '577659970ddb74bdaab6ee9c01f43f14b01352bdd1c5d490199ca406c5672d61', 'web', '2026-11-09 11:01:20.973', 0, '2026-11-02 11:01:20.973', '2026-11-02 11:01:20.973');
INSERT INTO `sys_refresh_token` VALUES (106, 5, '23a9bc929f74221bd91a7aa824324cd0af90162e5e072d7fc6646f9a40f1fee9', 'web', '2026-11-09 11:02:02.682', 0, '2026-11-02 11:02:02.683', '2026-11-02 11:02:02.683');
INSERT INTO `sys_refresh_token` VALUES (107, 9, '2c6536e74a97db790d680a7e4fb840a7ea4c0d25efabd630e543de32f266062b', 'web', '2026-11-09 11:07:44.505', 0, '2026-11-02 11:07:44.505', '2026-11-02 11:07:44.505');
INSERT INTO `sys_refresh_token` VALUES (108, 9, '7970287928e1ef2e698b485453f6bd4cd25474e861c0e9ebcce0843c683d415f', 'web', '2026-11-09 11:11:45.315', 0, '2026-11-02 11:11:45.316', '2026-11-02 11:11:45.316');
INSERT INTO `sys_refresh_token` VALUES (109, 9, '08d6fb89d0880a0d734647f2b6b9328b89e13efed1c534be3117aea6a37b4487', 'web', '2026-11-09 11:33:00.386', 0, '2026-11-02 11:33:00.387', '2026-11-02 11:33:00.387');

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
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户-角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_info
-- ----------------------------
INSERT INTO `sys_role_info` VALUES (1, 4, 6, '2026-10-26 16:06:00');
INSERT INTO `sys_role_info` VALUES (2, 5, 4, '2026-10-26 16:23:05');
INSERT INTO `sys_role_info` VALUES (3, 6, 6, '2026-10-26 16:26:56');
INSERT INTO `sys_role_info` VALUES (4, 7, 6, '2026-10-27 10:40:28');
INSERT INTO `sys_role_info` VALUES (5, 8, 6, '2026-10-28 18:37:02');
INSERT INTO `sys_role_info` VALUES (6, 9, 6, '2026-11-02 09:44:07');
INSERT INTO `sys_role_info` VALUES (7, 10, 6, '2026-11-02 10:17:11');

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
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'tom123', '$2a$12$tEFa.HGblOLYEOOUhB9B.u/3iUQdzPgKoi5puXnp4Itxqiz5QAATC', 'tom123', '123@qq.com', '17786174112', 1, '2026-10-27 09:28:10', '2026-10-26 11:53:23', '2026-10-27 09:28:10', 0);
INSERT INTO `sys_user` VALUES (2, 'kity123#DEL#2', '$2a$12$iZlVyeaysy/Nhs/YC7.sxOh6CDw6iF1H/5/XwRBGORFJp/0YUSq9G', 'kity123', '123@qq.com', '17786174112', 1, '2026-10-26 15:49:27', '2026-10-26 14:47:38', '2026-10-26 17:24:57', 1);
INSERT INTO `sys_user` VALUES (4, 'babo123#DEL#4', '$2a$12$AN/XgPPH3FwFqBUEx5ayKeeY7wzHsH.gwnuUfz6FY0v6HJAACyJ9m', 'babo123', '123@qq.com', '17786174112', 1, '2026-10-26 16:24:01', '2026-10-26 16:06:00', '2026-10-26 16:34:23', 1);
INSERT INTO `sys_user` VALUES (5, 'admin', '$2a$12$wThUxuRGa5RP6rpEtpfKAerFg0OOo312Wo5aqSUEWvflU/Z0tPIim', 'admin123', '123@qq.com', '17786174112', 1, '2026-11-02 11:02:03', '2026-10-26 16:23:05', '2026-11-02 11:02:03', 0);
INSERT INTO `sys_user` VALUES (6, 'public', '$2a$12$Vs84o9vWNOPlTWSFoJboD.uRIhbzR18sCr/D/YtcGbbynee69LNFO', 'public123', '123@qq.com', '17786174112', 1, '2026-10-28 18:49:59', '2026-10-26 16:26:56', '2026-10-28 18:49:59', 0);
INSERT INTO `sys_user` VALUES (7, 'test', '$2a$12$0PgccZ.RtVPrw0KdgUGU6uLdz.rRQ69QRYX2oAnJmbO8D05eZpHdm', 'test123', '123@qq.com', '17786174112', 1, '2026-11-02 09:45:06', '2026-10-27 10:40:29', '2026-11-02 09:45:06', 0);
INSERT INTO `sys_user` VALUES (8, 'mary', '$2a$12$fc8lQSIZy5UA5kyes2NrVusqWq/j6E5IpujUljqrcfkgqZ8dFwQGa', 'mary123', '123@qq.com', '17786174112', 1, '2026-10-28 18:37:25', '2026-10-28 18:37:03', '2026-10-28 18:37:25', 0);
INSERT INTO `sys_user` VALUES (9, 'lucy', '$2a$12$jzZH6./eEeTlrrlx8wERYeJddQjHCehTbrXFQjMpfW5bimJ0iBEL6', 'lucy123', '123@qq.com', '17786174112', 1, '2026-11-02 11:33:00', '2026-11-02 09:44:07', '2026-11-02 11:33:00', 0);
INSERT INTO `sys_user` VALUES (10, 'bard', '$2a$12$WOBBIvfbtL.oPbniuWcDo.4jsFTr8nfTEWPnqhMXbBiWghV4/uWH2', 'bard123', '123@qq.com', '17786174112', 1, '2026-11-02 10:17:21', '2026-11-02 10:17:11', '2026-11-02 10:17:21', 0);

SET FOREIGN_KEY_CHECKS = 1;
