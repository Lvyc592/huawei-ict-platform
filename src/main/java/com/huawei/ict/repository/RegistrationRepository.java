package com.huawei.ict.repository;

import com.huawei.ict.entity.Registration;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface RegistrationRepository extends JpaRepository<Registration, Long> {
    List<Registration> findByCompetitionId(Long competitionId);
    List<Registration> findByUserId(Long userId);
    boolean existsByCompetitionIdAndUserId(Long competitionId, Long userId);
}
