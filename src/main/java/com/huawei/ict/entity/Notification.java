package com.huawei.ict.entity;

import lombok.Getter;
import lombok.Setter;
import javax.persistence.*;

@Getter
@Setter
@Entity
@Table(name = "notifications")
public class Notification extends BaseEntity {

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String content;

    @Column(length = 20)
    private String type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private NoticeStatus status = NoticeStatus.UNREAD;

    /** 通知受众：STUDENT（仅学生）/ ADMIN（仅管理员）/ ALL（所有人）。默认 ALL 兼容历史数据。 */
    @Column(length = 20)
    private String audience = "ALL";

    public enum NoticeStatus {
        UNREAD, READ
    }

    public static final String AUDIENCE_STUDENT = "STUDENT";
    public static final String AUDIENCE_ADMIN = "ADMIN";
    public static final String AUDIENCE_ALL = "ALL";
}
