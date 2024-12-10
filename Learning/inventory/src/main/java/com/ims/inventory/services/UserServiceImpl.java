package com.ims.inventory.services;

import java.util.Optional;

// import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ims.inventory.dtos.UserDto;
import com.ims.inventory.dtos.UserResponseDto;
// import com.ims.inventory.entities.Inventory;
import com.ims.inventory.entities.User;
import com.ims.inventory.mappers.UserMapper;
import com.ims.inventory.repositories.InventoryRepository;
import com.ims.inventory.repositories.ProductRepository;
import com.ims.inventory.repositories.UserRepository;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    public InventoryRepository inventoryRepository;

    @Autowired
    public ProductRepository productRepository;

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
        // System.out.println("UserName "+user.getUsername());
        User savedUser = userRepository.save(user);

        return userMapper.toResponseDto(savedUser);
    }

    

    @Override
    public UserResponseDto getUserByUserName(String userName) {
        // System.out.println("User Name "+ userName);
        User user = userRepository.findMinimalUserByUsername(userName).orElseThrow(() -> new RuntimeException("User Name does not exists."));
        return userMapper.toResponseDto(user);
    }

    @Override
    public Long findUserIdByUsername(String userName){
        if(userName == null){
            return null;
        }
        User user = userRepository.findMinimalUserByUsername(userName).orElseThrow(() -> new RuntimeException("User Name does not exists."));
        return user.getId();
    }

    // @Override
    // public void deleteUserByUserName(String userName) {

    //     User user = userRepository.findMinimalUserByUsername(userName).orElseThrow(() -> new RuntimeException("User Name does not exists."));

    //     Optional<Inventory> inventory = inventoryRepository.findByUserId(user.getId());

    //     productRepository.deleteByInventoryId(inventory.get().getId());
    //     inventoryRepository.delete(inventory.get());
    //     userRepository.delete(user);

    //     System.out.println("User Delete Successfully.");
    // }

    @Override
    public void deleteUserByUserName(String userName) {

        User user = userRepository.findMinimalUserByUsername(userName).orElseThrow(() -> new RuntimeException("User Name does not exists."));

        // Optional<Inventory> inventory = inventoryRepository.findByUserId(user.getId());

        // productRepository.deleteByInventoryId(inventory.get().getId());
        // inventoryRepository.delete(inventory.get());
        userRepository.delete(user);

        System.out.println("User Delete Successfully.");
    }

    @Override
    public UserResponseDto updatePassword(String userName, String oldPassword, String newPassword) {
        // System.out.println("User Name "+ userName);
        User user = userRepository.findMinimalUserByUsername(userName).orElseThrow(() -> new RuntimeException("User Name does not exists."));
        User savedUser;
        if(user.getPassword().equals(oldPassword)){
            user.setPassword(newPassword);
            savedUser = userRepository.save(user);
        }else{
            throw new RuntimeException("Your old password is not correct.");
        }
        return userMapper.toResponseDto(savedUser);
    }

    @Override
    public UserResponseDto forgotPassword(String userName, String email, String newPassword) {
        User user = userRepository.findMinimalUserByUsername(userName).orElseThrow(() -> new RuntimeException("User does not exists."));
        User savedUser;
        if(user.getEmail().equals(email)){
            user.setPassword(newPassword);
            savedUser = userRepository.save(user);
        }else{
            throw new RuntimeException("Email address does not exist.");
        }
        return userMapper.toResponseDto(savedUser);
    }

    @Override
    public boolean authenticateUser(String username, String password) {
        Optional<User> user = userRepository.findMinimalUserByUsername(username);
        if(user != null && user.get().getUsername().equals(username)){
            return true;
        }
        else{
            return false;
        }
    }

    @Override
    public UserResponseDto getUserById(Long id) {
        UserResponseDto userResponseDto = userMapper.userResponseDto(userRepository.findById(id));
        return userResponseDto;
    }

}
