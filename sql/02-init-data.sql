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
