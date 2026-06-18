package com.huawei.ict.repository;

import com.huawei.ict.entity.Exam;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ExamRepository extends JpaRepository<Exam, Long> {
    List<Exam> findByCategory(String category);
    List<Exam> findByUserId(Long userId);
}
