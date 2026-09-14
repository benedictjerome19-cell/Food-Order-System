package com.yourname.yournameeats.model;

import java.time.LocalDateTime;

/** User, minus passwordHash — the safe shape to hand back from /api/v1/admin/users. */
public class AdminUserView {
    private int id;
    private String name;
    private String email;
    private String role;
    private LocalDateTime createdAt;

    public AdminUserView(User user) {
        this.id = user.getId();
        this.name = user.getName();
        this.email = user.getEmail();
        this.role = user.getRole();
        this.createdAt = user.getCreatedAt();
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public String getRole() { return role; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
