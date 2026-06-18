package com.huawei.ict.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DashboardStats {
    private long totalStudents;
    private long totalCourses;
    private long totalCertifications;
    private long totalLabs;
    private long onlineUsers;
    private long todayRegistrations;
}
