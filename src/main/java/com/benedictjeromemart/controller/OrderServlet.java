package com.benedictjeromemart.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.benedictjeromemart.util.DBConnectionManager;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

@WebServlet(urlPatterns = {"/orders", "/api/orders"})
public class OrderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        // 1. Verify/Initialize user session securely
        HttpSession session = req.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            userId = 1; // Fallback default user ID
            session.setAttribute("userId", userId);
        }

        try {
            // Read incoming JSON body from frontend cart/checkout
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = req.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }

            String payload = sb.toString().trim();
            double totalAmount = 0.0;
            JsonArray items = new JsonArray();

            if (!payload.isEmpty()) {
                JsonObject body = JsonParser.parseString(payload).getAsJsonObject();
                totalAmount = body.has("total") && !body.get("total").isJsonNull() ? body.get("total").getAsDouble() : 0.0;
                if (body.has("items") && body.get("items").isJsonArray()) {
                    items = body.getAsJsonArray("items");
                }
            }

            // 2. Insert order record and order items atomically
            String orderSql = "INSERT INTO orders (buyer_id, restaurant_id, total_amount, status) VALUES (?, 1, ?, 'CONFIRMED')";
            // Updated SQL statement to include both unit_price and price to satisfy database constraints
            String itemSql = "INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price, price) VALUES (?, ?, ?, ?, ?)";

            try (Connection conn = DBConnectionManager.getConnection()) {
                conn.setAutoCommit(false); // Begin transaction

                long orderId = -1;
                try (PreparedStatement stmt = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                    stmt.setInt(1, userId);
                    stmt.setDouble(2, totalAmount);
                    int affectedRows = stmt.executeUpdate();

                    if (affectedRows > 0) {
                        try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                            if (generatedKeys.next()) {
                                orderId = generatedKeys.getLong(1);
                            }
                        }
                    }
                }

                if (orderId == -1) {
                    conn.rollback();
                    resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"success\": false, \"message\": \"Failed to generate order ID.\"}");
                    out.flush();
                    return;
                }

                // Insert individual cart items into order_items table
                try (PreparedStatement itemStmt = conn.prepareStatement(itemSql)) {
                    for (JsonElement element : items) {
                        JsonObject itemObj = element.getAsJsonObject();
                        int menuItemId = itemObj.has("id") ? itemObj.get("id").getAsInt() : 1;
                        int quantity = itemObj.has("quantity") ? itemObj.get("quantity").getAsInt() : 1;
                        double price = itemObj.has("price") ? itemObj.get("price").getAsDouble() : 0.0;

                        itemStmt.setLong(1, orderId);
                        itemStmt.setInt(2, menuItemId);
                        itemStmt.setInt(3, quantity);
                        itemStmt.setDouble(4, price); // unit_price
                        itemStmt.setDouble(5, price); // price
                        itemStmt.addBatch();
                    }
                    itemStmt.executeBatch();
                }

                // Clear cart from session after successful order
                session.removeAttribute("cart");

                conn.commit(); // Commit transaction successfully
                out.print("{\"success\": true, \"message\": \"Order placed successfully!\", \"orderId\": " + orderId + "}");

            } catch (SQLException e) {
                e.printStackTrace();
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                String safeMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"").replace("\n", " ") : "Database error";
                out.print("{\"success\": false, \"message\": \"Database error: " + safeMsg + "\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            String safeMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"").replace("\n", " ") : "Invalid payload";
            out.print("{\"success\": false, \"message\": \"Invalid order payload format: " + safeMsg + "\"}");
        }

        out.flush();
    }
}