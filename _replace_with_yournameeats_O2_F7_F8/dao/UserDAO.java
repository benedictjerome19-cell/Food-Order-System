package com.yourname.yournameeats.dao;

import com.yourname.yournameeats.model.User;
import java.util.List;
import java.util.Optional;

public interface UserDAO {
    User create(User user);
    Optional<User> findByEmail(String email);
    List<User> findAll();
}
