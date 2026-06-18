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

-- =====================================================
-- 华为ICT智慧实训平台 - 初始化数据脚本
-- =====================================================

USE `huawei_ict`;

-- 默认管理员账号(密码: 123456 -> BCrypt加密)
INSERT IGNORE INTO `users` (`username`, `password`, `name`, `role`, `student_id`, `status`) VALUES
('guanli', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '管理员', 'ADMIN', 'ADMIN001', 'NORMAL'),
('xuesheng', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '学生用户', 'STUDENT', 'ICT2024001', 'NORMAL'),
('laoshi', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王老师', 'TEACHER', 'TCH2024001', 'NORMAL');

-- 样例用户
INSERT IGNORE INTO `users` (`username`, `password`, `name`, `role`, `student_id`, `certification_level`, `status`) VALUES
('zhangsan', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '张同学', 'STUDENT', 'ICT2024002', 'HCIA', 'NORMAL'),
('lisi', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '李同学', 'STUDENT', 'ICT2024003', 'HCIP', 'NORMAL'),
('zhaowu', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '赵同学', 'STUDENT', 'ICT2024004', NULL, 'PENDING');

('g402240101', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '艾玉鉴', 'STUDENT', 'G402240101', NULL, 'NORMAL'),
('g402240102', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '毕于杰', 'STUDENT', 'G402240102', NULL, 'NORMAL'),
('g402240103', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '陈家乐', 'STUDENT', 'G402240103', NULL, 'NORMAL'),
('g402240104', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '代浩', 'STUDENT', 'G402240104', NULL, 'NORMAL'),
('g402240105', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '郭洪扬', 'STUDENT', 'G402240105', NULL, 'NORMAL'),
('g402240107', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '房亚成', 'STUDENT', 'G402240107', NULL, 'NORMAL'),
('g402240108', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '葛卓', 'STUDENT', 'G402240108', NULL, 'NORMAL'),
('g402240109', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '焦龍阳', 'STUDENT', 'G402240109', NULL, 'NORMAL'),
('g402240110', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '郭涵召', 'STUDENT', 'G402240110', NULL, 'NORMAL'),
('g402240111', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '郭祥涛', 'STUDENT', 'G402240111', NULL, 'NORMAL'),
('g402240112', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '侯传亿', 'STUDENT', 'G402240112', NULL, 'NORMAL'),
('g402240113', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '胡家兴', 'STUDENT', 'G402240113', NULL, 'NORMAL'),
('g402240114', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '黄思赐', 'STUDENT', 'G402240114', NULL, 'NORMAL'),
('g402240115', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '纪子岩', 'STUDENT', 'G402240115', NULL, 'NORMAL'),
('g402240116', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '贾琪浩', 'STUDENT', 'G402240116', NULL, 'NORMAL'),
('g402240117', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '孔德顺', 'STUDENT', 'G402240117', NULL, 'NORMAL'),
('g402240120', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '李润甲', 'STUDENT', 'G402240120', NULL, 'NORMAL'),
('g402240121', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '李帅', 'STUDENT', 'G402240121', NULL, 'NORMAL'),
('g402240122', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '李天卓', 'STUDENT', 'G402240122', NULL, 'NORMAL'),
('g402240123', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '李元浩', 'STUDENT', 'G402240123', NULL, 'NORMAL'),
('g402240124', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '刘浩宇', 'STUDENT', 'G402240124', NULL, 'NORMAL'),
('g402240125', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '刘恒硕', 'STUDENT', 'G402240125', NULL, 'NORMAL'),
('g402240126', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '刘恒田', 'STUDENT', 'G402240126', NULL, 'NORMAL'),
('g402240127', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '刘继忠', 'STUDENT', 'G402240127', NULL, 'NORMAL'),
('g402240128', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '刘家硕', 'STUDENT', 'G402240128', NULL, 'NORMAL'),
('g402240129', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '刘裕', 'STUDENT', 'G402240129', NULL, 'NORMAL'),
('g402240133', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '陈家乐', 'STUDENT', 'G402240133', NULL, 'NORMAL'),
('g402240134', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '陈洋', 'STUDENT', 'G402240134', NULL, 'NORMAL'),
('g402240135', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '崔欣骞', 'STUDENT', 'G402240135', NULL, 'NORMAL'),
('g402240136', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '邓淑琪', 'STUDENT', 'G402240136', NULL, 'NORMAL'),
('g402240137', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '丁勋', 'STUDENT', 'G402240137', NULL, 'NORMAL'),
('g402240138', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '杜国翌', 'STUDENT', 'G402240138', NULL, 'NORMAL'),
('g402240139', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '冯琳曼', 'STUDENT', 'G402240139', NULL, 'NORMAL'),
('g402240140', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '胡秋荀', 'STUDENT', 'G402240140', NULL, 'NORMAL'),
('g402240141', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '胡晓苒', 'STUDENT', 'G402240141', NULL, 'NORMAL'),
('g402240144', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '贾宇琦', 'STUDENT', 'G402240144', NULL, 'NORMAL'),
('g402240145', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '李佳乐', 'STUDENT', 'G402240145', NULL, 'NORMAL'),
('g402240146', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '李佳崴', 'STUDENT', 'G402240146', NULL, 'NORMAL'),
('g402240148', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '李可成', 'STUDENT', 'G402240148', NULL, 'NORMAL'),
('g402240149', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '李思彤', 'STUDENT', 'G402240149', NULL, 'NORMAL'),
('g402240150', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '李文博', 'STUDENT', 'G402240150', NULL, 'NORMAL'),
('g402240151', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '刘家兴', 'STUDENT', 'G402240151', NULL, 'NORMAL'),
('g402240152', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '刘艳芮', 'STUDENT', 'G402240152', NULL, 'NORMAL'),
('g402240153', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '孟舒', 'STUDENT', 'G402240153', NULL, 'NORMAL'),
('g402240154', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '牟春晓', 'STUDENT', 'G402240154', NULL, 'NORMAL'),
('g402240201', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '吕毓昌', 'STUDENT', 'G402240201', NULL, 'NORMAL'),
('g402240202', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '钱家骐', 'STUDENT', 'G402240202', NULL, 'NORMAL'),
('g402240203', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '秦国铭', 'STUDENT', 'G402240203', NULL, 'NORMAL'),
('g402240204', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '邱世伟', 'STUDENT', 'G402240204', NULL, 'NORMAL'),
('g402240205', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '任相鑫', 'STUDENT', 'G402240205', NULL, 'NORMAL'),
('g402240206', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '石昌臣', 'STUDENT', 'G402240206', NULL, 'NORMAL'),
('g402240207', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '宋承昊', 'STUDENT', 'G402240207', NULL, 'NORMAL'),
('g402240209', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '田海宇', 'STUDENT', 'G402240209', NULL, 'NORMAL'),
('g402240210', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王东攀', 'STUDENT', 'G402240210', NULL, 'NORMAL'),
('g402240211', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王诺', 'STUDENT', 'G402240211', NULL, 'NORMAL'),
('g402240212', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王浩南', 'STUDENT', 'G402240212', NULL, 'NORMAL'),
('g402240215', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王顺熙', 'STUDENT', 'G402240215', NULL, 'NORMAL'),
('g402240216', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王泽舶', 'STUDENT', 'G402240216', NULL, 'NORMAL'),
('g402240217', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '吴长州', 'STUDENT', 'G402240217', NULL, 'NORMAL'),
('g402240218', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '徐尊举', 'STUDENT', 'G402240218', NULL, 'NORMAL'),
('g402240219', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '许梓洋', 'STUDENT', 'G402240219', NULL, 'NORMAL'),
('g402240220', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '许季宇', 'STUDENT', 'G402240220', NULL, 'NORMAL'),
('g402240221', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '张成达', 'STUDENT', 'G402240221', NULL, 'NORMAL'),
('g402240222', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '张淏', 'STUDENT', 'G402240222', NULL, 'NORMAL'),
('g402240224', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '张硕', 'STUDENT', 'G402240224', NULL, 'NORMAL'),
('g402240225', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '张文杰', 'STUDENT', 'G402240225', NULL, 'NORMAL'),
('g402240227', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '张镇涛', 'STUDENT', 'G402240227', NULL, 'NORMAL'),
('g402240228', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '张梓昂', 'STUDENT', 'G402240228', NULL, 'NORMAL'),
('g402240230', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '赵梓名', 'STUDENT', 'G402240230', NULL, 'NORMAL'),
('g402240231', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '郑帅昊', 'STUDENT', 'G402240231', NULL, 'NORMAL'),
('g402240232', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '郑茂康', 'STUDENT', 'G402240232', NULL, 'NORMAL'),
('g402240233', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '庄方旭', 'STUDENT', 'G402240233', NULL, 'NORMAL'),
('g402240234', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '屈研', 'STUDENT', 'G402240234', NULL, 'NORMAL'),
('g402240235', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '任静波', 'STUDENT', 'G402240235', NULL, 'NORMAL'),
('g402240236', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '盛思远', 'STUDENT', 'G402240236', NULL, 'NORMAL'),
('g402240237', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '孙子其', 'STUDENT', 'G402240237', NULL, 'NORMAL'),
('g402240238', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '田欣艳', 'STUDENT', 'G402240238', NULL, 'NORMAL'),
('g402240239', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王谛', 'STUDENT', 'G402240239', NULL, 'NORMAL'),
('g402240240', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王佳丽', 'STUDENT', 'G402240240', NULL, 'NORMAL'),
('g402240241', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王慧荣', 'STUDENT', 'G402240241', NULL, 'NORMAL'),
('g402240242', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王世杰', 'STUDENT', 'G402240242', NULL, 'NORMAL'),
('g402240243', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王舒', 'STUDENT', 'G402240243', NULL, 'NORMAL'),
('g402240244', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王思彤', 'STUDENT', 'G402240244', NULL, 'NORMAL'),
('g402240245', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王欣廷', 'STUDENT', 'G402240245', NULL, 'NORMAL'),
('g402240247', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '吴骏文', 'STUDENT', 'G402240247', NULL, 'NORMAL'),
('g402240248', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '辛中华', 'STUDENT', 'G402240248', NULL, 'NORMAL'),
('g402240250', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '尹艺萌', 'STUDENT', 'G402240250', NULL, 'NORMAL'),
('g402240251', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '张娜', 'STUDENT', 'G402240251', NULL, 'NORMAL'),
('g402240252', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '张怡歌', 'STUDENT', 'G402240252', NULL, 'NORMAL'),
('g402240255', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '王浩东', 'STUDENT', 'G402240255', NULL, 'NORMAL'),
('g503240109', '$2a$10$tUd4j.kzXxJ0L/6Fw8AKheQ0ma1f/v1Ho057YgMmluyuf32CASlHW', '蒋元珂', 'STUDENT', 'G503240109', NULL, 'NORMAL');
-- 24级学生账号（91 人，默认密码 123456）
INSERT IGNORE INTO `users` (`username`, `password`, `name`, `role`, `student_id`, `certification_level`, `status`) VALUES

-- 课程（teacher_id=3 默认全部分配给 laoshi 教师账号）
INSERT IGNORE INTO `courses` (`name`, `description`, `category`, `image_url`, `total_chapters`, `total_hours`, `student_count`, `teacher_id`, `status`) VALUES
('HCIA-Datacom 基础认证', '数据通信基础，网络工程师入门必学', 'HCIA', 'https://img.alicdn.com/imgextra/i2/O1CN01QeJFdg1YcCZ7XeVDK_!!6000000003069-2.png', 8, 32, 128, 3, 'PUBLISHED'),
('HCIP-Datacom 高级认证', '高级路由交换，企业网络实战', 'HCIP', 'https://img.alicdn.com/imgextra/i4/O1CN01ZJQzfT1YcCZ8WqXyG_!!6000000003069-2.png', 10, 48, 256, 3, 'PUBLISHED'),
('HCIE-Datacom 专家认证', '顶级网络专家认证，面试+实验', 'HCIE', 'https://cdn-icons-png.flaticon.com/512/2103/2103655.png', 12, 56, 89, 3, 'PUBLISHED'),
('华为云计算 HCIA-Cloud', '云计算基础架构与华为云解决方案', 'Cloud', 'https://cdn-icons-png.flaticon.com/512/4149/4149643.png', 6, 24, 312, 3, 'PUBLISHED'),
('华为大数据 HCIA-Big Data', '大数据采集、存储与分析技术', 'BigData', 'https://cdn-icons-png.flaticon.com/512/2092/2092562.png', 7, 28, 176, 3, 'PUBLISHED'),
('华为人工智能 HCIA-AI', '机器学习、深度学习与华为昇腾', 'AI', 'https://cdn-icons-png.flaticon.com/512/3502/3502686.png', 9, 36, 203, 3, 'PENDING');

-- 课程章节
INSERT IGNORE INTO `course_chapters` (`course_id`, `name`, `sort_order`) VALUES
(1, '网络基础概念', 1), (1, 'IP地址与子网划分', 2), (1, '路由协议基础', 3), (1, '交换机原理', 4), (1, 'VLAN技术', 5), (1, 'STP协议', 6), (1, '静态路由配置', 7), (1, '网络故障排查', 8),
(2, 'OSPF协议详解', 1), (2, 'BGP基础', 2), (2, 'IS-IS协议', 3), (2, '多生成树协议', 4), (2, 'VRRP技术', 5), (2, 'MPLS基础', 6), (2, '组播技术', 7), (2, 'QoS策略', 8), (2, '网络虚拟化', 9), (2, 'SDN与NFV', 10);

-- 用户课程关联（所有学生 HCIA+HCIP 入门）
INSERT IGNORE INTO `user_courses` (`user_id`, `course_id`, `progress`, `status`) VALUES
(2, 1, 68, 'IN_PROGRESS'),
(2, 2, 0, 'NOT_STARTED'),
(3, 1, 85, 'IN_PROGRESS'),
(3, 2, 0, 'NOT_STARTED');

-- 题库/考试
INSERT IGNORE INTO `exams` (`title`, `category`, `question_count`, `user_id`, `status`) VALUES
('HCIA-Datacom 模拟卷（一）', 'HCIA', 50, 2, 'COMPLETED'),
('HCIA-Datacom 模拟卷（二）', 'HCIA', 50, 2, 'IN_PROGRESS'),
('HCIP-Datacom 模拟卷（一）', 'HCIP', 60, 2, 'NOT_STARTED'),
('HCIE 实验模拟题', 'HCIE', 30, 2, 'NOT_STARTED'),
('HCIA-Cloud 云计算基础', 'Cloud', 60, NULL, 'NOT_STARTED'),
('HCIA-Security 安全基础', 'AI', 40, NULL, 'NOT_STARTED');

-- 题目 (HCIA-Datacom 模拟卷一部分)
INSERT IGNORE INTO `questions` (`exam_id`, `content`, `options`, `answer`, `type`) VALUES
(1, 'OSPF协议中，Router ID的选举规则是什么？', '{"A":"最大的Loopback接口IP","B":"最大的物理接口IP","C":"手动配置优先，其次最大Loopback IP，再其次最大物理接口IP","D":"最小的物理接口IP"}', 'C', 'SINGLE'),
(1, '以下哪个VLAN ID范围是正常的？', '{"A":"0-1005","B":"1-4094","C":"0-4095","D":"1006-4094"}', 'B', 'SINGLE'),
(1, 'STP协议中，根桥的选举依据是什么？', '{"A":"最小的MAC地址","B":"最大的Bridge ID","C":"最小的Bridge ID","D":"最大的MAC地址"}', 'C', 'SINGLE'),
(1, '在华为设备上，查看路由表的命令是？', '{"A":"display ip routing-table","B":"show ip route","C":"display route-table","D":"show routing-table"}', 'A', 'SINGLE'),
(1, 'VLAN的主要作用是什么？', '{"A":"提高网络速度","B":"隔离广播域","C":"提高安全性","D":"B和C都是"}', 'D', 'SINGLE');

-- 答题记录
INSERT IGNORE INTO `question_records` (`user_id`, `question_id`, `answer`, `is_correct`) VALUES
(2, 1, 'C', 1), (2, 2, 'B', 1), (2, 3, 'C', 1), (2, 4, 'A', 1), (2, 5, 'D', 1);

-- 实验
INSERT IGNORE INTO `labs` (`name`, `type`, `difficulty`, `description`, `status`) VALUES
('华为云ECS服务器部署实战', '云计算', '初级', '学习如何创建和配置华为云ECS实例，部署Web应用', 'IDLE'),
('VPC虚拟私有云网络配置', '网络', '中级', '掌握VPC网络规划、子网划分和安全组配置', 'IDLE'),
('对象存储OBS实战应用', '存储', '初级', '使用OBS SDK进行对象存储的上传下载管理', 'IDLE'),
('RDS关系型数据库部署', '数据库', '中级', '在华为云上创建和配置RDS MySQL数据库', 'IDLE'),
('CCE容器引擎Kubernetes实战', '容器', '高级', '使用华为云CCE服务部署和管理Kubernetes集群', 'IDLE');

-- 实验实例
INSERT IGNORE INTO `lab_instances` (`lab_id`, `user_id`, `status`, `resources`) VALUES
(1, 2, 'COMPLETED', '2 vCPU / 4GB'),
(2, 2, 'RUNNING', '1 vCPU / 2GB');

-- 竞赛
INSERT IGNORE INTO `competitions` (`name`, `track`, `registration_count`, `status`, `deadline`, `competition_date`, `description`) VALUES
('2025华为ICT大赛-网络赛道', '网络', 256, 'CLOSED', '2025-10-31', '2026-03-15', '华为ICT大赛网络赛道，考察路由交换、网络安全等知识'),
('2025华为ICT大赛-云计算赛道', '云计算', 128, 'CLOSED', '2025-10-31', '2026-03-15', '华为ICT大赛云计算赛道，考察云计算架构与运维'),
('2025华为ICT大赛-大数据赛道', '大数据', 86, 'CLOSED', '2025-10-31', '2026-03-15', '华为ICT大赛大数据赛道，考察大数据采集与分析');

-- 职位
INSERT IGNORE INTO `jobs` (`title`, `company`, `salary`, `location`, `experience`, `education`, `description`, `status`) VALUES
('华为云解决方案工程师', '华为技术有限公司', '15-25K·13薪', '深圳', '3-5年', '本科', '负责华为云产品解决方案设计，要求熟悉华为云ECS、OBS、VPC等产品', 'ACTIVE'),
('数据通信网络工程师', '中软国际', '10-18K·14薪', '北京', '1-3年', '本科', '负责企业网络规划与设计，要求掌握路由器交换机配置，有HCIA认证优先', 'ACTIVE'),
('云计算运维工程师', '软通动力', '18-28K·13薪', '杭州', '3-5年', '本科', '负责华为云Stack私有云运维，要求熟悉OpenStack、Kubernetes', 'ACTIVE'),
('网络安全工程师', '深信服科技', '12-20K', '深圳', '1-3年', '本科', '负责网络安全方案设计与实施，要求掌握网络安全基础', 'ACTIVE');

-- 通知
INSERT IGNORE INTO `notifications` (`title`, `content`, `type`, `status`, `audience`) VALUES
('新用户注册审核（3人待审）', '3名新用户等待审核，请及时处理', 'SYSTEM', 'UNREAD', 'ADMIN'),
('课程内容更新提醒', 'HCIA-Datacom课程内容已更新至最新版本', 'COURSE', 'UNREAD', 'ALL'),
('服务器扩容已完成', '云实验室服务器已扩容完成，性能提升50%', 'SYSTEM', 'UNREAD', 'ALL'),
('HCIP题库同步更新', 'HCIP-Datacom题库已同步更新，新增200道真题', 'COURSE', 'UNREAD', 'ALL');

-- 系统设置
INSERT IGNORE INTO `system_settings` (`key`, `value`) VALUES
('platform_name', '华技云·华为ICT智慧实训平台'),
('platform_subtitle', '领先级华为ICT学院 · 岗课赛证一体化实训平台'),
('tech_support', '博赛数字科技联合共建'),
('beian_no', '鲁ICP备XXXXXXX号'),
('system_version', 'v2.0.1');

-- 学习记录
INSERT IGNORE INTO `learning_records` (`user_id`, `date`, `duration`, `focus_rate`) VALUES
(2, '2024-06-07', 120, 80),
(2, '2024-06-08', 150, 85),
(2, '2024-06-09', 100, 75),
(2, '2024-06-10', 180, 90),
(2, '2024-06-11', 130, 82),
(2, '2024-06-12', 90, 70),
(2, '2024-06-13', 60, 65);

-- 知识点掌握度
INSERT IGNORE INTO `knowledge_points` (`name`, `mastery_rate`, `user_id`) VALUES
('IP路由基础', 92, 2),
('OSPF协议', 68, 2),
('VLAN与交换', 85, 2),
('访问控制列表', 45, 2),
('NAT地址转换', 78, 2);
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
-- 薄弱知识点 (knowledge_points) - 91 学员 × 2-3 知识点/课程
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240101'), 'IPv6 过渡技术', 35.00), ((SELECT id FROM users WHERE student_id='G402240101'), 'BGP 高级特性', 28.00), ((SELECT id FROM users WHERE student_id='G402240101'), 'DHCP Snooping', 17.00), ((SELECT id FROM users WHERE student_id='G402240101'), 'NAT 地址转换', 49.00), ((SELECT id FROM users WHERE student_id='G402240101'), '静态路由配置', 62.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240102'), 'RSTP/MSTP', 32.00), ((SELECT id FROM users WHERE student_id='G402240102'), 'BGP 高级特性', 30.00), ((SELECT id FROM users WHERE student_id='G402240102'), 'QoS 流量整形', 63.00), ((SELECT id FROM users WHERE student_id='G402240102'), 'VLAN 划分与配置', 48.00), ((SELECT id FROM users WHERE student_id='G402240102'), 'DNS 域名解析', 65.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240103'), 'MPLS VPN 原理', 22.00), ((SELECT id FROM users WHERE student_id='G402240103'), 'BFD 双向转发检测', 34.00), ((SELECT id FROM users WHERE student_id='G402240103'), 'RSTP/MSTP', 32.00), ((SELECT id FROM users WHERE student_id='G402240103'), 'TCP/IP 协议栈', 64.00), ((SELECT id FROM users WHERE student_id='G402240103'), 'IP 地址与子网划分', 42.00), ((SELECT id FROM users WHERE student_id='G402240103'), 'DHCP 动态主机配置', 88.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240104'), '组播技术', 28.00), ((SELECT id FROM users WHERE student_id='G402240104'), 'BGP 高级特性', 23.00), ((SELECT id FROM users WHERE student_id='G402240104'), 'IPv6 过渡技术', 21.00), ((SELECT id FROM users WHERE student_id='G402240104'), 'DHCP 动态主机配置', 90.00), ((SELECT id FROM users WHERE student_id='G402240104'), 'VRP 操作系统基础', 54.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240105'), 'QoS 流量整形', 27.00), ((SELECT id FROM users WHERE student_id='G402240105'), 'RSTP/MSTP', 45.00), ((SELECT id FROM users WHERE student_id='G402240105'), 'DNS 域名解析', 90.00), ((SELECT id FROM users WHERE student_id='G402240105'), 'VLAN 划分与配置', 35.00), ((SELECT id FROM users WHERE student_id='G402240105'), 'DHCP 动态主机配置', 85.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240107'), 'OSPF 高级特性', 25.00), ((SELECT id FROM users WHERE student_id='G402240107'), 'BGP 高级特性', 23.00), ((SELECT id FROM users WHERE student_id='G402240107'), 'DHCP 动态主机配置', 51.00), ((SELECT id FROM users WHERE student_id='G402240107'), 'BGP 路由协议', 23.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240108'), 'VRRP 双机热备', 24.00), ((SELECT id FROM users WHERE student_id='G402240108'), '组播技术', 16.00), ((SELECT id FROM users WHERE student_id='G402240108'), 'OSPF 高级特性', 32.00), ((SELECT id FROM users WHERE student_id='G402240108'), 'DHCP 动态主机配置', 82.00), ((SELECT id FROM users WHERE student_id='G402240108'), '静态路由配置', 58.00), ((SELECT id FROM users WHERE student_id='G402240108'), '帧中继与 PPPoE', 26.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240109'), 'BFD 双向转发检测', 22.00), ((SELECT id FROM users WHERE student_id='G402240109'), '组播技术', 23.00), ((SELECT id FROM users WHERE student_id='G402240109'), 'ISIS 路由协议', 30.00), ((SELECT id FROM users WHERE student_id='G402240109'), 'DNS 域名解析', 58.00), ((SELECT id FROM users WHERE student_id='G402240109'), 'VLAN 划分与配置', 91.00), ((SELECT id FROM users WHERE student_id='G402240109'), 'BGP 路由协议', 24.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240110'), 'RSTP/MSTP', 32.00), ((SELECT id FROM users WHERE student_id='G402240110'), 'QoS 流量整形', 63.00), ((SELECT id FROM users WHERE student_id='G402240110'), '策略路由', 45.00), ((SELECT id FROM users WHERE student_id='G402240110'), 'OSPF 邻居与区域', 36.00), ((SELECT id FROM users WHERE student_id='G402240110'), 'OSI 七层模型', 61.00), ((SELECT id FROM users WHERE student_id='G402240110'), 'ACL 访问控制列表', 42.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240111'), '策略路由', 41.00), ((SELECT id FROM users WHERE student_id='G402240111'), 'DHCP Snooping', 28.00), ((SELECT id FROM users WHERE student_id='G402240111'), 'ACL 访问控制列表', 85.00), ((SELECT id FROM users WHERE student_id='G402240111'), 'TCP/IP 协议栈', 53.00), ((SELECT id FROM users WHERE student_id='G402240111'), 'DHCP 动态主机配置', 57.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240112'), 'IPv6 过渡技术', 37.00), ((SELECT id FROM users WHERE student_id='G402240112'), 'QoS 流量整形', 40.00), ((SELECT id FROM users WHERE student_id='G402240112'), 'DHCP 动态主机配置', 57.00), ((SELECT id FROM users WHERE student_id='G402240112'), 'TCP/IP 协议栈', 52.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240113'), 'ISIS 路由协议', 19.00), ((SELECT id FROM users WHERE student_id='G402240113'), 'QoS 流量整形', 37.00), ((SELECT id FROM users WHERE student_id='G402240113'), 'BFD 双向转发检测', 22.00), ((SELECT id FROM users WHERE student_id='G402240113'), 'OSPF 邻居与区域', 25.00), ((SELECT id FROM users WHERE student_id='G402240113'), 'VLAN 划分与配置', 86.00), ((SELECT id FROM users WHERE student_id='G402240113'), 'STP 生成树协议', 42.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240114'), 'OSPF 高级特性', 68.00), ((SELECT id FROM users WHERE student_id='G402240114'), 'VRRP 双机热备', 62.00), ((SELECT id FROM users WHERE student_id='G402240114'), 'Eth-Trunk 链路聚合', 85.00), ((SELECT id FROM users WHERE student_id='G402240114'), 'HDLC 与 PPP 封装', 41.00), ((SELECT id FROM users WHERE student_id='G402240114'), 'DNS 域名解析', 61.00), ((SELECT id FROM users WHERE student_id='G402240114'), '静态路由配置', 64.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240115'), 'BGP 高级特性', 24.00), ((SELECT id FROM users WHERE student_id='G402240115'), 'VRRP 双机热备', 35.00), ((SELECT id FROM users WHERE student_id='G402240115'), 'BGP 路由协议', 23.00), ((SELECT id FROM users WHERE student_id='G402240115'), 'DNS 域名解析', 61.00), ((SELECT id FROM users WHERE student_id='G402240115'), '帧中继与 PPPoE', 24.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240116'), 'VRRP 双机热备', 31.00), ((SELECT id FROM users WHERE student_id='G402240116'), 'OSPF 高级特性', 71.00), ((SELECT id FROM users WHERE student_id='G402240116'), 'BGP 高级特性', 24.00), ((SELECT id FROM users WHERE student_id='G402240116'), 'TCP/IP 协议栈', 53.00), ((SELECT id FROM users WHERE student_id='G402240116'), 'HDLC 与 PPP 封装', 34.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240117'), '策略路由', 39.00), ((SELECT id FROM users WHERE student_id='G402240117'), 'RSTP/MSTP', 37.00), ((SELECT id FROM users WHERE student_id='G402240117'), 'IP 地址与子网划分', 90.00), ((SELECT id FROM users WHERE student_id='G402240117'), '帧中继与 PPPoE', 64.00), ((SELECT id FROM users WHERE student_id='G402240117'), 'HDLC 与 PPP 封装', 49.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240120'), 'BFD 双向转发检测', 19.00), ((SELECT id FROM users WHERE student_id='G402240120'), 'DHCP Snooping', 31.00), ((SELECT id FROM users WHERE student_id='G402240120'), 'DHCP 动态主机配置', 88.00), ((SELECT id FROM users WHERE student_id='G402240120'), 'DNS 域名解析', 65.00), ((SELECT id FROM users WHERE student_id='G402240120'), 'HDLC 与 PPP 封装', 77.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240121'), 'DHCP Snooping', 20.00), ((SELECT id FROM users WHERE student_id='G402240121'), 'BFD 双向转发检测', 56.00), ((SELECT id FROM users WHERE student_id='G402240121'), 'BGP 路由协议', 29.00), ((SELECT id FROM users WHERE student_id='G402240121'), 'STP 生成树协议', 27.00), ((SELECT id FROM users WHERE student_id='G402240121'), '静态路由配置', 63.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240122'), 'IPv6 过渡技术', 40.00), ((SELECT id FROM users WHERE student_id='G402240122'), 'MPLS VPN 原理', 18.00), ((SELECT id FROM users WHERE student_id='G402240122'), 'DNS 域名解析', 85.00), ((SELECT id FROM users WHERE student_id='G402240122'), 'VRP 操作系统基础', 86.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240123'), 'DHCP Snooping', 24.00), ((SELECT id FROM users WHERE student_id='G402240123'), 'BFD 双向转发检测', 33.00), ((SELECT id FROM users WHERE student_id='G402240123'), 'IPv6 过渡技术', 27.00), ((SELECT id FROM users WHERE student_id='G402240123'), 'IP 地址与子网划分', 40.00), ((SELECT id FROM users WHERE student_id='G402240123'), 'BGP 路由协议', 20.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240124'), 'BGP 高级特性', 65.00), ((SELECT id FROM users WHERE student_id='G402240124'), '策略路由', 35.00), ((SELECT id FROM users WHERE student_id='G402240124'), 'DHCP Snooping', 26.00), ((SELECT id FROM users WHERE student_id='G402240124'), 'HDLC 与 PPP 封装', 39.00), ((SELECT id FROM users WHERE student_id='G402240124'), 'QoS 流量整形', 15.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240125'), 'Eth-Trunk 链路聚合', 42.00), ((SELECT id FROM users WHERE student_id='G402240125'), 'QoS 流量整形', 37.00), ((SELECT id FROM users WHERE student_id='G402240125'), 'OSPF 邻居与区域', 84.00), ((SELECT id FROM users WHERE student_id='G402240125'), 'OSI 七层模型', 60.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240126'), 'IPv6 过渡技术', 22.00), ((SELECT id FROM users WHERE student_id='G402240126'), 'VRRP 双机热备', 25.00), ((SELECT id FROM users WHERE student_id='G402240126'), 'TCP/IP 协议栈', 59.00), ((SELECT id FROM users WHERE student_id='G402240126'), '静态路由配置', 86.00), ((SELECT id FROM users WHERE student_id='G402240126'), 'BGP 路由协议', 29.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240127'), 'RSTP/MSTP', 71.00), ((SELECT id FROM users WHERE student_id='G402240127'), 'Eth-Trunk 链路聚合', 46.00), ((SELECT id FROM users WHERE student_id='G402240127'), 'HDLC 与 PPP 封装', 39.00), ((SELECT id FROM users WHERE student_id='G402240127'), 'OSPF 邻居与区域', 22.00), ((SELECT id FROM users WHERE student_id='G402240127'), 'BGP 路由协议', 22.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240128'), 'Eth-Trunk 链路聚合', 43.00), ((SELECT id FROM users WHERE student_id='G402240128'), 'BFD 双向转发检测', 19.00), ((SELECT id FROM users WHERE student_id='G402240128'), 'NAT 地址转换', 41.00), ((SELECT id FROM users WHERE student_id='G402240128'), 'OSPF 邻居与区域', 30.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240129'), 'MPLS VPN 原理', 60.00), ((SELECT id FROM users WHERE student_id='G402240129'), 'IPv6 过渡技术', 61.00), ((SELECT id FROM users WHERE student_id='G402240129'), 'ACL 访问控制列表', 25.00), ((SELECT id FROM users WHERE student_id='G402240129'), 'OSI 七层模型', 63.00), ((SELECT id FROM users WHERE student_id='G402240129'), 'QoS 流量整形', 28.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240133'), 'ISIS 路由协议', 18.00), ((SELECT id FROM users WHERE student_id='G402240133'), 'RSTP/MSTP', 39.00), ((SELECT id FROM users WHERE student_id='G402240133'), 'MPLS VPN 原理', 30.00), ((SELECT id FROM users WHERE student_id='G402240133'), 'QoS 流量整形', 22.00), ((SELECT id FROM users WHERE student_id='G402240133'), 'HDLC 与 PPP 封装', 37.00), ((SELECT id FROM users WHERE student_id='G402240133'), 'DHCP 动态主机配置', 43.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240134'), 'ISIS 路由协议', 32.00), ((SELECT id FROM users WHERE student_id='G402240134'), 'Eth-Trunk 链路聚合', 49.00), ((SELECT id FROM users WHERE student_id='G402240134'), 'BFD 双向转发检测', 30.00), ((SELECT id FROM users WHERE student_id='G402240134'), 'BGP 路由协议', 24.00), ((SELECT id FROM users WHERE student_id='G402240134'), 'VRP 操作系统基础', 52.00), ((SELECT id FROM users WHERE student_id='G402240134'), 'QoS 流量整形', 34.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240135'), 'RSTP/MSTP', 71.00), ((SELECT id FROM users WHERE student_id='G402240135'), 'MPLS VPN 原理', 51.00), ((SELECT id FROM users WHERE student_id='G402240135'), 'DHCP Snooping', 24.00), ((SELECT id FROM users WHERE student_id='G402240135'), 'BGP 路由协议', 34.00), ((SELECT id FROM users WHERE student_id='G402240135'), '帧中继与 PPPoE', 66.00), ((SELECT id FROM users WHERE student_id='G402240135'), 'QoS 流量整形', 63.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240136'), 'BGP 高级特性', 15.00), ((SELECT id FROM users WHERE student_id='G402240136'), 'DHCP Snooping', 25.00), ((SELECT id FROM users WHERE student_id='G402240136'), 'DNS 域名解析', 60.00), ((SELECT id FROM users WHERE student_id='G402240136'), 'IP 地址与子网划分', 43.00), ((SELECT id FROM users WHERE student_id='G402240136'), 'HDLC 与 PPP 封装', 32.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240137'), 'MPLS VPN 原理', 30.00), ((SELECT id FROM users WHERE student_id='G402240137'), '策略路由', 32.00), ((SELECT id FROM users WHERE student_id='G402240137'), 'RSTP/MSTP', 27.00), ((SELECT id FROM users WHERE student_id='G402240137'), 'ACL 访问控制列表', 39.00), ((SELECT id FROM users WHERE student_id='G402240137'), 'TCP/IP 协议栈', 64.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240138'), 'RSTP/MSTP', 28.00), ((SELECT id FROM users WHERE student_id='G402240138'), 'OSPF 高级特性', 25.00), ((SELECT id FROM users WHERE student_id='G402240138'), '组播技术', 30.00), ((SELECT id FROM users WHERE student_id='G402240138'), 'DNS 域名解析', 87.00), ((SELECT id FROM users WHERE student_id='G402240138'), 'QoS 流量整形', 55.00), ((SELECT id FROM users WHERE student_id='G402240138'), '帧中继与 PPPoE', 60.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240139'), 'RSTP/MSTP', 29.00), ((SELECT id FROM users WHERE student_id='G402240139'), 'DHCP Snooping', 26.00), ((SELECT id FROM users WHERE student_id='G402240139'), '组播技术', 12.00), ((SELECT id FROM users WHERE student_id='G402240139'), 'IP 地址与子网划分', 46.00), ((SELECT id FROM users WHERE student_id='G402240139'), 'QoS 流量整形', 16.00), ((SELECT id FROM users WHERE student_id='G402240139'), '帧中继与 PPPoE', 33.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240140'), '组播技术', 45.00), ((SELECT id FROM users WHERE student_id='G402240140'), 'Eth-Trunk 链路聚合', 48.00), ((SELECT id FROM users WHERE student_id='G402240140'), 'MPLS VPN 原理', 16.00), ((SELECT id FROM users WHERE student_id='G402240140'), 'STP 生成树协议', 42.00), ((SELECT id FROM users WHERE student_id='G402240140'), 'DHCP 动态主机配置', 44.00), ((SELECT id FROM users WHERE student_id='G402240140'), 'ACL 访问控制列表', 25.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240141'), 'BFD 双向转发检测', 25.00), ((SELECT id FROM users WHERE student_id='G402240141'), 'IPv6 过渡技术', 20.00), ((SELECT id FROM users WHERE student_id='G402240141'), 'VLAN 划分与配置', 87.00), ((SELECT id FROM users WHERE student_id='G402240141'), 'DHCP 动态主机配置', 60.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240144'), 'ISIS 路由协议', 35.00), ((SELECT id FROM users WHERE student_id='G402240144'), 'OSPF 高级特性', 69.00), ((SELECT id FROM users WHERE student_id='G402240144'), 'NAT 地址转换', 47.00), ((SELECT id FROM users WHERE student_id='G402240144'), 'VRP 操作系统基础', 59.00), ((SELECT id FROM users WHERE student_id='G402240144'), 'VLAN 划分与配置', 85.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240145'), 'BGP 高级特性', 32.00), ((SELECT id FROM users WHERE student_id='G402240145'), 'RSTP/MSTP', 66.00), ((SELECT id FROM users WHERE student_id='G402240145'), 'QoS 流量整形', 69.00), ((SELECT id FROM users WHERE student_id='G402240145'), 'HDLC 与 PPP 封装', 84.00), ((SELECT id FROM users WHERE student_id='G402240145'), 'DHCP 动态主机配置', 40.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240146'), 'IPv6 过渡技术', 35.00), ((SELECT id FROM users WHERE student_id='G402240146'), '策略路由', 33.00), ((SELECT id FROM users WHERE student_id='G402240146'), 'OSPF 高级特性', 22.00), ((SELECT id FROM users WHERE student_id='G402240146'), 'VRP 操作系统基础', 54.00), ((SELECT id FROM users WHERE student_id='G402240146'), 'HDLC 与 PPP 封装', 79.00), ((SELECT id FROM users WHERE student_id='G402240146'), 'STP 生成树协议', 41.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240148'), 'VRRP 双机热备', 26.00), ((SELECT id FROM users WHERE student_id='G402240148'), 'QoS 流量整形', 22.00), ((SELECT id FROM users WHERE student_id='G402240148'), 'BGP 高级特性', 34.00), ((SELECT id FROM users WHERE student_id='G402240148'), 'TCP/IP 协议栈', 56.00), ((SELECT id FROM users WHERE student_id='G402240148'), 'NAT 地址转换', 44.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240149'), '策略路由', 27.00), ((SELECT id FROM users WHERE student_id='G402240149'), 'BFD 双向转发检测', 32.00), ((SELECT id FROM users WHERE student_id='G402240149'), '帧中继与 PPPoE', 38.00), ((SELECT id FROM users WHERE student_id='G402240149'), '静态路由配置', 56.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240150'), 'ISIS 路由协议', 27.00), ((SELECT id FROM users WHERE student_id='G402240150'), 'BGP 高级特性', 30.00), ((SELECT id FROM users WHERE student_id='G402240150'), 'NAT 地址转换', 41.00), ((SELECT id FROM users WHERE student_id='G402240150'), 'VLAN 划分与配置', 46.00), ((SELECT id FROM users WHERE student_id='G402240150'), 'OSPF 邻居与区域', 33.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240151'), 'BFD 双向转发检测', 50.00), ((SELECT id FROM users WHERE student_id='G402240151'), 'IPv6 过渡技术', 32.00), ((SELECT id FROM users WHERE student_id='G402240151'), 'NAT 地址转换', 38.00), ((SELECT id FROM users WHERE student_id='G402240151'), 'BGP 路由协议', 17.00), ((SELECT id FROM users WHERE student_id='G402240151'), 'VLAN 划分与配置', 46.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240152'), 'RSTP/MSTP', 36.00), ((SELECT id FROM users WHERE student_id='G402240152'), '组播技术', 54.00), ((SELECT id FROM users WHERE student_id='G402240152'), 'Eth-Trunk 链路聚合', 30.00), ((SELECT id FROM users WHERE student_id='G402240152'), 'TCP/IP 协议栈', 58.00), ((SELECT id FROM users WHERE student_id='G402240152'), 'HDLC 与 PPP 封装', 47.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240153'), 'BGP 高级特性', 32.00), ((SELECT id FROM users WHERE student_id='G402240153'), 'ISIS 路由协议', 30.00), ((SELECT id FROM users WHERE student_id='G402240153'), '组播技术', 53.00), ((SELECT id FROM users WHERE student_id='G402240153'), 'OSPF 邻居与区域', 29.00), ((SELECT id FROM users WHERE student_id='G402240153'), 'OSI 七层模型', 63.00), ((SELECT id FROM users WHERE student_id='G402240153'), 'STP 生成树协议', 27.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240154'), 'ISIS 路由协议', 21.00), ((SELECT id FROM users WHERE student_id='G402240154'), 'QoS 流量整形', 30.00), ((SELECT id FROM users WHERE student_id='G402240154'), 'QoS 流量整形', 31.00), ((SELECT id FROM users WHERE student_id='G402240154'), '帧中继与 PPPoE', 64.00), ((SELECT id FROM users WHERE student_id='G402240154'), 'ACL 访问控制列表', 29.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240201'), 'QoS 流量整形', 38.00), ((SELECT id FROM users WHERE student_id='G402240201'), 'VRRP 双机热备', 32.00), ((SELECT id FROM users WHERE student_id='G402240201'), 'DHCP 动态主机配置', 43.00), ((SELECT id FROM users WHERE student_id='G402240201'), 'QoS 流量整形', 59.00), ((SELECT id FROM users WHERE student_id='G402240201'), 'VLAN 划分与配置', 40.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240202'), 'IPv6 过渡技术', 40.00), ((SELECT id FROM users WHERE student_id='G402240202'), 'VRRP 双机热备', 22.00), ((SELECT id FROM users WHERE student_id='G402240202'), 'QoS 流量整形', 30.00), ((SELECT id FROM users WHERE student_id='G402240202'), 'VRP 操作系统基础', 64.00), ((SELECT id FROM users WHERE student_id='G402240202'), 'HDLC 与 PPP 封装', 42.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240203'), 'Eth-Trunk 链路聚合', 30.00), ((SELECT id FROM users WHERE student_id='G402240203'), '组播技术', 24.00), ((SELECT id FROM users WHERE student_id='G402240203'), 'STP 生成树协议', 35.00), ((SELECT id FROM users WHERE student_id='G402240203'), 'BGP 路由协议', 32.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240204'), '策略路由', 27.00), ((SELECT id FROM users WHERE student_id='G402240204'), 'DHCP Snooping', 26.00), ((SELECT id FROM users WHERE student_id='G402240204'), 'BGP 高级特性', 34.00), ((SELECT id FROM users WHERE student_id='G402240204'), 'IP 地址与子网划分', 87.00), ((SELECT id FROM users WHERE student_id='G402240204'), 'DHCP 动态主机配置', 83.00), ((SELECT id FROM users WHERE student_id='G402240204'), 'OSI 七层模型', 60.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240205'), 'MPLS VPN 原理', 19.00), ((SELECT id FROM users WHERE student_id='G402240205'), 'IPv6 过渡技术', 31.00), ((SELECT id FROM users WHERE student_id='G402240205'), '策略路由', 39.00), ((SELECT id FROM users WHERE student_id='G402240205'), 'VRP 操作系统基础', 58.00), ((SELECT id FROM users WHERE student_id='G402240205'), 'ACL 访问控制列表', 37.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240206'), '组播技术', 15.00), ((SELECT id FROM users WHERE student_id='G402240206'), 'MPLS VPN 原理', 25.00), ((SELECT id FROM users WHERE student_id='G402240206'), 'VRRP 双机热备', 27.00), ((SELECT id FROM users WHERE student_id='G402240206'), 'DNS 域名解析', 59.00), ((SELECT id FROM users WHERE student_id='G402240206'), 'HDLC 与 PPP 封装', 33.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240207'), 'Eth-Trunk 链路聚合', 85.00), ((SELECT id FROM users WHERE student_id='G402240207'), 'DHCP Snooping', 28.00), ((SELECT id FROM users WHERE student_id='G402240207'), '帧中继与 PPPoE', 23.00), ((SELECT id FROM users WHERE student_id='G402240207'), 'DNS 域名解析', 65.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240209'), 'DHCP Snooping', 23.00), ((SELECT id FROM users WHERE student_id='G402240209'), 'RSTP/MSTP', 34.00), ((SELECT id FROM users WHERE student_id='G402240209'), 'NAT 地址转换', 32.00), ((SELECT id FROM users WHERE student_id='G402240209'), 'VRP 操作系统基础', 50.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240210'), 'BFD 双向转发检测', 19.00), ((SELECT id FROM users WHERE student_id='G402240210'), 'DHCP Snooping', 55.00), ((SELECT id FROM users WHERE student_id='G402240210'), 'MPLS VPN 原理', 21.00), ((SELECT id FROM users WHERE student_id='G402240210'), 'OSPF 邻居与区域', 39.00), ((SELECT id FROM users WHERE student_id='G402240210'), 'HDLC 与 PPP 封装', 76.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240211'), 'BFD 双向转发检测', 18.00), ((SELECT id FROM users WHERE student_id='G402240211'), 'MPLS VPN 原理', 16.00), ((SELECT id FROM users WHERE student_id='G402240211'), 'Eth-Trunk 链路聚合', 33.00), ((SELECT id FROM users WHERE student_id='G402240211'), '帧中继与 PPPoE', 24.00), ((SELECT id FROM users WHERE student_id='G402240211'), 'ACL 访问控制列表', 80.00), ((SELECT id FROM users WHERE student_id='G402240211'), '静态路由配置', 64.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240212'), 'BFD 双向转发检测', 20.00), ((SELECT id FROM users WHERE student_id='G402240212'), 'Eth-Trunk 链路聚合', 35.00), ((SELECT id FROM users WHERE student_id='G402240212'), 'DNS 域名解析', 64.00), ((SELECT id FROM users WHERE student_id='G402240212'), 'ACL 访问控制列表', 45.00), ((SELECT id FROM users WHERE student_id='G402240212'), 'STP 生成树协议', 45.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240215'), 'ISIS 路由协议', 29.00), ((SELECT id FROM users WHERE student_id='G402240215'), 'BGP 高级特性', 27.00), ((SELECT id FROM users WHERE student_id='G402240215'), 'Eth-Trunk 链路聚合', 50.00), ((SELECT id FROM users WHERE student_id='G402240215'), 'IP 地址与子网划分', 49.00), ((SELECT id FROM users WHERE student_id='G402240215'), 'ACL 访问控制列表', 27.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240216'), 'DHCP Snooping', 30.00), ((SELECT id FROM users WHERE student_id='G402240216'), 'VRRP 双机热备', 31.00), ((SELECT id FROM users WHERE student_id='G402240216'), 'TCP/IP 协议栈', 87.00), ((SELECT id FROM users WHERE student_id='G402240216'), 'BGP 路由协议', 30.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240217'), 'BGP 高级特性', 68.00), ((SELECT id FROM users WHERE student_id='G402240217'), '组播技术', 29.00), ((SELECT id FROM users WHERE student_id='G402240217'), 'IPv6 过渡技术', 30.00), ((SELECT id FROM users WHERE student_id='G402240217'), 'BGP 路由协议', 16.00), ((SELECT id FROM users WHERE student_id='G402240217'), 'OSI 七层模型', 61.00), ((SELECT id FROM users WHERE student_id='G402240217'), 'STP 生成树协议', 45.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240218'), 'Eth-Trunk 链路聚合', 84.00), ((SELECT id FROM users WHERE student_id='G402240218'), 'DHCP Snooping', 60.00), ((SELECT id FROM users WHERE student_id='G402240218'), 'OSPF 高级特性', 71.00), ((SELECT id FROM users WHERE student_id='G402240218'), 'HDLC 与 PPP 封装', 42.00), ((SELECT id FROM users WHERE student_id='G402240218'), 'STP 生成树协议', 32.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240219'), 'IPv6 过渡技术', 29.00), ((SELECT id FROM users WHERE student_id='G402240219'), 'MPLS VPN 原理', 56.00), ((SELECT id FROM users WHERE student_id='G402240219'), 'BGP 高级特性', 63.00), ((SELECT id FROM users WHERE student_id='G402240219'), 'NAT 地址转换', 45.00), ((SELECT id FROM users WHERE student_id='G402240219'), 'DNS 域名解析', 65.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240220'), 'ISIS 路由协议', 22.00), ((SELECT id FROM users WHERE student_id='G402240220'), 'VRRP 双机热备', 39.00), ((SELECT id FROM users WHERE student_id='G402240220'), 'OSI 七层模型', 60.00), ((SELECT id FROM users WHERE student_id='G402240220'), 'VRP 操作系统基础', 53.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240221'), 'RSTP/MSTP', 73.00), ((SELECT id FROM users WHERE student_id='G402240221'), 'OSPF 高级特性', 29.00), ((SELECT id FROM users WHERE student_id='G402240221'), 'BGP 路由协议', 66.00), ((SELECT id FROM users WHERE student_id='G402240221'), 'VRP 操作系统基础', 88.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240222'), 'IPv6 过渡技术', 23.00), ((SELECT id FROM users WHERE student_id='G402240222'), 'DHCP Snooping', 17.00), ((SELECT id FROM users WHERE student_id='G402240222'), '静态路由配置', 59.00), ((SELECT id FROM users WHERE student_id='G402240222'), 'BGP 路由协议', 60.00), ((SELECT id FROM users WHERE student_id='G402240222'), 'VLAN 划分与配置', 92.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240224'), 'BGP 高级特性', 24.00), ((SELECT id FROM users WHERE student_id='G402240224'), 'OSPF 高级特性', 69.00), ((SELECT id FROM users WHERE student_id='G402240224'), '静态路由配置', 56.00), ((SELECT id FROM users WHERE student_id='G402240224'), 'HDLC 与 PPP 封装', 43.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240225'), 'Eth-Trunk 链路聚合', 78.00), ((SELECT id FROM users WHERE student_id='G402240225'), 'MPLS VPN 原理', 26.00), ((SELECT id FROM users WHERE student_id='G402240225'), 'VRRP 双机热备', 34.00), ((SELECT id FROM users WHERE student_id='G402240225'), 'BGP 路由协议', 32.00), ((SELECT id FROM users WHERE student_id='G402240225'), 'QoS 流量整形', 59.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240227'), 'Eth-Trunk 链路聚合', 41.00), ((SELECT id FROM users WHERE student_id='G402240227'), 'DHCP Snooping', 31.00), ((SELECT id FROM users WHERE student_id='G402240227'), 'STP 生成树协议', 44.00), ((SELECT id FROM users WHERE student_id='G402240227'), 'DNS 域名解析', 85.00), ((SELECT id FROM users WHERE student_id='G402240227'), 'TCP/IP 协议栈', 62.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240228'), 'IPv6 过渡技术', 36.00), ((SELECT id FROM users WHERE student_id='G402240228'), 'QoS 流量整形', 25.00), ((SELECT id FROM users WHERE student_id='G402240228'), 'OSI 七层模型', 65.00), ((SELECT id FROM users WHERE student_id='G402240228'), 'VRP 操作系统基础', 59.00), ((SELECT id FROM users WHERE student_id='G402240228'), 'IP 地址与子网划分', 36.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240230'), 'VRRP 双机热备', 22.00), ((SELECT id FROM users WHERE student_id='G402240230'), 'MPLS VPN 原理', 60.00), ((SELECT id FROM users WHERE student_id='G402240230'), 'QoS 流量整形', 32.00), ((SELECT id FROM users WHERE student_id='G402240230'), 'HDLC 与 PPP 封装', 38.00), ((SELECT id FROM users WHERE student_id='G402240230'), 'OSI 七层模型', 63.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240231'), 'OSPF 高级特性', 25.00), ((SELECT id FROM users WHERE student_id='G402240231'), 'MPLS VPN 原理', 30.00), ((SELECT id FROM users WHERE student_id='G402240231'), '策略路由', 42.00), ((SELECT id FROM users WHERE student_id='G402240231'), 'DNS 域名解析', 92.00), ((SELECT id FROM users WHERE student_id='G402240231'), 'OSPF 邻居与区域', 85.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240232'), 'ISIS 路由协议', 15.00), ((SELECT id FROM users WHERE student_id='G402240232'), '策略路由', 27.00), ((SELECT id FROM users WHERE student_id='G402240232'), 'HDLC 与 PPP 封装', 35.00), ((SELECT id FROM users WHERE student_id='G402240232'), '静态路由配置', 88.00), ((SELECT id FROM users WHERE student_id='G402240232'), 'QoS 流量整形', 34.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240233'), 'DHCP Snooping', 56.00), ((SELECT id FROM users WHERE student_id='G402240233'), '策略路由', 30.00), ((SELECT id FROM users WHERE student_id='G402240233'), 'Eth-Trunk 链路聚合', 33.00), ((SELECT id FROM users WHERE student_id='G402240233'), 'QoS 流量整形', 35.00), ((SELECT id FROM users WHERE student_id='G402240233'), 'HDLC 与 PPP 封装', 34.00), ((SELECT id FROM users WHERE student_id='G402240233'), 'BGP 路由协议', 31.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240234'), 'BFD 双向转发检测', 24.00), ((SELECT id FROM users WHERE student_id='G402240234'), '策略路由', 30.00), ((SELECT id FROM users WHERE student_id='G402240234'), 'IP 地址与子网划分', 43.00), ((SELECT id FROM users WHERE student_id='G402240234'), 'STP 生成树协议', 44.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240235'), 'MPLS VPN 原理', 54.00), ((SELECT id FROM users WHERE student_id='G402240235'), 'QoS 流量整形', 69.00), ((SELECT id FROM users WHERE student_id='G402240235'), 'HDLC 与 PPP 封装', 50.00), ((SELECT id FROM users WHERE student_id='G402240235'), 'OSPF 邻居与区域', 40.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240236'), '组播技术', 19.00), ((SELECT id FROM users WHERE student_id='G402240236'), 'VRRP 双机热备', 34.00), ((SELECT id FROM users WHERE student_id='G402240236'), 'IPv6 过渡技术', 29.00), ((SELECT id FROM users WHERE student_id='G402240236'), 'DNS 域名解析', 56.00), ((SELECT id FROM users WHERE student_id='G402240236'), 'TCP/IP 协议栈', 65.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240237'), 'DHCP Snooping', 35.00), ((SELECT id FROM users WHERE student_id='G402240237'), '组播技术', 20.00), ((SELECT id FROM users WHERE student_id='G402240237'), 'BFD 双向转发检测', 29.00), ((SELECT id FROM users WHERE student_id='G402240237'), 'VLAN 划分与配置', 90.00), ((SELECT id FROM users WHERE student_id='G402240237'), '帧中继与 PPPoE', 22.00), ((SELECT id FROM users WHERE student_id='G402240237'), 'OSI 七层模型', 60.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240238'), 'RSTP/MSTP', 68.00), ((SELECT id FROM users WHERE student_id='G402240238'), 'Eth-Trunk 链路聚合', 50.00), ((SELECT id FROM users WHERE student_id='G402240238'), 'BGP 路由协议', 34.00), ((SELECT id FROM users WHERE student_id='G402240238'), 'IP 地址与子网划分', 50.00), ((SELECT id FROM users WHERE student_id='G402240238'), 'STP 生成树协议', 31.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240239'), 'VRRP 双机热备', 38.00), ((SELECT id FROM users WHERE student_id='G402240239'), 'IPv6 过渡技术', 36.00), ((SELECT id FROM users WHERE student_id='G402240239'), 'QoS 流量整形', 68.00), ((SELECT id FROM users WHERE student_id='G402240239'), 'STP 生成树协议', 39.00), ((SELECT id FROM users WHERE student_id='G402240239'), 'TCP/IP 协议栈', 60.00), ((SELECT id FROM users WHERE student_id='G402240239'), 'QoS 流量整形', 31.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240240'), 'Eth-Trunk 链路聚合', 47.00), ((SELECT id FROM users WHERE student_id='G402240240'), 'MPLS VPN 原理', 21.00), ((SELECT id FROM users WHERE student_id='G402240240'), 'BGP 高级特性', 65.00), ((SELECT id FROM users WHERE student_id='G402240240'), 'TCP/IP 协议栈', 58.00), ((SELECT id FROM users WHERE student_id='G402240240'), 'BGP 路由协议', 19.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240241'), 'QoS 流量整形', 35.00), ((SELECT id FROM users WHERE student_id='G402240241'), 'MPLS VPN 原理', 29.00), ((SELECT id FROM users WHERE student_id='G402240241'), 'DHCP Snooping', 35.00), ((SELECT id FROM users WHERE student_id='G402240241'), 'STP 生成树协议', 42.00), ((SELECT id FROM users WHERE student_id='G402240241'), 'IP 地址与子网划分', 39.00), ((SELECT id FROM users WHERE student_id='G402240241'), 'HDLC 与 PPP 封装', 78.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240242'), 'BFD 双向转发检测', 35.00), ((SELECT id FROM users WHERE student_id='G402240242'), 'RSTP/MSTP', 26.00), ((SELECT id FROM users WHERE student_id='G402240242'), 'HDLC 与 PPP 封装', 47.00), ((SELECT id FROM users WHERE student_id='G402240242'), '帧中继与 PPPoE', 61.00), ((SELECT id FROM users WHERE student_id='G402240242'), 'IP 地址与子网划分', 47.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240243'), '组播技术', 19.00), ((SELECT id FROM users WHERE student_id='G402240243'), 'RSTP/MSTP', 45.00), ((SELECT id FROM users WHERE student_id='G402240243'), 'ACL 访问控制列表', 77.00), ((SELECT id FROM users WHERE student_id='G402240243'), 'NAT 地址转换', 46.00), ((SELECT id FROM users WHERE student_id='G402240243'), 'BGP 路由协议', 28.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240244'), 'IPv6 过渡技术', 26.00), ((SELECT id FROM users WHERE student_id='G402240244'), '组播技术', 18.00), ((SELECT id FROM users WHERE student_id='G402240244'), 'BGP 高级特性', 62.00), ((SELECT id FROM users WHERE student_id='G402240244'), 'OSPF 邻居与区域', 22.00), ((SELECT id FROM users WHERE student_id='G402240244'), 'VRP 操作系统基础', 63.00), ((SELECT id FROM users WHERE student_id='G402240244'), 'BGP 路由协议', 21.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240245'), 'BFD 双向转发检测', 24.00), ((SELECT id FROM users WHERE student_id='G402240245'), 'RSTP/MSTP', 45.00), ((SELECT id FROM users WHERE student_id='G402240245'), 'DNS 域名解析', 56.00), ((SELECT id FROM users WHERE student_id='G402240245'), 'VRP 操作系统基础', 60.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240247'), 'VRRP 双机热备', 29.00), ((SELECT id FROM users WHERE student_id='G402240247'), '策略路由', 71.00), ((SELECT id FROM users WHERE student_id='G402240247'), 'OSI 七层模型', 65.00), ((SELECT id FROM users WHERE student_id='G402240247'), 'DHCP 动态主机配置', 81.00), ((SELECT id FROM users WHERE student_id='G402240247'), 'OSPF 邻居与区域', 35.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240248'), '策略路由', 38.00), ((SELECT id FROM users WHERE student_id='G402240248'), 'IPv6 过渡技术', 38.00), ((SELECT id FROM users WHERE student_id='G402240248'), 'VRRP 双机热备', 24.00), ((SELECT id FROM users WHERE student_id='G402240248'), 'VRP 操作系统基础', 58.00), ((SELECT id FROM users WHERE student_id='G402240248'), 'DHCP 动态主机配置', 60.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240250'), 'BGP 高级特性', 19.00), ((SELECT id FROM users WHERE student_id='G402240250'), 'BFD 双向转发检测', 56.00), ((SELECT id FROM users WHERE student_id='G402240250'), 'ACL 访问控制列表', 37.00), ((SELECT id FROM users WHERE student_id='G402240250'), 'IP 地址与子网划分', 37.00), ((SELECT id FROM users WHERE student_id='G402240250'), 'HDLC 与 PPP 封装', 44.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240251'), 'BGP 高级特性', 70.00), ((SELECT id FROM users WHERE student_id='G402240251'), 'RSTP/MSTP', 34.00), ((SELECT id FROM users WHERE student_id='G402240251'), 'MPLS VPN 原理', 27.00), ((SELECT id FROM users WHERE student_id='G402240251'), 'IP 地址与子网划分', 40.00), ((SELECT id FROM users WHERE student_id='G402240251'), 'OSI 七层模型', 60.00), ((SELECT id FROM users WHERE student_id='G402240251'), 'OSPF 邻居与区域', 31.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240252'), 'BFD 双向转发检测', 16.00), ((SELECT id FROM users WHERE student_id='G402240252'), 'OSPF 高级特性', 21.00), ((SELECT id FROM users WHERE student_id='G402240252'), 'IPv6 过渡技术', 24.00), ((SELECT id FROM users WHERE student_id='G402240252'), 'HDLC 与 PPP 封装', 84.00), ((SELECT id FROM users WHERE student_id='G402240252'), 'ACL 访问控制列表', 26.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G402240255'), 'ISIS 路由协议', 30.00), ((SELECT id FROM users WHERE student_id='G402240255'), 'IPv6 过渡技术', 62.00), ((SELECT id FROM users WHERE student_id='G402240255'), '静态路由配置', 63.00), ((SELECT id FROM users WHERE student_id='G402240255'), 'VRP 操作系统基础', 65.00), ((SELECT id FROM users WHERE student_id='G402240255'), 'IP 地址与子网划分', 32.00);
INSERT INTO knowledge_points (user_id, name, mastery_rate, created_at, updated_at)
VALUES ((SELECT id FROM users WHERE student_id='G503240109'), 'OSPF 高级特性', 22.00), ((SELECT id FROM users WHERE student_id='G503240109'), '策略路由', 40.00), ((SELECT id FROM users WHERE student_id='G503240109'), 'QoS 流量整形', 24.00), ((SELECT id FROM users WHERE student_id='G503240109'), 'VLAN 划分与配置', 42.00), ((SELECT id FROM users WHERE student_id='G503240109'), 'HDLC 与 PPP 封装', 49.00);-- =====================================================
-- 华为ICT智慧实训平台 - HCIA-Security 安全基础题目
-- 为第6套试卷（HCIA-Security 安全基础）添加10道题目
-- =====================================================

