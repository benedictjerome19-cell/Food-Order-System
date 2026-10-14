package com.benedictjeromemart.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class PasswordMigration {

    public static void hashExistingPasswords(Connection conn) {
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT id, password FROM users")) {
             
            while (rs.next()) {
                int id = rs.getInt("id");
                String pwd = rs.getString("password");
                
                // If the password does not start with any standard BCrypt prefix, it is plain text
                if (pwd != null && !pwd.startsWith("$2a$") && !pwd.startsWith("$2b$") && !pwd.startsWith("$2y$")) {
                    String hashed = PasswordUtil.hash(pwd);
                    try (PreparedStatement pstmt = conn.prepareStatement("UPDATE users SET password = ? WHERE id = ?")) {
                        pstmt.setString(1, hashed);
                        pstmt.setInt(2, id);
                        pstmt.executeUpdate();
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Password migration error: " + e.getMessage());
        }
    }
}