package com.benedictjeromemart.service;

import com.benedictjeromemart.dao.UserDAO;
import com.benedictjeromemart.dao.UserDAOImpl;
import com.benedictjeromemart.model.User;
import com.benedictjeromemart.util.PasswordUtil;

import java.util.Optional;

public class UserService {

    private final UserDAO userDAO;

    public UserService() {
        this(new UserDAOImpl());
    }

    public UserService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    public User register(String name, String email, String plainPassword, String role) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Name is required");
        }
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Valid email is required");
        }
        if (plainPassword == null || plainPassword.length() < 6) {
            throw new IllegalArgumentException("Password must be at least 6 characters");
        }

        Optional<User> existing = userDAO.findByEmail(email);
        if (existing.isPresent()) {
            throw new IllegalArgumentException("Email already registered");
        }

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPasswordHash(PasswordUtil.hash(plainPassword));
        user.setRole(role);

        return userDAO.create(user);
    }
}
