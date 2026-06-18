package com.huawei.ict.repository;

import com.huawei.ict.entity.CourseChapter;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CourseChapterRepository extends JpaRepository<CourseChapter, Long> {
    List<CourseChapter> findByCourseIdOrderBySortOrder(Long courseId);
}
