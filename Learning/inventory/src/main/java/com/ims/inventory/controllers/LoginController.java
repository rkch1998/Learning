package com.ims.inventory.controllers;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ims.inventory.dtos.LoginRequest;
import com.ims.inventory.dtos.UserDto;
import com.ims.inventory.services.UserService;

@RestController
@RequestMapping("/api")
public class LoginController {
    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody LoginRequest loginRequest) {
        boolean isAuthenticated = userService.authenticateUser(loginRequest.getUsername(), loginRequest.getPassword());
        // System.out.println("Authentic : " + isAuthenticated);
        Map<String, String> response = new HashMap<>();
        if (isAuthenticated) {
            response.put("message", "Login successful!");
            return ResponseEntity.ok(response);
        } else {
            response.put("message", "Invalid username or password.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
    }

    @PostMapping("/signup")
    public ResponseEntity<String> signUp(@RequestBody UserDto userDto) {
        if(userDto.getId() != null){
            throw new IllegalArgumentException("ID should not be provided when creating a new user.");
        }
        userService.createUser(userDto);
        return ResponseEntity.status(HttpStatus.CREATED).body("User has been created.");
    }
}
