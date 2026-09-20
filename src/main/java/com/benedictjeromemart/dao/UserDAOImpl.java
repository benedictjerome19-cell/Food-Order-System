package com.benedictjeromemart.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.benedictjeromemart.model.User;
import com.benedictjeromemart.util.DBConnectionManager;

public class UserDAOImpl implements UserDAO {

    private static final Logger LOGGER = Logger.getLogger(UserDAOImpl.class.getName());

    private Connection getConnection() throws SQLException {
        return DBConnectionManager.getConnection();
    }

    @Override
    public User create(User user) {
        String sql = "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, user.getName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPasswordHash() != null ? user.getPasswordHash() : user.getPassword());
            stmt.setString(4, user.getRole() != null ? user.getRole() : "CUSTOMER");
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    user.setId(rs.getInt(1));
                }
            }
            return user;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to create user: " + user.getEmail(), e);
            throw new RuntimeException("Database error during user registration: " + e.getMessage(), e);
        }
    }

    @Override
    public boolean registerUser(User user) {
        try {
            User created = create(user);
            return created != null && created.getId() > 0;
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    public Optional<User> findByEmail(String email) {
        String sql = "SELECT id, name, email, password, role FROM users WHERE email = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setRole(rs.getString("role"));
                    return Optional.of(user);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to find user by email: " + email, e);
        }
        return Optional.empty();
    }

    @Override
    public User loginUser(String email, String password) {
        Optional<User> opt = findByEmail(email);
        if (opt.isPresent()) {
            User user = opt.get();
            if (user.getPassword() != null && user.getPassword().equals(password)) {
                return user;
            }
        }
        return null;
    }

    @Override
    public List<User> findAll() {
        String sql = "SELECT id, name, email, password, role FROM users";
        List<User> users = new ArrayList<>();
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setRole(rs.getString("role"));
                users.add(user);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to fetch all users", e);
        }
        return users;
    }

    @Override
    public User findById(int id) {
        String sql = "SELECT id, name, email, password, role FROM users WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setRole(rs.getString("role"));
                    return user;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to find user by ID: " + id, e);
        }
        return null;
    }

    @Override
    public boolean updateUser(User user) {
        String sql = "UPDATE users SET name = ?, email = ?, password = ?, role = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPassword());
            stmt.setString(4, user.getRole());
            stmt.setInt(5, user.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update user: " + user.getId(), e);
            return false;
        }
    }

    @Override
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to delete user: " + id, e);
            return false;
        }
    }
}