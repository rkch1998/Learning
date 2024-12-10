package com.ims.inventory;

// import static org.junit.jupiter.api.Assertions.assertEquals;
// import static org.junit.jupiter.api.Assertions.assertNotNull;
// import static org.mockito.ArgumentMatchers.any;
// import static org.mockito.Mockito.times;
// import static org.mockito.Mockito.verify;
// import static org.mockito.Mockito.when;

// import java.util.Optional;

// import org.junit.jupiter.api.BeforeEach;
// import org.junit.jupiter.api.Test;
// import org.mockito.InjectMocks;
// import org.mockito.Mock;
// import org.mockito.MockitoAnnotations;

// import com.ims.inventory.dtos.UserDto;
// import com.ims.inventory.dtos.UserResponseDto;
// import com.ims.inventory.entities.User;
// import com.ims.inventory.mappers.UserMapper;
// import com.ims.inventory.repositories.UserRepository;
// // import com.ims.inventory.services.UserService;
// import com.ims.inventory.services.UserServiceImpl;

// import utility.TestUserDataFactory;

public class UserServiceImplTest {
    // @Mock
    // UserMapper userMapper;

    // @Mock
    // UserRepository userRepository;

    // @InjectMocks
    // UserServiceImpl userService;

    // @BeforeEach
    // public void setUp(){
    //     MockitoAnnotations.openMocks(this);
    // }

    // @Test
    // void testCreateUser(){
    //     //Arrange
    //     UserDto userDto = TestUserDataFactory.createUserDto();
    //     User user = TestUserDataFactory.createUser();
    //     UserResponseDto userResponseDto = TestUserDataFactory.createUserResponseDto();

    //     when(userMapper.toEntity(userDto)).thenReturn(user);
    //     when(userRepository.save(any(User.class))).thenReturn(user);
    //     when(userMapper.toResponseDto(user)).thenReturn(userResponseDto);

    //     //Act
    //     UserResponseDto actualResponseDto = userService.createUser(userDto);

    //     //Assert
    //     assertNotNull(actualResponseDto);
    //     assertEquals(userResponseDto.getName(), actualResponseDto.getName());
    //     assertEquals(userResponseDto.getUsername(), actualResponseDto.getUsername());
    //     verify(userRepository, times(1)).save(user);
    // }

    // @Test
    // void testGetUserByUserName(){
    //     //Arrange
    //     User user = TestUserDataFactory.createUser();
    //     UserResponseDto userResponseDto = TestUserDataFactory.createUserResponseDto();

    //     when(userRepository.findByUsername("RkCH")).thenReturn(Optional.of(user));
    //     when(userMapper.toResponseDto(user)).thenReturn(userResponseDto);

    //     //Act
    //     UserResponseDto result = userService.getUserByUserName("RkCH");

    //     //Assert
    //     assertNotNull(result);
    //     assertEquals(userResponseDto.getName(), result.getName());
    //     assertEquals(userResponseDto.getUsername(), result.getUsername());
    //     verify(userRepository, times(1)).findByUsername("RkCH");
    // }




}
