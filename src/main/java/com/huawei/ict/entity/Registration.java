package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;

@Getter
@Setter
@Entity
@Table(name = "registrations")
public class Registration extends BaseEntity {

    @Column(name = "competition_id", nullable = false)
    private Long competitionId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private RegistrationStatus status = RegistrationStatus.PENDING;

    public enum RegistrationStatus {
        PENDING, APPROVED, REJECTED
    }
}
