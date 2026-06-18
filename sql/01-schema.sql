-- =====================================================
-- 华为ICT智慧实训平台 - 数据库建表脚本
-- 数据库: huawei_ict
-- =====================================================

CREATE DATABASE IF NOT EXISTS `huawei_ict` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `huawei_ict`;

-- 用户表
CREATE TABLE IF NOT EXISTS `users` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(50) NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `name` VARCHAR(100) DEFAULT NULL,
    `role` VARCHAR(20) NOT NULL COMMENT 'STUDENT, TEACHER, ADMIN',
    `student_id` VARCHAR(50) DEFAULT NULL COMMENT '学号/工号',
    `email` VARCHAR(100) DEFAULT NULL,
    `phone` VARCHAR(20) DEFAULT NULL,
    `avatar` VARCHAR(255) DEFAULT NULL,
    `certification_level` VARCHAR(50) DEFAULT NULL COMMENT '认证等级 HCIA/HCIP/HCIE',
    `status` VARCHAR(20) NOT NULL DEFAULT 'NORMAL' COMMENT 'NORMAL, DISABLED, PENDING',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 课程表
CREATE TABLE IF NOT EXISTS `courses` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(200) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `category` VARCHAR(50) DEFAULT NULL COMMENT 'HCIA/HCIP/HCIE/Cloud/BigData/AI',
    `image_url` VARCHAR(500) DEFAULT NULL,
    `total_chapters` INT DEFAULT NULL,
    `total_hours` INT DEFAULT NULL,
    `student_count` INT DEFAULT 0,
    `teacher_id` BIGINT DEFAULT NULL COMMENT '任课教师 user.id（User.Role=TEACHER）',
    `status` VARCHAR(20) NOT NULL DEFAULT 'DRAFT' COMMENT 'PUBLISHED, DRAFT, PENDING',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_teacher_id` (`teacher_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程表';

