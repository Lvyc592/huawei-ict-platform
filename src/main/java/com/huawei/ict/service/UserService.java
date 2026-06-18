package com.huawei.ict.service;

import com.huawei.ict.entity.User;
import com.huawei.ict.repository.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public Page<User> listUsers(Pageable pageable) {
        return userRepository.findAll(pageable);
    }

    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
    }

    public User createUser(User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    public User updateUser(Long id, User updated) {
        User user = getUserById(id);
        if (updated.getName() != null) user.setName(updated.getName());
        if (updated.getEmail() != null) user.setEmail(updated.getEmail());
        if (updated.getPhone() != null) user.setPhone(updated.getPhone());
        if (updated.getCertificationLevel() != null) user.setCertificationLevel(updated.getCertificationLevel());
        return userRepository.save(user);
    }

    public void updateStatus(Long id, User.UserStatus status) {
        User user = getUserById(id);
        user.setStatus(status);
        userRepository.save(user);
    }
}
