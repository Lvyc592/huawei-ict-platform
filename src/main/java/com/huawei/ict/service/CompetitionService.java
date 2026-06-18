package com.huawei.ict.service;

import com.huawei.ict.entity.Competition;
import com.huawei.ict.entity.Registration;
import com.huawei.ict.repository.CompetitionRepository;
import com.huawei.ict.repository.RegistrationRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CompetitionService {

    private final CompetitionRepository competitionRepository;
    private final RegistrationRepository registrationRepository;

    public CompetitionService(CompetitionRepository competitionRepository,
                              RegistrationRepository registrationRepository) {
        this.competitionRepository = competitionRepository;
        this.registrationRepository = registrationRepository;
    }

    public List<Competition> listCompetitions() {
        return competitionRepository.findAll();
    }

    public Competition createCompetition(Competition competition) {
        return competitionRepository.save(competition);
    }

    public Registration register(Long competitionId, Long userId) {
        if (registrationRepository.existsByCompetitionIdAndUserId(competitionId, userId)) {
            throw new RuntimeException("已报名该赛事");
        }
        Registration registration = new Registration();
        registration.setCompetitionId(competitionId);
        registration.setUserId(userId);
        return registrationRepository.save(registration);
    }

    public List<Registration> getUserRegistrations(Long userId) {
        return registrationRepository.findByUserId(userId);
    }
}
