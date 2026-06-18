package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;

@Getter
@Setter
@Entity
@Table(name = "questions")
public class Question extends BaseEntity {

    @Column(name = "exam_id", nullable = false)
    private Long examId;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(columnDefinition = "TEXT")
    private String options;

    @Column(length = 500)
    private String answer;

    @Column(length = 20)
    private String type;
}
