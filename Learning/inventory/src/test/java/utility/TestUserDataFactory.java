package utility;

import com.ims.inventory.dtos.UserDto;
import com.ims.inventory.dtos.UserResponseDto;
import com.ims.inventory.entities.User;

public class TestUserDataFactory {
    public static UserDto createUserDto() {
        return new UserDto(1L, "Ravi", "abc@gmail.com", "RkCH", "123455678");
    }

    public static User createUser() {
        return new User(1L, "Ravi", "abc@gmail.com", "RkCH", "123455678");
    }

    public static UserResponseDto createUserResponseDto() {
        return new UserResponseDto(1L, "Ravi", "RkCH", "abc@gmail.com");
    }
}
