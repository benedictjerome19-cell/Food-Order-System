package com.benedictjeromemart.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.benedictjeromemart.util.DBConnectionManager;
import com.google.gson.JsonObject;

@WebServlet(name = "HealthServlet", urlPatterns = {"/health", "/api/v1/health", "/api/health"})
public class HealthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        JsonObject json = new JsonObject();
        json.addProperty("status", "UP");
        json.addProperty("service", "BenedictJeromeMart");

        try (Connection conn = DBConnectionManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT count(*) FROM information_schema.tables WHERE table_schema='public'")) {

            int tableCount = rs.next() ? rs.getInt(1) : 0;
            json.addProperty("database", "CONNECTED");
            json.addProperty("publicTables", tableCount);
            resp.setStatus(HttpServletResponse.SC_OK);
        } catch (Exception e) {
            json.addProperty("database", "DISCONNECTED");
            json.addProperty("error", e.getMessage());
            resp.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        }

        resp.getWriter().write(json.toString());
    }
}
