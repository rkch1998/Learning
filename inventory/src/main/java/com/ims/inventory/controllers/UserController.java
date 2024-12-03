package com.ims.inventory.controllers;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.ims.inventory.dtos.UserDto;
import com.ims.inventory.dtos.UserResponseDto;
import com.ims.inventory.services.UserService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;



@RestController
@RequestMapping("/api/users")
public class UserController {
    public final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping
    public ResponseEntity<String> createUser(@RequestBody UserDto userDto) {
        userService.createUser(userDto);
        return ResponseEntity.status(HttpStatus.CREATED).body("User has been created.");
    }

    @GetMapping("/userName")
    public ResponseEntity<UserResponseDto> getUser(@PathVariable String userName){
        UserResponseDto userResponseDto = userService.getUserByUserName(userName);
        return ResponseEntity.ok(userResponseDto);
    }
    
    @DeleteMapping("/userName")
    public ResponseEntity<String> deleteUser(@PathVariable String userName){
        userService.deleteUserByUserName(userName);
        String responseMessage = String.format("User with Username %s has been successfully deleted.", userName);
        return ResponseEntity.ok(responseMessage);
    }

    @PostMapping("/{userName}/update-password")
    public ResponseEntity<String> updatePassword(@PathVariable String userName,
                                                @PathVariable String oldPassword,
                                                @PathVariable String newPassword                
                                                ){
        userService.updatePassword(userName, oldPassword, newPassword);
        String responseMessage = String.format("user with Username %s password has been successfully changed to new password.", userName);
        return ResponseEntity.ok(responseMessage);
    }

    @PostMapping("/{userName}/forgot-password")
    public ResponseEntity<String> forgotPassword(@PathVariable String userName, @RequestParam String email, @RequestParam String newPassword) {
        userService.forgotPassword(userName, email, newPassword);
        String responseMessage = String.format("user with Username %s password has been successfully changed to new password.", userName);
        return ResponseEntity.ok(responseMessage);
    }
    

}
