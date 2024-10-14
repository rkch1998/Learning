package com.example.jwt.controller;

import com.example.jwt.model.AuthenticationRequest;
import com.example.jwt.model.AuthenticationResponse;
import com.example.jwt.util.JwtUtil;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class AuthenticationController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtil jwtTokenUtil;

    @PostMapping("/authenticate")
    public ResponseEntity<?> createAuthenticationToken(@RequestBody AuthenticationRequest authenticationRequest) throws Exception {

        // Authenticate the user
        authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(authenticationRequest.getUsername(), authenticationRequest.getPassword())
        );

        // Generate JWT token
        final String jwt = jwtTokenUtil.generateToken(authenticationRequest.getUsername());

        // Return the JWT in the response
        return ResponseEntity.ok(new AuthenticationResponse(jwt));
    }
}
