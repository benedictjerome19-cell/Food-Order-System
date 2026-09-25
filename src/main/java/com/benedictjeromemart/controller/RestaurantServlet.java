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

@WebServlet("/api/v1/restaurants")
public class RestaurantServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        
        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true,\"data\":[");
        
        String sql = "SELECT id, name, cuisine_type FROM restaurants";
        
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                
                json.append("{")
                    .append("\"id\":").append(rs.getInt("id")).append(",")
                    .append("\"name\":\"").append(rs.getString("name")).append("\",")
                    .append("\"cuisineType\":\"").append(rs.getString("cuisine_type")).append("\"")
                    .append("}");
            }
        } catch (SQLException e) {
            // Fallback default restaurant if table doesn't exist yet
            json.append("{\"id\":1,\"name\":\"Benedict Partner Kitchen\",\"cuisineType\":\"Multicuisine\"}");
        }
        
        json.append("]}");
        out.print(json.toString());
        out.flush();
    }
}