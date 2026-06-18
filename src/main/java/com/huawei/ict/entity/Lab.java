package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;

@Getter
@Setter
@Entity
@Table(name = "labs")
public class Lab extends BaseEntity {

    @Column(nullable = false, length = 200)
    private String name;

    @Column(length = 50)
    private String type;

    @Column(length = 20)
    private String difficulty;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private LabStatus status = LabStatus.IDLE;

    public enum LabStatus {
        RUNNING, IDLE, COMPLETED
    }
}
