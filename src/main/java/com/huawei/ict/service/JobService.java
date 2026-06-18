package com.huawei.ict.service;

import com.huawei.ict.entity.Job;
import com.huawei.ict.entity.JobApplication;
import com.huawei.ict.repository.JobApplicationRepository;
import com.huawei.ict.repository.JobRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class JobService {

    private final JobRepository jobRepository;
    private final JobApplicationRepository applicationRepository;

    public JobService(JobRepository jobRepository, JobApplicationRepository applicationRepository) {
        this.jobRepository = jobRepository;
        this.applicationRepository = applicationRepository;
    }

    public List<Job> listJobs() {
        return jobRepository.findByStatus(Job.JobStatus.ACTIVE);
    }

    public Job createJob(Job job) {
        return jobRepository.save(job);
    }

    public JobApplication apply(Long jobId, Long userId) {
        JobApplication application = new JobApplication();
        application.setJobId(jobId);
        application.setUserId(userId);
        return applicationRepository.save(application);
    }

    public List<JobApplication> getUserApplications(Long userId) {
        return applicationRepository.findByUserId(userId);
    }
}
