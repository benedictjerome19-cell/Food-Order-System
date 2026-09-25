package com.benedictjeromemart.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.benedictjeromemart.util.DBConnectionManager;

@WebServlet(urlPatterns = {"/api/dishes", "/dishes"})
public class DishServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        
        StringBuilder jsonBuilder = new StringBuilder();
        jsonBuilder.append("[");
        
        String query = "SELECT id, name, category, price, image_url FROM dishes";
        
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            
            boolean first = true;
            while (rs.next()) {
                if (!first) {
                    jsonBuilder.append(",");
                }
                first = false;
                
                jsonBuilder.append("{");
                jsonBuilder.append("\"id\":").append(rs.getInt("id")).append(",");
                jsonBuilder.append("\"name\":\"").append(escapeJson(rs.getString("name"))).append("\",");
                jsonBuilder.append("\"category\":\"").append(escapeJson(rs.getString("category"))).append("\",");
                jsonBuilder.append("\"price\":").append(rs.getDouble("price")).append(",");
                jsonBuilder.append("\"imageUrl\":\"").append(escapeJson(rs.getString("image_url"))).append("\"");
                jsonBuilder.append("}");
            }
        } catch (SQLException e) {
            System.err.println("[DB] Error fetching dishes: " + e.getMessage());
            e.printStackTrace();
        }
        
        jsonBuilder.append("]");
        out.print(jsonBuilder.toString());
        out.flush();
    }
    
    private String escapeJson(String val) {
        if (val == null) return "";
        return val.replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }
}