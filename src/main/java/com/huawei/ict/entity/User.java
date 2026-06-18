package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;

@Getter
@Setter
@Entity
@Table(name = "users")
public class User extends BaseEntity {

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false, length = 255)
    private String password;

    @Column(length = 100)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Role role;

    @Column(name = "student_id", length = 50)
    private String studentId;

    @Column(length = 100)
    private String email;

    @Column(length = 20)
    private String phone;

    @Column(length = 255)
    private String avatar;

    @Column(name = "certification_level", length = 50)
    private String certificationLevel;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private UserStatus status = UserStatus.NORMAL;

    public enum Role {
        STUDENT, TEACHER, ADMIN
    }

    public enum UserStatus {
        NORMAL, DISABLED, PENDING
    }
}
