package com.huawei.ict.dto;

import lombok.Getter;
import lombok.Setter;

/**
 * 学生工作台"我的课程"卡片 DTO
 * - 在 UserCourse 基础上 join Course 拿课程名/分类/简介
 * - 课程卡片渲染和详情跳转都基于 courseId（HCIA=hcda-001 等）
 */
@Getter
@Setter
public class MyCourseDTO {
    private Long id;
    private Long courseId;
    private String courseName;
    private String category;
    private String description;
    private Integer totalChapters;
    private Integer totalHours;
    private Integer studentCount;
    private Integer progress;
    private String status;          // IN_PROGRESS / NOT_STARTED / COMPLETED
    private String statusText;      // 进行中 / 未开始 / 已完成
    private String slug;            // 详情页用的别名（hcda-001 等），从 category 映射
}
