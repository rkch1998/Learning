package com.ims.inventory.services;

import com.ims.inventory.dtos.UserDto;
import com.ims.inventory.dtos.UserResponseDto;

public interface UserService {
    UserResponseDto createUser(UserDto userDto); 
    UserResponseDto getUserByUserName(String userName);
    void deleteUserByUserName(String userName);
    UserResponseDto updatePassword(String userName, String oldPassword, String newPassword);
    UserResponseDto forgotPassword(String userName, String email, String newPassword);
}
