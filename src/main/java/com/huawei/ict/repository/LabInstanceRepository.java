package com.huawei.ict.repository;

import com.huawei.ict.entity.LabInstance;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface LabInstanceRepository extends JpaRepository<LabInstance, Long> {
    List<LabInstance> findByUserId(Long userId);
    long countByUserIdAndStatus(Long userId, LabInstance.LabStatus status);
}
