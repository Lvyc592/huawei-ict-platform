package com.huawei.ict.repository;

import com.huawei.ict.entity.QuestionRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface QuestionRecordRepository extends JpaRepository<QuestionRecord, Long> {
    List<QuestionRecord> findByUserId(Long userId);
    List<QuestionRecord> findByUserIdAndMode(Long userId, String mode);
    long countByUserIdAndIsCorrect(Long userId, Boolean isCorrect);
    long countByUserIdAndIsCorrectAndMode(Long userId, Boolean isCorrect, String mode);
}
