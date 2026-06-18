package com.huawei.ict.repository;

import com.huawei.ict.entity.Certification;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CertificationRepository extends JpaRepository<Certification, Long> {
    List<Certification> findByUserId(Long userId);
    long countByStatus(Certification.CertStatus status);
}