USE `huawei_ict`;

-- 先更新考试题量统计
UPDATE `exams` SET `question_count` = 10 WHERE `id` = 6;

-- 插入题目 (exam_id = 6)
INSERT IGNORE INTO `questions` (`exam_id`, `content`, `options`, `answer`, `type`) VALUES
(6, '防火墙安全策略的默认动作为以下哪项？', '{"A":"允许所有流量通过","B":"拒绝所有流量通过","C":"仅允许已建立连接的流量","D":"根据时间调度决定"}', 'B', 'SINGLE'),
(6, '以下关于状态检测防火墙的描述，正确的是？', '{"A":"只检查数据包头部，不维护连接状态","B":"基于会话状态进行检测，维护连接状态表","C":"只能检测应用层协议","D":"不需要考虑TCP三次握手状态"}', 'B', 'SINGLE'),
(6, '以下哪项属于典型的网络欺骗攻击？', '{"A":"ARP欺骗","B":"Ping of Death","C":"Teardrop攻击","D":"Land攻击"}', 'A', 'SINGLE'),
(6, 'IPSec VPN中用于数据加密的协议是？', '{"A":"AH","B":"ESP","C":"IKE","D":"ISAKMP"}', 'B', 'SINGLE'),
(6, '入侵防御系统(IPS)的主要工作方式是？', '{"A":"旁路监听，仅告警不拦截","B":"串联部署，实时检测并阻断恶意流量","C":"仅分析日志，不做实时处理","D":"被动接收告警信息"}', 'B', 'SINGLE'),
(6, '以下哪种加密算法属于非对称加密？', '{"A":"AES","B":"DES","C":"RSA","D":"SM4"}', 'C', 'SINGLE'),
(6, 'AAA认证架构中不包括以下哪个组件？', '{"A":"认证(Authentication)","B":"授权(Authorization)","C":"审计(Auditing)","D":"计费(Accounting)"}', 'C', 'SINGLE'),
(6, '华为防火墙中，以下哪个安全区域的优先级最高？', '{"A":"Trust区域","B":"Untrust区域","C":"DMZ区域","D":"Local区域"}', 'D', 'SINGLE'),
(6, '以下哪种攻击方式属于DDoS攻击？', '{"A":"SQL注入","B":"XSS跨站脚本","C":"SYN Flood","D":"口令暴力破解"}', 'C', 'SINGLE'),
(6, '包过滤防火墙工作在哪一层？', '{"A":"应用层","B":"传输层和网络层","C":"数据链路层","D":"物理层"}', 'B', 'SINGLE');
-- =====================================================
-- 华为ICT智慧实训平台 - 为所有考试补充题目
-- 确保每套考试至少10道题
-- =====================================================

