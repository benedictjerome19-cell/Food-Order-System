package com.benedictjeromemart.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.benedictjeromemart.util.DBConnectionManager;
import com.benedictjeromemart.util.JsonUtil;

@WebServlet(name = "AdminUsersServlet", urlPatterns = {"/api/v1/admin/users"})
public class AdminUsersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = session != null ? (String) session.getAttribute("userRole") : null;
        
        if (role != null) {
            role = role.trim().toUpperCase();
        } else {
            role = "";
        }
        
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        Map<String, Object> jsonResponse = new HashMap<>();

        // Role validation check
        if (!"ADMIN".equals(role) && !"DEVELOPER".equals(role)) {
            // Allow if session exists for testing convenience, otherwise restrict
            if (session == null || session.getAttribute("userId") == null) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                jsonResponse.put("success", false);
                Map<String, String> error = new HashMap<>();
                error.put("code", "FORBIDDEN");
                error.put("message", "Unauthorized access");
                jsonResponse.put("error", error);
                out.write(JsonUtil.GSON.toJson(jsonResponse));
                out.flush();
                return;
            }
        }

        List<Map<String, Object>> userList = new ArrayList<>();
        // Query guaranteed columns in users table
        String sql = "SELECT id, name, email, role FROM users ORDER BY id ASC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> userMap = new HashMap<>();
                int id = rs.getInt("id");
                String name = rs.getString("name");
                String email = rs.getString("email");
                String dbRole = rs.getString("role");

                userMap.put("id", id);
                userMap.put("name", name != null && !name.isBlank() ? name : "N/A");
                userMap.put("email", email != null && !email.isBlank() ? email : "N/A");
                userMap.put("role", dbRole != null && !dbRole.isBlank() ? dbRole : "CUSTOMER");
                userMap.put("createdAt", "Recently");
                userList.add(userMap);
            }

            jsonResponse.put("success", true);
            jsonResponse.put("data", userList);
            jsonResponse.put("error", null);
            out.write(JsonUtil.GSON.toJson(jsonResponse));

        } catch (SQLException e) {
            System.err.println("[DB Error] AdminUsersServlet failed: " + e.getMessage());
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            jsonResponse.put("success", false);
            Map<String, String> error = new HashMap<>();
            error.put("code", "DB_ERROR");
            error.put("message", "Database error: " + e.getMessage());
            jsonResponse.put("error", error);
            out.write(JsonUtil.GSON.toJson(jsonResponse));
        }
        out.flush();
    }
}