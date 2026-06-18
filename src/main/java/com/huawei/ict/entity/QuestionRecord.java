package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;

@Getter
@Setter
@Entity
@Table(name = "question_records")
public class QuestionRecord extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "question_id", nullable = false)
    private Long questionId;

    @Column(length = 500)
    private String answer;

    @Column(name = "is_correct")
    private Boolean isCorrect;

    @Column(length = 20)
    private String mode = "PRACTICE"; // PRACTICE / EXAM
}
