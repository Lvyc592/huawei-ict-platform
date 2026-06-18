package com.huawei.ict.repository;

import com.huawei.ict.entity.Job;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface JobRepository extends JpaRepository<Job, Long> {
    List<Job> findByStatus(Job.JobStatus status);
}
