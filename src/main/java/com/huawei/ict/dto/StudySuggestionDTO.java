package com.huawei.ict.dto;

import lombok.Getter;
import lombok.Setter;

/**
 * 学习建议 DTO
 * - title       建议标题（如"建议加强 ACL 和 NAT 相关知识点练习"）
 * - reason      建议原因（如"您在该知识点上的掌握度仅 35%，低于及格线 60%"）
 * - kpName      关联知识点名称
 * - masteryRate 当前掌握度
 * - priority    优先级：HIGH / MEDIUM / LOW
 * - relatedCourse    关联课程名
 * - relatedCourseSlug 关联课程 slug（跳 course-detail.html 用）
 * - actionType  推荐操作：PRACTICE / REVIEW / EXPERIMENT
 * - actionUrl   推荐操作链接（题库 / 课程 / 实验）
 * - actionText  按钮文字
 */
@Getter
@Setter
public class StudySuggestionDTO {
    private String title;
    private String reason;
    private String kpName;
    private Integer masteryRate;
    private String priority;
    private String relatedCourse;
    private String relatedCourseSlug;
    private String actionType;
    private String actionUrl;
    private String actionText;
}
