package com.benedictjeromemart.dao;

import java.util.List;
import java.util.Optional;

import com.benedictjeromemart.model.User;

public interface UserDAO {
    User create(User user);
    boolean registerUser(User user);
    Optional<User> findByEmail(String email);
    User loginUser(String email, String password);
    List<User> findAll();
    User findById(int id);
    boolean updateUser(User user);
    boolean deleteUser(int id);
}