USE `huawei_ict`;

-- =====================================================
-- 考试2: HCIA-Datacom 模拟卷（二）(exam_id=2)
-- =====================================================
INSERT IGNORE INTO `questions` (`exam_id`, `content`, `options`, `answer`, `type`) VALUES
(2, '以太网交换机中，MAC地址表的老化时间默认是？', '{"A":"60秒","B":"300秒","C":"600秒","D":"1800秒"}', 'B', 'SINGLE'),
(2, '以下哪种VLAN划分方式最灵活？', '{"A":"基于端口划分","B":"基于MAC地址划分","C":"基于IP子网划分","D":"基于协议划分"}', 'A', 'SINGLE'),
(2, 'STP协议中，端口从Blocking状态转换到Forwarding状态需要经过哪些状态？', '{"A":"Blocking→Listening→Learning→Forwarding","B":"Blocking→Learning→Listening→Forwarding","C":"Blocking→Forwarding","D":"Blocking→Listening→Forwarding"}', 'A', 'SINGLE'),
(2, '在华为交换机上，创建VLAN的命令是？', '{"A":"vlan batch","B":"create vlan","C":"vlan create","D":"add vlan"}', 'A', 'SINGLE'),
(2, 'Trunk链路上，缺省情况下允许哪些VLAN通过？', '{"A":"仅VLAN 1","B":"所有VLAN","C":"不允任何VLAN","D":"仅VLAN 4094"}', 'B', 'SINGLE'),
(2, '以下关于链路聚合的描述，错误的是？', '{"A":"可以增加带宽","B":"提供链路冗余","C":"需要手工配置所有参数","D":"可以在多条链路上负载分担"}', 'C', 'SINGLE'),
(2, 'DHCP服务器默认的租约期限是？', '{"A":"1小时","B":"1天","C":"7天","D":"30天"}', 'B', 'SINGLE'),
(2, '在华为路由器上，配置静态路由的命令是？', '{"A":"ip route-static","B":"ip route","C":"route add","D":"ip routing"}', 'A', 'SINGLE'),
(2, 'ACL规则中，通配符掩码0.0.0.0表示什么？', '{"A":"匹配所有地址","B":"匹配指定主机","C":"匹配所有主机","D":"不匹配任何地址"}', 'B', 'SINGLE'),
(2, 'SNMP协议中，用于主动上报告警的操作为？', '{"A":"Get","B":"Set","C":"Trap","D":"Response"}', 'C', 'SINGLE');

