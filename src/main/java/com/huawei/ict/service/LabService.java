package com.huawei.ict.service;

import com.huawei.ict.entity.Lab;
import com.huawei.ict.entity.LabInstance;
import com.huawei.ict.repository.LabInstanceRepository;
import com.huawei.ict.repository.LabRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LabService {

    private final LabRepository labRepository;
    private final LabInstanceRepository instanceRepository;

    public LabService(LabRepository labRepository, LabInstanceRepository instanceRepository) {
        this.labRepository = labRepository;
        this.instanceRepository = instanceRepository;
    }

    public List<Lab> listLabs() {
        return labRepository.findAll();
    }

    public Lab createLab(Lab lab) {
        return labRepository.save(lab);
    }

    public List<LabInstance> getUserInstances(Long userId) {
        return instanceRepository.findByUserId(userId);
    }

    public LabInstance startInstance(Long userId, Long labId) {
        LabInstance instance = new LabInstance();
        instance.setUserId(userId);
        instance.setLabId(labId);
        instance.setStatus(LabInstance.LabStatus.RUNNING);
        instance.setResources("2 vCPU / 4GB");
        return instanceRepository.save(instance);
    }
}
