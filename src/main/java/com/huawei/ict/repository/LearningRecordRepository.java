package com.huawei.ict.repository;

import com.huawei.ict.entity.LearningRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface LearningRecordRepository extends JpaRepository<LearningRecord, Long> {
    List<LearningRecord> findByUserIdAndDateBetween(Long userId, LocalDate start, LocalDate end);
    List<LearningRecord> findByUserIdIn(java.util.Collection<Long> userIds);
    List<LearningRecord> findByUserIdInAndDateBetween(java.util.Collection<Long> userIds, LocalDate start, LocalDate end);
}
