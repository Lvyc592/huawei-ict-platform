package com.huawei.ict.repository;

import com.huawei.ict.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface QuestionRepository extends JpaRepository<Question, Long> {
    List<Question> findByExamId(Long examId);
    long countByExamId(Long examId);
}
