package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;

@Getter
@Setter
@Entity
@Table(name = "courses")
public class Course extends BaseEntity {

    @Column(nullable = false, length = 200)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(length = 50)
    private String category;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "total_chapters")
    private Integer totalChapters;

    @Column(name = "total_hours")
    private Integer totalHours;

    @Column(name = "student_count")
    private Integer studentCount = 0;

    /** 任课教师 user.id（User.Role=TEACHER），NULL 表示未分配教师 */
    @Column(name = "teacher_id")
    private Long teacherId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private CourseStatus status = CourseStatus.DRAFT;

    public enum CourseStatus {
        PUBLISHED, DRAFT, PENDING
    }
}
