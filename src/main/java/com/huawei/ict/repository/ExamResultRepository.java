package com.huawei.ict.repository;

import com.huawei.ict.entity.ExamResult;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ExamResultRepository extends JpaRepository<ExamResult, Long> {
    List<ExamResult> findByUserId(Long userId);
    List<ExamResult> findByUserIdIn(List<Long> userIds);
    List<ExamResult> findByExamId(Long examId);
    List<ExamResult> findByUserIdAndExamId(Long userId, Long examId);
    Optional<ExamResult> findTopByUserIdAndExamIdAndStatusOrderByIdDesc(
        Long userId, Long examId, ExamResult.ResultStatus status);
    long countByUserIdAndStatus(Long userId, ExamResult.ResultStatus status);
    long countByExamId(Long examId);
}
