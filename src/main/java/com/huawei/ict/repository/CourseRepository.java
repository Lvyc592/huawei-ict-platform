package com.huawei.ict.repository;

import com.huawei.ict.entity.Course;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CourseRepository extends JpaRepository<Course, Long> {
    List<Course> findByCategory(String category);
    List<Course> findByStatus(Course.CourseStatus status);
    List<Course> findByTeacherId(Long teacherId);
    long countByTeacherId(Long teacherId);
}
