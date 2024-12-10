package com.ims.inventory.mappers;

import java.util.Optional;

import com.ims.inventory.dtos.UserDto;
import com.ims.inventory.dtos.UserResponseDto;
import com.ims.inventory.entities.User;

public interface UserMapper {
    UserDto toDto(User user);
    User toEntity(UserDto userDto);
    UserResponseDto toResponseDto(User user);
    UserResponseDto userResponseDto(Optional<User> byId);
}
