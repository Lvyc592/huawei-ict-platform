package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;
import java.time.LocalDate;

@Getter
@Setter
@Entity
@Table(name = "competitions")
public class Competition extends BaseEntity {

    @Column(nullable = false, length = 200)
    private String name;

    @Column(length = 50)
    private String track;

    @Column(name = "registration_count")
    private Integer registrationCount = 0;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private CompetitionStatus status = CompetitionStatus.OPEN;

    private LocalDate deadline;

    @Column(name = "competition_date")
    private LocalDate competitionDate;

    @Column(columnDefinition = "TEXT")
    private String description;

    public enum CompetitionStatus {
        OPEN, ONGOING, CLOSED
    }
}
