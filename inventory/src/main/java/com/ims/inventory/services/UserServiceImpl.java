package com.ims.inventory.services;

import org.springframework.stereotype.Service;

import com.ims.inventory.dtos.UserDto;
import com.ims.inventory.dtos.UserResponseDto;
import com.ims.inventory.entities.User;
import com.ims.inventory.mappers.UserMapper;
import com.ims.inventory.repositories.UserRepository;

@Service
public class UserServiceImpl implements UserService {

    public final UserMapper userMapper;
    public final UserRepository userRepository;

    public UserServiceImpl(UserMapper userMapper, UserRepository userRepository){
        this.userMapper = userMapper;
        this.userRepository = userRepository;
    }

    @Override
    public UserResponseDto createUser(UserDto userDto) {
        if(userDto == null){
            return null;
        }
        User user = userMapper.toEntity(userDto);
        User savedUser = userRepository.save(user);
        return userMapper.toResponseDto(savedUser);
    }

    @Override
    public UserResponseDto getUserByUserName(String userName) {
        User user = userRepository.findByUserName(userName).orElseThrow(() -> new RuntimeException("User Name does not exists."));
        return userMapper.toResponseDto(user);
    }

    @Override
    public void deleteUserByUserName(String userName) {

        User user = userRepository.findByUserName(userName).orElseThrow(() -> new RuntimeException("User Name does not exists."));
        if(user != null){
            userRepository.delete(user);
            System.out.println("User Delete Successfully.");
        }else{
            System.out.println("User does not exists.");
        }
    }

    @Override
    public UserResponseDto updatePassword(String userName, String oldPassword, String newPassword) {
        User user = userRepository.findByUserName(userName).orElseThrow(() -> new RuntimeException("User Name does not exists."));
        if(user.getPassword().equals(oldPassword)){
            user.setPassword(newPassword);
        }else{
            System.out.println("Your old password is not correct.");
        }
        return userMapper.toResponseDto(user);
    }

    @Override
    public UserResponseDto forgotPassword(String userName, String email, String newPassword) {
        User user = userRepository.findByUserName(userName).orElseThrow(() -> new RuntimeException("User does not exists."));
        if(user.getEmail().equals(email)){
            user.setPassword(newPassword);
        }else{
            System.out.println("Email address does not exist.");
        }
        return userMapper.toResponseDto(user);
    }

}
