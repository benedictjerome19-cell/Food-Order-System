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

@WebServlet(name = "MenuItemServlet", urlPatterns = {"/api/v1/menu-items"})
public class MenuItemServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        
        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true,\"data\":[");
        
        // Fixed: Query the correct 'menu_items' table instead of 'dishes'
        String sql = "SELECT id, name, category, price, image_url, description, stock_qty FROM menu_items WHERE is_available = true ORDER BY id ASC";
        
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            boolean first = true;
            while (rs.next()) {
                if (!first) {
                    json.append(",");
                }
                first = false;
                
                json.append("{")
                    .append("\"id\":").append(rs.getInt("id")).append(",")
                    .append("\"name\":\"").append(escape(rs.getString("name"))).append("\",")
                    .append("\"category\":\"").append(escape(rs.getString("category"))).append("\",")
                    .append("\"price\":").append(rs.getDouble("price")).append(",")
                    .append("\"stockQty\":").append(rs.getInt("stock_qty")).append(",")
                    .append("\"imageUrl\":\"").append(escape(rs.getString("image_url"))).append("\",")
                    .append("\"description\":\"").append(escape(rs.getString("description"))).append("\"")
                    .append("}");
            }
        } catch (SQLException e) {
            System.err.println("[DB] Error loading menu items: " + e.getMessage());
            e.printStackTrace();
        }
        
        json.append("]}");
        out.print(json.toString());
        out.flush();
    }
    
    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }
}