UPDATE `exams` SET `question_count` = 10 WHERE `id` = 2;

-- =====================================================
-- 考试3: HCIP-Datacom 模拟卷（一）(exam_id=3)
-- =====================================================
INSERT IGNORE INTO `questions` (`exam_id`, `content`, `options`, `answer`, `type`) VALUES
(3, 'OSPF协议中，哪类LSA用于描述区域内的路由器信息？', '{"A":"Type 1 LSA","B":"Type 2 LSA","C":"Type 3 LSA","D":"Type 5 LSA"}', 'A', 'SINGLE'),
(3, 'BGP协议中，IBGP对等体之间的最大跳数是多少？', '{"A":"1跳","B":"2跳","C":"255跳","D":"无限制"}', 'A', 'SINGLE'),
(3, 'IS-IS协议中，Level-1路由器可以学习到哪些路由？', '{"A":"本区域的路由","B":"所有区域的路由","C":"本区域和相邻区域的路由","D":"仅Level-2区域的路由"}', 'A', 'SINGLE'),
(3, 'MPLS标签的封装位置在？', '{"A":"二层帧头和三层IP头部之间","B":"IP头部之内","C":"二层帧头之前","D":"应用层数据之后"}', 'A', 'SINGLE'),
(3, 'VRRP协议中，Master设备的优先级范围是？', '{"A":"0-255","B":"1-254","C":"1-255","D":"0-254"}', 'B', 'SINGLE'),
(3, '以下关于QoS队列调度的描述，正确的是？', '{"A":"FIFO支持优先级区分","B":"PQ严格优先级队列可能导致低优先级队列饥饿","C":"WFQ不支持权重分配","D":"CBQ仅支持单一队列"}', 'B', 'SINGLE'),
(3, 'BGP选路规则中，以下哪项优先级最高？', '{"A":"Preferred-value最大","B":"Local-preference最大","C":"MED最小","D":"AS路径最短"}', 'A', 'SINGLE'),
(3, 'OSPF的虚连接(Virtual Link)通常用于解决？', '{"A":"区域0不连续的问题","B":"路由器性能不足","C":"链路带宽不够","D":"路由协议版本不兼容"}', 'A', 'SINGLE'),
(3, 'VXLAN技术中，VTEP设备的作用是？', '{"A":"封装和解封装VXLAN报文","B":"路由VXLAN流量","C":"过滤VXLAN数据","D":"加密VXLAN通信"}', 'A', 'SINGLE'),
(3, 'SDN架构中，控制层与转发层之间的接口是？', '{"A":"南向接口","B":"北向接口","C":"东西向接口","D":"管理接口"}', 'A', 'SINGLE');

