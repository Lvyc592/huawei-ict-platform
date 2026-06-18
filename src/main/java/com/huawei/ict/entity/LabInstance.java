package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;

@Getter
@Setter
@Entity
@Table(name = "lab_instances")
public class LabInstance extends BaseEntity {

    @Column(name = "lab_id", nullable = false)
    private Long labId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private LabStatus status = LabStatus.IDLE;

    @Column(length = 100)
    private String resources;

    public enum LabStatus {
        RUNNING, COMPLETED, IDLE
    }
}
