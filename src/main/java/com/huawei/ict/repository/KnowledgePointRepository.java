package com.huawei.ict.repository;

import com.huawei.ict.entity.KnowledgePoint;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface KnowledgePointRepository extends JpaRepository<KnowledgePoint, Long> {
    List<KnowledgePoint> findByUserId(Long userId);
    List<KnowledgePoint> findByUserIdIn(java.util.Collection<Long> userIds);
}
