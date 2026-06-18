package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;
import java.time.LocalDate;

@Getter
@Setter
@Entity
@Table(name = "learning_records")
public class LearningRecord extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private Long userId;

    private LocalDate date;

    private Integer duration;

    @Column(name = "focus_rate")
    private Double focusRate;
}
