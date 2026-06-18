package com.huawei.ict.service;

import com.huawei.ict.entity.Certification;
import com.huawei.ict.repository.CertificationRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CertificationService {

    private final CertificationRepository certificationRepository;

    public CertificationService(CertificationRepository certificationRepository) {
        this.certificationRepository = certificationRepository;
    }

    public List<Certification> listAll() {
        return certificationRepository.findAll();
    }

    public List<Certification> getUserCertifications(Long userId) {
        return certificationRepository.findByUserId(userId);
    }

    public Certification create(Certification certification) {
        return certificationRepository.save(certification);
    }
}
