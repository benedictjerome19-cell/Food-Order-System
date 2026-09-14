package com.benedictjeromemart.service;

import com.benedictjeromemart.dao.UserDAO;
import com.benedictjeromemart.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class UserServiceTest {

    @Mock
    private UserDAO userDAO;

    @InjectMocks
    private UserService userService;

    @Test
    public void testRegisterValidationFailureEmptyName() {
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.register("", "valid@email.com", "password123", "CUSTOMER");
        });
        assertTrue(exception.getMessage().toLowerCase().contains("name"));
    }

    @Test
    public void testRegisterValidationFailureDuplicateEmail() {
        when(userDAO.findByEmail("existing@email.com")).thenReturn(Optional.of(new User("Existing", "existing@email.com", "hash", "CUSTOMER")));

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.register("New User", "existing@email.com", "password123", "CUSTOMER");
        });
        assertTrue(exception.getMessage().toLowerCase().contains("already registered"));
    }
}
