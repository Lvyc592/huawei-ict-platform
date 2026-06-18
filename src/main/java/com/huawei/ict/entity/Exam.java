package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;

@Getter
@Setter
@Entity
@Table(name = "exams")
public class Exam extends BaseEntity {

    @Column(nullable = false, length = 200)
    private String title;

    @Column(length = 50)
    private String category;

    @Column(name = "question_count")
    private Integer questionCount = 0;

    @Column(name = "correct_rate")
    private Double correctRate;

    private Integer score;

    @Column(name = "user_id")
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private ExamStatus status = ExamStatus.NOT_STARTED;

    private Integer duration = 60;

    @Column(name = "total_score")
    private Integer totalScore = 100;

    @Column(name = "pass_score")
    private Integer passScore = 60;

    public enum ExamStatus {
        NOT_STARTED, IN_PROGRESS, COMPLETED
    }
}
