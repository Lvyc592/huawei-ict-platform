package com.huawei.ict.controller;

import com.huawei.ict.dto.ApiResponse;
import com.huawei.ict.dto.LoginRequest;
import com.huawei.ict.dto.LoginResponse;
import com.huawei.ict.service.AuthService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.view.RedirectView;

import javax.validation.Valid;

@RestController
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @GetMapping("/api/auth/login")
    public RedirectView loginPage() {
        return new RedirectView("/");
    }

    @PostMapping("/api/auth/login")
    public ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        try {
            LoginResponse response = authService.login(request);
            return ApiResponse.ok("登录成功", response);
        } catch (RuntimeException e) {
            return ApiResponse.error(e.getMessage());
        }
    }
}
