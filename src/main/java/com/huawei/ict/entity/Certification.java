package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;
import java.time.LocalDate;

@Getter
@Setter
@Entity
@Table(name = "certifications")
public class Certification extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(length = 100)
    private String type;

    @Column(name = "exam_date")
    private LocalDate examDate;

    private Integer score;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private CertStatus status = CertStatus.PENDING;

    public enum CertStatus {
        PASSED, FAILED, PENDING
    }
}
