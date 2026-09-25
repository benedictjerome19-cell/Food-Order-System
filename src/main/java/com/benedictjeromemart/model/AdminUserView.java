package com.benedictjeromemart.model;

import java.sql.Timestamp;

public class AdminUserView {
    private int id;
    private String name;
    private String email;
    private String role;
    private String createdAt;

    public AdminUserView(int id, String name, String email, String role, Timestamp createdAt) {
        this.id = id;
        this.name = name != null ? name : "";
        this.email = email != null ? email : "";
        this.role = role != null ? role : "";
        this.createdAt = createdAt != null ? createdAt.toString() : "";
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getRole() {
        return role;
    }

    public String getCreatedAt() {
        return createdAt;
    }
}