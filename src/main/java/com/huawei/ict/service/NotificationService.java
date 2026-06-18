package com.huawei.ict.service;

import com.huawei.ict.entity.Notification;
import com.huawei.ict.repository.NotificationRepository;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;

    public NotificationService(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    /** 管理员端：仅取 ADMIN + ALL 的通知，按 id 倒序 */
    public List<Notification> listNotifications() {
        return notificationRepository.findByAudienceInOrderByIdDesc(
                Arrays.asList(Notification.AUDIENCE_ADMIN, Notification.AUDIENCE_ALL));
    }

    public Notification createNotification(Notification notification) {
        return notificationRepository.save(notification);
    }
}
