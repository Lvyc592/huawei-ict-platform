package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;
import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "exam_results")
public class ExamResult extends BaseEntity {

    @Column(name = "exam_id", nullable = false)
    private Long examId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    private Integer score = 0;

    @Column(name = "total_score")
    private Integer totalScore = 0;

    @Column(name = "correct_count")
    private Integer correctCount = 0;

    @Column(name = "question_count")
    private Integer questionCount = 0;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private ResultStatus status = ResultStatus.IN_PROGRESS;

    @Column(name = "started_at")
    private LocalDateTime startedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    public enum ResultStatus {
        IN_PROGRESS, COMPLETED
    }
}