UPDATE `exams` SET `question_count` = 10 WHERE `id` = 3;

-- =====================================================
-- 考试4: HCIE 实验模拟题 (exam_id=4)
-- =====================================================
INSERT IGNORE INTO `questions` (`exam_id`, `content`, `options`, `answer`, `type`) VALUES
(4, '华为CloudEngine交换机中，M-LAG技术的作用是？', '{"A":"实现跨设备链路聚合","B":"提供虚拟化技术","C":"实现网络虚拟化","D":"实现业务隔离"}', 'A', 'SINGLE'),
(4, 'Segment Routing中，SRv6使用的转发平面是？', '{"A":"IPv6数据平面","B":"IPv4数据平面","C":"MPLS数据平面","D":"以太网帧平面"}', 'A', 'SINGLE'),
(4, 'iMaster NCE-Fabric的部署模式中，以下哪项是物理设备纳管的核心组件？', '{"A":"控制器(Controller)","B":"编排器(Orchestrator)","C":"分析器(Analyzer)","D":"采集器(Collector)"}', 'A', 'SINGLE'),
(4, '华为防火墙双机热备中，VGMP组的作用是？', '{"A":"管理VRRP组的状态切换","B":"监控接口状态","C":"同步会话表","D":"配置路由策略"}', 'A', 'SINGLE'),
(4, 'Telnet和SSH的主要区别在于？', '{"A":"SSH支持加密传输，Telnet明文传输","B":"Telnet支持加密传输","C":"两者没有区别","D":"SSH只支持文件传输"}', 'A', 'SINGLE'),
(4, '在大型园区网中，VLAN批量部署推荐使用什么协议？', '{"A":"NETCONF","B":"SNMP","C":"SSH","D":"Telnet"}', 'A', 'SINGLE'),
(4, 'EVPN VXLAN方案中，控制平面通过哪种协议传递MAC地址信息？', '{"A":"MP-BGP","B":"OSPF","C":"IS-IS","D":"RIP"}', 'A', 'SINGLE'),
(4, '华为交换机堆叠技术iStack中，最多支持多少台交换机堆叠？', '{"A":"4台","B":"8台","C":"9台","D":"16台"}', 'C', 'SINGLE'),
(4, 'NFV技术的主要思想是？', '{"A":"用通用硬件替代专用网络设备","B":"所有设备上云","C":"用专用芯片加速","D":"全光网络交换"}', 'A', 'SINGLE'),
(4, '网络切片技术在5G网络中可以实现？', '{"A":"一张物理网络虚拟出多个逻辑网络","B":"物理网络分片管理","C":"多张物理网络合并","D":"网络频谱切割"}', 'A', 'SINGLE');

