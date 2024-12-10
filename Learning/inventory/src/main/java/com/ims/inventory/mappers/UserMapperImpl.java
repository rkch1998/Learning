package com.ims.inventory.mappers;

import java.util.Optional;

import org.springframework.stereotype.Component;

import com.ims.inventory.dtos.UserDto;
import com.ims.inventory.dtos.UserResponseDto;
import com.ims.inventory.entities.User;

@Component
public class UserMapperImpl implements UserMapper{

    @Override
    public UserDto toDto(User user) {
        System.out.println("User : " + user);
        if(user == null){
            return null;
        }
        UserDto userDto = new UserDto();
        userDto.setName(user.getName());
        userDto.setUsername(user.getUsername());
        userDto.setPassword(user.getPassword());
        userDto.setEmail(user.getEmail());
        return userDto;
    }

    @Override
    public User toEntity(UserDto userDto) {
        // System.out.println("userDto : " + userDto);

       if(userDto == null) return null;

       User user = new User();
       user.setName(userDto.getName());
       user.setUsername(userDto.getUsername());
       user.setEmail(userDto.getEmail());
       user.setPassword(userDto.getPassword());
       return user;
    }

    @Override
    public UserResponseDto toResponseDto(User user) {
    // System.out.println("toUserResponce : " + user);
    if(user == null){
            return null;
        }
        UserResponseDto userDto = new UserResponseDto();
        userDto.setName(user.getName());
        userDto.setUsername(user.getUsername());
        userDto.setEmail(user.getEmail());
        return userDto;
    }

    @Override
    public UserResponseDto userResponseDto(Optional<User> user) {
        // System.out.println("UserResponce : " + user);
        if(user == null){
            return null;
        }
        UserResponseDto userDto = new UserResponseDto();
        userDto.setName(user.get().getName());
        userDto.setUsername(user.get().getUsername());
        userDto.setEmail(user.get().getEmail());
        return userDto;
    }

}
