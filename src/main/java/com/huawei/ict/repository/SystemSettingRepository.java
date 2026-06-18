package com.huawei.ict.repository;

import com.huawei.ict.entity.SystemSetting;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface SystemSettingRepository extends JpaRepository<SystemSetting, Long> {
    Optional<SystemSetting> findByKey(String key);
}