-- 课程章节表
CREATE TABLE IF NOT EXISTS `course_chapters` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `course_id` BIGINT NOT NULL,
    `name` VARCHAR(200) NOT NULL,
    `sort_order` INT DEFAULT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_course_id` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程章节表';

-- 用户课程关联表
CREATE TABLE IF NOT EXISTS `user_courses` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `course_id` BIGINT NOT NULL,
    `progress` INT NOT NULL DEFAULT 0 COMMENT '学习进度 0-100',
    `status` VARCHAR(20) NOT NULL DEFAULT 'NOT_STARTED' COMMENT 'NOT_STARTED, IN_PROGRESS, COMPLETED',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_course_id` (`course_id`),
    UNIQUE KEY `uk_user_course` (`user_id`, `course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户课程关联表';

-- 考试/题库表
CREATE TABLE IF NOT EXISTS `exams` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(200) NOT NULL,
    `category` VARCHAR(50) DEFAULT NULL,
    `question_count` INT DEFAULT 0,
    `correct_rate` DOUBLE DEFAULT NULL,
    `score` INT DEFAULT NULL,
    `user_id` BIGINT DEFAULT NULL,
    `status` VARCHAR(20) DEFAULT 'NOT_STARTED' COMMENT 'NOT_STARTED, IN_PROGRESS, COMPLETED',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考试/题库表';

-- 题目表
CREATE TABLE IF NOT EXISTS `questions` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `exam_id` BIGINT NOT NULL,
    `content` TEXT NOT NULL,
    `options` TEXT DEFAULT NULL COMMENT 'JSON格式的选项',
    `answer` VARCHAR(500) DEFAULT NULL,
    `type` VARCHAR(20) DEFAULT NULL COMMENT 'SINGLE/MULTI/JUDGE/FILL',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_exam_id` (`exam_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='题目表';

-- 答题记录表
CREATE TABLE IF NOT EXISTS `question_records` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `question_id` BIGINT NOT NULL,
    `answer` VARCHAR(500) DEFAULT NULL,
    `is_correct` TINYINT(1) DEFAULT NULL,
    `mode` VARCHAR(20) DEFAULT 'PRACTICE' COMMENT 'PRACTICE: 题库练习, EXAM: 模拟考试',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_question_id` (`question_id`),
    KEY `idx_mode` (`mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='答题记录表';

-- 实验表
CREATE TABLE IF NOT EXISTS `labs` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(200) NOT NULL,
    `type` VARCHAR(50) DEFAULT NULL COMMENT '云计算/网络/存储/容器',
    `difficulty` VARCHAR(20) DEFAULT NULL COMMENT '初级/中级/高级',
    `description` TEXT DEFAULT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'IDLE' COMMENT 'RUNNING, IDLE, COMPLETED',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实验表';

-- 实验实例表
CREATE TABLE IF NOT EXISTS `lab_instances` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `lab_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'IDLE' COMMENT 'RUNNING, COMPLETED, IDLE',
    `resources` VARCHAR(100) DEFAULT NULL COMMENT '资源配置，如 2 vCPU / 4GB',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_lab_id` (`lab_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实验实例表';

-- 竞赛表
CREATE TABLE IF NOT EXISTS `competitions` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(200) NOT NULL,
    `track` VARCHAR(50) DEFAULT NULL COMMENT '赛道/路由/云计算/大数据/AI',
    `registration_count` INT DEFAULT 0,
    `status` VARCHAR(20) NOT NULL DEFAULT 'OPEN' COMMENT 'OPEN, ONGOING, CLOSED',
    `deadline` DATE DEFAULT NULL,
    `competition_date` DATE DEFAULT NULL,
    `description` TEXT DEFAULT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='竞赛表';

-- 报名记录表
CREATE TABLE IF NOT EXISTS `registrations` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `competition_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    `status` VARCHAR(20) DEFAULT 'PENDING' COMMENT 'PENDING, APPROVED, REJECTED',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_competition_id` (`competition_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报名记录表';

-- 职位表
CREATE TABLE IF NOT EXISTS `jobs` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(200) NOT NULL,
    `company` VARCHAR(200) NOT NULL,
    `salary` VARCHAR(50) DEFAULT NULL,
    `location` VARCHAR(100) DEFAULT NULL,
    `experience` VARCHAR(50) DEFAULT NULL,
    `education` VARCHAR(50) DEFAULT NULL,
    `description` TEXT DEFAULT NULL,
    `requirement` TEXT DEFAULT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE, CLOSED, PENDING',
    `apply_count` INT DEFAULT 0,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='职位表';

-- 投递记录表
CREATE TABLE IF NOT EXISTS `job_applications` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `job_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    `status` VARCHAR(20) DEFAULT 'PENDING' COMMENT 'PENDING, APPROVED, REJECTED',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_job_id` (`job_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='投递记录表';

-- 认证考试记录表
CREATE TABLE IF NOT EXISTS `certifications` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `type` VARCHAR(100) DEFAULT NULL COMMENT '认证类型 HCIA/HCIP/HCIE',
    `exam_date` DATE DEFAULT NULL,
    `score` INT DEFAULT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT 'PASSED, FAILED, PENDING',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='认证考试记录表';

-- 通知表
CREATE TABLE IF NOT EXISTS `notifications` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(200) NOT NULL,
    `content` TEXT DEFAULT NULL,
    `type` VARCHAR(20) DEFAULT NULL COMMENT 'SYSTEM/COURSE/EXAM/JOB',
    `status` VARCHAR(20) NOT NULL DEFAULT 'UNREAD' COMMENT 'UNREAD, READ',
    `audience` VARCHAR(20) NOT NULL DEFAULT 'ALL' COMMENT 'STUDENT/ADMIN/ALL — 通知受众',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知表';

-- 学习记录表
CREATE TABLE IF NOT EXISTS `learning_records` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `date` DATE DEFAULT NULL,
    `duration` INT DEFAULT NULL COMMENT '学习时长(分钟)',
    `focus_rate` DOUBLE DEFAULT NULL COMMENT '专注度',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习记录表';

-- 知识点掌握度表
CREATE TABLE IF NOT EXISTS `knowledge_points` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(200) NOT NULL,
    `mastery_rate` DOUBLE DEFAULT NULL COMMENT '掌握度 0-100',
    `user_id` BIGINT NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识点掌握度表';

-- 系统设置表
CREATE TABLE IF NOT EXISTS `system_settings` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `key` VARCHAR(100) NOT NULL,
    `value` TEXT DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统设置表';

-- 迁移：为已有 question_records 表增加 mode 字段（如已存在则忽略）
ALTER TABLE `question_records` ADD COLUMN IF NOT EXISTS `mode` VARCHAR(20) DEFAULT 'PRACTICE' COMMENT 'PRACTICE: 题库练习, EXAM: 模拟考试' AFTER `is_correct`, ADD INDEX IF NOT EXISTS `idx_mode` (`mode`);

