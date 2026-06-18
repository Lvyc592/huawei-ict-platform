package com.huawei.ict.service;

import com.huawei.ict.config.JwtUtil;
import com.huawei.ict.dto.LoginRequest;
import com.huawei.ict.dto.LoginResponse;
import com.huawei.ict.entity.User;
import com.huawei.ict.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    public LoginResponse login(LoginRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("用户名或密码错误"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("用户名或密码错误");
        }

        if (user.getStatus() != User.UserStatus.NORMAL) {
            throw new RuntimeException("账号已被禁用或待审核");
        }

        // 不再校验 request.role：以用户实际 role 决定 token / 跳转。
        // 前端传 role 仅作历史兼容，这里忽略即可。

        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole().name());
        return new LoginResponse(token, user.getRole().name(), user.getName(), user.getId());
    }
}
