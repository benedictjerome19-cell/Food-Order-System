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
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

@WebServlet("/api/v1/debug/db")
public class DbCheckServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject result = new JsonObject();
        result.addProperty("envUrlDetected", DBConnectionManager.isEnvUrlDetected());
        result.addProperty("configuredTarget", DBConnectionManager.getLastConfiguredTarget());
        result.addProperty("configuredUser", DBConnectionManager.getConfiguredUser());

        JsonArray tablesList = new JsonArray();

        try (Connection conn = DBConnectionManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name")) {

            while (rs.next()) {
                tablesList.add(rs.getString("table_name"));
            }
            result.addProperty("success", true);
            result.add("tables", tablesList);
            result.addProperty("message", "Connected successfully to PostgreSQL database!");
        } catch (Exception e) {
            result.addProperty("success", false);
            result.addProperty("error", e.getMessage());
            result.addProperty("lastInitError", DBConnectionManager.getLastErrorMessage());
        }

        resp.getWriter().write(new Gson().toJson(result));
    }
}