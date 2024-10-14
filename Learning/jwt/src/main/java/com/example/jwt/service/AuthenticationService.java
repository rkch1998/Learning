package com.example.jwt.service;

import com.example.jwt.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class AuthenticationService {

    @Autowired
    private JwtUtil jwtUtil;

    public String authenticate(String username, String password) {
        // Dummy check for demonstration. Replace with actual user validation.
        if ("user".equals(username) && "password".equals(password)) {
            // Generate a JWT token if credentials are valid
            return jwtUtil.generateToken(username);
        } else {
            throw new RuntimeException("Invalid credentials");
        }
    }
}
