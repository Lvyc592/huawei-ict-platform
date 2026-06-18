package com.huawei.ict.repository;

import com.huawei.ict.entity.UserCourse;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface UserCourseRepository extends JpaRepository<UserCourse, Long> {
    List<UserCourse> findByUserId(Long userId);
    Optional<UserCourse> findByUserIdAndCourseId(Long userId, Long courseId);
    long countByUserIdAndStatus(Long userId, UserCourse.CourseStatus status);
    List<UserCourse> findByCourseId(Long courseId);
    List<UserCourse> findByCourseIdIn(java.util.Collection<Long> courseIds);
    long countByCourseId(Long courseId);
}
