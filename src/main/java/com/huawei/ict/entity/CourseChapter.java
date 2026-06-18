package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;

@Getter
@Setter
@Entity
@Table(name = "course_chapters")
public class CourseChapter extends BaseEntity {

    @Column(name = "course_id", nullable = false)
    private Long courseId;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(name = "sort_order")
    private Integer sortOrder;
}
