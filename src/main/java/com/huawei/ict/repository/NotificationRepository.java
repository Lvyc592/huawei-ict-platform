package com.huawei.ict.repository;

import com.huawei.ict.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByStatus(Notification.NoticeStatus status);

    /** 学生端：拿 STUDENT + ALL 的通知（按 id 倒序） */
    List<Notification> findByAudienceInOrderByIdDesc(List<String> audiences);
}
