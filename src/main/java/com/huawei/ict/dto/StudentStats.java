package com.huawei.ict.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class StudentStats {
    private double focusRate;
    private double accuracy;
    private int totalHours;
    private String level;
    private int completedCourses;
    private int totalCourses;
    private int classRank;
    private int totalClassmates;
}
