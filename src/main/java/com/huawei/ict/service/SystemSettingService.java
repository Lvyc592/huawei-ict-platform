package com.huawei.ict.service;

import com.huawei.ict.entity.SystemSetting;
import com.huawei.ict.repository.SystemSettingRepository;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class SystemSettingService {

    private final SystemSettingRepository settingRepository;

    public SystemSettingService(SystemSettingRepository settingRepository) {
        this.settingRepository = settingRepository;
    }

    public Map<String, String> getAllSettings() {
        Map<String, String> map = new HashMap<>();
        List<SystemSetting> settings = settingRepository.findAll();
        for (SystemSetting setting : settings) {
            map.put(setting.getKey(), setting.getValue());
        }
        return map;
    }

    public SystemSetting updateSetting(String key, String value) {
        SystemSetting setting = settingRepository.findByKey(key)
                .orElse(new SystemSetting());
        setting.setKey(key);
        setting.setValue(value);
        return settingRepository.save(setting);
    }
}