UPDATE `exams` SET `question_count` = 10 WHERE `id` = 4;

-- =====================================================
-- 考试5: HCIA-Cloud 云计算基础 (exam_id=5)
-- =====================================================
INSERT IGNORE INTO `questions` (`exam_id`, `content`, `options`, `answer`, `type`) VALUES
(5, '云计算三种服务模式中，用户能管理操作系统和应用程序的是？', '{"A":"IaaS","B":"PaaS","C":"SaaS","D":"DaaS"}', 'A', 'SINGLE'),
(5, '华为云ECS实例中，以下哪种计费模式适合长期稳定业务？', '{"A":"按需计费","B":"包年/包月","C":"竞价计费","D":"预留实例"}', 'B', 'SINGLE'),
(5, 'VPC网络规划中，子网掩码为255.255.255.0时可分配IP数量为？', '{"A":"254","B":"256","C":"252","D":"255"}', 'A', 'SINGLE'),
(5, '华为云OBS中，存储桶(Bucket)的命名规则为？', '{"A":"全局唯一","B":"区域唯一","C":"账号唯一","D":"可用区唯一"}', 'A', 'SINGLE'),
(5, '以下哪个不是对象存储的常用操作？', '{"A":"上传对象","B":"创建表结构","C":"下载对象","D":"删除对象"}', 'B', 'SINGLE'),
(5, '华为云安全组(Security Group)相当于哪一层防火墙？', '{"A":"虚拟状态检测防火墙","B":"物理防火墙","C":"WAF应用防火墙","D":"IPS入侵防御"}', 'A', 'SINGLE'),
(5, '华为云RDS MySQL支持哪类高可用部署？', '{"A":"主备架构","B":"双主架构","C":"多活架构","D":"单节点架构"}', 'A', 'SINGLE'),
(5, '弹性伸缩(AS)的伸缩策略不包括以下哪种？', '{"A":"定时策略","B":"基于CPU策略","C":"基于内存策略","D":"基于网络IO策略"}', 'D', 'SINGLE'),
(5, '华为云ELB负载均衡器支持以下哪种类型？', '{"A":"公网和私网","B":"仅公网","C":"仅私网","D":"仅内网"}', 'A', 'SINGLE'),
(5, '云硬盘EVS的快照功能主要用于？', '{"A":"数据备份与恢复","B":"磁盘扩容","C":"磁盘加密","D":"磁盘共享"}', 'A', 'SINGLE');

