package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;

@Getter
@Setter
@Entity
@Table(name = "jobs")
public class Job extends BaseEntity {

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, length = 200)
    private String company;

    @Column(length = 50)
    private String salary;

    @Column(length = 100)
    private String location;

    @Column(length = 50)
    private String experience;

    @Column(length = 50)
    private String education;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(columnDefinition = "TEXT")
    private String requirement;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private JobStatus status = JobStatus.ACTIVE;

    @Column(name = "apply_count")
    private Integer applyCount = 0;

    public enum JobStatus {
        ACTIVE, CLOSED, PENDING
    }
}
