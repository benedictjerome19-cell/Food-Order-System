package com.benedictjeromemart.model;

import java.time.LocalDateTime;

public class User {
    private int id;
    private String name;
    private String email;
    private String password;
    private String passwordHash;
    private String role;
    private LocalDateTime createdAt;

    // Default no-argument constructor
    public User() {}

    // Parameterized constructor required by unit tests
    public User(String name, String email, String password, String role) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.passwordHash = password;
        this.role = role;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { 
        this.password = password;
        this.passwordHash = password; 
    }

    public String getPasswordHash() { 
        return passwordHash != null ? passwordHash : password; 
    }
    
    public void setPasswordHash(String passwordHash) { 
        this.passwordHash = passwordHash;
        this.password = passwordHash; 
    }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}