package com.ims.inventory.mappers;

import org.springframework.stereotype.Component;

import com.ims.inventory.dtos.UserDto;
import com.ims.inventory.dtos.UserResponseDto;
import com.ims.inventory.entities.User;

@Component
public class UserMapperImpl implements UserMapper{

    @Override
    public UserDto toDto(User user) {
        if(user == null){
            return null;
        }
        UserDto userDto = new UserDto();
        userDto.setName(user.getName());
        userDto.setUserName(user.getUserName());
        userDto.setPassword(user.getPassword());
        userDto.setEmail(user.getEmail());
        return userDto;
    }

    @Override
    public User toEntity(UserDto userDto) {
       if(userDto == null) return null;

       User user = new User();
       user.setName(userDto.getName());
       user.setUserName(userDto.getUserName());
       user.setEmail(userDto.getEmail());
       user.setPassword(userDto.getPassword());
       return user;
    }

    @Override
    public UserResponseDto toResponseDto(User user) {
        if(user == null){
            return null;
        }
        UserResponseDto userDto = new UserResponseDto();
        userDto.setName(user.getName());
        userDto.setUserName(user.getUserName());
        userDto.setEmail(user.getEmail());
        return userDto;
    }

}
