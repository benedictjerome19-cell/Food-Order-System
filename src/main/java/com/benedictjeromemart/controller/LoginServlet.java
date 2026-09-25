package com.benedictjeromemart.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.benedictjeromemart.util.DBConnectionManager;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/api/v1/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"success\":false,\"error\":{\"message\":\"Email and password are required.\"}}");
            return;
        }

        String sql = "SELECT id, name, email, password, role FROM users WHERE email = ?";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email.trim());

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String dbPassword = rs.getString("password");
                    boolean passwordMatch = false;

                    // Support both plain-text passwords and BCrypt hashes[cite: 14]
                    if (dbPassword != null && dbPassword.equals(password)) {
                        passwordMatch = true;
                    } else if (dbPassword != null && dbPassword.startsWith("$2")) {
                        try {
                            passwordMatch = org.mindrot.jbcrypt.BCrypt.checkpw(password, dbPassword);
                        } catch (Exception e) {
                            passwordMatch = false;
                        }
                    }

                    if (passwordMatch) {
                        // Explicitly create and bind the session to ensure immediate propagation
                        HttpSession session = req.getSession(true);
                        session.setAttribute("userId", rs.getInt("id"));
                        session.setAttribute("userName", rs.getString("name"));
                        session.setAttribute("userEmail", rs.getString("email"));
                        
                        // Sanitize role to eliminate database whitespace and casing mismatches[cite: 14]
                        String role = rs.getString("role");
                        if (role != null) {
                            role = role.trim().toUpperCase();
                        } else {
                            role = "CUSTOMER";
                        }
                        session.setAttribute("userRole", role);

                        // Route developer/admin to admin dashboard, owners to owner dashboard, customers to home[cite: 14]
                        String redirectUrl = "home.jsp";
                        if ("ADMIN".equals(role) || "DEVELOPER".equals(role)) {
                            redirectUrl = "admin-dashboard.jsp";
                        } else if ("RESTAURANT_OWNER".equals(role)) {
                            redirectUrl = "owner-dashboard.jsp";
                        }

                        resp.getWriter().write("{\"success\":true,\"message\":\"Login successful!\",\"redirectUrl\":\"" + redirectUrl + "\"}");
                    } else {
                        resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                        resp.getWriter().write("{\"success\":false,\"error\":{\"message\":\"Invalid email or password!\"}}");
                    }
                } else {
                    resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    resp.getWriter().write("{\"success\":false,\"error\":{\"message\":\"Invalid email or password!\"}}");
                }
            }

        } catch (SQLException e) {
            System.err.println("[DB] Login error: " + e.getMessage());
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"success\":false,\"error\":{\"message\":\"Database error: " + e.getMessage().replace("\"", "'") + "\"}}");
        }
    }
}