UPDATE `exams` SET `question_count` = 10 WHERE `id` = 5;

-- =====================================================
-- 考试1: HCIA-Datacom 模拟卷（一）已有15题，补满至20题
-- =====================================================
INSERT IGNORE INTO `questions` (`exam_id`, `content`, `options`, `answer`, `type`) VALUES
(1, 'Ping命令使用的是哪种协议？', '{"A":"ICMP","B":"IGMP","C":"ARP","D":"TCP"}', 'A', 'SINGLE'),
(1, '在Windows系统中，查看本机路由表的命令是？', '{"A":"route print","B":"display ip routing-table","C":"show ip route","D":"netstat -r"}', 'A', 'SINGLE'),
(1, 'NAT地址转换中，以下哪项属于动态NAT的特点？', '{"A":"多对多的地址映射","B":"一对一的固定映射","C":"端口级复用","D":"仅支持IPv6"}', 'A', 'SINGLE'),
(1, 'DNS解析过程中，递归查询的特点是？', '{"A":"DNS服务器代客户端完成查询","B":"客户端依次查询多台DNS服务器","C":"仅查询本地hosts文件","D":"使用广播查询"}', 'A', 'SINGLE'),
(1, '在以太网中，帧的最小长度是？', '{"A":"64字节","B":"128字节","C":"256字节","D":"512字节"}', 'A', 'SINGLE');

UPDATE `exams` SET `question_count` = 20 WHERE `id` = 1;

-- =====================================================
-- 考试6: HCIA-Security 已有10题 (确认)
-- =====================================================
UPDATE `exams` SET `question_count` = 10 WHERE `id` = 6;
