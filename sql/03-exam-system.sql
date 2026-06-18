-- =====================================================
-- 华为ICT智慧实训平台 - 考试系统补充脚本
-- 新增 exam_results 表 & exams 表扩展字段
-- =====================================================

USE `huawei_ict`;

-- =====================================================
-- 1. exams 表新增字段（考试持续时间、总分、及格分）
-- MySQL 不支持 ADD COLUMN IF NOT EXISTS，用存储过程判断
-- =====================================================
DROP PROCEDURE IF EXISTS `AddExamColumns`;
DELIMITER $$
CREATE PROCEDURE `AddExamColumns`()
BEGIN
    IF NOT EXISTS (SELECT * FROM `information_schema`.`COLUMNS`
        WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'exams' AND `COLUMN_NAME` = 'duration') THEN
        ALTER TABLE `exams` ADD COLUMN `duration` INT DEFAULT 60 COMMENT '考试时长(分钟)';
    END IF;

    IF NOT EXISTS (SELECT * FROM `information_schema`.`COLUMNS`
        WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'exams' AND `COLUMN_NAME` = 'total_score') THEN
        ALTER TABLE `exams` ADD COLUMN `total_score` INT DEFAULT 100 COMMENT '总分';
    END IF;

    IF NOT EXISTS (SELECT * FROM `information_schema`.`COLUMNS`
        WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'exams' AND `COLUMN_NAME` = 'pass_score') THEN
        ALTER TABLE `exams` ADD COLUMN `pass_score` INT DEFAULT 60 COMMENT '及格分';
    END IF;
END$$
DELIMITER ;
CALL `AddExamColumns`();
DROP PROCEDURE IF EXISTS `AddExamColumns`;

-- 清理旧数据中 user_id 不为空的记录（迁移设计）
UPDATE `exams` SET `user_id` = NULL WHERE `user_id` IS NOT NULL;

-- =====================================================
-- 2. exam_results - 学生考试结果/记录表
-- =====================================================
CREATE TABLE IF NOT EXISTS `exam_results` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `exam_id` BIGINT NOT NULL COMMENT '考试ID',
    `user_id` BIGINT NOT NULL COMMENT '学生ID',
    `score` INT DEFAULT 0 COMMENT '得分',
    `total_score` INT DEFAULT 0 COMMENT '总分',
    `correct_count` INT DEFAULT 0 COMMENT '正确数',
    `question_count` INT DEFAULT 0 COMMENT '题目总数',
    `status` VARCHAR(20) NOT NULL DEFAULT 'IN_PROGRESS' COMMENT 'IN_PROGRESS, COMPLETED',
    `started_at` DATETIME DEFAULT NULL COMMENT '开始时间',
    `completed_at` DATETIME DEFAULT NULL COMMENT '完成时间',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_exam_id` (`exam_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_user_exam` (`user_id`, `exam_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考试结果/记录表';
